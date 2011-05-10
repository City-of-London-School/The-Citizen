//
//  FileManager.m
//  Locations
//
//  Created by Harry Maclean on 15/01/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import "FileManager.h"


@implementation FileManager
@synthesize eventsArray, managedObjectContext, delegate;

- (void)setup:(NSString *)context {
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSError * error = nil;
	NSMutableArray * mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"fetch error: %@", [error description]);
	}
	[self setEventsArray:mutableFetchResults];
	[mutableFetchResults release];
	[request release];
	if ([context isEqualToString:@"do_not_autodownload"]) {
		[self cleanDB];
	}
	downloadManager = [[DownloadPDF alloc] init];
	[downloadManager setDownloadPDFDelegate:(id<DownloadPDFDelegate>)self];
	if (![context isEqualToString:@"do_not_autodownload"]) {
		if ([DownloadPDF connectedToInternet]) {
			[self downloadFileList];
		}
		else {
			[DownloadPDF showNetworkError];
		}
	}

}

- (void)downloadFileList {
	[downloadManager downloadFile:@"files.txt"];
}

#pragma mark -
#pragma mark DownloadPDF Delegate 

- (void)fileWasDownloaded:(NSString *)filename {
	NSLog(@"fileWasDownloaded");
	if (filename == @"files.txt") {
		[self updateTable];
	}
	else {
		filename = [[filename componentsSeparatedByString:@".pdf"] objectAtIndex:0];
		Event * event = [self findEvent:filename];
		event.existsLocally = [NSNumber numberWithBool:YES];
		NSError * error = nil;
		if (![managedObjectContext save:&error]) {
			NSLog(@"error saving context: %@", [error description]);
		}
		[delegate updateTableView]; // delegate calls [self.tableView reloadData]
	}
	
}

- (void)fileDownload:(NSString *)filename hasProgressedBy:(NSNumber *)amount {
	NSString * remoteFile = [[self remoteFileList] objectAtIndex:indexOfCurrentlyDownloadingFile];
	if ([remoteFile isEqualToString:filename]) {
		[delegate downloadAtIndex:indexOfCurrentlyDownloadingFile hasProgressedBy:amount];
	}
	else {
		int index = [self findIndexOfEventWithFilename:filename];
		indexOfCurrentlyDownloadingFile = index;
		[delegate downloadAtIndex:index hasProgressedBy:amount];
	}
}

#pragma mark -
#pragma mark File Management

- (void)updateTable {
	NSArray * remoteFileList = [self remoteFileList];
	NSArray * localFileList = [self localFileList];
	localFileList = [self reverseArray:localFileList];
	if ([remoteFileList isEqualToArray:localFileList]) {
		NSLog(@"no new events");
	}
	else {
		NSLog(@"new events available");
		NSArray * newEvents = [self findNewEvents];
		if (newEvents) {
			[self addNewEvents:newEvents];
		}
	}
}

- (NSArray *)localFileList {
	NSArray * localFileList = nil;
	if ([eventsArray count] == 0) {
		return localFileList;
	}
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	for (Event * event in eventsArray) {
		[temp addObject:event.pdfPath];
	}
	localFileList = [temp copy];
	[temp release];
	return localFileList;
}

- (NSArray *)remoteFileList {
	NSString * remoteFileString = [NSString stringWithContentsOfFile:[DownloadPDF getLocalDocPath:@"files.txt"] encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray * remoteFileList = [[remoteFileString componentsSeparatedByString:@"\n"] mutableCopy];
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	for (NSString * str in remoteFileList) {
		str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		[temp insertObject:str atIndex:0];
	}
	[remoteFileList release];
	return (NSArray *)temp;
}

- (void)cleanDB {
	Event *prevEvent = nil;
	for (Event *event in self.eventsArray) {
		NSLog(@"Event: %@", event.pdfPath);
		if (prevEvent && [prevEvent.pdfPath isEqualToString:event.pdfPath] || event.pdfPath == nil || [event.pdfPath isEqualToString:@""] || event.date == nil) {
			NSLog(@"deleting %@", event.pdfPath);
			[managedObjectContext deleteObject:event];
		}
		prevEvent = event;
	}
}

-(NSArray *)nestedArray {
	NSArray *years = [[self years] copy];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	NSMutableArray *result = [[NSMutableArray alloc] init];
	for (NSString * year in years) {
		[dateFormatter setDateFormat:@"yyyy"];
		NSDate *startDate = [dateFormatter dateFromString:year];
		NSLog(@"date from string %@ = %@", year, startDate);
		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.month = 11;
		components.day = 30;
		NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:startDate options:0];
		[components release];
		NSArray *events = [self fetchEventsFromDate:startDate toDate:endDate];
		NSArray *months = [self monthsForEvents:events];
		[dateFormatter setDateFormat:@"yyyy-MM"];
		NSMutableArray * monthResult = [[NSMutableArray alloc] init];
		for (NSString * month in months) {
			startDate = [dateFormatter dateFromString:[year stringByAppendingFormat:@"-%@", month]];
			NSRange daysRange = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:startDate];
			NSDateComponents *components = [[NSDateComponents alloc] init];
			components.day = daysRange.length;
			NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:startDate options:0];
			[components release];
			NSArray *events = [self fetchEventsFromDate:startDate toDate:endDate];
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:month, @"month", events, @"array", nil];
			[monthResult addObject:dict];
		}
		[result addObject:[NSDictionary dictionaryWithObjectsAndKeys:year, @"year", monthResult, @"array", nil]];
	}
	return result;
}

- (NSArray *)fetchEventsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
	NSLog(@"startDate: %@ endDate: %@", startDate, endDate);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext]];
	[request setPredicate:predicate];
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	NSError *error = nil;
	return [managedObjectContext executeFetchRequest:request error:&error];
}
/*
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
 NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
 [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext]];
 [request setPredicate:predicate];
 
 NSError *error = nil;
 NSArray *results = [moc executeFetchRequest:request error:&error];
 */
- (NSArray *)years {
	NSMutableArray * arr = [[NSMutableArray alloc] init];
	NSString * str;
	for (Event * event in eventsArray) {
		str = [[event.date description] substringToIndex:4];
		if (![self string:str existsInArray:arr]) {
			[arr addObject:str];
		}
	}
	return arr;
}

- (NSArray *)monthsForEvents:(NSArray *)events {
	NSMutableArray * arr = [[NSMutableArray alloc] init];
	NSString * str;
	for (Event * event in events) {
		str = [[event.date description] substringWithRange:NSMakeRange(5,2)];
		NSLog(@"month: %@", str);
		if (![self string:str existsInArray:arr]) {
			[arr addObject:str];
		}
	}
	return arr;
}

- (BOOL)string:(NSString *)string existsInArray:(NSArray *)array {
	for (NSString * str in array) {
		if ([str isEqualToString:string]) {
			return YES;
		}
	}
	return NO;
}

#pragma mark -
#pragma mark Event

- (void)addEvent:(NSString *)filename {
	
	Event * event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
	
	[event setPdfPath:filename];
	[event setExistsLocally:[NSNumber numberWithBool:NO]];
	
	NSString * dateString = [filename stringByReplacingOccurrencesOfString:@"citizen" withString:@""];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate * date = [dateFormatter dateFromString:dateString];
	NSLog(@"%@", date);
	[event setDate:date];

	
	NSError * error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle error
		NSLog(@"error saving object");
	}
	
	[eventsArray insertObject:event atIndex:0];
	NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[delegate eventWasAdded:indexPath];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (NSArray *)findNewEvents {
	NSArray * localFileList = [self localFileList];
	if ([localFileList count] == 0) {
		return [self remoteFileList];
	}
	else {
		NSMutableArray * temp = [[NSMutableArray alloc] init];
		for (NSString * str in [self remoteFileList]) {
			BOOL exists = NO;
			for (NSString * filename in localFileList) {
				if ([filename isEqualToString:str]) {
					exists = YES;
				}
			}
			if (!exists) {
				[temp addObject:str];
			}
		}
		NSArray * newEvents = [temp copy];
		[temp release];
		return newEvents;
	}
}

- (void)addNewEvents:(NSArray *)newEvents {
	for (NSString * filename in newEvents) {
		[self addEvent:filename];
	}
}

- (Event *)findEvent:(NSString *)pdfPath {
	for (Event * event in eventsArray) {
		if ([event.pdfPath isEqualToString:pdfPath]) {
			return event;
		}
	}
	return nil;
}

- (void)deleteEventAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject * eventToDelete = [eventsArray objectAtIndex:indexPath.row];
	[managedObjectContext deleteObject:eventToDelete];
	[eventsArray removeObjectAtIndex:indexPath.row];
	NSError * error = nil;
	if (![managedObjectContext save:&error]) {
		NSLog(@"error: %@", [error description]);
	}
}

- (void)downloadEvent:(Event *)event{
	[downloadManager downloadFile:[event.pdfPath stringByAppendingFormat:@".pdf"]];
}

- (Event *)mostRecentEvent {
	NSArray * events = [self eventsArray];
	Event * anEvent = [events objectAtIndex:0];
	NSLog(@"%@", anEvent.date);
	return anEvent;
}

#pragma mark -
#pragma mark Helper Methods

- (NSArray *)reverseArray:(NSArray *)arr {
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[arr count]];
    NSEnumerator * enumerator = [arr reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

- (BOOL)array:(NSArray *)arrayOne isEqualToArray:(NSArray *)arrayTwo {
	for (int i = 0; i < [arrayOne count]; i++) {
		if (![[arrayOne objectAtIndex:i] isEqualToString:[arrayTwo objectAtIndex:i]]) {
			return FALSE;
		}
	}
	return TRUE;
}

- (int)findIndexOfEventWithFilename:(NSString *)filename {
	filename = [filename stringByDeletingPathExtension];
	NSArray * remoteFileList = [self reverseArray:[self remoteFileList]];
	for (int i = 0; i < [remoteFileList count]; i++) {
		if ([filename isEqualToString:[remoteFileList objectAtIndex:i]]) {
			return i;
		}
	}
	return nil;
}

@end

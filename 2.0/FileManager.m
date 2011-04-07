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
		// Handle the error.
		NSLog(@"fetch error: %@", [error description]);
	}
	[self setEventsArray:mutableFetchResults];
	[mutableFetchResults release];
	[request release];
	
	downloadManager = [[DownloadPDF alloc] init];
	[downloadManager setDownloadPDFDelegate:(id<DownloadPDFDelegate>)self];
	if ([DownloadPDF connectedToInternet]) {
		[self downloadFileList];
	}
	else {
		[DownloadPDF showNetworkError];
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
				if (filename == str) {
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

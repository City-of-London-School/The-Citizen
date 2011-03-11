//
//  RootViewController.m
//  Locations
//
//  Created by Harry Maclean on 12/01/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import "RootViewController.h"
#import "MyTableViewCell.h"
#import "ContentViewController.h"


@implementation RootViewController
@synthesize managedObjectContext, fileManager, addButton;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Locations";
	//self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	addButton.enabled = YES;
	self.navigationItem.rightBarButtonItem = addButton;
	
//	NSFetchRequest * request = [[NSFetchRequest alloc] init];
//	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
//	[request setEntity:entity];
//	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pdfPath" ascending:NO];
//	NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//	[request setSortDescriptors:sortDescriptors];
//	[sortDescriptors release];
//	[sortDescriptor release];
//	
//	NSError * error = nil;
//	NSMutableArray * mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
//	if (mutableFetchResults == nil) {
//		// Handle the error.
//		NSLog(@"fetch error: %@", [error description]);
//	}
//	[self setEventsArray:mutableFetchResults];
//	[mutableFetchResults release];
//	[request release];
//	
//	downloadManager = [[DownloadPDF alloc] init];
//	[downloadManager setDownloadPDFDelegate:(id<DownloadPDFDelegate>)self];
//	[downloadManager downloadFile:@"files.txt"];
	fileManager = [[FileManager alloc] init];
	fileManager.managedObjectContext = self.managedObjectContext;
	[fileManager setDelegate:self];
	[fileManager setup];
}

- (void)refresh {
	[fileManager updateTable];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
    //return [eventsArray count];
	return [fileManager.eventsArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//	static NSDateFormatter * dateFormatter = nil;
//	if (dateFormatter == nil) {
//		dateFormatter = [[NSDateFormatter alloc] init];
//		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
//		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//	}
//	
//	static NSNumberFormatter * numberFormatter = nil;
//	if (numberFormatter == nil) {
//		numberFormatter = [[NSNumberFormatter alloc] init];
//		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//		[numberFormatter setMaximumFractionDigits:3];
//	}
    
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//MyTableViewCell * cell = (MyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		//NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyTableViewCell" owner:nil options:nil];
//		for (id currentObject in topLevelObjects) {
//			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
//				cell = (MyTableViewCell *) currentObject;
//				break;
//			}
//		}
		
    }
    
	//cell.opaque = YES;
//	cell.button.tag = indexPath.row;
//	[cell.button addTarget:self action:@selector(downloadEventAtButton::) forControlEvents:UIControlEventTouchUpInside];
//	UIImage * img = [UIImage imageNamed:@"download_button.png"];
//	[cell.button setImage:img forState:UIControlStateNormal];
//	cell.button.alpha = 1;
//	cell.button.enabled = NO;
	
    Event * event = (Event *)[fileManager.eventsArray objectAtIndex:indexPath.row];
	cell.textLabel.text = event.pdfPath;
	cell.textLabel.textColor = [UIColor lightGrayColor];
	if ([event.existsLocally boolValue]) {
		//cell.button.alpha = 0;
		cell.textLabel.textColor = [UIColor blackColor];
	}
	//if ([DownloadPDF connectedToInternet]) {
//		cell.button.enabled = YES;
//	}
	
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	// Return NO for cells that have events that aren't downloaded
	Event * event = (Event *)[fileManager.eventsArray objectAtIndex:indexPath.row];
	if (event.existsLocally) {
		return YES;
	}
    else {
		return NO;
	}

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //NSManagedObject * eventToDelete = [eventsArray objectAtIndex:indexPath.row];
//		[managedObjectContext deleteObject:eventToDelete];
//		
//		[eventsArray removeObjectAtIndex:indexPath.row];
		[fileManager deleteEventAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
//		NSError * error = nil;
//		if (![managedObjectContext save:&error]) {
//			// Handle the error
//			NSLog(@"error: %@", [error description]);
//		}
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)downloadEventAtButton:(UIButton *)sender {
	int row = sender.tag;
	Event * event = [fileManager.eventsArray objectAtIndex:row];
	[fileManager downloadEvent:event];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	 
	 
	Event * event = [fileManager.eventsArray objectAtIndex:indexPath.row];
	if ([event.existsLocally boolValue]) {
		ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
		contentViewController.filename = [event.pdfPath stringByAppendingString:@".pdf"];
		NSLog(@"%@", event.pdfPath);
		[self.navigationController pushViewController:contentViewController animated:YES];
		[contentViewController release];
	}
	else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		// Download PDF
		//[fileManager downloadEvent:event];
		//[downloadManager downloadFile:[event.pdfPath stringByAppendingFormat:@".pdf"]];
	}

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	Event * event = [fileManager.eventsArray objectAtIndex:indexPath.row];
	if ([event.existsLocally boolValue]) {
		ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
		contentViewController.filename = [event.pdfPath stringByAppendingString:@".pdf"];
		NSLog(@"%@", event.pdfPath);
		[self.navigationController pushViewController:contentViewController animated:YES];
		[contentViewController release];
	}
	else {
		// Download PDF
		[fileManager downloadEvent:event];
		//[downloadManager downloadFile:[event.pdfPath stringByAppendingFormat:@".pdf"]];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.addButton = nil;
}


- (void)dealloc {
	[addButton release];
	[super dealloc];
}

//#pragma mark -
//#pragma mark Event
//
//- (void)addEvent:(NSString *)filename {
//	
//	Event * event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
//	
//	[event setPdfPath:filename];
//	[event setExistsLocally:[NSNumber numberWithBool:NO]];
//	
//	NSError * error = nil;
//	if (![managedObjectContext save:&error]) {
//		// Handle error
//		NSLog(@"error saving object");
//	}
//	
//	[eventsArray insertObject:event atIndex:0];
//	NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//}
//
//- (NSArray *)findNewEvents {
//	NSArray * localFileList = [self localFileList];
//	if ([localFileList count] == 0) {
//		return [self remoteFileList];
//	}
//	else {
//		NSMutableArray * temp = [[NSMutableArray alloc] init];
//		for (NSString * str in [self remoteFileList]) {
//			BOOL exists = NO;
//			for (NSString * filename in localFileList) {
//				if (filename == str) {
//					exists = YES;
//				}
//			}
//			if (!exists) {
//				[temp addObject:str];
//			}
//		}
//		NSArray * newEvents = [temp copy];
//		[temp release];
//		return newEvents;
//	}
//}
//
//- (void)addNewEvents:(NSArray *)newEvents {
//	for (NSString * filename in newEvents) {
//		[self addEvent:filename];
//	}
//}
//
//- (Event *)findEvent:(NSString *)pdfPath {
//	for (Event * event in eventsArray) {
//		if ([event.pdfPath isEqualToString:pdfPath]) {
//			return event;
//		}
//	}
//	return nil;
//}
//
//#pragma mark -
//#pragma mark File Management
//
//- (void)updateTable {
//	NSArray * remoteFileList = [self remoteFileList];
//	NSArray * localFileList = [self localFileList];
//	localFileList = [self reverseArray:localFileList];
//	if ([remoteFileList isEqualToArray:localFileList]) {
//		NSLog(@"no new events");
//	}
//	else {
//		NSLog(@"new events available");
//		NSArray * newEvents = [self findNewEvents];
//		if (newEvents) {
//			[self addNewEvents:newEvents];
//		}
//	}
//}
//
//- (NSArray *)localFileList {
//	NSArray * localFileList = nil;
//	if ([eventsArray count] == 0) {
//		return localFileList;
//	}
//	NSMutableArray * temp = [[NSMutableArray alloc] init];
//	for (Event * event in eventsArray) {
//		[temp addObject:event.pdfPath];
//	}
//	localFileList = [temp copy];
//	[temp release];
//	return localFileList;
//}
//
//- (NSArray *)remoteFileList {
//	NSString * remoteFileString = [NSString stringWithContentsOfFile:[downloadManager getLocalDocPath:@"files.txt"] encoding:NSUTF8StringEncoding error:NULL];
//	NSMutableArray * remoteFileList = [[remoteFileString componentsSeparatedByString:@"\n"] mutableCopy];
//	NSMutableArray * temp = [[NSMutableArray alloc] init];
//	for (NSString * str in remoteFileList) {
//		str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//		[temp insertObject:str atIndex:0];
//	}
//	[remoteFileList release];
//	return [temp copy];
//}
//
//#pragma mark -
//#pragma mark DownloadPDF Delegate 
//
//- (void)fileWasDownloaded:(NSString *)filename {
//	if (filename == @"files.txt") {
//		[self updateTable];
//	}
//	else {
//		filename = [[filename componentsSeparatedByString:@".pdf"] objectAtIndex:0];
//		Event * event = [self findEvent:filename];
//		event.existsLocally = [NSNumber numberWithBool:YES];
//		NSError * error = nil;
//		if (![managedObjectContext save:&error]) {
//			NSLog(@"error saving context: %@", [error description]);
//		}
//		[self.tableView reloadData];
//	}
//
//}
//
//#pragma mark -
//#pragma mark Helper Methods
//
//- (NSArray *)reverseArray:(NSArray *)arr {
//    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[arr count]];
//    NSEnumerator * enumerator = [arr reverseObjectEnumerator];
//    for (id element in enumerator) {
//        [array addObject:element];
//    }
//    return array;
//}

#pragma mark -
#pragma mark FileManager Delegate

- (void)updateTableView {
	NSLog(@"updateTable");
	[self.tableView reloadData];
}

- (void)eventWasAdded:(NSIndexPath *)indexPath {
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end


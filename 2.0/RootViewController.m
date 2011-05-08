//
//  RootViewController.m
//  The Citizen
//
//  Created by Harry Maclean on 08/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import "RootViewController.h"
#import "ContentViewController.h"
#import "ProgressCell.h"


@implementation RootViewController
@synthesize managedObjectContext, fileManager, addButton;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"The Citizen";
	
	fileManager = [[FileManager alloc] init];
	fileManager.managedObjectContext = self.managedObjectContext;
	[fileManager setDelegate:self];
	[fileManager setup:@""];
}

- (void)refresh {
	if ([DownloadPDF connectedToInternet]) {
		[fileManager updateTable];
	}
	else {
		[DownloadPDF showNetworkError];
	}
}

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
    static NSString *CellIdentifier = @"ProgressCell";
	ProgressCell * cell = (ProgressCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProgressCell" owner:nil options:nil];
		for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[ProgressCell class]]) {
				cell = (ProgressCell *) currentObject;
				break;
			}
		}
    }
    cell.progressView.alpha = 0;
	cell.textLabel.backgroundColor = [UIColor whiteColor];
	cell.textLabel.opaque = YES;
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0]; 
	cell.textLabel.alpha = 1;
    Event * event = (Event *)[fileManager.eventsArray objectAtIndex:indexPath.row];
	
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"dd MMMM, yyyy"];
	NSString * stringLabel = [df stringFromDate:event.date];
		
	cell.textLabel.text = stringLabel;
	cell.textLabel.textColor = [UIColor lightGrayColor];
	if ([event.existsLocally boolValue]) {
		cell.textLabel.textColor = [UIColor blackColor];
	}
	if ([[downloadProgress objectForKey:@"index"] floatValue] == indexPath.row) {
		[cell incrementProgressBarByAmount:[[downloadProgress objectForKey:@"amount"] floatValue]];
	}
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	// Return NO for cells that have events that aren't downloaded
		return NO;


}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //NSManagedObject * eventToDelete = [eventsArray objectAtIndex:indexPath.row];
//		[managedObjectContext deleteObject:eventToDelete];
//		
//		[eventsArray removeObjectAtIndex:indexPath.row];
			//[fileManager deleteEventAtIndexPath:indexPath];
			//[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
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
		NSString * path = [[DownloadPDF getLocalDocPath:event.pdfPath] stringByAppendingString:@".pdf"];
		CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
		contentViewController.pdf = pdf;
		[self.navigationController pushViewController:contentViewController animated:YES];
		[contentViewController release];
	}
	else {
		if (downloadInProgress) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
		else {
			if ([DownloadPDF connectedToInternet] && !downloadInProgress) {
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				[[[tableView cellForRowAtIndexPath:indexPath] progressView] setProgress:0];
				[[[tableView cellForRowAtIndexPath:indexPath] progressView] setAlpha:1];
				[[[tableView cellForRowAtIndexPath:indexPath] textLabel] setAlpha:0];
				downloadInProgress = YES;
				[fileManager downloadEvent:event];
			}
			else if (![DownloadPDF connectedToInternet]) {
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				[DownloadPDF showNetworkError];
			}
		}

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


#pragma mark -
#pragma mark FileManager Delegate

- (void)updateTableView {
	NSLog(@"updateTable");
	[self.tableView reloadData];
	downloadInProgress = NO;
}

- (void)eventWasAdded:(NSIndexPath *)indexPath {
	[self.tableView beginUpdates];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)downloadAtIndex:(int)index hasProgressedBy:(NSNumber *)amount {
	NSUInteger indexArr[] = {0, index};
	NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
	
	ProgressCell * cell = (ProgressCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell incrementProgressBarByAmount:[amount floatValue]];
}

@end


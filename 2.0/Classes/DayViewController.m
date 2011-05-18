//
//  DayViewController.m
//  The Citizen
//
//  Created by Harry Maclean on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DayViewController.h"
#import "ContentViewController.h"
#import "ProgressCell.h"

@implementation DayViewController
@synthesize managedObjectContext, fileManager, addButton, nestedArray, yearIndex, monthIndex;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM"];
	NSString *dateNum = [[[[nestedArray objectAtIndex:yearIndex] objectForKey:@"array"] objectAtIndex:monthIndex] objectForKey:@"month"];
	NSDate * monthDate = [dateFormatter dateFromString:dateNum];
	[dateFormatter setDateFormat:@"MMMM"];
	self.title = [dateFormatter stringFromDate:monthDate];
	[dateFormatter release];
	fileManager = [[FileManager alloc] init];
	fileManager.managedObjectContext = self.managedObjectContext;
	[fileManager setDelegate:self];
	[fileManager setup:@"do_not_autodownload"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[[[[nestedArray objectAtIndex:yearIndex] objectForKey:@"array"] objectAtIndex:monthIndex] objectForKey:@"array"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgressCell";
    
    ProgressCell *cell = (ProgressCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:20.0];
	cell.textLabel.alpha = 1;
	
	Event * event = [[[[[nestedArray objectAtIndex:yearIndex] objectForKey:@"array"] objectAtIndex:monthIndex] objectForKey:@"array"] objectAtIndex:indexPath.row];
    
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"dd MMMM"];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)downloadEventAtButton:(UIButton *)sender {
	int row = sender.tag;
	Event * event = [fileManager.eventsArray objectAtIndex:row];
	[fileManager downloadEvent:event];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Event * event = [[[[[nestedArray objectAtIndex:yearIndex] objectForKey:@"array"] objectAtIndex:monthIndex] objectForKey:@"array"] objectAtIndex:indexPath.row];
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
#pragma mark FileManager Delegate

- (void)updateTableView {
	[self.tableView reloadData];
	downloadInProgress = NO;
}

- (void)eventWasAdded:(NSIndexPath *)indexPath {
//	[self.tableView beginUpdates];
//	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//	[self.tableView endUpdates];
//	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	self.nestedArray = [fileManager nestedArray];
	[self.tableView reloadData];
	[super updateTable:nestedArray];
}

- (void)downloadAtIndex:(int)index hasProgressedBy:(NSNumber *)amount {
	NSUInteger indexArr[] = {0, index};
	NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
	
	ProgressCell * cell = (ProgressCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell incrementProgressBarByAmount:[amount floatValue]];
}


@end

//
//  HomeViewController.m
//  The Citizen
//
//  Created by Harry Maclean on 13/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import "HomeViewController.h"
#import "RootViewController.h"
#import "ContentViewController.h"
#import "ProgressCell.h"


@implementation HomeViewController
@synthesize managedObjectContext;

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

	self.title = @"The Citizen";
	
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 1) {
		static NSString *CellIdentifier = @"Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.textLabel.text = @"Previous";
		NSLog(@"%@", [cell.textLabel.font description]);
		return cell;
    }
	else {
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
		cell.textLabel.alpha = 1;
		cell.textLabel.text = @"Most Recent";
		cell.textLabel.textColor = [UIColor blackColor];
		UIFont * font = [UIFont boldSystemFontOfSize:20];
		cell.textLabel.font = font;
		return cell;
	}
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 1) {
		RootViewController * rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
		rootViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:rootViewController animated:YES];
		[rootViewController release];
	}
	else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		Event * event = [fileManager mostRecentEvent];
		if ([event.existsLocally boolValue]) {
			ContentViewController * contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
			NSString * path = [[DownloadPDF getLocalDocPath:event.pdfPath] stringByAppendingString:@".pdf"];
			CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
			contentViewController.pdf = pdf;
			[self.navigationController pushViewController:contentViewController animated:YES];
			[contentViewController release];
		}
		else {
			NSLog(@"file not downloaded..");
			if ([DownloadPDF connectedToInternet]) {
				// Download the article
				[fileManager downloadEvent:event];
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			}
		}
	}
}

- (void)loadMostRecentArticle {
	Event * event = [fileManager mostRecentEvent];
	if ([event.existsLocally boolValue]) {
		ContentViewController * contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
		NSString * path = [[DownloadPDF getLocalDocPath:event.pdfPath] stringByAppendingString:@".pdf"];
		CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
		contentViewController.pdf = pdf;
		[self.navigationController pushViewController:contentViewController animated:YES];
		[contentViewController release];
	}

}

#pragma -
#pragma File Manager Delegate Methods

- (void)downloadAtIndex:(int)index hasProgressedBy:(NSNumber *)amount {
	NSUInteger indexArr[] = {0, index};
	NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
	ProgressCell * cell = (ProgressCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell incrementProgressBarByAmount:[amount floatValue]];
}

- (void)eventWasAdded:(NSIndexPath *)indexPath {
	
}

- (void)updateTableView {
	[self loadMostRecentArticle];
}

@end

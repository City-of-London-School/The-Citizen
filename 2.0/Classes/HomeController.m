//
//  HomeController.m
//  The Citizen
//
//  Created by Harry Maclean on 12/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeController.h"
#import "ContentViewController.h"
#import "YearViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation HomeController
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

- (void)dealloc
{
	[mostRecentButton release];
	[previousButton release];
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
	
	mostRecentButton.layer.borderWidth = 1.0f;
	mostRecentButton.layer.cornerRadius = 8.0f;
//	mostRecentButton.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.02].CGColor;
	previousButton.layer.borderWidth = 1.0f;
	previousButton.layer.cornerRadius = 8.0f;
//	previousButton.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.02].CGColor;
	mostRecentButton.layer.masksToBounds = YES;
	
	self.title = @"The Citizen";
	fileManager = [[FileManager alloc] init];
	fileManager.managedObjectContext = self.managedObjectContext;
	[fileManager setDelegate:self];
	[fileManager setup:@""];
}

- (void)viewDidUnload
{
	[mostRecentButton release];
	mostRecentButton = nil;
	[previousButton release];
	previousButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)mostRecentButtonClicked:(id)sender {
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
		NSLog(@"file needs to be downloaded: %@", event.pdfPath);
		if ([DownloadPDF connectedToInternet]) {
			[fileManager downloadEvent:event];
		}
	}
}

- (IBAction)previousButtonClicked:(id)sender {
	YearViewController *yearViewController = [[YearViewController alloc] initWithNibName:@"YearViewController" bundle:nil];
	yearViewController.managedObjectContext = self.managedObjectContext;
	yearViewController.nestedArray = [fileManager nestedArray];
	[self.navigationController pushViewController:yearViewController animated:YES];
	[yearViewController release];
}

#pragma mark -
#pragma mark File Manager Delegate

- (void)updateTableView {
	[self loadMostRecentArticle];
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

- (void)eventWasAdded:(NSIndexPath *)indexPath {
	
}

- (void)downloadAtIndex:(int)index hasProgressedBy:(NSNumber *)amount {
	
}

@end

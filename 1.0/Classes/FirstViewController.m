//
//  firstViewController.m
//  NavigationApp
//
//  Created by Harry Maclean on 01/08/2010.
//  Copyright (c) 2010 City of London School. All rights reserved.
//

#import "FirstViewController.h"
#import "DownloadPDF.h"


@implementation FirstViewController
@synthesize filename;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	DownloadPDF * downloadPDF = [[DownloadPDF alloc] init];
	NSString * filePath = [downloadPDF getLocalDocPath:filename];
	[downloadPDF release];
	NSURL * pdfUrl = [NSURL fileURLWithPath:filePath];
	webView.scalesPageToFit = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[webView loadRequest:[NSURLRequest requestWithURL:pdfUrl]];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

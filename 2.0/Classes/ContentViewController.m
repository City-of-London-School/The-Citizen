//
//  ContentViewController.m
//  
//
//  Created by Harry Maclean on 05/02/2011.
//  Copyright City of London School 2011. All rights reserved.
//

#import "ContentViewController.h"
#import "HMTiledView.h"

@implementation ContentViewController
@synthesize pdf;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

#define PADDING 20
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	currentPage = 1;
	int numberOfPages = CGPDFDocumentGetNumberOfPages(pdf);

	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	int navBarHeight = self.navigationController.navigationBar.frame.size.height;
	frame.size.height -= navBarHeight;
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.contentSize = CGSizeMake((frame.size.width+PADDING) * numberOfPages, frame.size.height);
	scrollView.pagingEnabled = YES;
	scrollView.backgroundColor = [UIColor grayColor];
	self.view = scrollView;
	
	for (int i = 0; i < numberOfPages; i++) {
		int width = frame.size.width;
		HMTiledView * aView = [[HMTiledView alloc] initWithFrame:CGRectMake(i*(width+PADDING), 0.0, 320.0, frame.size.height)];
		aView.page = CGPDFDocumentGetPage(pdf, i+1);
		[self.view addSubview:aView];
		[aView release];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	CGRect frame = self.view.frame;
	frame.size.width += PADDING;
	self.view.frame = frame;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end

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
@synthesize pdf, navBar;



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

//- (void)loadView {
//
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)renderIssue {
    CGRect deviceFrame = [[UIScreen mainScreen] bounds];
    int deviceWidth = deviceFrame.size.width;
    int deviceHeight = deviceFrame.size.height; // Minus 20px for the status bar
    
    currentPage = 1;
	int numberOfPages = CGPDFDocumentGetNumberOfPages(pdf);
    
    // This is to reset the view frame because it tends to get changed by something when switching from one Issue to another
    CGRect a = CGRectMake(0, 0, deviceWidth, deviceHeight);
    self.view.frame = a;
    
    CGRect frame = self.view.frame;

    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.contentSize = CGSizeMake((frame.size.width+PADDING) * numberOfPages, frame.size.height);
	scrollView.pagingEnabled = YES;
	scrollView.backgroundColor = [UIColor grayColor];
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    
    CGRect f = scrollView.frame;
    f.size.width += PADDING;
    scrollView.frame = f;
    for (UIView *v in [self.view subviews]) {
        [v removeFromSuperview];
    }
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:scrollView];
	
	for (int i = 0; i < numberOfPages; i++) {
		int width = frame.size.width;
		HMTiledView * aView = [[HMTiledView alloc] initWithFrame:CGRectMake(i*(width+PADDING), 0.0, deviceWidth, frame.size.height)];
		aView.page = CGPDFDocumentGetPage(pdf, i+1);
		CGPDFPageRetain(aView.page);	
        [scrollView addSubview:aView];
	}
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

@end

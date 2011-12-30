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

- (void)viewDidLoad {
    [self checkForPDF];
}

- (void)checkForPDF {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	if (self.pdf) {
        [nc removeObserver:self name:@"DYServerIssueDownloadedNotification" object:nil];
        [nc removeObserver:self name:@"DYServerIssuesUpdatedNotification" object:nil];
        [self renderIssue];
    }
    else {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(downloadMostRecentIssue)];
        [nc addObserver:self selector:@selector(getIssuePDFPath) name:@"DYServerIssueDownloadedNotification" object:nil];
        [nc addObserver:self selector:@selector(getIssuePDFPath) name:@"DYServerIssuesUpdatedNotification" object:nil];
//        [nc addObserver:self selector:@selector(checkForPDF) name:@"DYServerIssuesUpdatedNotification" object:nil];
    }
}

- (void)getIssuePDFPath {
    NSURL * path = [[[UIApplication sharedApplication] delegate] performSelector:@selector(mostRecentIssuePDFPath)];
    if (!path)
        return;
    CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)path);
    self.pdf = pdfRef;
    [self renderIssue];
}

- (void)renderIssue {
    CGRect deviceFrame = [[UIScreen mainScreen] bounds];
    int deviceWidth = deviceFrame.size.width;
    int deviceHeight = deviceFrame.size.height -20; // Minus 20px for the status bar
    
    currentPage = 1;
	int numberOfPages = CGPDFDocumentGetNumberOfPages(pdf);
    
    // This is to reset the view frame because it tends to get changed by something when switching from one Issue to another
    CGRect a = CGRectMake(0, 0, deviceWidth, deviceHeight);
    self.view.frame = a;
    
    CGRect frame = self.view.frame;

//    int tabBarHeight = self.tabBarController.tabBar.frame.size.height;
//    frame.size.height -= tabBarHeight;
    // The tab bar can't always be accessed, so here we just use the pixel height and hope it doesn't change between iOS versions...
    int tabBarHeight = 49;
    frame.size.height -= tabBarHeight;
    if (self.navBar) {
//        int navBarHeight = self.navigationController.navigationBar.frame.size.height;
        // The nav bar can't be accessed either, so we'll use a known value for it instead.
        int navBarHeight = 44;
        frame.size.height -= navBarHeight;
    }
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

- (void)viewDidAppear:(BOOL)animated {
    // This is no longer necessary now that scrollView is a subclass of the ViewController's view
    
    // The DYScrollView subclass will ensure it has the correct width so we don't need to change it.
//	CGRect frame = self.view.frame;
//	frame.size.width += PADDING;
//	self.view.frame = frame;
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

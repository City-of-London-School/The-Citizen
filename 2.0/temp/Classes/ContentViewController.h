//
//  ContentViewController.h
//  
//
//  Created by Harry Maclean on 05/02/2011.
//  Copyright City of London School 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController {
	UIScrollView * scrollView;
	CGPDFDocumentRef pdf;
	int currentPage;
}

//- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;
//- (void)swipeLeft;
//- (void)swipeRight;

@property (nonatomic, assign) CGPDFDocumentRef pdf;

@end


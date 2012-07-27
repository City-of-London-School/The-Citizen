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
    BOOL navBar;
}

- (void)renderIssue;

@property (nonatomic, assign) CGPDFDocumentRef pdf;
@property (nonatomic, assign) BOOL navBar;

@end


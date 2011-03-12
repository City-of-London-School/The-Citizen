//
//  HMTiledView.h
//  UIView Test
//
//  Created by Harry Maclean on 23/02/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMViewDelegate.h"


@interface HMTiledView : UIView {
	CGPDFPageRef page;
	UIView * myContentView;
	HMViewDelegate * delegate;
}


@property (nonatomic, assign) CGPDFPageRef page;

@end

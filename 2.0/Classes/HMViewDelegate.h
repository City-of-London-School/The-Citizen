//
//  HMViewDelegate.h
//  test
//
//  Created by Harry Maclean on 06/12/2010.
//  Copyright 2010 City of London School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface HMViewDelegate : NSObject {
	CGRect bounds;
	CGPDFPageRef page;
}

@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CGPDFPageRef page;
@end

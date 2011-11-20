//
//  HMViewDelegate.m
//  test
//
//  Created by Harry Maclean on 06/12/2010.
//  Copyright 2010 City of London School. All rights reserved.
//

#import "HMViewDelegate.h"


@implementation HMViewDelegate
@synthesize bounds, page;

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
	CGContextTranslateCTM(ctx, 0.0, [self bounds].size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, [self bounds], 0, true));
	CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh); 
	CGContextSetRenderingIntent(ctx, kCGRenderingIntentDefault);
	CGContextDrawPDFPage(ctx, page);
}

@end

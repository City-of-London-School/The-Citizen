//
//  HMTiledView.m
//  UIView Test
//
//  Created by Harry Maclean on 23/02/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import "HMTiledView.h"
#import <QuartzCore/QuartzCore.h>


@implementation HMTiledView
@synthesize page;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor grayColor];
    }
    return self;
}



- (void)drawRect:(CGRect)rect { 
	delegate = [[HMViewDelegate alloc] init];
	delegate.bounds = self.bounds;
	delegate.page = page;
	CATiledLayer * subLayer = [CATiledLayer layer];
	subLayer.delegate = delegate;
	int w = (int)self.bounds.size.width;
	int h = (int)self.bounds.size.height;
	subLayer.tileSize = CGSizeMake(w*2, h*2);
	subLayer.levelsOfDetail = 3;
	subLayer.levelsOfDetailBias = 1;
	int width = self.bounds.size.width;
	int height = self.bounds.size.height;
	subLayer.frame = CGRectMake(0, 0, width, height);
	subLayer.backgroundColor = [[UIColor whiteColor] CGColor];
	
	myContentView = [[UIView alloc] initWithFrame:subLayer.frame];
	[myContentView.layer addSublayer:subLayer];
	myContentView.backgroundColor = [UIColor greenColor];
	
	CGRect viewFrame = self.frame;
	viewFrame.origin = CGPointZero;
	UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:viewFrame];
	scrollView.delegate = (id)self;
	scrollView.contentSize = subLayer.frame.size;
	scrollView.maximumZoomScale = 6;
	scrollView.bouncesZoom = NO;
	scrollView.zoomScale = 1;
	[scrollView addSubview:myContentView];
	[self addSubview:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return myContentView;
	
}




@end

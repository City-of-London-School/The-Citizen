//
//  MyTableViewCell.h
//  NavigationApp
//
//  Created by Harry Maclean on 12/09/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyTableViewCell : UITableViewCell {
	IBOutlet UILabel * textLabel;
	//IBOutlet UILabel * footer;
	IBOutlet UIButton * button;
	IBOutlet UIActivityIndicatorView * activityIndicator;
}
- (void)startAnimation;
- (void)stopAnimation;
@property(nonatomic, retain) UILabel * textLabel;
@property(nonatomic, retain) UIButton * button;
@property(nonatomic, retain) UIActivityIndicatorView * activityIndicator;
@end

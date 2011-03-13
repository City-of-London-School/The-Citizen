//
//  ProgressCell.h
//  Locations
//
//  Created by Harry Maclean on 06/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressCell : UITableViewCell {
	IBOutlet UILabel * textLabel;
	IBOutlet UIButton * button;
	IBOutlet UIProgressView * progressView;
}

- (void)incrementProgressBarByAmount:(float)amount;

@property (nonatomic, retain) UILabel * textLabel;
@property (nonatomic, retain) UIButton * button;
@property (nonatomic, retain) UIProgressView * progressView;

@end

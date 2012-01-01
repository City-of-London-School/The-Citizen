//
//  ProgressCell.m
//  Locations
//
//  Created by Harry Maclean on 06/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import "ProgressCell.h"


@implementation ProgressCell
@synthesize textLabel, progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.progressView.hidden = YES;
        self.textLabel.hidden = NO;
    }
    return self;
}

- (void)startProgressBar {
    self.progressView.hidden = NO;
    self.textLabel.hidden = YES;
    [self.progressView setProgress:0];
}

- (void)stopProgressBar {
    self.progressView.hidden = YES;
    self.textLabel.hidden = NO;
    self.textLabel.textColor = [UIColor blackColor];
}

- (void)incrementProgressBarByAmount:(float)amount {
    if (self.progressView.hidden) {
        [self startProgressBar];
    }
    if (amount == 1) {
        [self stopProgressBar];
    }
    else {
        [self.progressView setProgress:amount];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}





@end

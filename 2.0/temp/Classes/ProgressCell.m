//
//  ProgressCell.m
//  Locations
//
//  Created by Harry Maclean on 06/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import "ProgressCell.h"


@implementation ProgressCell
@synthesize textLabel, button, progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void)incrementProgressBarByAmount:(float)amount {
	[self.progressView setProgress:amount];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end

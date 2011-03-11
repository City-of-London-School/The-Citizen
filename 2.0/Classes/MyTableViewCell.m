//
//  MyTableViewCell.m
//  NavigationApp
//
//  Created by Harry Maclean on 12/09/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyTableViewCell.h"


@implementation MyTableViewCell
@synthesize textLabel, button, activityIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void)startAnimation {
	[activityIndicator startAnimating];
}

- (void)stopAnimation {
	[activityIndicator stopAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end

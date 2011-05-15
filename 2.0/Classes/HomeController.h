//
//  HomeController.h
//  The Citizen
//
//  Created by Harry Maclean on 12/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileManager.h"


@interface HomeController : UIViewController <FileManagerDelegate> {
	NSManagedObjectContext * managedObjectContext;
	FileManager * fileManager;
	IBOutlet UIButton *mostRecentButton;
	IBOutlet UIButton *previousButton;
}

- (IBAction)mostRecentButtonClicked:(id)sender;
- (IBAction)previousButtonClicked:(id)sender;
- (void)loadMostRecentArticle;

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

@end

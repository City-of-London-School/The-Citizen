//
//  HomeViewController.h
//  The Citizen
//
//  Created by Harry Maclean on 13/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileManager.h"


@interface HomeViewController : UITableViewController <FileManagerDelegate> {
	NSManagedObjectContext * managedObjectContext;
	FileManager * fileManager;
}

- (void)loadMostRecentArticle;

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

@end

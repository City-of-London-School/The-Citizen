//
//  DayViewController.h
//  The Citizen
//
//  Created by Harry Maclean on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadPDF.h"
#import "Event.h"
#import "FileManager.h"

@interface DayViewController : UITableViewController {
	NSManagedObjectContext * managedObjectContext;
	FileManager * fileManager;
	UIBarButtonItem * addButton;
	DownloadPDF * downloadManager;
	NSDictionary * downloadProgress;
	BOOL downloadInProgress;
	BOOL shouldLoadMostRecent;
	NSArray *nestedArray;
	int yearIndex;
	int monthIndex;
}

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) FileManager * fileManager;
@property (nonatomic, retain) UIBarButtonItem * addButton;
@property (nonatomic, retain) NSArray *nestedArray;
@property (nonatomic, assign) int yearIndex;
@property (nonatomic, assign) int monthIndex;

- (void)eventWasAdded:(NSIndexPath *)indexPath;
- (void)updateTableView;
- (void)refresh;
- (void)downloadEventAtButton:(UIButton *)sender;
@end

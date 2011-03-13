//
//  RootViewController.h
//  The Citizen
//
//  Created by Harry Maclean on 08/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadPDF.h"
#import "Event.h"
#import "FileManager.h"


@interface RootViewController : UITableViewController <FileManagerDelegate> {
	NSManagedObjectContext * managedObjectContext;
	FileManager * fileManager;
	UIBarButtonItem * addButton;
	DownloadPDF * downloadManager;
	NSDictionary * downloadProgress;
	BOOL downloadInProgress;
}

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) FileManager * fileManager;
@property (nonatomic, retain) UIBarButtonItem * addButton;

- (void)eventWasAdded:(NSIndexPath *)indexPath;
- (void)updateTableView;
- (void)refresh;
- (void)downloadEventAtButton:(UIButton *)sender;
@end

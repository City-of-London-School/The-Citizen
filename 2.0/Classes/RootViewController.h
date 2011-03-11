//
//  RootViewController.h
//  Locations
//
//  Created by Harry Maclean on 12/01/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadPDF.h"
#import "Event.h"
#import "FileManager.h"


@interface RootViewController : UITableViewController <FileManagerDelegate> {

//	NSMutableArray * eventsArray;
	NSManagedObjectContext * managedObjectContext;
	FileManager * fileManager;
	UIBarButtonItem * addButton;
	
	DownloadPDF * downloadManager;
	NSDictionary * downloadProgress;
}

//@property (nonatomic, retain) NSMutableArray * eventsArray;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) FileManager * fileManager;
@property (nonatomic, retain) UIBarButtonItem * addButton;

//- (void)addEvent:(NSString *)filename;
//- (void)fileWasDownloaded:(NSString *)filename;
//- (void)updateTable;
//- (NSArray *)localFileList;
//- (NSArray *)remoteFileList;
//- (NSArray *)findNewEvents;
//- (Event *)findEvent:(NSString *)pdfPath;
//- (void)addNewEvents:(NSArray *)newEvents;
//- (NSArray *)reverseArray:(NSArray *)arr;

- (void)eventWasAdded:(NSIndexPath *)indexPath;
- (void)updateTableView;
- (void)refresh;
- (void)downloadEventAtButton:(UIButton *)sender;
@end

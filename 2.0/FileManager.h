//
//  FileManager.h
//  Locations
//
//  Created by Harry Maclean on 15/01/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadPDF.h"
#import "Event.h"

@protocol FileManagerDelegate <NSObject>
- (void)eventWasAdded:(NSIndexPath *)indexPath;
@optional
- (void)updateTableView;
- (void)downloadAtIndex:(int)index hasProgressedBy:(NSNumber *)amount;
@end

@interface FileManager : NSObject <DownloadPDFDelegate> {
	
	id <FileManagerDelegate> delegate;
	NSMutableArray * eventsArray;
	NSManagedObjectContext * managedObjectContext;
	DownloadPDF * downloadManager;
	
	int indexOfCurrentlyDownloadingFile;
}

- (void)deleteEventAtIndexPath:(NSIndexPath *)indexPath;
- (void)downloadEvent:(Event *)event;
- (void)addEvent:(NSString *)filename;
- (void)fileWasDownloaded:(NSString *)filename;
- (void)updateTable;
- (NSArray *)localFileList;
- (NSArray *)remoteFileList;
- (NSArray *)findNewEvents;
- (Event *)findEvent:(NSString *)pdfPath;
- (void)addNewEvents:(NSArray *)newEvents;
- (void)setup:(NSString *)context; // 'year' for year controller, 'current' for most recent, 'all' for all (legacy)
- (void)downloadFileList;
- (Event *)mostRecentEvent;

- (NSArray *)reverseArray:(NSArray *)arr;
- (int)findIndexOfEventWithFilename:(NSString *)filename;

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (assign) id <FileManagerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray * eventsArray;

@end

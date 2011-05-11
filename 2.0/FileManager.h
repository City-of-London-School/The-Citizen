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
	NSMutableArray *indexes;
}

- (void)deleteEventAtIndexPath:(NSIndexPath *)indexPath;
- (void)downloadEvent:(Event *)event;
- (void)downloadEvent:(Event *)event withIndex:(int)index;
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
- (NSIndexPath *)findIndexPathOfEvent:(Event *)event;
- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForEventWithFilename:(NSString *)filename;

// Clean up DB by removing duplicate and null entries.
- (void)cleanDB;

// sort arrays for year/month
- (NSArray *)nestedArray;
- (NSArray *)years;
- (NSArray *)monthsForEvents:(NSArray *)events;
- (BOOL)string:(NSString *)string existsInArray:(NSArray *)array;
- (NSArray *)fetchEventsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (assign) id <FileManagerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray * eventsArray;

@end

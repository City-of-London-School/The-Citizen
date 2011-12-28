//
//  DYServer.h
//  The Citizen
//
//  Created by Harry Maclean on 23/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Issue.h"
#import "DownloadDelegate.h"

@interface DYServer : NSObject <DownloadDelegateDelegate> {
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *issues;
    BOOL online;
    NSMutableDictionary *delegates;
    BOOL needsFileList;
    NSArray *_allIssueDates;
    NSMutableDictionary *monthsForYears;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (Issue *)mostRecentIssue;
- (NSArray *)issuesThatExistLocally;
- (void)dowloadFileList;
//- (void)handleDownload;
- (void)updateFileList;
- (void)downloadIssue:(Issue *)issue;
- (void)downloadIssue:(Issue *)issue sender:(id)sender;
- (NSArray *)localFileList;
- (NSArray *)remoteFileList;
- (void)addIssue:(NSString *)filename exists:(BOOL)exists;
- (void)populateIssuesArray;
   
// Delegate Methods
- (void)downloadFinished:(NSDictionary *)response;
- (void)download:(NSDictionary *)response progressed:(float)progress;

// TableView Data Source Methods
- (NSArray *)yearsOfIssues;

// GroupedViewController Methods
- (NSArray *)allIssueDates;
- (NSArray *)months;
- (NSIndexPath *)indexPathForIssue:(Issue *)issue;
- (NSArray *)issuesForYear:(int)year month:(int)month;
- (NSArray *)monthsForYear:(int)year;

// Connection Test
- (void)testOnline;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) id delegate;
@property (assign) BOOL online;

@end

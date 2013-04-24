//
//  DYServer.h
//  The Citizen
//
//  Created by Harry Maclean on 23/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadDelegate.h"

@interface DYServer : NSObject <DownloadDelegateDelegate> {
    NSMutableDictionary *delegates;
    NSString *latestIssueFilename;
    NSURL *docdir;
    NSNotificationCenter *nc;
}

@property(nonatomic, assign)BOOL online;

- (NSURL *)issue;
- (void)dowloadFileList;
- (void)downloadIssueWithFilename:(NSString *)filename;
- (void)downloadFinished:(NSDictionary *)response;
//- (void)download:(NSDictionary *)response progressed:(float)progress;
- (NSArray *)remoteFileList;
- (void)updateIssue;
- (void)testOnline;
- (NSMutableArray *)parseFileList:(NSString *)fileList;

@end

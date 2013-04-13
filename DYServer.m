//
//  DYServer.m
//  The Citizen
//
//  Created by Harry Maclean on 23/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DYServer.h"
#import "DownloadDelegate.h"
#import "NSDate+Conveniences.h"

//NSString *const clsb = @"http://www.clsb.org.uk/downloads/citizen/";
NSString *const clsb = @"file:///Users/harry/Desktop/";

@implementation DYServer
@synthesize online;

- (id)init {
    self = [super init];
    delegates = [[NSMutableDictionary alloc] init];
    [self testOnline];
    if (self.online) {
        [self dowloadFileList];
    }
    return self;
}

/*
 The method that will be called by App Delegate
 Returns:   URL to issue, if it exists, or
            nil
 */
- (NSURL *)issue {
    if (latestIssueFilename) {
        NSURL *docdir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *issue = [docdir URLByAppendingPathComponent:latestIssueFilename];
        return issue;
    }
    else {
        if (self.online) {
            [self updateIssue];
        }
        return nil;
    }
}

- (void)dowloadFileList {
    NSString *filename = @"files.txt";
    NSString *path = [clsb stringByAppendingString:filename];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    DownloadDelegate *downloadDelegate = [[DownloadDelegate alloc] initWithRequest:req sender:self userData:[NSDictionary dictionary]];
    [delegates setObject:downloadDelegate forKey:filename];
}

- (void)downloadIssueWithFilename:(NSString *)filename {
    filename = [filename stringByAppendingFormat:@".pdf"];
    NSString *path = [clsb stringByAppendingString:filename];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    DownloadDelegate *downloadDelegate = [[DownloadDelegate alloc] initWithRequest:req sender:self userData:nil];
    [delegates setObject:downloadDelegate forKey:filename];
}

- (void)downloadFinished:(NSDictionary *)response {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSString *filename = [response objectForKey:@"filename"];
    [delegates removeObjectForKey:filename];
    if ([filename isEqualToString:@"files.txt"]) {
        [nc postNotification:[NSNotification notificationWithName:@"FileListDownloaded" object:nil]];
        [self updateIssue];
        return;
    }
    latestIssueFilename = filename;
    [nc postNotification:[NSNotification notificationWithName:@"DYServerIssueDownloadedNotification" object:nil]];    
}

//- (void)download:(NSDictionary *)response progressed:(float)progress {
//    NSDictionary *dict = [response objectForKey:@"userData"];
//    NSString *filename = [response objectForKey:@"filename"];
//    float rounded = lroundf(progress*500.0f)/500.0f;
//    if ([downloading objectForKey:filename]) {
//        if (progress == 1) {
//            [downloading removeObjectForKey:filename];
//        }
//        float oldProgress = [[downloading objectForKey:filename] floatValue];
//        if (rounded != oldProgress) {
//            [downloading setObject:[NSNumber numberWithFloat:rounded] forKey:filename];
//            id sender = [dict objectForKey:@"sender"];
//            [sender download:response progressed:progress];
//        }
//    }
//    else {
//        [downloading setObject:[NSNumber numberWithFloat:rounded] forKey:filename];
//    }
//}

- (NSArray *)remoteFileList {
    NSURL *docPath = [[[UIApplication sharedApplication] delegate] performSelector:@selector(applicationDocumentsDirectory)];
    NSURL *remoteFilePath = [docPath URLByAppendingPathComponent:@"files.txt"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[remoteFilePath path]]) {
        return [NSArray array];
    }
    NSError *err;
    NSString *remoteFileString = [NSString stringWithContentsOfURL:remoteFilePath encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"error reading files.txt %@", err);
        return [NSArray array];
    }
	NSMutableArray * remoteFileList = [NSMutableArray arrayWithArray:[remoteFileString componentsSeparatedByString:@"\n"]];
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	for (NSString * __strong str in remoteFileList) {
		str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		[temp addObject:str];
	}
	return (NSArray *)temp;
}

- (void)updateIssue {
    NSArray *files = [self remoteFileList];
    if ([files count] == 0) {
        [self dowloadFileList];
        return;
    }
    NSString *issue = [files objectAtIndex:0];
    
    NSURL *docDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * path = [[docDir URLByAppendingPathComponent:issue] URLByAppendingPathExtension:@"pdf"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[path path]]) {
        // Latest issue is already downloaded
        latestIssueFilename = [issue stringByAppendingPathExtension:@"pdf"];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"DYServerIssueDownloadedNotification" object:nil]];
        return;
    }
    [self downloadIssueWithFilename:issue];
}

#pragma Test Internet Connection

- (void)testOnline {
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    NSURLResponse *response;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error != nil) {
        NSLog(@"Not connected to the internet: %@", [error description]);
        self.online = NO;
        return;
    }
    self.online = YES;
}

@end

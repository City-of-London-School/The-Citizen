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

NSString *const clsb = @"http://cityoflondonboys.fluencycms.co.uk/Mainfolder/News-and-Events/docs/the_citizen/";

@implementation DYServer
@synthesize online;

- (id)init {
    self = [super init];
    docdir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    nc = [NSNotificationCenter defaultCenter];
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
    NSURL *url = [NSURL URLWithString:clsb];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    DownloadDelegate *downloadDelegate = [[DownloadDelegate alloc] initWithRequest:req sender:self userData:[NSDictionary dictionary]];
    [delegates setObject:downloadDelegate forKey:@"the_citizen"];
}

- (void)downloadIssueWithFilename:(NSString *)filename {
    NSString *path = [clsb stringByAppendingString:filename];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    DownloadDelegate *downloadDelegate = [[DownloadDelegate alloc] initWithRequest:req sender:self userData:nil];
    [delegates setObject:downloadDelegate forKey:filename];
}

- (void)downloadFinished:(NSDictionary *)response {
    NSString *filename = [response objectForKey:@"filename"];
    [delegates removeObjectForKey:filename];
    if ([filename isEqualToString:@"the_citizen"]) { // File list
        [nc postNotification:[NSNotification notificationWithName:@"FileListDownloaded" object:nil]];
        [self updateIssue];
        return;
    }
    latestIssueFilename = filename;
    [nc postNotification:[NSNotification notificationWithName:@"DYServerIssueDownloadedNotification" object:nil]];    
}

- (NSArray *)remoteFileList {
    NSURL *remoteFilePath = [docdir URLByAppendingPathComponent:@"the_citizen"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[remoteFilePath path]]) {
        return [NSArray array];
    }
    NSError *err;
    NSString *remoteFileString = [NSString stringWithContentsOfURL:remoteFilePath encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"error reading file list %@", err);
        return [NSArray array];
    }
	NSMutableArray * remoteFileList = [self parseFileList:remoteFileString];
    return remoteFileList;
}

- (NSMutableArray *)parseFileList:(NSString *)fileList {
    NSMutableArray *files = [NSMutableArray array];
    NSError *err;
//    Create regexes
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<br>([^>]*?)<A HREF=\"(.*?)\">(.*?)</A>" options:nil error:&err];
    if (err) NSLog(@"%@", [err description]);
    NSRegularExpression *dateregex = [NSRegularExpression regularExpressionWithPattern:@"\\A\\s*([\\S])*\\s" options:NSRegularExpressionAllowCommentsAndWhitespace error:&err];
    if (err) NSLog(@"%@", [err description]);
//    Iterate through matches
    NSArray *matches = [regex matchesInString:fileList options:nil range:NSMakeRange(0, [fileList length])];
    for (NSTextCheckingResult *match in matches) {
//        Extract filename, metadata and url
        NSString *filename = [fileList substringWithRange:[match rangeAtIndex:3]];
        NSString *metadata = [fileList substringWithRange:[match rangeAtIndex:1]];
//        Discard web.config
        if ([filename isEqualToString:@"web.config"]) continue;
//        Parse date in metadata
        NSTextCheckingResult *datematch = [dateregex firstMatchInString:metadata options:nil range:NSMakeRange(0, [metadata length])];
        NSString *datestring = [metadata substringWithRange:[datematch range]];
        NSDate *date = [NSDate dateFromString:datestring withFormat:@" MM/dd/yyyy"];
        if (!date) {
            date = [NSDate dateFromString:datestring withFormat:@"MM/dd/yyyy"];
        }
        if (!date) {
            NSLog(@"Failed to create date object for string %@", datestring);
        }
//        Store in dict
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", date, @"date", nil];
        [files addObject:dict];
    }
//    Sort by date
    [files sortUsingComparator:(NSComparator)^(NSDictionary *obj1, NSDictionary *obj2) {
        NSDate *date1 = [obj1 objectForKey:@"date"];
        NSDate *date2 = [obj2 objectForKey:@"date"];
        return [date2 compare:date1];
    }];
    return files;
}

- (void)updateIssue {
    NSArray *files = [self remoteFileList];
    if ([files count] == 0) {
//        [self dowloadFileList];
        return;
    }
    NSDictionary *issuedict = [files objectAtIndex:0];
    NSString *issue = [issuedict objectForKey:@"filename"];
    
    NSURL * path = [docdir URLByAppendingPathComponent:issue];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[path path]]) {
        // Latest issue is already downloaded
        latestIssueFilename = issue;
        [nc postNotification:[NSNotification notificationWithName:@"DYServerIssueDownloadedNotification" object:nil]];
        return;
    }
    [self downloadIssueWithFilename:issue];
}

#pragma mark Test Internet Connection

- (void)testOnline {
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:5];
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

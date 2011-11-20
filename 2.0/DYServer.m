//
//  DYServer.m
//  The Citizen
//
//  Created by Harry Maclean on 23/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DYServer.h"
//#import "DYDate.h"
#import "DownloadDelegate.h"
#import "NSDate+Conveniences.h"

NSString *const clsb = @"http://www.clsb.org.uk/downloads/citizen/";

@implementation DYServer
@synthesize managedObjectContext, delegate, online;

- (id)init {
    self = [super init];
    delegates = [[NSMutableDictionary alloc] init];
    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    self = [self init];
    self.managedObjectContext = context;
    [self populateIssuesArray];
    needsFileList = NO;
    if ([issues count] == 0) {
        needsFileList = YES;
    }
    [self testOnline];
    if (online) {
        [self dowloadFileList];
    }
    return self;
}

- (Issue *)mostRecentIssue {
    if ([issues count] == 0) {
        return nil;
    }
    Issue *anIssue = (Issue *)[issues lastObject];
    if ([anIssue.existsLocally boolValue]) {
        return anIssue;
    }
	if (online) {
        [self downloadIssue:anIssue];
    }
    NSArray *arr = [self issuesThatExistLocally];
    if ([arr count] != 0) {
        return (Issue *)[arr objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)issuesThatExistLocally {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:issues];
    for (Issue *issue in issues) {
        if (![issue.existsLocally boolValue]) {
            [arr removeObject:issue];
        }
    }
    return (NSArray *)arr;
}

- (void)dowloadFileList {
    NSString *filename = @"files.txt";
    NSString *path = [clsb stringByAppendingString:filename];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    DownloadDelegate *downloadDelegate = [[DownloadDelegate alloc] initWithRequest:req sender:self userData:[NSDictionary dictionary]];
    [delegates setObject:downloadDelegate forKey:filename];
}

- (void)downloadIssue:(Issue *)issue {
    NSString *filename = [issue.pdfPath stringByAppendingFormat:@".pdf"];
    NSString *path = [clsb stringByAppendingString:filename];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:issue forKey:@"issue"];
    DownloadDelegate *downloadDelegate = [[DownloadDelegate alloc] initWithRequest:req sender:self userData:dict];
    [delegates setObject:downloadDelegate forKey:filename];
}

- (void)downloadIssue:(Issue *)issue sender:(id)sender {
    NSString *filename = [issue.pdfPath stringByAppendingFormat:@".pdf"];
    NSString *path = [clsb stringByAppendingString:filename];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:issue forKey:@"issue"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:issue, @"issue", sender, @"sender", nil];
    DownloadDelegate *downloadDelegate = [[DownloadDelegate alloc] initWithRequest:req sender:self userData:dict];
    [delegates setObject:downloadDelegate forKey:filename];
}

//- (void)fileWasDownloaded:(NSString *)filename {
//    if (filename == @"files.txt") {
//        [self updateFileList];
//	}
//	else {
//		filename = [[filename componentsSeparatedByString:@".pdf"] objectAtIndex:0];
//		Issue *issue = [self findIssue:filename];
//		issue.existsLocally = [NSNumber numberWithBool:YES];
//		NSError *error = nil;
//		if (![managedObjectContext save:&error])
//            NSLog(@"error saving context: %@", [error description]);
//    }
//    [delegates removeObjectForKey:filename];
//}

- (void)downloadFinished:(NSDictionary *)response {
    NSString *filename = [response objectForKey:@"filename"];
    [delegates removeObjectForKey:filename];
    if ([filename isEqualToString:@"files.txt"]) {
        [self updateFileList];
        return;
    }
    Issue *issue = [[response objectForKey:@"userData"] objectForKey:@"issue"];
    issue.existsLocally = [NSNumber numberWithBool:YES];
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"error saving context: %@", [error description]);
    }    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotification:[NSNotification notificationWithName:@"DYServerIssueDownloadedNotification" object:nil]];    
}

- (void)download:(NSDictionary *)response progressed:(float)progress {
    NSDictionary *dict = [response objectForKey:@"userData"];
    id sender = [dict objectForKey:@"sender"];
    [sender download:response progressed:progress];
}

- (void)updateFileList {
    NSArray * remoteFileList = [self remoteFileList];
	NSArray * localFileList = [self localFileList];
//	localFileList = [self reverseArray:localFileList];
	if ([remoteFileList isEqualToArray:localFileList]) {
		NSLog(@"no new issues");
	}
	else {
		NSLog(@"new issues available");
		NSArray * newIssues = remoteFileList;
        if ([localFileList count] != 0) {
            NSMutableArray * temp = [[NSMutableArray alloc] init];
            for (NSString * str in newIssues) {
                BOOL exists = NO;
                for (NSString * filename in localFileList) {
                    if ([filename isEqualToString:str]) {
                        exists = YES;
                    }
                }
                if (!exists) {
                    [temp addObject:str];
                }
            }
            newIssues = [temp copy];
            for (NSString * filename in newIssues) {
                [self addIssue:filename exists:NO];
            }
        }
        else {
            for (NSString *filename in remoteFileList) {
                [self addIssue:filename exists:NO];
            }
        }
    }
    if (needsFileList) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotification:[NSNotification notificationWithName:@"DYServerIssuesUpdatedNotification" object:nil]];
    }
}

- (void)addIssue:(NSString *)filename exists:(BOOL)exists {
	Issue * issue = (Issue *)[NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:managedObjectContext];
	[issue setPdfPath:filename];
	[issue setExistsLocally:[NSNumber numberWithBool:exists]];
	
	NSString * dateString = [filename stringByReplacingOccurrencesOfString:@"citizen" withString:@""];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate * date = [dateFormatter dateFromString:dateString];
	if (!date) {
		NSLog(@"invalid date: %@", dateString);
		return;
	}
	[issue setDate:date];
	NSError * error = nil;
	if (![managedObjectContext save:&error]) {
		NSLog(@"error saving object");
	}
	[issues insertObject:issue atIndex:0];
}

- (NSArray *)localFileList {
	if ([issues count] == 0) {
		return nil;
	}
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	for (Issue * issue in issues) {
		[temp addObject:issue.pdfPath];
	}
	return (NSArray *)temp;
}

- (NSArray *)remoteFileList {
    NSURL *docPath = [[[UIApplication sharedApplication] delegate] performSelector:@selector(applicationDocumentsDirectory)];
    NSURL *remoteFilePath = [docPath URLByAppendingPathComponent:@"files.txt"];
    NSError *err;
    NSString *remoteFileString = [NSString stringWithContentsOfURL:remoteFilePath encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"error reading files.txt %@", err);
    }
	NSMutableArray * remoteFileList = [NSMutableArray arrayWithArray:[remoteFileString componentsSeparatedByString:@"\n"]];
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	for (NSString * __strong str in remoteFileList) {
		str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		[temp addObject:str];
	}
	return (NSArray *)temp;
}

- (void)populateIssuesArray {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"fetch error: %@", [error description]);
	}
	issues = mutableFetchResults;
}

#pragma mark TableView Data Source Methods

- (NSArray *)yearsOfIssues {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (Issue *issue in issues) {
        NSDate *date = issue.date;
        BOOL isThere = FALSE;
        for (NSNumber *n in arr) {
            if ([n intValue] == date.year) {
                isThere = TRUE;
            }
        }
        if (!isThere) {
            [arr addObject:[NSNumber numberWithInt:date.year]];
        }
    }
    return (NSArray *)arr;
}


# pragma mark GroupedViewController Methods
- (NSArray *)allIssueDates {
    if (_allIssueDates) {
        return _allIssueDates;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (Issue *issue in issues) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:issue.date.year], @"year", [NSNumber numberWithInt:issue.date.month], @"month", [NSNumber numberWithInt:issue.date.day], @"day", nil];
        [arr addObject:dict];
    }
    _allIssueDates = (NSArray *)arr;
    return _allIssueDates;
}
- (NSArray *)months {
    return [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
}

- (NSArray *)issuesForYear:(int)year month:(int)month {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (Issue *issue in issues) {
        if (year == issue.date.year && month == issue.date.month) {
            [arr addObject:issue];
        }
    }
    return (NSArray *)arr;
}

- (NSArray *)monthsForYear:(int)year {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in [self allIssueDates]) {
        if ([[dict objectForKey:@"year"] intValue] != year) {
            continue;
        }
        BOOL isThere = NO;
        for (NSNumber *n in arr) {
            if ([n intValue] == [[dict objectForKey:@"month"] intValue]) {
                isThere = YES;
            }
        }
        if (!isThere) {
            [arr addObject:[dict objectForKey:@"month"]];
        }
    }
    return (NSArray *)arr;
}

- (NSIndexPath *)indexPathForIssue:(Issue *)issue {
    NSDate *date = issue.date;
    NSArray *theIssues = [self issuesForYear:date.year month:date.month];
    int index = 0;
    for (Issue *anIssue in theIssues) {
        if (anIssue.date.day == issue.date.day) {
            break;
        }
        index++;
    }
    Issue *i = [issues objectAtIndex:index];
    date = i.date;
    if (![date isEqualToDate:issue.date]) {
        NSLog(@"Issue not found.");
        return nil;
    }
    NSArray *months = [self monthsForYear:issue.date.year];
    int j = 0;
    for (NSNumber *n in months) {
        if ([n intValue] == issue.date.month) {
            break;
        }
        j++;
    }
    return [NSIndexPath indexPathForRow:index inSection:j];
}

#pragma Test Internet Connection

- (void)testOnline {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    NSURLResponse *response;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil) {
        NSLog(@"Not connected to the internet: %@", [error description]);
        self.online = NO;
        return;
    }
    self.online = YES;
}

@end

//
//  DownloadDelegate.m
//  NewsstandKitTest
//
//  Created by Harry Maclean on 26/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DownloadDelegate.h"

@implementation DownloadDelegate
@synthesize connection = _connection;
@synthesize request = _request;
@synthesize userData = _userData;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)initWithRequest:(NSURLRequest *)req sender:(id)theSender userData:(NSDictionary *)userData{
	self = [self init];
	receivedData = [[NSMutableData alloc] init];
	self.request = req;
	self.userData = userData;
	sender = theSender;
    self.delegate = theSender;
	filename = (NSString *)[[[self.request URL] pathComponents] lastObject];
	self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
	[self.connection start];
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[receivedData setLength:0];
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
    float dataLength = (float)[receivedData length];
    float expectedLength = (float)[_response expectedContentLength];
    float progress = dataLength/expectedLength;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", self.userData, @"userData", nil];
    [self.delegate download:dict progressed:progress];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Save the file
    NSURL *filePath = [[[[UIApplication sharedApplication] delegate] performSelector:@selector(applicationDocumentsDirectory)] URLByAppendingPathComponent:filename];
    NSError *err;
    [receivedData writeToURL:filePath options:NSDataWritingAtomic error:&err];
    if (err) {
        NSLog(@"error saving file: %@", err);
    }
    
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", receivedData, @"data", self.userData, @"userData", nil];
    [self.delegate downloadFinished:dict];
}

+ (int)count {
    return 1;
}


@end
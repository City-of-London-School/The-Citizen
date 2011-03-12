//
//  DownloadPDF.m
//  NavigationApp
//
//  Created by Harry Maclean on 20/08/2010.
//  Copyright 2010 City of London School. All rights reserved.
//

#import "DownloadPDF.h"
#import	"MyNSURLConnectionDelegate.h"



@implementation DownloadPDF

@synthesize downloadPDFDelegate;

// Set up and return (so that you can cancel it, etc.) an NSURLConnection
- (NSURLConnection*)downloadFile:(NSString *)filename
{
	NSURLRequest*	request = nil;
	id		context = nil;
	
	// Set up request and context to taste
	[filename retain];
	[saveFilename release];
	saveFilename = filename;
	context = saveFilename;
	NSString * pdfURL = [@"http://www.clsb.org.uk/downloads/citizen/" stringByAppendingString:filename];
	request = [NSURLRequest requestWithURL:[NSURL URLWithString:pdfURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	MyNSURLConnectionDelegate* delegate = [[[MyNSURLConnectionDelegate alloc] initWithTarget:self
																					  action:@selector(handleResultOrError:withContext:)
																					 context:context] autorelease];
	NSURLConnection* conn = [NSURLConnection connectionWithRequest:request delegate:delegate];
	[conn start];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	return conn;
}

// Handle the result of an NSURLConnection.  Invoked asynchronously.
- (void)handleResultOrError:(id)resultOrError withContext:(id)context
{
	if ([resultOrError isKindOfClass:[NSError class]])
	{
		// Handle error
		NSLog(@"Error: %@", resultOrError);
		[downloadPDFDelegate fileWasDownloaded:context];
		return;
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	NSURLResponse* response = [resultOrError objectForKey:@"response"];
	NSData* data = [resultOrError objectForKey:@"data"];
	
	// Handle response and data
	NSLog(@"Response: %@", response);
	saveFilename = context;
	filePath = [DownloadPDF getLocalDocPath:saveFilename];
	[data writeToFile:filePath atomically:YES];
	if (self.downloadPDFDelegate != NULL && [self.downloadPDFDelegate respondsToSelector:@selector(fileWasDownloaded:)]) {
		NSLog(@"Saving file %@", saveFilename);
		[downloadPDFDelegate fileWasDownloaded:saveFilename];
	}
}

- (void)fileDownloadHasProgressedBy:(NSNumber *)amount {
	if (![saveFilename isEqualToString:@"files.txt"]) {
		[downloadPDFDelegate performSelector:@selector(fileDownload:hasProgressedBy:) withObject:saveFilename withObject:amount];
	}
}

+ (NSString *)getLocalDocPath:(NSString *)docFilename {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * docPath =  [paths objectAtIndex:0];
	NSString * documentsDirectory = [docPath stringByAppendingString:@"/"];
	if (docFilename != nil) {
		NSString * path = [documentsDirectory stringByAppendingString:docFilename];
		return path;
	}
	else {
		return documentsDirectory;
	}
}

+ (BOOL)connectedToInternet {
	NSString *urlAddress = @"http://www.google.com/";
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	// Check for response for server, if none pop error dialog
	NSURLResponse *resp = nil;
	NSError *err = nil;
	[NSURLConnection sendSynchronousRequest: requestObj returningResponse: &resp error: &err];
	if (err != nil) {
		return NO;
	}
	else {
		return YES;
	}

}

+ (void)showNetworkError {
	UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: @"No Internet Connection" message: @"You are not connected to the internet. No issues can be downloaded." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView  show];
	[alertView  release];
}

- (void)dealloc {
	[super dealloc];
}
@end

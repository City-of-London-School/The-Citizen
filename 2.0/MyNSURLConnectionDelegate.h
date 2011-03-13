//
//  MyNSURLConnectionDelegate.h
//  NavigationApp
//
//  Created by Harry Maclean on 22/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyNSURLConnectionDelegate : NSObject
{
	NSURLResponse*	response;
	NSMutableData*	responseData;
	
	id				target;
	SEL				action;
	id				context;
}

- (id)initWithTarget:(id)target action:(SEL)action context:(id)context;

- (BOOL)connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace*)protectionSpace;
- (void)connection:(NSURLConnection*)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge;
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error;
- (void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge;
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data;
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response;
- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (NSCachedURLResponse*)connection:(NSURLConnection*)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse;
- (NSURLRequest*)connection:(NSURLConnection*)connection willSendRequest:(NSURLRequest*)request redirectResponse:(NSURLResponse*)redirectResponse;
- (void)connectionDidFinishLoading:(NSURLConnection*)connection;
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection*)connection;

@property (nonatomic, retain) NSURLResponse* response;
@property (nonatomic, retain) NSMutableData* responseData;
@end
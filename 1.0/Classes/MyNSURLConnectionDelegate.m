//
//  MyNSURLConnectionDelegate.m
//  NavigationApp
//
//  Created by Harry Maclean on 22/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyNSURLConnectionDelegate.h"


//@interface MyNSURLConnectionDelegate
//
//
//@property (nonatomic, retain) NSURLResponse* response;
//@property (nonatomic, retain) NSMutableData* responseData;
//
//@end


@implementation MyNSURLConnectionDelegate

@synthesize response;
@synthesize responseData;


- (id)init
{
	return [self initWithTarget:nil action:(SEL)0 context:nil];
}


- (id)initWithTarget:(id)a_target action:(SEL)a_action context:(id)a_context
{
	if (self = [super init])
	{
		target	= [a_target retain];
		action	= a_action;
		context	= [a_context retain];
	}
	return self;
}


- (void)dealloc
{
	[response release];
	[responseData release];
	[target release];
	[context release];
	[super dealloc];
}


- (BOOL)connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace*)protectionSpace
{
	NSLog(@"canAuthenticateAgainstProtectionSpace");
	if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]	||
		[protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]			)
	{
		return NO;
	}
	else
	{
		return YES;
	}
}


- (void)connection:(NSURLConnection*)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
	NSLog(@"didCancelAuthenticationChallenge");
}


- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	NSLog(@"didFailWithError");
	[target performSelector:action withObject:error withObject:context];
}


- (void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
	NSLog(@"didReceiveAuthenticationChallenge");
	[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
}


- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	//NSLog(@"didReceiveData");
	[responseData appendData:data];
}


- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)aResponse
{
	NSLog(@"didReceiveResponse");
	self.response = aResponse;
	self.responseData = [NSMutableData data];
}


- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	NSLog(@"didSendBodyData");
}


- (NSCachedURLResponse*)connection:(NSURLConnection*)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
	NSLog(@"willCacheResponse");
	return cachedResponse;
}


- (NSURLRequest*)connection:(NSURLConnection*)connection willSendRequest:(NSURLRequest*)request redirectResponse:(NSURLResponse*)redirectResponse
{
	NSLog(@"willSendRequest (from %@ to %@)", redirectResponse.URL, request.URL);
	return request;
}


- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	NSLog(@"connectionDidFinishLoading");
	[target performSelector:action
				 withObject:[NSDictionary dictionaryWithObjectsAndKeys:response,@"response",responseData,@"data",nil]
				 withObject:context];
}


- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection*)connection
{
	NSLog(@"connectionShouldUseCredentialStorage");
	return YES;
}

@end
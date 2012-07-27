//
//  DownloadDelegate.h
//  NewsstandKitTest
//
//  Created by Harry Maclean on 26/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadDelegateDelegate <NSObject>

- (void)downloadFinished:(NSDictionary *)response;

@optional
- (void)download:(NSDictionary *)response progressed:(float)progress;

@end


@interface DownloadDelegate : NSObject  <NSURLConnectionDataDelegate> {
	id sender;
	NSMutableData *receivedData;
	NSString *filename;
    NSURLResponse *_response;
}

- (id)initWithRequest:(NSURLRequest *)req sender:(id)theSender userData:(NSDictionary *)userData;
+ (int)count;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSDictionary *userData;
@property (nonatomic, strong) id delegate;

@end

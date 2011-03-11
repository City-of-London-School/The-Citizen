//
//  DownloadPDF.h
//  NavigationApp
//
//  Created by Harry Maclean on 20/08/2010.
//  Copyright 2010 City of London School. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadPDFDelegate <NSObject>
@optional
- (void)fileWasDownloaded:(NSString *)filename;
@end

@interface DownloadPDF : NSObject {
	id <DownloadPDFDelegate> downloadPDFDelegate;
	NSMutableData * receivedData;
	NSString * filePath;
	NSString * saveFilename;
}

- (NSString *)getLocalDocPath:(NSString *)filename;
- (NSURLConnection *)startAsynchronousOperation:(NSString *)filename;
- (BOOL)connectedToInternet;
@property(assign) id <DownloadPDFDelegate> downloadPDFDelegate;
@end

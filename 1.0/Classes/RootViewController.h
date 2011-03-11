//
//  RootViewController.h
//  The Citizen
//
//  Created by Harry Maclean on 14/09/2010.
//  Copyright City of London School 2010. All rights reserved.
//

#import "DownloadPDF.h"
#import <UIKit/UIKit.h>

@class DownloadPDF;
@interface RootViewController : UITableViewController {
	NSFileManager * fileManager;
	DownloadPDF * downloadPDF;
	NSSet * localFileSet;
	NSMutableArray * totalFileList;
	BOOL connected;
}
- (NSString *)getLocalDocPath:(NSString *)filename;
- (void)fileWasDownloaded:(NSString *)filename;
- (void)refresh;
- (void)fillTotalFileList;
- (void)downloadAll;
- (void)downloadFile:(UIButton *)sender;

@end

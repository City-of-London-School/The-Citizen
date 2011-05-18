//
//  MonthViewController.h
//  The Citizen
//
//  Created by Harry Maclean on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadPDF.h"
#import "Event.h"
#import "FileManager.h"

@interface MonthViewController : UITableViewController {
    NSManagedObjectContext *managedObjectContext;
	FileManager *FileManager;
	NSArray *nestedArray;
	NSString * year;
	int index;
}

- (void)updateTable:(NSArray *)array;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) FileManager *fileManager;
@property (nonatomic, retain) NSArray *nestedArray;
@property (nonatomic, retain) NSString *year; 
@property (nonatomic, assign) int index;

- (void)refresh;

@end

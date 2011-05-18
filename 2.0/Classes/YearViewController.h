//
//  YearViewController.h
//  The Citizen
//
//  Created by Harry Maclean on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadPDF.h"
#import "Event.h"
#import "FileManager.h"


@interface YearViewController : UITableViewController {
    NSManagedObjectContext * managedObjectContext;
	FileManager * fileManager;
	NSArray *nestedArray;
	BOOL showError;
}

- (void)updateTable:(NSArray *)array;

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) FileManager * fileManager;
@property (nonatomic, retain) NSArray *nestedArray;

- (void)refresh;

@end

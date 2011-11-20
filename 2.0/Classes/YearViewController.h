//
//  YearViewController.h
//  The Citizen
//
//  Created by Harry Maclean on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue.h"
#import "DYServer.h"


@interface YearViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSManagedObjectContext * managedObjectContext;
    DYServer *server;
	NSArray *nestedArray;
	BOOL showError;
    NSFetchedResultsController *__fetchedResultsController;
}

- (void)updateTable:(NSArray *)array;

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) DYServer *server;
@property (nonatomic, retain) NSArray *nestedArray;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)refresh;

@end

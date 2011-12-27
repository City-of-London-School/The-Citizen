//
//  DYGroupedViewController.h
//  The Citizen
//
//  Created by Harry Maclean on 19/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentViewController;

#import <CoreData/CoreData.h>
#import "ContentViewController.h"
#import "Issue.h"
#import "DYServer.h"

@interface DYGroupedViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSArray *_dates; // Cache of dictionaries for each issue date
    NSMutableArray *downloading; // Table View cells that are downloading
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


// Server delegate
- (void)download:(NSDictionary *)response progressed:(float)progress;

@property (strong, nonatomic) DYServer *server;
@property (strong, nonatomic) ContentViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) int year;

@end

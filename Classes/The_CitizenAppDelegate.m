//
//  The_CitizenAppDelegate.m
//  The Citizen
//
//  Created by Harry Maclean on 08/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import "The_CitizenAppDelegate.h"
#import "ContentViewController.h"
#import "YearViewController.h"


@implementation The_CitizenAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the navigation controller's view to the window and display.
    ContentViewController *currentIssueViewController = [[ContentViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];
    server = [[DYServer alloc] initWithManagedObjectContext:self.managedObjectContext];
    Issue *issue = [server mostRecentIssue];
    if (issue) {
        NSURL * path = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:issue.pdfPath] URLByAppendingPathExtension:@"pdf"];
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)path);
        currentIssueViewController.pdf = pdf;
    }
        
    YearViewController *yearViewController = [[YearViewController alloc] initWithNibName:@"YearViewController" bundle:nil];
    yearViewController.managedObjectContext = self.managedObjectContext;
    yearViewController.server = server;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:yearViewController];
    currentIssueViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostRecent tag:0];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:0];
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:currentIssueViewController, nav, nil];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (NSURL *)mostRecentIssuePDFPath {
    Issue *issue = [server mostRecentIssue];
    if (!issue) {
        return nil;
    }
    if (issue && issue.existsLocally) {
        NSURL *appDoc = [self applicationDocumentsDirectory];
        NSURL *pdfPath = [appDoc URLByAppendingPathComponent:issue.pdfPath];
        return [pdfPath URLByAppendingPathExtension:@"pdf"];
    }
    [self downloadMostRecentIssue];
    return nil;
}

- (void)downloadMostRecentIssue {
    Issue *issue = [server mostRecentIssue];
    if (issue) {
        [server downloadIssue:issue];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"The_Citizen" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"The_Citizen.sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"The_Citizen.sqlite"];
//	NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:@"iRcon.sqlite"];
    
    NSError *error = nil;
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: @"Database Problem" message: @"A fatal database error has ocurred. Quit the application by pressing the home button. If the problem persists, reinstall the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView  show];
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


//- (void)dealloc {
//    
//    [managedObjectContext_ release];
//    [managedObjectModel_ release];
//    [persistentStoreCoordinator_ release];
//    
//    [navigationController release];
//    [window release];
//    [super dealloc];
//}


@end


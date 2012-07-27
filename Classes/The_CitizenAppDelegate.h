//
//  The_CitizenAppDelegate.h
//  The Citizen
//
//  Created by Harry Maclean on 08/03/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import "DYServer.h"

@interface The_CitizenAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    DYServer *server;
    ContentViewController *currentIssueViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;

@end


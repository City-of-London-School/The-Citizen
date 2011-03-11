//
//  firstViewController.h
//  NavigationApp
//
//  Created by Harry Maclean on 01/08/2010.
//  Copyright (c) 2010 City of London School. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstViewController : UIViewController {
	IBOutlet UIWebView * webView;
	NSString * filename;
}
@property(nonatomic, retain) NSString * filename;
@end

//
//  NSDate+Conveniences.h
//  The Citizen
//
//  Created by Harry Maclean on 18/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Conveniences)

@property (readonly) int year;
@property (readonly) int month;
@property (readonly) int day;

- (NSString *)stringValueWithFormat:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;

@end

//
//  NSDate+Conveniences.m
//  The Citizen
//
//  Created by Harry Maclean on 18/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Conveniences.h"

@implementation NSDate (Conveniences)

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:string];
}

- (int)year {
    return [[[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self] year];
}

- (int)month {
    return [[[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self] month];
}

- (int)day {
    return [[[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self] day];
}

- (NSString *)stringValueWithFormat:(NSString *)format {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}

@end

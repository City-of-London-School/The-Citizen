//
//  Event.h
//  Locations
//
//  Created by Harry Maclean on 13/01/2011.
//  Copyright 2011 City of London School. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Event :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * pdfPath;
@property (nonatomic, retain) NSNumber * existsLocally;
@property (nonatomic, retain) NSDate * date;

@end




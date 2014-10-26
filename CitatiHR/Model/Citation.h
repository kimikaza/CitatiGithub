//
//  Citation.h
//  CitatiHR
//
//  Created by Zoran Pleško on 27/05/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, Theme;

@interface Citation : NSManagedObject

@property (nonatomic, retain) NSNumber * favourite;
@property (nonatomic, retain) NSNumber * remote_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) Author *author;
@property (nonatomic, retain) Theme *theme;

@end

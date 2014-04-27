//
//  Theme.h
//  CitatiHR
//
//  Created by Zoran Pleško on 27/04/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Citation;

@interface Theme : NSManagedObject

@property (nonatomic, retain) NSString * remote_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *citations;
@end

@interface Theme (CoreDataGeneratedAccessors)

- (void)addCitationsObject:(Citation *)value;
- (void)removeCitationsObject:(Citation *)value;
- (void)addCitations:(NSSet *)values;
- (void)removeCitations:(NSSet *)values;

@end

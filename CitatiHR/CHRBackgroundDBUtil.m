//
//  CHRBackgroundDBUtil.m
//  CitatiHR
//
//  Created by Zoran Pleško on 14/05/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import "CHRBackgroundDBUtil.h"
#import "CHRAppDelegate.h"

@interface CHRBackgroundDBUtil()

@property (nonatomic, strong) NSManagedObjectContext *privateContext;


@end

@implementation CHRBackgroundDBUtil
+(CHRBackgroundDBUtil *) sharedInstance {
    static CHRBackgroundDBUtil * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CHRBackgroundDBUtil alloc] init];
        
        
    });
    
    return _sharedInstance;
    
}

-(NSManagedObjectContext *) privateContext {
    if (_privateContext != nil)  return _privateContext;
    CHRAppDelegate *ad = (CHRAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSPersistentStoreCoordinator *coordinator = ad.persistentStoreCoordinator;
    if (coordinator != nil) {
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateContext setPersistentStoreCoordinator:coordinator];
    }
    return _privateContext;
    
}

-(void) fetchAditionalDataFromServer {
    [self.privateContext performBlock:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setResultType:NSDictionaryResultType];
        NSExpression *expression = [NSExpression expressionForKeyPath:@"remote_id"];
        NSExpression *maxExpression= [NSExpression expressionForFunction:@"max:" arguments:@[expression]];
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        [expressionDescription setName:@"maxId"];
        [expressionDescription setExpression:maxExpression];
        [expressionDescription setExpressionResultType:NSStringAttributeType];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
        NSArray *object;
        object = [_privateContext executeFetchRequest:fetchRequest error:nil];
        [object[0] valueForKey:@"maxId"];
        
        
    }];
    
    
    
    
}


@end

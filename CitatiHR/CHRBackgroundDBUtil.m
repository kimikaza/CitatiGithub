//
//  CHRBackgroundDBUtil.m
//  CitatiHR
//
//  Created by Zoran Pleško on 14/05/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import "CHRBackgroundDBUtil.h"
#import "CHRAppDelegate.h"
#import "MASDataSource.h"
#import "Citation.h"
#import "Author.h"
#import "Theme.h"

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
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Citation"];
        [fetchRequest setResultType:NSDictionaryResultType];
        NSExpression *expression = [NSExpression expressionForKeyPath:@"remote_id"];
        NSExpression *maxExpression= [NSExpression expressionForFunction:@"max:" arguments:@[expression]];
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        [expressionDescription setName:@"maxId"];
        [expressionDescription setExpression:maxExpression];
        [expressionDescription setExpressionResultType:NSInteger32AttributeType];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
        NSArray *object;
        object = [_privateContext executeFetchRequest:fetchRequest error:nil];
        NSNumber *maxCitatID = [object[0] valueForKey:@"maxId"];
        [self getNewDataFromWeb:maxCitatID page:0];
        
        
    }];
}

- (void) getNewDataFromWeb:(NSNumber *)maxCitatID page:(NSInteger)page
    {
        MASDataSource *dataSource = [MASDataSource sharedInstance];
        //koment
        NSInteger nextPage = page++;
        [dataSource getNewCitationData:^(id responseObject) {
            //
            NSArray *posts = [responseObject objectForKey:@"posts"];
            BOOL cont = [self parseAllPostsIntoDatabase:posts maxCitatID:maxCitatID];
            if(cont){
                [self getNewDataFromWeb:maxCitatID page:nextPage];
            }
            
            
        } failure:^(NSError *error) {
            //
        } params:@{@"json":@"get_posts", @"orderby":@"ID", @"order":@"desc", @"count":@"20",
                   @"page":[NSString stringWithFormat:@"%ld", page]}];
    }
   
    
- (BOOL)parseAllPostsIntoDatabase:(NSArray *)posts maxCitatID:(NSNumber *)maxCitatID
{
    BOOL ret = YES;
    for(NSDictionary *post in posts){
        NSNumber *remote_id = [NSNumber numberWithInteger:[[post objectForKey:@"id"] integerValue]] ;
        if([remote_id compare:maxCitatID] == NSOrderedAscending || [remote_id compare:maxCitatID] == NSOrderedSame){
            ret = NO;
            break;
        }
        Citation *cit = [NSEntityDescription insertNewObjectForEntityForName:@"Citation" inManagedObjectContext:_privateContext];
        cit.favourite = [NSNumber numberWithBool:NO];
        cit.text = [post objectForKey:@"title"];
        cit.remote_id = remote_id;
        cit.timeStamp = [self makeDateFromString:[post objectForKey:@"date"]];
        
            
        NSArray *remoteAuthors = [post objectForKey:@"taxonomy_autor"];
        NSDictionary *remoteAuthor = remoteAuthors[0];
        
        Author *author = [self getAuthorForRemoteAuthor:remoteAuthor];
        author.name = [remoteAuthor objectForKey:@"title"];
        author.remote_id = [NSString stringWithFormat:@"%ld", (long)[(NSNumber *)[remoteAuthor objectForKey:@"id"] integerValue]];
        cit.author = author;
        [author addCitationsObject:cit];
        
        NSArray *remoteThemes = [post objectForKey:@"categories"];
        NSDictionary *remoteTheme = remoteThemes[0];
        
        
        Theme *theme = [self getThemeForRemoteTheme:remoteTheme];
        theme.text = [remoteTheme objectForKey:@"title"];
        theme.remote_id = [NSString stringWithFormat:@"%ld", (long)[(NSNumber *)[remoteTheme objectForKey:@"id"] integerValue]];
        cit.theme = theme;
        [theme addCitationsObject:cit];
        
    }
    [self saveContext];
    return ret;
    NSLog(@"GOTOVO");
}

- (NSDate *)makeDateFromString:(NSString *)string
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [df dateFromString:string];
    
}


-(Theme *)getThemeForRemoteTheme:(NSDictionary *)theme
{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Theme"];
    NSString *rem_id = [NSString stringWithFormat:@"%ld", (long)[(NSNumber *)[theme objectForKey:@"id"] integerValue]];
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"remote_id = %@", rem_id];
    [fr setPredicate:pr];
    NSArray *results = [_privateContext executeFetchRequest:fr error:nil];
    if(results.count > 0){
        return results[0];
    }else{
        return [NSEntityDescription insertNewObjectForEntityForName:@"Theme" inManagedObjectContext:_privateContext];
    }
    
    
}

- (Author *)getAuthorForRemoteAuthor:(NSDictionary *)author
{
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Author"];
    NSString *rem_id = [NSString stringWithFormat:@"%ld", (long)[(NSNumber *)[author objectForKey:@"id"] integerValue]];
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"remote_id = %@", rem_id];
    [fr setPredicate:pr];
    NSArray *results = [_privateContext executeFetchRequest:fr error:nil];
    if(results.count > 0){
        return results[0];
    }else{
        return [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:_privateContext];
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _privateContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}





@end

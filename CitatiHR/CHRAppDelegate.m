//
//  CHRAppDelegate.m
//  CitatiHR
//
//  Created by Zoran Pleško on 22/02/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import "CHRAppDelegate.h"

#import "CHRMasterViewController.h"

#import "ECSlidingViewController.h"
#import "CHRMenuViewController.h"

#import "Author.h"
#import "Theme.h"
#import "Citation.h"
#import "MASDataSource.h"

#import "CHRBackgroundDBUtil.h"

@implementation CHRAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static void uncaughtExeptionHandler(NSException *exception){
    NSLog(@"Unhandled exception: %@", exception.description);
    NSLog(@"Stack trace:%@",  [exception callStackSymbols].description);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExeptionHandler);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        CHRMasterViewController *controller = (CHRMasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    } else {
        CHRMasterViewController *controller = [[CHRMasterViewController alloc] init];
        [controller setSvi:CHRResultSetTypeAll];
        CHRMenuViewController *menuController = [[CHRMenuViewController alloc] init];
        ECSlidingViewController *slidingController = [ECSlidingViewController slidingWithTopViewController:controller];
        [slidingController setUnderLeftViewController:menuController];

        self.window.rootViewController = slidingController;
        
        controller.managedObjectContext = self.managedObjectContext;
    }
    [self.window makeKeyAndVisible];
    [self getDataFromWeb];
    [self writeAllFontsToConsole];
    CHRBackgroundDBUtil *dbUtil = [CHRBackgroundDBUtil sharedInstance];
    [dbUtil fetchAditionalDataFromServer];
    [self scheduleNotification];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSArray * scheduledApplications = application.scheduledLocalNotifications;
    int len = scheduledApplications.count;
    for (int i = 0; i<len; i++) {
        NSLog(@"ID: %@", [[scheduledApplications objectAtIndex:i] userInfo]);
    }
    return YES;
}

- (void)writeAllFontsToConsole
{
    NSArray *familyNames = [UIFont familyNames];
    for(NSString *familyName in familyNames)
    {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for(NSString *fontName in fontNames)
        {
            NSLog(@"FONT NAME: %@", fontName);
        }
    }
}

#pragma mark - database initialization

- (void)getDataFromWeb
{
    MASDataSource *dataSource = [MASDataSource sharedInstance];
    //koment
    [dataSource getAllCitationData:^(id responseObject) {
        //
        NSArray *posts = [responseObject objectForKey:@"posts"];
        [self parseAllPostsIntoDatabase:posts];
    } failure:^(NSError *error) {
        //
    } params:@{@"json":@"get_posts", @"orderby":@"ID", @"order":@"desc", @"count":@"5200", @"page":@"1"}];
}

- (void)parseAllPostsIntoDatabase:(NSArray *)posts
{
    for(NSDictionary *post in posts){
        Citation *cit = [NSEntityDescription insertNewObjectForEntityForName:@"Citation" inManagedObjectContext:_managedObjectContext];
        cit.favourite = [NSNumber numberWithBool:NO];
        cit.text = [post objectForKey:@"title"];
        cit.remote_id = [NSNumber numberWithInteger:[[post objectForKey:@"id"] integerValue]] ;
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
    NSArray *results = [_managedObjectContext executeFetchRequest:fr error:nil];
    if(results.count > 0){
        return results[0];
    }else{
        return [NSEntityDescription insertNewObjectForEntityForName:@"Theme" inManagedObjectContext:_managedObjectContext];
    }
    
    
}

- (Author *)getAuthorForRemoteAuthor:(NSDictionary *)author
{
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Author"];
    NSString *rem_id = [NSString stringWithFormat:@"%ld", (long)[(NSNumber *)[author objectForKey:@"id"] integerValue]];
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"remote_id = %@", rem_id];
    [fr setPredicate:pr];
    NSArray *results = [_managedObjectContext executeFetchRequest:fr error:nil];
    if(results.count > 0){
        return results[0];
    }else{
        return [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:_managedObjectContext];
    }
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CitatiHR" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CitatiHR.sqlite"];
    
    //NSURL *storeURLSHM = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CitatiHR.sqlite-shm"];
    
    //NSURL *storeURLWAL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CitatiHR.sqlite-wal"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:storeURL.path]) {
        NSString *presetDBPathInMainBundle = [[NSBundle mainBundle] pathForResource:@"CitatiHR" ofType:@"sqlite"];
        //NSString *presetDBPathInMainBundleSHM = [[NSBundle mainBundle] pathForResource:@"CitatiHR" ofType:@"sqlite-shm"];
        //NSString *presetDBPathInMainBundleWAL = [[NSBundle mainBundle] pathForResource:@"CitatiHR" ofType:@"sqlite-wal"];
        [fileManager copyItemAtPath:presetDBPathInMainBundle toPath:storeURL.path error:nil];
        //[fileManager copyItemAtPath:presetDBPathInMainBundleSHM toPath:storeURLSHM.path error:nil];
        //[fileManager copyItemAtPath:presetDBPathInMainBundleWAL toPath:storeURLWAL.path error:nil];
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - NotificationScheduling

- (void)scheduleNotification{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *today = [NSDate date];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *compsToday = [calendar components:unitFlags fromDate:today];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [compsToday setHour:9];
    today = [calendar dateFromComponents:compsToday];
    [comps setSecond:30];
    
    for (int i=0; i<60; i++) {
        [comps setDay:i];
        NSDate *tomorrow = [calendar dateByAddingComponents:comps toDate:today  options:0];

        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
        return;
        //[localNotif setSoundName:@"Cartoon.caf"];
        localNotif.fireDate = tomorrow;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.alertBody = @"poruka";
    
        //localNotif.alertBody = [NSString stringWithFormat:[self.st locStr:@"%@ in %i minutes."],
                           // [[e valueForKey:@"film"] valueForKey:[self.st sufStr:@"name"]], minutesBefore];
        localNotif.alertAction = @"View Details";
    
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *idForNotif = [df stringFromDate:tomorrow];
        idForNotif = [@"citati" stringByAppendingString:idForNotif];
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:idForNotif forKey:@"ID"];
        localNotif.userInfo = infoDict;
    
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

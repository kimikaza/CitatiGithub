//
//  CHRMasterViewController.h
//  CitatiHR
//
//  Created by Zoran Pleško on 22/02/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHRDetailViewController;

#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, CHRResultSetType) {
    CHRResultSetTypeAll,
    CHRResultSetTypeSearch,
    CHRResultSetTypeFavorites
};

@interface CHRMasterViewController : UIViewController <UIActionSheetDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) CHRResultSetType svi;
@property (nonatomic, strong) NSString *tematika;
@property (nonatomic, strong) NSString *autor;
@property (nonatomic, strong) NSString *searchString;

@end

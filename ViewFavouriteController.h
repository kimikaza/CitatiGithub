//
//  ViewFavouriteController.h
//  CitatiHR
//
//  Created by Zoran Pleško on 09/04/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface ViewFavouriteController : UIViewController <UIActionSheetDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end


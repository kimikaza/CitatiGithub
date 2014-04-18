//
//  CHRCitatCell.h
//  CitatiHR
//
//  Created by Zoran Pleško on 22/03/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHRCitatCell : UICollectionViewCell <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UILabel *citat;
@property (nonatomic, weak) IBOutlet UILabel *author;

@end

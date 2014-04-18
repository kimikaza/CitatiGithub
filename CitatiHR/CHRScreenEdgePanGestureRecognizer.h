//
//  CHRScreenEdgePanGestureRecognizer.h
//  CitatiHR
//
//  Created by Zoran Pleško on 22/03/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHRScreenEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer;

@end

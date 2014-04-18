//
//  CHRScreenEdgePanGestureRecognizer.m
//  CitatiHR
//
//  Created by Zoran Pleško on 22/03/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import "CHRScreenEdgePanGestureRecognizer.h"

@implementation CHRScreenEdgePanGestureRecognizer

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    if([preventedGestureRecognizer isKindOfClass:[CHRScreenEdgePanGestureRecognizer class]] ||
       [preventedGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) return NO;
    return YES;
}

@end

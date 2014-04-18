//
//  CHRCitatCell.m
//  CitatiHR
//
//  Created by Zoran Pleško on 22/03/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import "CHRCitatCell.h"

@interface CHRCitatCell ()<UIGestureRecognizerDelegate>


@end
@implementation CHRCitatCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




@end

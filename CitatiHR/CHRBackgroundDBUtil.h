//
//  CHRBackgroundDBUtil.h
//  CitatiHR
//
//  Created by Zoran Pleško on 14/05/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CHRBackgroundDBUtil : NSObject
+(CHRBackgroundDBUtil *) sharedInstance;
-(void) fetchAditionalDataFromServer;
@end

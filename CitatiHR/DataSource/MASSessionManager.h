//
//  MASSessionManager.h
//  vrtii
//
//  Created by Ivana Rast on 24/03/14.
//  Copyright (c) 2014 Ivana Rast. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface MASSessionManager : AFHTTPSessionManager

+ (MASSessionManager *) sharedClient;

@end

//
//  MASSessionManager.m
//  vrtii
//
//  Created by Ivana Rast on 24/03/14.
//  Copyright (c) 2014 Ivana Rast. All rights reserved.
//

#import "MASSessionManager.h"

@implementation MASSessionManager

+ (MASSessionManager *)sharedClient
{
    static MASSessionManager *__instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[MASSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    });
    
    return __instance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
		
		[[AFNetworkReachabilityManager sharedManager] startMonitoring];
		
		//TODO: setReachabilityStatusChangeBlock
    }
    
    return self;
}

@end

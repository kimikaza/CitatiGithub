//
//  MASDataSource.h
//  vrtii
//
//  Created by Ivana Rast on 21/03/14.
//  Copyright (c) 2014 Ivana Rast. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MASMethodType) {
	MASMethodGET,
	MASMethodPUT,
	MASMethodPOST
};

@interface MASDataSource : NSObject

+ (MASDataSource *)sharedInstance;

- (void)getAllCitationData:(void (^)(id responseObject))success
		  failure:(void (^)(NSError *error))failure
		   params:(NSDictionary *)params;

- (void)getNewCitationData:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure
                    params:(NSDictionary *)params;



@end



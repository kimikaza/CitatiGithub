//
//  MASDataSource.m
//  vrtii
//
//  Created by Ivana Rast on 21/03/14.
//  Copyright (c) 2014 Ivana Rast. All rights reserved.
//


#import "MASDataSource.h"
#import "MASSessionManager.h"

#import "CHRAppDelegate.h"

#import "AFHTTPRequestOperation.h"
#import "AFNetworkReachabilityManager.h"


@interface MASDataSource ()

@property(nonatomic, strong) NSManagedObjectContext *context;

@end


@implementation MASDataSource


+ (MASDataSource *)sharedInstance
{
    static MASDataSource *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MASDataSource alloc] init];
		[_sharedInstance setContext:((CHRAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext];
    });
    
    return _sharedInstance;
}

- (void)getAllCitationData:(void (^)(id responseObject))success
                  failure:(void (^)(NSError *error))failure
                   params:(NSDictionary *)params{
    [self callAPIWithPath:@""
               Dictionary:params
                   Method:MASMethodGET
                  Success:success
                  Failure:failure];
}




- (void)callAPIWithPath:(NSString *)path
             Dictionary:(NSDictionary *)params
                 Method:(MASMethodType)method
                Success:(void (^)(id responseObject))success
                Failure:(void (^)(NSError *error))failure {
	
	MASSessionManager *client = [MASSessionManager sharedClient];
	
//	if(![[AFNetworkReachabilityManager sharedManager] isReachable]) {
//		return;
//	}

	AFHTTPRequestSerializer *httpSerializerReq = [AFHTTPRequestSerializer serializer];
	AFJSONResponseSerializer *jsonSerializerResp = [AFJSONResponseSerializer serializer];
	
	
	client.requestSerializer = httpSerializerReq;
	client.responseSerializer = jsonSerializerResp;
	
	if (method == MASMethodGET) {
		
		[client GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
			
			success(responseObject);
			
		} failure:^(NSURLSessionDataTask *task, NSError *error) {
			failure(error);
		}];
		
	} else if(method == MASMethodPOST) {
		
		[client POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
			success(responseObject);
		} failure:^(NSURLSessionDataTask *task, NSError *error) {
			failure(error);
		}];
	}
    
}

@end

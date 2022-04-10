//
//  OSUser.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 7/23/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <FacebookSDK/FacebookSDK.h>

@class OSUser;
typedef void (^OSUserResultBlock)(OSUser *user, NSError *error, id response);

@interface OSUser : NSObject
+(OSUser *) currentUser;
+ (void)facebookLogInWithFacebookUser: (id<FBGraphUser>)user block:(OSUserResultBlock)block;
+ (void) loginWithUsername: (NSString *) username password: (NSString *) password block:(OSUserResultBlock)block;
+ (void) signupWithParams: (NSDictionary *) params block:(OSUserResultBlock)block;
+(void) mergeWithParams:(NSDictionary *)params block:(OSUserResultBlock)block;
+(void) refreshWithBlock:(OSUserResultBlock)block ;
+ (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+(void) updateUserWithRefreshID: (NSString *) refresh andSessionID: (NSString *) session;
+(void) logout;

@property (nonatomic) NSString *refresh_id;
@property (nonatomic) NSString *session_id;
@end

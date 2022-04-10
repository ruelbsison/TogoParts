//
//  OSUser.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 7/23/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSUser.h"

@implementation OSUser

static OSUser *currentUser = nil;
+ (id)currentUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        currentUser = [[self alloc] init];
    });
    return currentUser;
}

+ (void)facebookLogInWithFacebookUser: (id<FBGraphUser>)user block:(OSUserResultBlock)block {
//    NSLog(@"fb User: %@", user);
    NSString *fbId = user[@"id"];
    NSString *fbEmail = user[@"email"];
    NSNumber *loginTime = [NSNumber numberWithInt: (int) [[NSDate date] timeIntervalSince1970]];
    NSString *loginTimeString = [loginTime stringValue];
    NSLog(@"loginTime: %@", loginTime);
    NSString *tgpKey = [OSHelpers sha256HashFor: [NSString stringWithFormat:@"%@%@%@", fbId, loginTimeString, TGPClientKey]];
    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    NSDictionary *params =@{@"FBid": fbId, @"FBemail": fbEmail, @"TgpKey": tgpKey, @"AccessToken": accessToken, @"logintime": loginTime};
    NSLog(@"parameters: %@", params);
    
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    [testManager POST: @"https://www.togoparts.com/iphone_ws/user-login.php?source=ios" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"signin responseObject: %@", responseObject);
        NSDictionary *result = responseObject[@"Result"];
        if (result) {
            if ([result[@"Return"] isEqualToString: @"success"]) {
//                currentUser = [OSUser new];
//                currentUser.refresh_id = result[@"refresh_id"];
//                currentUser.session_id = result[@"session_id"];
                [OSUser updateUserWithRefreshID: result[@"refresh_id"] andSessionID: result[@"session_id"]];
            }
            if (block) {
                block(currentUser, nil, responseObject);
            }
        } else {
            if (block) {
                block(currentUser, nil, responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sign in error: %@", error.localizedDescription);
        NSLog(@"of request: %@ and response: %@", operation.request, operation.responseObject);
        if (block) block(nil, error, operation.responseObject);
    }];
}

+(void) loginWithUsername:(NSString *)username password:(NSString *)password block:(OSUserResultBlock)block {
    NSNumber *loginTime = [NSNumber numberWithInt: (int) [[NSDate date] timeIntervalSince1970]];
    NSString *loginTimeString = [loginTime stringValue];
    NSString *tgpKey = [OSHelpers sha256HashFor: [NSString stringWithFormat:@"%@%@%@", password, loginTimeString, TGPClientKey]];
    
    NSDictionary *params = @{@"TgpUserName": username, @"logintime": loginTimeString, @"TgpKey": tgpKey};
    NSLog(@"normal params: %@", params);
    
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    [testManager POST: @"https://www.togoparts.com/iphone_ws/user-login.php?source=ios" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"normal signin responseObject: %@", responseObject);
        NSDictionary *result = responseObject[@"Result"];
        if (result) {
            if ([result[@"Return"] isEqualToString: @"new"] || [result[@"Return"] isEqualToString: @"success"]) {
//                currentUser = [OSUser new];
//                currentUser.refresh_id = result[@"refresh_id"];
//                currentUser.session_id = result[@"session_id"];
                [OSUser updateUserWithRefreshID: result[@"refresh_id"] andSessionID: result[@"session_id"]];
                if (block) {
                    block(currentUser, nil, responseObject);
                }
            } else if ([result[@"Return"] isEqualToString: @"error"] || [result[@"Return"] isEqualToString: @"banned"]) {
                if (block) {
                    block(nil, nil, responseObject);
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sign in error: %@", error.localizedDescription);
       if (block) block(nil, error, operation.responseObject);
    }];
}

+(void) signupWithParams:(NSDictionary *)params block:(OSUserResultBlock)block {
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    [testManager POST: @"https://www.togoparts.com/iphone_ws/fb-user-new.php?source=ios" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"signup responseObject: %@", responseObject);
        NSDictionary *result = responseObject[@"Result"];
        if (result) {
            NSString *returnString = result[@"Return"];
            if ([returnString isEqualToString: @"success"]) {
//                currentUser = [OSUser new];
//                currentUser.refresh_id = result[@"refresh_id"];
//                currentUser.session_id = result[@"session_id"];
                [OSUser updateUserWithRefreshID: result[@"refresh_id"] andSessionID: result[@"session_id"]];
                if (block) {
                    block(currentUser, nil, responseObject);
                }
            } else if ([returnString isEqualToString: @"error"]) {
                if (block) {
                    block(nil, nil, responseObject);
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sign up error: %@", error.localizedDescription);
        NSLog(@"of request: %@ and response: %@", operation.request, operation.responseObject);
        if (block) block(nil, error, operation.responseObject);
    }];
}

+(void) mergeWithParams:(NSDictionary *)params block:(OSUserResultBlock)block {
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    [testManager POST: @"https://www.togoparts.com/iphone_ws/fb-user-merge.php?source=ios" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"merge responseObject: %@", responseObject);
        NSDictionary *result = responseObject[@"Result"];
        if (result) {
            NSString *returnString = result[@"Return"];
            if ([returnString isEqualToString: @"success"]) {
                //                currentUser = [OSUser new];
                //                currentUser.refresh_id = result[@"refresh_id"];
                //                currentUser.session_id = result[@"session_id"];
                [OSUser updateUserWithRefreshID: result[@"refresh_id"] andSessionID: result[@"session_id"]];
                if (block) {
                    block(currentUser, nil, responseObject);
                }
            } else {
                if (block) {
                    block(nil, nil, responseObject);
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sign up error: %@", error.localizedDescription);
        NSLog(@"of request: %@ and response: %@", operation.request, operation.responseObject);
        if (block) block(nil, error, operation.responseObject);
    }];
}

+(void) refreshWithBlock:(OSUserResultBlock)block {
    OSUser *user = currentUser;
    NSString *refresh_id = [OSHelpers sha256HashFor: [NSString stringWithFormat:@"%@%@", user.refresh_id, TGPClientKey]];
    NSDictionary *params = @{@"session_id": user.session_id, @"refresh_id": refresh_id};
    NSLog(@"refresh params: %@", params);
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    [testManager POST: @"https://www.togoparts.com/iphone_ws/user-session-refresh.php?source=ios" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"refresh session responseObject: %@", responseObject);
        NSDictionary *result = responseObject[@"Result"];
        if ([result[@"Return"] isEqualToString: @"success"]) {
            [self updateUserWithRefreshID: result[@"refresh_id"] andSessionID: result[@"session_id"]];
            if (block) block(currentUser, nil, responseObject);
        } else {
            if (block) block(nil, nil, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(nil, error, operation.responseObject);
    }];
}

+(AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    OSUser *user = [OSUser currentUser];
    NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithDictionary: @{@"session_id": user.session_id}];
    [params addEntriesFromDictionary: parameters];
    
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [testManager POST: URLString parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"user post responseObject: %@", responseObject);
        NSDictionary *result = responseObject[@"Result"];
        if (result) {
            if ([result[@"Return"] isEqualToString: @"expired"]) {
                [OSUser refreshWithBlock:^(OSUser *user, NSError *error, id response) {
                    if (user) {
                        [OSUser POST: URLString parameters: parameters success: success failure: failure];
                    }
                }];
            } else if ([result[@"Return"] isEqualToString: @"error"]) {
//                [OSUser logout];
                if (success)
                    success(operation, responseObject);
            } else if ([result[@"Return"] isEqualToString: @"banned"]) {
//                VTTShowAlertView(@"Banned",  result[@"Message"],  @"Ok");
                [OSUser logout];
                if (success)
                    success(operation, responseObject);
            } else {
                //Success
                if (success)
                    success(operation, responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sign in error: %@", error.localizedDescription);
        NSLog(@"of request: %@ and response: %@", operation.request, operation.responseObject);
        if (failure) {
            failure(operation, error);
        }
    }];

    return operation;
}

+(AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    OSUser *user = [OSUser currentUser];
    NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithDictionary: @{@"session_id": user.session_id}];
    [params addEntriesFromDictionary: parameters];
    
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [testManager POST: URLString parameters: params constructingBodyWithBlock: block success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"user post responseObject: %@", responseObject);
        NSDictionary *result = responseObject[@"Result"];
        if (result) {
            if ([result[@"Return"] isEqualToString: @"expired"]) {
                [OSUser refreshWithBlock:^(OSUser *user, NSError *error, id response) {
                    if (user) {
                        [OSUser POST: URLString parameters: parameters constructingBodyWithBlock: block success: success failure: failure];
                    }
                }];
            } else if ([result[@"Return"] isEqualToString: @"error"]) {
//                [OSUser logout];
                if (success)
                    success(operation, responseObject);
            } else {
                //Success
                if (success)
                    success(operation, responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sign in error: %@", error.localizedDescription);
        NSLog(@"of request: %@ and response: %@", operation.request, operation.responseObject);
        if (failure) {
            failure(operation, error);
        }
    }];
    
    return operation;
}

+(void) updateUserWithRefreshID:(NSString *)refresh andSessionID:(NSString *)session {
    if (refresh && session) {
        currentUser = [OSUser new];
        currentUser.refresh_id = refresh;
        currentUser.session_id = session;
        [[NSUserDefaults standardUserDefaults] setObject: refresh forKey: @"OSRefreshID"];
        [[NSUserDefaults standardUserDefaults] setObject: session forKey: @"OSSessionID"];
    }
}

+(void) logout {
   OSUser *user = currentUser;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"OSRefreshID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"OSSessionID"];
//    if (FBSession.activeSession.isOpen)
//    {
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
//    }
    if (currentUser) {
        NSString *refresh_id = [OSHelpers sha256HashFor: [NSString stringWithFormat:@"%@%@", user.refresh_id, TGPClientKey]];
        NSDictionary *params = @{@"session_id": user.session_id, @"refresh_id": refresh_id};
        NSLog(@"logout params: %@", params);
        user.session_id = nil;
        user.refresh_id = nil;
        currentUser = nil;
        user = nil;
        
        AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
        [testManager POST: @"https://www.togoparts.com/iphone_ws/user-logout.php?source=ios" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"logout responseObject: %@", responseObject);
            NSDictionary *result = responseObject[@"Result"];
            if (result) {
                NSString *returnString = result[@"Return"];
                if ([returnString isEqualToString: @"success"]) {
                    
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName: OS_USER_LOGGED_OUT_NOTIFICATON object: nil userInfo: nil];
}
@end

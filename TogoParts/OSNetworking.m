//
//  OSNetworking.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/17/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSNetworking.h"

@implementation OSNetworking
-(void) getListLatestAds {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://www.togoparts.com/iphone_ws/mp_list_latest_ads.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
@end

//
//  OSListingViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/20/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSListingViewController : UITableViewController
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString *parameterString;
@property (nonatomic) __block BOOL isSearch;
@property (nonatomic) __block BOOL isFromBikeShop;
@property (nonatomic) __block BOOL isShortList;
@property (nonatomic) BOOL showFilterButton;
@end

//
//  OSBikeshopListViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/10/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSBikeshopListViewController;

@protocol OSBikeshopListProtocol <NSObject>

-(void) bikeshopList: (OSBikeshopListViewController *) vc didLoadData: (NSDictionary *)data;

@end
@interface OSBikeshopListViewController : UITableViewController

@property (nonatomic,weak) id <OSBikeshopListProtocol> delegate;

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic) BOOL isSearch;
@property (nonatomic) BOOL fromMap;

-(void) goToBikeShopDetailWithSid: (NSString *) sid animated: (BOOL) animated;
@end

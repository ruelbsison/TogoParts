//
//  OSMapViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/21/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSBikeshopListViewController.h"

@interface OSMapViewController : UIViewController <OSBikeshopListProtocol>
@property (nonatomic, strong) NSMutableDictionary *data;

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic) BOOL isSearch;
@property (nonatomic) BOOL fromList;
@end

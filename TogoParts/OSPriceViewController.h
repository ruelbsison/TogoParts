//
//  OSPriceViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/5/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSPriceViewController;
@protocol OSPriceControllerDelegate <NSObject>

-(void) priceVC: (OSPriceViewController *) priceVC pickedData: (NSDictionary *) data;

@end

@interface OSPriceViewController : UITableViewController
@property (nonatomic, weak) id <OSPriceControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSMutableDictionary *info;
@end

//
//  OSItemInfoViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSMoreDetailController.h"

@class OSItemInfoViewController;
@protocol OSItemVCDelegate <NSObject, OSMoreDetailVCDelegate>

-(void) itemVC: (OSItemInfoViewController *) itemVC pickedData: (NSDictionary *) data;

@end

@interface OSItemInfoViewController : UITableViewController
@property (nonatomic, weak) id <OSItemVCDelegate> delegate;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSMutableDictionary *data;

@property (nonatomic) BOOL isEdit;
@end

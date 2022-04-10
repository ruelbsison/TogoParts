//
//  OSMoreDetailController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/5/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OSMoreDetailController;
@protocol OSMoreDetailVCDelegate <NSObject>

-(void) moreDetailVC: (OSMoreDetailController *) itemVC pickedData: (NSDictionary *) data;

@end
@interface OSMoreDetailController : UITableViewController
@property (nonatomic) BOOL isEdit;

@property (nonatomic, weak) id <OSMoreDetailVCDelegate> delegate;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSMutableDictionary *data;
@end

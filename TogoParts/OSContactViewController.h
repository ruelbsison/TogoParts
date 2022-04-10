//
//  OSContactViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/5/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSContactViewController;
@protocol OSContactVCDelegate <NSObject>

-(void) contactVC: (OSContactViewController *) contactVC pickedData: (NSDictionary *) data;

@end

@interface OSContactViewController : UITableViewController
@property (nonatomic) BOOL isEdit;
@property (nonatomic, weak) id <OSContactVCDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *data;

@end

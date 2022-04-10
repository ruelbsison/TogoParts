//
//  OSCategoryViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSubCategoryViewController.h"

@class OSCategoryViewController;

@protocol OSCategoryDelegate <NSObject, OSSubCategoryDelegate>

-(void) categoryVC: (OSCategoryViewController *) categoryVC didSelectedCategory: (NSNumber *) category;

@end

@interface OSCategoryViewController : UITableViewController
@property (nonatomic, weak) id <OSCategoryDelegate> delegate;
@property (nonatomic) NSNumber *cid;
@property (nonatomic, copy) NSDictionary *categoryData;

@end

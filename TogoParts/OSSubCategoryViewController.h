//
//  OSSubCategoryViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSubCategoryViewController;

@protocol OSSubCategoryDelegate <NSObject>

-(void) subCategoryVC: (OSSubCategoryViewController *) subCategoryVC didSelectedSubCategory: (NSNumber *) subCat;

@end

@interface OSSubCategoryViewController : UITableViewController
@property (nonatomic, weak) id <OSSubCategoryDelegate> delegate;
@property (nonatomic) NSNumber *cid;
@property (nonatomic) NSNumber *gid;
@property (nonatomic, copy) NSDictionary *categoryData;

@end

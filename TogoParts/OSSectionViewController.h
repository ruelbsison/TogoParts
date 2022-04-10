//
//  OSSectionViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCategoryViewController.h"

@class OSSectionViewController;

@protocol OSSectionDelegate <NSObject, OSCategoryDelegate>

-(void) sectionVC: (OSSectionViewController *) sectionVC didSelectedSection: (NSNumber *) section withData: (NSDictionary *) data;
-(void) sectionVCDidCancelled: (OSSectionViewController *) sectionVC;

@end

@interface OSSectionViewController : UITableViewController
@property (nonatomic, weak) id <OSSectionDelegate> delegate;
@property (nonatomic, copy) NSDictionary *categoryData;
@property (nonatomic) NSNumber *tcreds;
@property (nonatomic) NSNumber *adType;
@end

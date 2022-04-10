//
//  OSSearchViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSearchViewController;

@protocol OSSearchViewControllerDelegate <NSObject>

-(void) searchViewController: (OSSearchViewController *) searchVC didSelectedParameters: (NSDictionary *) parameters;

@end

@interface OSSearchViewController : UITableViewController

@property (nonatomic, weak) id <OSSearchViewControllerDelegate> delegate;

@property (nonatomic) NSDictionary *searchParams;
@property (nonatomic) BOOL isFromMainSearch;

@end

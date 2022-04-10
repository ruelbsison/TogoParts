//
//  OSPostViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSPostViewController;
@protocol OSPostDelegate <NSObject>

-(void) postController: (OSPostViewController *) postController wantToGoToPage: (TOGOTabBarControllerIndex) index;

@end

@interface OSPostViewController : UITableViewController
@property (nonatomic, weak) id <OSPostDelegate> delegate;
@property (nonatomic) NSString *aid;
@end

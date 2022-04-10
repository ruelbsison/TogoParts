//
//  OSAdDetailViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/21/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "OSImageView.h"

@interface OSAdDetailViewController : UITableViewController //<UIGestureRecognizerDelegate, OSImageViewDelegate>
@property (nonatomic, strong) NSString *aid;
@property (nonatomic) BOOL showSearchButton;
@property (nonatomic) BOOL showEditButton;
@end

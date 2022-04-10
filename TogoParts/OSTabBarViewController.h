//
//  OSTabBarViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 7/17/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSLogoutController.h"
#import "OSPostViewController.h"

@interface OSTabBarViewController : UITabBarController <OSLogoutDelegate, OSPostDelegate>
-(void) signin;
@end

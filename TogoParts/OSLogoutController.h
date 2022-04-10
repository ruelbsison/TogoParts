//
//  OSLogoutController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/6/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OSLogoutController;
@protocol OSLogoutDelegate <NSObject>

-(void) logoutVC: (OSLogoutController *) logoutVC wantToLogout: (BOOL) logout;

@end
@interface OSLogoutController : UITableViewController
@property (nonatomic, weak) id <OSLogoutDelegate> delegate;
@end

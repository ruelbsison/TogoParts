//
//  OSTabBarViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 7/17/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSTabBarViewController.h"
#import "OSUser.h"

@interface OSTabBarViewController () <UITabBarControllerDelegate, UIAlertViewDelegate>
@property (nonatomic) UINavigationController *signInNVC;
@property (nonatomic) UINavigationController *postNVC;

@property (nonatomic) __block BOOL presentedSignin;
@end

@implementation OSTabBarViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userLoggedIn:) name: OS_USER_LOGGED_IN_NOTIFICATON object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userLoggedOut:) name: OS_USER_LOGGED_OUT_NOTIFICATON object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userSkippedLogin:) name: OS_USER_SKIPPED_LOGGED_IN_NOTIFICION object: nil];
    self.delegate = self;
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    OSAppDelegate *appDelegate = (OSAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appDelegate.openForNotification) _presentedSignin = YES;
    
    if (![OSUser currentUser] && !_presentedSignin) {
        [self signin];
//        item.title = @"Login";
    }
}
-(void) signin {
    _presentedSignin = YES;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
    self.signInNVC = [storyboard instantiateViewControllerWithIdentifier: @"SigninNVC"];
    [self presentViewController: self.signInNVC animated: YES completion: nil];
}

-(void) userLoggedIn: (NSNotification *) noti {
    _presentedSignin = YES;

    if (self.signInNVC) {
        [self.signInNVC dismissViewControllerAnimated: YES completion: nil];
        self.signInNVC = nil;
        [self setSelectedIndex: TOGOMarketControllerIndex];
    }
//    [self updateLogoutTitle];
//    UITabBarItem *item = self.tabBar.items[TOGOLogoutControllerIndex];
//    item.title = @"Logout";
}

-(void) userLoggedOut: (NSNotification *) noti {
    if (!self.signInNVC) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
        self.signInNVC = [storyboard instantiateViewControllerWithIdentifier: @"SigninNVC"];
    }
    if (_postNVC && self.presentedViewController == _postNVC) {
        [_postNVC dismissViewControllerAnimated: YES completion:^{
            [self presentViewController: self.signInNVC animated: YES completion: nil];
        }];
    } else {
        if (!_signInNVC || self.presentedViewController != _signInNVC) {
            [self presentViewController: self.signInNVC animated: YES completion: nil];
        }
    }
//    [self updateLogoutTitle];
}

-(void) userSkippedLogin: (NSNotification *) noti {
    _presentedSignin = YES;
    if (self.presentedViewController) {
        [self setSelectedIndex: TOGOMarketControllerIndex];
        [self.moreNavigationController popToRootViewControllerAnimated: NO];
        [self.presentedViewController dismissViewControllerAnimated: YES completion:^{
        }];
        [self updateLogoutTitle];
    }
}

-(void) updateLogoutTitle {
    if (TOGOLogoutControllerIndex < self.viewControllers.count) {
        UIViewController *logoutVC = [self.viewControllers objectAtIndex: TOGOLogoutControllerIndex];
        if (logoutVC) {
            if (![OSUser currentUser]) {
//                UITabBarItem *tabBarItem = self.tabBar.items[TOGOLogoutControllerIndex];
//                tabBarItem.title = @"Login";
//                UITableViewController *moreTVC = self.moreNavigationController.viewControllers[0];
//                UITableViewCell *cell = [moreTVC.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: TOGOLogoutControllerIndex - 4 inSection: 0]];
//                cell.textLabel.text = @"Login";
            } else {
                logoutVC.tabBarItem.title = @"Logout";
            }
        }
    }
}

-(BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == self.viewControllers[TOGOPostControllerIndex])
    {
        if (![OSUser currentUser]) {
            [self signin];
            return NO;
        }
        self.postNVC = [self.storyboard instantiateViewControllerWithIdentifier: @"PostNVC"];
        OSPostViewController *postVC = _postNVC.viewControllers[0];
        postVC.delegate = self;
        [self presentViewController: _postNVC animated: NO completion: NO];
        return NO;
    }
    if (viewController == self.viewControllers[TOGOProfileControllerIndex]) {
        if (![OSUser currentUser]) {
            [self signin];
            return NO;
        }
    }
    if (viewController == self.viewControllers[TOGOLogoutControllerIndex]) {
        if ([OSUser currentUser]) {
            [[[UIAlertView alloc] initWithTitle: @"Logout confirm" message: @"Logout Togoparts account?" delegate: self cancelButtonTitle: @"NO" otherButtonTitles:@"YES", nil] show];
            return NO;
        } else {
            [self signin];
            return NO;
        }
    }
    /*
    else if (viewController == self.viewControllers[TOGOLogoutControllerIndex]) {
//        UIViewController *logoutVC = self.viewControllers[TOGOLogoutControllerIndex];
        UITabBarItem *item = tabBarController.tabBar.items[TOGOLogoutControllerIndex];
        if ([item.title isEqualToString: @"Logout"]) {
            [OSUser logout];
        } else {
            [self signin];
        }
        return NO;
    } else if (viewController == self.moreNavigationController) {
        [self updateLogoutTitle];
    }
     */
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString: @"Logout confirm"]) {
        [OSUser logout];
//        [[NSNotificationCenter defaultCenter] postNotificationName: OS_USER_LOGGED_OUT_NOTIFICATON object: nil];
    }
}

#pragma mark -OSPostDelegate
-(void) postController:(OSPostViewController *)postController wantToGoToPage:(TOGOTabBarControllerIndex)index {
    [self.postNVC dismissViewControllerAnimated: YES completion:^{
        [self setSelectedIndex: index];
    }];
}

#pragma mark - OSLogoutDelegate
-(void)logoutVC:(OSLogoutController *)logoutVC wantToLogout:(BOOL)logout {
    if (logout) {
//        [self setSelectedIndex: 4];
        [OSUser logout];
    } else {
//        [self setSelectedIndex: 4];
        [self signin];
    }

}
@end

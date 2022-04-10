//
//  OSLogoutController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/6/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSLogoutController.h"
#import "OSTabBarViewController.h"

@interface OSLogoutController () <UIAlertViewDelegate>
@property (nonatomic) BOOL showed;
@property (nonatomic) BOOL isPoped;

@end

@implementation OSLogoutController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = (OSTabBarViewController *) self.tabBarController;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
//    UITabBarItem *item = self.tabBarItem;
//    if ([item.title isEqualToString: @"Logout"]) {
//        //        [self.navigationController popViewControllerAnimated: YES];
//        if ([self.delegate respondsToSelector: @selector(logoutVC:wantToLogout:)]) {
//            [self.delegate logoutVC: self wantToLogout: YES];
//            //            [OSUser logout];
//        }
//    } else {
//        if ([self.delegate respondsToSelector: @selector(logoutVC:wantToLogout:)]) {
//            [self.delegate logoutVC: self wantToLogout: YES];
//        }
//        //        [(OSTabBarViewController *) self.tabBarController signin];
//    }
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
//    if (self.showed) {
//        self.showed = NO;
//        
//        [self.navigationController popViewControllerAnimated: NO];
//    } else {
    
        if ([OSUser currentUser]) {
            self.isPoped = NO;
            [[[UIAlertView alloc] initWithTitle: @"Logout confirm" message: @"Logout Togoparts account?" delegate: self cancelButtonTitle: @"NO" otherButtonTitles:@"YES", nil] show];
            [self.navigationController popViewControllerAnimated: NO];
        } else {
//            self.showed = YES;
            self.isPoped = YES;

            [self.navigationController popViewControllerAnimated: NO];

            if ([self.delegate respondsToSelector: @selector(logoutVC:wantToLogout:)]) {
                [self.delegate logoutVC: self wantToLogout: NO];
            }
        }
//    }
}

-(void) viewWillDisappear:(BOOL)animated {
//    self.showed = YES;
    if (!self.isPoped) {
//        self.isPoped = NO;
        self.showed = NO;
    }
    [super viewWillDisappear: animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex: buttonIndex];
    if ([alertView.title isEqualToString: @"Logout confirm"]) {
        if ([buttonTitle isEqualToString: @"YES"]) {
            if ([self.delegate respondsToSelector: @selector(logoutVC:wantToLogout:)]) {
                [self.delegate logoutVC: self wantToLogout: YES];
            }
        }
    }
}

@end

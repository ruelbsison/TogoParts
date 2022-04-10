//
//  OSAppDelegate.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/17/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSAppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "OSColorsPalette.h"

#import "OSTabBarViewController.h"
#import "OSHomeViewController.h"
#import "OSListingViewController.h"
#import "OSSearchViewController.h"
#import "GAI.h"
//#import "DFPInterstitial.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GoogleMobileAds/GoogleMobileAds.h"

#import "Reachability.h"

#import "OSUser.h"
#import "OSMarketViewController.h"
#import "OSBikeshopListViewController.h"

NSString * const OS_USER_LOGGED_IN_NOTIFICATON = @"OS_USER_LOGGED_IN_NOTIFICATON";
NSString * const OS_USER_LOGGED_OUT_NOTIFICATON = @"OS_USER_LOGGED_OUT_NOTIFICATON";
NSString * const OS_USER_SKIPPED_LOGGED_IN_NOTIFICION = @"OS_USER_SKIPPED_LOGGED_IN_NOTIFICION";

@interface OSAppDelegate ()
@property (nonatomic) DFPInterstitial *interstitial;
@end

@implementation OSAppDelegate

-(void) configureAppearances {
    if (VTTOSLessThan7) {
        [[UITabBar appearance] setBackgroundImage: [UIImage imageNamed: @"bottom-menu-bg-44"]];
        [[UITabBarItem appearance] setTitleTextAttributes: @{UITextAttributeTextColor: OSTogoTintColor} forState: UIControlStateSelected];
        [[UITabBarItem appearance] setTitleTextAttributes: @{UITextAttributeTextColor: OSTogoTabbarUnselected} forState: UIControlStateNormal];
        [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed: @"top-header-background-44"] forBarMetrics: UIBarMetricsDefault];
        [UIApplication sharedApplication].statusBarHidden = NO;
    } else {
        [self.window setTintColor: OSTogoTintColor];
        [[UITabBar appearance] setTintColor: OSTogoTintColor];
        [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed: @"top-header-background"] forBarMetrics: UIBarMetricsDefault];
        
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{UITextAttributeFont: [UIFont fontWithName: OSTogoFontName size: 28], UITextAttributeTextColor: [UIColor blackColor], UITextAttributeTextShadowColor: [UIColor clearColor] }];
}

// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    Reachability *internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"No Internet Connection" message: @"Turn on wifi or cellular to access Internet" delegate:Nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [alertView show];
        });
    };
    
    [internetReachableFoo startNotifier];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Push Notification
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    if ([application respondsToSelector: @selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    
    _openForNotification = NO;
    self.remoteNotiInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //User
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [OSUser updateUserWithRefreshID: [defaults objectForKey: @"OSRefreshID"] andSessionID: [defaults objectForKey: @"OSSessionID"]];
    
    [FBProfilePictureView class];
    
    self.appActivatedInFirstLaunch = YES;
    //Vendors
    // Optional: set Logger to VERBOSE for debug information.
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-479713-12"];
    
    // Override point for customization after application launch.
    [self configureAppearances];

    OSTabBarViewController *tabBarController = (OSTabBarViewController *) self.window.rootViewController;
    tabBarController.customizableViewControllers = [NSArray arrayWithObjects:nil];
    
    UITabBarItem *tabBarItem2 = tabBarController.tabBar.items[0];
    UITabBarItem *tabBarItem3 = tabBarController.tabBar.items[1];
    UITabBarItem *tabBarItem4 = tabBarController.tabBar.items[2];
    UITabBarItem *tabBarItem5 = tabBarController.tabBar.items[3];
    UITabBarItem *tabBarItem6 = tabBarController.tabBar.items[4];
    UITabBarItem *tabBarItem7 = tabBarController.tabBar.items[5];
//    UITabBarItem *tabBarItem8 = tabBarController.tabBar.items[6];
    
    if (VTTOSLessThan7) {
//        [tabBarItem1 setFinishedSelectedImage: [UIImage imageNamed: @"home-hover"] withFinishedUnselectedImage: [UIImage imageNamed: @"home"]];
        [tabBarItem2 setFinishedSelectedImage: [UIImage imageNamed: @"marketplace-hover"] withFinishedUnselectedImage: [UIImage imageNamed: @"marketplace"]];
        [tabBarItem3 setFinishedSelectedImage: [UIImage imageNamed: @"myads_menu_selected"] withFinishedUnselectedImage: [UIImage imageNamed: @"myads_menu"]];
        [tabBarItem4 setFinishedSelectedImage: [UIImage imageNamed: @"sell_menu_selected"] withFinishedUnselectedImage: [UIImage imageNamed: @"sell_menu"]];
        [tabBarItem5 setFinishedSelectedImage: [UIImage imageNamed: @"bikeshop-button-hover"] withFinishedUnselectedImage: [UIImage imageNamed: @"bikeshop-button"]];
        [tabBarItem6 setFinishedSelectedImage: [UIImage imageNamed: @"shortlisted-hover"] withFinishedUnselectedImage: [UIImage imageNamed: @"shortlisted"]];
//        [tabBarItem5 setFinishedSelectedImage: [UIImage imageNamed: @"marketplace-search-tab-hover-icon"] withFinishedUnselectedImage: [UIImage imageNamed: @"marketplace-search-tab-icon"]];
//        [tabBarItem6 setFinishedSelectedImage: [UIImage imageNamed: @"bikeshop-search-tab-hover-icon"] withFinishedUnselectedImage: [UIImage imageNamed: @"bikeshop-search-tab-icon"]];
        [tabBarItem7 setFinishedSelectedImage: [UIImage imageNamed: @"about-togoparts-tab-hover-icon"] withFinishedUnselectedImage: [UIImage imageNamed: @"about-togoparts-tab-icon"]];
    } else {
//        tabBarItem1 = [[UITabBarItem alloc] initWithTitle: @"Home" image: [UIImage imageNamed: @"home"] selectedImage: [UIImage imageNamed: @"home-hover"]];
        tabBarItem2 = [[UITabBarItem alloc] initWithTitle: @"Marketplace" image: [UIImage imageNamed: @"marketplace"] selectedImage: [UIImage imageNamed: @"marketplace-hover"]];
        tabBarItem3 = [[UITabBarItem alloc] initWithTitle: @"Shortlisted Ads" image: [UIImage imageNamed: @"shortlisted"] selectedImage: [UIImage imageNamed: @"shortlisted-hover"]];
        tabBarItem4 = [[UITabBarItem alloc] initWithTitle: @"Search" image: [UIImage imageNamed: @"marketplace-search-tab-icon"] selectedImage: [UIImage imageNamed: @"marketplace-search-tab-hover-icon"]];
        tabBarItem5 = [[UITabBarItem alloc] initWithTitle: @"Bikeshops" image: [UIImage imageNamed: @"bikeshop-button"] selectedImage: [UIImage imageNamed: @"bikeshop-button-hover"]];
        tabBarItem6 = [[UITabBarItem alloc] initWithTitle: @"Bikeshop Search" image: [UIImage imageNamed: @"bikeshop-search-tab-icon"] selectedImage: [UIImage imageNamed: @"bikeshop-search-tab-hover-icon"]];
        tabBarItem7 = [[UITabBarItem alloc] initWithTitle: @"Information" image: [UIImage imageNamed: @"about-togoparts-tab-icon"] selectedImage: [UIImage imageNamed: @"about-togoparts-tab-hover-icon"]];

    }
    
//     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager POST: @"https://www.togoparts.com/iphone_ws/user_login.php" parameters: @{@"message": @"Test from iOS app"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@ %@ %@", operation.request, operation.response, responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@ %@", operation.response, [error localizedDescription]);
//    }];
    

//    UINavigationController *homeNav = tabBarController.viewControllers[0];
//    OSHomeViewController *homeVC = homeNav.viewControllers[0];
//    [homeVC.navigationItem.backBarButtonItem setBackButtonBackgroundImage: [UIImage imageNamed: @"top-back-button"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [homeVC.navigationItem.backBarButtonItem  setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000) forBarMetrics:UIBarMetricsDefault];
//    

    OSListingViewController *shortListVC = ((UINavigationController *) tabBarController.viewControllers[TOGOShortListControllerIndex]).viewControllers[0];
    shortListVC.isShortList = YES;
    
    //Only splash the first time app launch
    if (self.appActivatedInFirstLaunch)
        [self splashInterstitial];
    
    self.appActivatedInFirstLaunch = NO;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.remoteNotiInfo = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSettings setDefaultAppID: @"198306676966429"];
    [FBAppEvents activateApp];
    
    [self testInternetConnection];
    
    if (self.remoteNotiInfo) {
        [self appRecievePushNotification];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

#pragma mark - Push Notification
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if ([application respondsToSelector: @selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceTokenData
{
    //	NSLog(@"My token is: %@", deviceToken);
    if ([application respondsToSelector: @selector(registerForRemoteNotifications)]) {
        if (!application.isRegisteredForRemoteNotifications) {
            return;
        }
    } else {
        if (application.enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone) {
            
        } else {
            return;
        }
    }
    
    //register to receive notifications
    if (deviceTokenData == nil) return;
    
    NSString* deviceToken = [[[[deviceTokenData description]
                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                              stringByReplacingOccurrencesOfString: @">" withString: @""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"%@",deviceToken);
    
    NSDictionary *param = @{@"device_token": deviceToken};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"https://www.togoparts.com/iphone_ws/app-ios-register.php?source=ios&v=1.2.4"parameters: param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userInfo for remoteNotification: %@", userInfo);
    
    NSString *currentLoc = self.remoteNotiInfo[@"app_loc"][@"loc"];
    NSString *newLoc = userInfo[@"app_loc"][@"loc"];
    if (currentLoc && newLoc && [currentLoc isEqualToString: newLoc]) {
        // Do nothing, the noti is the same
    } else {
        self.remoteNotiInfo = userInfo;
        
        if (application.applicationState == UIApplicationStateActive) {
            //            [self appRecievePushNotification];
        }
    }
    
}

-(void) gotoIndex: (TOGOTabBarControllerIndex) index parameters: (NSDictionary *) parameters withBlock: (void (^)(UINavigationController *navVC)) block {
    UITabBarController *tabBarViewController = (UITabBarController *) [self.window rootViewController];

    NSString *opt = parameters[@"opt_val"];
    
    UINavigationController *navVC = [tabBarViewController viewControllers][index];
    [navVC popToRootViewControllerAnimated: NO];
    
    if (opt) {
        if (block) block(navVC);
    }
    
    [tabBarViewController setSelectedIndex: index];
}

-(void) appRecievePushNotification {
    NSLog(@"self.remoteNotiInfo: %@", self.remoteNotiInfo);
    if (self.remoteNotiInfo) {
        self.openForNotification = YES;
        
        UITabBarController *tabBarViewController = (UITabBarController *) [self.window rootViewController];
        
        NSDictionary *parameters = self.remoteNotiInfo[@"app_loc"];
        NSString *loc = parameters[@"loc"];
        if ([loc isEqualToString: @"home"]) {
            
            [tabBarViewController setSelectedIndex: TOGOMarketControllerIndex];
            UINavigationController *navVC = [tabBarViewController viewControllers][TOGOMarketControllerIndex];
            [navVC popToRootViewControllerAnimated: NO];
            
        } else if ([loc isEqualToString: @"list_ads"]) {
            [self gotoIndex: TOGOMarketControllerIndex parameters: parameters withBlock:^(UINavigationController *navVC) {
                if (navVC.viewControllers && navVC.viewControllers.count > 0) {
                    OSMarketViewController *marketVC = navVC.viewControllers[0];
                    [marketVC goToOSListingViewControllerWithParameterString: parameters[@"opt_val"] params: nil animated: NO];
                } else {
                    self.listParameterString = parameters[@"opt_val"];
                }
            }];
            
        } else if ([loc isEqualToString: @"shop"]) {
            
            [self gotoIndex: TOGOBikeShopControllerIndex parameters: parameters withBlock:^(UINavigationController *navVC) {
//                if (navVC.viewControllers && navVC.viewControllers.count > 0) {
//                    OSBikeshopListViewController *bsVC = navVC.viewControllers[0];
//                    [bsVC goToBikeShopDetailWithSid: parameters[@"opt_val"] animated: NO];
//                } else {
                    self.sid = parameters[@"opt_val"];
//                }
            }];
            
        } else if ([loc isEqualToString: @"mp_ad"]) {
            [self gotoIndex: TOGOMarketControllerIndex parameters: parameters withBlock:^(UINavigationController *navVC) {
                if (navVC.viewControllers && navVC.viewControllers.count > 0) {
                    OSMarketViewController *marketVC = navVC.viewControllers[0];
                    [marketVC goToAdDetailWithAID: parameters[@"opt_val"] animated: NO];
                } else {
                    self.aid = parameters[@"opt_val"];
                }
            }];
        } else if ([loc isEqualToString: @"link"]) {
           if (parameters[@"opt_val"]) [[UIApplication sharedApplication] openURL: [NSURL URLWithString: parameters[@"opt_val"]]];
        }
         self.remoteNotiInfo = nil;
    }
}

#pragma mark - Interstitial & GADInterstitialDelegate
- (void)splashInterstitial
{
    UIImage *image;
    
    if (IS_IPHONE_5) {
        image = [UIImage imageNamed:@"Splash-568h"];
    } else {
        //TODO: replace with Default.png
        image = [UIImage imageNamed:@"Splash"];
    }
    
    _interstitial = [[DFPInterstitial alloc] initWithAdUnitID: DFP320x480_ID];
    DFPRequest *request = [DFPRequest request];
    request.testDevices = @[kGADSimulatorID];
    [_interstitial loadRequest: request];
    _interstitial.delegate = self;
    
//     = [[DFPInterstitial alloc] init];
//    splashInterstitial_.adUnitID = ;
//    splashInterstitial_.delegate = self;
//    [splashInterstitial_ loadAndDisplayRequest:[GADRequest request]
//                                   usingWindow: self.window
//                                  initialImage: image];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [_interstitial presentFromRootViewController:self.window.rootViewController];
}

- (void)interstitial:(DFPInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Interstitial error: %@", error.localizedDescription);
}

@end

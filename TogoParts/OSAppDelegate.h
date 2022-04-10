//
//  OSAppDelegate.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/17/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMobileAds/GoogleMobileAds.h"

extern NSString * const OS_USER_LOGGED_IN_NOTIFICATON;
extern NSString * const OS_USER_LOGGED_OUT_NOTIFICATON;
extern NSString * const OS_USER_SKIPPED_LOGGED_IN_NOTIFICION;

enum {
//    TOGOHomeControllerIndex,
    TOGOMarketControllerIndex,
    TOGOProfileControllerIndex,
    TOGOPostControllerIndex,
    TOGOBikeShopControllerIndex,
    TOGOShortListControllerIndex,
    TOGOSearchControllerIndex,
    TOGOBikeShopSearchIndex,
    TOGOAboutControllerIndex,
    TOGOLogoutControllerIndex,
};
typedef NSInteger TOGOTabBarControllerIndex;

#define TGPClientKey @"G101vptA69sVpvlr"

#define TOGO_UNIVERSAL_ERROR_ALERT \
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Cannot complete request" message: @"Check your internet connection and try later." delegate: Nil cancelButtonTitle: @"OK" otherButtonTitles: nil]; \
    [alert show];
#define VTTShowAlertView(title, aMessage, cancel) [[[UIAlertView alloc] initWithTitle: title message: aMessage delegate: nil cancelButtonTitle: cancel otherButtonTitles: nil] show];

#define DFP320x50_ID @"/4689451/iOSPro320x50"
#define DFP320x480_ID @"/4689451/iOSPro320x480"
#define DFP_HOME_TOP_ID @"/4689451/iOSPro-home-top320x50"

#define CONFIGURE_DFP_BANNER_AD -(void) configureDFPBannerAd: (DFPBannerView *) gAdView withId: (NSString *) adID { \
\
[gAdView resize: kGADAdSizeBanner]; \
gAdView.adUnitID = adID;   \
gAdView.rootViewController = self; \
GADRequest *request = [GADRequest request]; \
/*request.testDevices = @[ @"8964931890a3b979a3b17ae5e41ad15e", GAD_SIMULATOR_ID ];*/ \
[gAdView loadRequest: request]; \
}

#define SHOW_HIDE_AD_VIEW_WITH_SCROLL_VIEW(kSCROLLVIEW) -(void) showAdView { \
self.gAdView.hidden = NO;\
UIEdgeInsets inset = self.kSCROLLVIEW.contentInset; \
inset.bottom = self.gAdView.bounds.size.height; \
self.kSCROLLVIEW.contentInset = inset; \
}   \
\
-(void) hideAdView {     \
self.gAdView.hidden = YES;  \
UIEdgeInsets inset = self.kSCROLLVIEW.contentInset; \
inset.bottom = 0;   \
self.kSCROLLVIEW.contentInset = inset; \
}


@interface OSAppDelegate : UIResponder <UIApplicationDelegate, GADInterstitialDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) BOOL appActivatedInFirstLaunch;
#pragma mark - Push Notification
@property (nonatomic, strong) NSDictionary *remoteNotiInfo;
@property (nonatomic) BOOL openForNotification;

@property (nonatomic, strong) NSString *listParameterString;
@property (nonatomic, strong) NSString *sid;
@property (nonatomic, strong) NSString *aid;
@end

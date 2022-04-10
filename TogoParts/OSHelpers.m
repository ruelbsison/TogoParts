//
//  OSHelpers.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 3/13/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSHelpers.h"
#import "UIImage+animatedGIF.h"
#import "UIImage+VTTHelpers.h"
#import <CommonCrypto/CommonDigest.h>

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation OSHelpers
+(UIImageView *) padellingImageView {
    //    NSURL *urlZif = [[NSBundle mainBundle] URLForResource:@"dots64" withExtension:@"gif"];
    NSString *path=[[NSBundle mainBundle]pathForResource:@"padelling" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    UIImageView *padellingImageView = [[UIImageView alloc] initWithImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
    padellingImageView.frame = CGRectMake(0, 0, 50, 50);
    return padellingImageView;
}

+(UIToolbar *) doneToolBarWithTarget: (id) target selector: (SEL) selector {
    UIToolbar *doneToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    if (VTTOSLessThan7) {
        doneToolBar.tintColor = OSTogoTintColor;
        [doneToolBar setBackgroundImage: [UIImage imageWithColor: OSTogoTintColor cornerRadius: 0.0f] forToolbarPosition:UIBarPositionAny barMetrics: UIBarMetricsDefault];
    } else {
        doneToolBar.barTintColor = OSTogoTintColor;
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 44, 44)];
    [button setBackgroundImage: [UIImage imageWithColor: [UIColor clearColor] cornerRadius: 0.0f] forState: UIControlStateNormal];
    [button setTitle: @"Done" forState: UIControlStateNormal];
    [button addTarget: target action: selector forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: button];
    if (!VTTOSLessThan7) doneBarButtonItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem *stretch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
    doneToolBar.items = @[stretch, doneBarButtonItem];
    
    return doneToolBar;
}

+(UIBarButtonItem *) barButtonItemWithImage: (UIImage *) image target: (id) target selector: (SEL) selector {
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 44, 44)];
    [button setImage: image forState: UIControlStateNormal];
    [button addTarget: target action: selector forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView: button];
    return barButtonItem;
}

+(UIBarButtonItem *) searchBarButtonWithTarget: (id) target action: (SEL) action {
    UIButton *searchButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
    [searchButton addTarget: target action: action forControlEvents: UIControlEventTouchUpInside];
    [searchButton setImage: [UIImage imageNamed: @"top-search-button"] forState: UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView: searchButton];;
}

+(void) sendGATrackerWithName: (NSString *) name {
    //Google Analytics
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set: kGAIScreenName value: name];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

+(NSString*)sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+(MBProgressHUD *) showStandardHUDForView:(UIView *)view {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    return hud;
}
+(void) hideStandardHUD: (MBProgressHUD *) hud {
    [hud hide: YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}
@end

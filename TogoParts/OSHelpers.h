//
//  OSHelpers.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 3/13/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface OSHelpers : NSObject
+(UIImageView *) padellingImageView;
+(UIToolbar *) doneToolBarWithTarget: (id) target selector: (SEL) selector;
+(UIBarButtonItem *) barButtonItemWithImage: (UIImage *) image target: (id) target selector: (SEL) selector ;
+(UIBarButtonItem *) searchBarButtonWithTarget: (id) target action: (SEL) action;
+(void) sendGATrackerWithName: (NSString *) name;
+(NSString *) md5:(NSString *) input;
+(NSString*)sha256HashFor:(NSString*)input;

+(MBProgressHUD *) showStandardHUDForView:(UIView *)view;
+(void) hideStandardHUD: (MBProgressHUD *) hud;
@end

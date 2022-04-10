//
//  OSAdCell.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/15/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMobileAds/GoogleMobileAds.h"
//#import "DFPBannerView.h"

@interface OSAdCell : UITableViewCell <GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet DFPBannerView *bannerView;

@end

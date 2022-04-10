//
//  OSHomeHeaderView.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/27/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DFPBannerView.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

@interface OSHomeHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *titleBackground;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet DFPBannerView *bannerView;

@end

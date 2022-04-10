//
//  OSMarketCell.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSMarketCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAdsLabel;
@property (weak, nonatomic) IBOutlet UIButton *postAnAdsButton;

@end

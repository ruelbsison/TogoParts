//
//  OSBikeshopCell.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/10/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSBikeshopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *customTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UIView *openBackground;
@property (weak, nonatomic) IBOutlet UILabel *promosLabel;
@property (weak, nonatomic) IBOutlet UIView *promosBackground;
@property (weak, nonatomic) IBOutlet UIButton *promosButton;
@property (weak, nonatomic) IBOutlet UILabel *nItemLabel;
@property (weak, nonatomic) IBOutlet UIView *nItemBackground;
@property (weak, nonatomic) IBOutlet UIButton *nItemButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *distanceIcon;

@end

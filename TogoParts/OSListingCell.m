//
//  OSListingCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/20/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSListingCell.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+VTTHelpers.h"

@implementation OSListingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    
    [self setUp];
}

-(void) setUp {
    _nameLabel.font = [UIFont fontWithName: OSTogoFontName size: [_nameLabel.font pointSize]];
    _priceLabel.font = [UIFont fontWithName: OSTogoFontName size: [_priceLabel.font pointSize]];
    _firmLabel.font = [UIFont fontWithName: OSTogoFontName size: [_firmLabel.font pointSize]];
    _availableLabel.font = [UIFont fontWithName: OSTogoFontName size: [_availableLabel.font pointSize]];
    _dateAndPostLabel.font = [UIFont fontWithName: OSTogoFontName size: [_dateAndPostLabel.font pointSize]];
    _specialLabel.font = [UIFont fontWithName: OSTogoFontName size: [_specialLabel.font pointSize]];
    _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _nameLabel.textColor = OSBlackColor;
    _viewLabel.textColor = OSBlackColor;
    _commentLabel.textColor = OSBlackColor;
    _dateAndPostLabel.textColor = OSBlackColor;
    _priceLabel.textColor = OSTogoTintColor;
    _firmLabel.textColor = OSTogoTintColor;
    _availableLabel.textColor = OSGreenColor;
    
//    self.contentView.backgroundColor = OSTableViewBackground;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = OSTableViewBackground;
    self.backgroundColor = [UIColor clearColor];
}

-(void) configureCellWithData: (NSDictionary *) rowData {
    OSListingCell *cell = self;
    
    cell.nameLabel.text = rowData[@"title"];
    cell.priceLabel.text = rowData[@"price"];
    //Picture
    if (rowData[@"picture"] && ![rowData[@"picture"] isEqualToString: @""]) {
        [cell.mainPictureImageView setImageWithURL: [NSURL URLWithString: rowData[@"picture"]] placeholderImage: [UIImage imageNamed:@"image112x112"]];
    } else {
        [cell.mainPictureImageView setImage: [UIImage imageNamed: @"No_Image-112x112"]];
    }
    //Firm/Negotiable
    if (rowData[@"firm_neg"] || ![rowData[@"firm_neg"] isEqualToString: @""]) {
        cell.firmLabel.text = rowData[@"firm_neg"];
        cell.firmLabel.hidden = NO;
    } else {
        cell.firmLabel.hidden = YES;
    }
    cell.availableLabel.text = rowData[@"adstatus"];
    NSString *adStatus = rowData[@"adstatus"];
    NSArray *redStatus = @[@"Sold", @"Expired", @"Exchanged"];
    cell.availableLabel.textColor = OSGreenColor;
    for (NSString *status in redStatus) {
        if ([adStatus compare: status options: NSCaseInsensitiveSearch] == NSOrderedSame) {
             cell.availableLabel.textColor = OSRedColor;
        }
    }
    
    //New item and priority
    cell.viewLabel.text = rowData[@"ad_views"];
    cell.commentLabel.text = rowData[@"msg_sent"];
    NSString *listingLabel = rowData[@"listinglabel"];
    //        NSLog(@"listingLabel: %@", listingLabel);
    
    cell.nItem.hidden = YES;
    cell.priority.hidden = YES;
    if (listingLabel) {
        if ([listingLabel compare: @"NEW ITEM" options: NSCaseInsensitiveSearch] == NSOrderedSame) cell.nItem.hidden = NO;
        if ([listingLabel compare: @"PRIORITY" options: NSCaseInsensitiveSearch] == NSOrderedSame) cell.priority.hidden = NO;
    }
    
    //Date & Postedby
    NSString *datePost = [NSString stringWithFormat: @"%@/Posted by:%@", rowData[@"dateposted"], rowData[@"postedby"]];
    NSMutableAttributedString *datePostAttr = [[NSMutableAttributedString alloc] initWithString: datePost];
    [datePostAttr addAttribute:NSForegroundColorAttributeName value: OSBlackColor range: NSMakeRange(0, datePost.length)];
    [datePostAttr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range: [datePost rangeOfString: @"Posted by:"]];
    cell.dateAndPostLabel.attributedText = datePostAttr;
    
    //Merchant
    cell.logoImageView.hidden = YES;
    cell.companyName.hidden = YES;
    NSDictionary *merchantDetails = rowData[@"merchant_details"];
    if (merchantDetails && merchantDetails.count > 0) {
        if (merchantDetails[@"shop_logo"]) {
            cell.logoImageView.hidden = NO;
            [cell.logoImageView setImageWithURL: [NSURL URLWithString:merchantDetails[@"shop_logo"]]];
        } else if (merchantDetails[@"shop_name"]) {
            cell.logoImageView.hidden = YES;
            cell.companyName.text = merchantDetails[@"shop_name"];
        }
    }
    
    //Special (exp: clearance)
    NSDictionary *special = rowData[@"special"];
    // && [special isKindOfClass: [NSDictionary class]]
    if (special && special.count > 0) {
        cell.specialBackground.hidden = NO;
        cell.specialLabel.text = special[@"text"];
        if (special[@"bgcolor"]) cell.specialBackground.backgroundColor = [UIColor colorFromHexCode: special[@"bgcolor"]];
        if (special[@"textcolor"]) cell.specialLabel.textColor = [UIColor colorFromHexCode: special[@"textcolor"]];
    } else {
        cell.specialBackground.hidden = YES;
    }
}

#define kButtonWidth 138
#define kButtonHeight 68

/*
-(void) configureDrawerViewWithData: (NSDictionary *) rowData {
    if (!self.drawerView) {
        UIView *drawerView = [[UIView alloc] initWithFrame: self.frame];
        
        drawerView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        
        CGSize size = drawerView.frame.size;
        _leftButton = [[UIButton alloc] initWithFrame: CGRectMake((size.width - kButtonWidth * 2) / 3, (size.height - kButtonHeight)/2, kButtonWidth, kButtonHeight)];
        _rightButton  = [[UIButton alloc] initWithFrame: CGRectMake((size.width - kButtonWidth * 2) * 2 / 3 + kButtonWidth, (size.height - kButtonHeight)/2, kButtonWidth, kButtonHeight)];
        [drawerView addSubview: _rightButton];
        [drawerView addSubview: _leftButton];
    
        self.drawerView = drawerView;
    }
    
    _rightButton.hidden = YES;
    _leftButton.hidden = YES;
    [_rightButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [_leftButton removeTarget: nil action: NULL forControlEvents: UIControlEventAllEvents];
    
    NSString *listingLabel = rowData[@"listinglabel"];
    NSNumber *tcredCost = rowData[@"refresh_cost"];
    NSString *adStatus = rowData[@"adstatus"];
    
    if (listingLabel && ![listingLabel isEqualToString: @""]) {
        if (adStatus && [adStatus isEqualToString: @"Expired"]) {
            [self turnOnButton: _leftButton imageName: @"repost-ad-button" selector: @selector(repostClicked:)];
        } else {
            [self turnOnButton: _leftButton imageName: @"Takedownad-button" selector: @selector(takeDownClicked:)];
            
            if (adStatus && [adStatus isEqualToString: @"Sold"]) {
            } else {
                [_leftButton setImage: [UIImage imageNamed: @"mark-as-sold"] forState: UIControlStateNormal];
                _leftButton.hidden = NO;
                [self turnOnButton: _leftButton imageName: @"mark-as-sold" selector: @selector(markAsSoldClicked:)];
                
                if (rowData[@"TCreds"]) {
                    if ([rowData[@"TCreds"] integerValue] > [tcredCost integerValue]) {
                        [self turnOnButton: _rightButton imageName: @"refresh-ad-button" selector: @selector(refreshClicked:)];
                    }
                }
            }
        }
    } else {
        
        if (adStatus && [adStatus isEqualToString: @"Sold"]) {
        } else {
            [_leftButton setImage: [UIImage imageNamed: @"mark-as-sold"] forState: UIControlStateNormal];
            _leftButton.hidden = NO;
            [self turnOnButton: _leftButton imageName: @"mark-as-sold" selector: @selector(markAsSoldClicked:)];
            
            if (rowData[@"TCreds"]) {
                if ([rowData[@"TCreds"] integerValue] > [tcredCost integerValue]) {
                    [self turnOnButton: _rightButton imageName: @"refresh-ad-button" selector: @selector(refreshClicked:)];
                }
            }
        }
    }
}
*/

-(MGSwipeButton *) buttonWithTitle: (NSString *) title action: (SEL) selector color: (UIColor *) color{
    MGSwipeButton *btn = [MGSwipeButton buttonWithTitle: title backgroundColor: color];
    [btn addTarget: self action: selector forControlEvents: UIControlEventTouchUpInside];
    return btn;
}

-(void) configureDrawerViewWithData: (NSDictionary *) rowData {
    NSString *listingLabel = rowData[@"listinglabel"];
    NSLog(@"listingLabel: %@", listingLabel);
    NSNumber *tcredCost = rowData[@"refresh_cost"];
    NSString *adStatus = rowData[@"adstatus"];
    NSString *adType = rowData[@"adtype"];
    
    NSMutableArray *buttons = [NSMutableArray new];
    
    if ([listingLabel isEqualToString: @""] || [listingLabel isEqualToString: @"PRIORITY"]) {
        //Normal and Priority
        NSString *markAsSoldTitle;
        SEL markSelector;
        if (adStatus && [adStatus isEqualToString: @"Available"] && [adType isEqualToString: @"FOR SALE"]) {
            markAsSoldTitle = @"Mark As Sold";
            markSelector = @selector(markAsSoldClicked:);
        } else if (adStatus && [adStatus isEqualToString: @"Available"] && [adType isEqualToString: @"FREE!"]) {
            markAsSoldTitle = @"Mark As Given";
            markSelector = @selector(markAsGiven:);
        } else if ([adStatus isEqualToString: @"Looking"]) {
            markAsSoldTitle = @"Mark As Found";
            markSelector = @selector(markAsFound:);
        } else if ([adStatus isEqualToString: @"For Exchange"]) {
            markAsSoldTitle = @"Mark As Exchanged";
            markSelector = @selector(markAsExchanged:);
        }
        
        if (markAsSoldTitle) {
            MGSwipeButton *markAsSold = [self buttonWithTitle: markAsSoldTitle action: markSelector color: [UIColor redColor]];
            [buttons addObject: markAsSold];
            [buttons addObject: [self buttonWithTitle: @"Refresh" action: @selector(refreshClicked:) color: [UIColor greenColor]]];
        }
    } else if ([listingLabel isEqualToString: @"NEW ITEM"]) {
        //New Item
        if (adStatus && [adStatus isEqualToString: @"Expired"]) {
            MGSwipeButton *repostBtn = [self buttonWithTitle: @"Repost" action: @selector(repostClicked:) color: [UIColor greenColor]];
            [buttons addObject: repostBtn];
        } else if (adStatus && [adStatus isEqualToString: @"Sold"]) {
            [buttons addObject: [self buttonWithTitle: @"Take down" action: @selector(takeDownClicked:) color: [UIColor lightGrayColor]]];
//            [buttons addObject: [self buttonWithTitle: @"Refresh" action: @selector(refreshClicked:) color: [UIColor greenColor]]];
        } else if (adStatus && [adStatus isEqualToString: @"Available"] && adType && [adType isEqualToString: @"FOR SALE"]) {
            [buttons addObject: [self buttonWithTitle: @"Take down" action: @selector(takeDownClicked:) color: [UIColor lightGrayColor]]];
            [buttons addObject: [self buttonWithTitle: @"Mark As Sold" action: @selector(markAsSoldClicked:) color: [UIColor redColor]]];
            [buttons addObject: [self buttonWithTitle: @"Refresh" action: @selector(refreshClicked:) color: [UIColor greenColor]]];
        }
    }

    self.rightButtons = buttons;
//    self.rightSwipeSettings.transition = MGSwipeTransitionDrag;
}

-(void) turnOnButton: (UIButton *) button imageName: (NSString *) imageName selector: (SEL) selector {
    [button setImage: [UIImage imageNamed: imageName] forState: UIControlStateNormal];
    [button addTarget: self action: selector forControlEvents: UIControlEventTouchUpInside];
    button.hidden = NO;
}

-(void) markAsSoldClicked: (id) sender {
    if ([_listingDelegate respondsToSelector: @selector(listingCell:markAsSoldClicked:action:)]) {
        [_listingDelegate listingCell: self markAsSoldClicked: sender action: @"sold"];
    }
}
-(void) markAsExchanged: (id) sender {
   [_listingDelegate listingCell: self markAsSoldClicked: sender action: @"exchanged"];
}
-(void) markAsFound: (id) sender {
    [_listingDelegate listingCell: self markAsSoldClicked: sender action: @"found"];
}
-(void) markAsGiven: (id) sender {
    [_listingDelegate listingCell: self markAsSoldClicked: sender action: @"given"];
}

-(void) refreshClicked: (id) sender {
    if ([_listingDelegate respondsToSelector: @selector(listingCell:refreshClicked:)]) {
        [_listingDelegate listingCell: self refreshClicked: sender];
    }
}
-(void) repostClicked: (id) sender {
    if ([_listingDelegate respondsToSelector: @selector(listingCell:repostClicked:)]) {
        [_listingDelegate listingCell: self repostClicked: sender];
    }
}
-(void) takeDownClicked: (id) sender {
    if ([_listingDelegate respondsToSelector: @selector(listingCell:takeDownClicked:)]) {
        [_listingDelegate listingCell: self takeDownClicked: sender];
    }
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//    if (selected) {
////        self.contentView.backgroundColor = [UIColor whiteColor];
//        self.contentView.backgroundColor = [UIColor clearColor];
//    } else {
////        self.contentView.backgroundColor = OSTableViewBackground;
//        self.contentView.backgroundColor = [UIColor clearColor];
//    }
//}

//-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
////    [super setHighlighted: highlighted animated: animated];
//    if (highlighted) {
//        self.contentView.backgroundColor = [UIColor whiteColor];
//        self.contentView.backgroundColor = [UIColor clearColor];
//    } else {
////        self.contentView.backgroundColor = OSTableViewBackground;
//        self.contentView.backgroundColor = [UIColor clearColor];
//    }
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self applyEditingModeBackgroundViewPositionCorrections];
}
/**
 When using a backgroundView or selectedBackgroundView on a custom UITableViewCell
 subclass, iOS7 currently has a bug where tapping the Delete access control reveals
 the Delete button, only to have the background cover it up again! Radar 14940393 has
 been filed for this. Until solved, use this method in your Table Cell's layoutSubviews
 to correct the behavior.
 
 This solution courtesy of cyphers72 on the Apple Developer Forum, who posted the
 working solution here: https://devforums.apple.com/message/873484#873484
 */

- (void)applyEditingModeBackgroundViewPositionCorrections {
    if (!self.editing) { return; } // BAIL. This fix is not needed.
    
    // Assertion: we are in editing mode.
    
    // Do we have a regular background view?
    if (self.contentView) {
        // YES: So adjust the frame for that:
        CGRect contentFrame = self.contentView.frame;
        contentFrame.origin.x = 0;
        contentFrame.size.width = self.frame.size.width;
        self.contentView.frame = contentFrame;
    }
    
    // Do we have a selected background view?
    if (self.selectedBackgroundView) {
        // YES: So adjust the frame for that:
        CGRect selectedBackgroundViewFrame = self.selectedBackgroundView.frame;
        selectedBackgroundViewFrame.origin.x = 0;
        self.selectedBackgroundView.frame = selectedBackgroundViewFrame;
    }
}

@end

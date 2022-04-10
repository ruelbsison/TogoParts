//
//  OSListingCell.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/20/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHPanningTableViewCell.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

@class OSListingCell;
@protocol OSListingCellDelegate <NSObject>

-(void) listingCell: (OSListingCell *) cell markAsSoldClicked: (id) sender action: (NSString *) action;
-(void) listingCell: (OSListingCell *) cell refreshClicked: (id) sender;
-(void) listingCell: (OSListingCell *) cell repostClicked: (id) sender;
-(void) listingCell: (OSListingCell *) cell takeDownClicked: (id) sender;

@end

@interface OSListingCell : MGSwipeTableCell
@property (nonatomic, weak) id <OSListingCellDelegate> listingDelegate;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *specialLabel;
@property (weak, nonatomic) IBOutlet UIView *specialBackground;

@property (weak, nonatomic) IBOutlet UIImageView *priority;
@property (weak, nonatomic) IBOutlet UIImageView *nItem;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateAndPostLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyName;

@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *centerButton;

-(void) configureCellWithData: (NSDictionary *) rowData;
-(void) configureDrawerViewWithData: (NSDictionary *) rowData;
@end

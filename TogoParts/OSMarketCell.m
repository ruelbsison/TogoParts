//
//  OSMarketCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSMarketCell.h"
#import "OSColorsPalette.h"

@implementation OSMarketCell
-(id) init {
    self = [super init];
    if (self) {
//        [self setUp];
    }
    return self;
}
-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
//        [self setUp];
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        [self setUp];
    }
    return self;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}
-(void) setUp {
    self.titleLabel.font = [UIFont fontWithName: OSTogoFontName size: 19];
//    self.descriptionLabel.font = [UIFont fontWithName: OSTogoFontName size: 11];
    self.totalAdsLabel.font = [UIFont fontWithName: OSTogoFontName size: 22];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  OSMarketHeaderCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/21/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSMarketHeaderCell.h"

@implementation OSMarketHeaderCell

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
    OSChangeTogoFontForLabel(self.titleLabel);
    self.titleLabel.minimumScaleFactor = 0.5f;
    if (VTTOSLessThan7) {
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

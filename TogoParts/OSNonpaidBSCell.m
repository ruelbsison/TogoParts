//
//  OSNonpaidBSCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/10/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSNonpaidBSCell.h"

@implementation OSNonpaidBSCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    OSChangeTogoFontForLabel(_customTitleLabel);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

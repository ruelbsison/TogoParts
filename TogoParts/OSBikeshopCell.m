//
//  OSBikeshopCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/10/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSBikeshopCell.h"

@implementation OSBikeshopCell

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
    [self setUp];
}

-(void) setUp {
    OSChangeTogoFontForLabel(_customTitleLabel);
    OSChangeTogoFontForLabel(_openLabel);
    OSChangeTogoFontForLabel(_nItemLabel);
    OSChangeTogoFontForLabel(_promosLabel);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

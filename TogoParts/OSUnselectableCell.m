//
//  OSUnselectableCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/6/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSUnselectableCell.h"

@implementation OSUnselectableCell

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //Do nothing
}

@end

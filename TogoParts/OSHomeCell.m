//
//  OSHomeCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/27/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSHomeCell.h"

@implementation OSHomeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib {
    OSChangeTogoFontForLabel(_titleLabel);
    OSChangeTogoFontForLabel(_priceLabel);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

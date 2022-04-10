//
//  OSLabel.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/6/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSLabel.h"

@implementation OSLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    OSChangeTogoFontForLabel(self);
}
@end

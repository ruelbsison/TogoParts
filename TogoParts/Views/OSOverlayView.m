//
//  OSOverlayView.m
//  TogoParts
//
//  Created by Ruel Sison on 9/12/16.
//  Copyright © 2016 Oneshift. All rights reserved.
//

#import "OSOverlayView.h"

@implementation OSOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    }
    return self;
}

-(void) awakeFromNib {
    [super awakeFromNib];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

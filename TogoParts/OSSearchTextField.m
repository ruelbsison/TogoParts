//
//  OSSearchTextField.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSSearchTextField.h"
@import QuartzCore;

@implementation OSSearchTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

-(void) setUp {
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 1.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOpacity = 0.0;
    self.layer.shadowRadius = 0.0f;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 5 , 5 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 5 , 5 );
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

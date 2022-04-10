//
//  FRInputLabel.m
//  Frittie
//
//  Created by Thanh Tung Vu on 11/23/13.
//  Copyright (c) 2013 FR. All rights reserved.
//

#import "FRInputLabel.h"

@implementation FRInputLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)isUserInteractionEnabled
{
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL) resignFirstResponder {
    BOOL ret = [super resignFirstResponder];
    if ([self.delegate respondsToSelector: @selector(inputLabelDidResignFirstResponder:)]) {
        [self.delegate inputLabelDidResignFirstResponder: self];
    }
    return ret;
}

# pragma mark - UIResponder overrides
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector: @selector(inputLabelShouldBecomeFirstResponder:)]) {
        if (![self.delegate inputLabelShouldBecomeFirstResponder: self]) {
            return;
        }
    }
    
    [self becomeFirstResponder];
    if ([self.delegate respondsToSelector: @selector(inputLabelDidBecomeFirstResponder:)]) {
        [self.delegate inputLabelDidBecomeFirstResponder: self];
    }
}

@end
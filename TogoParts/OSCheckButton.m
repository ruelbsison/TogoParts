//
//  OSCheckButton.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/12/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSCheckButton.h"

@implementation OSCheckButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

-(id) initWithCheckedImage: (UIImage *) checkedImage uncheckedImage: (UIImage *) uncheckedImage {
    CGSize size = checkedImage.size;
    self = [self initWithFrame: CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _checkedImage = checkedImage;
        _uncheckedImage = uncheckedImage;
        self.checked = NO;
    }
    return self;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

-(void) setup {
   [[self imageView] setContentMode: UIViewContentModeScaleAspectFit];
}

-(void) setUseBackground:(BOOL)useBackground {
    _useBackground = useBackground;
    if (_useBackground) {
        [self setImage: nil forState: UIControlStateNormal];
    } else {
        [self setBackgroundImage: nil forState: UIControlStateNormal];
    }
}

-(void) setChecked:(BOOL)checked {
    _checked = checked;
    if (_useBackground) {
        if (checked) {
            [self setBackgroundImage: _checkedImage forState: UIControlStateNormal];
        } else {
            [self setBackgroundImage: _uncheckedImage forState: UIControlStateNormal];
        }
    } else {
        if (checked) {
            [self setImage: _checkedImage forState: UIControlStateNormal];
        } else {
            [self setImage: _uncheckedImage forState: UIControlStateNormal];
        }
    }
}

-(void) setCheckedImage:(UIImage *)checkedImage {
    _checkedImage = checkedImage;
    self.checked = _checked;
}

-(void) setUncheckedImage:(UIImage *)uncheckedImage {
    _uncheckedImage = uncheckedImage;
    self.checked = _checked;
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

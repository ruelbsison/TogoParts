//
//  UITextView+VTTHelpers.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 3/12/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "UITextView+VTTHelpers.h"

@implementation UITextView (VTTHelpers)

+ (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

+ (CGFloat)textViewHeightForText:(NSString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, width,  50)];
    [textView setText: text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    if (VTTOSLessThan7) {
        return size.height;
    } else {
        return size.height;
    }
    
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString: text];
//    return [UITextView textViewHeightForAttributedText: attrString andWidth: width];
}

+(CGFloat) textViewHeightForTextView: (UITextView *) textView{
    UITextView *nTextView = [[UITextView alloc] init];
    nTextView.font = textView.font;
    nTextView.text = textView.text;
    CGSize size = [nTextView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)];
        return size.height;
}
@end

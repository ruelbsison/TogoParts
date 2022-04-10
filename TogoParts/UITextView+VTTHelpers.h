//
//  UITextView+VTTHelpers.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 3/12/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (VTTHelpers)
+ (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width;
+ (CGFloat)textViewHeightForText:(NSString *)text andWidth:(CGFloat)width;
+(CGFloat) textViewHeightForTextView: (UITextView *) textView;
@end

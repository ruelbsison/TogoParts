//
//  OSPlaceHolderTextView.h
//  TogoParts
//
//  Created by Ruel Sison on 9/17/16.
//  Copyright © 2016 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface OSPlaceHolderTextView : UITextView

/**
 The string that is displayed when there is no other text in the text view. This property reads and writes the
 attributed variant.
 The default value is `nil`.
 */
@property (nonatomic, retain) IBInspectable NSString *placeholder;

@property (nonatomic, retain) IBInspectable UIColor *placeholderColor;

/**
 The attributed string that is displayed when there is no other text in the text view.
 The default value is `nil`.
 */
//@property (nonatomic, strong) NSAttributedString *attributedPlaceholder;

/**
 Returns the drawing rectangle for the text views’s placeholder text.
 @param bounds The bounding rectangle of the receiver.
 @return The computed drawing rectangle for the placeholder text.
 */
//- (CGRect)placeholderRectForBounds:(CGRect)bounds;

-(void)textChanged:(NSNotification*)notification;
@end

//
//  FRAbstractPickerField.m
//  Frittie
//
//  Created by Thanh Tung Vu on 12/19/13.
//  Copyright (c) 2013 FR. All rights reserved.
//

#import "FRAbstractInputField.h"
#import <QuartzCore/QuartzCore.h>

@implementation FRAbstractInputField

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self abstractSetUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self abstractSetUp];
    }
    return self;
}


-(void) abstractSetUp {
    //Model setup
    _isPlaceholderShowing = YES;
    _placeHolderFont = [UIFont systemFontOfSize: 14.0f];
    _placeHolderColor = [UIColor colorWithWhite: 0.0f alpha:0.2f];
    _textFont = [UIFont systemFontOfSize: 14.0f];
    _textColor = [UIColor darkGrayColor];
    _hightlightText = @"Editing...";
    _hightlightColor = [UIColor colorWithWhite: 0.0f alpha:0.1f];
    _highlightInterval = 0.7f;
    _isEditing = NO;
    _valueChanged = NO;
    
    
    //label
    _label = [[FRInputLabel alloc] initWithFrame: self.bounds];
    _label.delegate = self;
    _label.textColor = _textColor;
    
    [self configureToolBar];
    _label.inputAccessoryView = _toolBar;
    
    [self addSubview: self.label];
}

-(void) configureToolBar {
    //Tool bar
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _toolBar = [[UIView alloc] initWithFrame: CGRectMake(0, 0, screenWidth, 44)];

    if (VTTOSLessThan7) {
        _toolBar.backgroundColor = [UIColor lightGrayColor];
    } else {
        _toolBar.backgroundColor = self.tintColor;
    }
    
        
    //Done Button
    _doneButton = [[UIButton alloc] initWithFrame: CGRectMake(_toolBar.frame.size.width - 88, 0, 88, 44)];
    [_doneButton setTitle: @"Done" forState: UIControlStateNormal];
    [_doneButton addTarget: self action: @selector(done:) forControlEvents: UIControlEventTouchUpInside];
    [_toolBar addSubview: _doneButton];
    
    //Cancel Button
    _cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 88, 44)];
    [_cancelButton setTitle: @"Cancel" forState: UIControlStateNormal];
    [_cancelButton addTarget: self action: @selector(cancel:) forControlEvents: UIControlEventTouchUpInside];
    [_toolBar addSubview: _cancelButton];
}

#pragma mark - Accessor Methods
-(void) setPlaceHolder:(NSString *)placeHolder {
    if ((!_text || [_text isEqualToString: @""]) && [placeHolder isEqualToString: @""] == FALSE && placeHolder) {
        _label.font = _placeHolderFont;
        _label.textColor = _placeHolderColor;
        _label.text = placeHolder;
    }
    _placeHolder = placeHolder;
}

-(void) setText:(NSString *)text {
    if (text && ![text isEqualToString: @""]) {
        _label.font = _textFont;
        _label.textColor = _textColor;
        _label.text = text;
        _text = text;
        _isPlaceholderShowing = NO;
    } else if ((!_text || [text isEqualToString: @""]) && _placeHolder) {
        _text = text;
        [self setPlaceHolder: _placeHolder];
        _isPlaceholderShowing = YES;
    } else {
        _text = text;
        _label.text = text;
    }
}

-(void) setPlaceHolderColor:(UIColor *)placeHolderColor {
    if (placeHolderColor && _isPlaceholderShowing) {
        _placeHolderColor = placeHolderColor;
        [self setPlaceHolder: _placeHolder];
    }
}

-(void) setTextColor:(UIColor *)textColor {
    if (textColor && !_isPlaceholderShowing) {
        _textColor = textColor;
        [self setText: _text];
    }
}

#pragma mark - Helper methods
-(void) enterHighlightState {
    _isEditing = YES;
    if (!self.text) {
        [self.label setText: _hightlightText];
    } else {
        //TODO: Fucking annoying hack
        [self.label setText: [NSString stringWithFormat: @"%@ ", _text]];
        [self.label setText: _text];
    }
    [self.label setTextColor: _textColor];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"foregroundColor"];
    
    [anim setFromValue: (id) [_textColor CGColor]];
    [anim setToValue: (id) [_hightlightColor CGColor]];
    anim.fillMode = kCAFillModeBoth;
    anim.duration = _highlightInterval;
    anim.removedOnCompletion = NO;
    anim.repeatCount = MAXFLOAT;
    anim.autoreverses = YES;
    [self.label.textLayer addAnimation:anim forKey: nil];
}

-(void) exitHighlightState {
//    CGColorRef initialColor = self.label.textLayer.foregroundColor;
    [self.label.textLayer removeAllAnimations];
    /*
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"foregroundColor"];
    [anim setFromValue: (__bridge id) (initialColor)];
    [anim setToValue: (id) [_textColor CGColor]];
    anim.fillMode = kCAFillModeRemoved;
    anim.duration = 5;
    anim.removedOnCompletion = YES;
    [self.label.textLayer addAnimation:anim forKey: nil];
    */
    if (_isPlaceholderShowing && _placeHolder) {
        [self setPlaceHolder: _placeHolder];
    } else if (_text) {
        [self setText: _text];
    }
    _isEditing = NO;
}

#pragma mark - Target Action
-(void) done: (id) sender {
    if ([self.delegate respondsToSelector: @selector(inputFieldShouldResignFirstResponder:isCanceled:)]) {
        if (![self.delegate inputFieldShouldResignFirstResponder: self isCanceled: NO]) {
            return;
        }
    }
    
    //Below method is optionally implemented by subclass
    [self doBeforeDone];
    
    [self exitHighlightState];
    
    if ([self.delegate respondsToSelector: @selector(inputFieldDidHitDoneButton:)]) {
        [self.delegate inputFieldDidHitDoneButton: self];
    }
    if (self.doneBlock)
        self.doneBlock(self);
    
    [self.label resignFirstResponder];
}

-(void) cancel: (id) sender {
    if ([self.delegate respondsToSelector: @selector(inputFieldShouldResignFirstResponder:isCanceled:)]) {
        if (![self.delegate inputFieldShouldResignFirstResponder: self isCanceled: YES]) {
            return;
        }
    }
    
    //Below method is optionally implemented by subclass
    [self doBeforeCancel];
    
    [self exitHighlightState];
    
    if ([self.delegate respondsToSelector: @selector(inputFieldDidHitDoneButton:)]) {
        [self.delegate inputFieldDidHitCancelButton: self];
    }
    if (self.cancelBlock)
        self.cancelBlock(self);
    
    [self.label resignFirstResponder];
}

#pragma mark - FRInputLabelDelegate
-(void) inputLabelDidBecomeFirstResponder:(FRInputLabel *)inputLabel {
    if ([self.delegate respondsToSelector: @selector(inputFieldDidBecomeFirstResponder:)]) {
        [self.delegate inputFieldDidBecomeFirstResponder: self];
    }
    [self enterHighlightState];
}
-(BOOL) inputLabelShouldBecomeFirstResponder:(FRInputLabel *)inputLabel {
    if ([self.delegate respondsToSelector: @selector(inputFieldShouldBecomeFirstResponder:)]) {
        return [self.delegate inputFieldShouldBecomeFirstResponder: self];
    }
    return YES;
}
-(void) inputLabelDidResignFirstResponder:(FRInputLabel *)inputLabel {
    
    [self exitHighlightState];
    
    if ([self.delegate respondsToSelector: @selector(inputFieldDidResignFirstResponder:)]) {
        [self.delegate inputFieldDidResignFirstResponder: self];
    }
}
#pragma mark - To be subclassed
-(void) doBeforeDone {
    
}
-(void) doBeforeCancel {
    
}
@end

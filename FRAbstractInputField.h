//
//  FRAbstractPickerField.h
//  Frittie
//
//  Created by Thanh Tung Vu on 12/19/13.
//  Copyright (c) 2013 FR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRInputLabel.h"

@protocol FRInputFieldDelegate <NSObject>

@optional
-(void) inputFieldDidHitDoneButton: (id) pickerField;
-(void) inputFieldDidHitCancelButton: (id) pickerField;
-(BOOL) inputFieldShouldResignFirstResponder: (id) pickerField isCanceled: (BOOL) canceled;
-(BOOL) inputFieldShouldBecomeFirstResponder: (id) pickerField;
-(void) inputFieldDidBecomeFirstResponder: (id) pickerField;
-(void) inputFieldDidResignFirstResponder: (id) pickerField;
@end


@interface FRAbstractInputField : UIControl <UITextFieldDelegate, FRInputLabelDelegate>

//UIs
@property (nonatomic, strong, readwrite) FRInputLabel *label;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong, readonly) UIButton *doneButton;
@property (nonatomic, strong) UIButton *cancelButton;

//Color and text
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) NSString *placeHolder;
@property (nonatomic, strong) UIColor *placeHolderColor;
@property (nonatomic, strong) UIFont *placeHolderFont;
@property (nonatomic, strong) NSString *hightlightText;
@property (nonatomic, strong) UIColor *hightlightColor;
@property (nonatomic) CGFloat highlightInterval;

//States
@property (nonatomic, readonly) BOOL isEditing;
@property (nonatomic) BOOL valueChanged;
@property (nonatomic) BOOL isPlaceholderShowing;

//Delegate methods
@property (nonatomic, weak) id <FRInputFieldDelegate> delegate;
@property (nonatomic, strong) void (^doneBlock) (id inputField);
@property (nonatomic, strong) void (^cancelBlock) (id inputField);
@property (nonatomic, strong) void (^changeBlock) (id inputField);


#pragma mark - Methods
-(void) configureToolBar;
-(void) enterHighlightState;
-(void) exitHighlightState;
-(void) done: (id) sender;
-(void) cancel: (id) sender;

//To be subclassed
-(void) doBeforeDone;
-(void) doBeforeCancel;
@end

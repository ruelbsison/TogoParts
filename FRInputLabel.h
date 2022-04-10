//
//  FRInputLabel.h
//  Frittie
//
//  Created by Thanh Tung Vu on 11/23/13.
//  Copyright (c) 2013 FR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUIAnimatableLabel.h"

@class FRInputLabel;

@protocol FRInputLabelDelegate <NSObject>

-(void) inputLabelDidBecomeFirstResponder: (FRInputLabel *) inputLabel;
-(void) inputLabelDidResignFirstResponder: (FRInputLabel *) inputLabel;
-(BOOL) inputLabelShouldBecomeFirstResponder: (FRInputLabel *) inputLabel;

@end

@interface FRInputLabel : AUIAnimatableLabel

@property (strong, nonatomic, readwrite) UIView* inputView;
@property (strong, nonatomic, readwrite) UIView* inputAccessoryView;
@property (nonatomic, weak) id <FRInputLabelDelegate> delegate;
@end

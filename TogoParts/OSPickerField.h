//
//  OSPickerField.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRAbstractInputField.h"

@interface OSPickerField : FRAbstractInputField
@property (nonatomic, strong, readonly) UIPickerView *pickerView;

/**
 Array of string
 */
@property (nonatomic, strong) NSArray *componentsOfStrings;

/**
 Only apply if componentsOfStrings not nil
 Default is YES
 */
@property (nonatomic) BOOL autoUpdateText;

@end

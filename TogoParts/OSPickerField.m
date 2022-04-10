//
//  OSPickerField.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSPickerField.h"
@interface OSPickerField () <UIPickerViewDelegate, UIPickerViewDataSource>
@end

@implementation OSPickerField
-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

-(void) setUp {
    //Model and settings
    self.autoUpdateText = YES;
    
    //UI setup
    [self configurePickerView];
    
    //label
    self.label.inputView = _pickerView;
    
    UIImage *arrowImage = [UIImage imageNamed: @"dropdown-arrow-withbg"];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage: arrowImage];
    arrowImageView.contentMode = UIViewContentModeCenter;
    arrowImageView.frame = CGRectMake(self.frame.size.width - arrowImage.size.width, 0, arrowImage.size.width, self.frame.size.height);
    arrowImageView.userInteractionEnabled = YES;
    [arrowImageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(arrowTapped:)]];
    
    self.label.frame = CGRectMake(5, 5, self.frame.size.width - 10 - arrowImageView.frame.size.width,  self.frame.size.height - 10);
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.minimumScaleFactor = 0.5f;
    
    self.layer.borderColor = [UIColor colorWithWhite: 0.3f alpha: 0.5f].CGColor;
    self.layer.borderWidth = 0.5f;
    self.clipsToBounds = YES;
    [self addSubview: arrowImageView];
    [self addSubview: self.label];
    
    self.toolBar.backgroundColor = OSTogoTintColor;
    self.cancelButton.hidden = YES;
}

-(void) configurePickerView {
    //Date picker
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.frame = CGRectMake(0, 0, _pickerView.frame.size.width, _pickerView.frame.size.height);
    _pickerView.delegate = self;
}

#pragma mark - Accessor
-(void) setComponentsOfStrings:(NSArray *)componentsOfStrings {
    if (_componentsOfStrings == componentsOfStrings) return;
    if (componentsOfStrings.count <= 0) return;
    _componentsOfStrings = componentsOfStrings;
    [self.pickerView reloadAllComponents];
}

#pragma mark - Actions
-(void) arrowTapped: (UITapGestureRecognizer *) tap {
    [self.label becomeFirstResponder];
}

#pragma mark - UIPickerViewDatasource
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.componentsOfStrings count];
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.componentsOfStrings[component] count];
}
#pragma mark - UIPickerViewDelegate
-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.componentsOfStrings[component][row];
}
-(UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label;
    if (!view) {
       label  = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, pickerView.frame.size.width - 20, 66)];
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        if (VTTOSLessThan7) {
            label.font = [UIFont fontWithName: OSTogoFontName size: 17];
        } else {
            label.adjustsFontSizeToFitWidth = YES;
            label.font = [UIFont fontWithName: OSTogoFontName size: 19];
            label.minimumScaleFactor = 0.75;
        }
    } else {
        label = (UILabel *) view;
    }
    
    label.text = self.componentsOfStrings[component][row];
    return label;
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.componentsOfStrings && self.autoUpdateText) {
        NSInteger selected = [self.pickerView selectedRowInComponent: 0];
        NSString *selectedString = self.componentsOfStrings[0][selected];
        self.text = selectedString;
    }
    
    if (self.changeBlock) {
        self.changeBlock(self);
    }
}
@end
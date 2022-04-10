//
//  OSMoreDetailController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/5/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSMoreDetailController.h"
#import "OSPickerField.h"
#import "OSSearchTextField.h"

@interface OSMoreDetailController () <UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet OSPickerField *sizePickerField;
@property (weak, nonatomic) IBOutlet OSPickerField *colorPicker;
@property (weak, nonatomic) IBOutlet OSSearchTextField *weightField;
@property (weak, nonatomic) IBOutlet OSPickerField *conditionPicker;
@property (weak, nonatomic) IBOutlet OSSearchTextField *warrantyField;
@property (weak, nonatomic) IBOutlet UITextView *otherLinkTextView;

@end

@implementation OSMoreDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _otherLinkTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0f].CGColor;
    _otherLinkTextView.layer.borderWidth = 1.0f;
    
    _weightField.delegate = self;
    _warrantyField.delegate = self;

    //    top-back-button
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"top-back-button"]  target: self selector: @selector(backButtonClicked:)];
    self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"apply-icon"]  target: self selector: @selector(applyActionClicked:)];
    

    if (!self.data) {
        self.data = [NSMutableDictionary new];
    } else {
        //Update fields;
        if (_data[@"weight"]) _weightField.text = [NSString stringWithFormat: @"%@", _data[@"weight"]];
        if (_data[@"warranty"]) _warrantyField.text = [NSString stringWithFormat: @"%@", _data[@"warranty"]];
        if (_data[@"picturelink"]) _otherLinkTextView.text = _data[@"picturelink"];
    }
    [self configureSizePickerField];
    [self configureColorPicker];
    [self configureConditionPicker];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [OSHelpers sendGATrackerWithName: @"Marketplace Post or Edit Ad More Ad Details"];
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) configureSizePickerField {
    //    fs = Free Size		xxs = Extra Extra Small
    //    xs = Extra Small	s = Small
    //    ms = Medium Small	m =Medium
    //    ml = Medium Large	l = Large
    //    xl = Extra Large		xxl = Extra Extra Large
    //    na = N-A
    
    NSArray *sizeKeys = @[@"", @"fs", @"xxs", @"xs", @"s", @"ms", @"m", @"ml", @"l", @"xl", @"xxl", @"na"];
    NSArray *sizeValues = @[@"", @"Free Size", @"Extra Extra Small", @"Extra Small", @"Small", @"Medium Small", @"Medium", @"Medium Large", @"Large", @"Extra Large", @"Extra Extra Large", @"N-A"];
    
    __weak OSMoreDetailController *weakSelf = self;
    if (_data[@"size"]) {
        NSInteger index = [sizeKeys indexOfObject: _data[@"size"]];
        if (index != NSNotFound)
            self.sizePickerField.text = sizeValues[index];
    }
    self.sizePickerField.componentsOfStrings = @[sizeValues];
    self.sizePickerField.doneBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        if (value) {
            NSInteger index = [sizeValues indexOfObject: value];
            weakSelf.data[@"size"] = sizeKeys[index];
        } else {
            //default
//            [picker setText: sizeValues[0]];
//            weakSelf.data[@"size"] = sizeKeys[0];
        }
    };
}

-(void) configureColorPicker {
    NSArray *colors = @[@"", @"Beige", @"Black", @"Blue", @"Brown", @"Gold", @"Green", @"Grey", @"Orange", @"Purple", @"Red", @"Silver", @"White", @"Yellow", @"MultiColour"];
    
    __weak OSMoreDetailController *weakSelf = self;
    if (_data[@"colour"]) {
        NSInteger index = [colors indexOfObject: _data[@"colour"]];
        if (index != NSNotFound)
            self.colorPicker.text = colors[index];
    }
    self.colorPicker.componentsOfStrings = @[colors];
    self.colorPicker.changeBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        weakSelf.data[@"colour"] = value;
    };
}

-(void) configureConditionPicker {
    NSArray *conditionKeys = @[@0, @10, @9, @8, @7, @6, @5, @4, @3, @2, @1];
    NSArray *conditionValues = @[@"", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", @"1"];
    
    __weak OSMoreDetailController *weakSelf = self;
    if (_data[@"condition"]) {
        NSInteger index = [conditionKeys indexOfObject: _data[@"condition"]];
        if (index != NSNotFound)
            self.conditionPicker.text = conditionValues[index];
    }
    self.conditionPicker.componentsOfStrings = @[conditionValues];
    self.conditionPicker.changeBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        NSInteger index = [conditionValues indexOfObject: value];
        weakSelf.data[@"condition"] = conditionKeys[index];
    };
}


#pragma mark - Actions
- (IBAction)applyActionClicked:(id)sender {
    UITextField *textField = _weightField;
    if (textField.text && ![textField.text isEqualToString: @""]) {
        self.data[@"weight"] = [NSNumber numberWithDouble: [textField.text doubleValue]];
    } else {
        [self.data removeObjectForKey: @"weight"];
    }
    
    textField = _warrantyField;
    if (textField.text && ![textField.text isEqualToString: @""]) {
        self.data[@"warranty"] = [NSNumber numberWithDouble: [textField.text doubleValue]];
    } else {
        [self.data removeObjectForKey: @"warranty"];
    }
    
    NSString *value = _otherLinkTextView.text;
    if (value) {
        self.data[@"picturelink"] = value;
    } else {
        [self.data removeObjectForKey: @"picturelink"];
    }
    
    if ([_delegate respondsToSelector: @selector(moreDetailVC:pickedData:)]) {
        [_delegate moreDetailVC:self pickedData: self.data];
    }
}


#pragma mark - UITextViewDelegate
#pragma mark -UITextViewDelegate
-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *final = [textView.text stringByReplacingCharactersInRange: range withString: text];
    NSInteger limit = [_info[@"otherLinkLimit"] integerValue];
    if (final.length > limit) {
        [[[UIAlertView alloc] initWithTitle: @"Other Links too long" message: [NSString stringWithFormat: @"You have reached limit of %zd characters", limit] delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] show];
        textView.text = [final substringWithRange: NSMakeRange(0, limit)];
        return NO;
    } else {
        
        return YES;
    }
}
#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (_weightField == textField) {
        if (textField.text && ![textField.text isEqualToString: @""]) {
            self.data[@"weight"] = [NSNumber numberWithDouble: [textField.text doubleValue]];
        } else {
            [self.data removeObjectForKey: @"weight"];
        }
    } else if (_warrantyField == textField) {
        if (textField.text && ![textField.text isEqualToString: @""]) {
            self.data[@"warranty"] = [NSNumber numberWithDouble: [textField.text doubleValue]];
        } else {
            [self.data removeObjectForKey: @"warranty"];
        }
    }
    [textField resignFirstResponder];
    return YES;
}

@end

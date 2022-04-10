//
//  OSItemInfoViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSItemInfoViewController.h"
#import "OSSearchTextField.h"
#import "OSPickerField.h"
#import "OSSuggestionController.h"
#import "OSMoreDetailController.h"
#import "OSCheckButton.h"

@interface OSItemInfoViewController () <UITextFieldDelegate, OSSuggestionDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet OSSearchTextField *brandField;
@property (weak, nonatomic) IBOutlet OSPickerField *yearPicker;
@property (weak, nonatomic) IBOutlet OSSearchTextField *modelField;
@property (weak, nonatomic) IBOutlet OSPickerField *transtypePicker;
@property (weak, nonatomic) IBOutlet OSSearchTextField *adTitleField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet OSCheckButton *mtbButton;
@property (weak, nonatomic) IBOutlet OSCheckButton *foldingButton;
@property (weak, nonatomic) IBOutlet OSCheckButton *bmxButton;
@property (weak, nonatomic) IBOutlet OSCheckButton *roadButton;
@property (weak, nonatomic) IBOutlet OSCheckButton *commuteButton;
@property (weak, nonatomic) IBOutlet OSCheckButton *otherButton;

@property (weak, nonatomic) IBOutlet UIView *disciplineView;
@property (weak, nonatomic) IBOutlet UIView *otherView;

@property (nonatomic, strong) NSMutableDictionary *customData;
@end

@implementation OSItemInfoViewController

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
    
    [self configureCheckButton: _mtbButton action: @selector(mtbButtonClicked:)];
    [self configureCheckButton: _roadButton action: @selector(roadButtonClicked:)];
    [self configureCheckButton: _commuteButton action: @selector(commuteButtonClicked:)];
    [self configureCheckButton: _foldingButton action: @selector(foldingButtonClicked:)];
    [self configureCheckButton: _bmxButton action: @selector(bmxButtonClicked:)];
    [self configureCheckButton: _otherButton action: @selector(otherButtonClicked:)];
    _disciplineView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0f].CGColor;
    _disciplineView.layer.borderWidth = 1.0f;
    _otherView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0f].CGColor;
    _otherView.layer.borderWidth = 1.0f;
    _descriptionTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0f].CGColor;
    _descriptionTextView.layer.borderWidth = 1.0f;
    
    _brandField.delegate = self;
    _modelField.delegate = self;
    _adTitleField.delegate = self;
    _descriptionTextView.delegate = self;
    
//    top-back-button
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"top-back-button"]  target: self selector: @selector(backButtonClicked:)];
    self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"top-next-button"]  target: self selector: @selector(nextButtonClicked:)];
    
    _customData = [NSMutableDictionary dictionaryWithDictionary: self.data];
        //Update fields;
    [self checkButton: _mtbButton check: [_customData[@"d_mtb"] isEqual: @1] key: @"d_mtb"];
    [self checkButton: _roadButton check: [_customData[@"d_road"] isEqual: @1] key: @"d_road"];
    [self checkButton: _commuteButton check: [_customData[@"d_commute"] isEqual: @1] key: @"d_commute"];
    [self checkButton: _foldingButton check: [_customData[@"d_folding"] isEqual: @1] key: @"d_folding"];
    [self checkButton: _bmxButton check: [_customData[@"d_bmx"] isEqual: @1] key: @"d_bmx"];
    [self checkButton: _otherButton check: [_customData[@"d_others"] isEqual: @1] key: @"d_others"];
    
    _brandField.text = _customData[@"brand"];
    _modelField.text = _customData[@"item"];
    _adTitleField.text = _customData[@"title"];
    _descriptionTextView.text = _customData[@"description"];
    
    if (_isEdit) {
        _brandField.backgroundColor = [UIColor lightGrayColor];
        _modelField.backgroundColor = [UIColor lightGrayColor];
        _adTitleField.backgroundColor = [UIColor lightGrayColor];
        _yearPicker.backgroundColor = [UIColor lightGrayColor];
        _transtypePicker.backgroundColor = [UIColor lightGrayColor];
        _brandField.enabled = NO;
        _modelField.enabled = NO;
        _adTitleField.enabled = NO;
        _yearPicker.enabled = NO;
        _transtypePicker.enabled = NO;
    }
    
    [self configureYearField];
    [self configureTranstypeField];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [OSHelpers sendGATrackerWithName: @"Marketplace Post or Edit Ad Item Info"];
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

-(void) configureCheckButton: (OSCheckButton *) button action: (SEL) action {
    button.useBackground = YES;
    button.checkedImage = [UIImage imageNamed: @"check-box-checked"];
    button.uncheckedImage = [UIImage imageNamed: @"check-box-unchecked"];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget: self action: action forControlEvents: UIControlEventTouchUpInside];
}

-(void) checkButton: (OSCheckButton *) button check: (BOOL) check key: (NSString *) key{
    button.checked = check;
    self.customData[key] = check ? @1 : @0;
}

-(void) toggleButton: (OSCheckButton *) button key: (NSString *) key {
    if (button.checked) {
        [self checkButton: button check: NO key: key];
    } else {
        [self checkButton: button check: YES key: key];
    }
}

//> d_mtb (0 or 1)
//> d_road (0 or 1)
//> d_commute (0 or 1)
//> d_folding (0 or 1)
//> d_bmx = 0
//> d_others (0 or 1)
-(IBAction) mtbButtonClicked: (id) sender {
    [self toggleButton: _mtbButton key: @"d_mtb"];
    [self checkButton: _otherButton check: NO key: @"d_others"];
}
-(IBAction) roadButtonClicked: (id) sender {
    [self toggleButton: _roadButton key: @"d_road"];
    [self checkButton: _otherButton check: NO key: @"d_others"];
}
-(IBAction) commuteButtonClicked: (id) sender {
    [self toggleButton: _commuteButton key: @"d_commute"];
    [self checkButton: _otherButton check: NO key: @"d_others"];
}
-(IBAction) foldingButtonClicked: (id) sender {
    [self toggleButton: _foldingButton key: @"d_folding"];
    [self checkButton: _otherButton check: NO key: @"d_others"];
}
-(IBAction) bmxButtonClicked: (id) sender {
    [self toggleButton: _bmxButton key: @"d_bmx"];
    [self checkButton: _otherButton check: NO key: @"d_others"];
}
-(IBAction) otherButtonClicked: (id) sender {
    [self toggleButton: _otherButton key: @"d_others"];
    if (_otherButton.checked) {
        [self selectAllButtons: NO];
    }
}

-(void) selectAllButtons: (BOOL) selected {
    [self checkButton: _mtbButton check: selected key: @"d_mtb"];
    [self checkButton: _roadButton check: selected key: @"d_road"];
    [self checkButton: _commuteButton check: selected key: @"d_commute"];
    [self checkButton: _foldingButton check: selected key: @"d_folding"];
    [self checkButton: _bmxButton check: selected key: @"d_bmx"];
}
- (IBAction)selectAllClicked:(id)sender {
    [self selectAllButtons: YES];
    [self checkButton: _otherButton check: NO key:@"d_others"];
}

-(void) configureYearField {
    NSMutableArray *years = [NSMutableArray new];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy";
    NSInteger year = [[dateFormat stringFromDate: [NSDate date]] integerValue];
    [years addObject: @""];
    for (NSInteger i= year; i > year - 20; i--) {
        [years addObject: [NSString stringWithFormat: @"%zd", i]];
    }
    
    __weak OSItemInfoViewController * weakSelf = self;
    
    
    NSInteger index = [years indexOfObject: _customData[@"item_year"]];
    if (index != NSNotFound) {
        self.yearPicker.text = years[index];
        _customData[@"item_year"] = years[index];
    } else {
        self.yearPicker.placeHolder = years[0];
        _customData[@"item_year"] = years[0];
    }
    self.yearPicker.componentsOfStrings = @[years];
    self.yearPicker.changeBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        if (value) {
            weakSelf.customData[@"item_year"] = value;
        }
    };

}

-(void) configureTranstypeField {
//    transtype
//values:
//    1 - Want to Sell (default)
//    2 - Want to Buy
//    3 - Free
//    4 - Exchange+cash
    NSArray *transtypeKeys = @[@1, @2, @3, @4];
    NSArray *transtypeValues = @[@"Want to Sell", @"Want to Buy", @"Free", @"Exchange+cash"];
    
     __weak OSItemInfoViewController * weakSelf = self;
    
    
    NSInteger index = [transtypeKeys indexOfObject: _customData[@"transtype"]];
    if (index != NSNotFound) {
        self.transtypePicker.text = transtypeValues[index];
        self.customData[@"transtype"] = transtypeKeys[index];
    } else {
        self.transtypePicker.text = transtypeValues[0];
        _customData[@"transtype"] = transtypeKeys[0];
    }
    self.transtypePicker.componentsOfStrings = @[transtypeValues];
    self.transtypePicker.doneBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        NSInteger index = [transtypeValues indexOfObject: value];
        if (index != NSNotFound)
            weakSelf.customData[@"transtype"] = transtypeKeys[index];
    };
}

#pragma mark - actions
- (IBAction)nextButtonClicked:(id)sender {
    if (_adTitleField.text && ![_adTitleField.text isEqualToString: @""]) {
        self.customData[@"title"] = _adTitleField.text;
    }
    NSString *value = _descriptionTextView.text;
    if (value && ![value isEqualToString: @""]) {
        self.customData[@"description"] = value;
    } else {
        [self.customData removeObjectForKey: @"description"];
    }
    
    //Not allow to go next if ad title and description is not filled
    if (!self.customData[@"title"] || !self.customData[@"description"]) {
        [[[UIAlertView alloc] initWithTitle: @"Ad Title and Description required" message: @"Ad title and Description must has value" delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] show];
        return;
    }
    
    
    OSMoreDetailController *moreVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSMoreDetailController"];
    moreVC.info = self.info;
    moreVC.delegate = self.delegate;
    moreVC.data= [NSMutableDictionary dictionaryWithDictionary: self.customData];
    [self.navigationController pushViewController:moreVC animated: YES];
}

#pragma mark - Actions
- (IBAction)applyActionClicked:(id)sender {
    
    if ([_delegate respondsToSelector: @selector(itemVC:pickedData:)]) {
        [_delegate itemVC:self pickedData: self.customData];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _brandField) {
        OSSuggestionController *brandsVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSSuggestionController"];
        brandsVC.delegate = self;
        brandsVC.url = @"https://www.togoparts.com/iphone_ws/get-option-values.php?source=ios&brands=1";
        brandsVC.key = @"Brands";
        brandsVC.title = @"Brands";
        [self.navigationController pushViewController: brandsVC animated: YES];
        return NO;
    } else if (textField == _modelField) {
        OSSuggestionController *modelVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSSuggestionController"];
        modelVC.delegate = self;
        if (self.customData[@"brand"]) {
            modelVC.url = [NSString stringWithFormat: @"https://www.togoparts.com/iphone_ws/get-option-values.php?source=ios&models=1&brandname=%@", [self.customData[@"brand"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        } else {
            modelVC.url = @"https://www.togoparts.com/iphone_ws/get-option-values.php?source=ios&models=1&brandname=";
        }
        modelVC.key = @"Models";
        modelVC.title = @"Models";
        [self.navigationController pushViewController: modelVC animated: YES];
        return NO;
    }
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (_adTitleField == textField) {
        if (textField.text && ![textField.text isEqualToString: @""]) {
            self.customData[@"title"] = _adTitleField.text;
        } else {
            [[[UIAlertView alloc] initWithTitle: @"Not Empty" message: @"Ad title must has value" delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] show];
            return NO;
        }
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - OSSuggestionDelegate
-(void) suggestionController:(OSSuggestionController *)suggestionVC didSelectedValue:(id)value {
    if ([suggestionVC.key isEqualToString: @"Brands"]) {
        _brandField.text = value;
        if (value) {
            self.customData[@"brand"] = value;
        } else {
            [self.customData removeObjectForKey: @"brand"];
        }
    } else if ([suggestionVC.key isEqualToString: @"Models"]) {
        _modelField.text = value;
        if (value) {
            self.customData[@"item"] = value;
        } else {
            [self.customData removeObjectForKey: @"item"];
        }
    }
    
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark -UITextViewDelegate
-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *final = [textView.text stringByReplacingCharactersInRange: range withString: text];
    NSInteger limit = [_info[@"descriptionLimit"] integerValue];
    if (final.length > limit) {
        [[[UIAlertView alloc] initWithTitle: @"Description too long" message: [NSString stringWithFormat: @"You have reached limit of %zd characters", limit] delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] show];
        textView.text = [final substringWithRange: NSMakeRange(0, limit)];
        return NO;
    } else {
        return YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

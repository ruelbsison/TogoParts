//
//  OSContactViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/5/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSContactViewController.h"
#import "OSSearchTextField.h"
#import "OSPickerField.h"
#import "OSSuggestionController.h"

@interface OSContactViewController () <UITextFieldDelegate, OSSuggestionDelegate>
@property (weak, nonatomic) IBOutlet OSSearchTextField *personField;
@property (weak, nonatomic) IBOutlet OSSearchTextField *numberField;
@property (weak, nonatomic) IBOutlet OSPickerField *timeToCallField;
@property (weak, nonatomic) IBOutlet OSSearchTextField *locationField;

@end

@implementation OSContactViewController

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
    if (!_data) {
        self.data = [NSMutableDictionary new];
    } else  {
        //Update fields;
        _personField.text = _data[@"contactperson"];
        _numberField.text = _data[@"contactno"];
        _locationField.text = _data[@"address"];
        
    }
    
    self.personField.delegate = self;
    self.numberField.delegate = self;
    self.locationField.delegate = self;
    
    [self configureTimeToCallPicker];
    
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed:@"top-back-button"] target:self selector: @selector(backButtonClicked:)];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [OSHelpers sendGATrackerWithName: @"Marketplace Post or Edit Ad Contact Info"];
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

-(void) configureTimeToCallPicker {
//    time_to_contact (string)	- values
//   	Anytime (default)
//	Morning
//    Afternoon
//    After 7pm
//    SMS/WhatsApp only
//    Private Message only
    NSArray *times = @[@"Anytime", @"Morning", @"Afternoon", @"After 7pm", @"SMS/WhatsApp only", @"Private Message only"];
    
    __weak OSContactViewController *weakSelf = self;
    if (!_data[@"time_to_contact"]) {
        self.timeToCallField.text = times[0];
        self.data[@"time_to_contact"] = times[0];
    } else {
        self.timeToCallField.text = _data[@"time_to_contact"];
    }
    self.timeToCallField.componentsOfStrings = @[times];
    self.timeToCallField.changeBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        weakSelf.data[@"time_to_contact"] = value;
    };
}

#pragma mark - Actions
- (IBAction)applyButtonClicked:(id)sender {
    if (_personField.text && ![_personField.text isEqualToString: @""]) {
        self.data[@"contactperson"] = _personField.text;
    }
    if (_numberField.text && ![_numberField.text isEqualToString: @""]) {
        self.data[@"contactno"] = _numberField.text;
    }
    
    if ([self.delegate respondsToSelector: @selector(contactVC:pickedData:)]) {
        [_delegate contactVC:self pickedData:self.data];
    }
}

-(IBAction) clearLocationButtonClicked:(id)sender {
    [self.data removeObjectsForKeys: @[@"city", @"region", @"country", @"postalcode", @"address", @"lat", @"long"]];
    self.locationField.text = nil;
}

#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _locationField) {
        OSSuggestionController *locationVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSSuggestionController"];
        locationVC.isLocationSearch = YES;
        locationVC.delegate = self;
        locationVC.title = @"Location";
        [self.navigationController pushViewController: locationVC animated: YES];
        return NO;
    }
    return YES;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -OSSuggestionDelegate
-(void)suggestionController:(OSSuggestionController *)suggestionVC didSelectedValue:(id)value {
    NSDictionary *locationInfo = (NSDictionary *) value;
    if (locationInfo && locationInfo[@"address"]) {
        self.locationField.text = locationInfo[@"address"];
    }
    [self.data addEntriesFromDictionary: locationInfo];
    [self.navigationController popViewControllerAnimated: YES];
}


@end

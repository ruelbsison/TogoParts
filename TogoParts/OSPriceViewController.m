//
//  OSPriceViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/5/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSPriceViewController.h"
#import "OSSearchTextField.h"
#import "OSPickerField.h"
#import "OSCheckButton.h"

@interface OSPriceViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet OSSearchTextField *priceField;
@property (weak, nonatomic) IBOutlet OSPickerField *priceTypePicker;
@property (weak, nonatomic) IBOutlet OSSearchTextField *originPriceField;
@property (weak, nonatomic) IBOutlet OSCheckButton *clearanceButton;

@end

@implementation OSPriceViewController

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
//    _info[@"postingpack"] = @YES; //For testing clearance
    
    // Do any additional setup after loading the view.
    _clearanceButton.checkedImage = [UIImage imageNamed: @"check-box-checked"];
    _clearanceButton.uncheckedImage = [UIImage imageNamed: @"check-box-unchecked"];
    _clearanceButton.useBackground = YES;
    
    if (!self.data) {
        self.data = [NSMutableDictionary new];
        if (_info[@"postingpack"]) {
            [self checkButton: _clearanceButton check: NO key:@"clearance"];
        }
    } else {
        if (_data[@"price"]) _priceField.text = [NSString stringWithFormat: @"%@", _data[@"price"]];
         
        //Original price
        if (_info[@"merchant"] || _info[@"postingpack"]) {
            if (_data[@"original_price"]) _originPriceField.text = [_data[@"original_price"] stringValue];
        }
        
        //Clearance
        if (_info[@"postingpack"]) {
            if (_data[@"clearance"]) {
                [self checkButton: _clearanceButton check: [_data[@"clearance"] isEqual: @1] ? YES: NO key:@"clearance"];
            } else {
                [self checkButton: _clearanceButton check: NO key:@"clearance"];
            }
        }
    }
    
    [self configurePriceTypePicker];
    
    _priceField.delegate = self;
    _originPriceField.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed:@"top-back-button"] target:self selector: @selector(backButtonClicked:)];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [OSHelpers sendGATrackerWithName: @"Marketplace Post or Edit Ad Price"];
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

-(void) toggleButton: (OSCheckButton *) button key: (NSString *) key {
    if (button.checked) {
        [self checkButton: button check: NO key: key];
    } else {
        [self checkButton: button check: YES key: key];
    }
}

-(void) checkButton: (OSCheckButton *) button check: (BOOL) check key: (NSString *) key{
    button.checked = check;
    self.data[key] = check ? @1 : @0;
}

- (IBAction)clearanceButtonClicked:(id)sender {
    [self toggleButton: _clearanceButton key: @"clearance"];
}

-(void) configurePriceTypePicker {
//    3 - Do not specify	(default)
//    1 - Firm
//    2 - Negotiable
    NSArray *typeKeys = @[@3, @1, @2];
    NSArray *typeValues = @[ @"Do not specify", @"Firm", @"Negotiable"];
    
    __weak OSPriceViewController *weakSelf = self;
    if (!_data[@"pricetype"]) {
        self.priceTypePicker.placeHolder = typeValues[0];
        self.data[@"pricetype"] = typeKeys[0];
    } else {
        NSInteger index = [typeKeys indexOfObject: _data[@"pricetype"]];
        if (index != NSNotFound) {
            self.priceTypePicker.text = typeValues[index];
        }
    }
    self.priceTypePicker.componentsOfStrings = @[typeValues];
    self.priceTypePicker.doneBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        NSInteger index = [typeValues indexOfObject: value];
        if (index != NSNotFound)
            weakSelf.data[@"pricetype"] = typeKeys[index];
    };
}

#pragma mark - Actions
- (IBAction)applyButtonClicked:(id)sender {
    
    UITextField *textField = _priceField;
    if (textField.text && ![textField.text isEqualToString: @""]) {
        self.data[@"price"] = [NSNumber numberWithDouble: [textField.text doubleValue]];
    } else {
        [self.data removeObjectForKey: @"price"];
    }
    textField = _originPriceField;
    if (textField.text && ![textField.text isEqualToString: @""]) {
        self.data[@"original_price"] = [NSNumber numberWithDouble: [textField.text doubleValue]];
    } else {
        [self.data removeObjectForKey: @"original_price"];
    }

    if ([_delegate respondsToSelector: @selector(priceVC:pickedData:)]) {
        [_delegate priceVC: self pickedData: self.data];
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 2:
            if (_info[@"postingpack"]) {
                return 65;
            } else {
                return 0;
            }
            break;
        case 3:
            if (_info[@"merchant"] || _info[@"postingpack"]) {
                return 65;
            } else {
                return 0;
            }
            break;
            
        default:
            return 65;
            break;
    }
}


#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
}
@end

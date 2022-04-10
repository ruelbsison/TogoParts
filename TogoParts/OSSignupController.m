//
//  OSSignupController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 7/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSSignupController.h"
#import <AFNetworking/AFNetworking.h>
#import "OSUser.h"
#import "OSSearchTextField.h"
#import "OSPickerField.h"

@interface OSSignupController ()
@property (weak, nonatomic) IBOutlet OSSearchTextField *usernameField;
@property (weak, nonatomic) IBOutlet OSPickerField *countryPicker;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) NSString *country;
@end

@implementation OSSignupController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    NSDictionary *facebookUser = _params[@"facebookUser"];
    NSString *facebookName = [NSString stringWithFormat: @"%@ %@ %@", facebookUser[@"first_name"], facebookUser[@"middle_name"] ? facebookUser[@"middle_name"] : @"",facebookUser[@"last_name"]];
    
    self.nameLabel.text = facebookName;
    self.emailLabel.text = facebookUser[@"email"];
    
    [self configureCountryField];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    if (!self.emailLabel.text) {
        //Doesn't have permission
        //Eh-eh must have
        VTTShowAlertView(@"Email required!", @"You must allow us to access your facebook email in order to proceed", @"Dismiss");
        [self.navigationController popViewControllerAnimated: YES];
    }
    
    [OSHelpers sendGATrackerWithName: @"Facebook Signup Form"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpButtonClicked:(id)sender {
    if (!_params) {
        NSLog(@"_params not exist. Need Facebook infos");
        return;
    }
//    fb User: {
//        birthday = "08/08/1980";
//        email = "togoparts_yfgpnmc_two@tfbnw.net";
//        "first_name" = Togoparts;
//        gender = female;
//        id = 100004433239362;
//        "last_name" = two;
//        link = "http://www.facebook.com/100004433239362";
//        locale = "en_US";
//        "middle_name" = User;
//        name = "Togoparts User two";
//        timezone = 7;
//        "updated_time" = "2014-07-11T02:20:06+0000";
//        verified = 0;
//    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDictionary *facebookUser = _params[@"facebookUser"];
    params[@"FBid"] = facebookUser[@"id"];
    params[@"FBemail"] = facebookUser[@"email"];
    params[@"AccessToken"] = _params[@"AccessToken"];
    if (!_usernameField.text || [_usernameField.text isEqualToString: @""]) {
        VTTShowAlertView(@"Username required!", @"You must fill in username", @"Ok");
        return;
    } else {
        params[@"Username"] = _usernameField.text;
    }
    
    if (self.country && ![self.country isEqualToString: @""]) {
        params[@"Country"] = self.country;
    } else {
//        params[@"Country"] = @"Singapore";
        VTTShowAlertView(@"Country required!", @"You must pick a Country", @"Ok");
        return;
    }
    
    //    _params[@"Username"]= @"test_merge_ios";
    //    _params[@"Country"] = @"Vietnam";
    
    NSLog(@"signup params: %@", params);
    
    [OSUser signupWithParams: params block:^(OSUser *user, NSError *error, id response) {
        NSDictionary *result = response[@"Result"];
        if (result) {
            NSString *returnString = result[@"Return"];
            if ([returnString isEqualToString: @"success"]) {
                //Go to profile page
                [[NSNotificationCenter defaultCenter] postNotificationName:OS_USER_LOGGED_IN_NOTIFICATON object: nil];
            } else if ([returnString isEqualToString: @"error"]) {
                [[[UIAlertView alloc] initWithTitle: @"" message: result[@"Message"] delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] show];
            }
        }
    }];

}
- (IBAction)cancelButtonClicked:(id)sender {
    [OSUser logout];
    [self.navigationController popViewControllerAnimated: YES];
}

-(void) configureCountryField {
    __weak OSSignupController *weakSelf = self;
    NSMutableArray *countryKeys = [NSMutableArray new];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: @"http://www.togoparts.com/iphone_ws/get-dropdown-values.php?country=1" parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *countries = responseObject[@"Result"][@"Country"];
        for (NSInteger i = 0; i < countries.count; i++) {
            [countryKeys addObject: countries[i]];
        }
        
        weakSelf.countryPicker.enabled = YES;
        weakSelf.countryPicker.placeHolder = @"";
        weakSelf.countryPicker.componentsOfStrings = @[countryKeys];
        weakSelf.countryPicker.doneBlock = ^(OSPickerField *picker) {
            NSString *value = picker.text;
            weakSelf.country = value;
        };
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Country Dropdown Failure response: %@", operation.response);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

@end

//
//  OSMergeViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSMergeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "OSUser.h"

@interface OSMergeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation OSMergeViewController

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
    if (_info) {
        //                {"Result":{"Return":"merge","username":"tgptestuser1",
        //                    "picture": "http:\/\/www.togoparts.com\/members\/avatars\/icons\/10-3.gif",
        //                    "country":"Singapore","gender":"Female"}}
        _usernameLabel.text = _info[@"username"];
        _countryLabel.text = _info[@"country"];
        _genderLabel.text = _info[@"gender"];
        
        [_profileImageView setImageWithURL: [NSURL URLWithString: _info[@"picture"]] placeholderImage: nil];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [OSHelpers sendGATrackerWithName: @"Facebook Merge Account"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)yesButtonClicked:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary new];
//    FBid
//    Userid
//    FBemail
//    AccessToken
    NSDictionary *facebookUser = _info[@"facebookUser"];
    params[@"FBid"] = facebookUser[@"id"];
    params[@"FBemail"] = facebookUser[@"email"];
    params[@"AccessToken"] = _info[@"AccessToken"];
    params[@"Userid"] = _info[@"Userid"];
    
    MBProgressHUD *hud = [OSHelpers showStandardHUDForView: self.view];
    [OSUser mergeWithParams: params block:^(OSUser *user, NSError *error, id response) {
        [OSHelpers hideStandardHUD: hud];
        NSDictionary *result = response[@"Result"];
        if (result) {
            NSString *returnStr = result[@"Return"];
            if ([returnStr isEqualToString: @"success"]) {
                VTTShowAlertView(@"", @"You have merged account successfully!",  @"Ok");
//                [self.navigationController popToRootViewControllerAnimated: NO];
                [[NSNotificationCenter defaultCenter] postNotificationName: OS_USER_LOGGED_IN_NOTIFICATON object: self];
            } else if ([returnStr isEqualToString: @"error"]) {
                VTTShowAlertView(@"", result[@"Message"],  @"Ok");
                [self.navigationController popToRootViewControllerAnimated: YES];
            }
        }
        
        if (error || !result) {
            VTTShowAlertView(@"Notice", @"Oophs, some errors occurred, please try again later", @"Ok");
            [self.navigationController popToRootViewControllerAnimated: YES];
        }
    }];
}
- (IBAction)noButtonClicked:(id)sender {
    [OSUser logout];
    [self.navigationController popViewControllerAnimated: YES];
}

@end

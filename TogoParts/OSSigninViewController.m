//
//  OSSigninViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 7/10/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSSigninViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <FacebookSDK/FacebookSDK.h>
#import "OSUser.h"
#import "OSSignupController.h"
//#import "OSProfileViewController.h"
#import "OSMergeViewController.h"

@interface OSSigninViewController () <FBLoginViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (nonatomic) __block BOOL fbSigningUp;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;

@property (nonatomic) __block MBProgressHUD *hud;
@end


@implementation OSSigninViewController

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
    [self.navigationController setNavigationBarHidden:YES];
    
    OSChangeTogoFontForLabel(_orLabel);
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    // Create a FBLoginView to log the user in with basic, email and friend list permissions
    // You should ALWAYS ask for basic permissions (public_profile) when logging the user in
    _fbLoginView.readPermissions = @[@"public_profile", @"email"];
    
    // Set this loginUIViewController to be the loginView button's delegate
    _fbLoginView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    _fbSigningUp = false;
    
    if (_hud && !_hud.isHidden) [_hud hide: YES];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    //    _fbSigningUp = true;
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex: buttonIndex];
    if ([alertView.title isEqualToString: @"Detail missing!"]) {
        if ([buttonTitle isEqualToString: @"Authorize"]) {
            [[FBSession activeSession] requestNewReadPermissions: @[@"email"] completionHandler: nil];
        } else {
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
    }
}

#pragma mark - Facebook login delegate

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)fbuser {
    NSLog(@"fb User: %@", fbuser);
    
    if (!fbuser[@"email"]) {
        //        VTTShowAlertView(@"Email not Exist!", @"You must allow us to access your facebook email in order to proceed", @"Dismiss");
        [[[UIAlertView alloc] initWithTitle: @"Detail missing!" message: @"Email is required to proceed sign-up" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Authorize", nil] show];
        return;
    }
    
    //    NSString *fbId = fbuser[@"id"];
    //    NSString *fbEmail = fbuser[@"email"];
    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    if (!accessToken) return;
    
    if (_fbSigningUp) return;
    
    if (!_hud) {
        _hud = [OSHelpers showStandardHUDForView: self.view];
    } else {
        [_hud show: YES];
    }
    
    [OSUser facebookLogInWithFacebookUser: fbuser block:^(OSUser *user, NSError *error, id response) {
        if (_fbSigningUp) return;
        _fbSigningUp = true;
        NSDictionary *result = response[@"Result"];
        [OSHelpers hideStandardHUD: _hud];
        
        if (result) {
            NSString *returnString =result[@"Return"];
            if ([returnString isEqualToString: @"new"])
            {
                
                OSSignupController *signUp = [self.storyboard instantiateViewControllerWithIdentifier: @"OSSignupController"];
                signUp.params = [NSMutableDictionary dictionaryWithDictionary: @{ @"facebookUser" : fbuser ,@"AccessToken": accessToken}];
                [self.navigationController pushViewController: signUp animated: YES];
                
            } else if ([returnString isEqualToString: @"success"])
            {
                
                [[NSNotificationCenter defaultCenter] postNotificationName: OS_USER_LOGGED_IN_NOTIFICATON object: nil];
                
            } else if ([returnString isEqualToString: @"merge"]){
                //                {"Result":{"Return":"merge","username":"tgptestuser1",
                //                    "picture": "http:\/\/www.togoparts.com\/members\/avatars\/icons\/10-3.gif",
                //                    "country":"Singapore","gender":"Female"}}
                OSMergeViewController *mergeVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSMergeViewController"];
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary: result];
                info[@"facebookUser"] = fbuser;
                info[@"AccessToken"] = accessToken;
                mergeVC.info = info;
                
                [self.navigationController pushViewController: mergeVC animated: YES];
            }
            else if ([returnString isEqualToString: @"error"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: returnString message: result[@"Message"] delegate: nil cancelButtonTitle: @"Cancel" otherButtonTitles: nil];
                [alert show];
                _fbSigningUp = false;
            } else if ([result[@"Return"] isEqualToString: @"banned"]) {
                VTTShowAlertView(@"",  result[@"Message"],  @"Ok");
                _fbSigningUp = false;
                [OSUser logout];
            }
        }
    }];
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    //    self.statusLabel.text = @"You're logged in as";
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    //    self.profilePictureView.profileID = nil;
    //    self.nameLabel.text = @"";
    //    self.statusLabel.text= @"You're not logged in!";
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


#pragma mark - Action
- (IBAction)signinButtonClicked:(id)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (!username) username = @"";
    if (!password) password = @"";
    
    //    username = @"pauvi";
    //    password = @"tgptesting";
    
    MBProgressHUD *hud = [OSHelpers showStandardHUDForView: self.view];
    [OSUser loginWithUsername: username password: password block:^(OSUser *user, NSError *error, id response) {
        [OSHelpers hideStandardHUD: hud];
        
        if (response[@"Result"] && response[@"Result"][@"Return"]) {
            NSDictionary *result = response[@"Result"];
            NSString *returnStr = response[@"Result"][@"Return"];
            if ([returnStr isEqualToString: @"error"] || [returnStr isEqualToString: @"banned"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message: result[@"Message"] delegate: nil cancelButtonTitle: @"Cancel" otherButtonTitles: nil];
                [alert show];
            } else if ([returnStr isEqualToString: @"success"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName: OS_USER_LOGGED_IN_NOTIFICATON object: nil userInfo: nil];
            }
        }
    }];
}
- (IBAction)skipButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName: OS_USER_SKIPPED_LOGGED_IN_NOTIFICION object: nil];
}

#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end

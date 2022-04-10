//
//  OSProfileViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 7/23/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSProfileViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "OSUser.h"
#import "OSListingCell.h"
#import "OSAdDetailViewController.h"
#import "OSLabel.h"

@interface OSProfileViewController () <OSListingCellDelegate, UIAlertViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *neutralLabel;
@property (weak, nonatomic) IBOutlet UILabel *negativeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UICollectionView *attribCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *noAdLabel;
@property (weak, nonatomic) IBOutlet OSLabel *tcredsLabel;


@property (nonatomic) NSString *username;

@property (nonatomic) NSMutableArray *data;
@property (nonatomic) NSDictionary *result;
@end

@implementation OSProfileViewController

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
    
    //Data
    self.data = [NSMutableArray new];
    self.result = [NSDictionary new];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _positiveLabel.text = @"";
    _negativeLabel.text = @"";
    _neutralLabel.text  = @"";
    
    [self.tableView registerNib: [UINib nibWithNibName: @"OSListingCell" bundle: nil] forCellReuseIdentifier: @"OSListingCell"];
    
//    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"top-back-button"]  target: self selector: @selector(backButtonClicked:)];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
//    if ([OSUser currentUser]) {
//        self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed:@"logout-icon"] target: self selector: @selector(logoutButtonClicked:)];
//    }

    [OSHelpers sendGATrackerWithName: @"Marketplace Manage Ads"];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
-(void) logoutButtonClicked: (id) sender {
    
    [[[UIAlertView alloc] initWithTitle: @"Logout confirm" message: @"Logout Togoparts account?" delegate: self cancelButtonTitle: @"NO" otherButtonTitles:@"YES", nil] show];
}

-(void) logout {
    [OSUser logout];
    [[NSNotificationCenter defaultCenter] postNotificationName: OS_USER_LOGGED_OUT_NOTIFICATON object: nil];
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

-(void) openTCredsLink {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: _result[@"info"][@"TCredsLink"]]];

}

-(void) buyTcredsButtonClicked:(id) sender {
//    NSLog(@"_result[info][TcredsLink]: %@", _result[@"info"][@"TCredsLink"]);
    [self openTCredsLink];
}

- (void) loadData {
    OSUser *user = [OSUser currentUser];
    if (user) {
//        NSDictionary *params = @{@"session_id": user.session_id};
    
        MBProgressHUD *hud = [OSHelpers showStandardHUDForView: self.view];
        NSMutableDictionary *params = [NSMutableDictionary new];
        NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
        if (accessToken) params[@"AccessToken"] = accessToken;
//        AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
        [OSUser POST: @"https://www.togoparts.com/iphone_ws/user-profile.php?source=ios" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [OSHelpers hideStandardHUD: hud];
            NSLog(@"profile responseObject: %@", responseObject);
            NSDictionary *result = responseObject[@"Result"];
            if (result) {
                if ([result[@"Return"] isEqualToString: @"error"]) {
                    [OSUser logout];
//                [self.navigationController popToRootViewControllerAnimated: YES];
                } else if ([result[@"Return"] isEqualToString: @"banned"]) {
                    [OSUser logout];
                    
                } else if ([result[@"Return"] isEqualToString: @"success"]) {
                    _result = result;
                    
                    NSString *username = result[@"info"][@"username"];
                    self.username = username;
//                    self.usernameLabel.text = self.username;
                    
                    [self loadAds];
                    NSString *picture = result[@"info"][@"picture"];
                    if (picture) {
                        [self.profileImageView setImageWithURL: [NSURL URLWithString: picture] placeholderImage: nil];
                    }
                    
                    ///TCreds Label
                    self.tcredsLabel.text = [NSString stringWithFormat: @"%@", result[@"info"][@"TCreds"]];
                    
                    ///Ratings
                    if (result[@"ratings"]) {
                        NSDictionary *ratings = result[@"ratings"];
                        _positiveLabel.text = [NSString stringWithFormat: @"%@", ratings[@"Positive"]];
                        _negativeLabel.text = [NSString stringWithFormat: @"%@", ratings[@"Negative"]];
                        _neutralLabel.text  = [NSString stringWithFormat: @"%@", ratings[@"Neutral"]];
                    }
                    
                    ///Attribs
                    [self.attribCollectionView reloadData];
                    
                    //Add buyTcreds button
                    self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"buy-tcreds"] target: self selector: @selector(buyTcredsButtonClicked:)];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [OSHelpers hideStandardHUD: hud];
            NSLog(@"sign in error: %@", error.localizedDescription);
            NSLog(@"of request: %@ and response: %@", operation.request, operation.responseObject);
        }];
    } else {
        [OSUser logout];
    }
}

-(void) loadAds {
    NSDictionary *params = @{@"profilename" : self.username};
    NSLog(@"profile ads params: %@", params);
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    [testManager GET:@"http://www.togoparts.com/iphone_ws/mp_list_ads.php?v=1.2.4" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"list ads in profile: %@", responseObject);
        self.data = responseObject[@"ads"];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark - UITableViewDatasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.data.count <= 0) {
        self.noAdLabel.hidden = NO;
    } else {
        self.noAdLabel.hidden = YES;
    }
    return self.data.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    OSListingCell *cell = [tableView dequeueReusableCellWithIdentifier: @"OSListingCell" forIndexPath: indexPath];
    OSListingCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    [cell configureCellWithData: self.data[indexPath.row]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: self.data[indexPath.row]];
//    if (self.result[@"quota"]) {
//        dict[@"TCreds"] = self.result[@"quota"][@"TCredits balance"];
//    } else {
//        dict[@"TCreds"] = self.result[@"postingpack"][@"TCredits balance"];
//    }
    
    cell.tag = indexPath.row;
    cell.listingDelegate = self;
    [cell configureDrawerViewWithData: dict];
//    cell.directionMask = UISwipeGestureRecognizerDirectionLeft;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        NSDictionary *rowData = _data[indexPath.row];
        if (rowData[@"pinad"]) {
            //Do nothing
        } else {
            NSString *aid = rowData[@"aid"];
            
            if (aid) {
                OSAdDetailViewController *adDetailVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSAdDetailViewController"];
//                adDetailVC.aid = @"722327"; //ad with comments
                adDetailVC.aid = aid;
                NSString *status = rowData[@"adstatus"];
                if ([status isEqualToString: @"Available"] || [status isEqualToString: @"Looking"] || [status isEqualToString: @"For Exchange"]) {
                    adDetailVC.showEditButton = YES;
                } else {
                    adDetailVC.showEditButton = NO;
                }
                adDetailVC.showSearchButton = NO;
                [self.navigationController pushViewController: adDetailVC animated: YES];
            }
        }
}

#pragma mark - UICollectionViewDatasource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_result[@"quota"] count];
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath:indexPath];
    UILabel *label = (UILabel *) [cell viewWithTag: 1];
    UILabel *value = (UILabel *) [cell viewWithTag: 2];
    NSDictionary *rowData = _result[@"quota"][indexPath.row];
//    {
//        label = "Free Ads Posted";
//        value = 3;
//    },
    label.text = rowData[@"label"];
    value.text = [NSString stringWithFormat: @"%@", rowData[@"value"]];
    return cell;
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = alertView.title;
    NSString *buttonTitle = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: @"Insufficient TCredits"]) {
        if ([buttonTitle isEqualToString: @"Buy TCredits"]) {
            [self openTCredsLink];
        }
        
    } else if ([buttonTitle isEqualToString: @"YES"]) {
        if ([title isEqualToString: @"Confirm Mark As Sold"] || [title isEqualToString: @"Confirm Mark As Exchanged"] || [title isEqualToString: @"Confirm Mark As Found"] || [title isEqualToString: @"Confirm Mark As Given"]) {
            [self postLink: @"https://www.togoparts.com/iphone_ws/mp-manage-ad.php?source=ios" ofIndex: alertView.tag info: nil params:@{@"action": @"sold"}];
        } else if ([title isEqualToString: @"Confirm Refresh"]) {
            [self postLink: @"https://www.togoparts.com/iphone_ws/mp-manage-ad.php?source=ios" ofIndex: alertView.tag info: @{@"type": @"refresh"} params:@{@"action": @"refresh"}];
        } else if ([title isEqualToString: @"Confirm Repost"]) {
            [self postLink: @"https://www.togoparts.com/iphone_ws/mp-manage-ad.php?source=ios" ofIndex: alertView.tag info: nil params:@{@"action": @"repost"}];
        } else if ([title isEqualToString: @"Confirm Take Down"]) {
            [self postLink: @"https://www.togoparts.com/iphone_ws/mp-manage-ad.php?source=ios" ofIndex: alertView.tag info: nil params:@{@"action": @"takedown"}];
        } else if ([title isEqualToString: @"Logout confirm"]) {
            [self logout];
        }
    }
}

#pragma mark - OSListingCellDelegate

-(void) postLink: (NSString *) link ofIndex: (NSInteger) index info: (NSDictionary *) info  params: (NSDictionary *) parameters{
    NSDictionary *rowData = self.data[index];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary: @{@"aid": rowData[@"aid"]}];
    [params addEntriesFromDictionary: parameters];
    
    MBProgressHUD *hud = [OSHelpers showStandardHUDForView: self.view];
    
    [OSUser POST: link parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [OSHelpers hideStandardHUD: hud];
        NSDictionary *result = responseObject[@"Result"];
        if (result) {
            if (result[@"Message"]) {
                if (result[@"TCredsLink"]) {
                    [[[UIAlertView alloc] initWithTitle: result[@"Return"] message:result[@"Message"] delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
                    [self loadData];
                } else {
                    VTTShowAlertView(@"", result[@"Message"], @"Ok");
                }
            }

            if ([result[@"Return"] isEqualToString: @"success"]) {
//                VTTShowAlertView(@"Success", result[@"Message"], @"Dismiss");
                [self loadData];
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [OSHelpers hideStandardHUD: hud];
        NSLog(@"sign in error: %@", error.localizedDescription);
        NSLog(@"of request: %@ and response: %@", operation.request, operation.responseObject);
    }];
}

-(void) listingCell:(OSListingCell *)cell markAsSoldClicked:(id)sender action: (NSString *) action{
//    Web Service: https://www.togoparts.com/iphone_ws/mp-mark-ad.php?source=android
//    
//    Post values:
//    session_id
//    aid
    NSString *title;
    if ([action isEqualToString: @"sold"]) {
        title = @"Confirm Mark As Sold";
    } else if ([action isEqualToString: @"exchanged"]) {
        title = @"Confirm Mark As Exchanged";
    } else if ([action isEqualToString: @"found"]) {
        title = @"Confirm Mark As Found";
    } else if ([action isEqualToString: @"given"]) {
        title = @"Confirm Mark As Given";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: [NSString stringWithFormat: @"Do you want to mark the ad as %@?", action] delegate: self cancelButtonTitle: @"NO" otherButtonTitles: @"YES", nil];
    alert.tag = cell.tag;
    [alert show];
    
}
-(void) listingCell:(OSListingCell *)cell refreshClicked:(id)sender {
    NSDictionary *rowData = self.data[cell.tag];
    NSNumber *tcredCost = rowData[@"refresh_cost"];
    NSNumber *Tcreds = _result[@"info"][@"TCreds"];
    if ([Tcreds compare: tcredCost] == NSOrderedAscending) {
        [[[UIAlertView alloc] initWithTitle: @"Insufficient TCredits" message: @"Purchase Tcredits to refresh this ad." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Confirm Refresh" message: @"Bump your Ad to the top of the list for 1 Tcredit?" delegate: self cancelButtonTitle: @"NO" otherButtonTitles: @"YES", nil];
        alert.tag = cell.tag;
        [alert show];
    }
}
-(void) listingCell:(OSListingCell *)cell repostClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Confirm Repost" message: @"Do you want to repost the ad?" delegate: self cancelButtonTitle: @"NO" otherButtonTitles: @"YES", nil];
    alert.tag = cell.tag;
    [alert show];
}
-(void) listingCell:(OSListingCell *)cell takeDownClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Confirm Take Down" message: @"Do you want to take down the ad?" delegate: self cancelButtonTitle: @"NO" otherButtonTitles: @"YES", nil];
    alert.tag = cell.tag;
    [alert show];
}
@end

//
//  OSSectionViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSSectionViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "OSCategoryViewController.h"

@interface OSSectionViewController ()
@property (nonatomic, strong) NSDictionary *data;
@end

@implementation OSSectionViewController

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
    
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"top-back-button"]  target: self selector: @selector(backButtonClicked:)];
    
    self.data = [NSDictionary new];
    
    //Getdata
//    https://www.togoparts.com/iphone_ws/get-option-values.php?source=android&section=1
//    "Result": {
//        "Sections": {
//            "1": {
//                "title": "Bike Marketplace - Off-Road Bike Components",
//                "newitem_cost": 2,
//                "priority_cost": 4
//            },
//            ….
//        }
//    }

    OSUser *user = [OSUser currentUser];
    if (user) {
        MBProgressHUD *hud = [OSHelpers showStandardHUDForView: self.view];
        [OSUser POST: @"https://www.togoparts.com/iphone_ws/get-option-values.php?source=ios&section=1" parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [OSHelpers hideStandardHUD: hud];
            NSDictionary *result = responseObject[@"Result"];
            if ([result[@"Return"] isEqualToString: @"error"]) {
                [[[UIAlertView alloc] initWithTitle: @"Error" message: @"Session expired. Please login" delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                [self.navigationController dismissViewControllerAnimated: YES completion: nil];
            } else {
                self.data = result;
                
                [self.tableView reloadData];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [OSHelpers hideStandardHUD: hud];
        }];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [OSHelpers sendGATrackerWithName: @"Marketplace Post Ad Sections"];
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

#pragma mark - UITableViewDatasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data[@"Sections"] count];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    
    NSDictionary *rowData = self.data[@"Sections"][indexPath.row];
    
    UILabel *textLabel = (UILabel *) [cell viewWithTag: 2];
    textLabel.text = self.data[@"Sections"][indexPath.row][@"data"][@"title"];
    
    if (self.categoryData && self.categoryData[@"section"]) {
        UIImageView *tickImage = (UIImageView *) [cell viewWithTag:1];
        if ([self.categoryData[@"section"] isEqualToNumber: rowData[@"id"]]) {
            tickImage.hidden = NO;
        } else {
            tickImage.hidden = YES;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = self.data[@"Sections"][indexPath.row];
    
//    _adType = @1; //TODO: Just for Test
    
    NSNumber *priorityCost = rowData[@"data"][@"priority_cost"];
    NSNumber *nItemCost = rowData[@"data"][@"newitem_cost"];
    
    if (priorityCost) {
        NSComparisonResult priorityComparison = [_tcreds compare: priorityCost];
        if ([_adType isEqualToNumber: @1] && priorityComparison == NSOrderedAscending) {
    //        VTTShowAlertView(@"Insufficient TCredits", @"You do not have enough Tcredits to post Priority ad under this Section!", @"Ok");
            
            [[[UIAlertView alloc] initWithTitle: @"TCredits Insufficient" message: @"You do not have enough Tcredits to post Priority ad under the selected Category!." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
            
            return;
        }
    }
    
    if (nItemCost) {
        NSComparisonResult nItemComparison = [_tcreds compare: nItemCost];
        if ([_adType isEqualToNumber: @2] && nItemComparison == NSOrderedAscending){
    //        VTTShowAlertView(@"Insufficient TCredits", @"You do not have enough Tcredits to post New Item ad under this Section!", @"Ok");
            
            [[[UIAlertView alloc] initWithTitle: @"TCredits Insufficient" message: @"You do not have enough Tcredits to post New Item ad under the selected Category!." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
            
            return;
        }
        
        if ([_delegate respondsToSelector: @selector(sectionVC:didSelectedSection:withData:)]) {
            [_delegate sectionVC: self didSelectedSection: rowData[@"id"] withData: rowData[@"data"]];
        }
    }
    
    OSCategoryViewController *catVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSCategoryViewController"];
    catVC.delegate = self.delegate;
    catVC.cid = rowData[@"id"];
    catVC.categoryData = self.categoryData;
    [self.navigationController pushViewController: catVC animated: YES];
    
//    "Result": {
//        "Sections": [
//                     {"id" : "1",
//                     "data": {
//                        "title": "Bike Marketplace - Off-Road Bike Components",
//                        "newitem_cost": 2,
//                        "priority_cost": 4
//                     }},
//                     {"id" : "2",
//                     "data": {
//                         "title": "Bike Marketplace - Off-Road Bike Components",
//                         "newitem_cost": 2,
//                         "priority_cost": 4
//                     }}...
//                     ]
//    
//    {
//        "Result": {
//            "Category": [
//                         {"id": "7", "title": "Bike Accessories"},
//                         {"id": "11", "title": "Fitness & Training"},
//                         {"id": "12", "title": "Workshop"}
//            ]
//        }
//    }
//        
//        {
//            "Result": {
//                "Sub_category": [
//                                 {"id": "70", "title": "Bike Racks & Panniers"},
//                                 {"id": "71", "title": "Bottle Cages"},
//                                 {"id": "72", "title": "Car Racks"}
//                                 ...
//                ]
//            }
//        }
}

#pragma mark - UIAlertViewDelegate
-(void) openTCredsLink {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: self.data[@"TCredsLink"]]];
    
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = alertView.title;
    NSString *buttonTitle = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: @"TCredits Insufficient"]) {
        if ([buttonTitle isEqualToString: @"Buy TCredits"]) {
            [self openTCredsLink];
            [self.navigationController popViewControllerAnimated: YES];
        }
    }
}
@end

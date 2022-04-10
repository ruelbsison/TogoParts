//
//  OSSubCategoryViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSSubCategoryViewController.h"

@interface OSSubCategoryViewController ()
@property (nonatomic, strong) NSDictionary *data;
@end

@implementation OSSubCategoryViewController

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
    
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"top-back-button"]  target: self selector: @selector(backButtonClicked:)];
    
    NSDictionary *params = @{@"cid": _cid, @"gid": _gid};
    
    MBProgressHUD *hud = [OSHelpers showStandardHUDForView: self.view];
    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    [testManager GET: @"https://www.togoparts.com/iphone_ws/get-option-values.php?source=ios&subcat=1" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [OSHelpers hideStandardHUD: hud];
        self.data = responseObject[@"Result"];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [OSHelpers hideStandardHUD: hud];
    }];
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [OSHelpers sendGATrackerWithName: @"Marketplace Post Ad Sub Category"];
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
    return [self.data[@"Sub_category"] count];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    
    NSDictionary *rowData = self.data[@"Sub_category"][indexPath.row];
    
    UILabel *textLabel = (UILabel *) [cell viewWithTag: 2];
    textLabel.text = rowData[@"title"];
    
    if (self.categoryData && self.categoryData[@"sub_cat"]) {
        UIImageView *tickImage = (UIImageView *) [cell viewWithTag:1];
        if ([self.categoryData[@"sub_cat"] isEqualToNumber: rowData[@"id"]]) {
            tickImage.hidden = NO;
        }  else {
            tickImage.hidden = YES;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = self.data[@"Sub_category"][indexPath.row];
    if ([_delegate respondsToSelector: @selector(subCategoryVC:didSelectedSubCategory:)]) {
        [_delegate subCategoryVC: self didSelectedSubCategory: rowData[@"id"]];
    }
    
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
@end

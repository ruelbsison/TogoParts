//
//  OSCommentViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/7/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSCommentViewController.h"
#import "OSLabel.h"
#import "OSCommentCell.h"
#import "UITextView+VTTHelpers.h"

@interface OSCommentViewController ()

@end

@implementation OSCommentViewController

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
        _data = [NSArray new];
    }
    
    self.title = @"Comments";
    
    [self.tableView registerNib:[UINib nibWithNibName: @"OSCommentCell" bundle: nil] forCellReuseIdentifier:@"Cell"];
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"top-back-button"]  target: self selector: @selector(backButtonClicked:)];
    
    [self loadData];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [OSHelpers sendGATrackerWithName: @"Marketplace Ad Comments"];
}

-(void) loadData {
    MBProgressHUD *hud = [OSHelpers showStandardHUDForView: self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"aid": _aid};
    [manager GET:@"https://www.togoparts.com/iphone_ws/mp_ad_comments.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [OSHelpers hideStandardHUD: hud];
        NSLog(@"Get comments successfully");
        if (responseObject && responseObject[@"messages"]) {
            _data = responseObject[@"messages"];
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [OSHelpers hideStandardHUD: hud];
        NSLog(@"Get comments failed: %@ %@", operation.response, operation.request);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
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

#pragma mark - UITableViewdatasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath:indexPath];
    NSDictionary *rowData = _data[indexPath.row];
    [cell configureCellWithRowData: rowData];
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat padding = 44;
    NSDictionary *rowData = _data[indexPath.row];
    CGFloat height = [UITextView textViewHeightForText: rowData[@"message"] andWidth: 241.0f];
    return padding + height + 5;
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

//
//  OSPromosTableViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/15/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSPromosTableViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "OSPromosCell.h"

@interface OSPromosTableViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSArray *promos;
@end

@implementation OSPromosTableViewController

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
    OSChangeTogoFontForLabel(_titleLabel)
    
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"top-back-button"] target: self selector: @selector(backButtonClicked:)];
    }
    
    //Data
    _promos = [NSArray new];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = OSTogoTintColor;
    [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self loadData];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self.tableView reloadData];
    [OSHelpers sendGATrackerWithName: @"Bikeshop Promos"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

-(void) loadData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    [self.refreshControl beginRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
    NSString *url = [NSString stringWithFormat: @"http://www.togoparts.com/iphone_ws/bs_promos.php?source=ios&sid=%@", self.sid];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: url  parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Promos succeeded: %@", responseObject);
        if (responseObject && responseObject[@"scrtitle"]) {
            self.titleLabel.text = responseObject[@"scrtitle"];
        }
        if (responseObject && responseObject[@"list_promos"]) {
            _promos = responseObject[@"list_promos"];
            [self.tableView reloadData];
        }
        
        [hud hide: YES];
        [self.refreshControl endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Promos Failure response: %@", operation.response);
        NSLog(@"Error: %@", error.localizedDescription);
        
        TOGO_UNIVERSAL_ERROR_ALERT
        
        [hud hide: YES];
        [self.refreshControl endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _promos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSPromosCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *rowData = _promos[indexPath.row];
    
    cell.customTitleLabel.text = rowData[@"title"];
    if (VTTValidNSString(rowData[@"thumbnail"])) {
        [cell.customImageView setImageWithURL: [NSURL URLWithString: rowData[@"thumbnail"]] placeholderImage: [UIImage imageNamed: @"image112x112"]];
    } else {
        [cell.customImageView setImage: [UIImage imageNamed: @"No_Image-112x112"]];
    }
    cell.nameLabel.text = rowData[@"shopname"];
    cell.dateLabel.text = rowData[@"dateposted"];
    if (rowData[@"content"]) [cell.webView loadHTMLString: rowData[@"content"] baseURL: nil];
    cell.webView.delegate = self;
    return cell;
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView.scrollView flashScrollIndicators];
    webView.scrollView.showsVerticalScrollIndicator = YES;
    webView.scrollView.bounces = NO;
}
@end

//
//  OSMarketViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/17/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSMarketViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GoogleMobileAds/GoogleMobileAds.h"

#import "OSMarketCell.h"
#import "OSMarketHeaderCell.h"
#import "OSColorsPalette.h"
#import "OSListingViewController.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "OSAdDetailViewController.h"
#import "OSFeatureCell.h"

@interface OSMarketViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *categoryList;
//@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) DFPBannerView *bannerView;

@property (weak, nonatomic) IBOutlet DFPBannerView *headerBannerView;

@end

@implementation OSMarketViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


CONFIGURE_DFP_BANNER_AD

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.categoryList = [NSArray new];
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = OSTogoTintColor;
    [refreshControl addTarget:self action:@selector(updateCategoryList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
    [searchButton addTarget:self action: @selector(searchButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
    [searchButton setImage: [UIImage imageNamed: @"top-search-button"] forState: UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: searchButton];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self fetchCategoryList];
}

-(void) goToOSListingViewControllerWithParameterString: (NSString *) parameterString params: (NSDictionary *) params animated: (BOOL) animated {
    OSListingViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
    listVC.parameterString = parameterString;
    listVC.parameters = params;
    [self.navigationController pushViewController: listVC animated: animated];
}

-(void) goToAdDetailWithAID: (NSString *) aid animated: (BOOL) animated {
    OSAdDetailViewController *adDetailVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSAdDetailViewController"];
    adDetailVC.aid = aid;
    [self.navigationController pushViewController: adDetailVC animated: animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    OSAppDelegate *appDelegate = (OSAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *listParams;
    NSString *aid;
    if (appDelegate.listParameterString) {
        listParams = appDelegate.listParameterString;
        appDelegate.listParameterString = nil;
    } else if (appDelegate.aid) {
        aid = appDelegate.aid;
        appDelegate.listParameterString = nil;
    }
    if (listParams) {
        [self goToOSListingViewControllerWithParameterString: listParams params: NO animated: NO];
    } else if (aid) {
        [self goToAdDetailWithAID:aid animated: NO];
    }
    
    //Google Analytics
    [OSHelpers sendGATrackerWithName: @"Home"];
    
    //Configure Banner View
    //Dont need this anymore. Currently use headerBannerView instead
//    if (!_bannerView) {
//        _bannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
//        [self configureDFPBannerAd: _bannerView withId: DFP320x50_ID];
//        [self.tableView addSubview: _bannerView];
//        UIEdgeInsets inset = self.tableView.contentInset;
//        inset.bottom += _bannerView.frame.size.height;
//        self.tableView.contentInset = inset;
//    }
//    self.bannerView.frame = CGRectMake(0, self.tableView.contentOffset.y + self.tableView.frame.size.height - self.tableView.contentInset.bottom, _bannerView.frame.size.width, _bannerView.frame.size.height);
//    [self.tableView bringSubviewToFront: self.bannerView];
    
    [self configureDFPBannerAd: _headerBannerView withId:DFP_HOME_TOP_ID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) fetchCategoryList {
    
    //refresh DFP bannerView
    [_bannerView loadRequest: [GADRequest request]];
    [_headerBannerView loadRequest: [GADRequest request]];
    
//    [self.refreshControl beginRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: @"http://www.togoparts.com/iphone_ws/mp_list_categories.php?source=ios" parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject
            && [responseObject isKindOfClass: [NSDictionary class]]) {
            if (responseObject[@"grouplist"]) {
                self.categoryList = responseObject[@"grouplist"];
                [self.tableView reloadData];
            }
        }
        
        [hud hide: YES];
        [self.refreshControl endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response: %@", operation.responseObject);
        NSLog(@"Error: %@", error.localizedDescription);
        
        TOGO_UNIVERSAL_ERROR_ALERT
        
        [hud hide: YES];
        [self.refreshControl endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    }];
}
#pragma mark - Action

-(void) searchButtonClicked: (id) sender {
    [self.navigationController.tabBarController setSelectedIndex: TOGOSearchControllerIndex];
}

-(void) updateCategoryList {
    [self fetchCategoryList];
}

#pragma mark - UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.categoryList.count == 0) {
    } else {
        self.tableView.separatorColor = OSTableViewSeparator;
    }
    return self.categoryList.count;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSArray *category = self.categoryList[section][@"categories"];
    if (category) {
        NSArray *featured = self.categoryList[section][@"featured"];
        if (featured) {
            return category.count + 1;
        } else {
            return category.count;
        }
    }
    return 0;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
         NSArray *featured = self.categoryList[indexPath.section][@"featured"];
        if (featured && featured.count != 0) {
            return 130;
        } else {
            return 0;
        }
    }
    
    if (!VTTOSLessThan7) {
        NSString *stringText = _categoryList[indexPath.section][@"categories"][indexPath.row - 1][@"description"];
        //Here you can change the font to your req. font.
        UIFont * ft = [UIFont systemFontOfSize:12.0];
        
        CGSize labelSize = CGSizeMake(200, 0);
        
        CGRect labelRect = [stringText boundingRectWithSize: labelSize options: NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: ft} context:Nil];
        
        CGFloat height = 32 + labelRect.size.height;
        if (height < 80) height = 80;
        if (height > 120) height = 120;
        return height;
    }
    return 130;
    
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    if (indexPath.row == 0){
        NSArray *featured = self.categoryList[indexPath.section][@"featured"];
        if (featured) {
            OSFeatureCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"FeatureCell" forIndexPath: indexPath];
            cell.collectionView.tag = indexPath.section;
            cell.collectionView.dataSource = self;
            cell.collectionView.delegate = self;
            [cell.collectionView reloadData];
            return cell;
        } else {
            
        }
    }

    
    OSMarketCell *cell = [tableView dequeueReusableCellWithIdentifier: @"OSMarketCell"];
    NSDictionary *data = _categoryList[indexPath.section][@"categories"][indexPath.row - 1];
    if (data) {
        cell.titleLabel.text = data[@"title"];
        cell.descriptionLabel.text = data[@"description"];
        cell.totalAdsLabel.text = [NSString stringWithFormat: @"%@ Ads", data[@"total_ads"]];
    }
    return cell;
}
#pragma mark - UITableViewDelegate
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"MarketSectionHeader";
    OSMarketHeaderCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    headerView.titleLabel.text = _categoryList[section][@"title"];
    headerView.browseButton.tag = section;
    [headerView.browseButton addTarget: self action: @selector(headerBrowseButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
    if (!_categoryList[section][@"gid"] || [_categoryList[section][@"gid"] isEqualToString: @""]) {
        headerView.browseButton.hidden = YES;
    } else {
        headerView.browseButton.hidden = NO;
    }
    
    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return headerView;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 53;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData =_categoryList[indexPath.section][@"categories"][indexPath.row - 1];
    NSDictionary *parameters;
    NSString *parameterString;
    NSLog(@"row data: %@", rowData);
    if (!rowData[@"cid"] || [rowData[@"cid"] isEqualToString: @""]) {
        parameterString = rowData[@"parameters"];
    } else {
        NSString *cid = rowData[@"cid"];
        parameters = @{@"cid": cid};
    }
    
    OSListingViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
    listVC.parameters = parameters;
    listVC.parameterString = parameterString;
    [self.navigationController pushViewController: listVC animated: YES];
}
-(void) headerBrowseButtonClicked: (UIButton *) button {
    NSString *gid = _categoryList[button.tag][@"gid"];
    NSString *params =  _categoryList[button.tag][@"categories"][0][@"parameters"];
    NSDictionary *parameters;
    if (gid && ![gid isEqualToString: @""]) {
        parameters = @{@"gid": gid};
    } else if (params) {
        //TODO: deprecated
        parameters = @{@"parameters": params};
    }
    
    OSListingViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
    listVC.parameters = parameters;
    [self.navigationController pushViewController: listVC animated: YES];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.tableView) {
//        self.bannerView.frame = CGRectMake(0, scrollView.contentOffset.y + self.tableView.frame.size.height - self.tableView.contentInset.bottom, _bannerView.frame.size.width, _bannerView.frame.size.height);
//    }
}

#pragma mark - UICollectionViewDelegate
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *featured = self.categoryList[collectionView.tag][@"featured"];
    if (featured) {
        return featured.count;
    } else {
        return 0;
    }
}
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *) [cell viewWithTag: 1];
    UILabel *price = (UILabel *) [cell viewWithTag: 2];
    UILabel *title = (UILabel *) [cell viewWithTag: 3];
    NSDictionary *rowData = self.categoryList[collectionView.tag][@"featured"][indexPath.row];
//                 {
//                     "aid": 723895,
//                     "title": "Feedback Sports Pro Elite",
//                     "price": "$399",
//                     "picture": "http://www.togoparts.com/marketplace/uploads/thumb-adpic1-1406108122-59439.jpg"
//                 },
    if (VTTValidNSString(rowData[@"picture"])) {
        [imageView setImageWithURL: [NSURL URLWithString: rowData[@"picture"]] placeholderImage: nil];
    } else {
        [imageView setImage: nil];
    }
    
    price.text = rowData[@"price"];
    title.text = rowData[@"title"];
    
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = self.categoryList[collectionView.tag][@"featured"][indexPath.row];
    NSString *aid = rowData[@"aid"];
    
    if (aid) {
        OSAdDetailViewController *adDetailVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSAdDetailViewController"];
        adDetailVC.aid = aid;
        adDetailVC.showSearchButton = YES;
        [self.navigationController pushViewController: adDetailVC animated: YES];
    }
}
@end

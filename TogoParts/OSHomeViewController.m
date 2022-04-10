//
//  OSHomeViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/17/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSHomeViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "OSHomeCell.h"
#import "OSHomeHeaderView.h"
#import "OSAdDetailViewController.h"

#import "GoogleMobileAds/GoogleMobileAds.h"
//#import "DFPBannerView.h"
//#import "DFPInterstitial.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface OSHomeViewController ()
@property (nonatomic, strong) NSArray *latestAds;
@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) DFPBannerView *dfpBannerView;
@end

@implementation OSHomeViewController

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
    
    self.latestAds = [NSArray new];
    
//    self.orangeHeader.font = [UIFont fontWithName: OSTogoFontName size: self.orangeHeader.font.pointSize];
//    self.orangeHeader.text = @"LATEST ADS SINGAPORE";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = OSTogoTintColor;
    [refreshControl addTarget:self action:@selector(loadDatas) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview: refreshControl];
    
//    [self loadDatas];
    
	// Do any additional setup after loading the view.
    UIButton *searchButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
    [searchButton addTarget:self action: @selector(searchButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
    [searchButton setImage: [UIImage imageNamed: @"top-search-button"] forState: UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: searchButton];
}


-(void) loadDatas {
    //refresh DFP bannerView
    [_dfpBannerView loadRequest: [GADRequest request]];
    
    [self.refreshControl beginRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://www.togoparts.com/iphone_ws/mp_list_latest_ads.php?source=ios" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        if (responseObject && [responseObject isKindOfClass: [NSDictionary class]]) {
            NSDictionary *data = responseObject;
            if (data[@"ads"]) {
                self.latestAds = data[@"ads"];
                self.headerTitle = data[@"title"];
                [self.collectionView reloadData];
            }
        }
        
        [hud hide: YES];
        [self.refreshControl endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Response: %@", operation.response);
        NSLog(@"Error: %@", error);
        
        TOGO_UNIVERSAL_ERROR_ALERT
        
        [hud hide: YES];
        [self.refreshControl endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    }];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self loadDatas];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    //Google Analytics
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set: kGAIScreenName value:@"Home"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    UIImage *backImage = [UIImage imageNamed: @"top-back-button"];
    UIButton *plainButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [plainButton setImage: backImage forState: UIControlStateNormal];
    [plainButton addTarget: self.navigationController action: @selector(popViewControllerAnimated:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:plainButton];
    self.navigationItem.backBarButtonItem = customItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
-(void) searchButtonClicked: (id) sender {
    [self.navigationController.tabBarController setSelectedIndex: TOGOSearchControllerIndex];
}


#pragma mark - UICollectionViewDatasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _latestAds.count;
}
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OSHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"OSHomeCell" forIndexPath: indexPath];
    
     NSDictionary *data = self.latestAds[indexPath.row];
    
    cell.timeLabel.text = data[@"timeposted"];
    cell.priceLabel.text = data[@"price"];
    cell.titleLabel.text = data[@"title"];
    cell.userLabel.text = data[@"postedby"];
    if (data[@"picture"] && ![data[@"picture"] isEqualToString: @""]) {
        [cell.mainImageView setImageWithURL: [NSURL URLWithString: data[@"picture"]] placeholderImage: [UIImage imageNamed: @"image264x216"]];
    } else {
        [cell.mainImageView setImage: [UIImage imageNamed: @"No_Image-264x216"]];
    }
    
    return cell;
}

-(UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        OSHomeHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"OSHomeHeaderView" forIndexPath: indexPath];
        headerView.titleLabel.text = _headerTitle;
        if (_latestAds.count <= 0) {
            headerView.titleBackground.hidden = YES;
        } else {
            headerView.titleBackground.hidden = NO;
        }
        [self configureDFPBannerAd: headerView.bannerView withId:DFP_HOME_TOP_ID];
        return headerView;
    }
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemData = _latestAds[indexPath.item];
    NSString *aid = itemData[@"aid"];
    
    OSAdDetailViewController *adDetailVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSAdDetailViewController"];
    adDetailVC.aid = aid;
    [self.navigationController pushViewController: adDetailVC animated: YES];
}

@end

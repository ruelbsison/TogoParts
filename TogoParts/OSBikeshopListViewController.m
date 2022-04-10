//
//  OSBikeshopListViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/10/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSBikeshopListViewController.h"
#import "OSBikeshopCell.h"
#import "OSNonpaidBSCell.h"
#import "OSAdCell.h"
#import "OSBikeshopSearchViewController.h"
#import "OSBikeshopDetailViewController.h"
#import "OSPromosTableViewController.h"
#import "OSListingViewController.h"
//#import "GADAdSize.h"

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "OSMapViewController.h"


@import MapKit;

@interface OSBikeshopListViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *data;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic) BOOL isLoadingNewPage;

@property (nonatomic) NSInteger pageNo;
@property (nonatomic) NSInteger prevPageNo;
@property (nonatomic) NSInteger totalPages;
@property (nonatomic) NSInteger totalAds;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;
@end

@implementation OSBikeshopListViewController

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
    //General
    OSChangeTogoFontForLabel(_titleLabel);
    
    if (!_isSearch)   {
        self.navigationItem.rightBarButtonItem = [OSHelpers searchBarButtonWithTarget: self action: @selector(searchButtonClicked:)];
    }else {
        if (!_fromMap)
        self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"map-icon"] target: self selector: @selector(mapButtonClicked:)];
        self.titleLabel.text = @"Search Results";
    }
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"top-back-button"] target: self selector: @selector(backButtonClicked:)];
    }  else {
        if (!_fromMap)
        self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"map-icon"] target: self selector: @selector(mapButtonClicked:)];
    }
    
    //Data
    self.pageNo = 1;
    self.prevPageNo = 0;
    self.totalPages = 0;
    self.totalAds = 0;
    self.isLoadingNewPage = YES;
    
    self.data = [NSMutableDictionary new];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = OSTogoTintColor;
    [refreshControl addTarget:self action:@selector(pulledToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
//    [self loadData];
    
    //Location manager
    
    _locationManager = [[CLLocationManager alloc] init];
    if (!VTTOSLessThan8) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.delegate= self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter=kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) goToBikeShopDetailWithSid: (NSString *) sid animated: (BOOL) animated{
    OSBikeshopDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSBikeshopDetailViewController"];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"sid"] = sid;
    if (_userLocation) {
        parameters[@"lat"] = @(_userLocation.coordinate.latitude);
        parameters[@"long"] = @(_userLocation.coordinate.longitude);
    }
    detailVC.parameters = parameters;
    [self.navigationController pushViewController: detailVC animated: animated];
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    OSAppDelegate *appDelegate = (OSAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appDelegate.sid) {
        NSString *sid = appDelegate.sid;
        appDelegate.sid = nil;
        [self goToBikeShopDetailWithSid: sid animated: NO];
    }
    
    if (_isSearch) {
        [OSHelpers sendGATrackerWithName: @"Bikeshop Search Result"];
    } else {
        [OSHelpers sendGATrackerWithName: @"Bikeshop Listing"];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    _userLocation = newLocation;
    if (!oldLocation) {
        [self loadData];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self loadData];
}

#pragma mark - Actions
-(void) searchButtonClicked: (id) sender {
    OSBikeshopSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSBikeshopSearchViewController"];
    [self.navigationController pushViewController: searchVC animated: YES];
}

-(void) mapButtonClicked: (id) sender {
    OSMapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSMapViewController"];
//    mapVC.data = self.data;
//    self.delegate = mapVC;
    if (_isSearch || _parameters) {
        mapVC.parameters = _parameters;
        mapVC.isSearch = _isSearch;
        mapVC.fromList = YES;
    }
    [self.navigationController pushViewController: mapVC animated: YES];
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

-(void) pulledToRefresh {
    if (_isSearch) {
        [OSHelpers sendGATrackerWithName: @"Bikeshop Search Result Pull Refresh"];
    } else {
        [OSHelpers sendGATrackerWithName: @"Bikeshop Listing Pull Refresh"];
    }
    
    
    [self updateListing];
}

-(void) updateListing {
    //refresh DFP bannerView
//    [_bannerView loadRequest: [GADRequest request]];
    
    self.pageNo = 1;
    self.prevPageNo = 0;
    self.totalAds = 0;
    self.totalPages = 0;
    
    [self loadData];
}


-(void) showNoValue {
    [self.refreshControl endRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    //    [_activityIndicator stopAnimating];
    //    self.activityIndicator.hidden = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (!self.noDataLabel) {
        self.noDataLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width,  44)];
        self.noDataLabel.backgroundColor = [UIColor clearColor];
        self.noDataLabel.textAlignment = NSTextAlignmentCenter;
//        if (_isShortList) {
//            self.noDataLabel.text = @"You have no shortlisted ads";
//        } else {
            self.noDataLabel.text = @"No result found";
//        }
        [self.view addSubview: _noDataLabel];
    }
    self.noDataLabel.hidden = NO;
}

-(void) hideNoValue {
    self.noDataLabel.hidden = YES;
}


-(void) loadData {
    //Canonical: http://www.togoparts.com/iphone_ws/bs_listings.php?shopsearch=&country=&area=&open=&mechanic=&page_id=
    NSString *url = [NSString stringWithFormat: @"http://www.togoparts.com/iphone_ws/bs_listings.php?source=ios&v=1.2&app=free&page_id=%zd", self.pageNo];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (self.userLocation) {
        parameters[@"lat"] = @(_userLocation.coordinate.latitude);
        parameters[@"long"] = @(_userLocation.coordinate.longitude);
        NSLog(@"user lat: %@, long: %@", parameters[@"lat"], parameters[@"long"]);
    }
    
    if (_parameters) {
        [parameters addEntriesFromDictionary: _parameters];
    }
    
    [self hideNoValue];
    
    self.isLoadingNewPage = YES;
    MBProgressHUD *hud;
    if (self.pageNo <= 1) {
        hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [OSHelpers padellingImageView];
    }
    
    __weak OSBikeshopListViewController *weakSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: url  parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"url: %@", operation.request.URL);
//        NSLog(@"response object: %@", responseObject);
        if (self.pageNo > self.prevPageNo) {
            NSLog(@"pageNo: %zd prePageNo: %zd", self.pageNo, self.prevPageNo);
            
            NSInteger prevAdsCount;
            
            NSMutableArray *ads = [[NSMutableArray alloc] initWithArray: weakSelf.data[@"bikeshoplist"]];
            weakSelf.data = [[NSMutableDictionary alloc] initWithDictionary: responseObject];
            
            if (self.pageNo == 1) {
                ads = [NSMutableArray new]; //Refresh data by deleting all old data
                prevAdsCount = 0;
            } else {
                prevAdsCount = ads.count;
            }
            if (![[NSNull null] isEqual: responseObject[@"bikeshoplist"]] && responseObject[@"bikeshoplist"] && [responseObject[@"bikeshoplist"] count] > 0)
                [ads addObjectsFromArray: responseObject[@"bikeshoplist"]];
            weakSelf.data[@"bikeshoplist"] = ads;
            
//            if (!weakSelf.isSearch) {
                //Because the title doesn't apply to search
//                weakSelf.titleLabel.text = weakSelf.data[@"title"];
//            }
            //                    ,"page_details":{"page_id":"2","no_of_pages":100,"total_ads":1597}}
            weakSelf.prevPageNo = weakSelf.pageNo;
            weakSelf.totalPages = [weakSelf.data[@"page_details"][@"no_of_pages"] integerValue];
//            weakSelf.totalAds = [weakSelf.data[@"page_details"][@"total_ads"] integerValue];
            
            [weakSelf.tableView reloadData];
            if (prevAdsCount > 0)
                [weakSelf.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: prevAdsCount inSection: 0] atScrollPosition:UITableViewScrollPositionBottom animated: YES];
            
            if ([weakSelf.data[@"bikeshoplist"] count] <= 0 && _pageNo == 1) {
                [self showNoValue];
            }
            
            self.isLoadingNewPage = NO;
            if (_pageNo < _totalPages) {
                [self scrollViewDidScroll: self.tableView];
            }
            if (_pageNo == 2) {
                if (_isSearch) {
                    [OSHelpers sendGATrackerWithName: @"Bikeshop Search Result More"];
                } else {
                    [OSHelpers sendGATrackerWithName: @"Bikeshop Listing More"];
                }
            }
        }
        
        if ([weakSelf.delegate respondsToSelector: @selector(bikeshopList:didLoadData:)]) {
            [weakSelf.delegate bikeshopList: weakSelf didLoadData: weakSelf.data];
        }
        
        [hud hide: YES];
        [self.refreshControl endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Search Failure response: %@", operation.response);
        NSLog(@"Error: %@", error.localizedDescription);
        
        TOGO_UNIVERSAL_ERROR_ALERT
        
        [hud hide: YES];
        [self.refreshControl endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    }];
}

#pragma mark - UITableViewDatasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *listing = _data[@"bikeshoplist"];
    if (listing) {
        if (listing.count > 0) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            self.tableView.separatorColor = OSTableViewSeparator;
        }
        if (self.pageNo < self.totalPages) {
            return listing.count + 1;
        } else {
            return listing.count;
        }
    }
    return 0;
}
-(void) promosButtonClicked: (UIButton *) sender {
    NSDictionary *rowData = _data[@"bikeshoplist"][sender.tag];
    OSPromosTableViewController *promosVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSPromosTableViewController"];
    promosVC.sid = rowData[@"sid"];
    [self.navigationController pushViewController: promosVC animated: YES];
}
-(void) nItemButtonClicked: (UIButton *) sender {
    NSDictionary *rowData = _data[@"bikeshoplist"][sender.tag];
    OSListingViewController *nItemVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
    nItemVC.parameters = @{@"sid" : rowData[@"sid"]};
    nItemVC.isSearch = YES;
    nItemVC.isFromBikeShop = YES;
    [self.navigationController pushViewController: nItemVC animated: YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [_data[@"bikeshoplist"] count]) {
        NSDictionary *rowData = _data[@"bikeshoplist"][indexPath.row];
        if (rowData[@"pinad"]) {
//            "pinad":{
//                "unit_id":"\/4689451\/iOS320x100_b",
//                "unit_width":320
//                "unit_height":100
//            }
            
            OSAdCell *cell = [tableView dequeueReusableCellWithIdentifier: @"AdCell" forIndexPath: indexPath];
            DFPBannerView *gAdView = cell.bannerView;
            
            //Add valid size
            CGSize size = CGSizeMake([rowData[@"pinad"][@"unit_width"] floatValue], [rowData[@"pinad"][@"unit_height"] floatValue]);
            GADAdSize size1 = GADAdSizeFromCGSize(size);
            NSMutableArray *validSizes = [NSMutableArray array];
            [validSizes addObject:[NSValue valueWithBytes:&size1 objCType:@encode(GADAdSize)]];
            gAdView.validAdSizes = validSizes;
            
//            GADAdSize customAdSize = GADAdSizeFromCGSize(size);
//            gAdView = [[DFPBannerView alloc] initWithAdSize:customAdSize];
//            [cell addSubview: gAdView];

            //request
            gAdView.adUnitID = rowData[@"pinad"][@"unit_id"];
            gAdView.rootViewController = self;
            GADRequest *request = [GADRequest request];
            //            request.testDevices = @[ @"ff9a123840ce15490b9e7015cdae83bf", GAD_SIMULATOR_ID ];
            [gAdView loadRequest: request];
            
            return cell;
        }
        if (rowData[@"forpaidonly"] && [rowData[@"forpaidonly"] count] > 0)  {
            //Paid cell
            OSBikeshopCell *cell = [tableView dequeueReusableCellWithIdentifier: @"PaidCell" forIndexPath: indexPath];
            cell.customTitleLabel.text = rowData[@"shopname"];
            [cell.logoImageView setImageWithURL: [NSURL URLWithString: rowData[@"shoplogo"]] placeholderImage: [UIImage imageNamed: @""]];
            //Shop logo
            if (rowData[@"shoplogo"] && ![rowData[@"shoplogo"] isEqualToString: @""]) {
                [cell.logoImageView setImageWithURL: [NSURL URLWithString: rowData[@"shoplogo"]] placeholderImage: [UIImage imageNamed: @"image112x112"]];
            } else {
                [cell.logoImageView setImage: [UIImage imageNamed: @"No_Image-112x112"]];
            }
            
            if (VTTValidNSString(rowData[@"address"])) cell.addressLabel.text = rowData[@"address"];
            if (VTTValidNSString(rowData[@"distance"])) {
                cell.distanceLabel.text = rowData[@"distance"];
                cell.distanceLabel.hidden = NO;
                cell.distanceIcon.hidden = NO;
            } else {
                cell.distanceLabel.hidden = YES;
                cell.distanceIcon.hidden = YES;
            }
            
            //For Paid only
            NSDictionary *forPaidOnly = rowData[@"forpaidonly"];
            
            //Shop photo
            if (VTTValidNSString(forPaidOnly[@"shopphoto"])) {
                cell.photoImageView.hidden = NO;
                [cell.photoImageView setImageWithURL: [NSURL URLWithString: forPaidOnly[@"shopphoto"]] placeholderImage: [UIImage imageNamed: @"image112x112"]];
            } else {
                //                [cell.photoImageView setImage: [UIImage imageNamed: @"No_Image-112x112"]];
                cell.photoImageView.hidden = YES;
            }
            
            //Open Label
            if (forPaidOnly && VTTValidNSString(forPaidOnly[@"openlabel"])) {
                cell.openBackground.hidden = NO;
                if ([forPaidOnly[@"openlabel"] compare: @"closed now" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
                    cell.openBackground.backgroundColor = [UIColor colorWithRed:0.901961 green:0.901961 blue:0.901961 alpha:1];
                    cell.openLabel.textColor = [UIColor blackColor];
                } else {
                    cell.openBackground.backgroundColor = OSGreenColor;
                    cell.openLabel.textColor = [UIColor whiteColor];
                }
                NSMutableAttributedString *openAttr = [[NSMutableAttributedString alloc] initWithString: forPaidOnly[@"openlabel"] attributes: @{NSFontAttributeName: [UIFont fontWithName: OSTogoFontName size: 12]}];
                NSMutableAttributedString *remarksAttr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @"\n%@", forPaidOnly[@"remarks"]] attributes: @{NSFontAttributeName: [UIFont fontWithName: OSTogoFontName size: 10]}];
                NSMutableAttributedString *finalOpenAttr = [[NSMutableAttributedString alloc] initWithAttributedString: openAttr];
                [finalOpenAttr appendAttributedString: remarksAttr];
                cell.openLabel.attributedText = finalOpenAttr;
            } else {
                cell.openBackground.hidden = YES;
            }

            
            //New items
            if (forPaidOnly[@"new_item_ads"] && [forPaidOnly[@"new_item_ads"] integerValue] != 0){
                cell.nItemButton.enabled = YES;
            } else {
                cell.nItemButton.enabled = NO;
            }
            cell.nItemLabel.text = [NSString stringWithFormat: @"NEW ITEM ADS (%@)", forPaidOnly[@"new_item_ads"]];
            cell.nItemButton.tag = indexPath.row;
            [cell.nItemButton addTarget: self action: @selector(nItemButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
            
            //Promos
            if (forPaidOnly[@"promos"] && [forPaidOnly[@"promos"] integerValue] != 0){
                cell.promosButton.enabled = YES;
            } else {
                cell.promosButton.enabled = NO;
            }
            cell.promosLabel.text = [NSString stringWithFormat: @"PROMOS (%@)", forPaidOnly[@"promos"]];
            cell.promosButton.tag = indexPath.row;
            [cell.promosButton addTarget: self action: @selector(promosButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
            
            return cell;
        } else {
            //non-paid cell
            OSNonpaidBSCell *cell = [tableView dequeueReusableCellWithIdentifier: @"NonePaidCell" forIndexPath: indexPath];
            cell.customTitleLabel.text = rowData[@"shopname"];
            cell.addressTextView.text = rowData[@"address"];
            
            return cell;
        }
    } else {
        /******************
         Load More row
         ********************/
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"OSListingFooterCell"];
        //        UIButton *loadMoreButton  = (UIButton *) [cell viewWithTag: 100];
        //        [loadMoreButton addTarget: self action: @selector(loadMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *) [cell viewWithTag: 1];
        [activityIndicator startAnimating];
        return cell;
    }
}

-(void) loadMore {
    self.pageNo += 1;
    
//    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    if (_isSearch) {
//        [tracker set: kGAIScreenName value:@"Marketplace Search Result More"];
//    } else if (_isShortList) {
//        //        [tracker set: kGAIScreenName value:@"Marketplace Shortlisted Ads"];
//    } else {
//        [tracker set: kGAIScreenName value:@"Marketplace List Ads By Category More"];
//    }
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self loadData];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_data[@"bikeshoplist"] count]) {
        NSDictionary *rowData = _data[@"bikeshoplist"][indexPath.row];
        if (rowData[@"pinad"]) {
            //do nothing
        } else {
            [self goToBikeShopDetailWithSid: rowData[@"sid"] animated: YES];
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_data[@"bikeshoplist"] count]) {
        NSDictionary *rowData = _data[@"bikeshoplist"][indexPath.row];
        if (rowData[@"pinad"]) {
            return [rowData[@"pinad"][@"unit_height"] floatValue];
        }
         if (rowData[@"forpaidonly"] && [rowData[@"forpaidonly"] count] > 0)  {
             return 140;
         } else {
             return 85;
         }
    } else {
        return 50;
    }
}


-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
//        self.bannerView.frame = CGRectMake(0, scrollView.contentOffset.y + self.tableView.frame.size.height - self.tableView.contentInset.bottom, _bannerView.frame.size.width, _bannerView.frame.size.height);
        if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
            if (!self.isLoadingNewPage && self.pageNo < self.totalPages) {
                self.isLoadingNewPage = YES;
                [self loadMore];
            }
        }
    }
}
@end

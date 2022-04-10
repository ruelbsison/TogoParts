//
//  OSListingViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/20/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSListingViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "UIColor+VTTHelpers.h"
#import "OSListingCell.h"

#import "OSAdDetailViewController.h"
#import "OSSearchViewController.h"

#import "GoogleMobileAds/GoogleMobileAds.h"
//#import "DFPBannerView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "OSAdCell.h"

@interface OSListingViewController () <OSSearchViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) DFPBannerView *bannerView;

@property (nonatomic) NSInteger pageNo;
@property (nonatomic) NSInteger prevPageNo;
@property (nonatomic) NSInteger totalPages;
@property (nonatomic) NSInteger totalAds;

@property (nonatomic) BOOL isLoadingNewPage;

@property (nonatomic, strong) UIButton *editButton;
@end

@implementation OSListingViewController

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
    
    if (_isSearch) {
        self.title = @"Search Results";
        if (_showFilterButton) {
            UIButton *filterButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
            [filterButton addTarget:self action: @selector(filterButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
            [filterButton setImage: [UIImage imageNamed: @"filter-icon"] forState: UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: filterButton];
        }
    } else {
        if (_isShortList) {
            self.editButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
            [_editButton addTarget:self action: @selector(editButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
            [_editButton setImage: [UIImage imageNamed: @"edit"] forState: UIControlStateNormal];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: _editButton];
        }
        
        UIButton *searchButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
        [searchButton addTarget:self action: @selector(searchButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        [searchButton setImage: [UIImage imageNamed: @"top-search-button"] forState: UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: searchButton];
    }
    
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
        [backButton addTarget:self action: @selector(backButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        [backButton setImage: [UIImage imageNamed: @"top-back-button"] forState: UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    }
    
    if (!_isShortList)    [self updateListing];
    
//    [self.tableView registerNib: [UINib nibWithNibName: @"OSListingCell" bundle: nil] forCellReuseIdentifier: @"OSListingCell"];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    if (_isShortList) {
        self.title = @"Shortlisted Ads";
        [self updateListing];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    //Google Analytics
    
    if (_isFromBikeShop) {
        [OSHelpers sendGATrackerWithName: @"Marketplace List Ads by Bikeshop"];
    } else {
        id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        if (_isSearch) {
            [tracker set: kGAIScreenName value:@"Marketplace Search Result"];
        } else if (_isShortList) {
            [tracker set: kGAIScreenName value:@"Marketplace Shortlisted Ads"];
        } else {
            [tracker set: kGAIScreenName value:@"Marketplace List Ads By Category"];
        }
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
    
    //Configure Banner View
    if (!_bannerView) {
        _bannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        [self configureDFPBannerAd: _bannerView withId: DFP320x50_ID];
        [self.tableView addSubview: _bannerView];
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.bottom += _bannerView.frame.size.height;
        self.tableView.contentInset = inset;
    }
    
    self.bannerView.frame = CGRectMake(0, self.tableView.contentOffset.y + self.tableView.frame.size.height - self.tableView.contentInset.bottom, _bannerView.frame.size.width, _bannerView.frame.size.height);
    [self.tableView bringSubviewToFront: self.bannerView];
}

#pragma mark - Actions
-(void) pulledToRefresh {
    if (_isFromBikeShop) {
        [OSHelpers sendGATrackerWithName: @"Marketplace List Ads by Bikeshop Pull Refresh"];
    }
    [self updateListing];
}
-(void) updateListing {
    //refresh DFP bannerView
    [_bannerView loadRequest: [GADRequest request]];
    
    self.pageNo = 1;
    self.prevPageNo = 0;
    self.totalAds = 0;
    self.totalPages = 0;
    
    [self loadDatas];
}

-(void) searchButtonClicked: (id) sender {
    [self.navigationController.tabBarController setSelectedIndex: TOGOSearchControllerIndex];
}
-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}
-(void) editButtonClicked: (id) sender {
    self.editing = !self.editing;

    if (self.editing) {
        [_editButton setImage: [UIImage imageNamed: @"apply-icon"] forState: UIControlStateNormal];
    } else {
        [_editButton setImage: [UIImage imageNamed: @"edit"] forState: UIControlStateNormal];
    }
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
        if (_isShortList) {
            self.noDataLabel.text = @"You have no shortlisted ads";
        } else {
            self.noDataLabel.text = @"No result found";
        }
        [self.view addSubview: _noDataLabel];
    }
    self.noDataLabel.hidden = NO;
}

-(void) hideNoValue {
    self.noDataLabel.hidden = YES;
}

-(void) loadDatas {
    __weak OSListingViewController *weakSelf = self;
    
    if (!_isShortList) {
        
        /*********************
         Search or normal listing
         *********************/
        
        if (_parameters || _parameterString) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
//            [self.refreshControl beginRefreshing];
            [self hideNoValue];
            NSString *url = [NSString stringWithFormat: @"http://www.togoparts.com/iphone_ws/mp_list_ads.php?v=1.2.4&source=ios&app=free&page_id=%zd", self.pageNo];
            if (_parameterString) url = [NSString stringWithFormat: @"%@&%@", url, _parameterString];
            
            self.isLoadingNewPage = YES;
            MBProgressHUD *hud;
            if (self.pageNo <= 1) {
                hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [OSHelpers padellingImageView];
            }
            
            //Check if parameters has dynamic paramters
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager GET: url  parameters: _parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSLog(@"Success search: %@", responseObject);
                NSLog(@"url: %@", operation.request.URL);
                if (self.pageNo > self.prevPageNo) {
                    NSLog(@"pageNo: %zd prePageNo: %zd", self.pageNo, self.prevPageNo);
                    
                    NSInteger prevAdsCount;
    
                    NSMutableArray *ads = [[NSMutableArray alloc] initWithArray: weakSelf.data[@"ads"]];
                    weakSelf.data = [[NSMutableDictionary alloc] initWithDictionary: responseObject];
                    
                    if (self.pageNo == 1) {
                        ads = [NSMutableArray new]; //Refresh data by deleting all old data
                        prevAdsCount = 0;
                    } else {
                        prevAdsCount = ads.count;
                    }
                    if (responseObject[@"ads"] && [responseObject[@"ads"] count] > 0)
                        [ads addObjectsFromArray: responseObject[@"ads"]];
                    weakSelf.data[@"ads"] = ads;

                    if (!weakSelf.isShortList && !weakSelf.isSearch) {
                        //Because the title doesn't apply to shortlist and search
                        weakSelf.title = weakSelf.data[@"title"];
                    }
//                    ,"page_details":{"page_id":"2","no_of_pages":100,"total_ads":1597}}
                    weakSelf.prevPageNo = weakSelf.pageNo;
                    weakSelf.totalPages = [weakSelf.data[@"page_details"][@"no_of_pages"] integerValue];
                    weakSelf.totalAds = [weakSelf.data[@"page_details"][@"total_ads"] integerValue];
                    
                    [weakSelf.tableView reloadData];
                    if (prevAdsCount > 0)
                        [weakSelf.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: prevAdsCount inSection: 0] atScrollPosition:UITableViewScrollPositionBottom animated: YES];
                    
                    if ([weakSelf.data[@"ads"] count] <= 0 && _pageNo == 1) {
                        [self showNoValue];
                    }
                    
                    self.isLoadingNewPage = NO;
                    
                    if (weakSelf.pageNo == 2) {
                        if (weakSelf.isFromBikeShop) {
                            [OSHelpers sendGATrackerWithName: @"Marketplace List Ads by Bikeshop More"];
                        }
                    }
                    
                    [hud hide: YES];
                }
                
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
    } else {
        
    /*********************
        Short list
     *********************/
        
        NSArray *shortLists = [[NSUserDefaults standardUserDefaults] arrayForKey: @"ToGoShortList"];
        NSLog(@"shortlists : %@", shortLists);
        if (!shortLists || shortLists.count <= 0) {
            [self showNoValue];
        } else {
            
//            _parameters = @{@"aid": shortLists};
            //http://www.togoparts.com/iphone_ws/mp_shortlist_ads.php?aid=668742+668075+668380
            NSMutableString *string = [NSMutableString stringWithString: @"http://www.togoparts.com/iphone_ws/mp_shortlist_ads.php?source=ios&aid="];
            for (NSInteger i=0; i < shortLists.count; i++) {
                NSString *aid = shortLists[i];
                if (i != shortLists.count - 1) {
                    [string appendFormat: @"%@+",aid];
                } else {
                    [string appendString: aid];
                }
            }
            
            [self.refreshControl endRefreshing];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
            [self hideNoValue];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [OSHelpers padellingImageView];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager GET: string parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"operation response %@", operation.response);
                NSLog(@"Success search: %@", responseObject);
                weakSelf.data = responseObject;
                NSArray *ads = responseObject[@"ads"];
                
                // Update Shortlist in UserDefaults
                NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet new];
                for (NSDictionary *adDetails in ads) {
                    [orderedSet addObject: adDetails[@"aid"]];
                }
                NSArray *shortListArray = [orderedSet array];
                [[NSUserDefaults standardUserDefaults] setObject: shortListArray forKey: @"ToGoShortList"];
                
                if (ads.count <= 0) {
                    [weakSelf showNoValue];
                } else {
                    weakSelf.title = weakSelf.data[@"title"];
                    [weakSelf.tableView reloadData];
                }
                
                [hud hide: YES];
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
    }
}

-(void) filterButtonClicked: (id) sender {
    OSSearchViewController *filterVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSSearchViewController"];
    filterVC.delegate = self;
    filterVC.searchParams = _parameters;
    [self.navigationController pushViewController: filterVC animated: YES];
}
#pragma mark - UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *listing = _data[@"ads"];
    if (listing) {
        if (listing.count > 0) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            self.tableView.separatorColor = OSTableViewSeparator;
//            [_activityIndicator stopAnimating];
//            _activityIndicator.hidden = YES;
        }
        if (self.pageNo < self.totalPages) {
            return listing.count + 1;
        } else {
            return listing.count;
        }
    } else {
        if (!_activityIndicator && (!_noDataLabel || _noDataLabel.hidden == YES)) {
//            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
//            _activityIndicator.center = CGPointMake(self.view.frame.size.width/2, _activityIndicator.frame.size.height);
//            _activityIndicator.color = OSTogoTintColor;
//            [self.view addSubview: _activityIndicator];
//            [_activityIndicator startAnimating];
        }
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [_data[@"ads"] count]) {
        /******************
            Normal row
         ********************/
        NSDictionary *rowData = _data[@"ads"][indexPath.row];

        if (rowData[@"pinad"]) {
            //            "pinad":{
            //                "unit_id":"\/4689451\/iOS320x100_b",
            //                "unit_width":320
            //                "unit_height":100
            //            }
            OSAdCell *cell = [tableView dequeueReusableCellWithIdentifier: @"AdCell" forIndexPath: indexPath];
            DFPBannerView *gAdView = cell.bannerView;
            
            //add valid size
            CGSize size = CGSizeMake([rowData[@"pinad"][@"unit_width"] floatValue], [rowData[@"pinad"][@"unit_height"] floatValue]);
            GADAdSize size1 = GADAdSizeFromCGSize(size);
            NSMutableArray *validSizes = [NSMutableArray array];
            [validSizes addObject:[NSValue valueWithBytes:&size1 objCType:@encode(GADAdSize)]];
            gAdView.validAdSizes = validSizes;
            
            //request
            gAdView.adUnitID = rowData[@"pinad"][@"unit_id"];
            gAdView.rootViewController = self;
            GADRequest *request = [GADRequest request];
            //request.testDevices = @[ @"ff9a123840ce15490b9e7015cdae83bf", GAD_SIMULATOR_ID ];
            [gAdView loadRequest: request];
            
            return cell;
        }
        else
        {
            OSListingCell *cell = [tableView dequeueReusableCellWithIdentifier: @"OSListingCell"];
            [cell configureCellWithData: rowData];
            
//            cell.nameLabel.text = rowData[@"title"];
//            cell.priceLabel.text = rowData[@"price"];
//            //Picture
//            if (rowData[@"picture"] && ![rowData[@"picture"] isEqualToString: @""]) {
//                [cell.mainPictureImageView setImageWithURL: [NSURL URLWithString: rowData[@"picture"]] placeholderImage: [UIImage imageNamed:@"image112x112"]];
//            } else {
//                [cell.mainPictureImageView setImage: [UIImage imageNamed: @"No_Image-112x112"]];
//            }
//            //Firm/Negotiable
//            if (rowData[@"firm_neg"] || ![rowData[@"firm_neg"] isEqualToString: @""]) {
//                cell.firmLabel.text = rowData[@"firm_neg"];
//                cell.firmLabel.hidden = NO;
//            } else {
//                cell.firmLabel.hidden = YES;
//            }
//            cell.availableLabel.text = rowData[@"adstatus"];
//            NSString *adStatus = rowData[@"adstatus"];
//            if ([adStatus compare: @"sold" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
//                cell.availableLabel.textColor = OSRedColor;
//            } else {
//                cell.availableLabel.textColor = OSGreenColor;
//            }
//            
//            
//            //New item and priority
//            cell.viewLabel.text = rowData[@"ad_views"];
//            cell.commentLabel.text = rowData[@"msg_sent"];
//            NSString *listingLabel = rowData[@"listinglabel"];
//            //        NSLog(@"listingLabel: %@", listingLabel);
//            
//            cell.nItem.hidden = YES;
//            cell.priority.hidden = YES;
//            if (listingLabel) {
//                if ([listingLabel compare: @"NEW ITEM" options: NSCaseInsensitiveSearch] == NSOrderedSame) cell.nItem.hidden = NO;
//                if ([listingLabel compare: @"PRIORITY" options: NSCaseInsensitiveSearch] == NSOrderedSame) cell.priority.hidden = NO;
//            }
//            
//            //Date & Postedby
//            NSString *datePost = [NSString stringWithFormat: @"%@/Posted by:%@", rowData[@"dateposted"], rowData[@"postedby"]];
//            NSMutableAttributedString *datePostAttr = [[NSMutableAttributedString alloc] initWithString: datePost];
//            [datePostAttr addAttribute:NSForegroundColorAttributeName value: OSBlackColor range: NSMakeRange(0, datePost.length)];
//            [datePostAttr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range: [datePost rangeOfString: @"Posted by:"]];
//            cell.dateAndPostLabel.attributedText = datePostAttr;
//            
//            //Merchant
//            cell.logoImageView.hidden = YES;
//            cell.companyName.hidden = YES;
//            NSDictionary *merchantDetails = rowData[@"merchant_details"];
//            if (merchantDetails && merchantDetails.count > 0) {
//                if (merchantDetails[@"shop_logo"]) {
//                    cell.logoImageView.hidden = NO;
//                    [cell.logoImageView setImageWithURL: [NSURL URLWithString:merchantDetails[@"shop_logo"]]];
//                } else if (merchantDetails[@"shop_name"]) {
//                    cell.logoImageView.hidden = YES;
//                    cell.companyName.text = merchantDetails[@"shop_name"];
//                }
//            }
//            
//            //Special (exp: clearance)
//            NSDictionary *special = rowData[@"special"];
//            // && [special isKindOfClass: [NSDictionary class]]
//            if (special && special.count > 0) {
//                cell.specialBackground.hidden = NO;
//                cell.specialLabel.text = special[@"text"];
//                if (special[@"bgcolor"]) cell.specialBackground.backgroundColor = [UIColor colorFromHexCode: special[@"bgcolor"]];
//                if (special[@"textcolor"]) cell.specialLabel.textColor = [UIColor colorFromHexCode: special[@"textcolor"]];
//            } else {
//                cell.specialBackground.hidden = YES;
//            }
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
    
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    if (_isSearch) {
        [tracker set: kGAIScreenName value:@"Marketplace Search Result More"];
    } else if (_isShortList) {
//        [tracker set: kGAIScreenName value:@"Marketplace Shortlisted Ads"];
    } else {
        [tracker set: kGAIScreenName value:@"Marketplace List Ads By Category More"];
    }
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self loadDatas];
}

//-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 50;
//}
//
//-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"OSListingFooterCell"];
//    UIButton *loadMoreButton  = (UIButton *) [cell viewWithTag: 100];
//    [loadMoreButton addTarget: self action: @selector(loadMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    return cell;
//}
#pragma mark - UITableViewDelegate
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_data[@"ads"] count]) {
        NSDictionary *rowData = _data[@"ads"][indexPath.row];
        if (rowData[@"pinad"]) {
            return [rowData[@"pinad"][@"unit_height"] floatValue];
        } else {
            return 112;
        }
    } else {
        return 50;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_data[@"ads"] count]) {
        NSDictionary *rowData = _data[@"ads"][indexPath.row];
        if (rowData[@"pinad"]) {
            //Do nothing
        } else {
            NSString *aid = rowData[@"aid"];
            
            if (aid) {
                OSAdDetailViewController *adDetailVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSAdDetailViewController"];
                adDetailVC.aid = aid;
                if (_isSearch)  adDetailVC.showSearchButton = NO;
                [self.navigationController pushViewController: adDetailVC animated: YES];
            }
        }
    } else {
        //Do nothing. Auto load more
//        [self loadMore];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSArray *shortLists = [[NSUserDefaults standardUserDefaults] arrayForKey: @"ToGoShortList"];
        NSLog(@"shortlists : %@", shortLists);
        if (shortLists || shortLists.count > 0) {
            NSMutableArray *mutableShortlist = [NSMutableArray arrayWithArray: shortLists];
            [mutableShortlist removeObjectAtIndex: indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject: mutableShortlist forKey: @"ToGoShortList"];
            
            NSMutableDictionary *mutableData = [NSMutableDictionary dictionaryWithDictionary: self.data];
            NSMutableArray *mutableAds = [NSMutableArray arrayWithArray: mutableData[@"ads"]];
            [mutableAds removeObjectAtIndex: indexPath.row];
            [mutableData setObject: mutableAds forKey: @"ads"];
            self.data = mutableData;
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self loadDatas];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (_isShortList) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        self.bannerView.frame = CGRectMake(0, scrollView.contentOffset.y + self.tableView.frame.size.height - self.tableView.contentInset.bottom, _bannerView.frame.size.width, _bannerView.frame.size.height);
        if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
            if (!self.isLoadingNewPage && self.pageNo < self.totalPages) {
                self.isLoadingNewPage = YES;
                [self loadMore];
            }
        }
    }
}
#pragma mark - OSSearchViewControllerDelegate
-(void)searchViewController:(OSSearchViewController *)searchVC didSelectedParameters:(NSDictionary *)parameters {
    _parameters = parameters;
    [self updateListing];
}
@end

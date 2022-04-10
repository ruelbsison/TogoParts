//
//  OSMapViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/21/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSMapViewController.h"
#import "OSAnnotation.h"
#import "OSBikeshopDetailViewController.h"
#import "OSBikeshopSearchViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
@import MapKit;

@interface OSMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation OSMapViewController

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
    OSChangeTogoFontForLabel(_titleLabel);
    
    if (!_isSearch) {
        self.navigationItem.rightBarButtonItem = [OSHelpers searchBarButtonWithTarget: self action: @selector(searchButtonClicked:)];
        self.titleLabel.text = @"Singapore Bikeshop Listing";
    } else {
        if (!_fromList) {
            self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"list-icon"] target: self selector: @selector(listButtonClicked:)];
        }
        self.titleLabel.text = @"Search Results";
    }
    
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"top-back-button"] target: self selector: @selector(backButtonClicked:)];
    }
    
    //Segmentedcontrol
    _segmentedControl.selectedSegmentIndex = 0;
    
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

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    if (_isSearch) {
        [OSHelpers sendGATrackerWithName: @"Bikeshop Map Search Result"];
    } else {
        [OSHelpers sendGATrackerWithName: @"Bikeshop Map"];
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

//-(void) setData:(NSMutableDictionary *)data {
//    _data = data;
//    [self loadData];
//}

-(void) loadData {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    MBProgressHUD *hud;
    hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    
    __weak OSMapViewController *weakSelf = self;
    NSString *url = @"http://www.togoparts.com/iphone_ws/bs_listings.php?source=ios&map=on";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: url  parameters: _parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"url: %@", operation.request.URL);
        
        if (responseObject) {
            weakSelf.data = responseObject;
//            if (!weakSelf.isSearch) {
//                //Because the title doesn't apply to search
//                weakSelf.title = weakSelf.data[@"title"];
//            }
            [weakSelf updateViews];
        }
        
        [hud hide: YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Search Failure response: %@", operation.response);
         NSLog(@"Error: %@", error.localizedDescription);
         
         TOGO_UNIVERSAL_ERROR_ALERT
         
         [hud hide: YES];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
     }];
    
}
     
-(void) updateViews {
    if (!_mapView) return;
    
    if (_userLocation) {
        [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(_userLocation.coordinate, 5000.0f, 5000.0f)];
//        CLLocationCoordinate2D sing = CLLocationCoordinate2DMake(1.35208, 103.81984);
//        [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(sing, 5000.0f, 5000.0f)];
    }
    
    if (self.data) {
        NSLog(@"data: %@", _data);
        NSArray *bsList = _data[@"bikeshoplist"];
        if (bsList) {
            for (NSInteger i=0; i < bsList.count; i++) {
                NSDictionary *dict = bsList[i];
                
                if (dict[@"latitude"] && dict[@"longitude"]) {
                    //                {
                    //                    address = "598 Sembawang Road S(758456)";
                    //                    distance = "2187.8 km away";
                    //                    forpaidonly =             {
                    //                        "new_item_ads" = 14;
                    //                        openlabel = "OPEN NOW.";
                    //                        promos = 1;
                    //                        remarks = "Closing in 1 hr and 18 mins";
                    //                        shopphoto = "http://www.togoparts.com/bikeshops/images/shop/thumb-shop-50-1346991098.jpg";
                    //                    };
                    //                    latitude = "1.4410019";
                    //                    longitude = "103.824862";
                    //                    shoplogo = "http://www.togoparts.com/bikeshops/images/shop/logo-small-50.jpg";
                    //                    shopname = "Cheap John's Enterprise";
                    //                    sid =
                    NSDictionary *forPaidOnly = dict[@"forpaidonly"];
                    
                    OSAnnotation *annot = [[OSAnnotation alloc] init];
                    
                    //Title
                    if (forPaidOnly) {
                        if (!forPaidOnly[@"openlabel"]){
                            annot.title = [NSString stringWithFormat: @"%@ - %@", dict[@"shopname"], @"Unknown"];
                        } else {
                            annot.title = [NSString stringWithFormat: @"%@ - %@", dict[@"shopname"], dict[@"forpaidonly"][@"openlabel"]];
                        }
                    } else {
                        annot.title = [NSString stringWithFormat: @"%@ - %@", dict[@"shopname"],  @"Unknown"];
                    }
                    
                    //Subtitle
                    NSString *distance = @"";
                    if (dict[@"distance"]) distance = dict[@"distance"];
                    annot.subtitle = [NSString stringWithFormat: @"%@ %@",dict[@"address"], distance];
                    
                    //Pin color
                    if (forPaidOnly) {
                        if (forPaidOnly[@"openlabel"]) {
                            if ([forPaidOnly[@"openlabel"] compare: @"closed now" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
                                annot.pinColor = MKPinAnnotationColorRed;
                            } else if ([forPaidOnly[@"openlabel"] compare: @"open now" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
                                annot.pinColor = MKPinAnnotationColorGreen;
                            }
                        } else {
                            annot.pinColor = MKPinAnnotationColorPurple;
                        }
                    } else {
                        annot.pinColor = MKPinAnnotationColorPurple;
                    }
                    
                    //Coord
                    annot.coordinate = CLLocationCoordinate2DMake([dict[@"latitude"] doubleValue], [dict[@"longitude"] doubleValue]);
                    
                    annot.tag = i;
                    
                    //Add to mapView
                    [_mapView addAnnotation: annot];
                }
            }
        }
    }
}

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annot {
    if ([annot isKindOfClass:[MKUserLocation class]])
        return nil;
    
    OSAnnotation * annotation = (OSAnnotation *) annot;
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"AnnotationView"];
    annotationView.pinColor = annotation.pinColor;
    
    annotationView.draggable = NO;
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return  annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    OSAnnotation *annotation = (OSAnnotation *) view.annotation;
    NSDictionary *rowData = self.data[@"bikeshoplist"][annotation.tag];
    if (rowData) {
        OSBikeshopDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSBikeshopDetailViewController"];
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        parameters[@"sid"] = rowData[@"sid"];
        if (_userLocation) {
            parameters[@"lat"] = @(_userLocation.coordinate.latitude);
            parameters[@"long"] = @(_userLocation.coordinate.longitude);
        }
        detailVC.parameters = parameters;
        [self.navigationController pushViewController: detailVC animated: YES];
    }
}

#pragma mark - Actions
- (IBAction)segmentChanged:(id)sender {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            _mapView.mapType = MKMapTypeStandard;
        }
            break;
        case 1: {
            _mapView.mapType = MKMapTypeHybrid;
        }
            break;
        case 2: {
            _mapView.mapType = MKMapTypeSatellite;
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)hereButtonClicked:(id)sender {
    if (_userLocation) {
        [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(_userLocation.coordinate, 5000.0f, 5000.0f)];
    }
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}
-(void) searchButtonClicked: (id) sender {
    OSBikeshopSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSBikeshopSearchViewController"];
    searchVC.fromMap = YES;
    [self.navigationController pushViewController: searchVC animated: YES];
}
-(void) listButtonClicked: (id) sender {
    OSBikeshopListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSBikeshopListViewController"];
    listVC.parameters = _parameters;
    listVC.isSearch = _isSearch;
    listVC.fromMap = YES;
    [self.navigationController pushViewController: listVC animated: YES];
}


#pragma mark - OSBikeshopListProtocol
-(void) bikeshopList:(OSBikeshopListViewController *)vc didLoadData:(NSDictionary *)data {
    self.data = [[NSMutableDictionary alloc] initWithDictionary: data];
}
@end

//
//  OSSuggestionController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/5/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSSuggestionController.h"

@interface OSSuggestionController () <UISearchBarDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) NSMutableArray *searchedPlacemarks;
@property (strong, nonatomic) NSArray *places;
@property (nonatomic, strong) MKLocalSearch *localSearch;

@property (nonatomic) MKCoordinateRegion boundingRegion;

@property (nonatomic) __block MBProgressHUD *hud;

@end

@implementation OSSuggestionController

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
    
    _searchBar.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"top-back-button"]  target: self selector: @selector(backButtonClicked:)];
    
    if (!self.isLocationSearch) {
        self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"apply-icon"]  target: self selector: @selector(doneButtonClicked:)];
    } else {
        //Location manager
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate= self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=kCLDistanceFilterNone;
        [_locationManager startUpdatingLocation];
    }
    
    [self loadData];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    if (_isLocationSearch) {
        [OSHelpers sendGATrackerWithName: @"Marketplace Post of Edit Ad Location"];
    }
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

- (IBAction)doneButtonClicked:(id)sender {
    if (_isLocationSearch) {
        NSDictionary *location = @{@"address": _searchBar.text};
        if ([_delegate respondsToSelector: @selector(suggestionController:didSelectedValue:)]) {
            [_delegate suggestionController: self didSelectedValue: location];
        }
    } else {
        if ([_delegate respondsToSelector: @selector(suggestionController:didSelectedValue:)]) {
            [_delegate suggestionController: self didSelectedValue: _searchBar.text];
        }
    }
}
#pragma mark - UISearchBarDelegate
-(void) loadData {
    if (self.isLocationSearch) {
        [self startSearch];
    } else {
//    https://www.togoparts.com/iphone_ws/get-option-values.php?source=android&brands=1&search=da
//    brands = 1
//    search (optional)
        NSDictionary *params = @{@"search": _searchBar.text ? _searchBar.text : @""};
        if (!_key) _key = @"Brands";
        if (!_url) _url = @"https://www.togoparts.com/iphone_ws/get-option-values.php?source=ios";
        if (!_data) _data = [NSMutableArray new];
        
        if (!self.hud) {
            _hud = [OSHelpers showStandardHUDForView: self.view];
        } else {
            [_hud show: YES];
        }
        __weak OSSuggestionController * weakSelf = self;
        AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
        [testManager GET: _url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [OSHelpers hideStandardHUD: _hud];
            if (responseObject[@"Result"]) {
                weakSelf.data = responseObject[@"Result"][_key];
                [weakSelf.tableView reloadData];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [OSHelpers hideStandardHUD: _hud];
        }];
    }
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self loadData];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self loadData];
}

#pragma mark - Search Logic

-(NSString *) searchString {
    NSString *searchText = self.searchBar.text;
    //    NSString *appendText;
    //    if (_city) {
    //        appendText = _city[@"searchName"];
    //        if (!appendText) appendText = _city[@"name"];
    //    }
    //    if (appendText) searchText = [searchText stringByAppendingString: [NSString stringWithFormat: @", %@", appendText]];
    
    return searchText;
}

//for >= iOS 6.1
- (void)startSearch
{
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // confine the map search area to the user's current location
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    NSString *searchString = [self searchString];
    NSLog(@"searchString: %@", searchString);
    request.naturalLanguageQuery = searchString;
    if (_userLocation) {
        MKCoordinateRegion newRegion;
        newRegion.center.latitude = _userLocation.coordinate.latitude;
        newRegion.center.longitude = _userLocation.coordinate.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level)
    //
//        newRegion.span.latitudeDelta = 0.112872;
//        newRegion.span.longitudeDelta = 0.109863;
        newRegion.span.latitudeDelta = 1;
        newRegion.span.longitudeDelta = 1;
        request.region = newRegion;
    }

    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil)
        {
//            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
//                                                            message:errorStr
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
        }
        else
        {
            self.places = [response mapItems];
            
            // used for later when setting the map's region in "prepareForSegue"
            self.boundingRegion = response.boundingRegion;
            
            //            self.viewAllButton.enabled = self.places != nil ? YES : NO;
            
            [self.tableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil)
    {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.localSearch startWithCompletionHandler:completionHandler];
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

#pragma mark - UITableViewDatasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isLocationSearch) {
        return self.places.count;
    } else {
        return _data.count;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isLocationSearch) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CellSubtitle"];
        MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
        MKPlacemark *placemark = mapItem.placemark;
        
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        
        NSArray *formattedAddressLines = placemark.addressDictionary[@"FormattedAddressLines"];
        if (formattedAddressLines && formattedAddressLines.count > 0) {
            NSArray *tailArray = [formattedAddressLines subarrayWithRange: NSMakeRange(1, formattedAddressLines.count - 1)];
            if (placemark.name) {
                if ([placemark.name isEqualToString: formattedAddressLines[0]]) {
                    cell.textLabel.text = placemark.name;
                } else {
                    cell.textLabel.text = [NSString stringWithFormat: @"%@, %@", placemark.name, formattedAddressLines[0]];
                }
            }
            cell.detailTextLabel.text = [tailArray componentsJoinedByString:@", "];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
        NSString *title = _data[indexPath.row];
        cell.textLabel.text = title;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isLocationSearch) {
        [self.searchBar endEditing: YES];
        MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
        MKPlacemark *placemark = mapItem.placemark;
        NSMutableDictionary *location = [NSMutableDictionary new];
        NSArray *formattedAddressLines = placemark.addressDictionary[@"FormattedAddressLines"];
        NSArray *tailArray = [formattedAddressLines subarrayWithRange: NSMakeRange(1, formattedAddressLines.count - 1)];
        if (placemark.name) {
            if ([placemark.name isEqualToString: formattedAddressLines[0]]) {
                location[@"address"] = placemark.name;
            } else {
                location[@"address"] = [NSString stringWithFormat: @"%@, %@", placemark.name, formattedAddressLines[0]];
            }
        } else if (formattedAddressLines && formattedAddressLines.count > 0) {
            location[@"address"] = [formattedAddressLines componentsJoinedByString:@", "];
        }
        if (placemark.country) location[@"country"] = placemark.country;
        if (placemark.postalCode) location[@"postalcode"] = placemark.postalCode;
        if (placemark.administrativeArea) location[@"region"] = placemark.administrativeArea;
        if (placemark.locality) location[@"city"] = placemark.locality;
        if (CLLocationCoordinate2DIsValid(placemark.location.coordinate)) {
            location[@"lat"] = @(placemark.location.coordinate.latitude);
            location[@"long"] = @(placemark.location.coordinate.longitude);
        }
        
//        NSLog(@"%@", placemark.description);
        if (placemark.administrativeArea) location[@"administrativeArea"] = placemark.administrativeArea;
        if (placemark.subAdministrativeArea) location[@"subAdministrativeArea"] = placemark.subAdministrativeArea;
        if (placemark.locality) location[@"locality"] = placemark.locality;
        if (placemark.thoroughfare) location[@"thoroughfare"] = placemark.thoroughfare;
        if (placemark.subThoroughfare) location[@"subThoroughfare"] = placemark.subThoroughfare;
        if (placemark.region) location[@"region"] = placemark.region;
        
        if ([_delegate respondsToSelector: @selector(suggestionController:didSelectedValue:)]) {
            [_delegate suggestionController: self didSelectedValue: location];
        }
    } else {
        if ([_delegate respondsToSelector: @selector(suggestionController:didSelectedValue:)]) {
            [_delegate suggestionController: self didSelectedValue: _data[indexPath.row]];
        }
    }
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

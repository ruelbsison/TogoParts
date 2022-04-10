//
//  OSBikeshopSearchViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/12/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSBikeshopSearchViewController.h"
#import "OSBikeshopListViewController.h"
#import "OSPickerField.h"
#import "OSSearchTextField.h"
#import "OSCheckButton.h"
#import "OSMapViewController.h"

@import MapKit;

#import <AFNetworking/AFNetworking.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#define kTogoDefaultSortOptionWithLocation @"0"
#define kTogoDefaultSortOptionWithoutLocation @"2"

@interface OSBikeshopSearchViewController () <UITextFieldDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet OSSearchTextField *nameTextField;
@property (weak, nonatomic) IBOutlet OSPickerField *areaPickerField;
@property (weak, nonatomic) IBOutlet OSCheckButton *mechanicButton;
@property (weak, nonatomic) IBOutlet OSCheckButton *openButton;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *area;
@property (nonatomic, strong) NSString *sort;

@property (nonatomic, strong) NSArray *areaKeys;
@property (nonatomic, strong) NSArray *areaValues;

@property (nonatomic) BOOL mechanic;
@property (nonatomic) BOOL open;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;


@end

@implementation OSBikeshopSearchViewController

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
    self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"apply-button"] target: self selector: @selector(applyButtonClicked:)];
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"top-back-button"] target: self selector: @selector(backButtonClicked:)];
    }
    
    //Location manager
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate= self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter=kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
    
    /************************
        Data
     ************************/
    //    area
    //All in Singapore ""
    //North     n
    //South     s
    //East      e
    //West      w
    //Central   c
    _areaKeys = @[@"", @"n", @"s", @"e", @"w", @"c"];
    _areaValues = @[@"All in Singapore", @"North", @"South", @"East", @"West", @"Central"];

    [self configureAreaPickerField];
    
    //Sort
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
    self.sort = kTogoDefaultSortOptionWithoutLocation;
    } else {
        self.sort = kTogoDefaultSortOptionWithLocation;
    }
    
    //Open
    _open = NO; //Default
    _openButton.checkedImage = [UIImage imageNamed: @"open-now-check"];
    _openButton.uncheckedImage = [UIImage imageNamed: @"open-now-uncheck"];
    _openButton.checked = _open;
    
    //Mechanic
    _mechanic = NO; //Default
    _mechanicButton.checkedImage = [UIImage imageNamed: @"machenic-service-check"];
    _mechanicButton.uncheckedImage = [UIImage imageNamed: @"machenic-service-uncheck"];
    _mechanicButton.checked = _mechanic;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.tableView reloadData];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [OSHelpers sendGATrackerWithName: @"Bikeshop Search Form"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    _userLocation = newLocation;
    if (!oldLocation) {
//        [self loadData];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    //Failed
    [self checkForLocationAuthorization];
}

-(BOOL) checkForLocationAuthorization {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Location update not allowed" message: @"Please allow location update in Settings/Privacy/Location Services for Togoparts to use distance filters" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    return YES;
}

#pragma mark - Actions
-(IBAction) applyButtonClicked: (id) sender{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (_area) parameters[@"area"] = _area;
    if (_sort) parameters[@"sortedby"] = _sort;
    _name = _nameTextField.text;
    if (!_name) _name = @"";
    parameters[@"shopsearch"] = _name;
    if (_open) parameters[@"open"] = @"on";
    if (_mechanic) parameters[@"mechanic"] = @"on";
    
    
    if (!_fromMap) {
        OSBikeshopListViewController *listVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSBikeshopListViewController"];
        listVC.parameters = parameters;
        listVC.isSearch = YES;
        [self.navigationController pushViewController: listVC animated: YES];
    } else {
        OSMapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSMapViewController"];
        //    mapVC.data = self.data;
        //    self.delegate = mapVC;
        if (parameters) {
            mapVC.parameters = parameters;
            mapVC.isSearch = YES;
        }
        [self.navigationController pushViewController: mapVC animated: YES];
    }
}
- (IBAction)resetButtonClicked:(id)sender {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        _sort = kTogoDefaultSortOptionWithoutLocation;
    } else {
        _sort = kTogoDefaultSortOptionWithLocation;
    }
    _area = nil;
    _name = nil;
    _open = NO;
    _mechanic = NO;
    
    _nameTextField.text = 0;
    _areaPickerField.text = @"";
    _openButton.checked = _open;
    _mechanicButton.checked = _mechanic;
    [self.tableView reloadData]; //for sort
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}
- (IBAction)openButtonClicked:(id)sender {
    if (_open) {
        _open = NO;
        _openButton.checked = NO;
    } else {
        _open = YES;
        _openButton.checked = YES;
    }
}
- (IBAction)mechanicButtonClicked:(id)sender {
    if (_mechanic) {
        _mechanic = NO;
        _mechanicButton.checked = NO;
    } else {
        _mechanic = YES;
        _mechanicButton.checked = YES;
    }
}


#pragma mark - Configurations
-(void) configureAreaPickerField {
    
    __weak OSBikeshopSearchViewController *weakSelf = self;
    
    self.areaPickerField.placeHolder = _areaValues[0];
    self.areaPickerField.componentsOfStrings = @[_areaValues];
    self.areaPickerField.doneBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        if (value) {
            for (NSInteger i=0; i < _areaValues.count; i++) {
                if ([value isEqualToString: _areaValues[i]]) {
                    weakSelf.area = _areaKeys[i];
                }
            }
        } else {
            //default
            [picker setText: _areaValues[0]];
            weakSelf.area = _areaKeys[0];
        }
    };
}

#define BikeShopSortOffset 1
#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger sortIndex = [_sort integerValue] + BikeShopSortOffset;
    if (sortIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
-(void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0 && indexPath.row < 5) {
        if (indexPath.row == 1 || indexPath.row == 2) {
            if (![self checkForLocationAuthorization]) {
                _sort = kTogoDefaultSortOptionWithoutLocation;
            } else {
                _sort = [NSString stringWithFormat: @"%zd", indexPath.row - BikeShopSortOffset];
            }
        } else {
            _sort = [NSString stringWithFormat: @"%zd", indexPath.row - BikeShopSortOffset];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _nameTextField) {
        _name = _nameTextField.text;
    }
}

@end

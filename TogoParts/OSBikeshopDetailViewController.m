//
//  OSBikeshopDetailViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/11/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSBikeshopDetailViewController.h"
#import "OSPromosTableViewController.h"
#import "OSListingViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
@import MapKit;
#import "UIColor+VTTHelpers.h"
#import "UITextView+VTTHelpers.h"

@interface OSBikeshopDetailViewController () <UICollectionViewDataSource, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSDictionary *bsDetails;
@property (nonatomic, strong) NSArray *mainPictureURLs;
@property (nonatomic, strong) NSDictionary *forPaidOnly;

@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UIView *openBackground;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *distanceBackground;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIButton *smsButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@property (weak, nonatomic) IBOutlet UITextView *addressTextview;
@property (weak, nonatomic) IBOutlet UITextView *openinghrsTextView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UITextView *telephoneTextView;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;
@property (weak, nonatomic) IBOutlet UILabel *faxLabel;
@property (weak, nonatomic) IBOutlet UITextView *emailTextView;
@property (weak, nonatomic) IBOutlet UITextView *websiteTextView;
@property (weak, nonatomic) IBOutlet UITextView *bikeAvailTextView;
@property (weak, nonatomic) IBOutlet UITextView *mechanicTextView;
@property (weak, nonatomic) IBOutlet UITextView *deliveryTextView;

@property (weak, nonatomic) IBOutlet UILabel *brandsLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *brandsCollectionView;
@property (weak, nonatomic) IBOutlet UITextView *retailTextView;

@property (weak, nonatomic) IBOutlet UIImageView *nItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *nItemLabel;
@property (weak, nonatomic) IBOutlet UIView *nItemBackground;
@property (weak, nonatomic) IBOutlet UIImageView *promosImageView;
@property (weak, nonatomic) IBOutlet UILabel *promosLabel;
@property (weak, nonatomic) IBOutlet UIView *promosBackground;

//Icons
@property (weak, nonatomic) IBOutlet UIImageView *addressIcon;
@property (weak, nonatomic) IBOutlet UIImageView *openingIcon;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIcon;
@property (weak, nonatomic) IBOutlet UIImageView *mobileIcon;
@property (weak, nonatomic) IBOutlet UIImageView *faxIcon;
@property (weak, nonatomic) IBOutlet UIImageView *emailIcon;
@property (weak, nonatomic) IBOutlet UIImageView *websiteIcon;
@property (weak, nonatomic) IBOutlet UIImageView *bikeAvailIcon;
@property (weak, nonatomic) IBOutlet UIImageView *mechanicIcon;
@property (weak, nonatomic) IBOutlet UIImageView *deliveryIcon;


//Phones and email
@property (nonatomic, strong) NSMutableArray *phoneNumbers;
@property (nonatomic, strong) NSString *emailAddress;

@end

@implementation OSBikeshopDetailViewController

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
    
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"top-back-button"] target: self selector: @selector(backButtonClicked:)];
    }
    
    // Do any additional setup after loading the view.
    _addressTextview.text = nil;
    _openinghrsTextView.text = nil;
    _telephoneTextView.text = nil;
    _mobileLabel.text = nil;
    _faxLabel.text = nil;
    _emailTextView.text = nil;
    _websiteTextView.text = nil;
    _bikeAvailTextView.text = nil;
    _mechanicTextView.text = nil;
    _deliveryTextView.text = nil;
    
    _promosImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *promosTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(promosButtonClicked:)];
    [_promosImageView addGestureRecognizer: promosTap];
    
    _nItemImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *nItemTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(nItemButtonClicked:)];
    [_nItemImageView addGestureRecognizer: nItemTap];
    
}

-(void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear: animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters;
    if (self.parameters) {
        parameters = self.parameters;
    } else {
        parameters = @{@"sid" : self.sid};
    }
    
    [manager GET: @"http://www.togoparts.com/iphone_ws/bs_details.php?source=ios" parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success bs detail: %@", responseObject);
        self.bsDetails = responseObject;
        self.mainPictureURLs = responseObject[@"shopphotos"];
        self.forPaidOnly = responseObject[@"forpaidonly"];
        [hud hide: YES];
        
        [self updateViews];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide: YES];
        NSLog(@"Failure ad detail: %@", operation.responseObject);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [OSHelpers sendGATrackerWithName: @"Bikeshop Details"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers
-(void) updateViews {
    [self.tableView reloadData];
    [self.mainCollectionView reloadData];
    [self.brandsCollectionView reloadData];
    
    self.titleLabel.text = _bsDetails[@"shopname"];
    
    BOOL forPaid = [self isForPaidOnly];
    /*******************
        Top Labels
    ********************/
    _openBackground.hidden = YES;
    if (forPaid && VTTValidNSString(_forPaidOnly[@"openlabel"])) {
        _openBackground.hidden = NO;
        NSDictionary *forPaidOnly = _forPaidOnly;
        NSMutableAttributedString *openAttr = [[NSMutableAttributedString alloc] initWithString: forPaidOnly[@"openlabel"] attributes: @{NSFontAttributeName: [UIFont fontWithName: OSTogoFontName size: 15]}];
        NSMutableAttributedString *remarksAttr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @"\n%@", forPaidOnly[@"remarks"]] attributes: @{NSFontAttributeName: [UIFont fontWithName: OSTogoFontName size: 13]}];
        NSMutableAttributedString *finalOpenAttr = [[NSMutableAttributedString alloc] initWithAttributedString: openAttr];
        [finalOpenAttr appendAttributedString: remarksAttr];
        self.openLabel.attributedText = finalOpenAttr;
        
        if ([_forPaidOnly[@"openlabel"] compare: @"closed now" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.openBackground.backgroundColor = [UIColor colorWithRed:0.901961 green:0.901961 blue:0.901961 alpha:1];
            self.openLabel.textColor = [UIColor blackColor];
        } else {
            self.openBackground.backgroundColor = OSGreenColor;
            self.openLabel.textColor = [UIColor whiteColor];
        }
    }
    /*******************
        Distance
     ********************/
    //distance	:	15.6 km away
    _distanceBackground.hidden = YES;

    if (VTTValidNSString(_bsDetails[@"distance"])) {
        _distanceLabel.text = _bsDetails[@"distance"];
        [_locationButton setTitle: [NSString stringWithFormat: @" %@", _bsDetails[@"distance"]] forState: UIControlStateNormal];
    } else {
       if (VTTValidNSString(_bsDetails[@"latitude"]) && VTTValidNSString(_bsDetails[@"longitude"])) {
        [_locationButton setTitle: @" Location" forState: UIControlStateNormal];
       } else {
           _locationButton.hidden = YES;
       }
    }
    
    /*******************
        Main Sliders
     ********************/
    //shopphotos [array]
    if (_bsDetails[@"shopphotos"] && [_bsDetails[@"shopphotos"] count] > 1) {
        _prevButton.hidden = NO;
        _nextButton.hidden = NO;
    } else {
        _prevButton.hidden = YES;
        _nextButton.hidden = YES;
    }
    
    /*******************
        Address
     ********************/
    //address	:	#01-20, 33 Ubi Avenue 3 Singapore 408868
    if (VTTValidNSString(_bsDetails[@"address"])) {
        _addressTextview.text = _bsDetails[@"address"];
    }
    
    /*******************
        Openinghrs
     ********************/
    //forpaidonly.openinghrs
    if (forPaid && VTTValidNSString(_forPaidOnly[@"openinghrs"])) {
        _openinghrsTextView.text = _forPaidOnly[@"openinghrs"];
    }
    //shoplogo
    if (VTTValidNSString(_bsDetails[@"shoplogo"])) {
        [_logoImageView setImageWithURL: [NSURL URLWithString: _bsDetails[@"shoplogo"]]];
    } else {
        _logoImageView.hidden = YES;
    }
    
    /*******************
        phone and mobilephone
     ********************/
    //telephone, mobile
    _phoneNumbers = [NSMutableArray new];
    _smsButton.hidden = YES;
    if (forPaid && _forPaidOnly[@"actualno"]) {
        _phoneNumbers = _forPaidOnly[@"actualno"];
        for (NSString *number in _phoneNumbers) {
            NSString *firstDigit = [number substringToIndex: 1];
            if ([firstDigit isEqualToString: @"8"] || [firstDigit isEqualToString: @"9"]) {
                _smsButton.hidden = NO;
            }
        }
    }
    if (VTTValidNSString(_bsDetails[@"telephone"])) {
        _telephoneTextView.text = _bsDetails[@"telephone"];
//        [_phoneNumbers addObject: _bsDetails[@"telephone"]];
    }
    if (forPaid && VTTValidNSString(_forPaidOnly[@"mobile"])) {
        _mobileLabel.text = _forPaidOnly[@"mobile"];
//        [_phoneNumbers addObject: _forPaidOnly[@"mobile"]];
    } else {
        _mobileLabel.hidden = YES;
        _mobileIcon.hidden = YES;
    }
    
    /*******************
        The rest for forPaidOnly
     ********************/
    if (forPaid && VTTValidNSString(_forPaidOnly[@"fax"])) {
        _faxLabel.text = _forPaidOnly[@"fax"];
    }
    if (forPaid && VTTValidNSString(_forPaidOnly[@"email"])) {
        _emailTextView.text = _forPaidOnly[@"email"];
        _emailAddress = _forPaidOnly[@"email"];
    }
    if (forPaid && VTTValidNSString(_forPaidOnly[@"website"])) {
        _websiteTextView.text = _forPaidOnly[@"website"];
//        [_websiteTextView sizeToFit];
    }
    if (forPaid && VTTValidNSString(_forPaidOnly[@"bikes_avail"])) {
        _bikeAvailTextView.text = _forPaidOnly[@"bikes_avail"];
    }
    if (forPaid && VTTValidNSString(_forPaidOnly[@"mechanic_svcs"])) {
        _mechanicTextView.text = _forPaidOnly[@"mechanic_svcs"];
//        [_mechanicLabel sizeToFit];
    }
    if (forPaid && VTTValidNSString(_forPaidOnly[@"delivery"])) {
        _deliveryTextView.text = _forPaidOnly[@"delivery"];
//        [_deliveryLabel sizeToFit];
    }
    
    /*******************
        Brands Distributed
     ********************/
    _brandsLabel.text = [NSString stringWithFormat: @"Brands Distributed by %@", _bsDetails[@"shopname"]];
    if (forPaid && VTTValidNSString(_forPaidOnly[@"brands_retailed"])) {
        _retailTextView.text = _forPaidOnly[@"brands_retailed"];
    } else {
        _retailTextView.hidden = YES;
    }
    
    /*******************
        New Item & promos
     ********************/
    if (forPaid) {
        BOOL isNewItem = (VTTValidNSString(_forPaidOnly[@"new_item"]) || (_forPaidOnly[@"new_item_cnt"] && [_forPaidOnly[@"new_item_cnt"] integerValue] != 0));
        BOOL isPromos = (VTTValidNSString(_forPaidOnly[@"promo"]) || (_forPaidOnly[@"promo_cnt"] && [_forPaidOnly[@"promo_cnt"] integerValue] != 0));
        
        if (isNewItem) {
            if (VTTValidNSString(_forPaidOnly[@"new_item"])) {
                [self.nItemImageView setImageWithURL: [NSURL URLWithString: _forPaidOnly[@"new_item"]] placeholderImage: [UIImage imageNamed: @"image264x216"]];
            } else {
                [self.nItemImageView setImage: [UIImage imageNamed: @"new-item-tab.jpg"]];
            }
            self.nItemLabel.text = [NSString stringWithFormat: @"NEW ITEM ADS (%@)", _forPaidOnly[@"new_item_cnt"]];
        } else {
            _nItemImageView.hidden = YES;
            self.nItemBackground.hidden = YES;
        }
        if (isPromos) {
            if (VTTValidNSString(_forPaidOnly[@"promo"])) {
            [self.promosImageView setImageWithURL: [NSURL URLWithString: _forPaidOnly[@"promo"]] placeholderImage: [UIImage imageNamed: @"image264x216"]];
            } else {
                [self.promosImageView setImage: [UIImage imageNamed: @"promos-tab.jpg"]];
            }
            self.promosLabel.text = [NSString stringWithFormat: @"PROMOS (%@)", _forPaidOnly[@"promo_cnt"]];
        } else {
            _promosImageView.hidden = YES;
            self.promosBackground.hidden = YES;
        }
        CGFloat middleX = (self.view.frame.size.width - _promosImageView.frame.size.width) / 2;
        CGRect pFrame = _promosImageView.frame;
        CGRect nFrame = _nItemImageView.frame;
        if (isPromos && !isNewItem) {
            _promosImageView.frame = CGRectMake(middleX, pFrame.origin.y, pFrame.size.width, pFrame.size.height);
            _promosBackground.frame = CGRectMake(middleX, _promosBackground.frame.origin.y, _promosBackground.frame.size.width, _promosBackground.frame.size.height);
        } else if (!isPromos && isNewItem) {
            _nItemImageView.frame = CGRectMake(middleX, nFrame.origin.y, nFrame.size.width, nFrame.size.height);
            _nItemBackground.frame = CGRectMake(middleX, _nItemBackground.frame.origin.y, _nItemBackground.frame.size.width, _nItemBackground.frame.size.height);
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Actions
-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

-(BOOL) isForPaidOnly {
    return (_forPaidOnly && ![[NSNull null] isEqual: _forPaidOnly] && [_forPaidOnly count] > 0);
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
    if ([buttonTitle isEqualToString: @"Cancel"]) return;
    
    if ([actionSheet.title isEqualToString: @"SMS a number"]) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"id": _bsDetails[@"sid"], @"fktype": @"shopid", @"category": @"sms_iphone"};
        [manager POST:@"http://www.togoparts.com/iphone_ws/contact_log.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Logged sms successfully");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Logged sms failed: %@", operation.response);
            NSLog(@"Error: %@", error.localizedDescription);
        }];
        NSString *smsNumber = [buttonTitle stringByReplacingOccurrencesOfString: @" " withString: @""];
        NSURL *smsURL = [NSURL URLWithString: [NSString stringWithFormat: @"sms:%@", smsNumber]];
        [[UIApplication sharedApplication] openURL: smsURL];
        
    } else if ([actionSheet.title isEqualToString: @"Call a number"]) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"id": _bsDetails[@"sid"], @"fktype": @"shopid", @"category": @"call_iphone"};
        [manager POST:@"http://www.togoparts.com/iphone_ws/contact_log.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Logged call successfully");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Logged call failed: %@ %@", operation.response, operation.request);
            NSLog(@"Error: %@", error.localizedDescription);
        }];
        NSString *phoneNumber = [buttonTitle stringByReplacingOccurrencesOfString: @" " withString: @""];
        NSURL *callURL = [NSURL URLWithString: [NSString stringWithFormat: @"tel:%@", phoneNumber]];
        [[UIApplication sharedApplication] openURL: callURL];
    }
}

- (IBAction)smsButtonClicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: @"SMS a number" delegate: self cancelButtonTitle: nil destructiveButtonTitle: nil otherButtonTitles:nil];
    for (NSString *number in _phoneNumbers) {
        NSString *firstDigit = [number substringToIndex: 1];
        if ([firstDigit isEqualToString: @"8"] || [firstDigit isEqualToString: @"9"]) {
            [actionSheet addButtonWithTitle: number];
        }
    }
    if (actionSheet.numberOfButtons > 0) {
        [actionSheet addButtonWithTitle:@"Cancel"];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        [actionSheet showFromTabBar: self.navigationController.tabBarController.tabBar];
    }
    
}

- (IBAction)callButtonClicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: @"Call a number" delegate: self cancelButtonTitle: nil destructiveButtonTitle: nil otherButtonTitles:nil];
    for (NSString *number in _phoneNumbers) {
        [actionSheet addButtonWithTitle: number];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = [_phoneNumbers count];
    [actionSheet showFromTabBar: self.navigationController.tabBarController.tabBar];
}

- (IBAction)emailButtonClicked:(id)sender {
    if (VTTValidNSString(_emailAddress)) {
        NSURL *emailURL = [NSURL URLWithString: [NSString stringWithFormat: @"mailto:%@", _emailAddress]];
        [[UIApplication sharedApplication] openURL: emailURL];
    }
}

- (IBAction)previousButtonClicked:(id)sender {
    CGPoint originPoint = CGPointMake(_mainCollectionView.contentOffset.x + _mainCollectionView.frame.size.width/2, _mainCollectionView.contentOffset.y + _mainCollectionView.frame.size.height/2);
    NSIndexPath *indexPath = [self.mainCollectionView indexPathForItemAtPoint: originPoint];
    if (indexPath.item > 0) {
        [self.mainCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem: indexPath.row - 1 inSection: indexPath.section] atScrollPosition:UICollectionViewScrollPositionNone animated: YES];
    }
}
- (IBAction)nextButtonClicked:(id)sender {
    CGPoint originPoint = CGPointMake(_mainCollectionView.contentOffset.x + _mainCollectionView.frame.size.width/2, _mainCollectionView.contentOffset.y + _mainCollectionView.frame.size.height/2);
    NSIndexPath *indexPath = [self.mainCollectionView indexPathForItemAtPoint: originPoint];
    if (indexPath.item < _mainPictureURLs.count - 1) {
        [self.mainCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem: indexPath.row + 1 inSection: indexPath.section] atScrollPosition:UICollectionViewScrollPositionNone animated: YES];
    }
}
- (IBAction)locationButtonClicked:(id)sender {
    if (VTTValidNSString(_bsDetails[@"latitude"]) && VTTValidNSString(_bsDetails[@"longitude"])) {
        [self openMapWithOptions: nil coordinate: CLLocationCoordinate2DMake([_bsDetails[@"latitude"] doubleValue], [_bsDetails[@"longitude"] doubleValue])] ;
    }
}

-(void) openMapWithOptions: (NSDictionary *) launchOptions coordinate: (CLLocationCoordinate2D) coordinate{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
//        CLLocationCoordinate2D coordinate = self.annotation.coordinate;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName: self.titleLabel.text];
        
        // Set the directions mode to "Driving"
        //Options: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeWalking
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
}

- (IBAction)promosButtonClicked:(id)sender {
    OSPromosTableViewController *promosVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSPromosTableViewController"];
    promosVC.sid = _bsDetails[@"sid"];
    [self.navigationController pushViewController: promosVC animated: YES];
}

-(IBAction) nItemButtonClicked:(id)sender {
    OSListingViewController *nItemVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
    nItemVC.parameters = @{@"sid" : _bsDetails[@"sid"]};
    nItemVC.isSearch = YES;
    nItemVC.isFromBikeShop = YES;
    [self.navigationController pushViewController: nItemVC animated: YES];
}


#pragma mark - UITableViewDatasource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.bsDetails) {
        if (self.bsDetails.count == 0) {
//            self.headerView.hidden = YES;
            return 0;
        }
//        self.headerView.hidden = NO;
        return 15;
    }
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL forPaid = [self isForPaidOnly];
    
    switch (indexPath.row) {
        case 0: {
            if (forPaid) {
                return 51;
            }
            break;
        }
        case 1: {
            if (_bsDetails[@"shopphotos"] && [_bsDetails[@"shopphotos"] count] > 0)
                return 200;
        }
            break;
        case 2: {
            if (forPaid)
                return 46;
        }
            break;
        case 3: {
            if (VTTValidNSString(_bsDetails[@"address"])) {
                self.addressTextview.text = _bsDetails[@"address"];
                CGFloat height = [UITextView textViewHeightForTextView: self.addressTextview];
                return height + 10;
            }
        }
            break;
        case 4: {
            if (forPaid && VTTValidNSString(_forPaidOnly[@"openinghrs"])) {
                _openinghrsTextView.text = _forPaidOnly[@"openinghrs"];
                CGFloat height = [UITextView textViewHeightForTextView: self.openinghrsTextView];
                return height + 10;
            }
        }
            break;
        case 5: {
            if (VTTValidNSString(_bsDetails[@"telephone"])) {
                _telephoneTextView.text = _bsDetails[@"telephone"];
                CGFloat height = [UITextView textViewHeightForTextView:_telephoneTextView];
                return height + 10;
            }
            return 28;
        }
            break;
        case 6: {
            if (forPaid)
                return 30;
            break;
        }
        case 7: {
            if (forPaid && VTTValidNSString(_forPaidOnly[@"email"])) {
                self.emailTextView.text = _forPaidOnly[@"email"];
                CGFloat height = [UITextView textViewHeightForTextView: self.emailTextView];
                return height + 10;
            }
        }
            break;
        case 8:
        {
            if (forPaid && VTTValidNSString(_forPaidOnly[@"website"])) {
                self.websiteTextView.text = _forPaidOnly[@"website"];
                CGFloat height = [UITextView textViewHeightForTextView: self.websiteTextView];
                return height + 10;
            }
        }
            break;
        case 9:
        {
            if (forPaid && VTTValidNSString(_forPaidOnly[@"bikes_avail"])) {
                self.bikeAvailTextView.text = _forPaidOnly[@"bikes_avail"];
                CGFloat height = [UITextView textViewHeightForTextView: self.bikeAvailTextView];
                return height + 10;
            }
        }
            break;
        case 10:
        {
            if (forPaid && VTTValidNSString(_forPaidOnly[@"mechanic_svcs"])) {
                self.mechanicTextView.text = _forPaidOnly[@"mechanic_svcs"];
                CGFloat height = [UITextView textViewHeightForTextView: self.mechanicTextView];
                return height + 10;
            }
        }
            break;
        case 11:
        {
            if (forPaid && VTTValidNSString(_forPaidOnly[@"delivery"])) {
                self.deliveryTextView.text = _forPaidOnly[@"delivery"];
                CGFloat height = [UITextView textViewHeightForTextView: self.deliveryTextView];
                return height + 10;
            }
        }
            break;
        case 12: {
            if (forPaid) {
                BOOL isNewItem = (VTTValidNSString(_forPaidOnly[@"new_item"]) || (_forPaidOnly[@"new_item_cnt"] && [_forPaidOnly[@"new_item_cnt"] integerValue] != 0));
                BOOL isPromos = (VTTValidNSString(_forPaidOnly[@"promo"]) || (_forPaidOnly[@"promo_cnt"] && [_forPaidOnly[@"promo_cnt"] integerValue] != 0));
                if (isNewItem || isPromos) {
                    return 150;
                }
            }
        }
            break;
        case 13: {
            if (forPaid) {
                NSDictionary *brandsDist = _forPaidOnly[@"brands_dist"];
                if (brandsDist && ![[NSNull null] isEqual: brandsDist] && [brandsDist count] > 0) {
                    if ([brandsDist count] > 6) {
                        return 300;
                    } else if ([brandsDist count] > 3) {
                        return 200;
                    } else {
                        return 120;
                    }
                } else {
                    return 0;
                }
            }
        }
            break;
        case 14: {

            if (forPaid && VTTValidNSString(_forPaidOnly[@"brands_retailed"])) {
                _retailTextView.text = _forPaidOnly[@"brands_retailed"];
                CGFloat height = [UITextView textViewHeightForTextView: _retailTextView];
                return height + 10;
            }
        }
            break;

            
        default:
            break;
    }
    return 0;
}

#pragma mark - UICollectionViewDatasource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _mainCollectionView) {
        if (_mainPictureURLs) return _mainPictureURLs.count;
    } else {
        if ([self isForPaidOnly]) {
        NSDictionary *brandsDist = _forPaidOnly[@"brands_dist"];
        if (![[NSNull null] isEqual: brandsDist] && [_forPaidOnly[@"brands_dist"] count] > 0) return [_forPaidOnly[@"brands_dist"] count];
        }
    }
    
    return 0;
}
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _mainCollectionView) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];
        UIImageView *imageView = (UIImageView *) [cell viewWithTag: 1];
        [imageView setImageWithURL: [NSURL URLWithString: _mainPictureURLs[indexPath.row]] placeholderImage: [UIImage imageNamed: @"image264x216"]];
        
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];
        UIImageView *imageView = (UIImageView *) [cell viewWithTag: 1];
        UILabel *label = (UILabel *) [cell viewWithTag: 2];
        NSDictionary *brandist = _forPaidOnly[@"brands_dist"][indexPath.row];
        if (VTTValidNSString(brandist[@"img"])) {
            label.hidden = YES;
            [imageView setImageWithURL: [NSURL URLWithString: brandist[@"img"]] placeholderImage: [UIImage imageNamed: @"image264x216"]];
        } else {
            label.hidden = NO;
            label.text = brandist[@"name"];
        }
        
        return cell;
    }
    
    return nil;
}

@end

//
//  OSAdDetailViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/21/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSAdDetailViewController.h"
#import "OSBikeshopDetailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "UIColor+VTTHelpers.h"
#import "OSListingViewController.h"
#import "UITextView+VTTHelpers.h"
#import "UIImage+animatedGIF.h"
#import "OSImageView.h"

#import "GoogleMobileAds/GoogleMobileAds.h"
//#import "DFPBannerView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import <FacebookSDK/FacebookSDK.h>
#import "OSLabel.h"
#import "OSCommentViewController.h"
#import "OSCommentCell.h"
#import "OSPostViewController.h"
#import "OSTabBarViewController.h"

CGFloat const kMaxItemDetailScale = 2.0f;
CGFloat const kMinItemDetailScale = 1.0f;

@interface OSAdDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>
{
    UITapGestureRecognizer *tapRecognizer;
    UITapGestureRecognizer *doubleTapRecognizer;
}

#pragma mark - Gemeral and images
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceDifAndFirmLabel;
@property (weak, nonatomic) IBOutlet UIButton *shortlistAdButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UICollectionView *mainSliderView;
@property (weak, nonatomic) IBOutlet UIView *mainSliderOverlay;
@property (weak, nonatomic) IBOutlet UILabel *soldLabel;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *adDetailOverlayView;
//@property (weak, nonatomic) IBOutlet UICollectionView *addDetailsCollectionView;
@property (strong, nonatomic) IBOutlet OSImageView *productImageViewer;

#pragma mark - Main Info
@property (weak, nonatomic) IBOutlet UIView *clearanceBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *clearanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nItemImageView;
@property (weak, nonatomic) IBOutlet UIImageView *priorityImageview;
@property (weak, nonatomic) IBOutlet UIView *adTypeBackground;
@property (weak, nonatomic) IBOutlet UILabel *adTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UICollectionView *attributesCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *postedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedByDetail;
@property (weak, nonatomic) IBOutlet UIImageView *positiveIcon;
@property (weak, nonatomic) IBOutlet UIImageView *neutralIcon;
@property (weak, nonatomic) IBOutlet UIImageView *negativeIcon;
@property (weak, nonatomic) IBOutlet OSLabel *positiveLabel;
@property (weak, nonatomic) IBOutlet OSLabel *neutralLabel;
@property (weak, nonatomic) IBOutlet OSLabel *negativeLabel;
@property (weak, nonatomic) IBOutlet UIButton *seachByPostedByButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeToContactLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToContactDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *addressDetailTextView;
@property (weak, nonatomic) IBOutlet UILabel *viewLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *relatedProductsLabel;

@property (strong, nonatomic) DFPBannerView *bannerView;

@property (nonatomic, strong) NSArray *phoneNumbers;
@property (nonatomic, strong) NSString *emailAddress;

#pragma mark - Action Buttons
@property (weak, nonatomic) IBOutlet UIButton *smsButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@property (weak, nonatomic) IBOutlet UIButton *viewMoreComments;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;

#pragma mark - Related Slider
@property (weak, nonatomic) IBOutlet UICollectionView *relatedSilder;

@property (nonatomic, strong) NSDictionary *adDetails;

@property (nonatomic, strong) NSArray *mainPictureURLs;
@property (nonatomic, strong) NSArray *relatedAds;
@end

@implementation OSAdDetailViewController

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
//    _aid = @"713488"; //For comment test
//    _aid = @"737785"; //For time to contact test
    
    //previousScale = 1;
    
    self.title = @"Ad Details";
    
    //Data
    _adDetails = [NSDictionary new];
    _mainPictureURLs = [NSArray new];
    _relatedAds = [NSArray new];
    
    //Views
    OSChangeTogoFontForLabel(_titleLabel)
    OSChangeTogoFontForLabel(_priceLabel)
    OSChangeTogoFontForLabel(_priceDifAndFirmLabel)
    OSChangeTogoFontForLabel(_soldLabel)
    
    OSChangeTogoFontForLabel(_descriptionLabel)
//    OSChangeTogoFontForLabel(_descriptionDetails)
    OSChangeTogoFontForLabel(_postedByLabel)
    OSChangeTogoFontForLabel(_postedByDetail)
    OSChangeTogoFontForLabel(_sizeLabel)
    OSChangeTogoFontForLabel(_sizeDetailLabel)
    OSChangeTogoFontForLabel(_shopLabel)
    OSChangeTogoFontForLabel(_shopDetailLabel)
    OSChangeTogoFontForLabel(_contactLabel)
    OSChangeTogoFontForLabel(_contactDetailLabel)
    OSChangeTogoFontForLabel(_timeToContactLabel)
    OSChangeTogoFontForLabel(_timeToContactDetailLabel)
    OSChangeTogoFontForLabel(_addressLabel)
    _addressDetailTextView.font = [UIFont fontWithName: OSTogoFontName size: _addressDetailTextView.font.pointSize];
    OSChangeTogoFontForLabel(_relatedProductsLabel)
    
   [_commentsTableView registerNib:[UINib nibWithNibName: @"OSCommentCell" bundle: nil] forCellReuseIdentifier:@"Cell"];
    _commentsTableView.dataSource = self;
    
    if (_showSearchButton) {
        UIButton *searchButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
        [searchButton addTarget:self action: @selector(searchButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        [searchButton setImage: [UIImage imageNamed: @"top-search-button"] forState: UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: searchButton];
    }
    if (_showEditButton) {
        self.navigationItem.rightBarButtonItem = [OSHelpers barButtonItemWithImage:[UIImage imageNamed: @"edit"] target:self selector:@selector(editButtonClicked:)];
    }
    
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
        [backButton addTarget:self action: @selector(backButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        [backButton setImage: [UIImage imageNamed: @"top-back-button"] forState: UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    }
    
    UITapGestureRecognizer *logoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(shopTapped:)];
    self.logoImageView.userInteractionEnabled = YES;
    [self.logoImageView addGestureRecognizer: logoTap];
    
    UITapGestureRecognizer *shopTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(shopTapped:)];
    self.shopDetailLabel.userInteractionEnabled = YES;
    [self.shopDetailLabel addGestureRecognizer: shopTap];
    
    [_adDetailOverlayView removeFromSuperview];
    [_adDetailOverlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    [_productImageViewer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    _adDetailOverlayView.multipleTouchEnabled = YES;
    _adDetailOverlayView.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer;
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                         action:@selector(handleTapFrom:)];
    [_adDetailOverlayView addGestureRecognizer:recognizer];
    
    _productImageViewer.contentMode = UIViewContentModeScaleAspectFit;
    _productImageViewer.loadingImage = nil;
    _productImageViewer.tempDownloadedImageSavingEnabled = YES;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSLog(@"aid: %@", self.aid);
    [manager GET: @"http://www.togoparts.com/iphone_ws/mp_ad_details.php?source=ios" parameters: @{@"aid" : self.aid} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success ad detail: %@", responseObject);
        self.adDetails = responseObject;
        self.mainPictureURLs = responseObject[@"picture"];
        self.relatedAds = responseObject[@"related_ads"];
        
        [hud hide: YES];
        [self updateViews];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide: YES];
        NSLog(@"Failure ad detail: %@", operation.responseObject);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
//    UILabel *titleLabel = [[UILabel alloc] init];
//    titleLabel.backgroundColor = [UIColor redColor];
//    titleLabel.font = [UIFont fontWithName: OSTogoFontName size: 32.0f];
//    titleLabel.minimumScaleFactor = 0.75f;
//    titleLabel.text = self.title;
//    OSChangeTogoFontForLabel(titleLabel);
//    [titleLabel sizeToFit];
//    self.navigationItem.titleView = titleLabel;
}

CONFIGURE_DFP_BANNER_AD
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    //Google Analytics
    if (self.showEditButton) {
        [OSHelpers sendGATrackerWithName: @"Marketplace Manage Ads Details"];
    } else {
        [OSHelpers sendGATrackerWithName: @"Marketplace Ad Details"];
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

-(void) updateViews {
    /***********************
        Header
     ************************/
//    self.title = _adDetails[@"title"];
    self.titleLabel.text = _adDetails[@"title"];
    self.priceLabel.text = _adDetails[@"price"];
    NSMutableAttributedString *saveAndFirmAttr = [[NSMutableAttributedString alloc] init];
    
    
    NSMutableAttributedString *firmAttr;
    NSMutableAttributedString *saveAttr;
    NSMutableAttributedString *dashAttr;
    if (_adDetails[@"firm_neg"] && ![_adDetails[@"firm_neg"] isEqualToString: @""]) {
        firmAttr = [[NSMutableAttributedString alloc] initWithString: _adDetails[@"firm_neg"] attributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
    
    if (_adDetails[@"price_percent_diff"] && ![_adDetails[@"price_percent_diff"] isEqualToString: @"0"]) {
        saveAttr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @"Save %@", _adDetails[@"price_percent_diff"]] attributes: @{NSForegroundColorAttributeName : OSYellowColor}];
    }
    
    dashAttr = [[NSMutableAttributedString alloc] initWithString: @" - " attributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    if (firmAttr && saveAttr) {
        [saveAndFirmAttr insertAttributedString: firmAttr atIndex: 0];
        [saveAndFirmAttr insertAttributedString: dashAttr atIndex: saveAndFirmAttr.length];
        [saveAndFirmAttr insertAttributedString: saveAttr atIndex: saveAndFirmAttr.length];
    } else if (firmAttr) {
        [saveAndFirmAttr insertAttributedString: firmAttr atIndex: 0];
    } else if (saveAttr) {
        [saveAndFirmAttr insertAttributedString: saveAttr atIndex: 0];
    }
    
    self.priceDifAndFirmLabel.attributedText = saveAndFirmAttr;
    
    
    
    /***********************
        Top buttons and Slider
     ************************/
    
    NSArray *shortListArray = [[NSUserDefaults standardUserDefaults] valueForKey: @"ToGoShortList"];
    if (shortListArray && shortListArray.count > 0) {
        for (NSString *aid in shortListArray) {
            if ([aid isEqualToString: _adDetails[@"aid"]]) {
                [self.shortlistAdButton setImage: [UIImage imageNamed: @"shortlist-button-selected"] forState: UIControlStateNormal];
            }
        }
    }
    
    //Canonical url for facebook share
    if (_adDetails[@"canonical_url"] && ![_adDetails[@"canonical_url"] isEqualToString:@""]) {
        _shareButton.hidden = NO;
    } else {
        _shareButton.hidden = YES;
    }
    
    //Main Slider Overlay
    _mainSliderOverlay.backgroundColor = [UIColor clearColor];
    _soldLabel.hidden = YES;
    _mainSliderOverlay.hidden = YES;
    NSArray *adStatuses = @[@"Sold", @"Found", @"Given", @"Exchanged"];
    NSString *adStatus = _adDetails[@"adstatus"];
    if (adStatus) {
        for (NSString *status in adStatuses) {
            if ([adStatus compare: status options: NSCaseInsensitiveSearch] == NSOrderedSame) {
                _soldLabel.hidden = NO;
                _soldLabel.text = [adStatus uppercaseString];
                _mainSliderOverlay.backgroundColor = [UIColor colorWithWhite: 0.0f alpha:0.3f];
                _mainSliderOverlay.hidden = NO;
            }
        }
    }

    
    if (_mainPictureURLs.count > 1) {
        _prevButton.hidden = NO;
        _nextButton.hidden = NO;
    } else {
        _prevButton.hidden = YES;
        _nextButton.hidden = YES;
    }
    [self.mainSliderView reloadData];
    
    
    /***********************
        Small labels
     *************************/
//    special":{"text":"CLEARANCE","bgcolor":"#FF0000","textcolor":"#FFFFFF"},
    NSDictionary *special = _adDetails[@"special"];
    _clearanceBackgroundView.hidden = YES;
    if (special && special.count > 0) {
        UIColor *bgColor = OSRedColor; UIColor *textColor = [UIColor whiteColor];
        if (special[@"bgcolor"]) bgColor = [UIColor colorFromHexCode:special[@"bgcolor"]];
        if (special[@"textcolor"]) textColor = [UIColor colorFromHexCode: special[@"textcolor"]];
        _clearanceBackgroundView.hidden = NO;
        _clearanceBackgroundView.backgroundColor = bgColor;
        _clearanceLabel.textColor = textColor;
        _clearanceLabel.text = special[@"text"];
    }
    
    NSString *listingLabel = _adDetails[@"listinglabel"];
    
    _nItemImageView.hidden = YES;
    _priorityImageview.hidden = YES;
    if (!listingLabel || [listingLabel isEqualToString:@"standard"] || [listingLabel isEqualToString: @""]) {
        _nItemImageView.hidden = YES;
        _priorityImageview.hidden = YES;
    } else {
        if ([listingLabel compare: @"NEW ITEM" options: NSCaseInsensitiveSearch] == NSOrderedSame) _nItemImageView.hidden = NO;
        if ([listingLabel compare: @"PRIORITY" options: NSCaseInsensitiveSearch] == NSOrderedSame) _priorityImageview.hidden = NO;
    }
    
    //Ad type
    if (_adDetails[@"adtype"] && ![_adDetails[@"adtype"] isEqualToString: @""]) {
        _adTypeBackground.hidden = NO;
        _adTypeLabel.text = _adDetails[@"adtype"];
    } else {
        _adTypeBackground.hidden = YES;
    }
    
    
    /***********************
        Main info
     ************************/
    _descriptionTextView.text = _adDetails[@"description"];
    
    
    if (_adDetails[@"Attributes"]) {
        [_attributesCollectionView reloadData];
    }
//    "postedby_details": {
//        "userid": "30372",
//        "username": "gpbikes"
//    },
    //Date & Postedby
    NSString *userName = _adDetails[@"postedby_details"][@"username"];
    [_seachByPostedByButton setTitle: [NSString stringWithFormat: @"Search ads by %@", userName] forState: UIControlStateNormal];
    NSDictionary *ratings = _adDetails[@"postedby_details"][@"ratings"];
    if (ratings) {
        _positiveLabel.text = [NSString stringWithFormat: @"%@", ratings[@"Positive"]];
        _negativeLabel.text = [NSString stringWithFormat: @"%@", ratings[@"Negative"]];
        _neutralLabel.text  = [NSString stringWithFormat: @"%@", ratings[@"Neutral"]];
    } else {
        _positiveLabel.hidden = YES;
        _negativeLabel.hidden = YES;
        _neutralLabel.hidden = YES;
        _positiveIcon.hidden = YES;
        _neutralIcon.hidden = YES;
        _negativeIcon.hidden = YES;
//        _positiveLabel.text = @"0";
//        _negativeLabel.text = @"0";
//        _neutralLabel.text = @"0";
        
    }
    
    NSString *datePost = [NSString stringWithFormat: @"%@ on %@", userName, _adDetails[@"dateposted"]];
    NSMutableAttributedString *datePostAttr = [[NSMutableAttributedString alloc] initWithString: datePost];
    [datePostAttr addAttribute:NSForegroundColorAttributeName value: [UIColor darkGrayColor] range: NSMakeRange(0, datePost.length)];
    [datePostAttr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range: [datePost rangeOfString: userName]];
    _postedByDetail.attributedText = datePostAttr;
    
    self.messageLabel.text = _adDetails[@"msg_sent"];
    self.viewLabel.text = _adDetails[@"ad_views"];
    if (_adDetails[@"size"] && ![_adDetails[@"size"] isEqualToString: @""]) {
        self.sizeDetailLabel.text = _adDetails[@"size"];
    } else {
        self.sizeDetailLabel.text = @"N-A";
    }
    
    //    "contact_details": {
    //        "shop_logo": "http://www.togoparts.com/bikeshops/images/shop/logo-small-211.jpg",
//        "contact_email": "gpbike@singnet.com.sg",
//        "contact": {
//            "label": "Shop",
//            "value": "gpbikes"
//        },
//        "location": {
//            "label": "Address",
//            "value": "199 Upper Paya Lebar Road, Singapore 534875"
//        },
//        "contactno": {
//            "label": "Telephone",
//            "value": "62892787"
//        }
    
    //Contact
    NSDictionary *contactDetails = _adDetails[@"contact_details"];
    
    NSString *shopLogo = contactDetails[@"shop_logo"];
    if (shopLogo && ![shopLogo isEqualToString: @""]) {
        _logoImageView.hidden = NO;
        [_logoImageView setImageWithURL: [NSURL URLWithString: shopLogo]];
    } else {
        _logoImageView.hidden = YES;
    }
    
    NSDictionary *contact = contactDetails[@"contact"];
    self.shopLabel.text = contact[@"label"];
    _shopDetailLabel.text = contact[@"value"];
    
    NSDictionary *location = contactDetails[@"location"];
    _addressLabel.text = location[@"label"];
    _addressDetailTextView.text = location[@"value"];
//    [_addressDetailLabel sizeToFit];
    
    NSDictionary *contactNo = contactDetails[@"contactno"];
    self.contactLabel.text = contactNo[@"label"];
    self.contactDetailLabel.text = contactNo[@"value"];
    
    
    NSDictionary *timeToContacts = _adDetails[@"contact_details"][@"timetocontact"];
    if (timeToContacts) {
        _timeToContactLabel.hidden = NO;
        _timeToContactDetailLabel.hidden = NO;
        _timeToContactLabel.text = timeToContacts[@"label"];
        _timeToContactDetailLabel.text = timeToContacts[@"value"];
    } else {
        _timeToContactLabel.hidden = YES;
        _timeToContactDetailLabel.hidden = YES;
    }
    
    self.smsButton.hidden = YES;
    self.emailAddress = contactDetails[@"contact_email"];
    self.phoneNumbers = contactDetails[@"contactno"][@"actualno"];
    for (NSString *number in self.phoneNumbers) {
        NSString *firstDigit = [number substringToIndex: 1];
        if ([firstDigit isEqualToString: @"8"] || [firstDigit isEqualToString: @"9"]) {
            self.smsButton.hidden = NO;
        }
    }
    
    /**********************
        Comments
     ***********************/
//    NSMutableDictionary *newDetails = [NSMutableDictionary dictionaryWithDictionary: _adDetails];
//    [newDetails addEntriesFromDictionary: @{@"total_messages": @3,
//                                           @"messages": @[
//                                                        @{
//                                                            @"username": @"nestorvie",
//                                                            @"picture": @"http://www.togoparts.com/members/avatars/icons/10-3.gif",
//                                                            @"message": @"Hi, are you sure this one is a CAAD? I tried to look for the info but their CAAD model is for road bike. ",
//                                                            @"datesent": @"31st Jul 2014 5:00 PM"
//                                                        },
//                                                        @{
//                                                            @"username": @"finn29",
//                                                            @"picture": @"http://www.togoparts.com/members/avatars/icons/10-9.gif",
//                                                            @"message": @"This is the exact model Tks ",
//                                                            @"datesent": @"31st Jul 2014 6:54 PM"
//                                                        },
//                                                        @{
//                                                            @"username": @"finn29",
//                                                            @"picture": @"http://www.togoparts.com/members/avatars/icons/10-9.gif",
//                                                            @"message": @"This is the exact model Tks ",
//                                                            @"datesent": @"31st Jul 2014 6:54 PM"
//                                                        }
//                                                        ]}];
//    _adDetails = newDetails;
    
    NSInteger messageNumber = [_adDetails[@"total_messages"] integerValue];
//    NSArray *messages = _adDetails[@"messages"];
    
    if (messageNumber > 3) {
        [_viewMoreComments setTitle: [NSString stringWithFormat: @"View %li more ealier comments", messageNumber - 3] forState: UIControlStateNormal];
        OSChangeTogoFontForLabel(_viewMoreComments.titleLabel);
        _viewMoreComments.hidden = NO;
    } else {
        _viewMoreComments.hidden = YES;
    }
    
    /**********************
        Related products
     ***********************/
    if (self.relatedAds.count <= 0) {
        self.relatedProductsLabel.text = @"No Related Products";
    } else {
        self.relatedProductsLabel.text = @"Related Products:";
    }
    [self.relatedSilder reloadData];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
-(void) editButtonClicked: (id) sender {
    UINavigationController *postNVC = [self.storyboard instantiateViewControllerWithIdentifier: @"PostNVC"];
    OSPostViewController *postVC = postNVC.viewControllers[0];
    postVC.aid = self.aid;
    postVC.delegate = (OSTabBarViewController *) self.tabBarController;
    [self presentViewController: postNVC animated: YES
                     completion: nil];
}
-(void) shopTapped: (UITapGestureRecognizer *) tap {
    if (_adDetails[@"contact_details"] && _adDetails[@"contact_details"][@"sid"]) {
        OSBikeshopDetailViewController *bsVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSBikeshopDetailViewController"];
        bsVC.sid = _adDetails[@"contact_details"][@"sid"];
        [self.navigationController pushViewController: bsVC animated: YES];
    }
}
-(void) searchButtonClicked: (id) sender {
    [self.navigationController.tabBarController setSelectedIndex: TOGOSearchControllerIndex];
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
    if ([buttonTitle isEqualToString: @"Cancel"]) return;
    
    if ([actionSheet.title isEqualToString: @"SMS a number"]) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"id": _adDetails[@"aid"], @"fktype": @"aid", @"category": @"sms_iphone"};
        [manager POST:@"http://www.togoparts.com/iphone_ws/contact_log.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Logged sms successfully");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Logged sms failed: %@", operation.response);
            NSLog(@"Error: %@", error.localizedDescription);
        }];
        
        NSURL *smsURL = [NSURL URLWithString: [NSString stringWithFormat: @"sms:%@", buttonTitle]];
        [[UIApplication sharedApplication] openURL: smsURL];
        
    } else if ([actionSheet.title isEqualToString: @"Call a number"]) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"id": _adDetails[@"aid"], @"fktype": @"aid", @"category": @"call_iphone"};
        [manager POST:@"http://www.togoparts.com/iphone_ws/contact_log.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Logged call successfully");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Logged call failed: %@ %@", operation.response, operation.request);
            NSLog(@"Error: %@", error.localizedDescription);
        }];
        
        NSURL *callURL = [NSURL URLWithString: [NSString stringWithFormat: @"tel:%@", buttonTitle]];
        [[UIApplication sharedApplication] openURL: callURL];
    }
}

- (IBAction)smsButtonClicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: @"SMS a number" delegate: self cancelButtonTitle: nil destructiveButtonTitle: nil otherButtonTitles:nil];
    for (NSString *number in _phoneNumbers) {
        [actionSheet addButtonWithTitle: number];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = [_phoneNumbers count];
    [actionSheet showFromTabBar: self.navigationController.tabBarController.tabBar];

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
    NSURL *emailURL = [NSURL URLWithString: [NSString stringWithFormat: @"mailto:%@", _emailAddress]];
    [[UIApplication sharedApplication] openURL: emailURL];
}

- (IBAction)previousButtonClicked:(id)sender {
    CGPoint originPoint = CGPointMake(_mainSliderView.contentOffset.x + _mainSliderView.frame.size.width/2, _mainSliderView.contentOffset.y + _mainSliderView.frame.size.height/2);
    NSIndexPath *indexPath = [self.mainSliderView indexPathForItemAtPoint: originPoint];
    if (indexPath.item > 0) {
        [self.mainSliderView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem: indexPath.row - 1 inSection: indexPath.section] atScrollPosition:UICollectionViewScrollPositionNone animated: YES];
    }
}
- (IBAction)nextButtonClicked:(id)sender {
    CGPoint originPoint = CGPointMake(_mainSliderView.contentOffset.x + _mainSliderView.frame.size.width/2, _mainSliderView.contentOffset.y + _mainSliderView.frame.size.height/2);
    NSIndexPath *indexPath = [self.mainSliderView indexPathForItemAtPoint: originPoint];
    if (indexPath.item < _mainPictureURLs.count - 1) {
        [self.mainSliderView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem: indexPath.row + 1 inSection: indexPath.section] atScrollPosition:UICollectionViewScrollPositionNone animated: YES];
    }
}

- (IBAction)shortListAdButtonClicked:(id)sender {
    NSArray *shortListArray = [[NSUserDefaults standardUserDefaults] valueForKey: @"ToGoShortList"];
    NSMutableOrderedSet *shortListSet = [NSMutableOrderedSet orderedSetWithArray: shortListArray];
    NSLog(@"shortList array: %@", shortListArray);
    if (shortListSet) {
        if (shortListSet.count >= 50) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Shortlist is full" message: @"Please remove some ad in shortlist before adding more" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            [shortListSet addObject: _aid];
        }
        shortListArray = [shortListSet array];
    } else {
        shortListArray = @[_aid];
    }
    [[NSUserDefaults standardUserDefaults] setObject: shortListArray forKey: @"ToGoShortList"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Shortlisted Ad" message: @"You can view your shortlisted ads in Shortlisted Ads tab" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [alertView show];
    
    [self.shortlistAdButton setImage: [UIImage imageNamed: @"shortlist-button-selected"] forState: UIControlStateNormal];
}

- (IBAction)searchByUsernameButtonClicked:(id)sender {
    if (_adDetails[@"postedby_details"][@"username"])
    {
        OSListingViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
        listingVC.isSearch = YES;
        listingVC.parameters = @{@"usersearchname": _adDetails[@"postedby_details"][@"username"]};
        listingVC.showFilterButton = NO;
        [self.navigationController pushViewController: listingVC animated: YES];
    }
}

- (IBAction)shareButtonClicked:(id)sender {
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set: kGAIScreenName value:@"Marketplace Share"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    NSString *url = _adDetails[@"canonical_url"];
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString: url];
//    params.name = @"Sharing Tutorial";
//    params.caption = @"Build great social apps and get more installs.";
//    params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
//    params.description = @"Allow your users to share stories on Facebook from your app using the iOS SDK.";
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink: [NSURL URLWithString: url]
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              NSLog(@"Error: %@", error.description);
                                          } else {
                                              NSLog(@"Success!");
                                          }
                                      }];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       url, @"link",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"%@", [NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (IBAction)viewMoreCommentButtonClicked:(id)sender {
    OSCommentViewController *commentVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSCommentViewController"];
//    commentVC.data = _adDetails[@"messages"];
    commentVC.aid = _aid;
    [self.navigationController pushViewController:commentVC animated: YES];
}
#pragma mark - UITableViewDatasource
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        return [super tableView: tableView cellForRowAtIndexPath:indexPath];
    } else if (tableView == self.commentsTableView) {
        OSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath:indexPath];
        NSDictionary *rowData = _adDetails[@"messages"][indexPath.row];
        [cell configureCellWithRowData: rowData];
        return cell;
    }
    return nil;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (self.adDetails) {
            if (self.adDetails.count == 0) {
                self.headerView.hidden = YES;
                return 0;
            }
            self.headerView.hidden = NO;
            return 13;
        }
        return 0;
    } else if (tableView == self.commentsTableView) {
        NSInteger messageNumber = [_adDetails[@"total_messages"] integerValue];
        if (messageNumber > 3) {
            return 3;
        } else {
            return messageNumber;
        }
    }
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        switch (indexPath.row) {
            case 0:
                if (self.adDetails[@"picture"] && [self.adDetails[@"picture"] count] > 0) {
                    self.mainSliderOverlay.hidden = NO;
                    return 200;
                } else {
                    //Need to hide this because Sold label doesn't collaps to 0 height
                    self.mainSliderOverlay.hidden = YES;
                    return 0;
                }
                break;
            case 1:{
                return 52;
            }
                break;
            case 2:
                return 34;
                break;
            case 3:{
                self.descriptionTextView.text = self.adDetails[@"description"];
                CGFloat height = [UITextView textViewHeightForTextView: self.descriptionTextView];
                return height + 10; //Add 10 so that the UITextview doesn't scroll
            }
                break;
            case 4:
                if (self.adDetails[@"Attributes"]) {
                    NSInteger count = [_adDetails[@"Attributes"] count];
                    return (floorf(count / 2) + (count % 2 == 0 ? 0 : 1)) * 32 + 10 + 10; //10 + 10 is bottom + top padding
                }
                break;
            case 5:
                return 142;
                break;
            case 6: {
                if (_adDetails[@"contact_details"][@"timetocontact"]) {
                    return 28;
                } else {
                    return 0;
                }
            }
                break;
            case 7: {
                CGFloat height = [UITextView textViewHeightForTextView: _addressDetailTextView];
                return height;
            }
                break;
            case 8:
                return 38;
                break;
            case 9:
                return 46;
                break;
            case 10: {
                NSInteger messageNumber = [_adDetails[@"total_messages"] integerValue];
                if (messageNumber >= 1) {
                    return 33;
                } else {
                    return 0;
                }
            }
                break;
            case 11:{
                NSInteger messageNumber = [_adDetails[@"total_messages"] integerValue];
                CGFloat padding = 44;
                CGFloat totalHeight = 0;
                for (NSInteger i = 0; i < 3; i++) {
                    if (i > messageNumber-1) break;
                    NSDictionary *rowData = _adDetails[@"messages"][i];
                    CGFloat height = [UITextView textViewHeightForText: rowData[@"message"] andWidth: 241.0f] + 5;
                    totalHeight += height + padding;
                }
                return totalHeight;
            }
                break;
            case 12:
                return 132;
                break;

            default:
                break;
        }
    } else if (tableView == self.commentsTableView) {
        CGFloat padding = 44;
        NSDictionary *rowData = _adDetails[@"messages"][indexPath.row];
        CGFloat height = [UITextView textViewHeightForText: rowData[@"message"] andWidth: 241.0f] + 5;
        return padding + height;
    }
    return 0;
}

#pragma mark - UICollectionViewController
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _mainSliderView) {
        return _mainPictureURLs.count;
    } else if (collectionView == _relatedSilder) {
        return _relatedAds.count;
    }else if (collectionView == _attributesCollectionView) {
        if (self.adDetails[@"Attributes"])
            return [self.adDetails[@"Attributes"] count];
    }
    
    return 0;
}
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _mainSliderView) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];
        UIImageView *imageView = (UIImageView *) [cell viewWithTag: 1];
        [imageView setImageWithURL: [NSURL URLWithString: _mainPictureURLs[indexPath.row][@"l"]] placeholderImage: [UIImage imageNamed: @"image600x600"]];
        return cell;
    }
    else if (collectionView == _relatedSilder)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];
        
        //Image view
        UIImageView *imageView = (UIImageView *) [cell viewWithTag: 1];
        NSDictionary *relatedAd = _relatedAds[indexPath.row];
        if (relatedAd[@"picture"] && ![relatedAd[@"picture"] isEqualToString: @""]) {
        [imageView setImageWithURL: [NSURL URLWithString: relatedAd[@"picture"]] placeholderImage: [UIImage imageNamed: @"image140x110"]];
        } else {
            [imageView setImage: [UIImage imageNamed: @"No_Image-140x110"]];
        }
        
        //Image
        UILabel *label = (UILabel *) [cell viewWithTag: 2];
        OSChangeTogoFontForLabel(label)
        label.text = relatedAd[@"title"];
        label.textAlignment = NSTextAlignmentCenter;
        UIView *overlay = (UILabel *) [cell viewWithTag: 3];
        overlay.backgroundColor = [UIColor colorWithWhite: 0.0f alpha: 0.3f];
        
        //Doesn't need adstatus (sold/available)
        return cell;
    } else if (collectionView == _attributesCollectionView) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];
        OSLabel *label = (OSLabel *) [cell viewWithTag: 1];
        OSLabel *value = (OSLabel *) [cell viewWithTag: 2];
        NSDictionary *rowData = self.adDetails[@"Attributes"][indexPath.row];
        label.text = rowData[@"label"];
        value.text = rowData[@"value"];
        return cell;
    }
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _relatedSilder) {
        NSDictionary *itemData = _relatedAds[indexPath.row];
        OSAdDetailViewController *adDetailVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSAdDetailViewController"];
        adDetailVC.aid = itemData[@"aid"];
        adDetailVC.showSearchButton = NO;
        [self.navigationController pushViewController: adDetailVC animated: YES];
    } else if (collectionView == _mainSliderView) {
        CGRect frame = self.view.frame;
        _adDetailOverlayView.frame = frame;
        if (self.view.bounds.size.width < self.view.bounds.size.height) {
            [_productImageViewer setFrame:CGRectMake(0, ((frame.size.height - frame.size.width) / 2),
                                                     frame.size.width, frame.size.width)];
        } else {
            [_productImageViewer setFrame:CGRectMake(0, ((frame.size.width - frame.size.height) / 2),
                                                     frame.size.width, frame.size.height)];
        }
        [self.navigationController.view addSubview:_adDetailOverlayView];
        [self.navigationController.view bringSubviewToFront:_adDetailOverlayView];
        [_adDetailOverlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:1]];
        
        //[UIView beginAnimations:@"fade in" context:nil];
        //[UIView setAnimationDuration:0.5];
        
        //[_adDetailOverlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:1]];
        [_productImageViewer setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.4]];
        
         NSMutableArray *productImages = [[NSMutableArray alloc] init];
         for(NSDictionary *dic in _mainPictureURLs)
         {
         [productImages addObject:[NSURL URLWithString:dic[@"l"]]];
         }
         _productImageViewer.imagesUrls = productImages;
        //_productImageViewer.delegate = self;
        [_productImageViewer setInitialPage:indexPath.row];
         
        //[UIView commitAnimations];
    }
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.headerView.frame = CGRectMake(0, self.tableView.contentOffset.y + self.tableView.contentInset.top, self.headerView.frame.size.width, self.headerView.frame.size.height);
}
-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        self.bannerView.frame = CGRectMake(0, scrollView.contentOffset.y + self.tableView.frame.size.height - self.tableView.contentInset.bottom, _bannerView.frame.size.width, _bannerView.frame.size.height);
    }
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    
    //CGPoint touch = [recognizer locationInView:recognizer.view];
    //if (CGRectContainsPoint(_productImageViewer.frame, touch))
    //    return;
    
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:1.0];
    
    [_adDetailOverlayView removeFromSuperview];
    
    [_adDetailOverlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    [_productImageViewer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    
    [UIView commitAnimations];
}

@end

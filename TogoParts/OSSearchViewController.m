//
//  OSSearchViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSSearchViewController.h"
#import "OSColorsPalette.h"
#import "OSPickerField.h"
#import "OSSearchTextField.h"
#import "OSListingViewController.h"
#import "UIImage+VTTHelpers.h"

#import <AFNetworking/AFNetworking.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface OSSearchViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet OSSearchTextField *postedByTextField;

@property (weak, nonatomic) IBOutlet OSPickerField *sizePickerField;
@property (weak, nonatomic) IBOutlet OSSearchTextField *sizeNumberField;
@property (weak, nonatomic) IBOutlet OSPickerField *unitField;

@property (weak, nonatomic) IBOutlet OSSearchTextField *budgetFromNumberField;
@property (weak, nonatomic) IBOutlet OSSearchTextField *budgetToNumberField;

@property (weak, nonatomic) IBOutlet OSPickerField *categoryPickerField;

@property (weak, nonatomic) IBOutlet OSPickerField *marketPickerField;
@property (weak, nonatomic) IBOutlet OSPickerField *bikeshopPickerField;

@property (weak, nonatomic) IBOutlet OSPickerField *typePickerField;
@property (weak, nonatomic) IBOutlet OSPickerField *statusPickerField;

@property (nonatomic, strong) UIToolbar *doneToolBar;

@property (nonatomic) NSString *searchText;

@property (nonatomic) NSString *userSearchName;

@property (nonatomic) NSString *size;
@property (nonatomic) NSInteger sizeValue;
@property (nonatomic) NSString *sizeUnit;

@property (nonatomic) NSInteger budgetFrom;
@property (nonatomic) NSInteger budgetTo;

@property (nonatomic) NSString *category;

@property (nonatomic) NSString *cid;
@property (nonatomic) NSString *sid;

@property (nonatomic) NSString *adType;

@property (nonatomic) NSString *adStatus;

@property (nonatomic, strong) NSArray * NSArray;
@property (nonatomic, strong) NSArray *sizeValues;

@property (nonatomic, strong) NSArray *unitKeys;
@property (nonatomic, strong) NSArray *unitValues;

@property (nonatomic, strong) NSArray *sortbyValues;
@property (nonatomic, strong) NSString *sort;

@property (nonatomic, strong) NSArray *statusKeys;
@property (nonatomic, strong) NSArray *statusValues;
@property (nonatomic, strong) NSArray *currentStatusKeys;
@property (nonatomic, strong) NSArray *currentStatusValues;

@property (nonatomic, strong) NSArray *typeKeys;
@property (nonatomic, strong) NSArray *typeValues;

@property (nonatomic, strong) NSDictionary *typeToStatus;
@end

@implementation OSSearchViewController

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
    
    self.tableView.backgroundColor = OSTableViewBackground;
    
    self.doneToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    if (VTTOSLessThan7) {
        self.doneToolBar.tintColor = OSTogoTintColor;
        [self.doneToolBar setBackgroundImage: [UIImage imageWithColor: OSTogoTintColor cornerRadius: 0.0f] forToolbarPosition:UIBarPositionAny barMetrics: UIBarMetricsDefault];
    } else {
        self.doneToolBar.barTintColor = OSTogoTintColor;
    }
    
   
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 44, 44)];
    [button setBackgroundImage: [UIImage imageWithColor: [UIColor clearColor] cornerRadius: 0.0f] forState: UIControlStateNormal];
    [button setTitle: @"Done" forState: UIControlStateNormal];
    [button addTarget: self action: @selector(doneBarButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: button];
    if (!VTTOSLessThan7) doneBarButtonItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem *stretch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
    self.doneToolBar.items = @[stretch, doneBarButtonItem];
    
    
    UIButton *applyButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
    [applyButton addTarget:self action: @selector(searchButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
    [applyButton setImage: [UIImage imageNamed: @"apply-button"] forState: UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: applyButton];
    
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 41, 41)];
        [backButton addTarget:self action: @selector(backButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        [backButton setImage: [UIImage imageNamed: @"top-back-button"] forState: UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    }
    
    //Parameters
    self.sortbyValues = @[@"1", @"2", @"3", @"4"];

//    Corresponding Ad Type and Ad Status:
//    All - All, Available, Sold, Looking, Found, Given, Exchanged
//    For sale - All, Available, Sold
//    Want to Buy - All, Looking, Found
//    Exchange + Cash - All, Available, Exchanged
//    Free! - All, Available, Given
    self.typeToStatus = @{@"All": @[@"All", @"Available", @"Sold", @"Looking", @"Found", @"Given", @"Exchanged"],
                          @"For sale": @[@"All", @"Available", @"Sold"], @"Want to Buy": @[@"All", @"Looking", @"Found"], @"Exchange + Cash": @[@"All", @"Available", @"Exchanged"], @"Free!": @[@"All", @"Available", @"Given"]};
    
    self.typeKeys = @[@"", @"1", @"2", @"4", @"3"];
    self.typeValues = @[@"All", @"For sale", @"Want to Buy", @"Exchange + Cash", @"Free!"];
    
    self.statusKeys = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6"];
    self.statusValues = @[@"All", @"Available", @"Sold", @"Looking", @"Found", @"Given", @"Exchanged"];
    
    //Populate value if it existed.
    if (_searchParams) {
        _searchText = _searchParams[@"searchtext"];
        _userSearchName = _searchParams[@"usersearchname"];
        _size = _searchParams[@"size"];
        _sizeValue = [_searchParams[@"sizeft"] integerValue];
        _sizeUnit = _searchParams[@"sizelb"];
        _budgetFrom = [_searchParams[@"bfrom"] integerValue];
        _budgetTo = [_searchParams[@"bto"] integerValue];
        _category = _searchParams[@"cat"];
        _cid = _searchParams[@"cid"];
        _sid = _searchParams[@"sid"];
        _adType = _searchParams[@"adtype"];
        _adStatus = _searchParams[@"status"];
        //Get the value
        NSString *typeValue = [self valueForString: _adType ofValueArray: self.typeKeys inKeyArray: self.typeValues];
        if (_adType) {
            [self updateStatusForTypeValue: typeValue];
        } else {
            [self updateStatusForTypeValue: _typeValues[0]];
        }
        
        if (_searchParams[@"usersearchname"]) _postedByTextField.text = _searchParams[@"usersearchname"];
        _sizePickerField.text = _searchParams[@"size"];
        if (_searchParams[@"sizeft"]) _sizeNumberField.text = [NSString stringWithFormat: @"%li", (long) [_searchParams[@"sizeft"] integerValue]];
        if (_searchParams[@"sizelb"]) _unitField.text = _searchParams[@"sizelb"];
        if (_searchParams[@"bfrom"]) _budgetFromNumberField.text = [NSString stringWithFormat: @"%li", (long) [_searchParams[@"bfrom"] integerValue]];
        if (_searchParams[@"bto"]) _budgetToNumberField.text = [NSString stringWithFormat: @"%li", (long) [_searchParams[@"bto"] integerValue]];
        if (_searchParams[@"cat"]) _categoryPickerField.text = _searchParams[@"cat"];
        //        if (_searchParams[@"cid"]) _marketPickerField.text = _searchParams[@"cid"];
        _statusPickerField.text = _searchParams[@"status"];
        
        NSInteger row;
        if (_searchParams[@"sort"]) {
            self.sort = _searchParams[@"sort"];
            row = [_searchParams[@"sort"] integerValue];
        } else {
            self.sort = @"3";
            row = 3;
        }
        //        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: row inSection: 0]];
        //        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        //        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 3 inSection: 0]];
        //        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _sort = @"3";
    }
    
    
    [self configureSizePickerField];
    [self configureUnitField];
    [self configureAdStatusPickerField];
    //    [self configureCategoryPickerField];
    [self configureMarketPickerField];
    [self configureTypeField];
    
    [self.tableView reloadData];
}

-(void) updateStatusForTypeValue: (NSString *) typeValue {
    self.currentStatusValues = self.typeToStatus[typeValue];
    NSMutableArray *currentKeys = [NSMutableArray new];
    for (NSString *value in self.currentStatusValues) {
        NSString *key = [self valueForString: value ofValueArray: self.statusValues inKeyArray: self.statusKeys];
        [currentKeys addObject: key];
    }
    self.currentStatusKeys = currentKeys;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];


}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    //Google Analytics
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set: kGAIScreenName value:@"Marketplace Filter Form"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) viewWillDisappear:(BOOL)animated {
    //Close all input view. not to mess up with previous VC content insets
    [self.view endEditing: YES];
    [super viewWillDisappear: animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) valueForString: (NSString *) string ofValueArray: (NSArray *) valueArray inKeyArray: (NSArray *) keyArray {
    for (NSInteger i=0; i < valueArray.count; i++) {
        if ([string isEqualToString: valueArray[i]]) {
            return keyArray[i];
        }
    }
    return nil;
    
//    NSArray *sizeKeys = @[@"fs", @"xxs", @"xs", @"s", @"ms", @"m", @"ml", @"l", @"xl", @"xxl", @"na"];
//    NSArray *sizeValues = @[@"Free Size", @"Extra Extra Small", @"Extra Small", @"Small", @"Medium Small", @"Medium", @"Medium Large", @"Large", @"Extra Large", @"Extra Extra Large", @"N-A"];
//    NSArray *unitKeys = @[@"n-a", @"C", @"cm", @"grams", @"inches", @"kg", @"lbs", @"mm", @"speed", @"teeth"];
//    NSArray *unitValues = @[@"n-a", @"C", @"cm", @"grams", @"inches", @"kg", @"lbs", @"mm", @"speed", @"teeth"];
//    NSArray *catKeys = @[@"1", @"2", @"3"];
//    NSArray *catValues = @[@"Commercial Merchants", @"Commercial Member", @"Priority"];
}
#pragma mark - Configuration
-(void) configureSizePickerField {
    //    fs = Free Size		xxs = Extra Extra Small
    //    xs = Extra Small	s = Small
    //    ms = Medium Small	m =Medium
    //    ml = Medium Large	l = Large
    //    xl = Extra Large		xxl = Extra Extra Large
    //    na = N-A
    
    NSArray *sizeKeys = @[@"", @"fs", @"xxs", @"xs", @"s", @"ms", @"m", @"ml", @"l", @"xl", @"xxl", @"na"];
    NSArray *sizeValues = @[@"All", @"Free Size", @"Extra Extra Small", @"Extra Small", @"Small", @"Medium Small", @"Medium", @"Medium Large", @"Large", @"Extra Large", @"Extra Extra Large", @"N-A"];
    
    
    if (!self.size)  {
//        self.size = @"fs"; //Default
    }
    self.sizePickerField.text = [self valueForString: _size ofValueArray: sizeKeys inKeyArray: sizeValues];
    if (_size && ![_size isEqualToString: @""]) {
        self.sizeNumberField.enabled = NO;
        self.sizeNumberField.backgroundColor = [UIColor lightGrayColor];
        self.sizeNumberField.text = Nil;
        self.unitField.label.enabled = NO;
        self.unitField.enabled = NO;
        self.unitField.backgroundColor = [UIColor lightGrayColor];
        self.unitField.text = nil;
    }
    __weak OSSearchViewController *weakSelf = self;
    
    self.sizePickerField.placeHolder = @"All";
    self.sizePickerField.componentsOfStrings = @[sizeValues];
    self.sizePickerField.changeBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        if (value) {
            for (NSInteger i=0; i < sizeValues.count; i++) {
                if ([value isEqualToString: sizeValues[i]]) {
                    weakSelf.size = sizeKeys[i];
                }
            }
        }
        //Disable sizeft and sizelb if size == @"All"
        if (value && ![value isEqualToString: sizeValues[0]]) {
            weakSelf.sizeNumberField.enabled = NO;
            weakSelf.sizeNumberField.backgroundColor = [UIColor lightGrayColor];
            weakSelf.sizeNumberField.text = Nil;
            weakSelf.unitField.label.enabled = NO;
            weakSelf.unitField.enabled = NO;
            weakSelf.unitField.backgroundColor = [UIColor lightGrayColor];
            weakSelf.unitField.text = nil;
        } else {
            weakSelf.sizeNumberField.enabled = YES;
            weakSelf.sizeNumberField.backgroundColor = [UIColor whiteColor];
            weakSelf.unitField.label.enabled = YES;
            weakSelf.unitField.enabled = YES;
            weakSelf.unitField.backgroundColor = [UIColor whiteColor];
        }
    };
    
    self.sizePickerField.doneBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        if (value) {
            for (NSInteger i=0; i < sizeValues.count; i++) {
                if ([value isEqualToString: sizeValues[i]]) {
                    weakSelf.size = sizeKeys[i];
                }
            }
        } else {
            //default
            [picker setText: sizeValues[0]];
            weakSelf.size = sizeKeys[0];
        }
    };
}

-(void) configureUnitField {
//    sizelb
//    
//values:
//    n-a = n-a		C = C
//    cm = cm		grams = grams
//    inches = inches		kg = kg
//    lbs = lbs		mm = mm
//    speed = speed		teeth =  teeth
    NSArray *unitKeys = @[@"n-a", @"C", @"cm", @"grams", @"inches", @"kg", @"lbs", @"mm", @"speed", @"teeth"];
    NSArray *unitValues = @[@"n-a", @"C", @"cm", @"grams", @"inches", @"kg", @"lbs", @"mm", @"speed", @"teeth"];
    self.unitKeys = unitKeys;
    self.unitValues = unitValues;
    
    if (!self.sizeUnit) {
//        self.sizeUnit = @"n-a"; //Default
    }
    self.unitField.text = [self valueForString: _sizeUnit ofValueArray: unitKeys inKeyArray: unitValues];
    
    __weak OSSearchViewController *weakSelf = self;
    
    self.unitField.placeHolder = @"n-a";
    self.unitField.componentsOfStrings = @[unitValues];
    self.unitField.doneBlock = ^(OSPickerField *picker) {
        
        //If user pick size number and pick the unit "n-a". Alert user that it is  not allowed
        if (_sizeNumberField.text && ![_sizeNumberField.text isEqualToString: @""]) {
            if (!picker.text || [picker.text isEqualToString: unitValues[0]]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Pick an unit" message: @"Please pick a valid unit" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [alertView show];
                picker.text = unitValues[1];
            }
        }
        
        NSString *value = picker.text;

        if (value) {
            for (NSInteger i=0; i < unitValues.count; i++) {
                if ([value isEqualToString: unitValues[i]]) {
                    weakSelf.sizeUnit = unitKeys[i];
                }
            }
        } else {
            //default
            [picker setText: unitValues[0]];
            weakSelf.sizeUnit = unitKeys[0];
        }
    };
}

-(void) configureTypeField {
    //    adtype
    //values:
    //    1 = For Sale
    //    2 = Want to Buy
    //    4 = Exchange + Cash
    //    3 = Free!
    NSArray *typeKeys = self.typeKeys;
    NSArray *typeValues = self.typeValues;
    
    if (self.adType) {
        self.typePickerField.text = [self valueForString: _adType ofValueArray: typeKeys inKeyArray: typeValues];
    } else  {
        //        self.category = @"1"; //Default
    }
    
    __weak OSSearchViewController *weakSelf = self;
    
    self.typePickerField.placeHolder = @"All";
    self.typePickerField.componentsOfStrings = @[typeValues];
    self.typePickerField.doneBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        if (value) {
            for (NSInteger i=0; i < typeValues.count; i++) {
                if ([value isEqualToString: typeValues[i]]) {
                    weakSelf.adType = typeKeys[i];
                }
            }
        } else {
            //default   
            [picker setText: typeValues[0]];
            weakSelf.adType = typeKeys[0];
        }
    };
    
    self.typePickerField.changeBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        if (value) {
            for (NSInteger i=0; i < typeValues.count; i++) {
                if ([value isEqualToString: typeValues[i]]) {
                    weakSelf.adType = typeKeys[i];
                    
                }
            }
        } else {
            //default
            [picker setText: typeValues[0]];
            weakSelf.adType = typeKeys[0];
        }
        
        //Change status
        weakSelf.adStatus = @"";
        //Selected 0-0 index:
        if (weakSelf.statusPickerField.pickerView)
            [weakSelf.statusPickerField.pickerView selectRow: 0 inComponent: 0 animated: NO];
        weakSelf.statusPickerField.text = nil;
        [weakSelf updateStatusForTypeValue: value];
        [weakSelf configureAdStatusPickerField];
    };
}

-(void) configureAdStatusPickerField {
//    status
//values:
//    0=All		1=Available
//    2=Sold		3=Looking
//    4=Found	5=Gone
//    6=Exchanged

    NSArray *statusKeys = self.currentStatusKeys;
    NSArray *statusValues = self.currentStatusValues;
    
    if (self.adStatus) {
        self.statusPickerField.text = [self valueForString: _adStatus ofValueArray: statusKeys inKeyArray: statusValues];
    }
    
    __weak OSSearchViewController *weakSelf = self;
    
    self.statusPickerField.placeHolder = @"All";
    self.statusPickerField.componentsOfStrings = @[statusValues];
    self.statusPickerField.doneBlock = ^(OSPickerField *picker) {
        NSString *value = picker.text;
        if (value) {
            for (NSInteger i=0; i < statusValues.count; i++) {
                if ([value isEqualToString: statusValues[i]]) {
                    weakSelf.adStatus = statusKeys[i];
                }
            }
        } else {
            //default
            [picker setText: statusValues[0]];
            weakSelf.adStatus = statusKeys[0];
        }
    };
}

//-(void) configureCategoryPickerField {
////    cat
////values:
////    1 = Commercial Merchants
////    2 = Commercial Member
////    3 = Priority
//    NSArray *catKeys = @[@"", @"1", @"2", @"3"];
//    NSArray *catValues = @[@"All", @"Commercial Merchants", @"Commercial Member", @"Priority"];
//    
//    if (self.category) {
//        self.categoryPickerField.text = [self valueForString: _category ofValueArray: catKeys inKeyArray: catValues];
//    } else  {
////        self.category = @"1"; //Default
//    }
//    
//    __weak OSSearchViewController *weakSelf = self;
//    
//    self.categoryPickerField.placeHolder = @"All";
//    self.categoryPickerField.componentsOfStrings = @[catValues];
//    self.categoryPickerField.doneBlock = ^(OSPickerField *picker) {
//        NSString *value = picker.text;
//        if (value) {
//            for (NSInteger i=0; i < catValues.count; i++) {
//                if ([value isEqualToString: catValues[i]]) {
//                    weakSelf.category = catKeys[i];
//                }
//            }
//        } else {
//            //default
//            [picker setText: catValues[0]];
//            weakSelf.category = catKeys[0];
//        }
//    };
//}


-(void) configureMarketPickerField {
    //TODO: marketPickerField is not used anymore. But you still need bikeshopPickerField
    self.marketPickerField.enabled = NO;
    self.bikeshopPickerField.enabled = NO;
    
    __weak OSSearchViewController *weakSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: @"http://www.togoparts.com/iphone_ws/mp_search_variables.php?source=ios" parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *marketKeys = [NSMutableArray new];
        NSMutableArray *marketValues = [NSMutableArray new];
        
        NSMutableArray *bikeshopKeys = [NSMutableArray new];
        NSMutableArray *bikeshopValues = [NSMutableArray new];
        
        //default
//        [marketKeys addObject: @""];
//        [marketValues addObject: @"All"];
        
        //Dynamic
        NSArray *markets = responseObject[@"mp_categories"];
        for (NSInteger i = 0; i < markets.count; i++) {
            [marketKeys addObject: markets[i][@"value"]];
            [marketValues addObject: markets[i][@"title"]];
        }
        
        NSArray *bikeShops = responseObject[@"bikeshops"];
        for (NSInteger i = 0; i < bikeShops.count; i++) {
            [bikeshopKeys addObject: bikeShops[i][@"value"]];
            [bikeshopValues addObject: bikeShops[i][@"shopname"]];
        }
        
        if (self.cid) {
            self.marketPickerField.text = [self valueForString: _cid ofValueArray: marketKeys inKeyArray: marketValues];
        } else  {
//            self.cid = @"1"; //Default
        }
        
        if (self.sid) {
            self.bikeshopPickerField.text = [self valueForString: _sid ofValueArray: bikeshopKeys inKeyArray:bikeshopValues];
        }
        
        weakSelf.marketPickerField.enabled = YES;
        weakSelf.marketPickerField.placeHolder = @"All";
        weakSelf.marketPickerField.componentsOfStrings = @[marketValues];
        weakSelf.marketPickerField.doneBlock = ^(OSPickerField *picker) {
            NSString *value = picker.text;
            if (value) {
                for (NSInteger i=0; i < marketValues.count; i++) {
                    if ([value isEqualToString: marketValues[i]]) {
                        weakSelf.cid = marketKeys[i];
                    }
                }
            }  else {
                //default
                [picker setText: marketValues[0]];
                weakSelf.cid = marketKeys[0];
            }
        };
        
        weakSelf.bikeshopPickerField.enabled = YES;
        weakSelf.bikeshopPickerField.placeHolder = @"All";
        weakSelf.bikeshopPickerField.componentsOfStrings = @[bikeshopValues];
        weakSelf.bikeshopPickerField.doneBlock = ^(OSPickerField *picker) {
            NSString *value = picker.text;
            if (value) {
                for (NSInteger i=0; i < bikeshopValues.count; i++) {
                    if ([value isEqualToString: bikeshopValues[i]]) {
                        weakSelf.sid = bikeshopKeys[i];
                    }
                }
            }  else {
                //default
                [picker setText: bikeshopValues[0]];
                weakSelf.sid = bikeshopKeys[0];
            }
        };
        weakSelf.bikeshopPickerField.changeBlock = ^(OSPickerField *picker) {
            NSString *value = picker.text;
            if (![value isEqualToString: bikeshopValues[0]]) {
                self.postedByTextField.enabled = NO;
                self.postedByTextField.backgroundColor = [UIColor lightGrayColor];
                self.postedByTextField.text = nil;
            } else {
                self.postedByTextField.backgroundColor = [UIColor whiteColor];
                self.postedByTextField.enabled = YES;
            }
        };
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Market Category Failure response: %@", operation.response);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

#pragma mark - Action

- (IBAction)searchButtonClicked:(id)sender {
//    _searchText = _searchParams[@"searchText"];
    if (self.postedByTextField.text)
        _userSearchName = self.postedByTextField.text;
    
    _budgetFrom = [self.budgetFromNumberField.text integerValue];
    _budgetTo = [self.budgetToNumberField.text integerValue];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    if (_searchText) parameters[@"searchtext"] = _searchText;
    if (_userSearchName) parameters[@"usersearchname"] = _userSearchName;
    if (_size) parameters[@"size"] = _size;
    if (_sizeNumberField.text && ![_sizeNumberField.text isEqualToString: @""]) {
        self.sizeValue = [_sizeNumberField.text integerValue];
        parameters[@"sizeft"] = @(_sizeValue);
    }
    if (_sizeUnit) parameters[@"sizelb"] = _sizeUnit;
    if (_budgetFromNumberField.text && ![_budgetFromNumberField.text isEqualToString: @""]) {
        _budgetFrom = [_budgetFromNumberField.text integerValue];
         parameters[@"bfrom"] = @(_budgetFrom);
    }
    if (_budgetToNumberField.text && ![_budgetToNumberField.text isEqualToString: @""]) {
        _budgetTo = [_budgetToNumberField.text integerValue];
        parameters[@"bto"] = @(_budgetTo);
    }
    if (_category) parameters[@"cat"] = _category;
    if (_cid) parameters[@"cid"] = _cid;
    if (_sid) parameters[@"sid"] = _sid;
    if (_adType) parameters[@"adtype"] = _adType;
    if (_adStatus) parameters[@"status"] = _adStatus;
    if (_sort) parameters[@"sort"] = _sort;

    self.searchParams = parameters;
    
    if ([self.delegate respondsToSelector: @selector(searchViewController:didSelectedParameters:)]) {
        [self.delegate searchViewController: self didSelectedParameters: parameters];
        
        if (_isFromMainSearch) {
            OSListingViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
            listingVC.parameters = parameters;
            listingVC.isSearch = YES;
            [self.navigationController pushViewController: listingVC animated: YES];
        } else {
            [self.navigationController popViewControllerAnimated: YES];
        }
    }

}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

-(void) doneBarButtonClicked: (id) sender {
    [self.view endEditing: YES];
}


- (IBAction)resetButtonClicked:(id)sender {
    [self.view endEditing: YES];
    self.postedByTextField.text = nil;
    self.sizePickerField.text = @"";
    self.sizeNumberField.text = nil;
    self.unitField.text = @"";
    self.budgetFromNumberField.text = nil;
    self.budgetToNumberField.text = nil;
    self.categoryPickerField.text = @"";
    self.statusPickerField.text = @"";
    self.marketPickerField.text = @"";
    self.bikeshopPickerField.text = @"";
    self.typePickerField.text = @"";
    
    self.userSearchName = nil;
    self.size = nil;
    self.sizeUnit = nil;
    self.category = nil;
    self.cid = nil;
    self.sid = nil;
    self.adType = nil;
    self.adStatus = nil;
    self.sort = @"3";
//    [self updateSortBy];
    
    //enable sizeNumber and Unit field
    self.sizeNumberField.enabled = YES;
    self.sizeNumberField.backgroundColor = [UIColor whiteColor];
    self.unitField.label.enabled = YES;
    self.unitField.enabled = YES;
    self.unitField.backgroundColor = [UIColor whiteColor];
    
    NSString *searchText = self.searchParams[@"searchtext"];
    if (searchText) {
        self.searchParams = @{@"searchtext": searchText};
    } else {
        self.searchParams = @{};
    }
    
    [self.tableView reloadData];
    
}
#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.inputAccessoryView = _doneToolBar;

    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    if (_sizeNumberField == textField) {
        if (_sizeNumberField.text && ![_sizeNumberField.text isEqualToString: @""]) {
            if (!_unitField.text || [_unitField.text isEqualToString: _unitValues[0]]) {
                _unitField.text =  _unitValues[1];
            }
        }
    }
    
    return YES;
}
#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger sortIndex = [_sort integerValue];
    if (sortIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
-(void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0 && indexPath.row < 5) {
        _sort = [NSString stringWithFormat: @"%zd", indexPath.row];
        [self.tableView reloadData];
        
//        for (NSInteger i = 1; i < 5; i++) {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:i inSection: 0]];
//            if (i != indexPath.row) {
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            } else {
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                _sort = [NSString stringWithFormat: @"%zd", i];
//            }
//        }
    }
}

@end

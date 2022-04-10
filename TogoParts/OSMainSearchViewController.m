//
//  OSMainSearchViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/27/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSMainSearchViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "OSListingViewController.h"
#import "OSSearchViewController.h"

#import "UIImage+VTTHelpers.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#import "OSPickerField.h"

@interface OSMainSearchViewController () <UISearchBarDelegate, OSSearchViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) UIToolbar *doneToolBar;
@property (nonatomic, strong) NSString *searchText;

@property (weak, nonatomic) IBOutlet OSPickerField *marketPickerField;
@end

@implementation OSMainSearchViewController

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
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"top-back-button"] target: self selector: @selector(backButtonClicked:)];
    }

    self.doneToolBar = [OSHelpers doneToolBarWithTarget: self selector:@selector(doneButtonClicked:)];
    self.searchBar.inputAccessoryView = self.doneToolBar;
    
    /*
    UIBarButtonItem *filterBarButton = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"filter-icon"] target: self selector:@selector(filterButtonClicked:)];
    self.navigationItem.rightBarButtonItem = filterBarButton;
    */
    
    if (_searchParams) {
//        OSListingViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
//        listingVC.parameters = _searchParams;
//        listingVC.isSearch = YES;
//        [self.navigationController pushViewController: listingVC animated: YES];
        
    } else {
        _searchParams = [NSMutableDictionary new];
    }
    
    if (VTTOSLessThan7) {
        self.searchBar.backgroundColor = [UIColor clearColor];
        [self.searchBar setBackgroundImage: [UIImage imageWithColor: [UIColor clearColor] cornerRadius: 0.0f]];
    }
    
    [self configureMarketPickerField];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    //Google Analytics
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set: kGAIScreenName value:@"Marketplace Search Form"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) configureMarketPickerField {
    self.marketPickerField.enabled = NO;
    
    __weak OSMainSearchViewController *weakSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: @"http://www.togoparts.com/iphone_ws/mp_search_variables.php?source=ios" parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *marketKeys = [NSMutableArray new];
        NSMutableArray *marketValues = [NSMutableArray new];
        
        //default
        //        [marketKeys addObject: @""];
        //        [marketValues addObject: @"All"];
        
        //Dynamic
        NSArray *markets = responseObject[@"mp_categories"];
        for (NSInteger i = 0; i < markets.count; i++) {
            [marketKeys addObject: markets[i][@"value"]];
            [marketValues addObject: markets[i][@"title"]];
        }

        
        if (self.searchParams && self.searchParams[@"cid"]) {
            self.marketPickerField.text = [self valueForString: self.searchParams[@"cid"] ofValueArray: marketKeys inKeyArray: marketValues];
        } else  {
            //            self.cid = @"1"; //Default
        }
        
        
        weakSelf.marketPickerField.enabled = YES;
        weakSelf.marketPickerField.placeHolder = @"All";
        weakSelf.marketPickerField.componentsOfStrings = @[marketValues];
        weakSelf.marketPickerField.doneBlock = ^(OSPickerField *picker) {
            NSString *value = picker.text;
            if (value) {
                for (NSInteger i=0; i < marketValues.count; i++) {
                    if ([value isEqualToString: marketValues[i]]) {
                        weakSelf.searchParams[@"cid"] = marketKeys[i];
                    }
                }
            }  else {
                //default
                [picker setText: marketValues[0]];
                weakSelf.searchParams[@"cid"] = marketKeys[0];
            }
        };
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Market Category Failure response: %@", operation.response);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

-(NSString *) valueForString: (NSString *) string ofValueArray: (NSArray *) valueArray inKeyArray: (NSArray *) keyArray {
    for (NSInteger i=0; i < valueArray.count; i++) {
        if ([string isEqualToString: valueArray[i]]) {
            return keyArray[i];
        }
    }
    return nil;
}

#pragma mark - Actions
-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)searchButtonClicked:(id)sender {
    
    NSMutableDictionary *parameters = self.searchParams;
    if (_searchText) parameters[@"searchtext"] = _searchText;
    
    OSListingViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSListingViewController"];
    listingVC.parameters = parameters;
    listingVC.isSearch = YES;
    [self.navigationController pushViewController: listingVC animated: YES];
}

-(void) doneButtonClicked: (id) sender {
    [self.view endEditing: YES];
}
-(void) filterButtonClicked: (id) sender {
    NSMutableDictionary *parameters = self.searchParams;
    if (_searchText) parameters[@"searchtext"] = _searchText;
    
    OSSearchViewController *filterVC = [self.storyboard instantiateViewControllerWithIdentifier: @"OSSearchViewController"];
    filterVC.searchParams = parameters;
    filterVC.delegate = self;
    filterVC.isFromMainSearch = YES;
    [self.navigationController pushViewController: filterVC animated: YES];
}

#pragma mark - SearchBarDelegate
-(BOOL) searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    return YES;
}
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchText = searchBar.text;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _searchText = searchBar.text;
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchButtonClicked: searchBar];
}

#pragma mark -OSSearchViewControllerDelegate
-(void)searchViewController:(OSSearchViewController *)searchVC didSelectedParameters:(NSDictionary *)parameters {
    //Do nothing to reset filter for fresh text search
//    self.searchParams = [NSMutableDictionary dictionaryWithDictionary: parameters];
}

@end

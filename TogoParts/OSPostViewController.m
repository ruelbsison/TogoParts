//
//  OSPostViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/4/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSPostViewController.h"
#import "OSCheckButton.h"
#import "OSSectionViewController.h"
#import "OSItemInfoViewController.h"
#import "OSPriceViewController.h"
#import "OSContactViewController.h"
#import "OSPlaceHolderTextView.h"
#import "OSDownPicker.h"

#import <AviarySDK/AviarySDK.h>
#import "UIColor+VTTHelpers.h"
#import "UIImage+VTTHelpers.h"

@interface OSPostViewController () <OSSectionDelegate, OSCategoryDelegate, OSSubCategoryDelegate,
                                    UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate,
                                    AFPhotoEditorControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate,
                                    OSItemVCDelegate, OSMoreDetailVCDelegate,
                                    OSPriceControllerDelegate,
                                    OSContactVCDelegate>

@property (weak, nonatomic) IBOutlet OSCheckButton *freeAdButton;
@property (weak, nonatomic) IBOutlet OSCheckButton *priorityAdButton;
@property (weak, nonatomic) IBOutlet OSCheckButton *newitemAdButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *infoCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *buttonsLabel;

@property (nonatomic) NSNumber *adType;
@property (nonatomic) NSMutableDictionary *categoryData;
@property (nonatomic) NSMutableDictionary *tempCatData;
@property (nonatomic) NSDictionary *sectionCostData;
@property (nonatomic) NSMutableDictionary *itemData;
@property (nonatomic) NSMutableDictionary *priceData;
@property (nonatomic) NSMutableDictionary *contactData;

@property (nonatomic) NSMutableArray *pics;
@property (nonatomic) NSMutableArray *deletePics;

@property (nonatomic) NSArray *postingPack;
@property (nonatomic) NSArray *merchant;
@property (nonatomic) NSArray *quota;
@property (nonatomic) NSDictionary *result;

@property (nonatomic) NSInteger selectedImageIndex;


@property (weak, nonatomic) IBOutlet UIImageView *categoryTick;
@property (weak, nonatomic) IBOutlet UIImageView *itemTick;
@property (weak, nonatomic) IBOutlet UIImageView *priceTick;
@property (weak, nonatomic) IBOutlet UIImageView *locationTick;

@property (weak, nonatomic) IBOutlet OSCheckButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *tcredsLabel;

@property (nonatomic) NSArray *offerTypes;
@property (weak, nonatomic) IBOutlet OSDownPicker *adInfoOfferDownPicker;
@property (weak, nonatomic) IBOutlet OSPlaceHolderTextView *adInfoDescription;

@end

@implementation OSPostViewController

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
    
    
    if (_aid) {
        self.title = @"Edit Ad";
    }
    
    self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed:@"cancel-button"] target:self selector: @selector(cancelButtonClicked:)];
    
    // Do any additional setup after loading the view.
    self.pics = [NSMutableArray new];
    self.deletePics = [NSMutableArray new];
    self.adType = nil;
    self.categoryData = [NSMutableDictionary new];
    self.tempCatData = [NSMutableDictionary new];
    self.itemData = [NSMutableDictionary new];
    self.priceData = [NSMutableDictionary new];
    self.contactData = [NSMutableDictionary new];
    self.offerTypes = @[@"Want to Sell", @"Want to Buy", @"Free", @"Exchange+cash Pistols"];
    
    if (VTTOSLessThan7) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
        layout.sectionInset = UIEdgeInsetsMake(5, 25, 0, 25);
    }
    
    for (NSInteger i=0; i<6; i++) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        dict[@"title"] = i == 0? @"Cover Pic" : @"";
        [self.pics addObject: dict];
    }
    _selectedImageIndex = -1;
    
    _freeAdButton.checkedImage = [UIImage imageNamed: @"freead-button-selected"];
    _freeAdButton.uncheckedImage = [UIImage imageNamed: @"freead-button"];
    _priorityAdButton.checkedImage = [UIImage imageNamed: @"priorityad-button-selected"];
    _priorityAdButton.uncheckedImage = [UIImage imageNamed: @"priorityad-button"];
    _newitemAdButton.checkedImage = [UIImage imageNamed: @"newitem-button-selected"];
    _newitemAdButton.uncheckedImage = [UIImage imageNamed: @"newitem-button"];
    _emailButton.checkedImage = [UIImage imageNamed: @"checkin-box-bg-big"];
    _emailButton.uncheckedImage = [UIImage imageNamed: @"check-box-bg-big"];
    _emailButton.useBackground = YES;
    _emailButton.checked = YES;
    
    if (_aid) {
        _emailButton.hidden = YES;
        _emailLabel.hidden = YES;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (_aid) {
        params[@"aid"] = _aid;
    }
    [OSUser POST: @"https://www.togoparts.com/iphone_ws/mp-postad-requirements.php?source=ios" parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = responseObject[@"Result"];
        if (result) {
            self.result = result;
            NSString *returnStr = result[@"Return"];
            if ([returnStr isEqualToString: @"success"]) {
                if (result[@"postingpack"]) {
                    _postingPack = result[@"postingpack"];
                } else if (result[@"merchant"]) {
                    _merchant = result[@"merchant"];
                } else if (result[@"quota"]) {
                    _quota = result[@"quota"];
                }
                
                if ([result[@"email_me"] isEqual: @0] || !result[@"email_me"]) {
                   _emailButton.checked = YES;
                } else {
                    _emailButton.checked = NO;
                }
                
                
                if (!_postingPack) {
                    self.tcredsLabel.text = [NSString stringWithFormat: @"%@ TCredits", result[@"TCreds"]];
                }
                
                if (_quota) {
                    //Quota
                    if ([result[@"freeadsleft"] isEqualToNumber: @0]) {
                        self.freeAdButton.enabled = NO;
                        self.freeAdButton.hidden = YES;
                    } else {
                        [self freeAdButtonClicked: self];
                    }
                } else {
                    
                    //merchant or postingpack
                    _newitemAdButton.enabled = YES;
                    _priorityAdButton.enabled = NO;
                    _freeAdButton.enabled = NO;
                    _priorityAdButton.hidden = YES;
                    _freeAdButton.hidden = YES;
                    
                    [self newItemAdButtonClicked: self];
                    //TODO: enable all images
                }
                
                if (_aid) {
                    NSInteger adtype = [result[@"ad_details"][@"adtype"] integerValue];
                    _freeAdButton.hidden = YES;
                    _priorityAdButton.hidden = YES;
                    _newitemAdButton.hidden = YES;
                    _buttonsLabel.hidden = YES;
                    
                    if (adtype == 0) {
                        [self freeAdButtonClicked: self];
                        _freeAdButton.hidden = NO;
                    } else if (adtype == 1) {
                        [self priorityButtonClicked: self];
                        _priorityAdButton.hidden = NO;
                    } else if (adtype == 2) {
                        [self newItemAdButtonClicked:self];
                        _newitemAdButton.hidden = NO;
                    }
                    _freeAdButton.enabled = NO;
                    _priorityAdButton.enabled = NO;
                    _newitemAdButton.enabled = NO;
                }
                
                if (_newitemAdButton.checked || _priorityAdButton.checked) {
                    for (NSMutableDictionary *dict in _pics) {
                        dict[@"enabled"] = @"yes";
                    }
                } else if (_freeAdButton.checked) {
                    _pics[0][@"enabled"] = @"yes";
                }
                [self updateButtonsLabel];
                [_infoCollectionView reloadData];
                
                if (_aid) {
                    NSDictionary *adDetails = result[@"ad_details"];
                    _adType = adDetails[@"adtype"];
                    [self updateDictionary:_categoryData withKeys: @[@"section", @"cat", @"sub_cat"] fromDetails: adDetails];
                    [self updateDictionary: _itemData  withKeys:@[@"brand", @"colour", @"condition", @"d_bmx", @"d_commute", @"d_folding", @"d_mtb", @"d_others", @"d_road", @"description", @"item", @"item_year", @"size", @"title", @"transtype", @"warranty", @"weight", @"picturelink"] fromDetails: adDetails];
                    [self updateDictionary: _contactData withKeys: @[@"address", @"city", @"contactno", @"contactperson", @"country", @"lat", @"long", @"postalcode", @"region", @"time_to_contact"] fromDetails: adDetails];
                    [self updateDictionary: _priceData withKeys: @[@"original_price", @"price", @"pricetype", @"clearance"] fromDetails: adDetails];
                    
                    
                    for (NSInteger i = 0; i < [adDetails[@"picture"] count]; i++) {
                        NSDictionary *picDict = adDetails[@"picture"][i];
                        NSMutableDictionary *pic = _pics[i];
                        [pic addEntriesFromDictionary: picDict];
                    }
                    
                    (void)[_adInfoOfferDownPicker initWithData:self.offerTypes];
                }
                
                if (result[@"Message"]) {
                    VTTShowAlertView(@"", result[@"Message"], @"Ok");
                }
                
            } else if ([returnStr isEqualToString: @"error"]) {
                [[[UIAlertView alloc] initWithTitle: @"Notice" message: result[@"Message"] delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] show];
            } else if ([returnStr isEqualToString: @"banned"]) {
                [[[UIAlertView alloc] initWithTitle: @"" message: result[@"Message"] delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] show];
            } else if ([returnStr isEqualToString: @"Insufficient TCredits"]) {
                [[[UIAlertView alloc] initWithTitle: returnStr message: result[@"Message"] delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
            }
            
        } else {
            [self dismissViewControllerAnimated: YES completion: nil];
        }
        
        [hud hide: YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide: YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    }];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    if (_aid) {
        [OSHelpers sendGATrackerWithName: @"Marketplace Edit Ad"];
    } else {
        [OSHelpers sendGATrackerWithName: @"Marketplace Post Ad"];
    }
}

-(void) updateDictionary: (NSMutableDictionary *) dict withKeys: (NSArray *) keys fromDetails: (NSDictionary *) adDetails {
    for (NSString *key in keys) {
        if (adDetails[key])
            dict[key] = adDetails[key];
    }
}

#pragma mark - UIAlertViewDelegate
-(void) openTCredsLink {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: _result[@"TCredsLink"]]];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = alertView.title;
    NSString *buttonTitle = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: @"TCredits Insufficient"] || [title isEqualToString: @"Insufficient TCredits"]) {
        if ([buttonTitle isEqualToString: @"Buy TCredits"]) {
            [self openTCredsLink];
        } else if ([buttonTitle isEqualToString: @"Cancel"]) {
            //do nothing
        }
        
        if (![title isEqualToString: @"TCredits Insufficient"]) {
            //only go to profile page if it's not from priority and new item buttons
            if ([self.delegate respondsToSelector: @selector(postController:wantToGoToPage:)]) {
                [_delegate postController: self wantToGoToPage: TOGOProfileControllerIndex];
            }
        }
        
    } else if ([title isEqualToString: @"Notice"]) {
        if ([self.delegate respondsToSelector: @selector(postController:wantToGoToPage:)]) {
            [_delegate postController: self wantToGoToPage: TOGOProfileControllerIndex];
        }
    } else if ([title isEqualToString: @"Banned"]) {
        [OSUser logout];
    } else if ([title isEqualToString: @"Confirm Cancellation"]) {
        if ([buttonTitle isEqualToString: @"YES"]) {
            [self.navigationController dismissViewControllerAnimated: YES completion: NO];
        }
    } else if ([title isEqualToString: @"Remove Image?"]) {
        if ([buttonTitle isEqualToString: @"YES"]) {
            if (_selectedImageIndex != -1) {
                [self removeImageAtIdexIfNeeded: _selectedImageIndex];
                [self.collectionView reloadData];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
-(void) checkButton: (OSCheckButton *) button check: (BOOL) check{
    button.checked = check;
}

//-(void) toggleButton: (OSCheckButton *) button key: (NSString *) key {
//    if (button.checked) {
//        [self checkButton: button check: NO key: key];
//    } else {
//        [self checkButton: button check: YES key: key];
//    }
//}


#define kOSDescriptionLimitFree 700
#define kOSDescriptionLimitPaid 1500
#define kFreeAdPicNumber 3
- (IBAction)freeAdButtonClicked:(id)sender {
    self.freeAdButton.checked = true;
    self.priorityAdButton.checked = false;
    self.newitemAdButton.checked = false;
    self.adType = @0;
    
    //Remove all pics other than cover pic
    for (NSInteger i=kFreeAdPicNumber; i<6; i++) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        dict[@"title"] = @"";
        [self.pics replaceObjectAtIndex: i withObject: dict];
    }
    
    //Trim description
    if (self.itemData[@"description"]) {
        self.itemData[@"description"] = [self.itemData[@"description"] substringWithRange: NSMakeRange(0, kOSDescriptionLimitFree)];
    }
    
    [self updateButtonsLabel];
}
- (IBAction)priorityButtonClicked:(id)sender {
    NSNumber *tcred =  _result[@"TCreds"];
//    tcred = @10
    
    //Only check for Post, not Edit
    if (!_aid) {
        if (self.sectionCostData) {
            NSNumber *priorityCost = _sectionCostData[@"priority_cost"];
            if ([tcred compare: priorityCost] != NSOrderedAscending) {
                
            } else {
                if (sender != self)
                    [[[UIAlertView alloc] initWithTitle: @"TCredits Insufficient" message: @"You do not have enough Tcredits to post Priority ad under the selected Category!." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
                return;
            }
        }
        
        NSNumber *minPriorityCost = _result[@"min_priority_cost"];
        if (minPriorityCost) {
            NSComparisonResult priorityComparison = [tcred compare: minPriorityCost];
            if (priorityComparison != NSOrderedAscending) {
            } else {
                if (sender != self)
                     [[[UIAlertView alloc] initWithTitle: @"TCredits Insufficient" message: @"Purchase Tcredits to post this as Priority ad." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
                return;
            }
        }
    }
    
    //Click priorityAdButton
    self.freeAdButton.checked = false;
    self.priorityAdButton.checked = true;
    self.newitemAdButton.checked = false;
    self.adType = @1;
    [self updateButtonsLabel];
    
    
}
- (IBAction)newItemAdButtonClicked:(id)sender {
    NSNumber *tcred =  _result[@"TCreds"];
//    tcred = @10;
    
    //Only check for Post, not Edit
    if (!_aid) {
        if (self.sectionCostData) {
            NSNumber *nItemCost = _sectionCostData[@"newitem_cost"];
            if ([tcred compare: nItemCost] != NSOrderedAscending) {
                //will be continued to the click newItemButton
            } else {
                if (sender != self)
                    [[[UIAlertView alloc] initWithTitle: @"TCredits Insufficient" message: @"You do not have enough Tcredits to post New Item ad under the selected Category!" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
                return;
            }
        }
        
        NSNumber *minNewItemCost = _result[@"min_newitem_cost"];
        if (minNewItemCost) {
            NSComparisonResult newItemComparison = [tcred compare: minNewItemCost];
            if (newItemComparison != NSOrderedAscending){
                //will be continued to the click newItemButton
            } else {
                if (sender != self)
                    [[[UIAlertView alloc] initWithTitle: @"TCredits Insufficient" message: @"Purchase Tcredits to post this as New Item ad." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Buy TCredits", nil] show];
                
                return;
            }
        }
    }
    
    //Click newItemButton
    self.freeAdButton.checked = false;
    self.priorityAdButton.checked = false;
    self.newitemAdButton.checked = true;
    self.adType = @2;
    [self updateButtonsLabel];
    
}

-(void) updateButtonsLabel {
    if (_newitemAdButton.checked) {
        //New item button
        NSString *secondLine = @"";
        if (!_result[@"postingpack"]) {
            secondLine = [NSString stringWithFormat:@"\n%@ Tcreds / day for all item types.", _result[@"min_newitem_cost"]];
        }
        _buttonsLabel.text = [NSString stringWithFormat: @"Make a Profit selling New Items.%@", secondLine];
    } else if (_priorityAdButton.checked) {
        //Priority button
        _buttonsLabel.text = [NSString stringWithFormat: @"Sort your item above all Free Ads for 7 days.\n4 Tcreds for all stuff except complete bikes at 10 Tcreds."];
    } else if (_freeAdButton.checked) {
        //FreeAdButton
        _buttonsLabel.text = [NSString stringWithFormat: @"You are posting a Free Ad. To get 5x more views by getting your ad sorted First, post as a Priority or New Item Ad"];
    } else {
        _buttonsLabel.text = @"";
    }
    [_collectionView reloadData];
}

- (IBAction)emailButtonClicked:(id)sender {
    _emailButton.checked = !_emailButton.checked;
}
- (IBAction)cancelButtonClicked:(id)sender {
    NSString *message = @"Are you sure you want to cancel posting this Ad? All details and photos will not be saved.";
    if (_aid) {
        message = @"Are you sure you want to cancel editing this Ad? All details and photos will not be saved.";
    }
    [[[UIAlertView alloc] initWithTitle: @"Confirm Cancellation" message: message delegate: self cancelButtonTitle: @"NO" otherButtonTitles: @"YES", nil] show];
}

- (IBAction) submitButtonClicked:(id)sender {
    if (![OSUser currentUser]) {
        return;
    }
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary: @{@"session_id": [[OSUser currentUser] session_id]}];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params addEntriesFromDictionary: _categoryData];
    [params addEntriesFromDictionary: _itemData];
    [params addEntriesFromDictionary: _priceData];
    [params addEntriesFromDictionary: _contactData];
    
    NSMutableArray *messages = [NSMutableArray new];
//    NSDictionary *picDict = _pics[0];
//    if (!picDict[@"image"] && !picDict[@"picture"]) {
//        [messages addObject: @"- Cover Picture"];
//    }
    if (!_adType) {
        [messages addObject: @"- Ad Type"];
    }
    if (!_categoryData[@"section"]) {
        [messages addObject: @"- Section"];
    }
    if (!_categoryData[@"cat"]) {
        [messages addObject: @"- Category"];
    }
    if (!_categoryData[@"sub_cat"]) {
        [messages addObject: @"- Sub Category"];
    }
    if (!_itemData[@"title"]) {
        [messages addObject: @"- Title"];
    }
    if (!_itemData[@"description"]) {
        [messages addObject: @"- Description"];
    }
    if (!_contactData[@"country"] || [_contactData[@"country"] isEqualToString: @""]) {
        _contactData[@"country"] = @"Singapore";
    }
    
    if (messages.count > 0) {
        [[[UIAlertView alloc] initWithTitle: @"Below fields are required:" message: [messages componentsJoinedByString: @"\n"] delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return;
    }
    
    //Email
    if (!_aid) {
        if (_emailButton.checked) {
            params[@"email_me"] = @1;
        } else {
            params[@"email_me"] = @0;
        }
    }
    
    //Adtype
    params[@"adtype"] = self.adType;

    //aid and delPics
    if (_aid) {
        params[@"aid"] = _aid;
        params[@"del_pids"] = [_deletePics componentsJoinedByString: @","];
    }
    
    NSLog(@"post params: %@", params);
    MBProgressHUD *hud = [OSHelpers showStandardHUDForView: self.view];
//    AFHTTPRequestOperationManager *testManager = [AFHTTPRequestOperationManager manager];
    [OSUser POST:@"https://www.togoparts.com/iphone_ws/mp-postad.php?source=ios" parameters: params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
//        [formData appendPartWithFileData:imageData name: @"adpic1" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
        for (NSInteger i=0; i < _pics.count; i++) {
            UIImage *image = _pics[i][@"image"];
            if (image) {
                NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
                [formData appendPartWithFileData:imageData name: [NSString stringWithFormat: @"adpic%zd", i+1] fileName:@"photo.jpg" mimeType:@"image/jpeg"];
            }
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"post ad responseObject: %@", responseObject);
        NSDictionary *result = responseObject[@"Result"];
        BOOL dismiss = YES;
        if ([result[@"Return"] isEqualToString: @"error"]) {
            dismiss = NO; //Do not dismiss when it's error
            VTTShowAlertView(@"Notice", result[@"Message"],  @"Ok");
        } else if ([result[@"Return"] isEqualToString: @"success"]) {
            VTTShowAlertView(@"Successful", result[@"Message"], @"Ok");
        } else if (result[@"Message"]) {
                VTTShowAlertView(@"",  result[@"Message"],  @"Ok");
        }
        
        //GOTO Profile Page
        if (dismiss) {
            if (!_aid) {
                if ([self.delegate respondsToSelector: @selector(postController:wantToGoToPage:)]) {
                    [_delegate postController: self wantToGoToPage: TOGOProfileControllerIndex];
                }
            } else {
                [self.navigationController dismissViewControllerAnimated: YES completion: nil];
            }
        }
        
        [OSHelpers hideStandardHUD: hud];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"post ad error: %@", error.localizedDescription);
        NSLog(@"of request: %@ and response: %@", operation.request, operation.responseObject);
        [[[UIAlertView alloc] initWithTitle: @"Notice" message: error.localizedDescription delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] show];
        [OSHelpers hideStandardHUD: hud];
    }];
}

#pragma mark - Inspection
- (BOOL) isPictureEnabledAtIndex: (NSInteger) index {
    if (_freeAdButton.checked) {
        if (index < kFreeAdPicNumber) {
            return true;
        } else {
            return false;
        }
    } else {
        return true;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString: @"ToOSSectionViewController"]) {
        if (self.aid) {
            VTTShowAlertView(@"In Editing Mode", @"You cannot edit category",  @"Ok");
            return NO; // not allow to select section if it's edit mode
        } else if (!self.adType) {
            VTTShowAlertView(@"", @"Please select an Ad type before selecting a category!",  @"Ok");
            return NO;
        }
    } else if ([identifier isEqualToString: @"ToOSContactViewController"]) {
        if ([_result[@"Shopid"] compare: @0] == NSOrderedDescending) {
            VTTShowAlertView(@"Cannot edit contact & location", @"Shop cannot edit contact & location",  @"Ok");
            return NO; //Do not allow edit contact if it's shop
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"ToOSSectionViewController"]) {
        OSSectionViewController *sectionVC = segue.destinationViewController;
        sectionVC.categoryData = self.categoryData;
        sectionVC.adType = self.adType;
        sectionVC.tcreds = _result[@"TCreds"];
        sectionVC.delegate = self;
    } else if ([segue.identifier isEqualToString: @"ToOSItemViewController"]) {
        OSItemInfoViewController *itemVC = segue.destinationViewController;
        NSInteger descriptionLimit = kOSDescriptionLimitFree;
        if (_newitemAdButton.checked || _priorityAdButton.checked) {
            descriptionLimit = kOSDescriptionLimitPaid;
        }
        itemVC.info = @{@"descriptionLimit" : [NSNumber numberWithInteger: descriptionLimit], @"otherLinkLimit": @(200)};
        itemVC.data = [NSMutableDictionary dictionaryWithDictionary: self.itemData];
        if (_aid) itemVC.isEdit = YES;
        itemVC.delegate = self;
    } else if ([segue.identifier isEqualToString: @"ToOSPriceViewController"]) {
        OSPriceViewController *priceVC = segue.destinationViewController;
        priceVC.data = [NSMutableDictionary dictionaryWithDictionary: self.priceData];
        priceVC.info = [NSMutableDictionary dictionaryWithDictionary: self.result];
        priceVC.delegate = self;
    } else if ([segue.identifier isEqualToString: @"ToOSContactViewController"]) {
        OSContactViewController *contactVC = segue.destinationViewController;
        contactVC.data = [NSMutableDictionary dictionaryWithDictionary: self.contactData];
        contactVC.delegate = self;
    }
}

#pragma mark - UICollectionViewDatasource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _collectionView) {
        return _pics.count;
    } else if (collectionView == _infoCollectionView) {
        if (_merchant) {
            return _merchant.count;
        } else if (_postingPack) {
            return _postingPack.count;
        } else if (_quota) {
            return _quota.count;
        }
    }
    return 0;
}
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _collectionView) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];
        UIImageView *imageView = (UIImageView *) [cell viewWithTag: 1];
        UILabel *label = (UILabel *) [cell viewWithTag: 2];
        NSDictionary *picDict = _pics[indexPath.row];
        if (picDict[@"image"]) {
            imageView.image = picDict[@"image"];
        } else if (picDict[@"picture"]) {
            [imageView setImageWithURL: [NSURL URLWithString: picDict[@"picture"]] placeholderImage: nil];
        } else {
            if ([self isPictureEnabledAtIndex: indexPath.row]) {
                imageView.image = [UIImage imageNamed: @"upload-pic"];
            } else {
                imageView.image = [UIImage imageNamed: @"unselected-pic"];
            }
        }
        label.text = picDict[@"title"];
        return cell;
    } else if (collectionView == _infoCollectionView) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];
        NSArray *data;
        if (_merchant) data = _merchant;
        if (_postingPack) data = _postingPack;
        if (_quota) data = _quota;
        UILabel *label = (UILabel *) [cell viewWithTag: 1];
        UILabel *value = (UILabel *) [cell viewWithTag: 2];
        label.text = data[indexPath.row][@"label"];
        value.text = [NSString stringWithFormat: @"%@", data[indexPath.row][@"value"]];
        return cell;
    }
    return nil;
}

#define kAviaryAPIKey @"b12e60b65325427e"
#define kAviarySecret @"b5fd24ee33a8e4f7"
#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *picDict = _pics[indexPath.row];
//    if (!picDict[@"enabled"] || [picDict[@"enabled"] isEqualToString: @"no"]) return;
    if (![self isPictureEnabledAtIndex: indexPath.row]) return;
    
    
    _selectedImageIndex = indexPath.row;
    NSDictionary *picDict = _pics[_selectedImageIndex];
    
    NSString *destructiveButton;
    if (picDict[@"image"] || picDict[@"picture"]) destructiveButton = @"Remove image";

    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: @"Select action" delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle: destructiveButton otherButtonTitles:@"Capture image from camera", @"Pick image from library", nil];
        [actionSheet showInView: self.view];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: @"Select action" delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle: Nil otherButtonTitles:@"Photo Library", nil];
        [actionSheet showInView: self.view];
    }
}
#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([buttonTitle isEqualToString: @"Pick image from library"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        [self presentViewController: imagePicker animated: YES  completion: nil];
        
    } else if ([buttonTitle isEqualToString: @"Capture image from camera"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        
        [self presentViewController: imagePicker animated: YES  completion: nil];
    } else if ([buttonTitle isEqualToString: @"Remove image"]) {
        [[[UIAlertView alloc] initWithTitle: @"Remove Image?" message:@"Are you sure you want to remove the selected image?" delegate: self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil] show];
    }
}

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    [OSHelpers sendGATrackerWithName: @"Marketplace Photo Editor"];
    
    // kAviaryAPIKey and kAviarySecret are developer defined
    // and contain your API key and secret respectively
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFPhotoEditorController setAPIKey:kAviaryAPIKey secret:kAviarySecret];
        [AFPhotoEditorCustomization setToolOrder: @[kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSharpness]];
    });
    [AFPhotoEditorCustomization setNavBarImage:[UIImage imageWithColor: [UIColor colorWithRed:0.109804 green:0.125490 blue:0.152941 alpha:1] cornerRadius: 0.0f]];
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:NO completion:nil];
}

#pragma mark -UIImagePickerControllerDelegate, AFPhotoEditorControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *finishedImage = info[@"UIImagePickerControllerOriginalImage"];
    if (!finishedImage) finishedImage = info[@"UIImagePickerControllerEditedImage"];
    
    [picker dismissViewControllerAnimated: NO completion:^{

    }];
    
    if (finishedImage) {
        [self displayEditorForImage: finishedImage];
    } else {
        
    }

}

-(void) removeImageAtIdexIfNeeded: (NSInteger) index {
    NSMutableDictionary *dict = _pics[index];
    if (dict[@"pid"]) {
        [_deletePics addObject: dict[@"pid"]];
        [dict removeObjectForKey: @"pid"];
        [dict removeObjectForKey: @"picture"];
    } else {
        [dict removeObjectForKey: @"image"];
    }
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    // Handle the result image here
    [editor dismissViewControllerAnimated: YES completion: NO];
    
    if (_selectedImageIndex != -1) {
        NSMutableDictionary *dict = _pics[_selectedImageIndex];
        [self removeImageAtIdexIfNeeded: _selectedImageIndex];
        dict[@"image"] = image;
        [self.collectionView reloadData];
    }
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancellation here
    [editor dismissViewControllerAnimated: YES completion: NO];
}

-(BOOL) validateDict: (NSDictionary *) dict forKey: (NSArray *) keys {
    for (NSString *key in keys) {
        if (!dict[key]) return false;
    }
    return true;
}
#pragma mark - OSSectionDelegate
-(void)sectionVC:(OSSectionViewController *)sectionVC didSelectedSection:(NSNumber *)section withData:(NSDictionary *)data {
    self.tempCatData[@"section"] = section;
    self.tempCatData[@"sectionCost"] = data;
}
#pragma mark - OSCategoryDelegate
-(void)categoryVC:(OSCategoryViewController *)categoryVC didSelectedCategory:(NSNumber *)category {
    self.tempCatData[@"cat"] = category;
}
#pragma mark - OSSubCategoryDelegate
-(void) subCategoryVC:(OSSubCategoryViewController *)subCategoryVC didSelectedSubCategory:(NSNumber *)subCat {
    self.categoryData[@"sub_cat"] = subCat;
    self.categoryData[@"section"] = _tempCatData[@"section"];
    self.categoryData[@"cat"] = _tempCatData[@"cat"];
    self.sectionCostData = _tempCatData[@"sectionCost"];
    
    if (!_aid) {
        //only check for post
        BOOL completed = [self validateDict: self.categoryData forKey: @[@"section", @"cat", @"sub_cat"]];
        if (completed) {
            _categoryTick.hidden = NO;
        } else {
            _categoryTick.hidden = YES;
        }
    }
    [self.navigationController popToRootViewControllerAnimated: YES];
}
#pragma mark - OSItemVCDelegate, OSMoreDetailVCDelegate
-(void) itemVC:(OSItemInfoViewController *)itemVC pickedData:(NSDictionary *)data {
    self.itemData = [NSMutableDictionary dictionaryWithDictionary: data];
    [self.navigationController popToRootViewControllerAnimated: YES];
}
-(void) moreDetailVC:(OSMoreDetailController *)itemVC pickedData:(NSDictionary *)data {
    self.itemData = [NSMutableDictionary dictionaryWithDictionary: data];
    if (!_aid) {
        //only check for post
        BOOL completed = [self validateDict: self.itemData forKey: @[@"title", @"description"]];
        if (completed) {
            _itemTick.hidden = NO;
        } else {
            _itemTick.hidden = YES;
        }
    }
    [self.navigationController popToRootViewControllerAnimated: YES];
}

#pragma mark -OSPriceControllerDelegate
-(void)priceVC:(OSPriceViewController *)priceVC pickedData:(NSDictionary *)data {
    self.priceData = [NSMutableDictionary dictionaryWithDictionary: data];
    if (!_aid) {
        //only check for post
        self.priceTick.hidden = NO;
    }
    [self.navigationController popToRootViewControllerAnimated: YES];
}

#pragma mark -OSContactVCDelegate
-(void)contactVC:(OSContactViewController *)contactVC pickedData:(NSDictionary *)data {
    self.contactData = [NSMutableDictionary dictionaryWithDictionary: data];
    if (!_aid) {
        //only check for post
        self.locationTick.hidden = NO;
    }
    
    [self.navigationController popViewControllerAnimated: YES];
}
@end

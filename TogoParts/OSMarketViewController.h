//
//  OSMarketViewController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 2/17/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSMarketViewController : UITableViewController
@property (nonatomic, strong) NSString *listParameterString;
-(void) goToOSListingViewControllerWithParameterString: (NSString *) parameterString params: (NSDictionary *) params animated: (BOOL) animated;
-(void) goToAdDetailWithAID: (NSString *) aid animated: (BOOL) animated;
@end

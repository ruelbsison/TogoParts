//
//  OSSuggestionController.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/5/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@class OSSuggestionController;
@protocol OSSuggestionDelegate <NSObject>

-(void) suggestionController: (OSSuggestionController *) suggestionVC didSelectedValue: (id) value;

@end

@interface OSSuggestionController : UITableViewController
@property (nonatomic, weak) id <OSSuggestionDelegate> delegate;


@property (nonatomic) BOOL isLocationSearch;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSString *key;


@property (nonatomic) CLLocationDistance userRegionDistance;
@property (nonatomic) MKCoordinateRegion region;
@property (nonatomic) MKPointAnnotation *annotation;

-(NSString *) searchString;
@end

//
//  OSAnnotation.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/21/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface OSAnnotation : MKPointAnnotation
@property (nonatomic) MKPinAnnotationColor pinColor;
@property (nonatomic) NSInteger tag;
@end

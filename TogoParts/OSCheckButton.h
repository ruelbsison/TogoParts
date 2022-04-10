//
//  OSCheckButton.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/12/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCheckButton : UIButton
@property (nonatomic) BOOL checked;
@property (nonatomic) UIImage *checkedImage;
@property (nonatomic) UIImage *uncheckedImage;
@property (nonatomic) BOOL useBackground;

-(id) initWithCheckedImage: (UIImage *) checkedImage uncheckedImage: (UIImage *) uncheckedImage;
@end

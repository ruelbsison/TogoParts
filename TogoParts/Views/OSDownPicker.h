//
//  OSDownPicker.h
//  TogoParts
//
//  Created by Ruel Sison on 9/17/16.
//  Copyright © 2016 Oneshift. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDownPickerControl.h"

@interface OSDownPicker : UITextField
@property (strong, nonatomic) OSDownPickerControl *DownPicker;

-(id)initWithData:(NSArray*)data;

@end

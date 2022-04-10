//
//  OSDownPicker.m
//  TogoParts
//
//  Created by Ruel Sison on 9/17/16.
//  Copyright © 2016 Oneshift. All rights reserved.
//

#import "OSDownPicker.h"

@implementation OSDownPicker

-(id)init
{
    return [self initWithData:nil];
}

-(id)initWithData:(NSArray*)data
{
    self = [super init];
    if (self) {
        self.DownPicker = [[OSDownPickerControl alloc] initWithTextField:self withData:data];
    }
    return self;
}

@end

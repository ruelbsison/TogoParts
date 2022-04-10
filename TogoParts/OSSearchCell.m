//
//  OSSearchCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 3/14/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSSearchCell.h"

@implementation OSSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
//        [self setBackgroundColor: [UIColor clearColor]];
//        [self.contentView setBackgroundColor: [UIColor clearColor]];
        [self.selectedBackgroundView setBackgroundColor: [UIColor clearColor]];
    } else {
//        [self setBackgroundColor: [UIColor clearColor]];
//        [self.contentView setBackgroundColor: [UIColor clearColor]];
        [self.selectedBackgroundView setBackgroundColor: [UIColor clearColor]];
    }
}

//-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
////    [super setHighlighted: highlighted animated: animated];
//    
//    if (highlighted) {
//        [self.selectedBackgroundView setBackgroundColor: [UIColor clearColor]];
//
//    } else {
//        [self.selectedBackgroundView setBackgroundColor: [UIColor clearColor]];
//    }
//}
@end

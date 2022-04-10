//
//  OSCommentCell.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/7/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSCommentCell.h"

@implementation OSCommentCell


-(void) awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    _commentTextView.font = [UIFont fontWithName: OSTogoFontName size:13.0f];
}

-(void) configureCellWithRowData: (NSDictionary *) rowData {
//    {
//        "username": "nestorvie",
//        "picture": "http://www.togoparts.com/members/avatars/icons/10-3.gif",
//        "message": "Hi, are you sure this one is a CAAD? I tried to look for the info but their CAAD model is for road bike. ",
//        "datesent": "31st Jul 2014 5:00 PM"
//    },
    self.usernameLabel.text = rowData[@"username"];
    self.commentTextView.text = rowData[@"message"];
    self.timeLabel.text = rowData[@"datesent"];
    [self.profileImageView setImageWithURL: [NSURL URLWithString: rowData[@"picture"]] placeholderImage: nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        self.contentView.backgroundColor = [UIColor clearColor];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

@end

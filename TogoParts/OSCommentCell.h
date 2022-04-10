//
//  OSCommentCell.h
//  TogoParts
//
//  Created by Thanh Tung Vu on 8/7/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSLabel.h"

@interface OSCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet OSLabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet OSLabel *timeLabel;

-(void) configureCellWithRowData: (NSDictionary *) rowData;
@end

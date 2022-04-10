//
//  OSNormalSigninController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 7/18/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSNormalSigninController.h"
#import <AFNetworking/AFNetworking.h>
#import "OSUser.h"

@interface OSNormalSigninController ()

@end

@implementation OSNormalSigninController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

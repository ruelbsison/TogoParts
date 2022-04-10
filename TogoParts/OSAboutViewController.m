//
//  OSAboutViewController.m
//  TogoParts
//
//  Created by Thanh Tung Vu on 4/15/14.
//  Copyright (c) 2014 Oneshift. All rights reserved.
//

#import "OSAboutViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface OSAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSDictionary *about;

@end

@implementation OSAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.visibleViewController != self.navigationController.viewControllers[0]) {
        self.navigationItem.leftBarButtonItem = [OSHelpers barButtonItemWithImage: [UIImage imageNamed: @"top-back-button"] target: self selector: @selector(backButtonClicked:)];
    }
    
    OSChangeTogoFontForLabel(_titleLabel);
    
    // Do any additional setup after loading the view.
    //http://www.togoparts.com/iphone_ws/about-us.php
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [OSHelpers padellingImageView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: @"http://www.togoparts.com/iphone_ws/about-us.php?source=ios&v=1.2&app=free" parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success bs detail: %@", responseObject);
        self.about = responseObject;
        
        [hud hide: YES];
        
        [self updateViews];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide: YES];
        NSLog(@"Failure ad detail: %@", operation.responseObject);
        NSLog(@"Error: %@", error.localizedDescription);
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) backButtonClicked: (id) sender {
    if (self.navigationController.viewControllers.count > 1)
        [self.navigationController popViewControllerAnimated: YES];
}

-(void) updateViews {
    self.titleLabel.text = self.about[@"title"];
    [self.webView loadHTMLString: _about[@"content"] baseURL: nil];
}

@end

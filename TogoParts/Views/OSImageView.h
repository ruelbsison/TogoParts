//
//  OSImageView.h
//  TogoParts
//
//  Created by Ruel Sison on 9/20/16.
//  Copyright © 2016 Oneshift. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OSImageViewDelegate<NSObject>
-(UIImageView *) imageViewForPage:(int) page;
-(int) numberOfImages;
@end

@interface OSImageView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *imagesUrls;
@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic) BOOL disableSpinnerWhenLoadinImage;

@property (nonatomic) BOOL tempDownloadedImageSavingEnabled;

@property (nonatomic) UIViewContentMode contentMode;

@property (nonatomic, weak) id<OSImageViewDelegate> delegate;

-(void) setCustomPageControl:(UIPageControl *) customPageControl;

-(void)setInitialPage:(NSInteger)page;
-(NSInteger)currentPage;

@end

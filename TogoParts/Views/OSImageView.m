//
//  OSImageView.m
//  TogoParts
//
//  Created by Ruel Sison on 9/20/16.
//  Copyright © 2016 Oneshift. All rights reserved.
//

#import "OSImageView.h"

#define VIEW_FOR_ZOOM_TAG (1)

@interface OSImageView()

@property (strong, nonatomic) UIScrollView *imageScrollView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableDictionary *downloadedImages;

-(CGRect) imageViewFrame;
-(CGRect) pageControlFrame;

-(int) nb;
-(void) initializeImagesViewer;
-(void) initializeViewControllers;
-(void) loadScrollViewWithPage:(int)page;
-(void) loadImageWithPage:(int)page;
-(void) addImageView:(UIImageView *)imgView
   toImageScrollView:(UIScrollView *)imgScrollView
            withPage:(int) page
     removingSubview:(UIView *) subview;
-(void) reset;
-(void) setContentModeForImageView:(UIImageView *)imgView;
-(UIImageView *)asyncImageViewForPage:(int)page;
-(void)loadNeighborPagesForPage:(int)page;

@end

@implementation OSImageView {
    BOOL pageControlUsed;
    int initialPage;
}

@synthesize imageScrollView = _imageScrollView, viewControllers = _viewControllers, pageControl = _pageControl;

@synthesize images = _images, imagesUrls = _imagesUrls;
@synthesize contentMode = _contentMode;
@synthesize delegate = _delegate;
@synthesize loadingImage = _loadingImage, disableSpinnerWhenLoadinImage = _disableSpinnerWhenLoadinImage, downloadedImages = _downloadedImages, tempDownloadedImageSavingEnabled = _tempDownloadedImageSavingEnabled;

-(void)setCustomPageControl:(UIPageControl *)customPageControl
{
    int currentPage = (int)self.pageControl.currentPage;
    self.pageControl = customPageControl;
    self.pageControl.numberOfPages = self.nb;
    self.pageControl.currentPage = currentPage;
}

-(UIViewContentMode) contentMode
{
    if (!_contentMode) _contentMode = UIViewContentModeScaleAspectFit;
    return _contentMode;
}

-(void)setImages:(NSArray *)images
{
    if (images != _images) {
        _images = images;
        self.pageControl.numberOfPages = images.count;
    }
}

-(NSMutableDictionary *)downloadedImages
{
    if (!_downloadedImages) _downloadedImages = [NSMutableDictionary dictionary];
    return _downloadedImages;
}

-(void)setImagesUrls:(NSArray *)imagesUrls
{
    if (!_imagesUrls) {
        _imagesUrls = imagesUrls;
        self.pageControl.numberOfPages = imagesUrls.count;
    }
}

-(void)setDelegate:(id<OSImageViewDelegate>)delegate
{
    if (!_delegate) {
        _delegate = delegate;
        if ([delegate respondsToSelector:@selector(numberOfImages)]) self.pageControl.numberOfPages = [delegate numberOfImages];
    }
}

-(CGRect)imageViewFrame
{
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20);
}

-(CGRect)pageControlFrame
{
    return CGRectMake(0, [self imageViewFrame].size.height, self.frame.size.width, self.frame.size.height - [self imageViewFrame].size.height);
}

#pragma -mark initializers
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)layoutSubviews
{
    self.imageScrollView.frame = [self imageViewFrame];
    self.pageControl.frame = [self pageControlFrame];
    
    self.imageScrollView.contentSize = CGSizeMake(self.imageScrollView.frame.size.width * self.nb, self.imageScrollView.frame.size.height);
    
    [self reset];
}

-(void) reset
{
    for (UIImageView *imgView in self.viewControllers) {
        if ((NSNull *) imgView != [NSNull null])
            [imgView removeFromSuperview];
    }
    int imageScrollViewWidth = self.imageScrollView.frame.size.width;
    int imageScrollViewHeight = self.imageScrollView.frame.size.height;
    
    [self initializeViewControllers];
    
    int currentPage = (int)[self currentPage];
    
    [self loadNeighborPagesForPage:(int)self.pageControl.currentPage];
    [self.imageScrollView scrollRectToVisible:CGRectMake(currentPage * imageScrollViewWidth, 0, imageScrollViewWidth, imageScrollViewHeight) animated:NO];
}

-(void)loadNeighborPagesForPage:(int)page
{
    [self loadScrollViewWithPage:page];
    if (page == 0) {
        [self loadScrollViewWithPage:1];
    } else if (page == self.nb) {
        [self loadScrollViewWithPage:self.nb - 1];
    } else {
        [self loadScrollViewWithPage: page - 1];
        [self loadScrollViewWithPage: page + 1];
    }
}

-(void)initialize
{
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:[self imageViewFrame]];
    [self.imageScrollView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:1]];
    self.pageControl = [[UIPageControl alloc] initWithFrame:[self pageControlFrame]];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.multipleTouchEnabled = NO;
    [self.pageControl setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    [self addSubview:self.imageScrollView];
    [self addSubview:self.pageControl];
    
    
    [self initializeImagesViewer];
}

-(void)initializeViewControllers
{
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < self.nb; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
}

-(void)initializeImagesViewer
{
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.showsVerticalScrollIndicator = NO;
    self.imageScrollView.delegate = self;
    self.pageControl.numberOfPages = self.nb;
    self.pageControl.currentPage = 0;
}


#pragma -mark image view handlers

-(void)loadScrollViewWithPage:(int)page
{
    if ((page < 0) || (page >= self.nb)) return;
    
    if ((NSNull *)[self.viewControllers objectAtIndex:page] == [NSNull null]) [self loadImageWithPage:page];
}

-(void)setContentModeForImageView:(UIImageView *)imgView
{
    CGSize imageScrollViewSize = self.imageScrollView.frame.size;
    if ((self.contentMode == UIViewContentModeScaleAspectFill) && (imageScrollViewSize.width < imageScrollViewSize.height)) {
        [imgView sizeToFit];
    } else {
        imgView.contentMode = self.contentMode;
    }
}

-(int)nb
{
    if (self.imagesUrls) {
        return (int)[self.imagesUrls count];
    } else {
        if ([self.delegate respondsToSelector:@selector(numberOfImages)]) {
            return [self.delegate numberOfImages];
        } else {
            return (int)[self.images count];
        }
    }
}

-(void) loadImageWithPage:(int)page
{
    UIImageView *imgView;
    if (self.imagesUrls) {
        imgView = [self asyncImageViewForPage:page];
    } else {
        if ([self.delegate respondsToSelector:@selector(imageViewForPage:)]) {
            imgView = [self.delegate imageViewForPage:page];
        } else {
            if (self.images) imgView = [[UIImageView alloc] initWithImage: [self.images objectAtIndex:page]];
        }
    }
    if (imgView) {
        [self setContentModeForImageView:imgView];
        
        [self.viewControllers replaceObjectAtIndex:page withObject:imgView];
        
        if (imgView.superview == nil)
        {
            [self addImageView:imgView
             toImageScrollView:self.imageScrollView
                      withPage:page
               removingSubview:nil];
        }
    }
}

-(void) addImageView:(UIImageView *)imgView toImageScrollView:(UIScrollView *)imgScrollView withPage:(int) page removingSubview:(UIView *) subview
{
    if(subview) [subview removeFromSuperview];
    
    CGRect frame = imgScrollView.frame;
    frame.origin.x = 0; //frame.size.width * page;
    frame.origin.y = 0;
    imgView.frame = frame;
    imgView.tag = VIEW_FOR_ZOOM_TAG;
    [imgView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    
    frame = imgScrollView.bounds;
    frame.origin.x = frame.size.width * page;
    UIScrollView *pageScrollView = [[UIScrollView alloc] initWithFrame:frame];
    [pageScrollView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    pageScrollView.tag = (page + 20);
    pageScrollView.minimumZoomScale = 1.0f;
    pageScrollView.maximumZoomScale = 4.0f;
    pageScrollView.zoomScale = 1.0f;
    pageScrollView.contentSize = imgView.bounds.size;
    pageScrollView.delegate = self;
    pageScrollView.showsHorizontalScrollIndicator = NO;
    pageScrollView.showsVerticalScrollIndicator = NO;
    [pageScrollView addSubview:imgView];
    
    imgView.multipleTouchEnabled = YES;
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *dblRecognizer;
    dblRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(didDoubleTap:)];
    [dblRecognizer setNumberOfTapsRequired:2];
    [imgView addGestureRecognizer:dblRecognizer];
    
    UITapGestureRecognizer *recognizer;
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                         action:@selector(handleTapFrom:)];
    [recognizer requireGestureRecognizerToFail:dblRecognizer];
    [imgView addGestureRecognizer:recognizer];
    
    [imgScrollView addSubview:pageScrollView];
}

#pragma -mark scroll view delegate methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.imageScrollView) {
        return;
    }

    if (pageControlUsed) return;
    
    CGFloat pageWidth = self.imageScrollView.frame.size.width;
    int page = floor((self.imageScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    [self loadNeighborPagesForPage:page];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //if (scrollView == self.imageScrollView) {
    //    return nil;
    //}
    //UIView *parentView = [self.imageScrollView viewWithTag:(self.pageControl.currentPage + 20)];
    return [scrollView viewWithTag:VIEW_FOR_ZOOM_TAG];
}

#pragma -mark async image downloader

-(UIImageView *)asyncImageViewForPage:(int)page
{
    NSNumber *pageNumber = [NSNumber numberWithInt:page];
    NSLog(@"setting the image for page %@", pageNumber);
    UIImageView *imgView = [[UIImageView alloc] initWithImage:self.loadingImage];
    if ([self.downloadedImages objectForKey:pageNumber]) {
        imgView.image = self.downloadedImages[pageNumber];
    } else {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        if (!self.disableSpinnerWhenLoadinImage) {
            CGPoint center = self.imageScrollView.center;
            center.x = self.imageScrollView.bounds.size.width / 2;
            
            spinner.center = center;
            [spinner startAnimating];
            
            [imgView addSubview:spinner];
        }
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("iamge downloader", NULL);
        
        dispatch_async(downloadQueue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[self.imagesUrls objectAtIndex:page]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.disableSpinnerWhenLoadinImage) [spinner removeFromSuperview];
                UIImage *image = [UIImage imageWithData:imgData];
                if (self.tempDownloadedImageSavingEnabled)
                    self.downloadedImages[pageNumber] = image;
                imgView.image = image;
            });
        });
    }
    
    if (page == self.pageControl.currentPage)
    {
        int imageScrollViewWidth = self.imageScrollView.frame.size.width;
        int imageScrollViewHeight = self.imageScrollView.frame.size.height;
        [self.imageScrollView scrollRectToVisible:CGRectMake(page * imageScrollViewWidth, 0, imageScrollViewWidth, imageScrollViewHeight) animated:NO];
    }
    
    return imgView;
}

#pragma -mark other

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)setInitialPage:(NSInteger)page
{
    self.pageControl.currentPage = page;
    [self setNeedsLayout];
    
}

-(NSInteger)currentPage
{
    return self.pageControl.currentPage;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    //UIView *view = [self.imageScrollView viewWithTag:(self.pageControl.currentPage + 20)];
    UIView *parentView = [self.imageScrollView viewWithTag:(self.pageControl.currentPage + 20)];
    UIView *view = [parentView viewWithTag:VIEW_FOR_ZOOM_TAG];
    
    zoomRect.size.height = [view frame].size.height / scale;
    zoomRect.size.width  = [view frame].size.width  / scale;
    
    center = [view convertPoint:center fromView:parentView];
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:1.0];
    
    _imagesUrls = nil;
    [self.superview removeFromSuperview];
    
    [self.superview setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    
    [UIView commitAnimations];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)recognizer
{
    UIScrollView *imageScrollView = (UIScrollView*)[recognizer.view superview];
    
    if (imageScrollView.zoomScale > imageScrollView.minimumZoomScale)
    {
        [imageScrollView setZoomScale:imageScrollView.minimumZoomScale animated:YES];
    }
    else
    {
        CGPoint touch = [recognizer locationInView:recognizer.view];
        
        CGSize scrollViewSize = self.bounds.size;
        
        CGFloat w = scrollViewSize.width / imageScrollView.maximumZoomScale;
        CGFloat h = scrollViewSize.height / imageScrollView.maximumZoomScale;
        CGFloat x = touch.x-(w/2.0);
        CGFloat y = touch.y-(h/2.0);
        
        CGRect rectTozoom=CGRectMake(x, y, w, h);
        [imageScrollView zoomToRect:rectTozoom animated:YES];
    }
}

@end

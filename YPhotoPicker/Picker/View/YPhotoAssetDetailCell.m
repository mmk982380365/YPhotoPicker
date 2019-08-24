//
//  YPhotoAssetDetailCell.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAssetDetailCell.h"
#import "YPhotoPickerManager.h"

@interface YPhotoAssetDetailCell () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) CALayer *imageLayer;

@property (assign, nonatomic) PHImageRequestID reqID;

@end

@implementation YPhotoAssetDetailCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.multipleTouchEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bouncesZoom = YES;
        self.scrollView.maximumZoomScale = 4.0;
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.scrollsToTop = NO;
        [self.contentView addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        [self.scrollView addSubview:self.imageView];
        
        //        self.imageLayer = [CALayer layer];
        //        self.imageLayer.drawsAsynchronously = YES;
        //        [self.imageView.layer addSublayer:self.imageLayer];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAct:)];
        [self.scrollView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAct:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.scrollView addGestureRecognizer:doubleTap];
        
        [tap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)resetZoom {
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    }
}

-(void)tapAct:(UIGestureRecognizer *)recognizer{
    self.cellSingleClick ? self.cellSingleClick() : nil;
}

-(void)doubleTapAct:(UIGestureRecognizer *)recognizer{
    if (self.scrollView.zoomScale > 1) {
        [self resetZoom];
    }else{
        CGPoint touchPoint = [recognizer locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
    
}

- (void)setAsset:(YPhotoAsset *)asset {
    if (_asset != asset) {
        _asset = asset;
        [self resetZoom];
        if (self.reqID) {
            [YPhotoPickerManager cancelLoadImage:self.reqID];
        }
        
        CGFloat width = asset.asset.pixelWidth;
        CGFloat height = asset.asset.pixelHeight;
        [self layoutIfNeeded];
        float imageHeight = self.frame.size.width * (height / width);
        CGRect imageFrame = CGRectMake(0, 0, self.frame.size.width, imageHeight);
        
        if (width < self.frame.size.width && height < self.frame.size.height) {
            imageFrame.size = CGSizeMake(width, height);
        }
        
        self.imageView.frame = imageFrame;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.imageLayer.frame = self.imageView.bounds;
        [CATransaction commit];
        self.scrollView.contentSize = imageFrame.size;
        
        if (imageFrame.size.height < self.frame.size.height) {
            self.imageView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
        }else{
            self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5, self.scrollView.contentSize.height * 0.5);
        }
        
        CGFloat scale = [UIScreen mainScreen].scale;
        
        CGSize targetSize = CGSizeMake(imageFrame.size.width * scale, imageFrame.size.height * scale);
        self.imageView.image = nil;
        self.reqID = [self.manager getImageWithAsset:asset targetSize:targetSize callback:^(UIImage * _Nullable image) {
            self.imageView.image = image;
        }];
        
    }
}

- (void)loadFull {
    if (self.reqID) {
        [YPhotoPickerManager cancelLoadImage:self.reqID];
    }
    CGFloat aspect = (float)self.asset.asset.pixelHeight / (float)self.asset.asset.pixelWidth;
    CGSize preferredSize = CGSizeZero;
    preferredSize.width = self.frame.size.width * 1.5;
    preferredSize.height = preferredSize.width * aspect;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.reqID = [self.manager getImageWithAsset:self.asset targetSize:preferredSize callback:^(UIImage * _Nullable image) {
            self.imageView.image = image;
        }];
    });
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end

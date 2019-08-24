//
//  YPhotoAssetDetailViewController.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAssetDetailViewController.h"
#import "YPhotoTopView.h"
#import "YPhotoAssetDetailCell.h"
#import "YPhotoAssetListToolView.h"
#import "YPhotoAssetVideoCell.h"
#import "YPhotoProgressView.h"

#import <AVKit/AVKit.h>

@interface YPhotoAssetDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, YPhotoAssetVideoCellDelegate>

@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) YPhotoTopView *topView;

@property (strong, nonatomic) YPhotoAssetListToolView *bottomView;

@property (strong, nonatomic) YPhotoProgressView *progressView;

@property (assign, nonatomic) BOOL statusBarHidden;

@property (strong, nonatomic) AVPlayerItem *currentItem;

@property (strong, nonatomic) id timeObserver;

@property (weak, nonatomic) AVPlayer *player;

@property (strong, nonatomic) dispatch_queue_t timeQueue;

@property (assign, nonatomic) BOOL hasYear;

@property (assign, nonatomic) NSTimeInterval totalTime;

@property (copy, nonatomic) NSString *totalTimeString;

@property (assign, nonatomic) BOOL isPlayToEnd;

@end

@implementation YPhotoAssetDetailViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return self.statusBarHidden;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEndNote:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.timeQueue = dispatch_queue_create("time obs", DISPATCH_QUEUE_SERIAL);
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat margin = 8;
    
    
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.minimumLineSpacing = margin * 2;
    self.collectionViewLayout.minimumInteritemSpacing = margin * 2;
    self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, margin, 0, margin);
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionViewLayout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:self.collectionViewLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:YPhotoAssetDetailCell.class forCellWithReuseIdentifier:NSStringFromClass(YPhotoAssetDetailCell.class)];
    [self.collectionView registerClass:YPhotoAssetVideoCell.class forCellWithReuseIdentifier:NSStringFromClass(YPhotoAssetVideoCell.class)];
    self.collectionView.pagingEnabled = YES;
    [self.view addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.topView = [[YPhotoTopView alloc] init];
    [self.topView.leftBtn addTarget:self action:@selector(backAct:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.selectBtn addTarget:self action:@selector(selectAct:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.topView];
    self.topView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.bottomView = [[YPhotoAssetListToolView alloc] initWithStyle:YPhotoAssetListToolViewStyleBlack];
    [self.bottomView.confirmBtn addTarget:self action:@selector(confirmAct:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView prepareForPlay];
    [self.bottomView.playBtn addTarget:self action:@selector(playAct:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomView];
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.progressView = [[YPhotoProgressView alloc] init];
    [self.bottomView addSubview:self.progressView];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.progress = 1;
    if (@available(iOS 11, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    CGFloat offset = self.selectedIndex * ([UIScreen mainScreen].bounds.size.width + margin * 2);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.collectionView.contentOffset = CGPointMake(offset, 0);
        if (self.selectedIndex == 0) {
            [self checkingMediaType:self.selectedIndex];
        }
    });
    self.topView.selectBtn.hidden = !self.navigationController.manager.allowMultipleSelection;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionViewLayout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    CGFloat margin = 8;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[_collectionView]-(margin)-|" options:NSLayoutFormatAlignAllTop metrics:@{@"margin": @(-margin)} views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_collectionView]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_topView]-0-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_topView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_topView(height)]" options:NSLayoutFormatAlignAllTop metrics:@{@"height": @([YPhotoPickerManager iPhoneXStyle] ? 88 : 64)} views:NSDictionaryOfVariableBindings(_topView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_progressView]-0-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_progressView(2)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
    
    [NSLayoutConstraint activateConstraints:@[
                                              [self.bottomView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                              [self.bottomView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.bottomView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObserverForTime];
    for (UITableViewCell *cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:YPhotoAssetVideoCell.class]) {
            [[(YPhotoAssetVideoCell *)cell player] pause];
        }
    }
}

- (void)playAct:(UIButton *)btn {
    if (btn.isSelected) {
        [self.player pause];
    } else {
        if (self.isPlayToEnd) {
            self.isPlayToEnd = NO;
            [self.player seekToTime:kCMTimeZero];
        }
        [self.player play];
    }
}

- (void)backAct:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectAct:(UIButton *)btn {
    YPhotoAsset *asset = self.album.assets[self.selectedIndex];
    if (!asset.isSelected) {
        if (self.navigationController.maxCount == 0) {
            //不限
            asset.isSelected = YES;
        } else {
            NSInteger selectedCount = [[self.album.assets valueForKeyPath:@"@sum.isSelected"] integerValue];
            if (selectedCount < self.navigationController.maxCount) {
                asset.isSelected = YES;
            } else {
                //show alert
                NSString *hint = [NSString stringWithFormat:@"您最多可以选择%d张图片。", (int)self.navigationController.maxCount];
                [self showHint:hint];
            }
        }
    } else {
        asset.isSelected = NO;
    }
    
    self.topView.selectBtn.selected = asset.isSelected;
    [self.topView.selectBtn.layer addAnimation:[YPhotoPickerManager zoomingAnimation] forKey:@""];
}

- (void)confirmAct:(UIButton *)btn {
    NSInteger selectedCount = [[self.album.assets valueForKeyPath:@"@sum.isSelected"] integerValue];
    if (selectedCount == 0) {
        YPhotoAsset *asset = [self.album.assets objectAtIndex:self.selectedIndex];
        asset.isSelected  = YES;
        self.topView.selectBtn.selected = YES;
    }
    [self.navigationController presentSelectedAssetsWithAlbum:self.album];
}

- (void)toggleViewTap:(UIGestureRecognizer *)recognizer {
    
    if (self.statusBarHidden) {
        [self showTopBottomView:YES];
    } else {
        [self hideTopBottomView:YES];
    }
    
}

- (void)playToEndNote:(NSNotification *)note {
    self.isPlayToEnd = YES;
    [self showTopBottomView:YES];
}

- (void)showTopBottomView:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:@"" context:@""];
    }
    self.progressView.alpha = 1;
    self.statusBarHidden = NO;
    self.topView.alpha = 1;
    self.bottomView.alpha = 1;
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)hideTopBottomView:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:@"" context:@""];
    }
    self.progressView.alpha = 0;
    self.statusBarHidden = YES;
    self.topView.alpha = 0;
    self.bottomView.alpha = 0;
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)showVideoItem {
    self.progressView.hidden = NO;
    self.bottomView.playBtn.hidden = NO;
    self.bottomView.timeLabel.hidden = NO;
}

- (void)hideVideoItem {
    self.progressView.hidden = YES;
    self.bottomView.playBtn.hidden = YES;
    self.bottomView.timeLabel.hidden = YES;
}

- (void)addObserverForTime:(AVPlayerItem *)item {
    __weak typeof(self) ws = self;
    self.progressView.duration = 0.05;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.05, item.duration.timescale) queue:self.timeQueue usingBlock:^(CMTime time) {
        __strong typeof(ws) self = ws;
        double current = CMTimeGetSeconds(time);
        double progress = current / self.totalTime;
        if (progress < 0) {
            progress = 0;
        } else if (progress > 1) {
            progress = 1;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //progress != 0 ? YES : NO
            [self.progressView setProgress:progress animated:progress != 0 ? YES : NO];
            self.bottomView.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [YPhotoPickerManager convertTime:current hasYear:self.hasYear], self.totalTimeString];
        });
    }];
}

- (void)removeObserverForTime {
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
    }
}

- (void)checkingMediaType:(NSInteger)index {
    
    YPhotoAsset *asset = self.album.assets[index];
    if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
        YPhotoAssetVideoCell *cell = (YPhotoAssetVideoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if ([cell isKindOfClass:YPhotoAssetVideoCell.class]) {
            while (YES) {
                if (cell.player.currentItem) {
                    break;
                }
            }
            [self removeObserverForTime];
            self.player = cell.player;
            NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
            NSTimeInterval current = CMTimeGetSeconds(cell.player.currentItem.currentTime);
            self.hasYear = duration > 3600.0;
            self.totalTime = duration;
            self.totalTimeString = [YPhotoPickerManager convertTime:duration hasYear:self.hasYear];
            self.bottomView.timeLabel.text = [NSString stringWithFormat:@"%@/%@", self.hasYear ? @"00:00:00" : [YPhotoPickerManager convertTime:current hasYear:self.hasYear], self.totalTimeString];
            self.progressView.progress = current / duration;
            [self addObserverForTime:cell.player.currentItem];
        }
        [self showVideoItem];
    } else {
        [self hideVideoItem];
    }
}

#pragma mark - YPhotoAssetVideoCellDelegate

- (void)cellDidPreparedToPlay {
    self.bottomView.playBtn.enabled = YES;
}

- (void)cellDidNotPreparedToPlay {
    self.bottomView.playBtn.enabled = NO;
}

- (void)cellIsPause {
    self.bottomView.playBtn.selected = NO;
}

- (void)cellIsPlay {
    self.bottomView.playBtn.selected = YES;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YPhotoAsset *asset = self.album.assets[indexPath.item];
    if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
        YPhotoAssetVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(YPhotoAssetVideoCell.class) forIndexPath:indexPath];
        cell.manager = self.navigationController.manager;
        cell.asset = asset;
        cell.delegate = self;
        __weak typeof(self) ws = self;
        cell.cellSingleClick = ^{
            __strong typeof(ws) self = ws;
            [self toggleViewTap:nil];
        };
        return cell;
    } else {
        YPhotoAssetDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(YPhotoAssetDetailCell.class) forIndexPath:indexPath];
        cell.manager = self.navigationController.manager;
        cell.asset = asset;
        __weak typeof(self) ws = self;
        cell.cellSingleClick = ^{
            __strong typeof(ws) self = ws;
            [self toggleViewTap:nil];
        };
        return cell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.album.assets.count;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:YPhotoAssetDetailCell.class]) {
        [(YPhotoAssetDetailCell *)cell resetZoom];
    } else if ([cell isKindOfClass:YPhotoAssetVideoCell.class]) {
        [(YPhotoAssetVideoCell *)cell resetTime];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (page < 0) {
        page = 0;
    } else if (page >= self.album.assets.count) {
        page = self.album.assets.count - 1;
    }
    self.selectedIndex = page;
    YPhotoAsset *asset = self.album.assets[self.selectedIndex];
    self.topView.selectBtn.selected = asset.isSelected;
//    NSLog(@"isDragging=%d isTracking=%d isDecelerating=%d", scrollView.isDragging, scrollView.isTracking, scrollView.isDecelerating);
    if (!scrollView.isDragging && !scrollView.isTracking && !scrollView.isDecelerating) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.00 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollViewDidEndDecelerating:scrollView];
        });
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.player pause];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    
    [self checkingMediaType:self.selectedIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

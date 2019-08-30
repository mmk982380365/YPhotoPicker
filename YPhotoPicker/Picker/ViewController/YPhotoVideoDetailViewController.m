//
//  YPhotoVideoDetailViewController.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/16.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoVideoDetailViewController.h"
#import <AVKit/AVKit.h>
#import "YPhotoTopView.h"
#import "YPhotoAssetListToolView.h"
#import "YPhotoProgressView.h"

@interface YPhotoVideoDetailViewController ()

@property (strong, nonatomic) dispatch_queue_t timeQueue;

@property (strong, nonatomic) AVPlayerItem *currentItem;

@property (strong, nonatomic) AVPlayer *player;

@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) YPhotoTopView *topView;

@property (strong, nonatomic) YPhotoAssetListToolView *bottomView;

@property (strong, nonatomic) YPhotoProgressView *progressView;

@property (strong, nonatomic) id timeObserver;

@property (assign, nonatomic) BOOL hasHour;

@property (assign, nonatomic) NSTimeInterval totalTime;

@property (copy, nonatomic) NSString *totalTimeString;

@property (assign, nonatomic) BOOL statusBarHidden;

@property (assign, nonatomic) BOOL isPlayToEnd;

@end

@implementation YPhotoVideoDetailViewController

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
    [self.player removeObserver:self forKeyPath:@"rate"];
    if (self.currentItem) {
        [self.currentItem removeObserver:self forKeyPath:@"status"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEndNote:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.timeQueue = dispatch_queue_create("time obs", DISPATCH_QUEUE_SERIAL);
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.player = [AVPlayer playerWithPlayerItem:nil];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:self.playerLayer];
    
    self.topView = [[YPhotoTopView alloc] init];
    [self.topView.leftBtn addTarget:self action:@selector(backAct:) forControlEvents:UIControlEventTouchUpInside];
    self.topView.selectBtn.hidden = YES;
    self.topView.selectBtn.enabled = NO;
    [self.view addSubview:self.topView];
    self.topView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.bottomView = [[YPhotoAssetListToolView alloc] initWithStyle:YPhotoAssetListToolViewStyleBlack];
    [self.bottomView.confirmBtn addTarget:self action:@selector(confirmAct:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView prepareForPlay];
    [self.bottomView.playBtn addTarget:self action:@selector(playAct:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomView];
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.progressView = [[YPhotoProgressView alloc] init];
//    self.progressView.trackTintColor = [UIColor clearColor];
//    self.progressView.progressTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressView];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleViewTap:)]];
    
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial context:nil];
    
    self.progressView.progress = 0;
    
    [self.navigationController.manager getVideoWithAsset:self.asset callback:^(AVAsset * _Nullable videoAsset) {
        AVPlayerItem *currentItem = [AVPlayerItem playerItemWithAsset:videoAsset];
        self.currentItem = currentItem;
    }];
    
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_topView]-0-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_topView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_topView(height)]" options:NSLayoutFormatAlignAllTop metrics:@{@"height": @([YPhotoPickerManager iPhoneXStyle] ? 88 : 64)} views:NSDictionaryOfVariableBindings(_topView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_progressView]-0-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_progressView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressView(2)]-0-[_bottomView]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_progressView, _bottomView)]];
    
    [NSLayoutConstraint activateConstraints:@[
                                              [self.bottomView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                              [self.bottomView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.bottomView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.playerLayer.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self showTopBottomView:NO];
    if (self.player.rate > 0) {
        [self.player pause];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObserverForTime];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (self.currentItem.status) {
                case AVPlayerItemStatusReadyToPlay:
                {
                    self.bottomView.playBtn.enabled = YES;
                    NSTimeInterval duration = CMTimeGetSeconds(self.currentItem.duration);
                    self.hasHour = duration > 3600.0;
                    self.totalTime = duration;
                    self.totalTimeString = [YPhotoPickerManager convertTime:duration hasHour:self.hasHour];
                    self.bottomView.timeLabel.text = [NSString stringWithFormat:@"%@/%@", self.hasHour ? @"00:00:00" : @"00:00", self.totalTimeString];
                    [self addObserverForTime];
                }
                    break;
                    
                default:
                    self.bottomView.playBtn.enabled = NO;
                    break;
            }
        });
    } else if ([keyPath isEqualToString:@"rate"]) {
        NSLog(@"%f", self.player.rate);
        if (self.player.rate == 0) {
            self.bottomView.playBtn.selected = NO;
        } else {
            self.bottomView.playBtn.selected = YES;
        }
    }
}

- (void)backAct:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmAct:(UIButton *)btn {
    
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

- (void)playToEndNote:(NSNotification *)note {
    self.isPlayToEnd = YES;
    [self showTopBottomView:YES];
}

- (void)toggleViewTap:(UIGestureRecognizer *)recognizer {
    
    if (self.statusBarHidden) {
        [self showTopBottomView:YES];
    } else {
        [self hideTopBottomView:YES];
    }
    
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

- (void)addObserverForTime {
    __weak typeof(self) ws = self;
    self.progressView.duration = 0.05;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.05, self.currentItem.duration.timescale) queue:self.timeQueue usingBlock:^(CMTime time) {
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
            self.bottomView.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [YPhotoPickerManager convertTime:current hasHour:self.hasHour], self.totalTimeString];
        });
    }];
}

- (void)removeObserverForTime {
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
    }
}

- (void)setCurrentItem:(AVPlayerItem *)currentItem {
    if (_currentItem != currentItem) {
        if (_currentItem) {
            [_currentItem removeObserver:self forKeyPath:@"status"];
        }
        _currentItem = currentItem;
        [self.player replaceCurrentItemWithPlayerItem:_currentItem];
        [_currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:nil];
    }
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

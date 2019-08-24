//
//  YPhotoAssetVideoCell.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/19.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAssetVideoCell.h"

@interface YPhotoAssetVideoCell ()

@property (strong, nonatomic, readwrite) AVPlayer *player;

@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (assign, nonatomic) PHImageRequestID requestID;

@property (strong, nonatomic) id timeObserver;

@property (assign, nonatomic) BOOL hasYear;

@property (assign, nonatomic) NSTimeInterval totalTime;

@property (copy, nonatomic) NSString *totalTimeString;

@end

@implementation YPhotoAssetVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.contentView.layer addSublayer:self.playerLayer];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAct:)];
        [self.contentView addGestureRecognizer:tap];
    }
    return self;
}

- (void)dealloc
{
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
    }
    if (_player) {
        [_player removeObserver:self forKeyPath:@"rate"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([@"status" isEqualToString:keyPath]) {
        if (self.playerItem.status == AVPlayerStatusReadyToPlay) {
            if ([self checkDelegateForSelector:@selector(cellDidPreparedToPlay)]) {
                [self.delegate cellDidPreparedToPlay];
            }
        } else {
            if ([self checkDelegateForSelector:@selector(cellDidNotPreparedToPlay)]) {
                [self.delegate cellDidNotPreparedToPlay];
            }
            
        }
    } else if ([@"rate" isEqualToString:keyPath]) {
        if (self.player.rate == 0) {
            if ([self checkDelegateForSelector:@selector(cellIsPause)]) {
                [self.delegate cellIsPause];
            }
        } else {
            if ([self checkDelegateForSelector:@selector(cellIsPlay)]) {
                [self.delegate cellIsPlay];
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.contentView.bounds;
}

-(void)tapAct:(UIGestureRecognizer *)recognizer{
    self.cellSingleClick ? self.cellSingleClick() : nil;
}

- (void)resetTime {
    [self.player seekToTime:kCMTimeZero];
}

- (void)setAsset:(YPhotoAsset *)asset {
    if (_asset != asset) {
        _asset = asset;
        [YPhotoPickerManager cancelLoadImage:self.requestID];
        [self resetTime];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.requestID = [self.manager getVideoWithAsset:asset callback:^(AVAsset * _Nullable videoAsset) {
            self.playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
        }];
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
    }
    _playerItem = playerItem;
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:nil];
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _player;
}

#pragma mark - helper

- (BOOL)checkDelegateForSelector:(SEL)selector {
    return self.delegate && [self.delegate conformsToProtocol:@protocol(YPhotoAssetVideoCellDelegate)] && [self.delegate respondsToSelector:selector];
}

@end

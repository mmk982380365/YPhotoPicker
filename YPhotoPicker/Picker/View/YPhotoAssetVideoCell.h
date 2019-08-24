//
//  YPhotoAssetVideoCell.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/19.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPhotoAsset.h"
#import <AVKit/AVKit.h>
#import "YPhotoPickerManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YPhotoAssetVideoCellDelegate <NSObject>

- (void)cellDidNotPreparedToPlay;

- (void)cellDidPreparedToPlay;

- (void)cellIsPlay;

- (void)cellIsPause;

@end

@interface YPhotoAssetVideoCell : UICollectionViewCell

@property (weak, nonatomic) id<YPhotoAssetVideoCellDelegate> delegate;

@property (strong, nonatomic, readonly) AVPlayer *player;

@property (strong, nonatomic) YPhotoAsset *asset;

@property (strong, nonatomic) YPhotoPickerManager *manager;

@property (copy, nonatomic) void (^cellSingleClick)(void);

- (void)resetTime;

@end

NS_ASSUME_NONNULL_END

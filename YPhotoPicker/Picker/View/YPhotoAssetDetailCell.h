//
//  YPhotoAssetDetailCell.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPhotoAsset.h"
#import "YPhotoPickerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoAssetDetailCell : UICollectionViewCell

@property (strong, nonatomic) YPhotoAsset *asset;

@property (copy, nonatomic) void (^cellSingleClick)(void);

@property (strong, nonatomic) YPhotoPickerManager *manager;

- (void)resetZoom;

@end

NS_ASSUME_NONNULL_END

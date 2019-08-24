//
//  YPhotoAssetListCell.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPhotoAsset.h"
#import "YPhotoPickerController.h"
#import "YPhotoPickerManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YPhotoAssetListCellDelegate <NSObject>

- (void)cellDidSelectAsset:(YPhotoAsset *)asset;

@end

@interface YPhotoAssetListCell : UICollectionViewCell

@property (weak, nonatomic) id<YPhotoAssetListCellDelegate> delegate;

@property (strong, nonatomic) YPhotoAsset *asset;

@property (strong, nonatomic) YPhotoPickerManager *manager;

@end

NS_ASSUME_NONNULL_END

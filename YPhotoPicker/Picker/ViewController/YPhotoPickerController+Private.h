//
//  YPhotoPickerController+Private.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoPickerController.h"
#import "YPhotoPickerManager.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoPickerController (Private)

@property (strong, nonatomic, readonly) YPhotoPickerManager *manager;

- (void)closeViewController;

- (void)presentSelectedAssetsWithAlbum:(YPhotoAlbum *)album;

- (void)showLoading;

- (void)hideLoading;

@end

NS_ASSUME_NONNULL_END

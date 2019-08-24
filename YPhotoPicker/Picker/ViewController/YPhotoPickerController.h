//
//  YPhotoPickerController.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString * YPhotoPickerControllerInfoKey NS_TYPED_ENUM;

NS_ASSUME_NONNULL_BEGIN

//原图
UIKIT_EXTERN YPhotoPickerControllerInfoKey const YPhotoPickerControllerOriginalImage __TVOS_PROHIBITED;
//视频类型图片url NSURL
UIKIT_EXTERN YPhotoPickerControllerInfoKey const YPhotoPickerControllerMediaURL __TVOS_PROHIBITED;
//媒体类型 kUTTypeImage kUTTypeVideo
UIKIT_EXTERN YPhotoPickerControllerInfoKey const YPhotoPickerControllerMediaType __TVOS_PROHIBITED;
//图片旋转
UIKIT_EXTERN YPhotoPickerControllerInfoKey const YPhotoPickerControllerImageOrientation __TVOS_PROHIBITED;

/**
 媒体类型

 - YPhotoPickerMediaTypeAll: 全部
 - YPhotoPickerMediaTypePhotos: 只有图片
 - YPhotoPickerMediaTypeVideos: 只有视频
 */
typedef NS_ENUM(NSInteger, YPhotoPickerMediaType) {
    YPhotoPickerMediaTypeAll = 0,
    YPhotoPickerMediaTypePhotos,
    YPhotoPickerMediaTypeVideos
};

@protocol YPhotoPickerControllerDelegate;

@interface YPhotoPickerController : UINavigationController

/**
 是否允许多选
 */
@property (assign, nonatomic) BOOL allowMultipleSelection;

/**
 最大选择数量
 */
@property (assign, nonatomic) NSInteger maxCount;

/**
 相册媒体类型
 */
@property (assign, nonatomic) YPhotoPickerMediaType mediaType;

/**
 设置视频转码质量 默认 AVAssetExportPresetPassthrough
 */
@property (copy, nonatomic) NSString *videoExportPreset;

/**
 代理
 */
@property (nullable,nonatomic,weak) id <UINavigationControllerDelegate, YPhotoPickerControllerDelegate> delegate;

@end

@protocol YPhotoPickerControllerDelegate <NSObject>

@optional

/**
 选完图片的回调

 @param picker picker
 @param info 图片数组
 */
- (void)photoPickerController:(YPhotoPickerController *)picker
didFinishPickingMediaWithInfo:(NSArray<NSDictionary<YPhotoPickerControllerInfoKey, id> *> *)info;

/**
 点击取消的回调

 @param picker <#picker description#>
 */
- (void)photoPickerControllerDidCancel:(YPhotoPickerController *)picker;

@end

NS_ASSUME_NONNULL_END

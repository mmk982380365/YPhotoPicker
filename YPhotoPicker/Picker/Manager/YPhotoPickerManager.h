//
//  YPhotoPickerManager.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPhotoAlbum.h"
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YPhotoPickerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoPickerManager : NSObject

#pragma mark - Options

/**
 允许多选
 */
@property (assign, nonatomic) BOOL allowMultipleSelection;

/**
 媒体类型
 */
@property (assign, nonatomic) YPhotoPickerMediaType mediaType;

#pragma mark - Authorization

/**
 获取相册权限

 @param block 结果回调
 */
- (void)requestAuthorization:(void (^)(BOOL authorized))block;

#pragma mark - Albums

/**
 获取相册列表

 @param block 回调
 */
- (void)requestAlbumList:(void (^)(NSArray<YPhotoAlbum *> *albums))block;

/**
 相册列表
 */
@property (strong, nonatomic) NSArray *albums;

#pragma mark - Data Request

/**
 获取指定尺寸的图片

 @param asset 图片model
 @param size 图片尺寸
 @param block 回调
 @return 请求id
 */
- (PHImageRequestID)getImageWithAsset:(YPhotoAsset *)asset targetSize:(CGSize)size callback:(void (^)(UIImage * _Nullable image))block;

/**
 获取图片data

 @param asset 图片model
 @param block 回调
 @return 请求id
 */
- (PHImageRequestID)getImageDataWithAsset:(YPhotoAsset *)asset callback:(void (^)(NSData * _Nullable imageData, UIImageOrientation orientation))block;

/**
 获取视频的asset

 @param asset 资源model
 @param block 回调
 @return 请求id
 */
- (PHImageRequestID)getVideoWithAsset:(YPhotoAsset *)asset callback:(void (^)(AVAsset * _Nullable videoAsset))block;

/**
 获取视频转码对象

 @param asset 资源model
 @param exportPreset 导出预设
 @param block 回调
 @return 请求id
 */
- (PHImageRequestID)getVideoExportSessionWithAsset:(YPhotoAsset *)asset exportPreset:(NSString *)exportPreset callback:(void (^)(AVAssetExportSession * _Nullable exportSession))block;

/**
 取消读取

 @param requestID 请求id
 */
+ (void)cancelLoadImage:(PHImageRequestID)requestID;

#pragma mark - Utils

/**
 缩放动画

 @return 动画
 */
+ (CAAnimation *)zoomingAnimation;

/**
 是否有刘海

 @return 是否有刘海
 */
+ (BOOL)iPhoneXStyle;

/**
 转换时间

 @param time 时间戳
 @return 时间
 */
+ (NSString *)convertTime:(NSTimeInterval)time;

/**
 转换时间

 @param time 时间戳
 @param hasHour 是否有小时
 @return 时间
 */
+ (NSString *)convertTime:(NSTimeInterval)time hasHour:(BOOL)hasHour;

/**
 时间线程
 */
@property (strong, nonatomic) dispatch_queue_t timeQueue;

/**
 保存视频的路径

 @param asset 资源model
 @return 路径
 */
- (NSString *)videoPathWithAsset:(YPhotoAsset *)asset;

/**
 从项目里读取图片

 @param imageNamed 图片名
 @return 图片
 */
+ (UIImage * _Nullable)imageNamedFromBundle:(NSString *)imageNamed;

@end

NS_ASSUME_NONNULL_END

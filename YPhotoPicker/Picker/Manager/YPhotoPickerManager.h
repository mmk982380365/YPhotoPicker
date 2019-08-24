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

@property (assign, nonatomic) BOOL allowMultipleSelection;

@property (assign, nonatomic) YPhotoPickerMediaType mediaType;

- (void)requestAuthorization:(void (^)(BOOL authorized))block;

- (void)requestAlbumList:(void (^)(NSArray<YPhotoAlbum *> *albums))block;

@property (strong, nonatomic) NSArray *albums;

- (PHImageRequestID)getImageWithAsset:(YPhotoAsset *)asset targetSize:(CGSize)size callback:(void (^)(UIImage * _Nullable image))block;

- (PHImageRequestID)getImageDataWithAsset:(YPhotoAsset *)asset callback:(void (^)(NSData * _Nullable imageData, UIImageOrientation orientation))block;

- (PHImageRequestID)getVideoWithAsset:(YPhotoAsset *)asset callback:(void (^)(AVAsset * _Nullable videoAsset))block;

- (PHImageRequestID)getVideoExportSessionWithAsset:(YPhotoAsset *)asset exportPreset:(NSString *)exportPreset callback:(void (^)(AVAssetExportSession * _Nullable exportSession))block;

+ (void)cancelLoadImage:(PHImageRequestID)requestID;

+ (CAAnimation *)zoomingAnimation;

+ (BOOL)iPhoneXStyle;

+ (NSString *)convertTime:(NSTimeInterval)time;

+ (NSString *)convertTime:(NSTimeInterval)time hasYear:(BOOL)hasYear;

@property (strong, nonatomic) dispatch_queue_t timeQueue;

- (NSString *)videoPathWithAsset:(YPhotoAsset *)asset;

@end

NS_ASSUME_NONNULL_END

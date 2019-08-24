//
//  YPhotoPickerManager.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoPickerManager.h"
#import <Photos/Photos.h>
#import <sys/utsname.h>
#import <CommonCrypto/CommonDigest.h>

@interface YPhotoPickerManager ()

@end

@implementation YPhotoPickerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeQueue = dispatch_queue_create("time obs", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)requestAuthorization:(void (^)(BOOL))block {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusDenied:
            block ? block(NO) : nil;
            break;
        case PHAuthorizationStatusAuthorized:
            block ? block(YES) : nil;
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                block ? block(status == PHAuthorizationStatusAuthorized) : nil;
            }];
        }
            break;
        default:
            block ? block(NO) : nil;
            break;
    }
}

- (void)requestAlbumList:(void (^)(NSArray<YPhotoAlbum *> * _Nonnull))block {
    NSMutableArray<YPhotoAlbum *> *albums = [NSMutableArray arrayWithCapacity:0];
    
    [albums addObjectsFromArray:[self collectionsWithType:PHAssetCollectionTypeSmartAlbum subType:PHAssetCollectionSubtypeAny]];
    [albums addObjectsFromArray:[self collectionsWithType:PHAssetCollectionTypeAlbum subType:PHAssetCollectionSubtypeAny]];
    
    self.albums = albums;
    block ? block(albums) : nil;
}

- (NSArray<YPhotoAlbum *> *)collectionsWithType:(PHAssetCollectionType)type subType:(PHAssetCollectionSubtype)subType {
    NSMutableArray<YPhotoAlbum *> *albums = [NSMutableArray arrayWithCapacity:0];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHFetchResult *fetch = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:subType options:fetchOptions];
    for (PHAssetCollection *collection in fetch) {
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) {
            continue;
        }
        YPhotoAlbum *album = [[YPhotoAlbum alloc] init];
        PHFetchOptions *assetFetchOptions = [[PHFetchOptions alloc] init];
        assetFetchOptions.includeHiddenAssets = NO;
        if (self.mediaType > 0) {
            assetFetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld", self.mediaType];
        }
        PHFetchResult *assetFetch = [PHAsset fetchAssetsInAssetCollection:collection options:assetFetchOptions];
        if (assetFetch.count == 0) {
            continue;
        }
        NSMutableArray<YPhotoAsset *> *assets = [NSMutableArray arrayWithCapacity:0];
        album.title = collection.localizedTitle;
        album.assets = assets;
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            [albums insertObject:album atIndex:0];
        } else {
            [albums addObject:album];
        }
        for (PHAsset *asset in assetFetch) {
            YPhotoAsset *assetModel = [[YPhotoAsset alloc] init];
            assetModel.asset = asset;
            [assets addObject:assetModel];
        }
    }
    return albums;
}

- (PHImageRequestID)getImageWithAsset:(YPhotoAsset *)asset targetSize:(CGSize)size callback:(void (^)(UIImage * _Nullable))block {
    if (!asset) {
        block ? block(nil) : nil;
        return 0;
    }
    PHImageRequestOptions *opts = [[PHImageRequestOptions alloc] init];
    opts.networkAccessAllowed = YES;
//    opts.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    opts.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset.asset targetSize:size contentMode:PHImageContentModeDefault options:opts resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        block ? block(result) : nil;
    }];
    
    return requestID;
}

- (PHImageRequestID)getImageDataWithAsset:(YPhotoAsset *)asset callback:(nonnull void (^)(NSData * _Nullable, UIImageOrientation))block {
    if (!asset) {
        block ? block(nil, 0) : nil;
        return 0;
    }
    PHImageRequestOptions *opts = [[PHImageRequestOptions alloc] init];
    opts.networkAccessAllowed = YES;
    
    return [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset.asset options:opts resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        block ? block(imageData, orientation) : nil;
    }];
    
}

- (PHImageRequestID)getVideoWithAsset:(YPhotoAsset *)asset callback:(void (^)(AVAsset * _Nullable))block {
    if (asset.asset.mediaType != PHAssetMediaTypeVideo) {
        block ? block(nil) : nil;
        return 0;
    }
    PHVideoRequestOptions *opts = [[PHVideoRequestOptions alloc] init];
    opts.networkAccessAllowed = YES;
    
    return [[PHImageManager defaultManager] requestAVAssetForVideo:asset.asset options:opts resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        block ? block(asset) : nil;
    }];
}

- (PHImageRequestID)getVideoExportSessionWithAsset:(YPhotoAsset *)asset exportPreset:(nonnull NSString *)exportPreset callback:(nonnull void (^)(AVAssetExportSession * _Nullable))block {
    if (asset.asset.mediaType != PHAssetMediaTypeVideo) {
        block ? block(nil) : nil;
        return 0;
    }
    PHVideoRequestOptions *opts = [[PHVideoRequestOptions alloc] init];
    opts.networkAccessAllowed = YES;
    return [[PHImageManager defaultManager] requestExportSessionForVideo:asset.asset options:opts exportPreset:exportPreset resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        block ? block(exportSession) : nil;
    }];
    
}

+ (void)cancelLoadImage:(PHImageRequestID)requestID {
    [[PHImageManager defaultManager] cancelImageRequest:requestID];
}

+ (CAAnimation *)zoomingAnimation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1.0)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                    ];
    anim.keyTimes = @[
                      @0,
                      @0.6,
                      @0.9,
                      @1
                      ];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = 0.3;
    return anim;
}

+ (NSString *)machineName {
#if TARGET_IPHONE_SIMULATOR
    NSString *model = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
#else
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithUTF8String:systemInfo.machine];
#endif
    return model;
}

+ (BOOL)iPhoneXStyle {
    static NSString *mcName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcName = [self machineName];
    });
    
    
    if ([mcName isEqualToString:@"iPhone10,3"]) return YES;// X
    if ([mcName isEqualToString:@"iPhone10,6"]) return YES;// X
    
    if ([mcName isEqualToString:@"iPhone11,2"]) return YES;// XS
    if ([mcName isEqualToString:@"iPhone11,4"]) return YES;// XS MAX
    if ([mcName isEqualToString:@"iPhone11,6"]) return YES;// XS MAX
    if ([mcName isEqualToString:@"iPhone11,8"]) return YES;// XR
    
    return NO;
}

+ (NSString *)bundleID {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
}

+ (NSString *)convertTime:(NSTimeInterval)time {
    
    NSString *result = @"";
    if (time < 60) {
        //小于一分钟
        result = [NSString stringWithFormat:@"00:%02.0f", time];
    } else if (time < 60 * 60) {
        int minute = (int)time / 60;
        int second = (int)time % 60;
        result = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    } else {
        
        int second = (int)time % 60;
        int minute = ((int)time / 60) % 60;
        int hour = (int)time / 3600;
        result = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    }
    
    return result;
}

+ (NSString *)convertTime:(NSTimeInterval)time hasYear:(BOOL)hasYear {
    NSString *result = @"";
    if (time < 60) {
        //小于一分钟
        if (hasYear) {
            result = [NSString stringWithFormat:@"00:00:%02.0f", time];
        } else {
            result = [NSString stringWithFormat:@"00:%02.0f", time];
        }
        
    } else if (time < 60 * 60) {
        int minute = (int)time / 60;
        int second = (int)time % 60;
        if (hasYear) {
            result = [NSString stringWithFormat:@"00:%02d:%02d", minute, second];
        } else {
            result = [NSString stringWithFormat:@"%02d:%02d", minute, second];
        }
    } else {
        
        int second = (int)time % 60;
        int minute = ((int)time / 60) % 60;
        int hour = (int)time / 3600;
        result = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    }
    
    return result;
}

- (NSString *)videoPathWithAsset:(YPhotoAsset *)asset {
    NSString *path = [self tempPath];
    NSString *fileName;
    if (asset.asset.localIdentifier) {
        fileName = [[self md5StrFromString:asset.asset.localIdentifier] stringByAppendingPathExtension:@"mp4"];
    } else {
        NSDateFormatter *dtfm = [[NSDateFormatter alloc] init];
            [dtfm setDateFormat:@"yyyyMMdd-HHmmss-"];
            fileName = [[[dtfm stringFromDate:asset.asset.creationDate] stringByAppendingFormat:@"%@", [self randomString]] stringByAppendingPathExtension:@"mp4"];
    }
    
    path = [path stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return path;
}

- (NSString *)tempPath {
    NSString *tempPath = NSTemporaryDirectory();
    
    tempPath = [tempPath stringByAppendingPathComponent:@"yphotopicker"];
    BOOL isDir = NO;
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&isDir];
    if (!fileExist && !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return tempPath;
}

- (NSString *)randomString {
    NSMutableString *str = [NSMutableString stringWithFormat:@""];
    for (int i = 0; i < 4; i++) {
        int randomChar = arc4random() % (26 + 10);
        if (randomChar < 10) {
            [str appendFormat:@"%c", randomChar + 48];
        } else {
            [str appendFormat:@"%c", randomChar - 10 + 65];
        }
    }
    return str;
}

- (NSString *)md5StrFromString:(NSString *)inStr {
    NSData *data = [inStr dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char md[CC_MD5_DIGEST_LENGTH] = { 0 };
    CC_MD5(data.bytes, (CC_LONG)data.length, md);
    NSMutableString *outStr = [NSMutableString stringWithFormat:@""];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [outStr appendFormat:@"%02x", md[i]];
    }
    return outStr;
}

@end

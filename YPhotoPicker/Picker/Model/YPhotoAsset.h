//
//  YPhotoAsset.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoAsset : NSObject

@property (assign, nonatomic) BOOL isSelected;

@property (strong, nonatomic) PHAsset *asset;

@end

NS_ASSUME_NONNULL_END

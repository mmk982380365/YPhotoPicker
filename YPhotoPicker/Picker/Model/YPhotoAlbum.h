//
//  YPhotoAlbum.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPhotoAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoAlbum : NSObject

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSArray<YPhotoAsset *> *assets;

@end

NS_ASSUME_NONNULL_END

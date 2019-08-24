//
//  YPhotoAssetDetailViewController.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoBaseController.h"
#import "YPhotoAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoAssetDetailViewController : YPhotoBaseController

@property (strong, nonatomic) YPhotoAlbum *album;

@property (assign, nonatomic) NSInteger selectedIndex;

@end

NS_ASSUME_NONNULL_END

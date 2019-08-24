//
//  YPhotoAlbumCell.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPhotoAlbum.h"
#import "YPhotoPickerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoAlbumCell : UITableViewCell

@property (strong, nonatomic) YPhotoAlbum *album;

@property (strong, nonatomic) YPhotoPickerManager *manager;

@end

NS_ASSUME_NONNULL_END

//
//  YPhotoBaseController.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPhotoPickerController.h"
#import "YPhotoPickerController+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoBaseController : UIViewController

@property (nullable, nonatomic,readonly,strong) YPhotoPickerController *navigationController;

- (void)showHint:(NSString *)hint;

@end

NS_ASSUME_NONNULL_END

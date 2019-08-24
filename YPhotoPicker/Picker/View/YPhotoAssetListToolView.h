//
//  YPhotoAssetListToolView.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YPhotoAssetListToolViewStyle) {
    YPhotoAssetListToolViewStyleWhite,
    YPhotoAssetListToolViewStyleBlack,
};

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoAssetListToolView : UIView

- (instancetype)initWithStyle:(YPhotoAssetListToolViewStyle)style;

@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) UIButton *confirmBtn;

@property (strong, nonatomic) UIButton *playBtn;

@property (strong, nonatomic) UILabel *timeLabel;

- (void)prepareForPlay;

@end

NS_ASSUME_NONNULL_END

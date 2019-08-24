//
//  YProgressHUD.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/19.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YProgressHUDMode) {
    YProgressHUDModeIndicator,
    YProgressHUDModeProgress,
    YProgressHUDModeText,
};

@interface YProgressHUD : UIView

@property (assign, nonatomic) CGFloat contentMargin;

@property (assign, nonatomic) YProgressHUDMode mode;

@property (assign, nonatomic) float progress;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

- (void)showWithAnimated:(BOOL)animated;

- (void)hideWithAnimated:(BOOL)animated;

- (void)setLabelText:(NSString *)labelText;

- (void)setLabelDetailText:(NSString *)labelDetailText;

@end

NS_ASSUME_NONNULL_END

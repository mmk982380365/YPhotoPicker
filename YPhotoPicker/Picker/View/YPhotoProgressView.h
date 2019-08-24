//
//  YPhotoProgressView.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/19.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPhotoProgressView : UIView

@property (assign, nonatomic) CGFloat progress;

@property (assign, nonatomic) NSTimeInterval duration;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END

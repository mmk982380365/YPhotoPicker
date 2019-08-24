//
//  SceneDelegate.h
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/22.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __IPHONE_13_0

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0))
@interface SceneDelegate : UIWindowScene <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;

@end

NS_ASSUME_NONNULL_END

#endif

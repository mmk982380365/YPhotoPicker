//
//  YPhotoAssetListToolView.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAssetListToolView.h"
#import "YPhotoPickerController+Private.h"

@interface YPhotoAssetListToolView ()

@property (assign, nonatomic) YPhotoAssetListToolViewStyle style;

@end

@implementation YPhotoAssetListToolView

- (instancetype)initWithStyle:(YPhotoAssetListToolViewStyle)style
{
    self = [super init];
    if (self) {
        self.style = style;
        switch (style) {
            case YPhotoAssetListToolViewStyleWhite:
            {
                [self.confirmBtn setTitleColor:UIColorFromRGB(0x00DF00) forState:UIControlStateNormal];
                [self.confirmBtn setTitleColor:UIColorFromRGB(0x005F00) forState:UIControlStateDisabled];
                [self.confirmBtn setTitleColor:[UIColorFromRGB(0x00DF00) colorWithAlphaComponent:0.8] forState:UIControlStateSelected];
#ifdef __IPHONE_13_0
                if (@available(iOS 13.0, *)) {
                    self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                        switch (traitCollection.userInterfaceStyle) {
                        case UIUserInterfaceStyleDark:
                            return UIColorFromRGB(0x121212);
                            break;
                            
                        default:
                            return UIColorFromRGB(0xFFFFFF);
                            break;
                        }
                    }];
                    self.lineView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                        switch (traitCollection.userInterfaceStyle) {
                        case UIUserInterfaceStyleDark:
                            return UIColorFromRGB(0x000000);
                            break;
                            
                        default:
                            return UIColorFromRGB(0xFFFFFF);
                            break;
                        }
                    }];
                } else {
                    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
                    self.lineView.backgroundColor = UIColorFromRGB(0xEEEEEE);
                }
#else
                self.backgroundColor = UIColorFromRGB(0xFFFFFF);
                self.lineView.backgroundColor = UIColorFromRGB(0xEEEEEE);
#endif
            }
                break;
            case YPhotoAssetListToolViewStyleBlack:
            {
                self.lineView.backgroundColor = [UIColor clearColor];
                [self.confirmBtn setTitleColor:UIColorFromRGB(0x00DF00) forState:UIControlStateNormal];
                [self.confirmBtn setTitleColor:UIColorFromRGB(0x005F00) forState:UIControlStateDisabled];
                [self.confirmBtn setTitleColor:[UIColorFromRGB(0x00DF00) colorWithAlphaComponent:0.8] forState:UIControlStateSelected];
                self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
            }
                break;
            default:
                break;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineView = [[UIView alloc] init];
        [self addSubview:self.lineView];
        self.lineView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self.confirmBtn setTitleColor:UIColorFromRGB(0x00DF00) forState:UIControlStateNormal];
        [self.confirmBtn setTitleColor:UIColorFromRGB(0x00AF00) forState:UIControlStateDisabled];
//        [self.confirmBtn setTitleColor:[UIColorFromRGB(0x00DF00) colorWithAlphaComponent:0.8] forState:UIControlStateSelected];
        self.confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        self.confirmBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        [self addSubview:self.confirmBtn];
        self.confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (@available(iOS 11.0, *)) {
            [NSLayoutConstraint activateConstraints:@[
                                                      [self.confirmBtn.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor],
                                                      ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                                                      [self.confirmBtn.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
                                                      ]];
        }
        
        [NSLayoutConstraint activateConstraints:@[
                                                  [self.lineView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
                                                  [self.lineView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
                                                  [self.lineView.topAnchor constraintEqualToAnchor:self.topAnchor],
                                                  [self.lineView.heightAnchor constraintEqualToConstant:1.0],
                                                  [self.confirmBtn.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-5],
                                                  [self.confirmBtn.topAnchor constraintEqualToAnchor:self.topAnchor],
                                                  [self.confirmBtn.heightAnchor constraintEqualToConstant:44],
                                                  ]];
        
    }
    return self;
}

- (void)prepareForPlay {
    if (!self.playBtn) {
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playBtn setImage:[YPhotoPickerManager imageNamedFromBundle:@"picker_play"] forState:UIControlStateNormal];
        [self.playBtn setImage:[YPhotoPickerManager imageNamedFromBundle:@"picker_play"] forState:UIControlStateNormal | UIControlStateHighlighted];
        [self.playBtn setImage:[YPhotoPickerManager imageNamedFromBundle:@"picker_pause"] forState:UIControlStateSelected];
        [self.playBtn setImage:[YPhotoPickerManager imageNamedFromBundle:@"picker_pause"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.playBtn setImage:[YPhotoPickerManager imageNamedFromBundle:@"picker_unselect"] forState:UIControlStateDisabled];
        self.playBtn.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [self addSubview:self.playBtn];
        self.playBtn.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_playBtn(44)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_playBtn)]];
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playBtn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                               ]];
    }
    
    if (!self.timeLabel) {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.timeLabel];
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_timeLabel]" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_timeLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_timeLabel(44)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_timeLabel)]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  YPhotoTopView.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoTopView.h"
#import "YPhotoPickerManager.h"

@interface YPhotoTopView ()

@end

@implementation YPhotoTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        
        self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftBtn setImage:[UIImage imageNamed:@"picker_back"] forState:UIControlStateNormal];
        [self.leftBtn setTitle:@"返回" forState:UIControlStateNormal];
//        [self.leftBtn addTarget:self action:@selector(leftBtnAct:) forControlEvents:UIControlEventTouchUpInside];
        self.leftBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        self.leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        [self addSubview:self.leftBtn];
        
        
        
        self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectBtn setImage:[UIImage imageNamed:@"picker_unselect"] forState:UIControlStateNormal];
        [self.selectBtn setImage:[UIImage imageNamed:@"picker_unselect"] forState:UIControlStateNormal | UIControlStateHighlighted];
        [self.selectBtn setImage:[UIImage imageNamed:@"picker_select"] forState:UIControlStateSelected];
        [self.selectBtn setImage:[UIImage imageNamed:@"picker_select"] forState:UIControlStateSelected | UIControlStateHighlighted];
//        [self.selectBtn addTarget:self action:@selector(selectBtnAct:) forControlEvents:UIControlEventTouchUpInside];
        self.selectBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [self addSubview:self.selectBtn];
        
        self.selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftBtn.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[_leftBtn]" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_leftBtn)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftBtn(==navHeight)]-0-|" options:NSLayoutFormatAlignAllLeft metrics:@{@"navHeight": @(44)} views:NSDictionaryOfVariableBindings(_leftBtn)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_selectBtn(==navHeight)]-12-|" options:NSLayoutFormatAlignAllTop metrics:@{@"navHeight": @(44)} views:NSDictionaryOfVariableBindings(_selectBtn)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_selectBtn(==navHeight)]-0-|" options:NSLayoutFormatAlignAllLeft metrics:@{@"navHeight": @(44)} views:NSDictionaryOfVariableBindings(_selectBtn)]];
        
    }
    return self;
}

- (void)leftBtnAct:(UIButton *)btn {
    
    
}

- (void)selectBtnAct:(UIButton *)btn {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

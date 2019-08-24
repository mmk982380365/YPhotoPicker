//
//  YPhotoAssetListCell.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAssetListCell.h"
#import "YPhotoPickerManager.h"

@interface YPhotoAssetListCell ()

@property (assign, nonatomic) PHImageRequestID lastID;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIButton *selectBtn;

@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation YPhotoAssetListCell

- (void)dealloc {
    self.imageView.image = nil;
    if (_asset) {
        [_asset removeObserver:self forKeyPath:@"isSelected"];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectBtn setImage:[UIImage imageNamed:@"picker_unselect"] forState:UIControlStateNormal];
        [self.selectBtn setImage:[UIImage imageNamed:@"picker_unselect"] forState:UIControlStateNormal | UIControlStateHighlighted];
        [self.selectBtn setImage:[UIImage imageNamed:@"picker_select"] forState:UIControlStateSelected];
        [self.selectBtn setImage:[UIImage imageNamed:@"picker_select"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.selectBtn addTarget:self action:@selector(selectAct:) forControlEvents:UIControlEventTouchUpInside];
        self.selectBtn.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
        [self.contentView addSubview:self.selectBtn];
        self.selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.timeLabel];
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_selectBtn(44)]-0-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_selectBtn)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_selectBtn(44)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_selectBtn)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_imageView]-0-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_imageView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_imageView]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_imageView)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_timeLabel]-(>=5)-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_timeLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeLabel]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_timeLabel)]];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isSelected"]) {
        self.selectBtn.selected = self.asset.isSelected;
    }
}

- (void)setAsset:(YPhotoAsset *)asset {
    if (_asset != asset) {
        if (_asset) {
            [_asset removeObserver:self forKeyPath:@"isSelected"];
        }
        self.selectBtn.hidden = !self.manager.allowMultipleSelection;
        _asset = asset;
        [_asset addObserver:self forKeyPath:@"isSelected" options:NSKeyValueObservingOptionInitial context:nil];
        self.selectBtn.selected = asset.isSelected;
        [YPhotoPickerManager cancelLoadImage:self.lastID];
        [self.contentView layoutIfNeeded];
        CGFloat width = self.frame.size.width * 1.5;
        self.lastID = [self.manager getImageWithAsset:asset targetSize:CGSizeMake(width, width) callback:^(UIImage * _Nullable image) {
            self.imageView.image = image;
        }];
        if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
            self.timeLabel.hidden = NO;
            self.timeLabel.text = [NSString stringWithFormat:@"%@", [YPhotoPickerManager convertTime:asset.asset.duration]];
        } else {
            self.timeLabel.hidden = YES;
        }
    }
}

- (void)selectAct:(UIButton *)btn {
    if (self.delegate) {
        [self.delegate cellDidSelectAsset:self.asset];
    }
    [self.selectBtn.layer addAnimation:[YPhotoPickerManager zoomingAnimation] forKey:@"1"];
}

@end

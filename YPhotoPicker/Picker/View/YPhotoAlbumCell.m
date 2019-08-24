//
//  YPhotoAlbumCell.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAlbumCell.h"
#import "YPhotoPickerManager.h"
#import "YPhotoPickerController+Private.h"

@interface YPhotoAlbumCell ()

@property (assign, nonatomic) PHImageRequestID lastID;

@property (strong, nonatomic) UIImageView *tempImageView;

@property (strong, nonatomic) UILabel *nameLabel;

@property (strong, nonatomic) UIView *lineView;

@end

@implementation YPhotoAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.tempImageView = [[UIImageView alloc] init];
        self.tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.tempImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.tempImageView];
        self.tempImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.nameLabel];
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        self.lineView = [[UIView alloc] init];
        
#ifdef __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            self.lineView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                switch (traitCollection.userInterfaceStyle) {
                case UIUserInterfaceStyleDark:
                    return UIColorFromRGB(0x121212);
                    break;
                    
                default:
                    return UIColorFromRGB(0xEEEEEE);
                    break;
                }
            }];
        } else {
            self.lineView.backgroundColor = UIColorFromRGB(0xEEEEEE);
        }
#else
        self.lineView.backgroundColor = UIColorFromRGB(0xEEEEEE);
#endif
        
        [self.contentView addSubview:self.lineView];
        self.lineView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraints:@[
                                           [NSLayoutConstraint constraintWithItem:self.tempImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.tempImageView attribute:NSLayoutAttributeHeight multiplier:16.0/9.0 constant:0.0],
                                           [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
                                           ]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[_tempImageView]-12-[_nameLabel]-(>=12)-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_tempImageView, _nameLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[_lineView]-0-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_lineView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_tempImageView(48)]-10-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_tempImageView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lineView(1)]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_lineView)]];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAlbum:(YPhotoAlbum *)album {
    if (_album != album) {
        _album = album;
        self.nameLabel.text = [NSString stringWithFormat:@"%@ (%ld)", album.title, album.assets.count];
        [YPhotoPickerManager cancelLoadImage:self.lastID];
        CGFloat height = 48 * 3;
        CGFloat width = height * 16.0 / 9.0;
        CGSize size = CGSizeMake(width, height);
        self.lastID = [self.manager getImageWithAsset:album.assets.lastObject targetSize:size callback:^(UIImage * _Nullable image) {
            self.tempImageView.image = image;
        }];
    }
}

@end

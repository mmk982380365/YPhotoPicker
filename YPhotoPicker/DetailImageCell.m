//
//  DetailImageCell.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/24.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "DetailImageCell.h"

@interface DetailImageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;

@end

@implementation DetailImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (CGSize)sizeThatFits:(CGSize)size {
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat height = width * (9.0 / 16.0);
//    return CGSizeMake(width, height);
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDetailImage:(UIImage *)image {
    self.detailImageView.image = image;
}

@end

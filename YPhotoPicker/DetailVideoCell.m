//
//  DetailVideoCell.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/24.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "DetailVideoCell.h"
#import <AVKit/AVKit.h>

@interface DetailVideoCell ()

@property (strong, nonatomic) AVPlayerViewController *playerController;

@property (strong, nonatomic) AVPlayer *player;

@end

@implementation DetailVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.player = [[AVPlayer alloc] initWithPlayerItem:nil];
    self.playerController = [[AVPlayerViewController alloc] init];
    self.playerController.player = self.player;
    [self addSubview:self.playerController.view];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 10;
    CGFloat height = width * (9.0 / 16.0);
    self.playerController.view.frame = CGRectMake(5, 5, width, height);
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = width * (9.0 / 16.0);
    return CGSizeMake(width, height);
}

- (void)setVideoPath:(NSURL *)videoPath {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoPath];
    [self.playerController.player replaceCurrentItemWithPlayerItem:item];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

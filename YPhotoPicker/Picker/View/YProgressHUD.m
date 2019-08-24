//
//  YProgressHUD.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/19.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YProgressHUD.h"

@interface YProgressHUDProgressLayer : CALayer

@property (assign, nonatomic) float progress;

@property (assign, nonatomic) BOOL animated;

@end

@implementation YProgressHUDProgressLayer
@dynamic progress;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.backgroundColor = [UIColor clearColor].CGColor;
        
        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    CGRect rect = self.bounds;
    CGFloat color[4] = { 1,1,1,1 };
    CGContextSetStrokeColor(ctx, color);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextAddArc(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetMidX(rect) - 2, 0, M_PI * 2 * self.progress, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([@"progress" isEqualToString:key]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event {
    if ([event isEqualToString:@"progress"]) {
        if (!self.animated) {
            return nil;
        }
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 0.2;
        animation.fromValue = @([[self presentationLayer] progress]);
        return animation;
    }
    return [super actionForKey:event];
}

@end

@interface YProgressHUD ()

@property (strong, nonatomic) YProgressHUDProgressLayer *progressLayer;

@property (strong, nonatomic, readwrite) UIView *backgroundView;

@property (strong, nonatomic, readwrite) UIView *contentView;

@property (strong, nonatomic, readwrite) UILabel *label;

@property (strong, nonatomic, readwrite) UILabel *labelDetal;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation YProgressHUD

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentMargin = 16;
        self.alpha = 0;
        self.backgroundView = [[UIView alloc] init];
//        self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self addSubview:self.backgroundView];
        
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        self.contentView.layer.cornerRadius = 8;
        [self addSubview:self.contentView];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.indicatorView startAnimating];
        [self.contentView addSubview:self.indicatorView];
        
        self.progressLayer = [YProgressHUDProgressLayer layer];
        [self.contentView.layer addSublayer:self.progressLayer];
        
        self.label = [[UILabel alloc] init];
        self.label.font = [UIFont systemFontOfSize:14];
        self.label.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.label];
        
        self.labelDetal = [[UILabel alloc] init];
        self.labelDetal.font = [UIFont systemFontOfSize:12];
        self.labelDetal.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.labelDetal];
        
        [self layoutIfNeeded];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundView.frame = self.bounds;
    
    
    
    CGFloat bodyMargin = 30;
    
    CGSize labelSize = [self.label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - (self.contentMargin + bodyMargin) * 2, CGFLOAT_MAX)];
    CGSize labelDetailSize = [self.labelDetal sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - (self.contentMargin + bodyMargin) * 2, CGFLOAT_MAX)];
    
    CGFloat maxWidth = MAX(MAX(self.indicatorView.frame.size.width, labelSize.width), labelDetailSize.width);
    
    CGFloat contentHeight = self.contentMargin * 2;
    if (self.mode == YProgressHUDModeIndicator) {
        contentHeight += self.indicatorView.frame.size.height;
        [self.indicatorView sizeToFit];
    } else if (self.mode == YProgressHUDModeProgress) {
        contentHeight += 37;
        //prog
        [self.progressLayer setNeedsDisplay];
    }
    
    if (!CGSizeEqualToSize(labelSize, CGSizeZero)) {
        contentHeight += labelSize.height;
        if (self.mode == YProgressHUDModeIndicator || self.mode == YProgressHUDModeProgress) {
            contentHeight += 10;
        }
    }
    
    if (!CGSizeEqualToSize(labelDetailSize, CGSizeZero)) {
        contentHeight += labelDetailSize.height;
        if (self.mode == YProgressHUDModeIndicator || self.mode == YProgressHUDModeProgress) {
            contentHeight += 10;
        }
    }
    
    CGFloat contentWidth = maxWidth + 2 * self.contentMargin;
    
    
    CGFloat offset = self.contentMargin;
    
    self.contentView.frame = CGRectMake((self.frame.size.width - contentWidth) / 2.0, (self.frame.size.height - contentHeight) / 2.0, contentWidth, contentHeight);
    
    if (self.mode == YProgressHUDModeIndicator) {
        self.indicatorView.center = CGPointMake(self.contentView.frame.size.width / 2.0, offset + self.indicatorView.frame.size.height / 2.0);
        offset = CGRectGetMaxY(self.indicatorView.frame) + 10;
    }
    
    if (self.mode == YProgressHUDModeProgress) {
        self.progressLayer.frame = CGRectMake((self.contentView.frame.size.width - 37) / 2.0, offset, 37, 37);
        offset = CGRectGetMaxY(self.progressLayer.frame) + 10;
    }
    
    if (CGSizeEqualToSize(labelSize, CGSizeZero)) {
        self.label.frame = CGRectZero;
    } else {
        self.label.frame = CGRectMake((self.contentView.frame.size.width - labelSize.width) / 2.0, offset, labelSize.width, labelSize.height);
        offset = CGRectGetMaxY(self.label.frame) + 10;
    }
    
    if (CGSizeEqualToSize(labelDetailSize, CGSizeZero)) {
        self.labelDetal.frame = CGRectZero;
    } else {
        self.labelDetal.frame = CGRectMake((self.contentView.frame.size.width - labelDetailSize.width) / 2.0, offset, labelDetailSize.width, labelDetailSize.height);
       
    }
    
}

- (void)showWithAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1;
        }];
    } else {
        self.alpha = 1;
    }
}

- (void)hideWithAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        }];
    } else {
        self.alpha = 0;
    }
}

- (void)setLabelText:(NSString *)labelText {
    self.label.text = labelText;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setLabelDetailText:(NSString *)labelDetailText {
    self.labelDetal.text = labelDetailText;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setMode:(YProgressHUDMode)mode {
    if (_mode != mode) {
        _mode = mode;
        if (mode == YProgressHUDModeIndicator) {
            self.indicatorView.hidden = NO;
            [self.indicatorView startAnimating];
            self.progressLayer.hidden = YES;
        } else if (mode == YProgressHUDModeProgress) {
            self.indicatorView.hidden = YES;
            self.progressLayer.hidden = NO;
            [self.indicatorView stopAnimating];
        } else {
            self.indicatorView.hidden = YES;
            self.progressLayer.hidden = YES;
            [self.indicatorView stopAnimating];
        }
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:progress > 0 ? YES : NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    self.progressLayer.animated = animated;
    _progress = progress;
    [self.progressLayer setValue:@(progress) forKey:@"progress"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

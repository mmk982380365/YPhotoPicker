//
//  YPhotoProgressView.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/19.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoProgressView.h"

@interface YPhotoProgressLayer : CALayer

@property (assign, nonatomic) BOOL animated;

@property (assign, nonatomic) float progress;

@property (assign, nonatomic) NSTimeInterval durations;

@end

@implementation YPhotoProgressLayer
@dynamic progress;

- (instancetype)initWithLayer:(YPhotoProgressLayer *)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    
    CGRect rect = self.bounds;
    
    CGFloat color[4] = { 1, 1, 1, 1 };
    CGContextSetStrokeColor(ctx, color);
    CGContextSetLineWidth(ctx, CGRectGetHeight(rect));
    
    CGContextMoveToPoint(ctx, 0, CGRectGetMidY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) * self.progress, CGRectGetMidY(rect));
    
    CGContextDrawPath(ctx, kCGPathStroke);
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([@"progress" isEqualToString:key]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event {
    if ([@"progress" isEqualToString:event]) {
        if (!self.animated) {
            return nil;
        }
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = @([[self presentationLayer] progress]);
        animation.duration = self.durations;
        return animation;
    }
    return [super actionForKey:event];
}

@end

@interface YPhotoProgressView ()

@property (strong, nonatomic) YPhotoProgressLayer *progressLayer;

@end

@implementation YPhotoProgressView

+ (Class)layerClass {
    return YPhotoProgressLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
//        self.progressLayer = [YPhotoProgressLayer layer];
        
//        [self.layer addSublayer:self.progressLayer];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.progressLayer.frame = self.bounds;
    
    [self updateProgress];
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    _progress = progress;
    [self.layer setValue:@(animated) forKey:@"animated"];
    [self updateProgress];
}

- (void)updateProgress {
    [self.layer setValue:@(self.progress) forKey:@"progress"];
}

- (void)setDuration:(NSTimeInterval)duration {
    [self.layer setValue:@(duration) forKey:@"durations"];
}

@end

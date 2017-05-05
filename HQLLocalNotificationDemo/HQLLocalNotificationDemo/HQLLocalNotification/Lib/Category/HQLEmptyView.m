//
//  HQLEmptyView.m
//  HQLGoodsListViewDemo
//
//  Created by weplus on 2017/3/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLEmptyView.h"
#import <WebKit/WebKit.h>
#import "UIImageView+GifAnimation.h"
#import "HQLTimer.h"

#define kMargin 10
#define kAnimationLabelTitle @"正在加载"
#define kGifPerImageTime 0.1 // 每一帧的时间

static NSInteger timerCount = 0;

typedef enum {
    HQLEmptyViewDefault , // 默认状态 ---> 显示 imageView 和 titleLabel
    HQLEmptyViewLoadingAndShowGif , // 加载动画 ---> 显示gifImageView 和 animationLabel
    HQLEmptyViewLoadingAndShowIndicator , // 加载动画(如果没有设置gif,则默认显示这个状态) ---> 显示指示View(菊花) 和 animationLabel
} HQLEmptyViewStatus; // 记录当前显示的状态

@interface HQLEmptyView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIImageView *gifImageView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) UILabel *animationLabel;

@property (assign, nonatomic) BOOL isAnimating;

@property (strong, nonatomic) HQLTimer *animationLabelTimer;

@end

@implementation HQLEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI {
    [self titleLabel];
    [self imageView];
    
    // 添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self calculateFrame];
}

#pragma mark - event

- (void)tap {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

// 计算frame
- (void)calculateFrame {
    
    // 根据当前显示的状态 对需要显示的View 设置frame
    switch ([self getCurrentStatus]) {
        case HQLEmptyViewDefault: {
            
            UILabel *titleLabel = nil;
            if (self.title) {
                titleLabel = self.titleLabel;
            }
            
            UIImageView *imageView = nil;
            if (self.image) {
                // 根据Image的比例来设置imageView的宽高
                CGFloat imageViewW = [self defalutWidth];
                CGFloat imageViewH = (imageViewW * self.image.size.height) / self.image.size.width;
                self.imageView.frame = CGRectMake(0, 0, imageViewW, imageViewH);
                imageView = self.imageView;
            }
            
            [self calculateFrameWithView:imageView label:titleLabel];
            break;
        }
        case HQLEmptyViewLoadingAndShowGif: {
            // 到这个里的时候 ---> GIFImageView的size已经设置好了
            [self calculateFrameWithView:self.gifImageView label:self.animationLabel];
            break;
        }
        case HQLEmptyViewLoadingAndShowIndicator: {
            [self calculateFrameWithView:self.indicatorView label:self.animationLabel];
            break;
        };
    }
}

// 计算frame值 ---> 因为都大同小异 所以就抽取出来
- (void)calculateFrameWithView:(UIView *)view label:(UILabel *)label {
    [label setFrame:CGRectMake(0, 0, [self labelDefalutWidth], 1000)];
    [label sizeToFit];
    
    CGFloat totalHeight = CGRectGetHeight(view.frame) + kMargin + CGRectGetHeight(label.frame);
    
    CGFloat imageViewY = (self.frame.size.height - totalHeight) * 0.5;
    CGFloat imageViewX = (self.frame.size.width - view.frame.size.width) * 0.5;
    CGFloat titleLabelY = imageViewY + kMargin + CGRectGetHeight(view.frame);
    CGFloat titleLabelX = (self.frame.size.width - label.frame.size.width) * 0.5;
    
    [view setFrame:CGRectMake(imageViewX, imageViewY, view.frame.size.width, view.frame.size.height)];
    
    [label setFrame:CGRectMake(titleLabelX, titleLabelY, label.frame.size.width, label.frame.size.height)];
}

- (CGFloat)labelDefalutWidth {
    return self.frame.size.width - 2 * kMargin;
}

- (CGFloat)defalutWidth {
    return  self.frame.size.width * 0.6;
}

- (HQLEmptyViewStatus)getCurrentStatus {
    // 判断当前的状态
    if (!self.isAnimating) {
        // 没有在动画中
        return HQLEmptyViewDefault;
    } else {
        // 有在动画中
        if (self.gifData || self.gifImageArray) {
            return HQLEmptyViewLoadingAndShowGif; // 有设置gif则显示gif
        } else {
            return HQLEmptyViewLoadingAndShowIndicator; // 没有设置gif,则显示菊花
        }
    }
}

#pragma mark - loading animation

- (void)startAnimaion {
    if (self.isAnimating) {
        return; // 如果正在动画中 则不能继续动画
    }
    self.isAnimating = YES;
    
    __weak typeof(self) weakSelf = self;
    switch ([self getCurrentStatus]) {
        case HQLEmptyViewDefault: { break; }
        case HQLEmptyViewLoadingAndShowGif: {
            // 显示gif
            if (self.image) {
                [self.imageView setAlpha:0];
            }
            if (self.title) {
                [self.titleLabel setAlpha:0];
            }
            
            if (self.gifData) {
                [self.gifImageView setGifData:self.gifData completeBlock:^(CGFloat width, CGFloat height) {
                    // 根据比例 设置GIFImageView的size
                    [weakSelf.gifImageView setFrame:CGRectMake(0, 0, [weakSelf defalutWidth], ([weakSelf defalutWidth] * height) / width)];
                    
                    // 计算frame
                    [weakSelf calculateFrame];
                    
                    [weakSelf.gifImageView setAlpha:1];
                    [weakSelf.animationLabel setAlpha:1];
                    // 开启animationLabel
                    [weakSelf startAnimationLabel];
                    [weakSelf.gifImageView startAnimating];
                }];
            } else if (self.gifImageArray) {
                UIImage *image = self.gifImageArray.firstObject;
                CGFloat imageWidth = [self defalutWidth];
                CGFloat imageHeight = (imageWidth * image.size.height) / image.size.width;
                [self.gifImageView setFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
                [self calculateFrame];
                
                [self.gifImageView setAlpha:1];
                [self.animationLabel setAlpha:1];
                // 开启animationLabel
                [self startAnimationLabel];
                [self.gifImageView startAnimating];
            }
            
            break;
        }
        case HQLEmptyViewLoadingAndShowIndicator: {
            
            [self calculateFrame];
            
            if (self.image) {
                if (self.title) {
                    [self.titleLabel setAlpha:0];
                }
                
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.imageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                } completion:^(BOOL finished) {
                    [weakSelf.animationLabel setAlpha:1];
                    [weakSelf.indicatorView setAlpha:1];
                    
                    [weakSelf.indicatorView startAnimating];
                    [weakSelf startAnimationLabel];
                    
                    [weakSelf.imageView setAlpha:0];
                }];
            } else if (self.title) {
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.titleLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
                } completion:^(BOOL finished) {
                    [weakSelf.animationLabel setAlpha:1];
                    [weakSelf.indicatorView setAlpha:1];
                    
                    [weakSelf.indicatorView startAnimating];
                    [weakSelf startAnimationLabel];
                    
                    [weakSelf.titleLabel setAlpha:0];
                }];
            } else {
                [self.animationLabel setAlpha:1];
                [self.indicatorView setAlpha:1];
                
                [self.indicatorView startAnimating];
                [self startAnimationLabel];
            }
            
            break;
        }
    }
}

- (void)stopAnimation {
    self.isAnimating = NO; // 调用这个方法 则表明需要结束动画
    
    // 停止动画
    if (self.gifData || self.gifImageArray) {
        [self.gifImageView stopAnimating];
        self.gifImageView.animationImages = nil;
        [self.gifImageView setAlpha:0];
    } else {
        [self.indicatorView stopAnimating];
        [self.indicatorView setAlpha:0];
    }
    [self stopAnimationLabel];
    [self.animationLabel setAlpha:0];
    
    if (self.image) {
        [self.imageView setAlpha:1];
        [self.imageView setTransform:CGAffineTransformMakeScale(1, 1)];
    }
    if (self.title) {
        [self.titleLabel setAlpha:1];
        [self.titleLabel setTransform:CGAffineTransformMakeScale(1, 1)];
    }
    
    [self calculateFrame];
}

#pragma mark - animation label

// 开启 animationLabel 的动画
- (void)startAnimationLabel {
    self.animationLabelTimer = [HQLTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(labelAnimation) userInfo:nil repeats:YES];
    [self.animationLabelTimer reStart];
}

// animationLabel 执行的动画
- (void)labelAnimation {
    timerCount++;
    if (timerCount % 4 == 0) {
        if (self.animationTitle) {
            self.animationLabel.text = self.animationTitle;
        } else {
            self.animationLabel.text = kAnimationLabelTitle;
        }
    } else {
        self.animationLabel.text = [self.animationLabel.text stringByAppendingString:@"."];
    }
    
    if (self.gifData) {
        [self calculateFrameWithView:self.gifImageView label:self.animationLabel];
    } else {
        [self calculateFrameWithView:self.indicatorView label:self.animationLabel];
    }
}

// animationLabel停止动画
- (void)stopAnimationLabel {
    [self.animationLabelTimer stop];
    [self.animationLabelTimer invalidate];
    self.animationLabelTimer = nil;
    
    timerCount = 0;
    if (self.animationTitle) {
        self.animationLabel.text = self.animationTitle;
    } else {
        self.animationLabel.text = kAnimationLabelTitle;
    }
}

#pragma mark - setter 

- (void)setImage:(UIImage *)image {
    if (!image) {
        return;
    }
    _image = image;
    self.imageView.image = image;
}

- (void)setTitle:(NSString *)title {
    if (!title) {
        return;
    }
    _title = title;
    self.titleLabel.text = title;
}

- (void)setAnimationTitle:(NSString *)animationTitle {
    if (!animationTitle) {
        return;
    }
    _animationTitle = animationTitle;
    self.animationLabel.text = animationTitle;
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (!titleColor) {
        return;
    }
    _titleColor = titleColor;
    [self.titleLabel setTextColor:titleColor];
    [self.animationLabel setTextColor:titleColor];
}

#pragma mark - getter

// 显示title
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextColor:[UIColor grayColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_titleLabel setUserInteractionEnabled:YES];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

// 显示Image
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setUserInteractionEnabled:YES];
        [self addSubview:_imageView];
    }
    return _imageView;
}

// 需要显示gif的View
- (UIImageView *)gifImageView {
    if (!_gifImageView) {
        _gifImageView = [[UIImageView alloc] init];
        [_gifImageView setAlpha:0];
        [self addSubview:_gifImageView];
    }
    return _gifImageView;
}

// 网络指示器
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.color = [UIColor lightGrayColor];
        [_indicatorView setAlpha:0];
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UILabel *)animationLabel {
    if (!_animationLabel) {
        _animationLabel = [[UILabel alloc] init];
        [_animationLabel setTextColor:[UIColor grayColor]];
        [_animationLabel setFont:[UIFont systemFontOfSize:14]];
        [_animationLabel setUserInteractionEnabled:YES];
        [_animationLabel setNumberOfLines:0];
        [_animationLabel setTextAlignment:NSTextAlignmentCenter];
        [_animationLabel setText:kAnimationLabelTitle];
        [_animationLabel setAlpha:0];
        
        [self addSubview:_animationLabel];
    }
    return _animationLabel;
}

@end

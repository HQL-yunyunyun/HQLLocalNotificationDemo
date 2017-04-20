//
//  HQLSelectButton.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLSelectButton.h"
#import "HQLLayerDrawGeometricShape.h"

#define kEllipseShapeHeightRatio 0.4

@interface HQLSelectButton ()

@property (strong, nonatomic) CALayer *shapeLayer;
@property (assign, nonatomic) CGSize xibSize;

@end

@implementation HQLSelectButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.xibSize = self.frame.size;
}

#pragma mark - over write

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (!self.defaultShapeColor) {
        self.defaultShapeColor = [UIColor orangeColor];
    }
    if (!self.selectedShapeColor) {
        self.selectedShapeColor = [UIColor orangeColor];
    }
    
    if (selected) {
        // 选中
        [self configShapeLayerFrameWithShape:self.selectedMode];
        [HQLLayerDrawGeometricShape layerDrawGeometricShapeWithLayer:self.shapeLayer shape:self.selectedMode color:self.selectedShapeColor.CGColor];
    } else {
        [self configShapeLayerFrameWithShape:self.defaultMode];
        [HQLLayerDrawGeometricShape layerDrawGeometricShapeWithLayer:self.shapeLayer shape:self.defaultMode color:self.defaultShapeColor.CGColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.xibSize, CGSizeZero)) { // 判断是否为空
        if (!CGSizeEqualToSize(self.xibSize, self.frame.size)) {
            [self setSelected:self.isSelected];
            self.xibSize = self.frame.size;
        }
    }
}

- (void)setFrame:(CGRect)frame {
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    [super setFrame:frame];
    // 如果是从xib中创建的，不会走这个方法
    if (originWidth != self.frame.size.width || originHeight != self.frame.size.height) {
        [self setSelected:self.isSelected]; // 如果frame值有变 则重新描绘 layer
    }
}

- (void)configShapeLayerFrameWithShape:(HQLGeometricShape)shapeMode {
    if (shapeMode == HQLGeometricShapeNone) {
        return; // 如果为没有形状 则 维持之前的frame
    }
    if (shapeMode == HQLGeometricShapeEllipse) {
        CGFloat width = self.layer.frame.size.width;
        CGFloat height = width * 0.4; // 椭圆形 宽高比为 1 : 0.4
        if ((self.titleLabel.frame.size.height + 10) > height) {
            height = self.titleLabel.frame.size.height + 10;
        }
        CGFloat x = (self.layer.frame.size.width - width) * 0.5;
        CGFloat y = (self.layer.frame.size.height - height) * 0.5;
        self.shapeLayer.frame = CGRectMake(x, y, width, height);
    } else {
        self.shapeLayer.frame = self.bounds;
    }
}

#pragma mark - setter

- (void)setSelectedMode:(HQLGeometricShape)selectedMode {
    _selectedMode = selectedMode;
    if (selectedMode != HQLGeometricShapeNone && selectedMode != HQLGeometricShapeCircularRing) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
    [self configShapeLayerFrameWithShape:selectedMode];
}

- (void)setDefaultMode:(HQLGeometricShape)defaultMode {
    _defaultMode = defaultMode;
    [self configShapeLayerFrameWithShape:defaultMode];
}

#pragma mark - getter

- (CALayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [[CALayer alloc] init];
        [self.layer insertSublayer:_shapeLayer atIndex:0];
    }
    return _shapeLayer;
}

@end

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

@end

@implementation HQLSelectButton

#pragma mark - over write

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.shapeLayer.frame = self.layer.bounds;
    if (!self.defaultShapeColor) {
        self.defaultShapeColor = [UIColor orangeColor];
    }
    if (!self.selectedShapeColor) {
        self.selectedShapeColor = [UIColor orangeColor];
    }
    
    if (selected) {
        // 选中
        if (self.selectedMode == drawGeometricShapeEllipse) {
            CGFloat width = self.layer.frame.size.width;
            CGFloat height = width * 0.4; // 椭圆形 宽高比为 1 : 0.4 
            if ((self.titleLabel.frame.size.height + 10) > height) {
                height = self.titleLabel.frame.size.height + 10;
            }
            CGFloat x = (self.layer.frame.size.width - width) * 0.5;
            CGFloat y = (self.layer.frame.size.height - height) * 0.5;
            self.shapeLayer.frame = CGRectMake(x, y, width, height);
        }
        [HQLLayerDrawGeometricShape layerDrawGeometricShapeWithLayer:self.shapeLayer shape:self.selectedMode color:self.selectedShapeColor.CGColor];
    } else {
        [HQLLayerDrawGeometricShape layerDrawGeometricShapeWithLayer:self.shapeLayer shape:self.defaultMode color:self.defaultShapeColor.CGColor];
    }
}

- (void)setFrame:(CGRect)frame {
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    [super setFrame:frame];
    if (originWidth != self.frame.size.width || originHeight != self.frame.size.height) {
        [self setSelected:self.isSelected]; // 如果frame值有变 则重新描绘 layer
    }
}

#pragma mark - setter

- (void)setSelectedMode:(HQLDrawGeometricShape)selectedMode {
    _selectedMode = selectedMode;
    if (selectedMode != drawGeometricShapeNone && selectedMode != drawGeometricShapeCircularRing) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
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

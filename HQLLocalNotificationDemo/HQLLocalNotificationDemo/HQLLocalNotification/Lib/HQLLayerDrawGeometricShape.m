//
//  HQLLayerDrawGeometricShape.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLayerDrawGeometricShape.h"
#import "CALayer+HQLXIBLayer.h"
#import <UIKit/UIKit.h>

#define HQLLayerShapeTag 8820
#define kLayerPadding 3

@implementation HQLLayerDrawGeometricShape

+ (void)layerDrawGeometricShapeWithLayer:(CALayer *)layer shape:(HQLDrawGeometricShape)shape color:(CGColorRef)color {
    CALayer *deleteLayer = nil;
    for (CALayer *subLayer in layer.sublayers) {
        if (subLayer.HQLLayerTag == HQLLayerShapeTag) {
            deleteLayer = subLayer;
            break;
        }
    }
    if (deleteLayer) {
        [deleteLayer removeFromSuperlayer];
    }
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.HQLLayerTag = HQLLayerShapeTag;
    shapeLayer.frame = layer.bounds;
    shapeLayer.fillColor = color;
    shapeLayer.strokeColor = nil;
    UIBezierPath *path = nil;
    
    // length --- 可以理解为直径，如果需要显示正方形 或 圆形 ，边长和半径就以这个为标准
    CGFloat length = (layer.frame.size.width > layer.frame.size.height ? layer.frame.size.height : layer.frame.size.width) - kLayerPadding;
    
    CGFloat width = layer.frame.size.width - kLayerPadding; // 显示的形状都内缩 kLayerPadding 的距离
    CGFloat height = layer.frame.size.height - kLayerPadding;
    CGFloat x = (layer.frame.size.width - width) * 0.5;
    CGFloat y = (layer.frame.size.height - height) * 0.5;
    
    switch (shape) {
        case drawGeometricShapeCircular: {
            // 圆形
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width * 0.5 + x, height * 0.5 + y) radius:length * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            break;
        }
        case drawGeometricShapeRect: {
            // 矩形
            path = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, width, height)];
            break;
        }
        case drawGeometricShapeLeftHalfCircular:{
            // 左半圆 右半正方形
            x += length * 0.5;
            y += height * 0.5;
            CGFloat radius = length * 0.5;
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:radius startAngle:M_PI_2 endAngle:M_PI_2 + M_PI  clockwise:YES];
            [path addLineToPoint:CGPointMake(x + width, y - height * 0.5)];
            [path addLineToPoint:CGPointMake(x + width, y + height * 0.5)];
            [path closePath];
            break;
        }
        case drawGeometricShapeRightHalfCircular: {
            // 右半圆 左半正方形
            x += length * 0.5;
            y += height * 0.5;
            CGFloat radius = length * 0.5;
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:radius startAngle:M_PI_2 endAngle:M_PI_2 + M_PI  clockwise:NO];
            [path addLineToPoint:CGPointMake(x - length * 0.5, y - height * 0.5)];
            [path addLineToPoint:CGPointMake(x - length * 0.5, y + height * 0.5)];
            [path closePath];
            break;
        }
        case drawGeometricShapeCircularRing: {
            // 圆环
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width * 0.5 + x, height * 0.5 + y) radius:length * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            shapeLayer.fillColor = nil;
            shapeLayer.strokeColor = color;
            break;
        }
        case drawGeometricShapeEllipse: {
            // 椭圆形
            x += length * 0.5;
            y += height * 0.5;
            CGFloat radius = length * 0.5;
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:radius startAngle:M_PI_2 endAngle:M_PI_2 + M_PI  clockwise:YES];
            [path addLineToPoint:CGPointMake(x + width - length, y - height * 0.5)];
            [path addArcWithCenter:CGPointMake(x + width - length, y) radius:radius startAngle:M_PI_2 + M_PI endAngle:M_PI_2 clockwise:YES];
            [path closePath];
            break;
        }
        case drawGeometricShapeNone: {
            // 空白就什么都不做
            
            break;
        }
    }
    
    shapeLayer.path = path.CGPath;
    [layer insertSublayer:shapeLayer atIndex:0];
}

@end

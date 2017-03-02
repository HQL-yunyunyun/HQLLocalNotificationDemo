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
    
    CGFloat length = layer.frame.size.width > layer.frame.size.height ? layer.frame.size.height : layer.frame.size.width;
    CGFloat width = length - 3;
    CGFloat height = length - 3;
    CGFloat x = (layer.frame.size.width - width) * 0.5;
    CGFloat y = (layer.frame.size.height - height) * 0.5 + 1;
    
    switch (shape) {
        case drawGeometricShapeCircular: {
            // 圆形
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width * 0.5 + x, height * 0.5 + y) radius:width * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            break;
        }
        case drawGeometricShapeRect: {
            // 正方形
            width = layer.frame.size.width;
            x = (layer.frame.size.width - width) * 0.5;
            path = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, width, height)];
            break;
        }
        case drawGeometricShapeLeftHalfCircular:{
            // 左半圆 右半正方形
            x += width * 0.5;
            y += height * 0.5;
            CGFloat radius = width * 0.5;
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:radius startAngle:M_PI_2 endAngle:M_PI_2 + M_PI  clockwise:YES];
            [path addLineToPoint:CGPointMake(x + radius + 1.5, y - height * 0.5)];
            [path addLineToPoint:CGPointMake(x + radius + 1.5, y + height * 0.5)];
            [path closePath];
            break;
        }
        case drawGeometricShapeRightHalfCircular: {
            // 右半圆 左半正方形
            x += width * 0.5;
            y += height * 0.5;
            CGFloat radius = width * 0.5;
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:radius startAngle:M_PI_2 endAngle:M_PI_2 + M_PI  clockwise:NO];
            [path addLineToPoint:CGPointMake(x - radius - 1.5, y - height * 0.5)];
            [path addLineToPoint:CGPointMake(x - radius - 1.5, y + height * 0.5)];
            [path closePath];
            break;
        }
        case drawGeometricShapeCircularRing: {
            // 圆环
            path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width * 0.5 + x, height * 0.5 + y) radius:width * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            shapeLayer.fillColor = nil;
            shapeLayer.strokeColor = color;
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

//
//  HQLLayerDrawGeometricShape.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum {
    HQLGeometricShapeNone = 0 ,                    //  空白
    HQLGeometricShapeCircular ,                      // 圆形
    HQLGeometricShapeRect ,                           // 矩形
    HQLGeometricShapeLeftHalfCircular,           // 左半圆 右半正方形
    HQLGeometricShapeRightHalfCircular,        // 右半圆 左半正方形
    HQLGeometricShapeCircularRing  ,             //  圆环
    HQLGeometricShapeEllipse ,                       //  椭圆
} HQLGeometricShape;

@interface HQLLayerDrawGeometricShape : NSObject

+ (void)layerDrawGeometricShapeWithLayer:(CALayer *)layer shape:(HQLGeometricShape)shape color:(CGColorRef)color;

@end

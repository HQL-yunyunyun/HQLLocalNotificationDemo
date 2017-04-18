//
//  HQLLayerDrawGeometricShape.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum {
    drawGeometricShapeNone = 0 ,                    //  空白
    drawGeometricShapeCircular ,                      // 圆形
    drawGeometricShapeRect ,                           // 矩形
    drawGeometricShapeLeftHalfCircular,           // 左半圆 右半正方形
    drawGeometricShapeRightHalfCircular,        // 右半圆 左半正方形
    drawGeometricShapeCircularRing  ,             //  圆环
    drawGeometricShapeEllipse ,                       //  椭圆
} HQLDrawGeometricShape;

@interface HQLLayerDrawGeometricShape : NSObject

+ (void)layerDrawGeometricShapeWithLayer:(CALayer *)layer shape:(HQLDrawGeometricShape)shape color:(CGColorRef)color;

@end

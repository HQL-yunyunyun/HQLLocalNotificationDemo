//
//  HQLSelectButton.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQLLayerDrawGeometricShape.h"

@interface HQLSelectButton : UIButton

@property (assign, nonatomic) HQLGeometricShape defaultMode; // 没有选择时的状态
@property (strong, nonatomic) UIColor *defaultShapeColor; // 没有选择时的颜色

@property (assign, nonatomic) HQLGeometricShape selectedMode; // 选中时的形状
@property (strong, nonatomic) UIColor *selectedShapeColor; // 形状颜色

@end

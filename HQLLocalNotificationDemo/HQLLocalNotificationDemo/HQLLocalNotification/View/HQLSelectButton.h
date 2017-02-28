//
//  HQLSelectButton.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HQLSelectButtonNone , // 没有
    HQLSelectButtonCircle // 圆形
} HQLSelectButtonDefaultMode;

@interface HQLSelectButton : UIButton

@property (assign, nonatomic) HQLSelectButtonDefaultMode defaultMode; // 没有选择时的状态
@property (strong, nonatomic) UIColor *selectedShapeColor; // 圆环的颜色
@property (strong, nonatomic) UIColor *defaultShapeColor; // 没有选择时的颜色

@end

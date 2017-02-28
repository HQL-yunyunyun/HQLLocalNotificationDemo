//
//  CALayer+HQLXIBLayer.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "CALayer+HQLXIBLayer.h"
#import <UIKit/UIKit.h>

@implementation CALayer (HQLXIBLayer)

- (void)setHQL_BorderColor:(UIColor *)color {
    self.borderColor = color.CGColor;
}

@end

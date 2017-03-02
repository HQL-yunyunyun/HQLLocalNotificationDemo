//
//  CALayer+HQLXIBLayer.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (HQLXIBLayer)

@property (assign, nonatomic) NSInteger HQLLayerTag;

- (void)setHQL_BorderColor:(UIColor *)HQL_BorderColor;

//@property (strong, nonatomic) UIColor *HQL_BorderColor;

@end

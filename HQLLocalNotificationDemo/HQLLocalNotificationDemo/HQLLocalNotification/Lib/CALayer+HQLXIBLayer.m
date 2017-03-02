//
//  CALayer+HQLXIBLayer.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "CALayer+HQLXIBLayer.h"
#import <objc/runtime.h>

static NSString *HQLRuntimeKey;

@implementation CALayer (HQLXIBLayer)

- (NSInteger)HQLLayerTag {
    return [objc_getAssociatedObject(self, &HQLRuntimeKey) integerValue];
}

- (void)setHQLLayerTag:(NSInteger)HQLLayerTag {
    
    objc_setAssociatedObject(self, &HQLRuntimeKey, [NSNumber numberWithInteger:HQLLayerTag], OBJC_ASSOCIATION_ASSIGN);
}

- (void)setHQL_BorderColor:(UIColor *)HQL_BorderColor {
    self.borderColor = HQL_BorderColor.CGColor;
}

@end

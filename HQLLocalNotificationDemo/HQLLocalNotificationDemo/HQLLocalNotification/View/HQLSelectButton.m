//
//  HQLSelectButton.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/28.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLSelectButton.h"
#import "HQLLayerDrawGeometricShape.h"

@implementation HQLSelectButton

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    // selectedColor
    UIColor *shapeColor = nil;
    HQLDrawGeometricShape shape = drawGeometricShapeNone;
    if (selected) {
        if (!self.selectedShapeColor) {
            self.selectedShapeColor = [UIColor orangeColor];
        }
        shapeColor = self.selectedShapeColor;
        shape = drawGeometricShapeCircular;
    } else {
        if (self.defaultMode == HQLSelectButtonCircle) {
            if (!self.defaultShapeColor) {
                self.defaultShapeColor = [UIColor orangeColor];
            }
            shapeColor = self.defaultShapeColor;
            shape = drawGeometricShapeCircularRing;
        } else if (self.defaultMode == HQLSelectButtonNone) {
            shape = drawGeometricShapeNone;
            shapeColor = nil;
        }
    }
    [HQLLayerDrawGeometricShape layerDrawGeometricShapeWithLayer:self.layer shape:shape color:shapeColor.CGColor];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
//    NSLog(@"%@", NSStringFromCGRect(frame));
    [self setSelected:self.isSelected];
}

@end

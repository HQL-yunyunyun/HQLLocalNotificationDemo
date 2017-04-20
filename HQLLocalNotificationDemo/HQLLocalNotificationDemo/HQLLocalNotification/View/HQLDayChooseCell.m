//
//  HQLDayChooseCell.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/19.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLDayChooseCell.h"
#import "HQLSelectButton.h"

@interface HQLDayChooseCell ()

@property (strong, nonatomic) HQLSelectButton *button;

@end

@implementation HQLDayChooseCell

#pragma mark - setter

- (void)setModel:(HQLDayChooseModel *)model {
    _model = model;
    
    [self.button setTitle:[NSString stringWithFormat:@"%ld", model.day] forState:UIControlStateNormal];
    self.button.frame = self.bounds;
    [self.button setSelected:model.isSelected];
}

#pragma mark - getter

- (HQLSelectButton *)button {
    if (!_button) {
        _button = [HQLSelectButton buttonWithType:UIButtonTypeCustom];
        _button.selectedMode = HQLGeometricShapeCircularRing;
        _button.selectedShapeColor = [UIColor colorWithRed:0 green:(211 / 255.0) blue:(221 / 255.0) alpha:1];
        [_button setTitleColor:[UIColor colorWithRed:(10 / 255.0) green:(40 / 255.0) blue:(80 / 255.0) alpha:1] forState:UIControlStateNormal];
        _button.userInteractionEnabled = NO; // 不能拦截 collectionView didSelectedCellForItem
        [_button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        
        [self addSubview:_button];
    }
    return _button;
}

@end

#pragma mark - day choose model

@implementation HQLDayChooseModel

@end

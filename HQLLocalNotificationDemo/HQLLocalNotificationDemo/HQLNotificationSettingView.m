//
//  HQLNotificationSettingView.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/27.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLNotificationSettingView.h"

@interface HQLNotificationSettingView ()

@property (strong, nonatomic) UIDatePicker *datePicker; // 时刻选择
@property (strong, nonatomic) UIView *monthChooseView; // 选择月份
@property (strong, nonatomic) UIView *weekdayChooseView; // 选择循环的weekday
@property (strong, nonatomic) UIView *shortcutView; // 快捷选择
@property (strong, nonatomic) UIScrollView *dateChooseView; // 日期选择

@property (strong, nonatomic) NSMutableArray *dateButtonArray; // 日期的button
@property (strong, nonatomic) NSMutableArray *selectedDate; // 日选择日期

@end

@implementation HQLNotificationSettingView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.showDate = [NSDate date];
        
        [self datePicker];
    }
    return self;
}

#pragma mark - setter

- (void)setShowDate:(NSDate *)showDate {
    _showDate = showDate;
    self.datePicker.date = showDate;
}

#pragma mark - getter 

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * 0.3)];
        _datePicker.datePickerMode = UIDatePickerModeTime;
//        _datePicker.date = self.showDate;
        [self addSubview:_datePicker];
    }
    return _datePicker;
}

@end

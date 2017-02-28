//
//  HQLNotificationSettingView.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/27.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLNotificationSettingView.h"
#import "HQLSelectButton.h"
#import "HQLLocalNotificationModel.h"

#define HQLScreenHeight [UIScreen mainScreen].bounds.size.height
#define HQLScreenWidth [UIScreen mainScreen].bounds.size.width

#define HQLDateButtonWidth 40
#define HQLDateButtonConstTag 278

@interface HQLNotificationSettingView ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker; // 时刻选择

@property (weak, nonatomic) IBOutlet UIButton *lastMonthButton; // 上个月
@property (weak, nonatomic) IBOutlet UIButton *nextMonthButton; // 下个月
@property (weak, nonatomic) IBOutlet UILabel *monthLabel; // 月份

@property (weak, nonatomic) IBOutlet UIView *weekdayChooseView; // 选择weekday

@property (weak, nonatomic) IBOutlet UIScrollView *dateChooseView; // 选择日期

@property (weak, nonatomic) IBOutlet HQLSelectButton *workdayButton; // 工作日
@property (weak, nonatomic) IBOutlet HQLSelectButton *weekendButton; // 周末
@property (weak, nonatomic) IBOutlet HQLSelectButton *everydayButton; // 每天
@property (weak, nonatomic) IBOutlet HQLSelectButton *everymonthButton; // 每月

@property (strong, nonatomic) NSMutableArray *dateButtonArray; // 日期的button
@property (strong, nonatomic) NSMutableArray *selectedDates; // 已选择日期(具体)

@property (strong, nonatomic) NSMutableArray *selectedWeekday; // 已选择日期(周一 周二)

@property (assign, nonatomic) HQLLocalNotificationRepeat currentRepeat; // 当前循环的模式

@property (strong, nonatomic) NSDate *currentDate; // 当前显示的月份
@end

@implementation HQLNotificationSettingView

#pragma mark - init

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.showDate = [NSDate date];
    // 创建dateButton
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

#pragma mark - prepare UI

- (void)createDateButtons {
    [self.dateButtonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.dateButtonArray removeAllObjects];
    self.dateButtonArray = [NSMutableArray array];
    // 获取当前月份的
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dayCount = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.currentDate].length;
    
    NSDateComponents *compon = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self.currentDate];
    
    for (int i = 1; i <= dayCount ; i++) {
        HQLSelectButton *button = [HQLSelectButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        compon.day = i;
        if ([self isToday:[calendar dateFromComponents:compon]]) {
            button.defaultMode = HQLSelectButtonCircle;
        } else {
            button.defaultMode = HQLSelectButtonNone;
        }
        button.tag = (HQLDateButtonConstTag * i) + i;
        [self.dateButtonArray addObject:button];
        [self.dateChooseView addSubview:button];
        
        // 再判断当前日期是否有选中
    }
}

- (BOOL)isToday:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayCom = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *dateCom = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return ((todayCom.year == dateCom.year) && (todayCom.month == dateCom.month) && (todayCom.day == dateCom.day));
}

#pragma mark - event 

- (void)dateButtonDidClick:(UIButton *)button {
    if (!self.selectedDates) {
        self.selectedDates = [NSMutableArray array];
    }
    
    // 清除 周一 周二 的选择 清除已选择的weekdayDate 如果循环模式是 day 或者 week 则都变成 none
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compon = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self.currentDate];
    compon.day = button.tag / (HQLDateButtonConstTag + 1);
    NSDate *selectedDate = [calendar dateFromComponents:compon];
    
    if (button.isSelected) { // 已经选择了
        NSDate *deleDate = nil;
        for (NSDate *date in self.selectedDates) {
            if ([date compare:selectedDate]) {
                deleDate = date;
                break;
            }
        }
        if (deleDate) {
            [self.selectedDates removeObject:deleDate];
        }
    } else { // 没有选择
        [self.selectedDates addObject:selectedDate];
    }
    
    [button setSelected:!button.isSelected];
}

#pragma mark - setter

- (void)setShowDate:(NSDate *)showDate {
    _showDate = showDate;
    self.datePicker.date = showDate;
    self.currentDate = showDate;
}

@end

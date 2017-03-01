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
#import "HQLLocalNotificationConfig.h"

#define HQLScreenHeight [UIScreen mainScreen].bounds.size.height
#define HQLScreenWidth [UIScreen mainScreen].bounds.size.width

//#define HQLDateButtonWidth 40
#define HQLDateButtonConstTag 278

#define HQLWeekdayButtonConstTag 8820

#define HQLWorkdayButtonTag 9394
#define HQLWeekendButtonTag 9233
#define HQLEverydayButtonTag 9555
#define HQLEverymonthButtonTag 9333

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
    
    HQLSelectButton *lastButton = nil;
    CGFloat margin = 3;
    HQLSelectButton *todayButton = nil;
    
    for (int i = 1; i <= dayCount ; i++) {
        HQLSelectButton *button = [HQLSelectButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dateButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        compon.day = i;
        NSDate *buttonDate = [calendar dateFromComponents:compon];
        if ([self compareDay:buttonDate compareDay:[NSDate date]]) {
            button.defaultMode = HQLSelectButtonCircle;
            todayButton = button;
        } else {
            button.defaultMode = HQLSelectButtonNone;
        }
        button.tag = (HQLDateButtonConstTag * i) + i;
        [self.dateButtonArray addObject:button];
        [self.dateChooseView addSubview:button];
        
        // 再判断当前日期是否有选中
        for (NSDate *date in self.selectedDates) {
            if ([self compareDay:date compareDay:buttonDate]) {
                [button setSelected:YES];
            }
        }
        
        // 配对button的frame
        CGFloat buttonW = 40;
        CGFloat buttonH = buttonW;
        CGFloat buttonX = CGRectGetMaxX(lastButton.frame) + margin;
        CGFloat buttonY = (self.dateChooseView.frame.size.height - buttonH) * 0.5;
        [button setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
        lastButton = button;
    }
    // 设置contentSize
    [self.dateChooseView setContentSize:CGSizeMake(CGRectGetMaxX(lastButton.frame) + margin, self.dateChooseView.frame.size.height)];
    if (todayButton) {
        CGFloat x = todayButton.frame.origin.x - self.dateChooseView.frame.size.width * 0.5;
        CGFloat y = 0;
        [self.dateChooseView setContentOffset:CGPointMake( x, y) animated:YES];
    }
}

- (BOOL)compareDay:(NSDate *)date compareDay:(NSDate *)compareDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compareCom = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:compareDay];
    NSDateComponents *dateCom = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return ((compareCom.year == dateCom.year) && (compareCom.month == dateCom.month) && (compareCom.day == dateCom.day));
}

#pragma mark - event

- (IBAction)weekdayButtonDidClick:(HQLSelectButton *)sender {
    // 取消date的选择
    if (self.selectedDates.count != 0 ) {
        [self.selectedDates removeAllObjects];
        [self.dateButtonArray makeObjectsPerformSelector:@selector(setSelected:) withObject:[NSNumber numberWithBool:NO]];
    }
    
    if (!self.selectedWeekday) {
        self.selectedWeekday = [NSMutableArray array];
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger weekday = sender.tag - HQLWeekdayButtonConstTag;
    if (sender.selected) { // 已选择
        NSDate *deleDate = nil;
        for (NSDate *date in self.selectedWeekday) {
            if (weekday == [calendar component:NSCalendarUnitWeekday fromDate:date]) {
                deleDate = date;
                break;
            }
        }
        if (deleDate) {
            [self.selectedWeekday removeObject:deleDate];
        }
    } else { // 没有选择
        [self.selectedWeekday addObject:[HQLLocalNotificationConfig getWeekdayDateWithWeekday:weekday]];
    }
    
    // 取消所有快捷键
    [self.workdayButton setSelected:NO];
    [self.weekendButton setSelected:NO];
    [self.everydayButton setSelected:NO];
    [self.everymonthButton setSelected:NO];
    self.currentRepeat = HQLLocalNotificationWeekRepeat; // 点击了weekdayButton 一定是week的循环
    
    // 判断是否点亮快捷键
    if (self.selectedWeekday.count == 7) { // 一定是every day
        [self.everydayButton setSelected:YES];
        self.currentRepeat = HQLLocalNotificationDayRepeat; // 每一天
    } else if (self.selectedWeekday.count == 5) {
        BOOL isHighlight = YES;
        for (NSDate *date in self.selectedWeekday) {
            NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date];
            if (weekday == 7 || weekday == 1) {
                isHighlight = NO;
                break;
            }
        }
        [self.workdayButton setSelected:isHighlight];
    } else if (self.selectedWeekday.count == 2) {
        BOOL isHighlight = YES;
        for (NSDate *date in self.selectedWeekday) {
            NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date];
            if (weekday < 7 || weekday > 1) {
                isHighlight = NO;
                break;
            }
        }
        [self.workdayButton setSelected:isHighlight];
    } else {
    
    }
    
    [sender setSelected:!sender.isSelected];
}

// 闹钟模式
- (IBAction)alarmModeShortcut:(HQLSelectButton *)sender {
    if (sender.tag == HQLWorkdayButtonTag) {
        
    } else if (sender.tag == HQLWeekendButtonTag) {
        
    } else if (sender.tag == HQLEverydayButtonTag) {
        
    } else{
    
    }
}

- (IBAction)scheduleModeShortcut:(HQLSelectButton *)sender {
    if (sender.tag == HQLEverymonthButtonTag) {
        
    } else {
        
    }
}

- (void)dateButtonDidClick:(UIButton *)button {
    // 清除 周一 周二 的选择 清除已选择的weekdayDate 如果循环模式是 day 或者 week 则都变成 none
    if (self.selectedWeekday.count != 0) {
        [self.selectedWeekday removeAllObjects];
        for (UIView *view in self.weekdayChooseView.subviews) {
            if ([view isKindOfClass:[HQLSelectButton class]]) {
                HQLSelectButton *button = (HQLSelectButton *)view;
                [button setSelected:NO];
            }
        }
    }
    if (self.currentRepeat != HQLLocalNotificationMonthRepeat && self.currentRepeat != HQLLocalNotificationYearRepeat) {
        self.currentRepeat = HQLLocalNotificationNoneRepeat;
    }
    // 清除快捷键
    [self.workdayButton setSelected:NO];
    [self.weekendButton setSelected:NO];
    [self.everydayButton setSelected:NO];
    
    if (!self.selectedDates) {
        self.selectedDates = [NSMutableArray array];
    }
    
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

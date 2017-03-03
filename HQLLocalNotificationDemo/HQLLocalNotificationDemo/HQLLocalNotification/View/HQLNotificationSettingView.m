//
//  HQLNotificationSettingView.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/27.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLNotificationSettingView.h"
#import "HQLSelectButton.h"
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

@property (assign, nonatomic) HQLLocalNotificationMode currentNotificationMode; // 当前通知的模式 --- 闹钟或日程

@property (strong, nonatomic) NSDate *currentDate; // 当前显示的月份
@end

@implementation HQLNotificationSettingView

#pragma mark - init

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.showDate = [NSDate date];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithCoder:aDecoder];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    // 创建dateButton
    if (self.dateChooseView) {
        [self createDateButtons]; // 如果xib里面的subView还没有创建,则不创建
    }
}

#pragma mark - prepare UI

- (void)createDateButtons {
    [self.dateButtonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.dateButtonArray removeAllObjects];
    self.dateButtonArray = [NSMutableArray array];
    
    // 获取当前月份的
    NSInteger dayCount = [[self calendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.currentDate].length;
    NSDateComponents *compon = [[self calendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self.currentDate];
    
    HQLSelectButton *lastButton = nil;
    CGFloat margin = 3;
    HQLSelectButton *todayButton = nil;
    
    // 因为dateChooseViewHeight的高度在刚创建的时候是不能确定的,所以需要手动计算
    CGFloat dateChooseViewHeight = self.frame.size.height * 0.6 * 0.4;
    CGFloat dateChooseViewWidth = self.frame.size.width * 0.75;
    
    for (int i = 1; i <= dayCount ; i++) {
        // 创建
        HQLSelectButton *button = [HQLSelectButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dateButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 配对button的frame
        CGFloat buttonW = dateChooseViewHeight * 0.6;
        CGFloat buttonH = buttonW;
        CGFloat buttonX = CGRectGetMaxX(lastButton.frame) + margin;
        CGFloat buttonY = (dateChooseViewHeight - buttonH) * 0.5;
        [button setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
        lastButton = button;
        
        // 配置
        compon.day = i;
        NSDate *buttonDate = [[self calendar] dateFromComponents:compon];
        if ([self compareDay:buttonDate compareDay:[NSDate date]]) {
            button.defaultShapeColor = [UIColor orangeColor];
            button.defaultMode = HQLSelectButtonCircle;
            [button setSelected:NO];
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
    }
    
    // 设置contentSize
    [self.dateChooseView setContentSize:CGSizeMake(CGRectGetMaxX(lastButton.frame) + margin, dateChooseViewHeight)];
    // 偏移量
    if (todayButton) {
        CGFloat x = todayButton.frame.origin.x - dateChooseViewWidth * 0.5;
        if (todayButton.frame.origin.x < dateChooseViewWidth) {
            x = 0;
        } else if (todayButton.frame.origin.x > (self.dateChooseView.contentSize.width - dateChooseViewWidth)) {
            x = self.dateChooseView.contentSize.width - dateChooseViewWidth;
        }
        CGFloat y = 0;
        [self.dateChooseView setContentOffset:CGPointMake( x, y) animated:YES];
    } else {
        [self.dateChooseView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

#pragma mark - event

- (IBAction)lastMonth:(UIButton *)sender {
    // 上个月
    self.currentDate = [HQLLocalNotificationConfig getPriusDateFromDate:self.currentDate withMonth:-1];
    [self createDateButtons];
}

- (IBAction)nextMonth:(UIButton *)sender {
    // 下个月
    self.currentDate = [HQLLocalNotificationConfig getPriusDateFromDate:self.currentDate withMonth:1];
    [self createDateButtons];
}

// 点击weekday
- (IBAction)weekdayButtonDidClick:(HQLSelectButton *)sender {
    // 取消date的选择
    if (self.selectedDates.count != 0 ) {
        [self.selectedDates removeAllObjects];
        [self.dateButtonArray makeObjectsPerformSelector:@selector(setSelected:) withObject:[NSNumber numberWithBool:NO]];
    }
    
    if (!self.selectedWeekday) {
        self.selectedWeekday = [NSMutableArray array];
    }
    
    NSInteger weekday = sender.tag - HQLWeekdayButtonConstTag;
    if (sender.selected) { // 已选择
        NSDate *deleDate = nil;
        for (NSDate *date in self.selectedWeekday) {
            if (weekday == [[self calendar] component:NSCalendarUnitWeekday fromDate:date]) {
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
            NSInteger weekday = [[self calendar] component:NSCalendarUnitWeekday fromDate:date];
            if (weekday == 7 || weekday == 1) {
                isHighlight = NO;
                break;
            }
        }
        [self.workdayButton setSelected:isHighlight];
    } else if (self.selectedWeekday.count == 2) {
        BOOL isHighlight = YES;
        for (NSDate *date in self.selectedWeekday) {
            NSInteger weekday = [[self calendar] component:NSCalendarUnitWeekday fromDate:date];
            if (weekday < 7 && weekday > 1) {
                isHighlight = NO;
                break;
            }
        }
        [self.weekendButton setSelected:isHighlight];
    } else {
    
    }
    
    [sender setSelected:!sender.isSelected];
    
    // 代理
    if ([self.delegate respondsToSelector:@selector(notificationSettingViewDidChangeDate:dateArray:timeMoment:repeatMode:notificationMode:)]) {
        [self.delegate notificationSettingViewDidChangeDate:[NSMutableArray arrayWithArray:self.selectedWeekday] dateArray:[NSMutableArray arrayWithArray:self.selectedDates] timeMoment:[self.datePicker date] repeatMode:self.currentRepeat notificationMode:self.currentNotificationMode];
    }
}

// 闹钟模式
- (IBAction)alarmModeShortcut:(HQLSelectButton *)sender {
    
    if (self.selectedWeekday.count != 0) { // 取消weekday
        [self.selectedWeekday removeAllObjects];
        for (UIView *view in self.weekdayChooseView.subviews) {
            if ([view isKindOfClass:[HQLSelectButton class]]) {
                HQLSelectButton *button = (HQLSelectButton *)view;
                [button setSelected:NO];
            }
        }
    }
    
    if (sender.isSelected) { // 已选择 ---> 取消选择
        [sender setSelected:NO];
    } else { // 选择
        // 先取消 date 的选择 weekday 的选择 和 everymonth 的选择
        if (self.selectedDates.count != 0 ) { // 取消date
            [self.selectedDates removeAllObjects];
            [self.dateButtonArray makeObjectsPerformSelector:@selector(setSelected:) withObject:[NSNumber numberWithBool:NO]];
        }
        // 取消快捷键的选择
        [self.workdayButton setSelected:NO];
        [self.weekendButton setSelected:NO];
        [self.everydayButton setSelected:NO];
        [self.everymonthButton setSelected:NO];
        
        if (!self.selectedWeekday) {
            self.selectedWeekday = [NSMutableArray array];
        }
        
        for (UIView *view in self.weekdayChooseView.subviews) {
            if ([view isKindOfClass:[HQLSelectButton class]]) {
                HQLSelectButton *button = (HQLSelectButton *)view;
                NSInteger weekday = button.tag - HQLWeekdayButtonConstTag;
                if (sender.tag == HQLWorkdayButtonTag) { // 工作日
                    if (weekday > 1 && weekday < 7) {
                        [self weekdayButtonDidClick:button];
                    }
                } else if (sender.tag == HQLWeekendButtonTag) { // 周末
                    if (weekday == 1 || weekday == 7) {
                        [self weekdayButtonDidClick:button];
                    }
                } else if (sender.tag == HQLEverydayButtonTag) { // 每一天
                    [self weekdayButtonDidClick:button];
                } else{
                    
                }
            }
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(notificationSettingViewDidChangeDate:dateArray:timeMoment:repeatMode:notificationMode:)]) {
        [self.delegate notificationSettingViewDidChangeDate:[NSMutableArray arrayWithArray:self.selectedWeekday] dateArray:[NSMutableArray arrayWithArray:self.selectedDates] timeMoment:[self.datePicker date] repeatMode:self.currentRepeat notificationMode:self.currentNotificationMode];
    }
}

- (IBAction)scheduleModeShortcut:(HQLSelectButton *)sender {
    
    // 先取消 weekday 的选择 和 everymonth 的选择
    if (self.selectedWeekday.count != 0) { // 取消weekday
        [self.selectedWeekday removeAllObjects];
        for (UIView *view in self.weekdayChooseView.subviews) {
            if ([view isKindOfClass:[HQLSelectButton class]]) {
                HQLSelectButton *button = (HQLSelectButton *)view;
                [button setSelected:NO];
            }
        }
    }
    // 取消快捷键的选择
    [self.workdayButton setSelected:NO];
    [self.weekendButton setSelected:NO];
    [self.everydayButton setSelected:NO];
    
    if (sender.tag == HQLEverymonthButtonTag) {
        [sender setSelected:!sender.isSelected];
        if (sender.isSelected) {
            self.currentRepeat = HQLLocalNotificationMonthRepeat;
        } else {
            self.currentRepeat = HQLLocalNotificationNoneRepeat;
        }
    } else {
        
    }
    
    if ([self.delegate respondsToSelector:@selector(notificationSettingViewDidChangeDate:dateArray:timeMoment:repeatMode:notificationMode:)]) {
        [self.delegate notificationSettingViewDidChangeDate:[NSMutableArray arrayWithArray:self.selectedWeekday] dateArray:[NSMutableArray arrayWithArray:self.selectedDates] timeMoment:[self.datePicker date] repeatMode:self.currentRepeat notificationMode:self.currentNotificationMode];
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
    
    NSDateComponents *compon = [[self calendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self.currentDate];
    compon.day = button.tag / (HQLDateButtonConstTag + 1);
    NSDate *selectedDate = [[self calendar] dateFromComponents:compon];
    
    if (button.isSelected) { // 已经选择了
        NSDate *deleDate = nil;
        for (NSDate *date in self.selectedDates) {
            if ([self compareDay:date compareDay:selectedDate]) {
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
    
    if ([self.delegate respondsToSelector:@selector(notificationSettingViewDidChangeDate:dateArray:timeMoment:repeatMode:notificationMode:)]) {
        [self.delegate notificationSettingViewDidChangeDate:[NSMutableArray arrayWithArray:self.selectedWeekday] dateArray:[NSMutableArray arrayWithArray:self.selectedDates] timeMoment:[self.datePicker date] repeatMode:self.currentRepeat notificationMode:self.currentNotificationMode];
    }
}

// 获取 content
- (void)notificationContent:(void(^)(NSArray *targetDateArray, HQLLocalNotificationRepeat repeatMode, HQLLocalNotificationMode notificationMode))completeBlock {
    NSArray *array = nil;
    if (self.selectedDates.count != 0 && self.selectedDates) {
        array = [NSArray arrayWithArray:self.selectedDates];
    } else if (self.selectedWeekday.count != 0 && self.selectedWeekday) {
        array = [NSArray arrayWithArray:self.selectedWeekday];
    } else {
    
    }
    
    NSDateComponents *moment = [[self calendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[self.datePicker date]];
    
    NSMutableArray *targetArray = [NSMutableArray array];
    // 合并 形成目标date
    for (NSDate *date in array) {
        NSDateComponents *dateCompon = [[self calendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:date];
        dateCompon.hour = moment.hour;
        dateCompon.minute = moment.minute;
        
        [targetArray addObject:[[self calendar] dateFromComponents:dateCompon]];
    }
    // 回调
    if (completeBlock) {
        completeBlock(targetArray.copy, self.currentRepeat, self.currentNotificationMode);
    }
}

- (void)showDateArray:(NSArray *)dateArray repeatMode:(HQLLocalNotificationRepeat)repeatMode notificationMode:(HQLLocalNotificationMode)notificationMode {
    // 根据 repeatMode 设置
    
}

#pragma mark - tool method

// 是否同一天
- (BOOL)compareDay:(NSDate *)date compareDay:(NSDate *)compareDay{
    NSDateComponents *compareCom = [[self calendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:compareDay];
    NSDateComponents *dateCom = [[self calendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return ((compareCom.year == dateCom.year) && (compareCom.month == dateCom.month) && (compareCom.day == dateCom.day));
}

- (NSCalendar *)calendar {
    return [NSCalendar currentCalendar];
}

#pragma mark - getter 

- (HQLLocalNotificationMode)currentNotificationMode {
    HQLLocalNotificationMode mode = HQLLocalNotificationAlarmMode; // 闹钟
    if (self.currentRepeat == HQLLocalNotificationNoneRepeat) {
        if (self.selectedWeekday.count != 0 && self.selectedWeekday) {
            mode = HQLLocalNotificationAlarmMode;
        } else if (self.selectedDates.count != 0 && self.selectedDates) {
            mode = HQLLocalNotificationScheduleMode;
        } else {
        
        }
    } else if (self.currentRepeat == HQLLocalNotificationMonthRepeat || self.currentRepeat == HQLLocalNotificationYearRepeat) {
        mode = HQLLocalNotificationScheduleMode;
    } else {
        mode = HQLLocalNotificationAlarmMode;
    }
    return mode;
}

#pragma mark - setter

- (void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月"];
    [self.monthLabel setText:[formatter stringFromDate:self.currentDate]];
}

- (void)setShowDate:(NSDate *)showDate {
    _showDate = showDate;
    self.datePicker.date = showDate;
    self.currentDate = showDate;
}

@end

//
//  HQLSetNotificationView.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLSetNotificationView.h"
#import "HQLSelectButton.h"
#import "HQLDayChooseCell.h"
#import "HQLCalendarView.h"

#import "HQLDateModel.h"
#import "HQLLocalNotificationModel.h"

#import "HQLLocalNotificationConfig.h"

#define HQLEveryDayButtonTag 7729
#define HQLWorkDayButtonTag 8832
#define HQLWeekendButtonTag 9934
#define HQLEveryMonthButtonTag 5543
#define HQLNotRepeatButtonTag 3450

#define HQLWeekButtonConstTag 479

#define HQLLastMonthButtontTag 2356
#define HQLNextMonthButtonTag 6532

#define HQLNotificationAlertTitle @"本地通知"

#define HQLFixedHeight 263
#define HQLDateButtonSize (((self.frame.size.width - 60) / 7.0) - 1)
#define HQLEveryMonthModeHeight (HQLDateButtonSize * 5.0)
#define HQLNotRepeatModeHeight ((HQLDateButtonSize * 6.0) + 10)
#define HQLWeekModeHeight 50
#define HQLTitleViewWidth 60

#define HQLDayChooseCellReuseID @"HQLDayChooseCellReuseID"

@interface HQLSetNotificationView () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, HQLCalendarViewDelegate>

/*========== 通知的基本信息 ==========*/
@property (weak, nonatomic) IBOutlet UITextField *notificationContentTextField;
@property (weak, nonatomic) IBOutlet UILabel *notificationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationTimeLabel;

// 选择时刻
@property (weak, nonatomic) IBOutlet UIDatePicker *notificationTimePicker;

/*========== 通知的周期选择 ==========*/
@property (weak, nonatomic) IBOutlet HQLSelectButton *everydayButton;
@property (weak, nonatomic) IBOutlet HQLSelectButton *workdayButton;
@property (weak, nonatomic) IBOutlet HQLSelectButton *weekendButton;
@property (weak, nonatomic) IBOutlet HQLSelectButton *everymonthButton;
@property (weak, nonatomic) IBOutlet HQLSelectButton *notRepeatButton;
@property (weak, nonatomic) IBOutlet UIView *modeButtonView; // 模式选择所在的View

/*========== 通知的日期选择 ==========*/
@property (weak, nonatomic) IBOutlet UIView *notificationDateSettingTitleView;
@property (weak, nonatomic) IBOutlet UIView *notificationDateSettingView;
// 显示周一、周二等button，因为设计问题，这些button是不能点击的，只有在 每天 工作日 休息日 的时候显示
@property (strong, nonatomic) NSMutableArray *weekButtonArray;
@property (strong, nonatomic) UIView *weekButtonView; // 选择 星期 一 二 三 等button的View
// 选择日期，1-31号 只有在 每月 的时候显示
@property (strong, nonatomic) UICollectionView *dayChooseView;
@property (strong, nonatomic) UICollectionViewFlowLayout *dayChooseFlowLayout;
// 显示的数据
@property (strong, nonatomic) NSMutableArray <HQLDayChooseModel *>*dayChooseDataSource;

@property (strong, nonatomic) UILabel *titleLabel; // 显示title(日期、星期、月份)

/*========== 日期选择(不重复的情况) ==========*/
@property (strong, nonatomic) UIButton *lastMonth;
@property (strong, nonatomic) UIButton *nextMonth;
// 日期View
@property (strong, nonatomic) UIView *calendarView; // 显示日历
@property (strong, nonatomic) NSMutableArray <HQLCalendarView *>*calendarViewArray; // 保存日历 (三个日历)

// 模式
@property (assign, nonatomic) HQLLocalNotificationMode currentMode;
// 重复
@property (assign, nonatomic) HQLLocalNotificationRepeat currentRepeat;

// 保存当前选择的日期
@property (strong, nonatomic) NSMutableArray *currentDateArray;

// 保存当前 日历显示的月份
@property (strong, nonatomic) NSDate *currentMonth;

@end

@implementation HQLSetNotificationView

#pragma mark - life cycle 

+ (instancetype)setNotificationView {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HQLSetNotificationView" owner:nil options:nil];
    HQLSetNotificationView *notificationView = array.firstObject;
    return notificationView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self prepareConfig];
}

- (void)setFrame:(CGRect)frame {
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    [super setFrame:frame];
    if (originWidth != self.frame.size.width || originHeight != self.frame.size.height) {
        if (originWidth != self.frame.size.width ) {
            [self layoutIfNeeded]; // 因为本页面的 subView 的frame 主要受 width影响
        }
        [self updateFrame];
    }
}

#pragma mark - prepare config

- (void)prepareConfig {
    if (!self.notificationAlertTitle) {
        self.notificationAlertTitle = HQLNotificationAlertTitle;
    }
    for (UIView *view in self.modeButtonView.subviews) {
        if ([view isKindOfClass:[HQLSelectButton class]]) {
            HQLSelectButton *button = (HQLSelectButton *)view;
            [button setSelectedShapeColor:[UIColor colorWithRed:0 green:(211 / 255.0) blue:(221 / 255.0) alpha:1]];
            [button setSelectedMode:HQLGeometricShapeEllipse];
        }
    }
    [self.notificationTimePicker setValue:[UIColor colorWithRed:0 green:(211 / 255.0) blue:(221 / 255.0) alpha:1] forKey:@"textColor"];
    [self.notificationTimePicker setBackgroundColor:[UIColor whiteColor]];
    
    if (!self.notificationModel) {
        HQLLocalNotificationModel *model = [HQLLocalNotificationModel localNotificationModel];
        model.repeatMode = HQLLocalNotificationDayRepeat;
        model.isActivity = YES;
        self.notificationModel = model;
    }
}

#pragma mark - event

// 更新info
- (void)updateNotificationDateInfo {
    // 根据 选择的 dateArray 和 datePicker的时间刷新
    // 时间
    NSDate *timeDate = [self.notificationTimePicker date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [self.notificationTimeLabel setText:[formatter stringFromDate:timeDate]];
    
    HQLLocalNotificationModel *model = [HQLLocalNotificationModel localNotificationModel];
    model.repeatMode = self.currentRepeat;
    model.notificationMode = self.currentMode;
    model.repeatDateArray = self.currentDateArray;
    self.notificationDateLabel.text = [model getModelDateDescription];
}

// 更新frame
- (void)updateFrame {
    // 增加一个条件
    if (!self.notificationModel) {
        return; // 保证在设 model 之前不会创建其他控件
    }
    
    self.lastMonth.hidden = self.currentRepeat != HQLLocalNotificationNoneRepeat;
    self.nextMonth.hidden = self.lastMonth.isHidden;
    
    // 因为frame的改变只有最后的 选择日期 区域会有所改变,所以根据当前模式更新高度,高度的变化都是固定的
    CGRect frame = self.frame;
    
    [self.titleLabel setFrame:CGRectMake(0, 0, 1000, 1000)];
    [self.titleLabel sizeToFit];
    CGRect titleLabelFrame = self.titleLabel.frame;
    titleLabelFrame.origin.x = (HQLTitleViewWidth - titleLabelFrame.size.width) * 0.5;
    
    switch (self.currentRepeat) {
        case HQLLocalNotificationDayRepeat:
        case HQLLocalNotificationWeekRepeat: { // 每天 + 每周
            frame.size.height = HQLFixedHeight + HQLWeekModeHeight;
            titleLabelFrame.origin.y = (HQLWeekModeHeight - titleLabelFrame.size.height) * 0.5;
            
            // 更新weekButtons的frame
            UIButton *lastButton = nil;
            CGFloat buttonWidth = (self.frame.size.width - HQLTitleViewWidth) / 7;
            for (UIButton *button in self.weekButtonArray) {
                button.frame = CGRectMake(CGRectGetMaxX(lastButton.frame), 0, buttonWidth, HQLWeekModeHeight);
                lastButton = button;
            }
            
            self.weekButtonView.frame = CGRectMake(0, 0, (self.frame.size.width - HQLTitleViewWidth), HQLWeekModeHeight);
            
            break;
        }
        case HQLLocalNotificationMonthRepeat: { // 每月
            frame.size.height = HQLFixedHeight + HQLEveryMonthModeHeight;
            titleLabelFrame.origin.y = (HQLEveryMonthModeHeight - titleLabelFrame.size.height) * 0.5;
            
            self.dayChooseFlowLayout.itemSize = CGSizeMake(HQLDateButtonSize, HQLDateButtonSize);
            self.dayChooseView.frame = CGRectMake(0, 0, (self.frame.size.width - HQLTitleViewWidth), HQLEveryMonthModeHeight);
            [self.dayChooseView reloadData];
            
            break;
        }
        case HQLLocalNotificationNoneRepeat: { // 不重复
            frame.size.height = HQLFixedHeight + HQLNotRepeatModeHeight;
            titleLabelFrame.origin.y = (HQLNotRepeatModeHeight - titleLabelFrame.size.height) * 0.5;
            
            // 还要刷新两个button的frame
            CGFloat margin = 5;
            CGFloat width = 30;
            CGFloat height = 28;
            CGFloat buttonX = (HQLTitleViewWidth - width) * 0.5;
            CGFloat lastButtonY = CGRectGetMinY(titleLabelFrame) - margin - height;
            CGFloat nextButtonY = CGRectGetMaxY(titleLabelFrame) + margin;
            self.lastMonth.frame = CGRectMake(buttonX, lastButtonY, width, height);
            self.nextMonth.frame = CGRectMake(buttonX, nextButtonY, width, height);
            
            self.calendarView.frame = CGRectMake(0, 0, (self.frame.size.width - HQLTitleViewWidth), HQLNotRepeatModeHeight);
            [self updateCalendarViewsFrame]; // 更新日历的frame
            
            break;
        }
        default: {
            frame.size.height = HQLFixedHeight;
            break;
        }
    }
    
    self.frame = frame;
    self.titleLabel.frame = titleLabelFrame;
    
    if ([self.delegate respondsToSelector:@selector(setNotificationViewDidChangeFrame:)]) {
        [self.delegate setNotificationViewDidChangeFrame:self];
    }
}

// 更新在不重复模式下的title
- (void)updateNotRepeatModeTitle {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:self.currentMonth];
    NSInteger year = [calendar component:NSCalendarUnitYear fromDate:self.currentMonth];
    self.titleLabel.text = [NSString stringWithFormat:@"%ld\n%ld月", year, month];
}

// 模式按钮点击
- (IBAction)modeButtonDidClick:(HQLSelectButton *)sender {
    [self endEditing:YES];
    
    // 取消button的选择
    for (UIView *view in self.modeButtonView.subviews) {
        if ([view isKindOfClass:[HQLSelectButton class]]) {
            HQLSelectButton *button = (HQLSelectButton *)view;
            [button setSelected:NO];
        }
    }
    
    [sender setSelected:!sender.isSelected];
    
    [self.weekButtonView setHidden:YES];
    [self.dayChooseView setHidden:YES];
    [self.calendarView setHidden:YES];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    switch (sender.tag) {
        case HQLEveryDayButtonTag: // 每日按钮
        case HQLWorkDayButtonTag: // 工作日按钮
        case HQLWeekendButtonTag: { // 休息日按钮
            if (sender.tag == HQLEveryDayButtonTag) {
                self.currentRepeat = HQLLocalNotificationDayRepeat;
            } else {
                self.currentRepeat = HQLLocalNotificationWeekRepeat;
            }
            self.currentMode = HQLLocalNotificationAlarmMode; // 默认闹钟模式
            self.titleLabel.text = @"星期";
            
            // 创建buttons
            if (self.weekButtonArray.count == 0) {
                [self createWeekButtons];
            } else {
                [self.weekButtonArray enumerateObjectsUsingBlock:^(HQLSelectButton *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.selected = NO;
                }];
            }
            // 清除currentSelectedDate
            [self.currentDateArray removeAllObjects];
            // 根据三种情况 设置date
            if (sender.tag == HQLEveryDayButtonTag) {
                // 每天
                [self.currentDateArray addObject:[NSDate date]];
                [self.weekButtonArray enumerateObjectsUsingBlock:^(HQLSelectButton *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.selected = YES;
                }];
            } else {
                if (sender.tag == HQLWorkDayButtonTag) {
                    for (int i = 2; i <= 6; i++) {
                        [self.currentDateArray addObject:[HQLLocalNotificationConfig getWeekdayDateWithWeekday:i]];
                    }
                } else if (sender.tag == HQLWeekendButtonTag) {
                    [self.currentDateArray addObject:[HQLLocalNotificationConfig getWeekdayDateWithWeekday:1]];
                    [self.currentDateArray addObject:[HQLLocalNotificationConfig getWeekdayDateWithWeekday:7]];
                }
                
                for (NSDate *date in self.currentDateArray) {
                    NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date];
                    HQLSelectButton *button = self.weekButtonArray[weekday - 1];
                    [button setSelected:YES];
                }
            }
            
            [self.weekButtonView setHidden:NO];
            
            break;
        }
        case HQLEveryMonthButtonTag: { // 每月按钮
            // 判断当前的repeat模式是否是每月重复
            if (self.currentRepeat != HQLLocalNotificationMonthRepeat) {
                // 清除已选择日期
                [self.currentDateArray removeAllObjects];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                for (HQLDayChooseModel *model in self.dayChooseDataSource) { // 设置已选择的日期
                    if (model.isSelected) {
                        NSDateComponents *component = [[NSDateComponents alloc] init];
                        component.year = 2017;
                        component.month = 5;
                        component.day = model.day;
                        [self.currentDateArray addObject:[calendar dateFromComponents:component]];
                    }
                }
            }
            self.currentRepeat = HQLLocalNotificationMonthRepeat;
            self.currentMode = HQLLocalNotificationScheduleMode;
            self.titleLabel.text = @"日期";
            
            [self.dayChooseView setHidden:NO];
            
            break;
        }
        case HQLNotRepeatButtonTag: { // 不重复按钮
            
            if (self.currentRepeat != HQLLocalNotificationNoneRepeat) {
                [self.currentDateArray removeAllObjects];
                for (HQLCalendarView *view in self.calendarViewArray) {
                    for (HQLDateModel *date in [view currentSelectDateArray]) { // 更新日期
                        [self.currentDateArray addObject:[date changeToNSDate]];
                    }
                }
            }
            
            if (self.calendarViewArray.count == 0) {
                [self createCalendarViews];
            }
            
            self.currentRepeat = HQLLocalNotificationNoneRepeat;
            self.currentMode = HQLLocalNotificationScheduleMode;
            [self updateNotRepeatModeTitle];
            [self.calendarView setHidden:NO];
            
            break;
        }
        default: { break; }
    }
    // 更新信息
    [self updateNotificationDateInfo];
    // 更新frame
    [self updateFrame];
}

- (void)createWeekButtons {
    [self.weekButtonArray removeAllObjects];
    for (int i = 1; i <= 7; i++) {
        HQLSelectButton *button = [HQLSelectButton buttonWithType:UIButtonTypeCustom];
        if (i == 1 || i == 7) {
            [button setTitleColor:[UIColor colorWithRed:0 green:(211 / 255.0) blue:(211 / 255.0) alpha:1] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor colorWithRed:(10 / 255.0) green:(40 / 255.0) blue:(80 / 255.0) alpha:1] forState:UIControlStateNormal];
        }
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        button.defaultMode = HQLGeometricShapeNone;
        button.selectedMode = HQLGeometricShapeCircularRing;
        button.selectedShapeColor = [UIColor colorWithRed:0 green:(211 / 255.0) blue:(211 / 255.0) alpha:1];
        
        [button setTitle:[self getWeekdayChineseWithInteger:i] forState:UIControlStateNormal];
        
        [self.weekButtonView addSubview:button];
        [self.weekButtonArray addObject:button];
    }
}

- (NSString *)getWeekdayChineseWithInteger:(NSInteger)integer {
    switch (integer) {
        case 1: return @"日";
        case 2: return @"一";
        case 3: return @"二";
        case 4: return @"三";
        case 5: return @"四";
        case 6: return @"五";
        case 7: return @"六";
        default: return @"";
    }
}

// 更新日历的frame
- (void)updateCalendarViewsFrame {
    CGFloat width = self.frame.size.width - HQLTitleViewWidth;
    HQLCalendarView *lastView = nil;
    NSInteger index = 0;
    for (HQLCalendarView *view in self.calendarViewArray) {
        CGFloat sign = index == 0 ? -HQLNotRepeatModeHeight : (index == 1 ? 0 : HQLNotRepeatModeHeight);
        view.alpha = (index == 1 ? 1 : 0);
        view.frame = CGRectMake(0, (CGRectGetMaxY(lastView.frame) + sign), width, HQLNotRepeatModeHeight);
        lastView = view;
        index++;
    }
}

// 创建日历
- (void)createCalendarViews {
    CGFloat width = self.frame.size.width - HQLTitleViewWidth;
    for (int i = 0; i < 3; i++) {
        NSDate *month = self.currentMonth;
        if (i == 0) {
            month = [HQLLocalNotificationConfig getPriusDateFromDate:month withMonth:-1];
        } else if (i == 2) {
            month = [HQLLocalNotificationConfig getPriusDateFromDate:month withMonth:1];
        }
        HQLCalendarView *calendar = [[HQLCalendarView alloc] initWithFrame:CGRectMake(0, 0, width, HQLNotRepeatModeHeight) dateModel:[[HQLDateModel alloc] initwithNSDate:month]];
        calendar.delegate = self;
        calendar.hideHeaderView = YES;
        calendar.allowSelectedMultiDate = YES;
        calendar.allowSelectedFutureDate = YES;
        calendar.allowSelectedPassedDate = NO;
        calendar.cellTintColor = [UIColor colorWithRed:0 green:(211 / 255.0) blue:(211 / 255.0) alpha:1];
        
        // 设置已选择日期
        for (NSDate *date in self.currentDateArray) {
            // 判断date的month是否等于calendar显示的月份
            HQLDateModel *targetDate = [[HQLDateModel alloc] initwithNSDate:date];
            if (targetDate.month == calendar.dateModel.month) {
                [calendar selectDate:targetDate isTriggerDelegate:NO];
            }
        }
        
        [self.calendarView addSubview:calendar];
        [self.calendarViewArray addObject:calendar];
    }
}

// 上一月 或 下一月
- (void)lastOrNextMonthDidClick:(UIButton *)button {
    if (self.calendarViewArray.count != 3) return;
    BOOL isLastMonth = button.tag == HQLLastMonthButtontTag;
    
    self.currentMonth = [HQLLocalNotificationConfig getPriusDateFromDate:self.currentMonth withMonth:(isLastMonth ? -1 : 1)];
    [self updateNotRepeatModeTitle];
    
    HQLCalendarView *moveView = self.calendarViewArray[(isLastMonth ? 2 : 0)];
    [self.calendarViewArray removeObject:moveView];
    [self.calendarViewArray insertObject:moveView atIndex:(isLastMonth ? 0 : 2)];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf updateCalendarViewsFrame];
    } completion:^(BOOL finished) {
        [moveView setDateModel:[[HQLDateModel alloc] initwithNSDate:[HQLLocalNotificationConfig getPriusDateFromDate:weakSelf.currentMonth withMonth:(isLastMonth ? -1 : 1)]]];
        for (NSDate *date in weakSelf.currentDateArray) {
            // 判断date的month是否等于calendar显示的月份
            HQLDateModel *targetDate = [[HQLDateModel alloc] initwithNSDate:date];
            if (targetDate.month == moveView.dateModel.month) {
                [moveView selectDate:targetDate isTriggerDelegate:NO];
            }
        }
    }];
}

// 获取当前选中日期数组的date
- (NSDate *)getDateFromCurrentRepeatDateArray:(NSDate *)date {
    NSDate *targetDate = nil;
    for (NSDate *selectDate in self.currentDateArray) {
        HQLDateModel *selectDateModel = [[HQLDateModel alloc] initwithNSDate:selectDate];
        HQLDateModel *dateModel = [[HQLDateModel alloc] initwithNSDate:date];
        if ([selectDateModel compareWithHQLDateWithOutTime:dateModel] == 0) {
            targetDate = selectDate;
            break;
        }
    }
    return targetDate;
}

// 改变了时刻
- (IBAction)timePickerValueChanged:(UIDatePicker *)sender {
    [self endEditing:YES];
    [self updateNotificationDateInfo];
}

// 获取当前的model
- (HQLLocalNotificationModel *)getCurrentNotificationModel {
    HQLLocalNotificationModel *targetModel = [[HQLLocalNotificationModel alloc] initWithModel:self.notificationModel];
    targetModel.content.alertTitle = self.notificationAlertTitle;
    targetModel.content.alertBody = [self.notificationContentTextField.text isEqualToString:@""] ? @"自定义名称" : self.notificationContentTextField.text;
    targetModel.repeatMode = self.currentRepeat;
    targetModel.notificationMode = self.currentMode;
    
    NSMutableArray *array = [NSMutableArray array];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *time = self.notificationTimePicker.date;
    NSDateComponents *timeComponent = [calendar components:NSCalendarUnitHour |
                                                                                                          NSCalendarUnitMinute
                                                                                                          fromDate:time]; // 获取time
    for (NSDate *date in self.currentDateArray) {
        NSDateComponents *dateComponent = [calendar components:NSCalendarUnitYear |
                                                                                                              NSCalendarUnitMonth |
                                                                                                              NSCalendarUnitDay |
                                                                                                              NSCalendarUnitWeekday
                                                                                                              fromDate:date];
        dateComponent.hour = timeComponent.hour;
        dateComponent.minute = timeComponent.minute;
        [array addObject:[calendar dateFromComponents:dateComponent]];
    }
    targetModel.repeatDateArray = [NSArray arrayWithArray:array];
    
    return targetModel;
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - calendar view delegate

- (void)calendarView:(HQLCalendarView *)calendarView selectionStyle:(HQLCalendarViewSelectionStyle)style beginDate:(HQLDateModel *)begin endDate:(HQLDateModel *)end {
    // 先判断当前时候有该日期
    NSDate *targetDate = [begin changeToNSDate];
    NSDate *currentDate = [self getDateFromCurrentRepeatDateArray:targetDate];
    if (currentDate) { // 已存在
        [self.currentDateArray removeObject:currentDate];
    } else {
        [self.currentDateArray addObject:targetDate];
    }
    [self updateNotificationDateInfo];
}

#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HQLDayChooseModel *model = self.dayChooseDataSource[indexPath.item];
    model.isSelected = !model.isSelected;
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (model.isSelected) { // 选中
        NSDateComponents * components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth  fromDate:[NSDate date]];
        components.month = 5;
        components.day = model.day;
        [self.currentDateArray addObject:[calendar dateFromComponents:components]];
    } else {
        NSDate *deleteDate = nil;
        for (NSDate *date in self.currentDateArray) {
            NSInteger day = [calendar component:NSCalendarUnitDay fromDate:date];
            if (day == model.day) {
                deleteDate = date;
            }
        }
        if (deleteDate) {
            [self.currentDateArray removeObject:deleteDate];
        }
    }
    
    // 更新信息
    [self updateNotificationDateInfo];
}

#pragma mark - collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 31;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HQLDayChooseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HQLDayChooseCellReuseID forIndexPath:indexPath];
    cell.model = self.dayChooseDataSource[indexPath.item];
    return cell;
}

#pragma mark - setter

- (void)setNotificationModel:(HQLLocalNotificationModel *)notificationModel {
    _notificationModel = notificationModel;
    // 根据model设置View
    HQLLocalNotificationContentModel *contentModel = notificationModel.content;
    
    // 设置模式
    self.currentMode = notificationModel.notificationMode;
    self.currentRepeat = notificationModel.repeatMode;
    
    // 内容
    self.notificationContentTextField.text = contentModel.alertBody;
    [self.currentDateArray removeAllObjects]; // 选择的日期
    [self.currentDateArray addObjectsFromArray:notificationModel.repeatDateArray];
    if (self.currentDateArray.count != 0) {
        self.currentMonth = self.currentDateArray.firstObject;
    }
    [self.notificationTimePicker setDate:notificationModel.repeatDateArray.firstObject]; // 选择的时刻
    [self updateNotificationDateInfo]; // 更新内容
    
    // 根据repeatModel 点击对应的按钮
    switch (notificationModel.repeatMode) {
        case HQLLocalNotificationDayRepeat: {
            [self modeButtonDidClick:self.everydayButton];
            break;
        }
        case HQLLocalNotificationWeekRepeat: {
            switch ([notificationModel getModelWeekMode]) {
                case HQLWorkDay: {
                    [self modeButtonDidClick:self.workdayButton];
                    break;
                }
                case HQLWeekEnd: {
                    [self modeButtonDidClick:self.weekendButton];
                    break;
                }
                case HQLWeekday: {
                    [self modeButtonDidClick:self.everydayButton];
                    break;
                }
            }
            break;
        }
        case HQLLocalNotificationMonthRepeat: {
            [self modeButtonDidClick:self.everymonthButton];
            break;
        }
        case HQLLocalNotificationNoneRepeat: {
            [self modeButtonDidClick:self.notRepeatButton];
            break;
        }
        case HQLLocalNotificationYearRepeat: { break; }
    }
}

#pragma mark - getter

- (UIView *)calendarView {
    if (!_calendarView) {
        _calendarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _calendarView.clipsToBounds = YES;
        _calendarView.backgroundColor = [UIColor clearColor];
        
        [self.notificationDateSettingView insertSubview:_calendarView atIndex:0];
    }
    return _calendarView;
}

- (UICollectionView *)dayChooseView {
    if (!_dayChooseView) {
        _dayChooseView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - HQLTitleViewWidth, HQLEveryMonthModeHeight) collectionViewLayout:self.dayChooseFlowLayout];
        _dayChooseView.backgroundColor = [UIColor clearColor];
        
        [_dayChooseView setShowsVerticalScrollIndicator:NO];
        [_dayChooseView setShowsHorizontalScrollIndicator:NO];
        _dayChooseView.delegate = self;
        _dayChooseView.dataSource = self;
        _dayChooseView.hidden = YES;
        
        [_dayChooseView registerClass:[HQLDayChooseCell class] forCellWithReuseIdentifier:HQLDayChooseCellReuseID];
        
        [self.notificationDateSettingView addSubview:_dayChooseView];
    }
    return _dayChooseView;
}

- (UICollectionViewFlowLayout *)dayChooseFlowLayout {
    if (!_dayChooseFlowLayout) {
        _dayChooseFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _dayChooseFlowLayout.minimumLineSpacing = 0;
        _dayChooseFlowLayout.minimumInteritemSpacing = 0;
        _dayChooseFlowLayout.itemSize = CGSizeMake(HQLDateButtonSize, HQLDateButtonSize);
    }
    return _dayChooseFlowLayout;
}

- (UIView *)weekButtonView {
    if (!_weekButtonView) {
        _weekButtonView = [[UIView alloc] initWithFrame:self.notificationDateSettingView.bounds];
        [_weekButtonView setHidden:YES];
        [_weekendButton setBackgroundColor:[UIColor clearColor]];
        [self.notificationDateSettingView addSubview:_weekButtonView];
    }
    return _weekButtonView;
}

- (NSDate *)currentMonth {
    if (!_currentMonth) {
        _currentMonth = [NSDate date];
    }
    return _currentMonth;
}

- (UIButton *)lastMonth {
    if (!_lastMonth) {
        _lastMonth = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lastMonth setFrame:CGRectMake(0, 0, 15, 14)];
        [_lastMonth setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-lastMonth" ofType:@"png"]] forState:UIControlStateNormal];
        [_lastMonth setHidden:YES];
        _lastMonth.tag = HQLLastMonthButtontTag;
        
        [_lastMonth addTarget:self action:@selector(lastOrNextMonthDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.notificationDateSettingTitleView addSubview:_lastMonth];
    }
    return _lastMonth;
}

- (UIButton *)nextMonth {
    if (!_nextMonth) {
        _nextMonth = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextMonth setFrame:CGRectMake(0, 0, 15, 14)];
        [_nextMonth setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-nextMonth" ofType:@"png"]] forState:UIControlStateNormal];
        [_nextMonth setHidden:YES];
        _nextMonth.tag = HQLNextMonthButtonTag;
        
        [_nextMonth addTarget:self action:@selector(lastOrNextMonthDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.notificationDateSettingTitleView addSubview:_nextMonth];
    }
    return _nextMonth;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor colorWithRed:(10 / 255.0) green:(40 / 255.0) blue:(80 / 255.0) alpha:1]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        _titleLabel.numberOfLines = 0;
        
        [self.notificationDateSettingTitleView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (NSMutableArray<HQLDayChooseModel *> *)dayChooseDataSource {
    if (!_dayChooseDataSource) {
        _dayChooseDataSource = [NSMutableArray array];
        for (int i = 1; i <= 31; i++) {
            HQLDayChooseModel *model = [[HQLDayChooseModel alloc] init];
            model.day = i;
            model.isSelected = NO;
            [_dayChooseDataSource addObject:model];
        }
    }
    return _dayChooseDataSource;
}

- (NSMutableArray<HQLCalendarView *> *)calendarViewArray {
    if (!_calendarViewArray) {
        _calendarViewArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _calendarViewArray;
}

- (NSMutableArray *)weekButtonArray {
    if (!_weekButtonArray) {
        _weekButtonArray = [NSMutableArray arrayWithCapacity:7];
    }
    return _weekButtonArray;
}

- (NSMutableArray *)currentDateArray {
    if (!_currentDateArray) {
        _currentDateArray = [NSMutableArray array];
    }
    return _currentDateArray;
}

@end

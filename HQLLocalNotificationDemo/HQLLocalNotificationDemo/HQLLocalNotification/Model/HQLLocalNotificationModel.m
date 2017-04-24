//
//  HQLLocalNotificationModel.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/18.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationModel.h"

@implementation HQLLocalNotificationModel

/*- (instancetype)initWithDate:(NSDate *)date content:(HQLLocalNotificationContentModel *)content repeatDateArray:(NSArray *)repeatDateArray identifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier repeatMode:(HQLLocalNotificationRepeat)repeatMode isRepeat:(BOOL)isRepeat {
    if (self = [super init]) {
        self.date = date;
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identifier = identifier;
        self.subIdentifier = subIdentifier;
        self.repeatMode = repeatMode;
        self.isRepeat = isRepeat;
    }
    return self;
}
- (nullable instancetype)initContent:(nonnull HQLLocalNotificationContentModel *)content repeatDateArray:(nonnull NSArray *)repeatDateArray identifier:(nonnull NSString *)identifier subIdentifier:(nonnull NSString *)subIdentifier repeatMode:(HQLLocalNotificationRepeat)repeatMode isRepeat:(BOOL)isRepeat {
    if (self = [super init]) {
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identifier = identifier;
        self.subIdentifier = subIdentifier;
        self.repeatMode = repeatMode;
        self.isRepeat = isRepeat;
    }
    return self;
}*/

- (instancetype)init {
    if (self = [super init]) {
        self.content = [[HQLLocalNotificationContentModel alloc] init];
        self.repeatDateArray = [NSArray array];
        self.identifier = @"";
        self.subIdentifier = @"";
        self.repeatMode = HQLLocalNotificationNoneRepeat;
        self.isActivity = NO;
    }
    return self;
}

- (nullable instancetype)initContent:(nonnull HQLLocalNotificationContentModel *)content
                                      repeatDateArray:(nonnull NSArray *)repeatDateArray
                                      identifier:(nonnull NSString *)identifier
                                      subIdentifier:(nonnull NSString *)subIdentifier
                                      repeatMode:(HQLLocalNotificationRepeat)repeatMode
                                      notificationMode:(HQLLocalNotificationMode)notificationMode
                                      isActivity:(BOOL)isActivity
{
    if (self = [self init]) {
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identifier = identifier;
        self.subIdentifier = subIdentifier;
        self.repeatMode = repeatMode;
        self.notificationMode = notificationMode;
        self.isActivity = isActivity;
    }
    return self;
}

- (instancetype)initWithModel:(HQLLocalNotificationModel *)model {
    if (self = [self init]) {
        self.content = [[HQLLocalNotificationContentModel alloc] initWithModel:model.content];
        self.repeatDateArray = [NSMutableArray arrayWithArray:model.repeatDateArray];
        self.identifier = model.identifier;
        self.subIdentifier = model.subIdentifier;
        self.repeatMode = model.repeatMode;
        self.notificationMode = model.notificationMode;
        self.isActivity = model.isActivity;
    }
    return self;
}

+ (instancetype)localNotificationModel {
    HQLLocalNotificationModel *model = [[HQLLocalNotificationModel alloc] init];
    model.repeatDateArray = @[[NSDate date]];
    model.notificationMode = HQLLocalNotificationScheduleMode;
    return model;
}


#pragma mark - event

- (HQLWeekMode)getModelWeekMode {
    // 先从数量判断 --- 工作日5天 休息日2天 其他都是平日
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    
    NSMutableArray *weekArray = [NSMutableArray arrayWithArray:@[@1, @2, @3, @4, @5, @6, @7]]; // 记录一周七天
    for (NSDate *date in self.repeatDateArray) {
        NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date]; // 数字只会是1-7
        if ([weekArray[weekday - 1] isEqual:@0] ) {
            // 表示已经有相同的 星期 来过
            return HQLWeekday;
        } else {
            weekArray[weekday - 1] = @0; // 来过的标识
        }
    }
    // 判断 只有两种情况是值得提示的
    NSArray *weekendArray = @[@0, @2, @3, @4, @5, @6, @0];
    NSArray *workdayArray = @[@1, @0, @0, @0, @0, @0, @7];
    if ([self compareArray:weekendArray ortherArray:weekArray]) {
        return HQLWeekEnd;
    } else if ([self compareArray:workdayArray ortherArray:weekArray]) {
        return HQLWorkDay;
    } else {
        return HQLWeekday;
    }
}

- (BOOL)compareArray:(NSArray *)array ortherArray:(NSArray *)otherArray {
    // 比较两个array
    if (array.count != otherArray.count) {
        return NO;
    } else {
        if (![array.firstObject isKindOfClass:[NSNumber class]]) {
            return NO;
        }
        for (int i = 0; i < array.count; i++) {
            NSNumber *num = array[i];
            NSNumber *otherNum = otherArray[i];
            if ([num compare:otherNum] != NSOrderedSame ) {
                return NO;
            }
        }
        return YES;
    }
}

- (NSString *)getModelDateDescription {
    NSString *targetString = @"";
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    switch (self.repeatMode) {
        case HQLLocalNotificationDayRepeat: { // 每日
            targetString = @"每天";
            break;
        }
        case HQLLocalNotificationWeekRepeat: { // 每周
            switch ([self getModelWeekMode]) {
                case HQLWeekday: {
                    // 平时
                    NSInteger index = 0;
                    for (NSDate *date in self.repeatDateArray) {
                        if (index == 0) {
                            targetString = [targetString stringByAppendingString:@"周 "];
                        }
                        NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date];
                        targetString = [targetString stringByAppendingString:[NSString stringWithFormat:@"%@ ", [self getWeekdayChineseWithInteger:weekday]]];
                        index++;
                    }
                    break;
                }
                case HQLWorkDay: {
                    // 工作日
                    targetString = @"工作日";
                    break;
                }
                case HQLWeekEnd: {
                    // 休息日
                    targetString = @"休息日";
                    break;
                }
            }
            break;
        }
        case HQLLocalNotificationMonthRepeat: { // 每月
            NSInteger index = 0;
            for (NSDate *date in self.repeatDateArray) {
                if (index == 0) {
                    targetString = [targetString stringByAppendingString:@"每月 "];
                }
                NSInteger weekday = [calendar component:NSCalendarUnitDay fromDate:date];
                targetString = [targetString stringByAppendingString:[NSString stringWithFormat:@"%ld号 ", weekday]];
                index++;
            }
            break;
        }
        case HQLLocalNotificationNoneRepeat: { // 不重复
            if (self.notificationMode == HQLLocalNotificationScheduleMode) { // 日程模式
                
            } else if (self.notificationMode == HQLLocalNotificationAlarmMode) { // 闹钟模式
            
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy.MM.dd"];
            for (NSDate *date in self.repeatDateArray) {
                targetString = [targetString stringByAppendingString:[NSString stringWithFormat:@"%@ ", [formatter stringFromDate:date]]];
            }
            break;
        }
        case HQLLocalNotificationYearRepeat: { // 每年重复
            NSInteger index = 0;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM月dd日"];
            for (NSDate *date in self.repeatDateArray) {
                if (index == 0) {
                    targetString = [targetString stringByAppendingString:@"每年"];
                }
                targetString = [targetString stringByAppendingString:[formatter stringFromDate:date]];
                index++;
            }
            break;
        }
    }
    return targetString;
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

#pragma mark - NSCodeing delegate

- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.repeatDateArray forKey:@"repeatDateArray"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.subIdentifier forKey:@"subIdentifier"];
    [aCoder encodeInteger:self.repeatMode forKey:@"repeatMode"];
//    [aCoder encodeBool:self.isRepeat forKey:@"isRepeat"];
    [aCoder encodeInteger:self.notificationMode forKey:@"notificationMode"];
    [aCoder encodeBool:self.isActivity forKey:@"isActivity"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self.date = [aDecoder decodeObjectForKey:@"date"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.repeatDateArray = [aDecoder decodeObjectForKey:@"repeatDateArray"];
    self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    self.subIdentifier = [aDecoder decodeObjectForKey:@"subIdentifier"];
    self.repeatMode = (HQLLocalNotificationRepeat)[aDecoder decodeIntegerForKey:@"repeatMode"];
//    self.isRepeat = [aDecoder decodeBoolForKey:@"isRepeat"];
    self.notificationMode = (HQLLocalNotificationMode)[aDecoder decodeIntegerForKey:@"notificationMode"];
    self.isActivity = [aDecoder decodeBoolForKey:@"isActivity"];
    return self;
}

#pragma mark - setter

- (void)setIdentifier:(NSString *)identifier {
    NSAssert([identifier rangeOfString:HQLLocalNotificationIdentifierLinkChar].location == NSNotFound, @"标识字符不能有已定义字符");
    _identifier = identifier;
}

- (void)setSubIdentifier:(NSString *)subIdentifier {
    NSAssert([subIdentifier rangeOfString:HQLLocalNotificationIdentifierLinkChar].location == NSNotFound, @"标识字符不能有已定义字符");
    _subIdentifier = subIdentifier;
}

@end

#pragma mark - local notification content

@implementation HQLLocalNotificationContentModel

- (instancetype)init {
    if (self = [super init]) {
        self.alertBody = @"";
        self.alertAction = @"";
        self.alertLaunchImage = @"";
        self.alertTitle = @"";
        self.soundName = @"";
        self.applicationIconBadgeNumber = 0;
        self.userInfo = [NSDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithModel:(HQLLocalNotificationContentModel *)model {
    if (self = [self init]) {
        self.alertBody = model.alertBody;
        self.alertAction = model.alertAction;
        self.alertLaunchImage = model.alertLaunchImage;
        self.alertTitle = model.alertTitle;
        self.soundName = model.soundName;
        self.applicationIconBadgeNumber = model.applicationIconBadgeNumber;
        self.userInfo = [NSDictionary dictionaryWithDictionary:model.userInfo];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.alertBody forKey:@"alertBody"];
    [aCoder encodeObject:self.alertAction forKey:@"alertAction"];
    [aCoder encodeObject:self.alertLaunchImage forKey:@"alertLaunchImage"];
    [aCoder encodeObject:self.alertTitle forKey:@"alertTitle"];
    [aCoder encodeObject:self.soundName forKey:@"soundName"];
    [aCoder encodeInteger:self.applicationIconBadgeNumber forKey:@"applicationIconBadgeNumber"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.alertBody = [aDecoder decodeObjectForKey:@"alertBody"];
    self.alertAction = [aDecoder decodeObjectForKey:@"alertAction"];
    self.alertLaunchImage = [aDecoder decodeObjectForKey:@"alertLaunchImage"];
    self.alertTitle = [aDecoder decodeObjectForKey:@"alertTitle"];
    self.soundName = [aDecoder decodeObjectForKey:@"soundName"];
    self.applicationIconBadgeNumber = [aDecoder decodeIntegerForKey:@"applicationIconBadgeNumber"];
    self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    return self;
}


@end

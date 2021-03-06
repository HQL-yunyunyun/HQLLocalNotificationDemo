//
//  HQLLocalNotificationConfig.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationConfig.h"
#import "HQLLocalNotificationModel.h"

// 所有的通知的userInfo都将添加这个key,用来标识区分别的通知
#define HQLNotificationsDefaultIdentifier @"HQLNotificationsDefaultIdentifier"

@implementation HQLLocalNotificationConfig

#pragma mark - authorization method

// 通知授权
+ (void)replyNotificationAuthorization:(UIApplication *)application iOS10NotificationDelegate:(id <UNUserNotificationCenterDelegate>)notificationDelegate successComplete:(void(^)(BOOL isFirstGranted))successComplete failureComplete:(void(^)(BOOL isFirstGranted))failureComplete {
    // 每一个版本的系统的通知授权都有一点改变
    if (iOS10_OR_LATER) { // iOS 10 以后的版本
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        if (notificationDelegate) {
            center.delegate = notificationDelegate;
        }
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            // 获取授权状态
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) { // 第一次授权
                [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge |
                                                                                  UNAuthorizationOptionSound |
                                                                                  UNAuthorizationOptionAlert
                            completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                if (!error && granted) { // 同意授权
                                    NSLog(@"授权成功.");
                                    if (successComplete) {
                                        successComplete(YES);
                                    }
                                } else { // 授权失败 --- 弹框
                                    NSLog(@"授权失败,如果想开启通知,请到系统设置下更改.");
                                    if (failureComplete) {
                                        failureComplete(NO);
                                    }
                                }
                            }];
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) { // 用户设置成不可通知
                NSLog(@"如果想开启通知,请到系统设置下更改.");
                if (failureComplete) {
                    failureComplete(NO);
                }
            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) { // 用户允许通知
                NSLog(@"用户允许通知");
                if (successComplete) {
                    successComplete(NO);
                }
            }
        }];
    } else if (iOS8_OR_LATER) { // iOS 8 以后的版本
        UIUserNotificationSettings *settings = [application currentUserNotificationSettings];
        if (settings.types == UIUserNotificationTypeNone) { // 用户设置成禁用通知,或第一次设置
            settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge |
                                                                                                     UIUserNotificationTypeSound |
                                                                                                     UIUserNotificationTypeAlert
                                                                                                     categories:nil];
            [application registerUserNotificationSettings:settings];
        }
    } else { // iOS 8 一下的版本
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                                                      UIRemoteNotificationTypeSound |
                                                                                      UIRemoteNotificationTypeAlert];
    }
    
    /* 
    // 远程推送授权
    if (iOS8_OR_LATER) {
        if (!application.isRegisteredForRemoteNotifications) { // iOS 8 以后注册远程推送
            [application registerForRemoteNotifications]; // 注册远程推送
        }
    }*/
}

#pragma mark - method 

// 添加通知
+ (void)addLocalNotificationWithModel:(HQLLocalNotificationModel *)model completeBlock:(void(^)(NSError *error))completeBlock{
    
    // 首先 -> 判断是否可以启用, 如果是日程模式,且不循环,则如果日期都已经过去了,则不启用 isActivity = NO
    if (model.isActivity) {
        if (model.repeatMode == HQLLocalNotificationNoneRepeat) { // 不重复都有两种状态
            if (model.notificationMode == HQLLocalNotificationScheduleMode) { // 日程状态
                for (NSDate *date in model.repeatDateArray) {
                    if ([date compare:[NSDate date]] == NSOrderedDescending) { // 日期大于现在
                        model.isActivity = YES;
                        break;
                    } else {
                        model.isActivity = NO;
                    }
                }
            } else if (model.notificationMode == HQLLocalNotificationAlarmMode) { // 闹钟状态
                // 在这个状态下，只有一个时间
                if (model.repeatDateArray.count != 1) {
                    model.isActivity = NO;
                } else {
                    NSDate *date = model.repeatDateArray.firstObject;
                    if ([date compare:[NSDate date]] != NSOrderedDescending) { // 如果日期不大于显示时间
                        // 直接覆盖时间，改变触发日期
                        model.repeatDateArray = [NSArray arrayWithObject:[self getPriusDateFromDate:date withDay:1]];
                    }
                }
            }
        }
    } else { // 原本不启用,则不用管
        
    }
    
    if (model.isActivity) { // 启用的
        NSInteger index = 0;
        for (NSDate *date in model.repeatDateArray) {
            // iOS 10 新增了UserNotification类,该类与之前的通知都不一样
            NSString *identifier = [NSString stringWithFormat:@"%@%@%@%@%ld", model.identifier, HQLLocalNotificationIdentifierLinkChar, model.subIdentifier, HQLLocalNotificationIdentifierLinkChar, index];
            // 取消已存在的通知
            [self removeNotificationWithNotificationIdentifier:identifier];
            if (iOS10_OR_LATER) {
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                [center addNotificationRequest:[self setupUNNotificationRequestWithModel:model date:date identifier:identifier] withCompletionHandler:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"设置错误");
                    } else {
                        NSLog(@"设置成功");
                    }
                    if (completeBlock) {
                        completeBlock(error);
                    }
                }];
                
                [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
                    for (UNNotificationRequest *request in requests) {
                        NSLog(@"id : %@", request.identifier);
                    }
                }];
                
            } else {
                UIApplication *application = [UIApplication sharedApplication];
                [application scheduleLocalNotification:[self setupUILocalNotificationWithModel:model date:date identifier:identifier]];
//                [application presentLocalNotificationNow:[self setupUILocalNotificationWithModel:model date:date identifier:identifier]];
                if (completeBlock) {
                    completeBlock(nil); // 一定会成功
                }
            }
            index++;
        }
    } else { // 不启用
        if (completeBlock) {
            completeBlock([NSError errorWithDomain:HQLLocalNotificationErrorDomain code:HQLLocalNotificationNotActiveFailed userInfo:@{@"通知没有启用" : NSLocalizedDescriptionKey}]);
        }
    }
}

// 删除通知
+ (void)removeNotificationWithNotificationIdentifier:(NSString *)identifier {
    if (iOS10_OR_LATER) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removePendingNotificationRequestsWithIdentifiers:@[identifier]]; // 移除还没有
        [center removeDeliveredNotificationsWithIdentifiers:@[identifier]];
    } else {
        UIApplication *application = [UIApplication sharedApplication];
        UILocalNotification *targetNotification = nil;
        for (UILocalNotification *notification in [application scheduledLocalNotifications]) {
            if ([(NSString *)[notification.userInfo valueForKey:HQLUserInfoIdentifier] isEqualToString:identifier]) {
                targetNotification = notification;
                break; // 查找目标通知
            }
        }
        if (!targetNotification) {
            [application cancelLocalNotification:targetNotification]; // 取消通知
        }
    }
}

// 删除通知
+ (void)removeAllNotification {
    if (iOS10_OR_LATER) { // iOS10 以上
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        typeof(self) weakSelf = self;
        [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            NSMutableArray *deliveredArray = [NSMutableArray array];
            for (UNNotification *notification in notifications) {
                if ([weakSelf isHQLNotificationWithUserInfo:notification.request.content.userInfo]) {
                    [deliveredArray addObject:notification.request.identifier];
                }
            }
            [center removeDeliveredNotificationsWithIdentifiers:deliveredArray];
        }];
        
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            NSMutableArray *pendingArray = [NSMutableArray array];
            for (UNNotificationRequest *request in requests) {
                if ([weakSelf isHQLNotificationWithUserInfo:request.content.userInfo]) {
                    [pendingArray addObject:request.identifier];
                }
            }
            [center removePendingNotificationRequestsWithIdentifiers:pendingArray];
        }];
//        [center removeAllDeliveredNotifications]; // 移除已触发的通知
//        [center removeAllPendingNotificationRequests]; // 移除还没触发的通知
    } else { // iOS10 以下
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *notifications = [app scheduledLocalNotifications];
        for (UILocalNotification *notification in notifications) {
            if ([self isHQLNotificationWithUserInfo:notification.userInfo]) {
                [app cancelLocalNotification:notification];
            }
        }
    }
}

// 根据userInfo判断是否是自定义的通知
+ (BOOL)isHQLNotificationWithUserInfo:(NSDictionary *)userInfo {
    for (NSString *key in userInfo.allKeys) {
        if ([key isEqualToString:HQLNotificationsDefaultIdentifier]) {
            if ([userInfo[key] isEqualToString:HQLNotificationsDefaultIdentifier]) {
                return YES;
            }
        }
    }
    return NO;
}

// 获取前后日期
+ (NSDate *)getPriusDateFromDate:(NSDate *)date withDay:(NSInteger)day {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    return mDate;
}

// 获取weekday
+ (NSDate *)getWeekdayDateWithWeekday:(NSInteger)weekday {
    if (weekday < 1 || weekday > 7) {
        return nil;
    }
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSInteger nowWeekday = [calendar component:NSCalendarUnitWeekday fromDate:nowDate];
    return [self getPriusDateFromDate:nowDate withDay:(weekday - nowWeekday)];
}

// 获取前后日期
+ (NSDate *)getPriusDateFromDate:(NSDate *)date withMonth:(NSInteger)month {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    return mDate;
}


#pragma mark - private method

// iOS10 以前的做法
+ (UILocalNotification *)setupUILocalNotificationWithModel:(HQLLocalNotificationModel *)model date:(NSDate *)date identifier:(NSString *)identifier {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = model.content.alertBody; // 主要内容
    notification.alertAction = model.content.alertAction; // 按钮
    notification.hasAction = YES;
    notification.alertTitle = model.content.alertTitle; // title
    notification.alertLaunchImage = model.content.alertLaunchImage; // 启动图片
    notification.applicationIconBadgeNumber = model.content.applicationIconBadgeNumber; // 角标
    if (![model.content.soundName isEqualToString:@""] && model.content.soundName && ![model.content.soundName isEqualToString:HQLLocalNotificationDefaultSoundName]) {
        notification.soundName = model.content.soundName; // 自定义声音 --- 路径
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName; // 默认声音
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (model.content.userInfo) {
        userInfo = [NSMutableDictionary dictionaryWithDictionary:model.content.userInfo];
    }
    [userInfo setValue:HQLNotificationsDefaultIdentifier forKey:HQLNotificationsDefaultIdentifier];
    [userInfo setValue:identifier forKey:HQLUserInfoIdentifier];
    notification.userInfo = userInfo; // userInfo
    
    switch (model.notificationMode) {
        case HQLLocalNotificationAlarmMode: { // 闹钟模式
            switch (model.repeatMode) {
                case HQLLocalNotificationNoneRepeat: { // 不重复
                    // 判断日期是否已经过了
                    NSComparisonResult result = [[NSDate date] compare:date];
                    if (result == NSOrderedAscending) { // 还没有过
                        notification.fireDate = date;
                    } else { // 已经过了
                        // 下一天的这个时刻
                        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                        NSDateComponents *moment = [calendar components:NSCalendarUnitHour |
                                                                                                                 NSCalendarUnitMinute
                                                                                                                 fromDate:date]; // 获取目标时刻
                        NSDateComponents *targetDay = [calendar components:NSCalendarUnitYear |
                                                                                                                    NSCalendarUnitMonth |
                                                                                                                    NSCalendarUnitDay
                                                                                                                    fromDate:[self getPriusDateFromDate:[NSDate date] withDay:1]]; // 获取下一天
                        targetDay.hour = moment.hour;
                        targetDay.minute = moment.minute;
                        
                        notification.fireDate = [calendar dateFromComponents:targetDay]; // 获取下一天的这个时刻
                    }
                    break;
                }
                case HQLLocalNotificationDayRepeat: { // 每日重复
                    notification.fireDate = date;
                    notification.repeatInterval = NSCalendarUnitDay;
                    break;
                }
                case HQLLocalNotificationWeekRepeat: {
                    notification.fireDate = date;
                    notification.repeatInterval = NSCalendarUnitWeekday;
                    break;
                }
                    // 这两种模式是 日程模式 独有
                case HQLLocalNotificationMonthRepeat: { break; }
                case HQLLocalNotificationYearRepeat: { break; }
                default: { break; }
            }
            break;
        }
        case HQLLocalNotificationScheduleMode: { // 日程模式
            switch (model.repeatMode) {
                case HQLLocalNotificationNoneRepeat: { // 不重复
                    NSComparisonResult result = [[NSDate date] compare:date];
                    if (result == NSOrderedAscending) { // 还没有过时间
                        notification.fireDate = date;
                    } else { // 日程模式下,如果时间过了,则不会添加到日程当中,但UI还是可以显示
                    
                    }
                    break;
                }
                case HQLLocalNotificationMonthRepeat: { // 每月重复
                    notification.fireDate = date;
                    notification.repeatInterval = NSCalendarUnitMonth;
                    break;
                }
                case HQLLocalNotificationYearRepeat: { // 每年重复
                    notification.fireDate = date;
                    notification.repeatInterval = NSCalendarUnitYear;
                    break;
                }
                    // 这两种模式是闹钟模式独有
                case HQLLocalNotificationDayRepeat: { break; }
                case HQLLocalNotificationWeekRepeat: { break; }
                default: { break; }
            }
            break;
        }
        default: { break; }
    }
    
    return notification;
}

// iOS10 以后的做法
+ (UNNotificationRequest *)setupUNNotificationRequestWithModel:(HQLLocalNotificationModel *)model date:(NSDate *)date identifier:(NSString *)identifier {
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.badge = @(model.content.applicationIconBadgeNumber); // 角标暂时为0
    content.body = model.content.alertBody; // 内容体
    content.launchImageName = model.content.alertLaunchImage; // 启动图片
    if (![model.content.soundName isEqualToString:@""] && model.content.soundName && ![model.content.soundName isEqualToString:HQLLocalNotificationDefaultSoundName]) {
        // 不为空
        content.sound = [UNNotificationSound soundNamed:model.content.soundName]; // 声音
    } else { // 为空,则默认声音
        content.sound = [UNNotificationSound defaultSound]; // 声音
    }
    content.title = model.content.alertTitle; // 标题
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (model.content.userInfo) {
        userInfo = [NSMutableDictionary dictionaryWithDictionary:model.content.userInfo];
    }
    [userInfo setValue:HQLNotificationsDefaultIdentifier forKey:HQLNotificationsDefaultIdentifier];
    [userInfo setValue:identifier forKey:HQLUserInfoIdentifier];
    content.userInfo = userInfo; // userInfo
    
    // 触发时机
    UNNotificationTrigger *trigger = nil;
    // 日历
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    
    // 判断模式
    switch (model.notificationMode) {
        case HQLLocalNotificationAlarmMode: { // 闹钟模式
            // 目标触发时机
            NSDateComponents *targetMoment = nil;
            BOOL isRepeat = NO;
            switch (model.repeatMode) {
                case HQLLocalNotificationNoneRepeat: { // 不循环
                    targetMoment = [calendar components:NSCalendarUnitHour |
                                                                                   NSCalendarUnitMinute
                                                                                   fromDate:date];
                    isRepeat = NO;
                    break;
                }
                case HQLLocalNotificationDayRepeat: { // 每日循环
                    targetMoment = [calendar components:NSCalendarUnitHour |
                                                                                   NSCalendarUnitMinute
                                                                                   fromDate:date];
                    isRepeat = YES;
                    break;
                }
                case HQLLocalNotificationWeekRepeat: { // 每周循环
                    targetMoment = [calendar components:NSCalendarUnitWeekday |
                                                                                   NSCalendarUnitHour |
                                                                                   NSCalendarUnitMinute
                                                                                   fromDate:date];
                    isRepeat = YES;
                    break;
                }
                    // 这两个是日程模式独有的
                case HQLLocalNotificationMonthRepeat: { break; }
                case HQLLocalNotificationYearRepeat: { break; }
                default: { break; }
            }
            trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:targetMoment repeats:isRepeat];
        break;
        }
        case HQLLocalNotificationScheduleMode: { // 日程模式
            NSDateComponents *targetMoment = nil;
            BOOL isRepeat = NO;
            switch (model.repeatMode) {
                case HQLLocalNotificationNoneRepeat: { // 不循环
                    targetMoment = [calendar components:NSCalendarUnitYear |
                                                                                   NSCalendarUnitMonth |
                                                                                   NSCalendarUnitDay |
                                                                                   NSCalendarUnitHour |
                                                                                   NSCalendarUnitMinute
                                                                                   fromDate:date];
                    isRepeat = NO;
                    break;
                }
                case HQLLocalNotificationMonthRepeat: { // 月循环
                    targetMoment = [calendar components:NSCalendarUnitDay |
                                                                                   NSCalendarUnitHour |
                                                                                   NSCalendarUnitMinute
                                                                                   fromDate:date];
                    isRepeat = YES;
                    break;
                }
                case HQLLocalNotificationYearRepeat: { // 年循环
                    targetMoment = [calendar components:NSCalendarUnitMonth |
                                                                                   NSCalendarUnitDay |
                                                                                   NSCalendarUnitHour |
                                                                                   NSCalendarUnitMinute
                                                                                   fromDate:date];
                    isRepeat = YES;
                    break;
                }
                    // 这两个是闹钟模式独有的
                case HQLLocalNotificationDayRepeat: { break; }
                case HQLLocalNotificationWeekRepeat: { break; }
                default: { break; }
            }
            trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:targetMoment repeats:isRepeat];
            break;
        }
        default: { break; }
    }
    
    return [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
}

/*- (void)test {
    NSComparisonResult result = [[NSDate date] compare:date];
    
    // 猜想 --- 直接赋值 xx时:xx分 并不重复
    if (result == NSOrderedAscending) { // 还没过时间
        targetMoment = [calendar components:NSCalendarUnitYear |
                        NSCalendarUnitMonth |
                        NSCalendarUnitDay |
                        NSCalendarUnitHour |
                        NSCalendarUnitMinute
                                   fromDate:date];
    } else {
        NSDateComponents *moment = [calendar components:NSCalendarUnitHour |
                                    NSCalendarUnitMinute
                                               fromDate:date]; // 获取时刻
        
        targetMoment = [calendar components:NSCalendarUnitYear |
                        NSCalendarUnitMonth |
                        NSCalendarUnitDay
                                   fromDate:[self getPriusDateFromDate:[NSDate date] withDay:1]]; // 目标日期
        targetMoment.hour = moment.hour;
        targetMoment.minute = moment.minute;
        
    }
    isRepeat = NO;
}*/

@end

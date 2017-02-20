//
//  HQLLocalNotificationConfig.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationConfig.h"
#import "HQLLocalNotificationModel.h"

@implementation HQLLocalNotificationConfig

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

+ (void)addLocalNotificationWithModel:(HQLLocalNotificationModel *)model {
    
    if (model.isActivity) {
        for (NSDate *date in model.repeatDateArray) {
            // iOS 10 新增了UserNotification类,该类与之前的通知都不一样
            if (iOS10_OR_LATER) {
                
            } else {
                
            }
        }
    }
}

+ (UNNotificationRequest *)setupUNNotificationRequestWithModel:(HQLLocalNotificationModel *)model date:(NSDate *)date identify:(NSString *)identify {
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.badge = @(model.content.applicationIconBadgeNumber); // 角标暂时为0
    content.body = model.content.alertBody; // 内容体
    content.launchImageName = model.content.alertLaunchImage; // 启动图片
    if (![model.content.soundName isEqualToString:@""] && !model.content.soundName) {
        // 不为空
        content.sound = [UNNotificationSound soundNamed:model.content.soundName]; // 声音
    } else { // 为空,则默认声音
        content.sound = [UNNotificationSound defaultSound]; // 声音
    }
    content.title = model.content.alertTitle; // 标题
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:model.content.userInfo]; //
    [userInfo setValue:identify forKey:HQLUserInfoIdentify];
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
                    targetMoment = [calendar components:NSCalendarUnitMonth |
                                                                                   NSCalendarUnitDay |
                                                                                   NSCalendarUnitHour |
                                                                                   NSCalendarUnitMinute
                                                                                   fromDate:date];
                    isRepeat = YES;
                    break;
                }
                case HQLLocalNotificationYearRepeat: { // 年循环
                    targetMoment = [calendar components:NSCalendarUnitYear |
                                                                                   NSCalendarUnitMonth |
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
    
    return [UNNotificationRequest requestWithIdentifier:identify content:content trigger:trigger];
}

+ (NSDate *)getPriusDateFromDate:(NSDate *)date withDay:(NSInteger)day {
    if (day < 1) {
        return date;
    }
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    return mDate;
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

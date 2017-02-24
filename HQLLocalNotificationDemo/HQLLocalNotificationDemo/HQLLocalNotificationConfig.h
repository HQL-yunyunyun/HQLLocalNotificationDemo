//
//  HQLLocalNotificationConfig.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define iOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define iOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define iOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define iOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define HQLUserInfoIdentifier @"HQLUserInfoIdentifier"

@class HQLLocalNotificationModel;

@interface HQLLocalNotificationConfig : NSObject

/**
 通知授权

 @param application application
 @param notificationDelegate iOS10版本以后,得遵守这个通知协议
 @param successComplete 授权成功后的调用(只有iOS10以后版本才有用)
 @param failureComplete 授权失败后的调用(iOS10以后版本才有用)
 */
+ (void)replyNotificationAuthorization:(UIApplication *)application iOS10NotificationDelegate:(id <UNUserNotificationCenterDelegate>)notificationDelegate successComplete:(void(^)(BOOL isFirstGranted))successComplete failureComplete:(void(^)(BOOL isFirstGranted))failureComplete;

/**
 添加通知

 @param model 通知组的配置
 @param completeBlock 只有在iOS10 以后的版本有用
 */
+ (void)addLocalNotificationWithModel:(HQLLocalNotificationModel *)model completeBlock:(void(^)(NSError *error))completeBlock;

/**
 移除通知

 @param identifier 通知的标识(一个)
 */
+ (void)removeNotificationWithNotificationIdentifier:(NSString *)identifier;

/**
 移除所有的本地通知
 */
+ (void)removeAllNotification;

/**
 获取date的前后日期

 @param date date
 @param day 相加的数据
 @return targetDate
 */
+ (NSDate *)getPriusDateFromDate:(NSDate *)date withDay:(NSInteger)day;

/**
 获取weekday的NSDate

 @param weekday 1-7
 @return 获取weekday的NSDate
 */
+ (NSDate *)getWeekdayDateWithWeekday:(NSInteger)weekday;

@end

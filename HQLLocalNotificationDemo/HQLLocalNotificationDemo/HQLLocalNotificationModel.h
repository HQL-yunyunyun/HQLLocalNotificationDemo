//
//  HQLLocalNotificationModel.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/18.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HQLLocalNotificationIdentifierLinkChar @"_"

typedef enum {
    HQLLocalNotificationAlarmMode , // 闹钟模式
    HQLLocalNotificationScheduleMode // 日程模式
} HQLLocalNotificationMode;

typedef enum {
    HQLLocalNotificationNoneRepeat , // 不重复
    HQLLocalNotificationDayRepeat , // 每日重复
    HQLLocalNotificationWeekRepeat , // 每周重复
    HQLLocalNotificationMonthRepeat , // 每月重复
    HQLLocalNotificationYearRepeat , // 每年重复
} HQLLocalNotificationRepeat;

@class HQLLocalNotificationContentModel;

@interface HQLLocalNotificationModel : NSObject <NSCoding, NSCopying>

/**
 提醒的主要内容
 */
@property (strong, nonatomic, nonnull) HQLLocalNotificationContentModel *content;

/**
 一级标识(通常是用户名)
 */
@property (copy, nonatomic, nonnull) NSString *identifier; // 标识

/**
 二级标识(通常是提醒组的名字)
 */
@property (copy, nonatomic, nonnull) NSString *subIdentifier; // 二级标识

/**
 多个时间的数组(如:周一,周二 或 一月一日,一月二日) ---> 会根据这个数组生成相应的通知
 */
@property (strong, nonatomic, nonnull) NSArray <NSDate *>*repeatDateArray;

/**
 是否启用
 */
@property (assign, nonatomic) BOOL isActivity;

/**
 重复模式(规则)
 */
@property (assign, nonatomic) HQLLocalNotificationRepeat repeatMode;

/**
 通知的类型 --- 闹钟 和 日程
 */
@property (assign, nonatomic) HQLLocalNotificationMode notificationMode;

- (nullable instancetype)initContent:(nonnull HQLLocalNotificationContentModel *)content
                                      repeatDateArray:(nonnull NSArray *)repeatDateArray
                                      identifier:(nonnull NSString *)identifier
                                      subIdentifier:(nonnull NSString *)subIdentifier
                                      repeatMode:(HQLLocalNotificationRepeat)repeatMode
                                      notificationMode:(HQLLocalNotificationMode)notificationMode
                                      isActivity:(BOOL)isActivity;

/**
 是否重复
 */
//@property (assign, nonatomic) BOOL isRepeat;

/**
 触发时刻(只取时间 xx时xx分)
 */
//@property (strong, nonatomic, nonnull) NSDate *date;

/**
 最终标识(identifier_subIdentifier_num) -> (一级标识_二级标识_序号)
 */
//@property (copy, nonatomic, readonly, nonnull) NSString *HQLIdentifier;

/*- (nullable instancetype)initWithDate:(nonnull NSDate *)date content:(nonnull HQLLocalNotificationContentModel *)content repeatDateArray:(nonnull NSArray *)repeatDateArray identifier:(nonnull NSString *)identifier subIdentifier:(nonnull NSString *)subIdentifier repeatMode:(HQLLocalNotificationRepeat)repeatMode isRepeat:(BOOL)isRepeat;

- (nullable instancetype)initContent:(nonnull HQLLocalNotificationContentModel *)content repeatDateArray:(nonnull NSArray *)repeatDateArray identifier:(nonnull NSString *)identifier subIdentifier:(nonnull NSString *)subIdentifier repeatMode:(HQLLocalNotificationRepeat)repeatMode isRepeat:(BOOL)isRepeat;*/

@end

#pragma mark - local notification content

@interface HQLLocalNotificationContentModel : NSObject <NSCoding>

// alerts
@property(nullable, nonatomic,copy) NSString *alertBody;      // defaults to nil. pass a string or localized string key to show an alert
@property(nullable, nonatomic,copy) NSString *alertAction;    // used in UIAlert button or 'slide to unlock...' slider in place of unlock
@property(nullable, nonatomic,copy) NSString *alertLaunchImage;   // used as the launch image (UILaunchImageFile) when launch button is tapped
@property(nullable, nonatomic,copy) NSString *alertTitle;  // defaults to nil. pass a string or localized string key

// sound
@property(nullable, nonatomic,copy) NSString *soundName;      // name of resource in app's bundle to play or UILocalNotificationDefaultSoundName

// badge
@property(nonatomic) NSInteger applicationIconBadgeNumber;  // 0 means no change. defaults to 0

// user info
@property(nullable, nonatomic,copy) NSDictionary *userInfo;   // throws if contains non-property list types

// category identifer of the local notification, as set on a UIUserNotificationCategory and passed to +[UIUserNotificationSettings settingsForTypes:categories:]
//@property (nullable, nonatomic, copy) NSString *category;

@end

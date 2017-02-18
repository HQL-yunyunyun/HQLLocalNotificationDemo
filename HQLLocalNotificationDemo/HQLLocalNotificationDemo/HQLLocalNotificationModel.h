//
//  HQLLocalNotificationModel.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/18.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HQLLocalNotificationAlarmMode , // 闹钟模式
    HQLLocalNotificationScheduleMode // 日程模式
} HQLLocalNotificationMode;

typedef enum {
    HQLLocalNotificationMonthRepeat , // 每月重复
    HQLLocalNotificationYearRepeat , // 每年重复
} HQLLocalNotificationRepeat;

@class HQLLocalNotificationContentModel;

@interface HQLLocalNotificationModel : NSObject

@property (strong, nonatomic, nonnull) NSDate *date; // 触发时刻(只取时间 xx时xx分)

@property (strong, nonatomic, nonnull) HQLLocalNotificationContentModel *content; // 内容

@property (copy, nonatomic, nonnull) NSString *identify; // 标识

@property (copy, nonatomic, nonnull) NSString *subIdentify; // 二级标识

@property (strong, nonatomic, nullable) NSArray *repeat;

@end

#pragma mark - local notification content

@interface HQLLocalNotificationContentModel : NSObject

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

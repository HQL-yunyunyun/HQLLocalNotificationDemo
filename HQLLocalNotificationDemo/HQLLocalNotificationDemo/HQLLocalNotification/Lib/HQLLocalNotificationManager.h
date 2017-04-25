//
//  HQLLocalNotificationManager.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/21.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQLLocalNotificationModel.h"
#import "HQLLocalNotificationConfig.h"

#define HQLLocalNotificationDefaultIdentifier @"HQLLocalNotificationDefaultIdentifier"

@protocol HQLLocalNotificationManagerDelegate <NSObject>

@optional
// iOS10以后的版本 --- 将要收到通知
- (void)userNotificationDelegateNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification;

// iOS10以后的版本 --- 点击通知
- (void)userNotificationDelegateNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response;

@end

@interface HQLLocalNotificationManager : NSObject

// 所有通知
@property (strong, nonatomic, readonly) NSMutableArray <HQLLocalNotificationModel *>*notificationArray;

@property (assign, nonatomic) id <HQLLocalNotificationManagerDelegate>delegate;

// 一级标识, default: HQLLocalNotificationDefaultIdentifier
@property (copy, nonatomic) NSString *identifier;

// 启动图片, default: default
@property (copy, nonatomic) NSString *alertLaunchImage;

// 提示音, default : @""
@property (copy, nonatomic) NSString *soundName;

// 单例方法
+ (instancetype)shareManger;

// 不能从外部使用init初始化
- (instancetype)init NS_UNAVAILABLE;

// 增
- (void)addNotificationWithSubIdentifier:(NSString *)subIdentifier
                                  notificationMode:(HQLLocalNotificationMode)notificationMode
                                  repeatMode:(HQLLocalNotificationRepeat)repeatMode
                                  alertTitle:(NSString *)alertTitle
                                  alertBody:(NSString *)alertBody
                                  repeatDateArray:(NSArray <NSDate *>*)repeatDateArray
                                  userInfo:(NSDictionary *)userInfo
                                  badgeNumber:(NSInteger)badgeNumber
                                  isActivity:(BOOL)isActivity
                                  complete:(void(^)(NSError *error))completeBlock;

- (void)addNotificationWithModel:(HQLLocalNotificationModel *)model complete:(void(^)(NSError *error))completeBlock;

// 删
- (void)deleteNotificationWithModel:(HQLLocalNotificationModel *)model;
- (void)deleteNotificationWithIdentifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier;
- (void)deleteAllNotification; // 删除所有通知

// 改, key 为需要改的属性, value 为属性的值 ---> 使用setValueForKey:的形式
- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict identifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier;
- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict notificationModel:(HQLLocalNotificationModel *)model;

// 查
- (HQLLocalNotificationModel *)getNotificationModelWithIdentifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier;

// 设置是否启用
- (void)setNotificationActivity:(BOOL)isActivity notificationModel:(HQLLocalNotificationModel *)model;
- (void)setNotificationActivity:(BOOL)isActivity identifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier;

// 保存到本机
- (void)saveNotification;

// 在触发通知后一个要调用这个方法, iOS10以后的版本已经在内部调用了, iOS10以前的版本需要手动调用
- (void)notificationIsActivity:(NSString *)notificationIdentifier;

// 显示所有notification
- (void)showNotification;

// 更新所有通知的状态
- (void)updateNotificationActivity;

@end

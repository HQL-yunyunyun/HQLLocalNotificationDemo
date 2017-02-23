//
//  HQLLocalNotificationManager.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/21.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQLLocalNotificationModel.h"

#define HQLLocalNotificationDefaultIdentify @"HQLLocalNotificationDefaultIdentify"

@protocol HQLLocalNotificationManagerDelegate <NSObject>



@end

@interface HQLLocalNotificationManager : NSObject

// 所有通知
@property (strong, nonatomic, readonly) NSMutableArray <HQLLocalNotificationModel *>*notificationArray;

@property (assign, nonatomic) id <HQLLocalNotificationManagerDelegate>delegate;

// 一级标识, default: HQLLocalNotificationDefaultIdentify
@property (copy, nonatomic) NSString *identify;

// 启动图片, default: default
@property (copy, nonatomic) NSString *alertLaunchImage;

// 提示音, default : @""
@property (copy, nonatomic) NSString *soundName;

// 单例方法
+ (instancetype)shareManger;

// 不能从外部使用init初始化
- (instancetype)init NS_UNAVAILABLE;

// 增
- (void)addNotificationWithSubIdentify:(NSString *)subIdentify
                                  notificationMode:(HQLLocalNotificationMode)notificationMode
                                  repeatMode:(HQLLocalNotificationRepeat)repeatMode
                                  alertTitle:(NSString *)alertTitle
                                  alertBody:(NSString *)alertBody
                                  repeatDateArray:(NSArray <NSDate *>*)repeatDateArray
                                  userInfo:(NSDictionary *)userInfo
                                  badgeNumber:(NSInteger)badgeNumber
                                  isActivity:(BOOL)isActivity;

// 删
- (void)deleteNotificationWithModel:(HQLLocalNotificationModel *)model;
- (void)deleteNotificationWithIdentify:(NSString *)identify subIdentify:(NSString *)subIdentify;

// 改, key 为需要改的属性, value 为属性的值 ---> 使用setValueForKey:的形式
- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict identify:(NSString *)identify subIdentify:(NSString *)subIdentify;
- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict notificationModel:(HQLLocalNotificationModel *)model;

// 查
- (HQLLocalNotificationModel *)getNotificationModelWithIdentify:(NSString *)identify subIdentify:(NSString *)subIdentify;

// 设置是否启用
- (void)setNotificationActivity:(BOOL)isActivity notificationModel:(HQLLocalNotificationModel *)model;
- (void)setNotificationActivity:(BOOL)isActivity identify:(NSString *)identify subIdentify:(NSString *)subIdentify;

// 保存到本机
- (void)saveNotification;

@end

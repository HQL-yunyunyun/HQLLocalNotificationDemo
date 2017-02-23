//
//  HQLLocalNotificationManager.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/21.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationManager.h"
#import "HQLLocalNotificationConfig.h"
#import "HQLLocalNotificationModel.h"

#define HQLLocalNotificationArray @"HQLLocalNotificationArray"

@interface HQLLocalNotificationManager () <UNUserNotificationCenterDelegate>

@property (strong, nonatomic, readwrite) NSMutableArray <HQLLocalNotificationModel *>*notificationArray;

@end

@implementation HQLLocalNotificationManager

+ (instancetype)shareManger {
    static HQLLocalNotificationManager *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [HQLLocalNotificationConfig replyNotificationAuthorization:[UIApplication sharedApplication] iOS10NotificationDelegate:self successComplete:^(BOOL isFirstGranted) {
            // 授权成功
        } failureComplete:^(BOOL isFirstGranted) {
            // 授权失败
        }];
        self.identify = HQLLocalNotificationDefaultIdentify;
        self.alertLaunchImage = @"Default";
        self.soundName = @""; // 设置的时候有默认的
        
        [self getNotification];
    }
    return self;
}

#pragma mark - notificationModel operation method

// 增
- (void)addNotificationWithSubIdentify:(NSString *)subIdentify
                                  notificationMode:(HQLLocalNotificationMode)notificationMode
                                  repeatMode:(HQLLocalNotificationRepeat)repeatMode
                                  alertTitle:(NSString *)alertTitle
                                  alertBody:(NSString *)alertBody
                                  repeatDateArray:(NSArray<NSDate *> *)repeatDateArray
                                  userInfo:(NSDictionary *)userInfo
                                  badgeNumber:(NSInteger)badgeNumber
                                  isActivity:(BOOL)isActivity
{
    HQLLocalNotificationContentModel *content = [[HQLLocalNotificationContentModel alloc] init];
    content.alertBody = alertBody;
    content.alertTitle = alertTitle;
    content.userInfo = userInfo;
    content.applicationIconBadgeNumber = badgeNumber;
    HQLLocalNotificationModel *model = [[HQLLocalNotificationModel alloc] initContent:content repeatDateArray:repeatDateArray identify:self.identify subIdentify:subIdentify repeatMode:repeatMode notificationMode:notificationMode isActivity:isActivity];
    
    [HQLLocalNotificationConfig addLocalNotificationWithModel:model completeBlock:^(NSError *error) {
        if (error) {
            // 添加错误
            NSLog(@"add notification error : %@", error);
        } else {
            NSLog(@"add notification success");
        }
    }];
    
    [self.notificationArray addObject:model];
    [self saveNotification]; // 保存到本机中
}

// 删
- (void)deleteNotificationWithModel:(HQLLocalNotificationModel *)model {
    // 先删除通知,再删除model
    if (model) {
        // 判断model是否在队列中
        if (![self.notificationArray containsObject:model]) {
            // 不在队列中
            NSLog(@"model 不在队列中");
            return;
        }
        [self removeNotificationWithIdentify:model.identify subIdentify:model.subIdentify];
        [self.notificationArray removeObject:model];
        [self saveNotification];
    } else {
        // model为空
        NSLog(@"model不能为空");
    }
}

- (void)deleteNotificationWithIdentify:(NSString *)identify subIdentify:(NSString *)subIdentify {
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentify:identify subIdentify:subIdentify];
    if (model) {
        [self deleteNotificationWithModel:model];
    } else {
        // 不存在该model
        NSLog(@"不存在该model");
    }
}

// 改
- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict identify:(NSString *)identify subIdentify:(NSString *)subIdentify {
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentify:identify subIdentify:subIdentify];
    if (model) {
        [self updateNotificationWithPropertyDict:propertyDict notificationModel:model];
    } else {
        // 不存在该model
        NSLog(@"不存在该model");
    }
}

- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict notificationModel:(HQLLocalNotificationModel *)model {
    if (model) {
        // 判断model是否在队列中
        if (![self.notificationArray containsObject:model]) {
            // 不在队列中
            NSLog(@"model 不在队列中");
            return;
        }
        // 先取消通知
        [self removeNotificationWithIdentify:model.identify subIdentify:model.subIdentify];
        for (NSString *key in propertyDict.allKeys) {
            [model setValue:propertyDict[key] forKeyPath:key];
        }
        [HQLLocalNotificationConfig addLocalNotificationWithModel:model completeBlock:^(NSError *error) {
            if (error) {
                // 添加错误
                NSLog(@"add notification error : %@", error);
            } else {
                NSLog(@"add notification success");
            }
        }];
        
        [self saveNotification]; // 保存
    } else {
        // model为空
        NSLog(@"model不能为空");
    }
}

// 查
- (HQLLocalNotificationModel *)getNotificationModelWithIdentify:(NSString *)identify subIdentify:(NSString *)subIdentify {
    for (HQLLocalNotificationModel *model in self.notificationArray) {
        if ([model.subIdentify isEqualToString:subIdentify] && [model.identify isEqualToString:identify]) {
            return model;
        }
    }
    return nil;
}

// 设置通知是否启用
- (void)setNotificationActivity:(BOOL)isActivity notificationModel:(HQLLocalNotificationModel *)model {
    if (model) {
        // 判断model是否在队列中
        if (![self.notificationArray containsObject:model]) {
            // 不在队列中
            NSLog(@"model 不在队列中");
            return;
        }
        [self removeNotificationWithIdentify:model.identify subIdentify:model.subIdentify];
        model.isActivity = isActivity;
        [HQLLocalNotificationConfig addLocalNotificationWithModel:model completeBlock:^(NSError *error) {
            if (error) {
                // 添加错误
                NSLog(@"add notification error : %@", error);
            } else {
                NSLog(@"add notification success");
            }
        }];
        
        [self saveNotification]; // 保存
    } else {
        // model为空
        NSLog(@"model不能为空");
    }
}

- (void)setNotificationActivity:(BOOL)isActivity identify:(NSString *)identify subIdentify:(NSString *)subIdentify {
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentify:identify subIdentify:subIdentify];
    if (model) {
        [self setNotificationActivity:isActivity notificationModel:model];
    } else {
        // 不存在该model
        NSLog(@"不存在该model");
    }
}

#pragma mark - private method

- (void)removeNotificationWithIdentify:(NSString *)identify subIdentify:(NSString *)subIdentify {
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentify:identify subIdentify:subIdentify];
    for (int i = 0; i < model.repeatDateArray.count; i++) {
        [HQLLocalNotificationConfig removeNotificationWithNotificationIdentify:[NSString stringWithFormat:@"%@_%@_%d", model.identify, model.subIdentify, i]];
    }
}

#pragma mark - userDefaults method

- (void)getNotification {
    NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:HQLLocalNotificationArray];
    if (!array) {
        self.notificationArray = [NSMutableArray arrayWithArray:array];
    } else {
        self.notificationArray = [NSMutableArray array];
    }
}

- (void)saveNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.notificationArray forKey:HQLLocalNotificationArray];
    [defaults synchronize];
}

@end

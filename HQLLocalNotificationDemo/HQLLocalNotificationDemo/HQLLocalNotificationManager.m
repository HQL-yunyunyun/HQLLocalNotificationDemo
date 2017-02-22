//
//  HQLLocalNotificationManager.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/21.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationManager.h"
#import "HQLLocalNotificationConfig.h"

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
    // 首先 -> 判断是否可以启用
}

// 删
- (void)deleteNotificationWithModel:(HQLLocalNotificationModel *)model {

}

- (void)deleteNotificationWithIdentify:(NSString *)identify subIdentify:(NSString *)subIdentify {

}

// 改
- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict identify:(NSString *)identify subIdentify:(NSString *)subIdentify {

}

- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict notificationModel:(HQLLocalNotificationModel *)model {

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

}

- (void)setNotificationActivity:(BOOL)isActivity identify:(NSString *)identify subIdentify:(NSString *)subIdentify {

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

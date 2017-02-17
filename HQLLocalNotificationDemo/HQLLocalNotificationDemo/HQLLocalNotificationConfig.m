//
//  HQLLocalNotificationConfig.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationConfig.h"

@implementation HQLLocalNotificationConfig

// 通知授权
- (void)replyNotificationAuthorization:(UIApplication *)application {
    // 每一个版本的系统的通知授权都有一点改变
    if (iOS10_OR_LATER) { // iOS 10 以后的版本
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            // 获取授权状态
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) { // 第一次授权
                [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge |
                                                                                  UNAuthorizationOptionSound |
                                                                                  UNAuthorizationOptionAlert
                            completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                if (!error && granted) { // 同意授权
                                    NSLog(@"授权成功.");
                                } else { // 授权失败 --- 弹框
                                    NSLog(@"授权失败,如果想开启通知,请到系统设置下更改.");
                                }
                            }];
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) { // 用户设置成不可通知
                NSLog(@"如果想开启通知,请到系统设置下更改.");
            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) { // 用户允许通知
                NSLog(@"用户允许通知");
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
@end

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

@interface HQLLocalNotificationConfig : NSObject

/**
 通知授权

 @param application application
 @param notificationDelegate iOS10版本以后,得遵守这个通知协议
 @param successComplete 授权成功后的调用(只有iOS10以后版本才有用)
 @param failureComplete 授权失败后的调用(iOS10以后版本才有用)
 */
+ (void)replyNotificationAuthorization:(UIApplication *)application iOS10NotificationDelegate:(id <UNUserNotificationCenterDelegate>)notificationDelegate successComplete:(void(^)(BOOL isFirstGranted))successComplete failureComplete:(void(^)(BOOL isFirstGranted))failureComplete;

@end

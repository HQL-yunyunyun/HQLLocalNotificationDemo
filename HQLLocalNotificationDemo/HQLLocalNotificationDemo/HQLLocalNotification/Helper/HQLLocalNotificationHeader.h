//
//  HQLLocalNotificationHeader.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/5/4.
//  Copyright © 2017年 weplus. All rights reserved.
//

#ifndef HQLLocalNotificationHeader_h
#define HQLLocalNotificationHeader_h

// 点击了通知View
static NSString *HQLShowNotificationViewDidClickNotification = @"HQLShowNotificationViewDidClickNotification";
// 隐藏通知View
static NSString *HQLShowNotificationViewDidHideNotification = @"HQLShowNotificationViewDidHideNotification";
// iOS10以前在 app中收到了通知
static NSString *HQLiOS10BeforeDidReceiveLocalNotification = @"HQLiOS10BeforeDidReceiveLocalNotification";

#define HQLWeakSelf __weak typeof(self) weakSelf = self

#define HQLScreenWidth [UIScreen mainScreen].bounds.size.width
#define HQLScreenHeight [UIScreen mainScreen].bounds.size.height

#define HQLShowAlertView(Title, Message) [[[UIAlertView alloc] initWithTitle:Title message:Message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show]

#define HQLBackgroundColor [UIColor colorWithRed:(247 / 255.0) green:(248 / 255.0) blue:(250 / 255.0) alpha:1]

#endif /* HQLLocalNotificationHeader_h */

//
//  HQLShowNotificationView.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/26.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *HQLShowNotificationViewDidClickNotification = @"HQLShowNotificationViewDidClickNotification";
static NSString *HQLShowNotificationViewDidHideNotification = @"HQLShowNotificationViewDidHideNotification";

@class HQLLocalNotificationModel;

@interface HQLShowNotificationView : UIView

@property (strong, nonatomic) HQLLocalNotificationModel *notificationModel;

// 创建iOS10的样式
+ (instancetype)showNotificationViewiOS10Style;

// 创建iOS10以前的样式
+ (instancetype)showNotificationViewiOS10BeforeStyle;

- (void)showView; 
- (void)hideView;

@end

//
//  HQLNotificationSettingView.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/27.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQLLocalNotificationModel.h"

@protocol HQLNotificationSettingViewDelegate <NSObject>

// 每一次点击都会触发这个方法
- (void)notificationSettingViewDidChangeDate:(NSMutableArray *)weekdayArray dateArray:(NSMutableArray *)dateArray timeMoment:(NSDate *)timeMoment repeatMode:(HQLLocalNotificationRepeat)repeatMode notificationMode:(HQLLocalNotificationMode)notificationMode;

@end

@interface HQLNotificationSettingView : UIView

@property (assign, nonatomic) id <HQLNotificationSettingViewDelegate>delegate;

// 设置默认显示的date
- (void)showDateArray:(NSArray *)dateArray repeatMode:(HQLLocalNotificationRepeat)repeatMode notificationMode:(HQLLocalNotificationMode)notificationMode;

// 获取当前的目标date
- (void)notificationContent:(void(^)(NSArray *targetDateArray, HQLLocalNotificationRepeat repeatMode, HQLLocalNotificationMode notificationMode))completeBlock;

+ (instancetype)notificationSettingViewWithFrame:(CGRect)frame;

@end

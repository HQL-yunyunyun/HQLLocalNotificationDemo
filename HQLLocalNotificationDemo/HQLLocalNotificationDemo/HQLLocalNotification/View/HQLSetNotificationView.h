//
//  HQLSetNotificationView.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQLLocalNotificationModel, HQLSetNotificationView;

@protocol HQLSetNotificationViewDelegate <NSObject>

/**
 改变了frame

 @param setView View
 */
- (void)setNotificationViewDidChangeFrame:(HQLSetNotificationView *)setView;

@end

@interface HQLSetNotificationView : UIView

@property (strong, nonatomic) HQLLocalNotificationModel *notificationModel;
@property (copy, nonatomic) NSString *notificationAlertTitle;
@property (assign, nonatomic) id <HQLSetNotificationViewDelegate>delegate;

+ (instancetype)setNotificationView;

- (HQLLocalNotificationModel *)getCurrentNotificationModel;

@end

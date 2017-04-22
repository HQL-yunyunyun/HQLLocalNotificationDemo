//
//  HQLSetNotificationController.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/22.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQLLocalNotificationModel;

@interface HQLSetNotificationController : UIViewController

@property (strong, nonatomic) HQLLocalNotificationModel * _Nullable model;

@property (copy, nonatomic) void(^ _Nullable confirmBlock)( HQLLocalNotificationModel * _Nonnull model);

@end

//
//  HQLLocalNotificationManagerCell.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/22.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQLLocalNotificationModel, HQLLocalNotificationManagerCell;

@protocol HQLLocalNotificationManagerCellDelegate <NSObject>

- (void)localNotificationManagerCellDidClickStatusSwitch:(HQLLocalNotificationManagerCell *)cell isOn:(BOOL)isOn;

@end

@interface HQLLocalNotificationManagerCell : UITableViewCell

@property (strong, nonatomic) HQLLocalNotificationModel *model;

@property (assign, nonatomic) id <HQLLocalNotificationManagerCellDelegate>delegate;

@end

//
//  HQLDayChooseCell.h
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/19.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQLDayChooseModel;

@interface HQLDayChooseCell : UICollectionViewCell

@property (strong, nonatomic) HQLDayChooseModel *model;

@end

@interface HQLDayChooseModel : NSObject

@property (assign, nonatomic) NSInteger day; // 显示的日
@property (assign, nonatomic) BOOL isSelected; // 是否选中该日期

@end

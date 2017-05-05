//
//  UITableView+EmptyView.h
//  HQLGoodsListViewDemo
//
//  Created by weplus on 2017/3/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+emptyView.h"

@interface UITableView (EmptyView)

@property (copy, nonatomic) void(^reloadDataCompleteBlock)(BOOL dataEmpty);

@end

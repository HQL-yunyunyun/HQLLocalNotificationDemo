//
//  HQLEmptyView.h
//  HQLGoodsListViewDemo
//
//  Created by weplus on 2017/3/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQLEmptyView : UIView

@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) void(^tapBlock)();
@property (copy, nonatomic) NSString *animationTitle;

@property (strong, nonatomic) NSData *gifData; // 显示GIF

@property (strong, nonatomic) NSArray <UIImage *>*gifImageArray; // 帧动画

@property (strong, nonatomic) UIColor *titleColor;

- (void)startAnimaion;

- (void)stopAnimation;

@end

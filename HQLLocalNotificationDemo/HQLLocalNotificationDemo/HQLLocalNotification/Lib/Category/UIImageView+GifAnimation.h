//
//  UIImageView+GifAnimation.h
//  HQLGoodsListViewDemo
//
//  Created by weplus on 2017/4/12.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (GifAnimation)

// 会自适应高度
- (void)setGifData:(NSData *)gifData completeBlock:(void(^)(CGFloat width, CGFloat height))completeBlock;

@end

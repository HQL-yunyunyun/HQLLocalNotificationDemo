//
//  UIImageView+GifAnimation.m
//  HQLGoodsListViewDemo
//
//  Created by weplus on 2017/4/12.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "UIImageView+GifAnimation.h"

#import <ImageIO/ImageIO.h>

@implementation UIImageView (GifAnimation)

- (void)setGifData:(NSData *)gifData completeBlock:(void (^)(CGFloat, CGFloat))completeBlock {
    CGImageSourceRef source = CGImageSourceCreateWithData(CFBridgingRetain(gifData), NULL);
    //获取gif文件中图片的个数
    size_t count = CGImageSourceGetCount(source);
    //定义一个变量记录gif播放一轮的时间
    float allTime=0;
    // 根据data获取gif的信息
    NSMutableArray * imageArray = [[NSMutableArray alloc]init];
    CGFloat gifWidth = self.frame.size.width;
    CGFloat gifHeight = self.frame.size.height;
    // 遍历imageSource
    for (size_t i=0; i < count; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        [imageArray addObject:[UIImage imageWithCGImage:image]];
        CGImageRelease(image);
        //获取图片信息
        NSDictionary * info = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
        if (i == 0) {
            gifWidth = [[info objectForKey:(__bridge NSString *)kCGImagePropertyPixelWidth] floatValue];
            gifHeight = [[info objectForKey:(__bridge NSString *)kCGImagePropertyPixelHeight] floatValue];
        }
        NSDictionary * timeDic = [info objectForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
        CGFloat time = [[timeDic objectForKey:(__bridge NSString *)kCGImagePropertyGIFDelayTime]floatValue];
        allTime+=time;
        CFRelease((__bridge CFTypeRef)(info));
    }
    CFRelease(source);
    
    // 设置帧动画
    self.animationImages = [NSArray arrayWithArray:imageArray];
    self.animationDuration = allTime;
    self.animationRepeatCount = 0; // 表示无限播放
    
    if (completeBlock) {
        completeBlock(gifWidth, gifHeight);
    }
}

@end

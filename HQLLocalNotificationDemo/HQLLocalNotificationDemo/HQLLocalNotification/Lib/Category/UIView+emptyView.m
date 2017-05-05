//
//  UIView+emptyView.m
//  HQLGoodsListViewDemo
//
//  Created by weplus on 2017/4/14.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "UIView+emptyView.h"

#import <objc/runtime.h>

static const NSString *HQLEmptyViewImageKey = @"HQLEmptyViewImageKey";
static const NSString *HQLEmptyViewTitleKey = @"HQLEmptyViewTitleKey";
static const NSString *HQLEmptyViewTapBlockKey= @"HQLEmptyViewTapBlockKey";
static const NSString *HQLIsUseEmptyViewKey = @"HQLIsUseEmptyViewKey";
static const NSString *HQLEmptyViewKey = @"HQLEmptyViewKey";
static const NSString *HQLEmptyViewGifData = @"HQLEmptyViewGifData";
static const NSString *HQLEmptyViewGifImageArray = @"HQLEmptyViewGifImageArray";
static const NSString *HQLEmptyViewAnimationTitle = @"HQLEmptyViewAnimationTitle";
static const NSString *HQLEmptyViewTitleColor = @"HQLEmptyViewTitleColor";

#define kEmptyViewTag 1101

@implementation UIView (emptyView)

#pragma mark - event

- (void)updateEmptyViewFrame {
    if (!self.isUseEmptyView) {
        return;
    }
    [self emptyView].frame = self.frame;
}

- (void)emptyViewStartAnimation {
    if (!self.isUseEmptyView) {
        return;
    }
    [self.emptyView startAnimaion];
}

- (void)emptyViewStopAnimation {
    if (!self.isUseEmptyView) {
        return;
    }
    [self.emptyView stopAnimation];
}

- (void)showEmptyView {
    if (!self.isUseEmptyView) {
        return;
    }
    [self.emptyView setHidden:NO];
}

- (void)hideEmptyView {
    if (!self.isUseEmptyView) {
        return;
    }
    [self.emptyView setHidden:YES];
}

#pragma mark - setter

- (void)setEmptyView:(HQLEmptyView *)emptyView {
    if (emptyView.tag == kEmptyViewTag) {
        objc_setAssociatedObject(self, &HQLEmptyViewKey, emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setEmptyViewImage:(UIImage *)emptyViewImage {
    self.emptyView.image = emptyViewImage;
    objc_setAssociatedObject(self, &HQLEmptyViewImageKey, emptyViewImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setEmptyViewTitle:(NSString *)emptyViewTitle {
    self.emptyView.title = emptyViewTitle;
    objc_setAssociatedObject(self, &HQLEmptyViewTitleKey, emptyViewTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setEmptyTapBlock:(void (^)())emptyTapBlock {
    self.emptyView.tapBlock = emptyTapBlock;
    objc_setAssociatedObject(self, &HQLEmptyViewTapBlockKey, emptyTapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIsUseEmptyView:(BOOL)isUseEmptyView {
    objc_setAssociatedObject(self, &HQLIsUseEmptyViewKey, [NSNumber numberWithBool:isUseEmptyView], OBJC_ASSOCIATION_ASSIGN);
    
    if (isUseEmptyView) {
        [self emptyView].image = self.emptyViewImage;
        [self emptyView].title = self.emptyViewTitle;
        [self emptyView].tapBlock = self.emptyTapBlock;
        [self emptyView].gifData = self.emptyViewGifData;
        [self emptyView].gifImageArray = self.emptyViewGifImageArray;
        [self emptyView].animationTitle = self.emptyViewAnimationTitle;
        [self emptyView].titleColor = self.emptyViewTitleColor;
    }
}

- (void)setEmptyViewGifData:(NSData *)emptyViewGifData {
    self.emptyView.gifData = emptyViewGifData;
    objc_setAssociatedObject(self, &HQLEmptyViewGifData, emptyViewGifData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setEmptyViewGifImageArray:(NSArray<UIImage *> *)emptyViewGifImageArray {
    self.emptyView.gifImageArray = emptyViewGifImageArray;
    objc_setAssociatedObject(self, &HQLEmptyViewGifImageArray, emptyViewGifImageArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setEmptyViewAnimationTitle:(NSString *)emptyViewAnimationTitle {
    self.emptyView.animationTitle = emptyViewAnimationTitle;
    objc_setAssociatedObject(self, &HQLEmptyViewAnimationTitle, emptyViewAnimationTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setEmptyViewTitleColor:(UIColor *)emptyViewTitleColor {
    self.emptyView.titleColor = emptyViewTitleColor;
    objc_setAssociatedObject(self, &HQLEmptyViewTitleColor, emptyViewTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getter

- (UIImage *)emptyViewImage {
    return objc_getAssociatedObject(self, &HQLEmptyViewImageKey);
}

- (NSString *)emptyViewTitle {
    return objc_getAssociatedObject(self, &HQLEmptyViewTitleKey);
}

- (void (^)())emptyTapBlock {
    return objc_getAssociatedObject(self, &HQLEmptyViewTapBlockKey);
}

- (BOOL)isUseEmptyView {
    return [objc_getAssociatedObject(self, &HQLIsUseEmptyViewKey) boolValue];
}

- (HQLEmptyView *)emptyView {
    if (!self.isUseEmptyView) {
        return nil; // 如果不启用 则 返回空
    }
    HQLEmptyView *view = objc_getAssociatedObject(self, &HQLEmptyViewKey);
    if (view) {
        return view;
    } else {
        HQLEmptyView *emtpyView = [[HQLEmptyView alloc] init];
        emtpyView.frame = self.frame;
        emtpyView.tag = kEmptyViewTag;
        
        emtpyView.hidden = YES;
        emtpyView.title = @"没有数据诶，喵";
        
        [self.superview addSubview:emtpyView];
        [self setEmptyView:emtpyView];
    }
    
    return objc_getAssociatedObject(self, &HQLEmptyViewKey);
}

- (NSData *)emptyViewGifData {
    return objc_getAssociatedObject(self, &HQLEmptyViewGifData);
}

- (NSArray<UIImage *> *)emptyViewGifImageArray {
    return objc_getAssociatedObject(self, &HQLEmptyViewGifImageArray);
}

- (NSString *)emptyViewAnimationTitle {
    return objc_getAssociatedObject(self, &HQLEmptyViewAnimationTitle);
}

- (UIColor *)emptyViewTitleColor {
    return objc_getAssociatedObject(self, &HQLEmptyViewTitleColor);
}
@end

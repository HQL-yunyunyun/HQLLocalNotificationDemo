//
//  UITableView+EmptyView.m
//  HQLGoodsListViewDemo
//
//  Created by weplus on 2017/3/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "UITableView+EmptyView.h"
#import <objc/runtime.h>

static const NSString *HQLReloadDataCompleteBlock = @"HQLReloadDataCompleteBlock";

@implementation UITableView (EmptyView)

#pragma mark - system method

+ (void)load {
    [super load];
    Method fromMethod = class_getInstanceMethod([self class], @selector(reloadData));
    Method toMethod = class_getInstanceMethod([self class], @selector(HQL_reloadData));
    method_exchangeImplementations(fromMethod, toMethod);
}

#pragma mark - method swizzling

- (void)HQL_reloadData {
    [self HQL_reloadData];
    
    // 如果 row为0 且headerView和footerView都为空 --- 可以判断sectionHeaderHeight 和 sectionFooterHeight
    BOOL isNoHeaderOrFooterView = YES;
    if (self.sectionHeaderHeight > 1 || self.sectionFooterHeight > 1) {
        isNoHeaderOrFooterView = NO; // 没有headerView或FooterView
    }
    
    BOOL isDataEmpty = YES;
    NSInteger row = 0;
    for (int i = 0; i < self.numberOfSections; i++) {
        row += [self numberOfRowsInSection:i];
    }
    if (row > 0) { // row不为0 表明有数据
        isDataEmpty = NO;
    }
    
    // 只有符合这三个条件才会显示emptyView
    if (self.isUseEmptyView && isNoHeaderOrFooterView && isDataEmpty) {
        [self showEmptyView];
    } else {
        [self hideEmptyView];
    }
    
    if (self.reloadDataCompleteBlock) {
        // 只有符合这两个条件才表示没有数据 ---> row的总数量为0 且 headerView和FooterView的高都不大于1
        self.reloadDataCompleteBlock((isDataEmpty && isNoHeaderOrFooterView));
    }
}

#pragma mark - setter

- (void)setReloadDataCompleteBlock:(void (^)(BOOL))reloadDataCompleteBlock {
    objc_setAssociatedObject(self, &HQLReloadDataCompleteBlock, reloadDataCompleteBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - getter

- (void (^)(BOOL))reloadDataCompleteBlock {
    return objc_getAssociatedObject(self, &HQLReloadDataCompleteBlock);
}

@end

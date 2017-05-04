//
//  HQLTimer.m
//  Registration
//
//  Created by weplus on 16/8/10.
//  Copyright © 2016年 weplus. All rights reserved.
//

#import "HQLTimer.h"

@interface HQLTimer ()

@property (nonatomic, assign) NSTimeInterval ti;
@property (nonatomic, weak) id aTarget;
@property (nonatomic,assign) SEL aSelector;
@property (nonatomic, weak) id userInfo;
@property (nonatomic, assign) BOOL yesOrNo;
@property (nonatomic, assign, getter=isValid) BOOL valid;

@end

@implementation HQLTimer

- (instancetype) init {
    if (self = [super init]) {
        self.yesOrNo = YES;
        self.valid = YES;
    }
    return self;
}

+ (HQLTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    HQLTimer *timer = [[HQLTimer alloc] init];
    timer.ti = ti;
    timer.aTarget = aTarget;
    timer.aSelector = aSelector;
    timer.userInfo = userInfo;
    
    if (yesOrNo) {
        [timer repeatSelector];
    } else {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ti *   NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [aTarget performSelectorOnMainThread:aSelector withObject:userInfo waitUntilDone:NO];
        });
    }
    
    return timer;
}

// 运行指定方法
- (void) repeatSelector {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.ti * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if (self.yesOrNo) {
            [self.aTarget performSelectorOnMainThread:self.aSelector withObject:self.userInfo waitUntilDone:NO];
        }
        if (self.isValid) {
            [self repeatSelector];
        }
    });
}

- (void)reStart {
    self.yesOrNo = YES;
}

- (void)stop {
    self.yesOrNo = NO;
}

- (void)invalidate {
    self.valid = NO;
}

- (void)dealloc {
    self.aTarget = nil;
    self.aSelector = NULL;
    self.userInfo = nil;
    NSLog(@"销毁计时器---->%@",NSStringFromClass([self class]));
}

@end

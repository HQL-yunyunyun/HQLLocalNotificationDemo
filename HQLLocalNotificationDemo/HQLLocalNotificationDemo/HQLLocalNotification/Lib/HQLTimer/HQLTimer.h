//
//  HQLTimer.h
//  Registration
//
//  Created by weplus on 16/8/10.
//  Copyright © 2016年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQLTimer : NSObject

+ (nonnull HQLTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

/** 开始 */
- (void)reStart;
/** 暂停 */
- (void)stop;
/** 销毁 */
- (void)invalidate;

@end

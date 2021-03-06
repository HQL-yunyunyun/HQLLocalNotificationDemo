//
//  HQLShowNotificationView.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/26.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLShowNotificationView.h"
#import "HQLLocalNotificationModel.h"
#import "HQLTimer.h"
#import <AVFoundation/AVFoundation.h>
#import "HQLLocalNotificationHeader.h"

typedef enum {
    HQLDragDirectionNone , // 没有方向
    HQLDragDirectionUp , // 向上
    HQLDragDirectionDown , // 向下
} HQLDragDirection;

#define HQLDefaultWidth [UIScreen mainScreen].bounds.size.width
#define HQLMaxHeight [UIScreen mainScreen].bounds.size.height

#define HQLiOS10BeforeHeight 70
#define HQLiOS10DefaultHeight 90
#define HQLiOS10FullHeight 105

#define HQLContentLabelFontSize 13

#define HQLViewStayTime 5
#define HQLViewAnimateTime 0.3

#define HQLiOS10BeforeFixedHeight 38.5

@interface HQLShowNotificationView ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *applicationName;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIView *iOS10MaskView;
@property (weak, nonatomic) IBOutlet UILabel *iOS10AlertTitleLabel;

@property (assign, nonatomic) HQLDragDirection currentDirection;

@property (assign, nonatomic) BOOL iOS10; // 是否是iOS10

@property (assign, nonatomic) CGFloat contentLabelHeight;

@property (assign, nonatomic) CGPoint lastTouchPoint; // 记录最新的touchPoint

// iOS10以前的内容的top的约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iOS10BeforeContentTopConstraint;

@property (strong, nonatomic) HQLTimer *timer;

@property (assign, nonatomic) NSInteger countDown;

@end

@implementation HQLShowNotificationView

#pragma mark - initialize method 

+ (instancetype)showNotificationViewiOS10Style {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HQLShowNotificationView" owner:nil options:nil];
    HQLShowNotificationView *view = array[1];
    view.iOS10 = YES;
    return view;
}

+ (instancetype)showNotificationViewiOS10BeforeStyle {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HQLShowNotificationView" owner:nil options:nil];
    HQLShowNotificationView *view = array[0];
    view.iOS10 = NO;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self viewConfig];
    [self configGestureMethod];
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

// 一些设置
- (void)viewConfig {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 设置iconView和applicationName
    NSString *iconPath = [[infoDictionary valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    if (!iconPath) {
        iconPath = [[NSBundle mainBundle] pathForResource:@"iOSDefaultAppIcon" ofType:@"png"];
    }
    UIImage *appIcon = [UIImage imageNamed:iconPath];
    [self.iconView setImage:appIcon];
    // app名称
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [infoDictionary objectForKey:@"CFBundleName"];
    }
    if (!appName) {
        appName = @"HQLDefaultApplicationName";
    }
    self.applicationName.text = appName;
    
    self.currentDirection = HQLDragDirectionDown;
}

// 隐藏View
- (void)hideView {
    HQLWeakSelf;
    [UIView animateWithDuration:HQLViewAnimateTime animations:^{
        weakSelf.frame = CGRectMake(0, -weakSelf.frame.size.height, weakSelf.frame.size.width, weakSelf.frame.size.height);
    } completion:^(BOOL finished) {
        [weakSelf.timer invalidate];
        weakSelf.timer = nil;
        for (UIView *view in weakSelf.subviews) {
            CGRect frame = view.frame;
            [view removeConstraints:view.constraints];
            view.frame = frame;
            [view removeFromSuperview];
        }
        [weakSelf removeConstraints:weakSelf.constraints];
        [weakSelf removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:HQLShowNotificationViewDidHideNotification object:weakSelf];
    }];
}

// 显示View
- (void)showView {
    if (!self.superview) {
        [[self appRootViewController].view addSubview:self];
    }
    // 播放提示音
    [self playSoundWithName:self.notificationModel.content.soundName];
    HQLWeakSelf;
    self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:HQLViewAnimateTime animations:^{
        weakSelf.frame = CGRectMake(0, 0, weakSelf.frame.size.width, weakSelf.frame.size.height);
    } completion:^(BOOL finished) {
        // 添加一个timer
        weakSelf.countDown = HQLViewStayTime;
        weakSelf.timer = [HQLTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideViewWithTimer) userInfo:nil repeats:YES];
    }];
}

// 寻找rootController
- (UIViewController *)appRootViewController{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

// 计算content的高度
- (CGFloat)calculateContentLabelHeightWithContent:(NSString *)content {
    
    CGFloat width = HQLDefaultWidth;
    if (self.iOS10) {
        width -= 33;
    } else {
        width -= 54;
    }
    CGSize size = CGSizeMake(width, MAXFLOAT);
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:HQLContentLabelFontSize] forKey:NSFontAttributeName];
    CGRect rect = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.height;
}

// timer要调用的方法
- (void)hideViewWithTimer {
    self.countDown--;
    if (self.countDown <= 0) {
        [self hideView];
    }
}

- (void)playSoundWithName:(NSString *)name {
    SystemSoundID soundID = 0;
    if (![name isEqualToString:@""] && name && ![name isEqualToString:HQLLocalNotificationDefaultSoundName]) {
        // 播放自定义提示音
        NSURL *soundURL = [NSURL fileURLWithPath:name];
        // 添加到系统提示音当中，soundID会返回一个id
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &soundID);
    } else {
        // 系统预设的音效(短信，详情参照 http://iphonedevwiki.net/index.php/AudioServices)
        soundID = 1312;
    }
    AudioServicesPlayAlertSound(soundID);
}

#pragma mark - gesture method

// 手势
- (void)configGestureMethod {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [pan setMaximumNumberOfTouches:1];
    [pan setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:pan];
}

// 手势
- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.notificationModel)  {
        [[NSNotificationCenter defaultCenter] postNotificationName:HQLShowNotificationViewDidClickNotification object:self.notificationModel];
        [self hideView];
    }
}

// 手势
- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    __weak typeof(self) weakSelf = self;
    
    [self.timer stop];
    
    CGFloat yMin = -(self.frame.size.height * 0.5); // y值最少的值
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: { // 开始
            self.currentDirection = HQLDragDirectionNone;
            break;
        }
        case UIGestureRecognizerStateChanged: { // 移动中
            CGFloat distance = point.y - self.lastTouchPoint.y;
            self.currentDirection = distance >= 0 ? HQLDragDirectionDown : HQLDragDirectionUp;
            switch (self.currentDirection) {
                case HQLDragDirectionUp: {
                    if (self.iOS10) {
                        // 移动y
                        CGFloat y = self.frame.origin.y;
                        y = y <= yMin ? yMin : (y + distance);
                        self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
                        // 更新touchPoint
                        point.y -= distance;
//                        point.y -= (y <= -38 ? 0 : distance);
                    } else {
                        // 先判断top约束是否大于6
                        CGFloat height = self.frame.size.height;
                        CGFloat y = self.frame.origin.y;
                        if (self.iOS10BeforeContentTopConstraint.constant > 6) {
                            CGFloat constant = self.iOS10BeforeContentTopConstraint.constant;
                            if ((constant + distance) <= 6) {
                                height -= (constant - 6);
                                self.iOS10BeforeContentTopConstraint.constant = 6;
                            } else {
                                height += distance;
                                self.iOS10BeforeContentTopConstraint.constant += distance;
                            }
                        } else { // 小于等于6
                            self.iOS10BeforeContentTopConstraint.constant = 6;
                            height += distance;
                        }
                        if (height <= HQLiOS10BeforeHeight) {
                            height = HQLiOS10BeforeHeight;
                            y += distance;
                            point.y -= distance;
                            if (y <= yMin) {
                                y = yMin;
                                point.y -= (self.frame.origin.y - (yMin));
                            }
                        }
                        self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, height);
                    }
                    break;
                }
                case HQLDragDirectionDown: {
                    if (self.iOS10) {
                        CGFloat moveDistance = [self calculateMoveDistanceWithCurrentDistance:self.frame.origin.y beginDecelerateDistance:10 maxDistance:40 decelerateRangeCount:5 normalSpeed:distance];
                        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + moveDistance, self.frame.size.width, self.frame.size.height);
                    } else {
                        // View变高
                        CGFloat height = self.frame.size.height;
                        // 判断View的height
                        CGFloat fixedHeight = 38.5;
                        CGFloat contentLabelHeight = [self calculateContentLabelHeightWithContent:self.notificationModel.content.alertBody];
                        CGFloat y = self.frame.origin.y;
                        if (y < 0) {
                            y += distance;
                            if (y >= 0) {
                                y = 0;
                            }
                        } else {
                            y = 0;
                            CGFloat moveDistance = [self calculateMoveDistanceWithCurrentDistance:height beginDecelerateDistance:(fixedHeight + contentLabelHeight) maxDistance:(fixedHeight + contentLabelHeight + 50) decelerateRangeCount:10 normalSpeed:distance];
                            height += moveDistance;
                            if (moveDistance != distance) {
                                self.iOS10BeforeContentTopConstraint.constant += moveDistance;
                            }
                            height = height >= HQLMaxHeight ? HQLMaxHeight : height;
                        }
                        self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, height);
                    }
                    break;
                }
                case HQLDragDirectionNone: { break; }
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: { // 结束
            // 根据当前 View 的位置来判断是否隐藏或者展开
            [self.timer reStart];
            if (self.frame.origin.y <= yMin) {
                // 小于或等于最少值 ---> 隐藏
                [self hideView];
            } else {
                if (self.iOS10) { // 滚到原来的位置
                    [UIView animateWithDuration:HQLViewAnimateTime animations:^{
                        weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, 0, weakSelf.frame.size.width, weakSelf.frame.size.height);
                    }];
                } else {
                    CGFloat height = HQLiOS10BeforeFixedHeight + [self calculateContentLabelHeightWithContent:self.notificationModel.content.alertBody] + 1;
                    height = height >= HQLMaxHeight ? HQLMaxHeight : height;
                    [UIView animateWithDuration:HQLViewAnimateTime animations:^{
                        weakSelf.iOS10BeforeContentTopConstraint.constant = 6;
                        weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, 0, weakSelf.frame.size.width, height);
                        // 如果需要改变 约束 ，则一定要调用[layoutIfNeeded]方法，否则动画将不显示
                        [weakSelf layoutIfNeeded];
                    }];
                }
            }
            
            break;
        }
        default: { break; } // 其他情况
    }
    
    self.lastTouchPoint = point;
}

/**
 计算每次移动的距离
 
 @param currentDistance 当前的距离
 @param beginDecelerate 开始减速的距离(边界)
 @param maxDistance 距离的最大值(如果当前距离大于最大距离,返回0)
 @param rangeCount 减速区间(每个区间的减速速度)
 @param normalSpeed 正常移动的速度，每个减速区间都会按照这个速度减速下去
 @return 移动距离
 */
- (CGFloat)calculateMoveDistanceWithCurrentDistance:(CGFloat)currentDistance beginDecelerateDistance:(CGFloat)beginDecelerate maxDistance:(CGFloat)maxDistance decelerateRangeCount:(NSInteger)rangeCount normalSpeed:(CGFloat)normalSpeed {
    if (currentDistance < maxDistance) {
        if (currentDistance > beginDecelerate) { // 进入减速区间
            // 计算减速区的长度
            CGFloat decelerateRange = ((maxDistance - beginDecelerate) / rangeCount);
            // 计算当前在哪个减速区
            NSInteger index = ((currentDistance - beginDecelerate) / decelerateRange) + 1;
            // 计算当前减速区计算速度(移动距离)
            return (pow(0.5, index) * normalSpeed);
        } else { // 没有进入减速区间 移动距离就是normalSpeed
            return normalSpeed;
        }
    } else { // 当前距离大于最大距离
        return 0;
    }
}

#pragma mark - setter

- (void)setIOS10:(BOOL)iOS10 {
    _iOS10 = iOS10;
    // 设置iOS10下的阴影
    if (iOS10) {
        self.iOS10MaskView.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.iOS10MaskView.layer.shadowOpacity = 1;
//        self.iOS10MaskView.layer.shadowRadius = 10;
//        self.iOS10MaskView.layer.shadowOffset = CGSizeMake(4, 4);
    }
}

- (void)setNotificationModel:(HQLLocalNotificationModel *)notificationModel {
    if (!notificationModel) return;
    _notificationModel = notificationModel;
    // 设置数据
    
    // 内容
    self.contentLabel.text = notificationModel.content.alertBody;
    self.contentLabelHeight = [self calculateContentLabelHeightWithContent:notificationModel.content.alertBody];
    CGFloat viewHeight = HQLiOS10BeforeHeight;
    if (self.iOS10) {
        self.iOS10AlertTitleLabel.text = notificationModel.content.alertTitle;
        CGFloat lineHeight = [self calculateContentLabelHeightWithContent:@"霸"];
        if ((self.contentLabelHeight / lineHeight) > 1) { // 一行以上
            viewHeight = HQLiOS10FullHeight; // 显示两行
        } else {
            viewHeight = HQLiOS10DefaultHeight; // 显示一行
        }
    }
    
    // 设置frame
    self.frame = CGRectMake(0, 0, HQLDefaultWidth, viewHeight);
}

@end

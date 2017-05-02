//
//  HQLShowNotificationView.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/26.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLShowNotificationView.h"

#import "HQLLocalNotificationModel.h"

typedef enum {
    HQLDragDirectionNone , // 没有方向
    HQLDragDirectionUp , // 向上
    HQLDragDirectionDown , // 向下
} HQLDragDirection;

#define HQLWeakSelf __weak typeof(self) weakSelf = self

#define HQLDefaultWidth [UIScreen mainScreen].bounds.size.width
#define HQLMaxHeight [UIScreen mainScreen].bounds.size.height

#define HQLiOS10BeforeHeight 70
#define HQLiOS10DefaultHeight 90
#define HQLiOS10FullHeight 105

#define HQLContentLabelFontSize 13

#define HQLViewStayTime 4.7
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

@property (assign, nonatomic) BOOL isTap;

//@property (strong, nonatomic) UIWindow *originWindow;
//@property (assign, nonatomic) BOOL isHideStatusBar;

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
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

// 一些设置
- (void)viewConfig {
    
    // 设置iconView和applicationName
    UIImage *appIcon;
    appIcon = [UIImage imageNamed:@"AppIcon60x60"];
    if (!appIcon) {
        appIcon = [UIImage imageNamed:@"AppIcon80x80"];
    }
    [self.iconView setImage:appIcon];
    // app名称
    NSDictionary *infoDictionary = [[NSBundle bundleForClass:[self class]] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [infoDictionary objectForKey:@"CFBundleName"];
    }
    if (!appName) {
        appName = @"HQLDefaultApplicationName";
    }
    self.applicationName.text = appName;
    
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
//    self.originWindow = [UIApplication sharedApplication].keyWindow;
}

// 点击
- (void)tap {
    if (!self.notificationModel) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:HQLShowNotificationViewDidClickNotification object:self.notificationModel];
    self.isTap = YES;
    [self hideView];
}

// 隐藏View
- (void)hideView {
    HQLWeakSelf;
    [UIView animateWithDuration:HQLViewAnimateTime animations:^{
        weakSelf.frame = CGRectMake(0, -weakSelf.frame.size.height, weakSelf.frame.size.width, weakSelf.frame.size.height);
    } completion:^(BOOL finished) {
        for (UIView *view in weakSelf.subviews) {
            CGRect frame = view.frame;
            [view removeConstraints:view.constraints];
            view.frame = frame;
            [view removeFromSuperview];
        }
        [weakSelf removeConstraints:weakSelf.constraints];
//        [weakSelf resignKeyWindow];
//        [weakSelf.originWindow makeKeyAndVisible];
//        [UIApplication sharedApplication].statusBarHidden = weakSelf.isHideStatusBar;
        [weakSelf removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:HQLShowNotificationViewDidHideNotification object:weakSelf];
        
        weakSelf.isTap = NO;
    }];
}

// 显示View
- (void)showView {
    if (!self.superview) {
        [[self appRootViewController].view addSubview:self];
//        [self makeKeyAndVisible];
    }
    
//    self.isHideStatusBar = [UIApplication sharedApplication].statusBarHidden;
//    [self appRootViewController].prefersStatusBarHidden = YES;
//    [UIApplication sharedApplication].statusBarHidden = YES;
    HQLWeakSelf;
    self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:HQLViewAnimateTime animations:^{
        weakSelf.frame = CGRectMake(0, 0, weakSelf.frame.size.width, weakSelf.frame.size.height);
    } completion:^(BOOL finished) {
        
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

#pragma mark - touch method

// 开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    self.lastTouchPoint = [touch locationInView:self];
    self.currentDirection = HQLDragDirectionNone;
    NSLog(@"touchBegan : %@", NSStringFromCGPoint(self.lastTouchPoint));
}

// 取消
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

// 结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isTap) return;
    
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self];
    __weak typeof(self) weakSelf = self;
    // 根据方向来决定接下来的动画
    switch (self.currentDirection) {
        case HQLDragDirectionUp: {
            // 只要是向上都hide
            [self hideView];
            break;
        }
        case HQLDragDirectionDown: {
            if (self.iOS10) {
                // 滚到原来的位置
                [UIView animateWithDuration:HQLViewAnimateTime animations:^{
                    weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, 0, weakSelf.frame.size.width, weakSelf.frame.size.height);
                } completion:^(BOOL finished) {
                    
                }];
            } else {
                CGFloat height = HQLiOS10BeforeFixedHeight + [self calculateContentLabelHeightWithContent:self.notificationModel.content.alertBody] + 1;
                height = height >= HQLMaxHeight ? HQLMaxHeight : height;
                [UIView animateWithDuration:HQLViewAnimateTime animations:^{
                    weakSelf.iOS10BeforeContentTopConstraint.constant = 6;
                    weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, height);
                    [weakSelf layoutIfNeeded];
                } completion:^(BOOL finished) {
                    
                }];
            }
            break;
        }
        case HQLDragDirectionNone: { break; }
    }
    NSLog(@"touchEnd : %@", NSStringFromCGPoint(touchPoint));
}

// 移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touches.anyObject locationInView:self];
    CGFloat distance = touchPoint.y - self.lastTouchPoint.y;
    if (distance < 0) { // 向上
        self.currentDirection = HQLDragDirectionUp;
        if (self.iOS10) { // iOS10 样式 ---> 直接修改y值
            self.frame = CGRectMake(self.frame.origin.x, (self.frame.origin.y <= -38 ? -38 : self.frame.origin.y + distance), self.frame.size.width, self.frame.size.height);
            // 更新touchPoint
            touchPoint.y -= distance;
        } else {
            
        }
    } else { // 向下
        self.currentDirection = HQLDragDirectionDown;
        if (self.iOS10) {
            CGFloat y = self.frame.origin.y;
            y += self.frame.origin.y >= 38 ? 0 : (self.frame.origin.y >= 30 ? (distance * 0.001) : self.frame.origin.y >= 20 ? (distance * 0.01) : self.frame.origin.y >= 0 ? (distance * 0.02) : distance);
            self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
            // 更新touchPoint
            touchPoint.y -= distance;
        } else {
            // View变高
            CGFloat height = self.frame.size.height;
            // 判断View的height
            CGFloat fixedHeight = 38.5;
            CGFloat contentLabelHeight = [self calculateContentLabelHeightWithContent:self.notificationModel.content.alertBody];
            if (height >= fixedHeight + contentLabelHeight) {
                if (height >= fixedHeight + contentLabelHeight + 20) {
                    if (height >= fixedHeight + contentLabelHeight + 40) { // 一级一级递进
                        height += 0;
                    } else {
                        height += distance * 0.01;
                        self.iOS10BeforeContentTopConstraint.constant += distance * 0.01;
                    }
                } else {
                    height += distance * 0.05;
                    self.iOS10BeforeContentTopConstraint.constant += distance * 0.05;
                }
            } else {
                height += distance;
                self.iOS10BeforeContentTopConstraint.constant += 0;
            }
            height = height >= HQLMaxHeight ? HQLMaxHeight : height;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
        }
    }
    
//    NSLog(@"touchMove : %@, distance : %g, lastPoint : %@", NSStringFromCGPoint(touchPoint), distance, NSStringFromCGPoint(self.lastTouchPoint));
    self.lastTouchPoint = touchPoint;
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

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

//#define HQLWeakSelf __weak typeof(self) weakSelf = self

#define HQLDefaultWidth [UIScreen mainScreen].bounds.size.width

#define HQLiOS10BeforeHeight 70
#define HQLiOS10DefaultHeight 90
#define HQLiOS10FullHeight 105

#define HQLContentLabelFontSize 13

#define HQLViewStayTime 4.7
#define HQLViewAnimateTime 0.3

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
    
    // 设置iOS10下的阴影
    if (self.iOS10) {
        self.iOS10MaskView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.iOS10MaskView.layer.shadowOpacity = 0.4;
        self.iOS10MaskView.layer.shadowRadius = 10;
        self.iOS10MaskView.layer.shadowOffset = CGSizeMake(0, 0);
    }
}

// 点击
- (void)tap {
    if (!self.notificationModel) return;
//    [[NSNotificationCenter defaultCenter] postNotificationName:HQLShowNotificationViewDidClickNotification object:self.notificationModel];
    [self hideView];
}

// 隐藏View
- (void)hideView {
//    HQLWeakSelf;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:HQLViewAnimateTime animations:^{
        weakSelf.frame = CGRectMake(0, -weakSelf.frame.size.height, weakSelf.frame.size.width, weakSelf.frame.size.height);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

// 显示View
- (void)showView {
    [[self appRootViewController].view addSubview:self];
    
//    HQLWeakSelf;
    __weak typeof(self) weakSelf = self;
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
        width = HQLDefaultWidth - 33;
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
    CGPoint touchPoint = [touch locationInView:self];
    NSLog(@"touchBegan : %@", NSStringFromCGPoint(touchPoint));
}

// 取消
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self];
    NSLog(@"touchCancel : %@", NSStringFromCGPoint(touchPoint));
}

// 结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self];
    NSLog(@"touchEnd : %@", NSStringFromCGPoint(touchPoint));
}

// 移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self];
    NSLog(@"touchMove : %@", NSStringFromCGPoint(touchPoint));
}

#pragma mark - setter

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

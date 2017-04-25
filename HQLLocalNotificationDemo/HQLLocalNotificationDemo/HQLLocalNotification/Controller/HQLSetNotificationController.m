//
//  HQLSetNotificationController.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/22.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLSetNotificationController.h"

#import "HQLSetNotificationView.h"

#import "HQLLocalNotificationModel.h"

#define HQLNotificationSubIdentifier @"HQLNotificationSubIdentifier"

@interface HQLSetNotificationController () <UIScrollViewDelegate, HQLSetNotificationViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) HQLSetNotificationView *setNotificationView;

@property (strong, nonatomic) UIButton *confirmButton;

@end

@implementation HQLSetNotificationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:(247 / 255.0) green:(248 / 255.0) blue:(250 / 255.0) alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self scrollView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self controllerConfig];
}

#pragma mark - event 

- (void)controllerConfig {
    NSString *string = @"新建";
    if (self.model) {
        [self.setNotificationView setNotificationModel:self.model];
        string = @"保存";
    } else {
        [self setNotificationView];
    }
    [self.confirmButton setTitle:string forState:UIControlStateNormal];
    [self calculateFrame];
}

- (void)calculateFrame {
    CGFloat scorllViewHeight = self.scrollView.frame.size.height;
    CGFloat bottomHeight = 50 + 20 * 2; // 底部button占的高度
    CGFloat contentHeight = CGRectGetMaxY(self.setNotificationView.frame) + bottomHeight;
    if (contentHeight < (scorllViewHeight + 1)) {
        contentHeight = scorllViewHeight + 1;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, contentHeight);
    
    CGFloat width = self.scrollView.frame.size.width;
    self.confirmButton.frame = CGRectMake(width * 0.1, contentHeight - 50 - 20, width * 0.8, 50);
}

- (void)confirmButtonDidClick:(UIButton *)button {
    // 获取model
    HQLLocalNotificationModel *model = [self.setNotificationView getCurrentNotificationModel];
    if (!self.model) {
        model.subIdentifier = [NSString stringWithFormat:@"%@%@", HQLNotificationSubIdentifier, [self nowDateString]];
    }
    if (self.confirmBlock) {
        self.confirmBlock(model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)nowDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SS"];
    return [formatter stringFromDate:[NSDate date]];
}

#pragma mark - scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - set notification view delegate

- (void)setNotificationViewDidChangeFrame:(HQLSetNotificationView *)setView {
    [self calculateFrame];
}

#pragma mark - setter

- (void)setModel:(HQLLocalNotificationModel *)model {
    _model = model;
}

#pragma mark - getter

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(0, 0, 100, 50);
        _confirmButton.layer.cornerRadius = 25;
        _confirmButton.layer.masksToBounds = YES;
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[UIColor colorWithRed:0 green:(211 / 255.0) blue:(221 / 255.0) alpha:1]];
        
        [_confirmButton addTarget:self action:@selector(confirmButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_confirmButton];
    }
    return _confirmButton;
}

- (HQLSetNotificationView *)setNotificationView {
    if (!_setNotificationView) {
        _setNotificationView = [HQLSetNotificationView setNotificationView];
        _setNotificationView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, 600);
        _setNotificationView.delegate = self;
        
        [self.scrollView addSubview:_setNotificationView];
    }
    return _setNotificationView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor colorWithRed:(247 / 255.0) green:(248 / 255.0) blue:(250 / 255.0) alpha:1];
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

@end

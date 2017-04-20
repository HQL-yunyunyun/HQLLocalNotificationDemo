//
//  HQLTestController.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/3/2.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLTestController.h"

#import "HQLNotificationSettingView.h"

#import "HQLSetNotificationView.h"

@interface HQLTestController ()

@property (strong, nonatomic) HQLNotificationSettingView *settingView;

@property (strong, nonatomic) HQLSetNotificationView *setNotificationView;

@end

@implementation HQLTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
//    [self.view addGestureRecognizer:tap];
//    [self settingView];
//    [self setNotificationView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self setNotificationView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNotificationView];
}

- (void)tap {
//    [self.settingView notificationContent:^(NSArray *targetDateArray, HQLLocalNotificationRepeat repeatMode, HQLLocalNotificationMode notificationMode) {
//        NSLog(@"dateArray : %@, repeatMode : %d, notificationMode : %d", targetDateArray, repeatMode, notificationMode);
//    }];
}

- (HQLSetNotificationView *)setNotificationView {
    if (!_setNotificationView) {
        _setNotificationView = [HQLSetNotificationView setNotificationView];
        _setNotificationView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height * 0.5);
        [self.view addSubview:_setNotificationView];
    }
    return _setNotificationView;
}

- (HQLNotificationSettingView *)settingView {
    if (!_settingView) {
        _settingView = [HQLNotificationSettingView notificationSettingViewWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height * 0.5)];
        [_settingView showDateArray:@[[NSDate date]] repeatMode:HQLLocalNotificationWeekRepeat notificationMode:HQLLocalNotificationAlarmMode];
        [self.view addSubview:_settingView];
    }
    return _settingView;
}

@end

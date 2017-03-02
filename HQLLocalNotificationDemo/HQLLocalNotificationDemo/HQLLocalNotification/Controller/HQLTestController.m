//
//  HQLTestController.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/3/2.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLTestController.h"

#import "HQLNotificationSettingView.h"

@interface HQLTestController ()

@end

@implementation HQLTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HQLNotificationSettingView" owner:nil options:nil];
    HQLNotificationSettingView *settingView = array.firstObject;
    settingView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height * 0.5);
    [self.view addSubview:settingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "ViewController.h"
#import "HQLLocalNotificationConfig.h"
#import "HQLLocalNotificationModel.h"

@interface ViewController () <UNUserNotificationCenterDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [HQLLocalNotificationConfig replyNotificationAuthorization:[UIApplication sharedApplication] iOS10NotificationDelegate:self successComplete:^(BOOL isFirstGranted) {
        
    } failureComplete:^(BOOL isFirstGranted) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addNotification:(id)sender {
    HQLLocalNotificationContentModel *content = [[HQLLocalNotificationContentModel alloc] init];
    content.alertBody = @"屠龙宝刀,一点就送";
    content.alertTitle = @"传奇人物";
    HQLLocalNotificationModel *model = [[HQLLocalNotificationModel alloc] initContent:content repeatDateArray:@[[NSDate dateWithTimeIntervalSinceNow:60.0]] identify:@"firtIdentify" subIdentify:@"subIdentify" repeatMode:HQLLocalNotificationNoneRepeat notificationMode:HQLLocalNotificationAlarmMode isActivity:YES];
    [HQLLocalNotificationConfig addLocalNotificationWithModel:model completeBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"收到通知");
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"收到");
    completionHandler();
}

@end

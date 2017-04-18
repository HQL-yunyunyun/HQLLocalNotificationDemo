//
//  HQLAddNotificationController.m
//  HQLLocalNotificationDemo
//
//  Created by 何启亮 on 2017/2/21.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLAddNotificationController.h"
#import "HQLLocalNotificationModel.h"
#import "HQLLocalNotificationManager.h"
#import "HQLTestController.h"

@interface HQLAddNotificationController ()

@end

@implementation HQLAddNotificationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushToView:(UIBarButtonItem *)sender {
    HQLTestController *controller = [HQLTestController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)alarmModeNotification:(UIButton *)button {
    int constTag = 9000;
    NSInteger tag = button.tag - constTag;
    NSMutableArray <NSDate *>*dateArray = [NSMutableArray array];
    HQLLocalNotificationRepeat repeat = HQLLocalNotificationNoneRepeat;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone localTimeZone];
    switch (tag) {
        case 0: { // 早上九点不重复
            repeat = HQLLocalNotificationNoneRepeat;
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.hour = 9;
            NSDate *date = [calendar dateFromComponents:components];
            NSLog(@"早上九点不重复 : %@", date);
            [dateArray addObject:date];
            break;
        }
        case 1: { // 每天九点
            repeat = HQLLocalNotificationDayRepeat;
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.hour = 9;
            NSDate *date = [calendar dateFromComponents:components];
            NSLog(@"每天九点 : %@", date);
            [dateArray addObject:date];
            break;
        }
        case 2: { // 工作日九点
            repeat = HQLLocalNotificationWeekRepeat;
            for (int i = 1; i <= 5; i++) {
                NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:[HQLLocalNotificationConfig getWeekdayDateWithWeekday:(i+1)]];
                components.hour = 9;
                NSDate *date = [calendar dateFromComponents:components];
                NSLog(@"星期%d九点 : %@", i, date);
                [dateArray addObject:date];
            }
            break;
        }
        case 3: { // 周末九点
            repeat = HQLLocalNotificationWeekRepeat;
            for (int i = 0; i < 2; i++) {
                int weekday = 0;
                if (i == 0) {
                    weekday = 1; // 周日
                } else if (i == 1) {
                    weekday = 7; // 周六
                }
                NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:[HQLLocalNotificationConfig getWeekdayDateWithWeekday:weekday]];
                components.hour = 9;
                NSDate *date = [calendar dateFromComponents:components];
                if (i == 0) {
                    NSLog(@"星期天九点 : %@", date);
                } else if (i == 1) {
                    NSLog(@"星期六九点 : %@", date);
                }
                
                [dateArray addObject:date];
            }
            break;
        }
        case 4: {
            [dateArray addObject:[NSDate dateWithTimeIntervalSinceNow:60]];
            repeat = HQLLocalNotificationNoneRepeat;
            break;
        }
        default: { break; }
    }
    
    NSString *subIdentifier = [NSString stringWithFormat:@"alarm-%@", [self nowDateString]];
    [[HQLLocalNotificationManager shareManger] addNotificationWithSubIdentifier:subIdentifier notificationMode:HQLLocalNotificationAlarmMode repeatMode:repeat alertTitle:@"test-test" alertBody:[button currentTitle] repeatDateArray:dateArray userInfo:nil badgeNumber:0 isActivity:YES complete:^(NSError *error) {
        
    }];
}

- (IBAction)scheduleModeNotification:(UIButton *)button {
    int constTag = 8000;
    NSInteger tag = button.tag - constTag;
    NSMutableArray <NSDate *>*dateArray = [NSMutableArray array];
    HQLLocalNotificationRepeat repeat = HQLLocalNotificationNoneRepeat;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    switch (tag) {
        case 0: { // 2.19九点不重复
            repeat = HQLLocalNotificationNoneRepeat;
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = 2017;
            components.month = 2;
            components.day = 19;
            components.hour = 9;
            NSDate *date = [calendar dateFromComponents:components];
            NSLog(@"2.19九点不重复 : %@", date);
            [dateArray addObject:date];
            break;
        }
        case 1: { // 每月19号 18号九点
            repeat = HQLLocalNotificationMonthRepeat;
            for (int i = 0; i < 2; i++) {
                NSDateComponents *components = [[NSDateComponents alloc] init];
                if (i == 0) {
                    components.day = 18; // 周日
                } else if (i == 1) {
                    components.day = 19; // 周六
                }
                components.hour = 9;
                NSDate *date = [calendar dateFromComponents:components];
                if (i == 0) {
                    NSLog(@"每月18号九点 : %@", date);
                } else if (i == 1) {
                    NSLog(@"每月19号九点 : %@", date);
                }
                
                [dateArray addObject:date];
            }
            break;
        }
        case 2: { // 每年2.19 2.18九点
            repeat = HQLLocalNotificationYearRepeat;
            for (int i = 0; i < 2; i++) {
                NSDateComponents *components = [[NSDateComponents alloc] init];
                if (i == 0) {
                    components.day = 18; // 周日
                } else if (i == 1) {
                    components.day = 19; // 周六
                }
                components.month = 2;
                components.hour = 9;
                NSDate *date = [calendar dateFromComponents:components];
                if (i == 0) {
                    NSLog(@"每年2.18九点 : %@", date);
                } else if (i == 1) {
                    NSLog(@"每年2.19九点 : %@", date);
                }
                
                [dateArray addObject:date];
            }
            break;
        }
        case 3: { // 2.25九点不重复
            repeat = HQLLocalNotificationNoneRepeat;
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = 2017;
            components.month = 2;
            components.day = 25;
            components.hour = 9;
            NSDate *date = [calendar dateFromComponents:components];
            NSLog(@"2.25九点不重复 : %@", date);
            [dateArray addObject:date];
            break;
        }
        default: { break; }
    }
    
    NSString *subIdentifier = [NSString stringWithFormat:@"schedule-%@", [self nowDateString]];
    [[HQLLocalNotificationManager shareManger] addNotificationWithSubIdentifier:subIdentifier notificationMode:HQLLocalNotificationScheduleMode repeatMode:repeat alertTitle:@"test-test-test" alertBody:[button currentTitle] repeatDateArray:dateArray userInfo:nil badgeNumber:0 isActivity:YES complete:^(NSError *error) {
        
    }];
}

- (NSString *)nowDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SS"];
    return [formatter stringFromDate:[NSDate date]];
}

@end

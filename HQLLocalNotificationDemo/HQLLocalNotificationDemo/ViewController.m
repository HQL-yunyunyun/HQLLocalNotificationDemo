//
//  ViewController.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "ViewController.h"
#import "HQLLocalNotificationManager.h"

#define HQLNotificationTableViewCell @"HQLNotificationTableViewCell"

@interface ViewController () <UNUserNotificationCenterDelegate, UITableViewDelegate, UITableViewDataSource, HQLLocalNotificationManagerDelegate>

@property (strong, nonatomic) HQLLocalNotificationManager *notificationManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"星期日 : %@", [self getWeekdayDateWithWeekday:1]);
//    NSLog(@"星期一 : %@", [self getWeekdayDateWithWeekday:2]);
//    NSLog(@"星期二 : %@", [self getWeekdayDateWithWeekday:3]);
//    NSLog(@"星期三 : %@", [self getWeekdayDateWithWeekday:4]);
//    NSLog(@"星期四 : %@", [self getWeekdayDateWithWeekday:5]);
//    NSLog(@"星期五 : %@", [self getWeekdayDateWithWeekday:6]);
//    NSLog(@"星期六 : %@", [self getWeekdayDateWithWeekday:7]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - HQLLocalNotification delegate

- (void)userNotificationDelegateNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification {
    [self.tableView reloadData];
}

- (void)userNotificationDelegateNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response {
    [self.tableView reloadData];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationManager.notificationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HQLNotificationTableViewCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:HQLNotificationTableViewCell];
    }
    
    HQLLocalNotificationModel *model = self.notificationManager.notificationArray[indexPath.row];
    cell.textLabel.text = model.content.alertBody;
    if (model.isActivity) {
        cell.detailTextLabel.text = @"启用";
    } else {
        cell.detailTextLabel.text = @"不启用";
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除
        HQLLocalNotificationModel *model = self.notificationManager.notificationArray[indexPath.row];
        [self.notificationManager deleteNotificationWithModel:model];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        [self.notificationManager showNotification];
    }
}

#pragma mark - table view delegate

- (NSDate *)getWeekdayDateWithWeekday:(NSInteger)weekday {
    if (weekday < 1 || weekday > 7) {
            return nil;
    }
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSInteger nowWeekday = [calendar component:NSCalendarUnitWeekday fromDate:nowDate];
    return [self getPriusDateFromDate:nowDate withDay:(weekday - nowWeekday)];
}

- (NSDate *)getPriusDateFromDate:(NSDate *)date withDay:(NSInteger)day {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    return mDate;
}

- (HQLLocalNotificationManager *)notificationManager {
    if (!_notificationManager) {
        _notificationManager = [HQLLocalNotificationManager shareManger];
        _notificationManager.delegate = self;
    }
    return _notificationManager;
}

@end

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

@interface ViewController () <UNUserNotificationCenterDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) HQLLocalNotificationManager *notificationManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

#pragma mark - table view delegate



- (HQLLocalNotificationManager *)notificationManager {
    if (!_notificationManager) {
        _notificationManager = [HQLLocalNotificationManager shareManger];
    }
    return _notificationManager;
}

@end

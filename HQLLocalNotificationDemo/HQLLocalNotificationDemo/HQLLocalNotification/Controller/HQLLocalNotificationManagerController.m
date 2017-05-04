//
//  HQLLocalNotificationManagerController.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/22.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationManagerController.h"
#import "HQLSetNotificationController.h"
#import "HQLLocalNotificationManagerCell.h"
#import "HQLLocalNotificationManager.h"
#import "HQLShowNotificationView.h"
#import "HQLLocalNotificationHeader.h"

#define HQLTableViewCellHeight 80

#define HQLNotificationManagerCellReuseID @"HQLNotificationManagerCellReuseID"

@interface HQLLocalNotificationManagerController () <UITableViewDelegate, UITableViewDataSource, HQLLocalNotificationManagerCellDelegate, HQLLocalNotificationManagerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *createButton;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) HQLLocalNotificationManager *manager;

@end

@implementation HQLLocalNotificationManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self controllerConfig];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.editButton.selected = YES;
    [self editButtonDidClick:self.editButton];
    [self.tableView reloadData];
}

#pragma mark - controller config

- (void)controllerConfig {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
    
    UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cleanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cleanButton setTitle:@"清除通知" forState:UIControlStateNormal];
    [cleanButton sizeToFit];
    [cleanButton addTarget:self action:@selector(cleanAllNotification) forControlEvents:UIControlEventTouchUpInside];
    [cleanButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cleanButton];
    
    [self.view setBackgroundColor:HQLBackgroundColor];
    [self scrollView];
    [self createButton];
    [self tableView];
    
    self.title = @"提醒";
    [self calculateFrame];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hql_applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNotificationViewDidHide:) name:HQLShowNotificationViewDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocalNotification:) name:HQLiOS10BeforeDidReceiveLocalNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

// 接受到了 本地通知
- (void)didReceiveLocalNotification:(NSNotification *)notification {
    [self.tableView reloadData];
}

// 点击
- (void)showNotificationViewDidClick:(NSNotification *)notification {

}

// 隐藏
- (void)showNotificationViewDidHide:(NSNotification *)notification {
    
}

// 当进入前台， 更新通知的状态
- (void)hql_applicationDidBecomeActive {
    [self.manager updateNotificationActivity];
    [self.tableView reloadData];
}


- (void)calculateFrame {
    // 计算tableView的高度
    CGFloat tableViewHeight = HQLTableViewCellHeight * self.manager.notificationArray.count;
    self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, tableViewHeight);
    CGFloat bottomHeight = 50 + 20 * 2;
    CGFloat contentHeight = tableViewHeight + bottomHeight;
    CGFloat scrollViewHeight = self.scrollView.frame.size.height;
    CGFloat scrollViewWidth = self.scrollView.frame.size.width;
    if (contentHeight < (scrollViewHeight + 1)) {
        contentHeight = scrollViewHeight + 1;
    }
    
    self.scrollView.contentSize = CGSizeMake(scrollViewWidth, contentHeight);
    
    self.createButton.frame = CGRectMake(scrollViewWidth * 0.1, contentHeight - 20 - 50, scrollViewWidth * 0.8, 50);
}

- (void)createButtonDidClick:(UIButton *)button {
    // 创建localNotification
    __weak typeof(self) weakSelf = self;
    HQLSetNotificationController *setController = [[HQLSetNotificationController alloc] init];
    setController.confirmBlock = ^(HQLLocalNotificationModel * _Nonnull model) {
      [weakSelf.manager addNotificationWithModel:model complete:^(NSError *error) {
          if (error) {
              NSLog(@"添加错误 : %@", error);
          } else {
              NSLog(@"添加成功");
          }
          dispatch_async(dispatch_get_main_queue(), ^{
              [weakSelf calculateFrame];
              [weakSelf.tableView reloadData];
          });
      }];
    };
    
    [self.navigationController pushViewController:setController animated:YES];
}

- (void)editButtonDidClick:(UIButton *)button {
    button.selected = !button.isSelected;
    [self.tableView setEditing:button.isSelected animated:YES];
}

- (void)cleanAllNotification {
    [self.manager showNotification];
    [self.manager deleteAllNotification];
    [self.tableView reloadData];
    [self calculateFrame];
    [self.manager showNotification];
    
    HQLLocalNotificationModel *model = [[HQLLocalNotificationModel alloc] init];
    HQLLocalNotificationContentModel *content = [[HQLLocalNotificationContentModel alloc] init];
    content.alertBody = @"alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody-alertBody";
    content.alertTitle = @"alertTitle";
//    content.soundName = [[NSBundle mainBundle] pathForResource:@"HQLDefaultSound" ofType:@"mp3"];
    model.content = content;
    HQLShowNotificationView *view = [HQLShowNotificationView showNotificationViewiOS10BeforeStyle];
    view.notificationModel = model;
    [view showView];
}

#pragma mark - notification manager delegate

- (void)userNotificationDelegateNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification {
//    NSLog(@"通知1");
    [self.tableView reloadData];
    [self calculateFrame];
}

- (void)userNotificationDelegateNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response {
//    NSLog(@"通知2");
    [self.tableView reloadData];
    [self calculateFrame];
}

#pragma mark - notification manager cell delegate

- (void)localNotificationManagerCellDidClickStatusSwitch:(HQLLocalNotificationManagerCell *)cell isOn:(BOOL)isOn {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HQLLocalNotificationModel *model = self.manager.notificationArray[indexPath.row];
    [self.manager setNotificationActivity:isOn notificationModel:model];
    
    if (isOn && !model.isActivity) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        HQLShowAlertView(@"该提醒不能触发", @"该提醒因超过时间，不能激活");
    }
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HQLTableViewCellHeight;
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
        HQLLocalNotificationModel *model = self.manager.notificationArray[indexPath.row];
        [self.manager deleteNotificationWithModel:model];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self calculateFrame];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editButton.isSelected) {
        // 在编辑状态 跳转到 设置界面
        HQLSetNotificationController *controller = [[HQLSetNotificationController alloc] init];
        HQLLocalNotificationModel *model = self.manager.notificationArray[indexPath.row];
        controller.model = model;
        __weak typeof(self) weakSelf = self;
        controller.confirmBlock = ^(HQLLocalNotificationModel *targetModel) {
            // 修改
            NSMutableDictionary *updateProperty = [[NSMutableDictionary alloc] init];
            [updateProperty setObject:targetModel.content forKey:@"content"];
            [updateProperty setObject:targetModel.repeatDateArray forKey:@"repeatDateArray"];
            [updateProperty setObject:[NSNumber numberWithBool:targetModel.isActivity] forKey:@"isActivity"];
            [updateProperty setObject:@(targetModel.repeatMode) forKey:@"repeatMode"];
            [updateProperty setObject:@(targetModel.notificationMode) forKey:@"notificationMode"];
            [weakSelf.manager updateNotificationWithPropertyDict:updateProperty notificationModel:model];
            
//            [weakSelf calculateFrame];
//            [weakSelf.tableView reloadData];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.manager.notificationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HQLLocalNotificationManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:HQLNotificationManagerCellReuseID];
    cell.delegate = self;
    cell.model = self.manager.notificationArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - getter

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editButton setTitle:@"保存" forState:UIControlStateSelected];
        [_editButton sizeToFit];
        [_editButton addTarget:self action:@selector(editButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _editButton;
}

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _createButton.frame = CGRectMake(0, 0, 100, 50);
        _createButton.layer.cornerRadius = 25;
        _createButton.layer.masksToBounds = YES;
        [_createButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_createButton setBackgroundColor:[UIColor colorWithRed:0 green:(211 / 255.0) blue:(221 / 255.0) alpha:1]];
        [_createButton setTitle:@"新建提醒事件" forState:UIControlStateNormal];
        
        [_createButton addTarget:self action:@selector(createButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_createButton];
    }
    return _createButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, HQLScreenWidth, 200) style:UITableViewStylePlain];
        _tableView.allowsSelectionDuringEditing = YES; // 在编辑状态都可以点击cell
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"HQLLocalNotificationManagerCell" bundle:nil] forCellReuseIdentifier:HQLNotificationManagerCellReuseID];
        
        [self.scrollView addSubview:_tableView];
    }
    return _tableView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, HQLScreenWidth, HQLScreenHeight - 64)];
        [_scrollView setBackgroundColor:HQLBackgroundColor];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (HQLLocalNotificationManager *)manager {
    if (!_manager) {
        _manager = [HQLLocalNotificationManager shareManger];
        _manager.delegate = self;
    }
    return _manager;
}

@end

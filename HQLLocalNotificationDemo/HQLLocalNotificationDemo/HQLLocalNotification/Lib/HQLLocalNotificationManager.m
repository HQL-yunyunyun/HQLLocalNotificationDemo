//
//  HQLLocalNotificationManager.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/21.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationManager.h"
#import "HQLLocalNotificationModel.h"

#define HQLLocalNotificationArray @"HQLLocalNotificationArray"

@interface HQLLocalNotificationManager () <UNUserNotificationCenterDelegate>

@property (strong, nonatomic, readwrite) NSMutableArray <HQLLocalNotificationModel *>*notificationArray;

@end

@implementation HQLLocalNotificationManager

+ (instancetype)shareManger {
    static HQLLocalNotificationManager *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [HQLLocalNotificationConfig replyNotificationAuthorization:[UIApplication sharedApplication] iOS10NotificationDelegate:self successComplete:^(BOOL isFirstGranted) {
            // 授权成功
        } failureComplete:^(BOOL isFirstGranted) {
            // 授权失败
        }];
        self.identifier = HQLLocalNotificationDefaultIdentifier;
        self.alertLaunchImage = @"Default";
        self.soundName = @""; // 设置的时候有默认的
        
        [self getNotification];
        
        [self showNotification];
        
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - notificationModel operation method

// 增
- (void)addNotificationWithSubIdentifier:(NSString *)subIdentifier
                                  notificationMode:(HQLLocalNotificationMode)notificationMode
                                  repeatMode:(HQLLocalNotificationRepeat)repeatMode
                                  alertTitle:(NSString *)alertTitle
                                  alertBody:(NSString *)alertBody
                                  repeatDateArray:(NSArray<NSDate *> *)repeatDateArray
                                  userInfo:(NSDictionary *)userInfo
                                  badgeNumber:(NSInteger)badgeNumber
                                  isActivity:(BOOL)isActivity
                                  complete:(void (^)(NSError *))completeBlock
{
    HQLLocalNotificationContentModel *content = [[HQLLocalNotificationContentModel alloc] init];
    content.alertBody = alertBody;
    content.alertTitle = alertTitle;
    
    NSMutableDictionary *aUserInfo = [NSMutableDictionary dictionary];
    if (userInfo) {
        aUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    }
    [aUserInfo setValue:@"holdPlace" forKey:@"holdPlace"];
    content.userInfo = aUserInfo.copy;
    
    content.applicationIconBadgeNumber = badgeNumber;
    HQLLocalNotificationModel *model = [[HQLLocalNotificationModel alloc] initContent:content repeatDateArray:repeatDateArray identifier:self.identifier subIdentifier:subIdentifier repeatMode:repeatMode notificationMode:notificationMode isActivity:isActivity];
    
    __weak typeof(self) weakSelf = self;
    __block int index = 0;
    __block NSError *targetError = nil; // 保存最近一次的error
    [HQLLocalNotificationConfig addLocalNotificationWithModel:model completeBlock:^(NSError *error) {
        if (error) {
            // 添加错误
            NSLog(@"add notification error : %@", error);
            targetError = error;
        } else {
            NSLog(@"add notification success");
        }
        // 都得添加到当前数组中
        index++;
        if (index == model.repeatDateArray.count || !model.isActivity) {
            [weakSelf.notificationArray addObject:model];
            [weakSelf saveNotification]; // 保存到本机中
            if (completeBlock) {
                completeBlock(targetError);
            }
        }
    }];
}

- (void)addNotificationWithModel:(HQLLocalNotificationModel *)model complete:(void (^)(NSError *))completeBlock {
    [self addNotificationWithSubIdentifier:model.subIdentifier
                                notificationMode:model.notificationMode
                                repeatMode:model.repeatMode
                                alertTitle:model.content.alertTitle
                                alertBody:model.content.alertBody
                                repeatDateArray:model.repeatDateArray
                                userInfo:model.content.userInfo
                                badgeNumber:model.content.applicationIconBadgeNumber
                                isActivity:model.isActivity
                                complete:completeBlock];
}

// 删
- (void)deleteNotificationWithModel:(HQLLocalNotificationModel *)model {
    // 先删除通知,再删除model
    if (model) {
        // 判断model是否在队列中
        if (![self.notificationArray containsObject:model]) {
            // 不在队列中
            NSLog(@"model 不在队列中");
            return;
        }
        [self removeNotificationWithIdentifier:model.identifier subIdentifier:model.subIdentifier];
        [self.notificationArray removeObject:model];
        [self saveNotification];
    } else {
        // model为空
        NSLog(@"model不能为空");
    }
}

- (void)deleteNotificationWithIdentifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier {
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentifier:identifier subIdentifier:subIdentifier];
    if (model) {
        [self deleteNotificationWithModel:model];
    } else {
        // 不存在该model
        NSLog(@"不存在该model");
    }
}

- (void)deleteAllNotification {
    [self.notificationArray removeAllObjects];
    [self saveNotification];
    [HQLLocalNotificationConfig removeAllNotification];
}

// 改
- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict identifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier {
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentifier:identifier subIdentifier:subIdentifier];
    if (model) {
        [self updateNotificationWithPropertyDict:propertyDict notificationModel:model];
    } else {
        // 不存在该model
        NSLog(@"不存在该model");
    }
}

- (void)updateNotificationWithPropertyDict:(NSDictionary *)propertyDict notificationModel:(HQLLocalNotificationModel *)model {
    if (model) {
        // 判断model是否在队列中
        if (![self.notificationArray containsObject:model]) {
            // 不在队列中
            NSLog(@"model 不在队列中");
            return;
        }
        // 先取消通知
        [self removeNotificationWithIdentifier:model.identifier subIdentifier:model.subIdentifier];
        for (NSString *key in propertyDict.allKeys) {
            [model setValue:propertyDict[key] forKeyPath:key];
        }
        [HQLLocalNotificationConfig addLocalNotificationWithModel:model completeBlock:^(NSError *error) {
            if (error) {
                // 添加错误
                NSLog(@"add notification error : %@", error);
            } else {
                NSLog(@"add notification success");
            }
        }];
        
        [self saveNotification]; // 保存
    } else {
        // model为空
        NSLog(@"model不能为空");
    }
}

// 查
- (HQLLocalNotificationModel *)getNotificationModelWithIdentifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier {
    for (HQLLocalNotificationModel *model in self.notificationArray) {
        if ([model.subIdentifier isEqualToString:subIdentifier] && [model.identifier isEqualToString:identifier]) {
            return model;
        }
    }
    return nil;
}

// 设置通知是否启用
- (void)setNotificationActivity:(BOOL)isActivity notificationModel:(HQLLocalNotificationModel *)model {
    if (model) {
        // 判断model是否在队列中
        if (![self.notificationArray containsObject:model]) {
            // 不在队列中
            NSLog(@"model 不在队列中");
            return;
        }
        [self removeNotificationWithIdentifier:model.identifier subIdentifier:model.subIdentifier];
        model.isActivity = isActivity;
        [HQLLocalNotificationConfig addLocalNotificationWithModel:model completeBlock:^(NSError *error) {
            if (error) {
                // 添加错误
                NSLog(@"add notification error : %@", error);
            } else {
                NSLog(@"add notification success");
            }
        }];
        
        [self saveNotification]; // 保存
    } else {
        // model为空
        NSLog(@"model不能为空");
    }
}

- (void)setNotificationActivity:(BOOL)isActivity identifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier {
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentifier:identifier subIdentifier:subIdentifier];
    if (model) {
        [self setNotificationActivity:isActivity notificationModel:model];
    } else {
        // 不存在该model
        NSLog(@"不存在该model");
    }
}

- (void)updateNotificationActivity {
    for (HQLLocalNotificationModel *model in self.notificationArray) {
        if (model.isActivity) {
            [self notificationIsActivity:[NSString stringWithFormat:@"%@%@%@", model.identifier, HQLLocalNotificationIdentifierLinkChar, model.subIdentifier]];
        }
    }
}

#pragma mark - user notification center delegate

// App处于前台接收通知时
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // 判断是否还是 活动
    [self notificationIsActivity:notification.request.identifier];
    if ([self.delegate respondsToSelector:@selector(userNotificationDelegateNotificationCenter:willPresentNotification:)]) {
        [self.delegate userNotificationDelegateNotificationCenter:center willPresentNotification:notification];
    }
    completionHandler(UNNotificationPresentationOptionAlert |
                                   UNNotificationPresentationOptionBadge |
                                   UNNotificationPresentationOptionSound);
}

// 点击通知进入app或者
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // 判断是否还是 活动
    [self notificationIsActivity:response.notification.request.identifier];
    if ([self.delegate respondsToSelector:@selector(userNotificationDelegateNotificationCenter:didReceiveNotificationResponse:)]) {
        [self.delegate userNotificationDelegateNotificationCenter:center didReceiveNotificationResponse:response];
    }
    completionHandler();
}

// 通知触发后,判断该通知组是否还活动 isActivity
- (void)notificationIsActivity:(NSString *)notificationIdentifier {
    NSArray *identifierArray = [notificationIdentifier componentsSeparatedByString:HQLLocalNotificationIdentifierLinkChar];
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentifier:identifierArray[0] subIdentifier:identifierArray[1]];
    if (model) {
        if (model.repeatMode == HQLLocalNotificationNoneRepeat) { // 不重复
            if (model.notificationMode == HQLLocalNotificationAlarmMode) {
                model.isActivity = NO; // 只要是 闹钟模式, 一旦触发了,就会变成不启用(闹钟模式的不循环只有一个通知)
            } else if (model.notificationMode == HQLLocalNotificationScheduleMode) {
                // 日程模式, 因为日程模式可以有好几个日期,所以所有的通知都触发了才能变成不启用
                for (NSDate *date in model.repeatDateArray) {
                    if ([date compare:[NSDate date]] == NSOrderedDescending) {
                        model.isActivity = YES;
                        break; // 跳出循环
                    } else {
                        model.isActivity = NO;
                    }
                }
            }
        }
        
        [self saveNotification]; // 保存修改
    } else {
        NSLog(@"不存在该model");
    }
}

#pragma mark - private method

- (void)showNotification {
    if (iOS10_OR_LATER) {
        [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            for (UNNotificationRequest *request in requests) {
                NSLog(@"%@", request);
            }
        }];
    } else {
        for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            NSLog(@"%@", notification);
        }
    }
}

- (void)showDeliveredNotification {
    if (iOS10_OR_LATER) {
        [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            
        }];
    } else {
        
    }
}

- (void)removeNotificationWithIdentifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier {
    HQLLocalNotificationModel *model = [self getNotificationModelWithIdentifier:identifier subIdentifier:subIdentifier];
    for (int i = 0; i < model.repeatDateArray.count; i++) {
        [HQLLocalNotificationConfig removeNotificationWithNotificationIdentifier:[NSString stringWithFormat:@"%@%@%@%@%d", model.identifier, HQLLocalNotificationIdentifierLinkChar, model.subIdentifier, HQLLocalNotificationIdentifierLinkChar, i]];
    }
}

#pragma mark - userDefaults method

- (void)getNotification {
    NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:HQLLocalNotificationArray];
    self.notificationArray = [NSMutableArray array];
    if (array) {
        for (NSData *data in array) {
            [self.notificationArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        }
    } else {
        [HQLLocalNotificationConfig removeAllNotification];
    }
}

- (void)saveNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.notificationArray.count];
    for (HQLLocalNotificationModel *model in self.notificationArray) {
        [array addObject:[NSKeyedArchiver archivedDataWithRootObject:model]];
    }
    [defaults setObject:array forKey:HQLLocalNotificationArray];
    [defaults synchronize];
}

@end

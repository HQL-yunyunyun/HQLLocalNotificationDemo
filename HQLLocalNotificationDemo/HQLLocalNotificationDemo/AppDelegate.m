//
//  AppDelegate.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/17.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "AppDelegate.h"

#import "HQLLocalNotificationConfig.h"
#import "HQLLocalNotificationManager.h"
#import "HQLLocalNotificationManagerController.h"

#import "HQLShowNotificationView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    HQLLocalNotificationManagerController *controller = [[HQLLocalNotificationManagerController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = nav;
    
    if (launchOptions) {
        // 从通知点击进来
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        NSDictionary *userinfo = notification.userInfo;
        NSString *identifier = userinfo[HQLUserInfoIdentifier];
        [[HQLLocalNotificationManager shareManger] notificationIsActivity:identifier];
        
        NSLog(@"identifier : %@ alertBody:%@ alertTitle:%@ fireDate:%@", identifier, notification.alertBody, notification.alertTitle, notification.fireDate);
    }
    return YES;
}

// 收到远程通知才会实现的
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    
//}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSString *identifier = userinfo[HQLUserInfoIdentifier];
    [[HQLLocalNotificationManager shareManger] notificationIsActivity:identifier];
    
//    NSArray *identifierArray = [identifier componentsSeparatedByString:HQLLocalNotificationIdentifierLinkChar];
//    HQLShowNotificationView *notificationView = [HQLShowNotificationView showNotificationViewiOS10BeforeStyle];
//    notificationView.notificationModel = [[HQLLocalNotificationManager shareManger] getNotificationModelWithIdentifier:identifierArray[0] subIdentifier:identifierArray[1]];
//    [notificationView showView];
    
    NSLog(@"identifier : %@ alertBody:%@ alertTitle:%@ fireDate:%@", identifier, notification.alertBody, notification.alertTitle, notification.fireDate);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - notification Authorization

@end

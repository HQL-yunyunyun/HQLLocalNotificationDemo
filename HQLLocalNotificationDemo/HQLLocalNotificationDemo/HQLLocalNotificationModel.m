//
//  HQLLocalNotificationModel.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/18.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationModel.h"

@implementation HQLLocalNotificationModel

/*- (instancetype)initWithDate:(NSDate *)date content:(HQLLocalNotificationContentModel *)content repeatDateArray:(NSArray *)repeatDateArray identify:(NSString *)identify subIdentify:(NSString *)subIdentify repeatMode:(HQLLocalNotificationRepeat)repeatMode isRepeat:(BOOL)isRepeat {
    if (self = [super init]) {
        self.date = date;
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identify = identify;
        self.subIdentify = subIdentify;
        self.repeatMode = repeatMode;
        self.isRepeat = isRepeat;
    }
    return self;
}
- (nullable instancetype)initContent:(nonnull HQLLocalNotificationContentModel *)content repeatDateArray:(nonnull NSArray *)repeatDateArray identify:(nonnull NSString *)identify subIdentify:(nonnull NSString *)subIdentify repeatMode:(HQLLocalNotificationRepeat)repeatMode isRepeat:(BOOL)isRepeat {
    if (self = [super init]) {
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identify = identify;
        self.subIdentify = subIdentify;
        self.repeatMode = repeatMode;
        self.isRepeat = isRepeat;
    }
    return self;
}*/

- (nullable instancetype)initContent:(nonnull HQLLocalNotificationContentModel *)content
                                      repeatDateArray:(nonnull NSArray *)repeatDateArray
                                      identify:(nonnull NSString *)identify
                                      subIdentify:(nonnull NSString *)subIdentify
                                      repeatMode:(HQLLocalNotificationRepeat)repeatMode
                                      notificationMode:(HQLLocalNotificationMode)notificationMode
                                      isActivity:(BOOL)isActivity
{
    if (self = [super init]) {
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identify = identify;
        self.subIdentify = subIdentify;
        self.repeatMode = repeatMode;
        self.notificationMode = notificationMode;
        self.isActivity = isActivity;
    }
    return self;
}

#pragma mark - NSCodeing delegate

- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.repeatDateArray forKey:@"repeatDateArray"];
    [aCoder encodeObject:self.identify forKey:@"identify"];
    [aCoder encodeObject:self.subIdentify forKey:@"subIdentify"];
    [aCoder encodeInteger:self.repeatMode forKey:@"repeatModel"];
//    [aCoder encodeBool:self.isRepeat forKey:@"isRepeat"];
    [aCoder encodeInteger:self.notificationMode forKey:@"notificationMode"];
    [aCoder encodeBool:self.isActivity forKey:@"isActivity"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self.date = [aDecoder decodeObjectForKey:@"date"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.repeatDateArray = [aDecoder decodeObjectForKey:@"repeatDateArray"];
    self.identify = [aDecoder decodeObjectForKey:@"identify"];
    self.subIdentify = [aDecoder decodeObjectForKey:@"subIdentify"];
    self.repeatMode = (HQLLocalNotificationRepeat)[aDecoder decodeIntegerForKey:@"repeatMode"];
//    self.isRepeat = [aDecoder decodeBoolForKey:@"isRepeat"];
    self.notificationMode = (HQLLocalNotificationMode)[aDecoder decodeObjectForKey:@"notificationMode"];
    self.isActivity = [aDecoder decodeBoolForKey:@"isActivity"];
    return self;
}

@end

#pragma mark - local notification content

@implementation HQLLocalNotificationContentModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.alertBody forKey:@"alertBody"];
    [aCoder encodeObject:self.alertAction forKey:@"alertAction"];
    [aCoder encodeObject:self.alertLaunchImage forKey:@"alertLaunchImage"];
    [aCoder encodeObject:self.alertTitle forKey:@"alertTitle"];
    [aCoder encodeObject:self.soundName forKey:@"soundName"];
    [aCoder encodeInteger:self.applicationIconBadgeNumber forKey:@"applicationIconBadgeNumber"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.alertBody = [aDecoder decodeObjectForKey:@"alertBody"];
    self.alertAction = [aDecoder decodeObjectForKey:@"alertAction"];
    self.alertLaunchImage = [aDecoder decodeObjectForKey:@"alertLaunchImage"];
    self.alertTitle = [aDecoder decodeObjectForKey:@"alertTitle"];
    self.soundName = [aDecoder decodeObjectForKey:@"soundName"];
    self.applicationIconBadgeNumber = [aDecoder decodeIntegerForKey:@"applicationIconBadgeNumber"];
    self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    return self;
}


@end

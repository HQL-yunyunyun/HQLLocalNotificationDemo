//
//  HQLLocalNotificationModel.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/2/18.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationModel.h"

@implementation HQLLocalNotificationModel

/*- (instancetype)initWithDate:(NSDate *)date content:(HQLLocalNotificationContentModel *)content repeatDateArray:(NSArray *)repeatDateArray identifier:(NSString *)identifier subIdentifier:(NSString *)subIdentifier repeatMode:(HQLLocalNotificationRepeat)repeatMode isRepeat:(BOOL)isRepeat {
    if (self = [super init]) {
        self.date = date;
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identifier = identifier;
        self.subIdentifier = subIdentifier;
        self.repeatMode = repeatMode;
        self.isRepeat = isRepeat;
    }
    return self;
}
- (nullable instancetype)initContent:(nonnull HQLLocalNotificationContentModel *)content repeatDateArray:(nonnull NSArray *)repeatDateArray identifier:(nonnull NSString *)identifier subIdentifier:(nonnull NSString *)subIdentifier repeatMode:(HQLLocalNotificationRepeat)repeatMode isRepeat:(BOOL)isRepeat {
    if (self = [super init]) {
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identifier = identifier;
        self.subIdentifier = subIdentifier;
        self.repeatMode = repeatMode;
        self.isRepeat = isRepeat;
    }
    return self;
}*/

- (instancetype)init {
    if (self = [super init]) {
        self.content = [[HQLLocalNotificationContentModel alloc] init];
        self.repeatDateArray = [NSArray array];
        self.identifier = @"";
        self.subIdentifier = @"";
        self.repeatMode = HQLLocalNotificationNoneRepeat;
        self.isActivity = NO;
    }
    return self;
}

- (nullable instancetype)initContent:(nonnull HQLLocalNotificationContentModel *)content
                                      repeatDateArray:(nonnull NSArray *)repeatDateArray
                                      identifier:(nonnull NSString *)identifier
                                      subIdentifier:(nonnull NSString *)subIdentifier
                                      repeatMode:(HQLLocalNotificationRepeat)repeatMode
                                      notificationMode:(HQLLocalNotificationMode)notificationMode
                                      isActivity:(BOOL)isActivity
{
    if (self = [self init]) {
        self.content = content;
        self.repeatDateArray = repeatDateArray;
        self.identifier = identifier;
        self.subIdentifier = subIdentifier;
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
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.subIdentifier forKey:@"subIdentifier"];
    [aCoder encodeInteger:self.repeatMode forKey:@"repeatModel"];
//    [aCoder encodeBool:self.isRepeat forKey:@"isRepeat"];
    [aCoder encodeInteger:self.notificationMode forKey:@"notificationMode"];
    [aCoder encodeBool:self.isActivity forKey:@"isActivity"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self.date = [aDecoder decodeObjectForKey:@"date"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.repeatDateArray = [aDecoder decodeObjectForKey:@"repeatDateArray"];
    self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    self.subIdentifier = [aDecoder decodeObjectForKey:@"subIdentifier"];
    self.repeatMode = (HQLLocalNotificationRepeat)[aDecoder decodeIntegerForKey:@"repeatMode"];
//    self.isRepeat = [aDecoder decodeBoolForKey:@"isRepeat"];
    self.notificationMode = (HQLLocalNotificationMode)[aDecoder decodeObjectForKey:@"notificationMode"];
    self.isActivity = [aDecoder decodeBoolForKey:@"isActivity"];
    return self;
}

#pragma mark - setter

- (void)setIdentifier:(NSString *)identifier {
    NSAssert([identifier rangeOfString:HQLLocalNotificationIdentifierLinkChar].location == NSNotFound, @"标识字符不能有已定义字符");
    _identifier = identifier;
}

- (void)setSubIdentifier:(NSString *)subIdentifier {
    NSAssert([subIdentifier rangeOfString:HQLLocalNotificationIdentifierLinkChar].location == NSNotFound, @"标识字符不能有已定义字符");
    _subIdentifier = subIdentifier;
}

@end

#pragma mark - local notification content

@implementation HQLLocalNotificationContentModel

- (instancetype)init {
    if (self = [super init]) {
        self.alertBody = @"";
        self.alertAction = @"";
        self.alertLaunchImage = @"";
        self.alertTitle = @"";
        self.soundName = @"";
        self.applicationIconBadgeNumber = 0;
        self.userInfo = [NSDictionary dictionary];
    }
    return self;
}

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

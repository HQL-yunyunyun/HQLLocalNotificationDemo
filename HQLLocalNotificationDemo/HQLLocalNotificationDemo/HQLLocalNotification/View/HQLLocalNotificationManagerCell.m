//
//  HQLLocalNotificationManagerCell.m
//  HQLLocalNotificationDemo
//
//  Created by weplus on 2017/4/22.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLLocalNotificationManagerCell.h"

#import "HQLLocalNotificationModel.h"

@interface HQLLocalNotificationManagerCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;


@end

@implementation HQLLocalNotificationManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self cellConfig];
}

- (void)cellConfig {
    self.statusSwitch.alpha = 1;
    self.rightArrow.alpha = 0;
}

#pragma mark - event

- (IBAction)statusSwitchDidClick:(UISwitch *)sender {
    self.timeLabel.alpha = sender.isOn ? 1 : 0.4;
    if (self.delegate) {
        [self.delegate localNotificationManagerCellDidClickStatusSwitch:self isOn:sender.isOn];
    }
}

- (void)cellChangeEditing {
    self.rightArrow.alpha = self.isEditing ? 1 : 0;
    self.statusSwitch.alpha = self.isEditing ? 0 : 1;
}

#pragma mark - setter 

- (void)setModel:(HQLLocalNotificationModel *)model {
    _model = model;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [self.timeLabel setText:[formatter stringFromDate:model.repeatDateArray.firstObject]];
    
    NSString *targetString = [NSString stringWithFormat:@"%@,", model.content.alertBody];
    targetString = [targetString stringByAppendingString:[model getModelDateDescription]];
    [self.descLabel setText:targetString];
    
    self.statusSwitch.on = model.isActivity;
    self.statusSwitch.alpha = 1;
    self.timeLabel.alpha = model.isActivity ? 1 : 0.4;
}

@end

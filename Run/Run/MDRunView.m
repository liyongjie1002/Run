//
//  MDRunView.m
//  Run
//
//  Created by 李永杰 on 2019/8/28.
//  Copyright © 2019 muheda. All rights reserved.
//

#import "MDRunView.h"

#define label_width     self.frame.size.width
#define label_height    self.frame.size.height / 3

@interface MDRunView ()
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger second;


@end

@implementation MDRunView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.speedLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.distanceLabel];
    }
    return self;
}

-(void)setTime:(CGFloat)time {
    
    self.hour = time / 3600;
    self.minute = (time - self.hour * 3600) / 60;
    self.second = time - self.hour * 3600 - self.minute * 60;
    [self setupTimeLabelText];
}
-(void)setSpeed:(CGFloat)speed {
    self.speedLabel.text = [NSString stringWithFormat:@"%lf m/s",speed];
}
-(void)setDistance:(CGFloat)distance {
    self.distanceLabel.text = [NSString stringWithFormat:@"%lf m",distance];
}

- (void)setupTimeLabelText
{
    NSString *hourText = @"";
    if (self.hour < 10)
    {
        hourText = [hourText stringByAppendingString:@"0"];
    }
    hourText = [hourText stringByAppendingString:[NSString stringWithFormat:@"%@", @(self.hour)]];
    
    NSString *minuteText = @"";
    if (self.minute < 10)
    {
        minuteText = [minuteText stringByAppendingString:@"0"];
    }
    minuteText = [minuteText stringByAppendingString:[NSString stringWithFormat:@"%@", @(self.minute)]];
    
    NSString *secondText = @"";
    if (self.second < 10)
    {
        secondText = [secondText stringByAppendingString:@"0"];
    }
    secondText = [secondText stringByAppendingString:[NSString stringWithFormat:@"%@", @(self.second)]];
    
    NSString *labelText = [NSString stringWithFormat:@"%@ : %@ : %@", hourText, minuteText, secondText];
    self.timeLabel.text = labelText;
}

#pragma mark get
-(UILabel *)speedLabel {
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, label_width, label_height)];
        _speedLabel.text = @"m/s";
        _speedLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _speedLabel;
}

-(UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, label_height, label_width, label_height)];
        _timeLabel.text = @"min";
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

-(UILabel *)distanceLabel {
    if (!_distanceLabel) {
        _distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*label_height, label_width, label_height)];
        _distanceLabel.text = @"0.00米";
        _distanceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _distanceLabel;
}

@end

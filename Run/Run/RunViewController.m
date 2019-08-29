//
//  RunViewController.m
//  Run
//
//  Created by 李永杰 on 2019/8/28.
//  Copyright © 2019 muheda. All rights reserved.
//

#import "RunViewController.h"
#import "MDRunView.h"
#import <AMapTrackKit/AMapTrackKit.h>
#import "APIKey.h"
#import "MDLocationManager.h"
#import "MDTimeManager.h"

@interface RunViewController () <AMapTrackManagerDelegate, MDLocationManagerDelegate, MDTimeManagerDelegate>

@property (nonatomic, strong) MDRunView             *runView;
@property (nonatomic, strong) UIButton              *runButton;
@property (nonatomic, strong) AMapTrackManager      *trackManager;
@property (nonatomic, strong) MDLocationManager     *locationManager;
@property (nonatomic, strong) MDTimeManager         *timeManager;

@end

@implementation RunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.runView];
    [self.view addSubview:self.runButton];
    
    [self initTrackManager];
    [self initTimeManager];
    [self initLocationManager];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
-(void)run {
/*
 // 点击开始运动
 1. 开启轨迹追踪上传
 2. 计时器
 3. 定位计算距离，速度
 */
    [self startTrackService];
    [self.timeManager start];
    [self.locationManager startLocation];
}
-(void)initTimeManager {
    self.timeManager = [[MDTimeManager alloc]init];
    self.timeManager.delegate = self;
}
-(void)initLocationManager {
    self.locationManager = [[MDLocationManager alloc]init];
    self.locationManager.delegate = self;
}
-(void)initTrackManager {
    if ([kAMapTrackServiceID length] <= 0 || [kAMapTrackTerminalID length] <= 0) {
        
        self.runButton.enabled = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"您需要指定ServiceID和TerminalID才可以使用轨迹服务"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    //Service ID 需要根据需要进行修改
    AMapTrackManagerOptions *option = [[AMapTrackManagerOptions alloc] init];
    option.serviceID = kAMapTrackServiceID;
    
    //初始化AMapTrackManager
    self.trackManager = [[AMapTrackManager alloc] initWithOptions:option];
    self.trackManager.delegate = self;
    
    //配置定位属性
    [self.trackManager setAllowsBackgroundLocationUpdates:YES];
    [self.trackManager setPausesLocationUpdatesAutomatically:NO];
}

/*开启轨迹服务 -> 开始轨迹采集*/
-(void)startTrackService {
    //开始服务
    AMapTrackManagerServiceOption *serviceOption = [[AMapTrackManagerServiceOption alloc] init];
    serviceOption.terminalID = kAMapTrackTerminalID;
    
    [self.trackManager startServiceWithOptions:serviceOption];
    
    [self startTrackGather];
}
-(void)startTrackGather {
    if (self.trackManager == nil) {
        return;
    }
    
    if ([self.trackManager.terminalID length] <= 0) {
        NSLog(@"您需要先开始轨迹服务，才可以开始轨迹采集。");
        return;
    }
    [self.trackManager startGatherAndPack];

}
#pragma mark - AMapTrackManagerDelegate

- (void)didFailWithError:(NSError *)error associatedRequest:(id)request {
   
    NSLog(@"didFailWithError:%@; --- associatedRequest:%@;", error, request);
}

- (void)onStartService:(AMapTrackErrorCode)errorCode {
    if (errorCode == AMapTrackErrorOK) {
        NSLog(@"开始服务成功");
    } else {
        NSLog(@"开始服务失败");
    }
    
    NSLog(@"onStartService:%ld", (long)errorCode);
}

- (void)onStopService:(AMapTrackErrorCode)errorCode {
    
    NSLog(@"onStopService:%ld", (long)errorCode);
}

- (void)onStartGatherAndPack:(AMapTrackErrorCode)errorCode {
    if (errorCode == AMapTrackErrorOK) {
        
        NSLog(@"开始采集成功");
    } else {
        NSLog(@"开始采集失败");
    }
}

- (void)onStopGatherAndPack:(AMapTrackErrorCode)errorCode {

    NSLog(@"onStopGatherAndPack:%ld", (long)errorCode);
}

- (void)onStopGatherAndPack:(AMapTrackErrorCode)errorCode errorMessage:(NSString *)errorMessage {
    NSLog(@"onStopGatherAndPack:%ld errorMessage:%@", (long)errorCode,errorMessage);
}

- (void)onAddTrackDone:(AMapTrackAddTrackRequest *)request response:(AMapTrackAddTrackResponse *)response
{
    NSLog(@"onAddTrackDone%@", response.formattedDescription);
    
    if (response.code == AMapTrackErrorOK) {
        //创建trackID成功，开始采集
        self.trackManager.trackID = response.trackID;
        [self.trackManager startGatherAndPack];
    } else {
        //创建trackID失败
        NSLog(@"创建trackID失败");
    }
}
#pragma mark MDLocationManagerDelegate
-(void)updateDistance:(CGFloat)distance {
    CGFloat pace = 0;
    
    // distance单位为公里，刚开始位置有小距离波动，大于一定距离时才进行配速计算，否则配速得到的值会很大
    if (distance > 0.2) {
        CGFloat second = (CGFloat)[self.timeManager currentAccumulatedTime];
        pace = distance / second;
    }
    
    [self.runView setSpeed:pace];
    [self.runView setDistance:distance];
}
#pragma mark MDTimeManagerDelegate
-(void)tickWithAccumulatedTime:(NSUInteger)time {
    [self.runView setTime:time];
}
#pragma mark lazy
-(MDRunView *)runView {
    if (!_runView) {
        _runView = [[MDRunView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 100)];
    }
    return _runView;
}
-(UIButton *)runButton {
    if (!_runButton) {
        _runButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_runButton setTitle:@"开始运动" forState:UIControlStateNormal];
        [_runButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_runButton setTitle:@"暂不能使用" forState:UIControlStateDisabled];
        [_runButton setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
        [_runButton setFrame:CGRectMake(self.view.frame.size.width/2.0 - 50, 300, 100, 30)];
        [_runButton addTarget:self action:@selector(run) forControlEvents:UIControlEventTouchUpInside];
    }
    return _runButton;
}
-(void)dealloc {
    
}
@end

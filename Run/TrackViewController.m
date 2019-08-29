//
//  TrackViewController.m
//  Run
//
//  Created by mac on 2019/8/28.
//  Copyright © 2019 muheda. All rights reserved.
//

#import "TrackViewController.h"
#import <AMapTrackKit/AMapTrackKit.h>
#import <MAMapKit/MAMapKit.h>
#import "APIKey.h"

@interface TrackViewController ()<AMapTrackManagerDelegate, MAMapViewDelegate>

@property (nonatomic, strong) AMapTrackManager      *trackManager;
@property (nonatomic, strong) MAMapView             *mapView;

@property (nonatomic, strong) UIView                *dataView;
@property (nonatomic, strong) UIButton              *queryButton;
@property (nonatomic, strong) UILabel               *mileLabel;
@property (nonatomic, strong) UILabel               *speedLabel;
@property (nonatomic, strong) UILabel               *timeLabel;

@end

@implementation TrackViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configUI];
    [self initTrackManager];
}

- (void)configUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.dataView];
}

- (void)initTrackManager {
    if ([kAMapTrackServiceID length] <= 0 || [kAMapTrackTerminalID length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"您需要指定ServiceID和TerminalID才可以使用轨迹服务"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    AMapTrackManagerOptions *option = [[AMapTrackManagerOptions alloc] init];
    option.serviceID = kAMapTrackServiceID;
    self.trackManager = [[AMapTrackManager alloc] initWithOptions:option];
    self.trackManager.delegate = self;
    
    //配置定位属性
    [self.trackManager setAllowsBackgroundLocationUpdates:YES];
    [self.trackManager setPausesLocationUpdatesAutomatically:NO];
}

#pragma mark - PrivateMethods
//查询Track信息（现在根据serviceID和TerminalID进行查询，项目中从后台接口查询）
- (void)queryTrackInfoAction {
    
    AMapTrackQueryTrackInfoRequest *request = [[AMapTrackQueryTrackInfoRequest alloc] init];
    request.serviceID = self.trackManager.serviceID;
    request.terminalID = kAMapTrackTerminalID;
    request.startTime = ([[NSDate date] timeIntervalSince1970] - 12*60*60) * 1000;
    request.endTime = [[NSDate date] timeIntervalSince1970] * 1000;
//    request.recoupMode = AMapTrackRecoupModeDriving;
    [self.trackManager AMapTrackQueryTrackInfo:request];
}

//查询历史轨迹和距离
- (void)queryTrackHisAction {
    
    AMapTrackQueryTrackHistoryAndDistanceRequest *request = [[AMapTrackQueryTrackHistoryAndDistanceRequest alloc] init];
    request.serviceID = self.trackManager.serviceID;
    request.terminalID = kAMapTrackTerminalID;
    request.startTime = ([[NSDate date] timeIntervalSince1970] - 12*60*60) * 1000;
    request.endTime = [[NSDate date] timeIntervalSince1970] * 1000;
//    request.recoupMode = AMapTrackRecoupModeDriving;
    [self.trackManager AMapTrackQueryTrackHistoryAndDistance:request];
}

//根据代理回调拿到轨迹点集合，画线
- (void)showPolylineWithTrackPoints:(NSArray<AMapTrackPoint *> *)points {
    
    int pointCount = (int)[points count];
    CLLocationCoordinate2D *allCoordinates = (CLLocationCoordinate2D *)malloc(pointCount * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < pointCount; i++) {
        allCoordinates[i].latitude = [[points objectAtIndex:i] coordinate].latitude;
        allCoordinates[i].longitude = [[points objectAtIndex:i] coordinate].longitude;
    }
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:allCoordinates count:pointCount];
    [self.mapView addOverlay:polyline];
    
    if (allCoordinates) {
        free(allCoordinates);
        allCoordinates = NULL;
    }
}

// 给布局赋值
- (void)setTrackInfo:(AMapTrackBasicTrack *)track {
    
    NSLog(@"%@", track);
    NSString *time = [self getMMSSFromSS:[NSString stringWithFormat:@"%lld", track.lastingTime]];
    NSString *distance = [NSString stringWithFormat:@"%.2f公里", track.distance/1000.0];
    NSString *speed = [NSString stringWithFormat:@"%.2f公里/小时",(track.distance/1000.0)/(track.lastingTime/3600000.0)];
    self.timeLabel.text = time;
    self.mileLabel.text = distance;
    self.speedLabel.text = speed;
}

- (void)queryButtonTarget {
    
    [self queryTrackInfoAction];
    [self queryTrackHisAction];
}

//传入毫秒  得到 xx:xx:xx
-(NSString *)getMMSSFromSS:(NSString *)totalTime{
    
    NSInteger seconds = [totalTime integerValue]/1000;
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02d",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02d",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02d",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

#pragma mark - AMapTrackManagerDelegate
- (void)didFailWithError:(NSError *)error associatedRequest:(id)request {
    
    NSLog(@"didFailWithError:%@; --- associatedRequest:%@;", error, request);
}

- (void)onQueryTrackHistoryAndDistanceDone:(AMapTrackQueryTrackHistoryAndDistanceRequest *)request response:(AMapTrackQueryTrackHistoryAndDistanceResponse *)response {
    
    NSLog(@"onQueryTrackHistoryAndDistanceDone%@", response.formattedDescription);
    
//    if ([[response points] count] > 0) {
//        [self.mapView removeOverlays:[self.mapView overlays]];
//        [self showPolylineWithTrackPoints:[response points]];
//        [self.mapView showOverlays:self.mapView.overlays animated:NO];
//    }
}

- (void)onQueryTrackInfoDone:(AMapTrackQueryTrackInfoRequest *)request response:(AMapTrackQueryTrackInfoResponse *)response {
    
    NSLog(@"onQueryTrackInfoDone%@", response.formattedDescription);
    
    [self.mapView removeOverlays:[self.mapView overlays]];
    if (response.tracks.count > 0) {
        // 拿到最近24小时最新的一次轨迹,并划线
        AMapTrackBasicTrack *track = response.tracks[response.tracks.count - 1];
        if ([[track points] count] > 0) {
            [self showPolylineWithTrackPoints:[track points]];
        }
        [self setTrackInfo:track];
    }

//    for (AMapTrackBasicTrack *track in response.tracks) {
//        if ([[track points] count] > 0) {
//            [self showPolylineWithTrackPoints:[track points]];
//        }
//    }
    [self.mapView showOverlays:self.mapView.overlays animated:NO];
}

#pragma mark - MapView Delegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    
    // 设置轨迹样式
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer * polylineRenderer = [[MAPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRenderer.lineWidth = 5.f;
        polylineRenderer.fillColor = [UIColor darkGrayColor];
        
        return polylineRenderer;
    }
    return nil;
}

#pragma mark - Properties
- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 200)];
        [_mapView setDelegate:self];
        [_mapView setZoomLevel:13.0];
        [_mapView setShowsUserLocation:YES];
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow];
    }
    return _mapView;
}

- (UIView *)dataView {
    if (!_dataView) {
        _dataView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetHeight(self.view.bounds)-200, CGRectGetWidth(self.view.bounds)-20, 190)];
        _dataView.backgroundColor = [UIColor orangeColor];
        
        [_dataView addSubview:self.queryButton];
        [_dataView addSubview:self.mileLabel];
        [_dataView addSubview:self.speedLabel];
        [_dataView addSubview:self.timeLabel];
    }
    return _dataView;
}

-(UIButton *)queryButton {
    if (!_queryButton) {
        _queryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _queryButton.backgroundColor = [UIColor cyanColor];
        [_queryButton setTitle:@"查询" forState:UIControlStateNormal];
        _queryButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)-90, 10, 60, 60);
        [_queryButton addTarget:self action:@selector(queryButtonTarget) forControlEvents:UIControlEventTouchUpInside];
    }
    return _queryButton;
}

- (UILabel *)mileLabel {
    if (!_mileLabel) {
        _mileLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 50)];
        _mileLabel.backgroundColor = [UIColor whiteColor];
    }
    return _mileLabel;
}

- (UILabel *)speedLabel {
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 300, 50)];
        _speedLabel.backgroundColor = [UIColor whiteColor];
    }
    return _speedLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 130, 300, 50)];
        _timeLabel.backgroundColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

- (void)dealloc {
    [self.trackManager stopService];
    self.trackManager.delegate = nil;
    self.trackManager = nil;
    
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

@end

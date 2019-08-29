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
@property (nonatomic, strong) UILabel               *mileLabel;
@property (nonatomic, strong) UILabel               *speedLabel;
@property (nonatomic, strong) UILabel               *timeLabel;

@end

@implementation TrackViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configUI];
    [self drawData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if ([kAMapTrackServiceID length] <= 0 || [kAMapTrackTerminalID length] <= 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"您需要指定ServiceID和TerminalID才可以使用轨迹服务"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
}

- (void)configUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.dataView];
}

- (void)drawData {

    [self queryTrackInfoAction];
    [self queryTrackHisAction];
}

#pragma mark - PrivateMethods
//查询Track信息（现在根据serviceID和TerminalID进行查询，项目中从后台接口查询）
- (void)queryTrackInfoAction {
    
    AMapTrackQueryTrackInfoRequest *request = [[AMapTrackQueryTrackInfoRequest alloc] init];
    request.serviceID = self.trackManager.serviceID;
    request.terminalID = kAMapTrackTerminalID;
    request.startTime = ([[NSDate date] timeIntervalSince1970] - 12*60*60) * 1000;
    request.endTime = [[NSDate date] timeIntervalSince1970] * 1000;
    request.recoupMode = AMapTrackRecoupModeDriving;
    [self.trackManager AMapTrackQueryTrackInfo:request];
}

//查询历史轨迹和距离
- (void)queryTrackHisAction {
    
    AMapTrackQueryTrackHistoryAndDistanceRequest *request = [[AMapTrackQueryTrackHistoryAndDistanceRequest alloc] init];
    request.serviceID = self.trackManager.serviceID;
    request.terminalID = kAMapTrackTerminalID;
    request.startTime = ([[NSDate date] timeIntervalSince1970] - 12*60*60) * 1000;
    request.endTime = [[NSDate date] timeIntervalSince1970] * 1000;
    request.recoupMode = AMapTrackRecoupModeDriving;
    
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
- (void)setTrackInfo:(NSDictionary *)description {
    
    NSLog(@"%@", description);
}

#pragma mark - AMapTrackManagerDelegate
- (void)didFailWithError:(NSError *)error associatedRequest:(id)request {
    
    NSLog(@"didFailWithError:%@; --- associatedRequest:%@;", error, request);
}

- (void)onQueryTrackHistoryAndDistanceDone:(AMapTrackQueryTrackHistoryAndDistanceRequest *)request response:(AMapTrackQueryTrackHistoryAndDistanceResponse *)response {
    
    NSLog(@"onQueryTrackHistoryAndDistanceDone%@", response.formattedDescription);
    
    if ([[response points] count] > 0) {
        [self.mapView removeOverlays:[self.mapView overlays]];
        [self showPolylineWithTrackPoints:[response points]];
        [self.mapView showOverlays:self.mapView.overlays animated:NO];
    }
}

- (void)onQueryTrackInfoDone:(AMapTrackQueryTrackInfoRequest *)request response:(AMapTrackQueryTrackInfoResponse *)response {
    
    NSLog(@"onQueryTrackInfoDone%@", response.formattedDescription);
    
    NSError *err;
    NSData *jsonData = [response.formattedDescription dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    [self setTrackInfo:dic];
    
    [self.mapView removeOverlays:[self.mapView overlays]];
    for (AMapTrackBasicTrack *track in response.tracks) {
        if ([[track points] count] > 0) {
            [self showPolylineWithTrackPoints:[track points]];
        }
    }
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

- (AMapTrackManager *)trackManager {
    if (!_trackManager) {
        //Service ID 需要根据需要进行修改
        AMapTrackManagerOptions *option = [[AMapTrackManagerOptions alloc] init];
        option.serviceID = kAMapTrackServiceID;
        
        _trackManager = [[AMapTrackManager alloc]initWithOptions:option];
        _trackManager.delegate = self;
        _trackManager.allowsBackgroundLocationUpdates = YES;
        _trackManager.pausesLocationUpdatesAutomatically = NO;
    }
    return _trackManager;
}

- (UIView *)dataView {
    if (!_dataView) {
        _dataView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetHeight(self.view.bounds)-200, CGRectGetWidth(self.view.bounds)-20, 190)];
        _dataView.backgroundColor = [UIColor orangeColor];
        
        [_dataView addSubview:self.mileLabel];
        [_dataView addSubview:self.speedLabel];
        [_dataView addSubview:self.timeLabel];
    }
    return _dataView;
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

@end

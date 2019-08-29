//
//  MDLocationManager.m
//  Run
//
//  Created by 李永杰 on 2019/8/29.
//  Copyright © 2019 muheda. All rights reserved.
//

#import "MDLocationManager.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MDMapAnnotation.h"
@interface MDLocationManager () <AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager   *locationManager;
@property (nonatomic, assign) NSInteger updateuLocationTimes;   // 系统回调更新定位数据的次数

@end

@implementation MDLocationManager

-(instancetype)init {
    if (self = [super init]) {
        self.annotationRecordArray = [NSMutableArray array];
        [self initLocationManager];
    }
    return self;
}

-(void)initLocationManager {
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:5];
    // iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    // iOS 9（包含iOS9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = NO;
    }
}
-(void)startLocation {
    [self.locationManager startUpdatingLocation];
}
- (void)updateRunningData {
    CGFloat distance  = [self totalDistance];
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateDistance:)]) {
        [self.delegate updateDistance:distance];
    }
}
#pragma mark 定位代理
- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager {
    if (@available(iOS 9.0, *)) {
        [locationManager requestAlwaysAuthorization];
    } else {
        // Fallback on earlier versions
    }
}
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode {
    
    AudioServicesPlaySystemSound(1007);
//    self.updateuLocationTimes++;
//    NSInteger ignoreTimes = 2;
//    if (self.updateuLocationTimes <= ignoreTimes) {
//        return;
//    }

//    // 滤波在处理慢速运行时，会出现路径端点与定位点连接不上的情况，所以在绘制路径时，将未处理过的当前点添加到数组的末尾，每次有新位置进行计算时，先将上一次数组末尾的点移除。
//    if ([self.annotationRecordArray count] > 0) {
//        [self.annotationRecordArray removeLastObject];
//    }
    
    // 本次定位坐标
    CLLocationCoordinate2D coordinate = location.coordinate;
    MDMapAnnotation *annotation = [[MDMapAnnotation alloc] initWithCoordinate:coordinate];
    [self.annotationRecordArray addObject:annotation];
    
    [self updateRunningData];
    
}

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败");
}

-(double)totalDistance {
    // 总距离
    CGFloat totalDistance = 0.0;
    
    NSInteger numberOfCoords = [self.annotationRecordArray count];
    if (numberOfCoords > 1)
    {
        for (NSInteger i = 0; i < numberOfCoords - 1; i++)
        {
            MDMapAnnotation *annotation1 = self.annotationRecordArray[i];
            MDMapAnnotation *annotation2 = self.annotationRecordArray[i + 1];
            
            CGFloat distance = [self distanceBetweenCoordinate1:annotation1.coordinate coordinate2:annotation2.coordinate];
            totalDistance += distance;
        }
    }
    return totalDistance;
}

- (CGFloat)distanceBetweenCoordinate1:(CLLocationCoordinate2D)coordinate1
                          coordinate2:(CLLocationCoordinate2D)coordinate2 {
    // 两个坐标间的距离
    MAMapPoint point1 = MAMapPointForCoordinate(coordinate1);
    MAMapPoint point2 = MAMapPointForCoordinate(coordinate2);
    
    // 距离为米
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    return distance;
}
@end

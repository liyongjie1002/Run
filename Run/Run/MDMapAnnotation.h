//
//  MDMapAnnotation.h
//  Run
//
//  Created by 李永杰 on 2019/8/29.
//  Copyright © 2019 muheda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAAnnotation.h>

@interface MDMapAnnotation : NSObject <MAAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end


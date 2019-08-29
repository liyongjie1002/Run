//
//  MDMapAnnotation.m
//  Run
//
//  Created by 李永杰 on 2019/8/29.
//  Copyright © 2019 muheda. All rights reserved.
//

#import "MDMapAnnotation.h"

@implementation MDMapAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        _coordinate = coordinate;
    }
    return self;
}

@end

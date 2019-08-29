//
//  MDTimeManager.h
//  Run
//
//  Created by 李永杰 on 2019/8/29.
//  Copyright © 2019 muheda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDTimeManagerDelegate <NSObject>

- (void)tickWithAccumulatedTime:(NSUInteger)time;

@end

@interface MDTimeManager : NSObject

@property (nonatomic, weak) id<MDTimeManagerDelegate> delegate;

- (void)start;
- (void)pause;
- (NSUInteger)getTotalTime;
- (NSUInteger)currentAccumulatedTime;
@end

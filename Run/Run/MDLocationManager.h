//
//  MDLocationManager.h
//  Run
//
//  Created by 李永杰 on 2019/8/29.
//  Copyright © 2019 muheda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@protocol MDLocationManagerDelegate <NSObject>

@required
- (void)updateDistance:(CGFloat)distance;

@end

@interface MDLocationManager : NSObject

@property (nonatomic, strong) NSMutableArray *annotationRecordArray;
@property (nonatomic, weak) id<MDLocationManagerDelegate> delegate;

-(void)startLocation;

@end
 

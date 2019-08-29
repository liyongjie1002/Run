//
//  ViewController.m
//  Run
//
//  Created by 李永杰 on 2019/8/28.
//  Copyright © 2019 muheda. All rights reserved.
//

#import "ViewController.h"
#import "RunViewController.h"
#import "TrackViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"点击了" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(100, 100, 100, 30)];
    [btn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
 
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"轨迹" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 setFrame:CGRectMake(100, 200, 100, 30)];
    [btn1 addTarget:self action:@selector(clickAction1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}

-(void)clickAction {
    RunViewController *run = [RunViewController new];
    [self.navigationController pushViewController:run animated:YES];
}


-(void)clickAction1 {
    TrackViewController *run = [TrackViewController new];
    [self.navigationController pushViewController:run animated:YES];
}


@end

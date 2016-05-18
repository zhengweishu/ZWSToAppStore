//
//  ZWSViewController.m
//  ZWSToAppStore
//
//  Created by zhengweishu on 05/18/2016.
//  Copyright (c) 2016 zhengweishu. All rights reserved.
//

#import "ZWSViewController.h"
#import "ZWSToAppStore.h"

@interface ZWSViewController ()


@end

@implementation ZWSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    // 用户好评系统
    ZWSToAppStore *toAppStore = [[ZWSToAppStore alloc] initWithAppId:@""];
    [toAppStore showToAppStoreInController:self];
}




@end

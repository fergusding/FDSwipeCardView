//
//  ViewController.m
//  FDSwipeCardViewDemo
//
//  Created by 本来 on 17/1/12.
//  Copyright © 2017年 Fergus.Ding. All rights reserved.
//

#import "ViewController.h"
#import "FDSwipeCardView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FDSwipeCardView *swipeCardView = [[FDSwipeCardView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    swipeCardView.imageNames = @[@"1.jpeg", @"2.jpeg", @"3.jpeg"];
    swipeCardView.currentIndex = 0;
    [self.view addSubview:swipeCardView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

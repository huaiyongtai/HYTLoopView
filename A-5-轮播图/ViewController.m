//
//  ViewController.m
//  A-5-轮播图
//
//  Created by HelloWorld on 15/11/16.
//  Copyright (c) 2015年 HelloWorld. All rights reserved.
//

#import "ViewController.h"
#import "HYTLoopView.h"
#import <UIImageView+WebCache.h>

@interface ViewController () <HYTLoopViewDelegate>

@property (nonatomic, weak)HYTLoopView *loopView;
@property (nonatomic, weak)HYTLoopView *loopView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor brownColor]];
    
    HYTLoopView *loopView = [HYTLoopView loopView];
    [loopView setFrame:CGRectMake(0, 100, 375, 200)];
    NSArray *titles = @[@"阿克苏记得哈开始记得发货",
                        @"安装性能项目处女座",
                        @"阿德里克放假啊是的离开房间啊"];
    NSArray *imageNames = @[@"testImage_1",
                            @"testImage_2",
                            @"testImage_3",
                            @"testImage_4",
                            @"testImage_5",
                            @"testImage_6",
                            @"testImage_1"];
    [loopView loopImageNames:imageNames loopTitles:titles];
    loopView.delegate = self;
    [self.view addSubview:loopView];
    self.loopView = loopView;
    
    //=======================================================================================
    HYTLoopView *loopView2 = [HYTLoopView loopViewWidthDidSelectImage:^(NSInteger imageIndex) {
        NSLog(@"loopView2中索引为-- %li", imageIndex);
    }];
    
    [loopView2 setDisplayIndicatePageControl:NO];
    [loopView2 setFrame:CGRectMake(10, 350, 355, 100)];
    NSArray *imageURLs = @[@"http://img2.3lian.com/2014/f7/5/d/22.jpg",
                           @"http://image.tianjimedia.com/uploadImages/2011/327/1VPRY46Q4GB7.jpg",
                           @"http://img6.faloo.com/Picture/0x0/0/747/747488.jpg",
                           @"http://i6.topit.me/6/5d/45/1131907198420455d6o.jpg"];
    [loopView2 loopImageURLs:imageURLs placeholderImage:[UIImage imageNamed:@"testImage_1"]];
    [self.view addSubview:loopView2];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn setFrame:CGRectMake(200, 550, 50, 50)];
    [btn addTarget:self action:@selector(deallocLoopView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.loopView2 = loopView2;
}

- (void)loopView:(HYTLoopView *)loopView didSelectImageIndex:(NSInteger)imageIndex {
    
    NSLog(@"loopView中索引为--- %li", imageIndex);
}

- (void)deallocLoopView {
    NSLog(@"deallocLoopView");
    
    [self.loopView stopLoop];
    [self.loopView removeFromSuperview];
    
    [self.loopView2 stopLoop];
    [self.loopView2 removeFromSuperview];
}

@end

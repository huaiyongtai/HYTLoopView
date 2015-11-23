//
//  HYTLoopView.h
//  A-5-轮播图
//
//  Created by HelloWorld on 15/11/16.
//  Copyright (c) 2015年 HelloWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYTLoopView;

@protocol HYTLoopViewDelegate <NSObject>

@optional
- (void)loopView:(HYTLoopView *)loopView didSelectImageIndex:(NSInteger)imageIndex;

@end

@interface HYTLoopView : UIView

+ (instancetype)loopView;
+ (instancetype)loopViewWidthDidSelectImage:(void(^)(NSInteger imageIndex))selectImage;

/** 图片的滚动速率 默认2s */
@property (nonatomic, assign) NSTimeInterval loopVelocity;

/**
 *  给定的URL数组来确定滚动图片
 *
 *  @param loopImageNames   滚动图片的图片名数组
 *  @param loopImageURLs    滚动图片的URL地址数组
 *  @param loopTitles       滚动图片的标题数组
 *  @param placeholderImage 占位图的名称
 */
- (void)loopImageNames:(NSArray *)loopImageNames;
- (void)loopImageNames:(NSArray *)loopImageNames loopTitles:(NSArray *)loopTitles;
- (void)loopImageURLs:(NSArray *)loopImageURLs placeholderImage:(UIImage *)placeholderImage;
- (void)loopImageURLs:(NSArray *)loopImageURLs loopTitles:(NSArray *)loopTitles placeholderImage:(UIImage *)placeholderImage;

#pragma mark - 开始、终止滚动
- (void)startLoop;  //默认开始循环
- (void)stopLoop;   //当要销毁LoopView的时候，必须先发送一个stopLoop消息

@property (nonatomic, weak) id<HYTLoopViewDelegate> delegate;

#pragma mark - 指示器属性
/** 展示指示器（分页控制器），默认YES */
@property (nonatomic, assign, getter=isDisplayIndicatePageControl) BOOL displayIndicatePageControl;
/** 指示器（分页控制器），位置坐标，默认居中 */
@property (nonatomic, assign) CGPoint indicatePagePosition;

#pragma mark - 标题属性（你应该在设置滚动视图信息之后在设置标题属性）
@property (nonatomic, strong) UIFont *loopTitleFont;
@property (nonatomic, assign) NSTextAlignment loopTitleAlignment;
@property (nonatomic, assign) CGRect loopTitleViewFrame;
@property (nonatomic, strong) UIColor *loopTitleViewBackgroundColor;

#pragma mark - 下列属性为只读属性，不行去尝试着直接修改该属性
@property (nonatomic, strong) NSArray *loopImageInfos;
@property (nonatomic, strong, readonly) NSArray *loopTitles;
@property (nonatomic, strong, readonly) UIImage *placeholderImage;


@end

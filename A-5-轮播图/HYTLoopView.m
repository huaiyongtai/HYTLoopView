//
//  HYTLoopView.m
//  A-5-轮播图
//
//  Created by HelloWorld on 15/11/16.
//  Copyright (c) 2015年 HelloWorld. All rights reserved.
//

#import "HYTLoopView.h"
#import <UIImageView+WebCache.h>

typedef void(^SelectImage)(NSInteger selectImageIndex);

typedef NS_ENUM(NSInteger, ImageInfoTypes) {
    
    kImageInfoTypeLocation,
    kImageInfoTypeURL
};

@interface HYTLoopView() <UIScrollViewDelegate>

@property (nonatomic, weak  ) UIScrollView   *containerView;
@property (nonatomic, weak  ) UIImageView    *preImageView;
@property (nonatomic, weak  ) UIImageView    *middleImageView;
@property (nonatomic, weak  ) UIImageView    *nextImageView;

@property (nonatomic, weak  ) UILabel        *preLabel;
@property (nonatomic, weak  ) UILabel        *middleLabel;
@property (nonatomic, weak  ) UILabel        *nextLabel;

@property (nonatomic, assign) NSInteger      currentImageIndex;

@property (nonatomic, strong) NSTimer        *loopTimer;
@property (nonatomic, weak  ) UIPageControl  *pageControl;

@property (nonatomic, assign) ImageInfoTypes imageInfoType;
@property (nonatomic, strong) UIImage        *placeholderImage;
@property (nonatomic, copy  ) SelectImage    selectImage;

@end

@implementation HYTLoopView

+ (instancetype)loopView {
    return [self loopViewWidthDidSelectImage:nil];
}
+ (instancetype)loopViewWidthDidSelectImage:(void (^)(NSInteger imageIndex))selectImage {
    HYTLoopView *loopView = [[self alloc] init];
    loopView.selectImage = selectImage;
    return loopView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setBackgroundColor:[UIColor clearColor]];
    
        self.loopVelocity = 2.0;
        
        self.displayIndicatePageControl = YES;
        
        self.loopTitleFont = [UIFont systemFontOfSize:17];
        self.loopTitleAlignment = NSTextAlignmentLeft;
        self.loopTitleViewBackgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];

        //添加手势
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)]];
        
        
        
        
        [self startLoop];
    }
    return self;
}

- (UIScrollView *)containerView {
    
    if (_containerView == nil) {
        //构建轮播视图的内容视图
        UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [containerView setContentSize:CGSizeMake(CGRectGetWidth(containerView.frame) * 3, 0)];
        [containerView setBounces:NO];
        [containerView setPagingEnabled:YES];
        [containerView setShowsHorizontalScrollIndicator:NO];
        [containerView setDelegate:self];
        [self addSubview:containerView];
        self.containerView = containerView;
        
        UIImageView *preImageView = [[UIImageView alloc] init];
        [preImageView setFrame:CGRectMake(0, 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame))];
        [containerView addSubview:preImageView];
        self.preImageView = preImageView;
        
        UIImageView *middleImageView = [[UIImageView alloc] init];
        [middleImageView setFrame:CGRectMake(CGRectGetWidth(containerView.frame), 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame))];
        [containerView addSubview:middleImageView];
        self.middleImageView = middleImageView;
        
        UIImageView *nextImageView = [[UIImageView alloc] init];
        [nextImageView setFrame:CGRectMake(CGRectGetWidth(containerView.frame)*2, 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame))];
        [containerView addSubview:nextImageView];
        self.nextImageView = nextImageView;
        
        self.indicatePagePosition = CGPointMake(CGRectGetWidth(self.bounds)*0.5, CGRectGetHeight(self.bounds)*0.9);
        self.loopTitleViewFrame = CGRectMake(0, CGRectGetHeight(middleImageView.frame)*0.85, CGRectGetWidth(middleImageView.frame), CGRectGetHeight(middleImageView.frame)*(1.0-0.85));
    }
    return _containerView;
}

#pragma mark - 设置滚动信息
- (void)loopImageNames:(NSArray *)imageNames {
    [self loopImageNames:imageNames loopTitles:nil];
}
- (void)loopImageNames:(NSArray *)imageNames loopTitles:(NSArray *)loopTitles {
    [self loopImages:imageNames imageInfoType:kImageInfoTypeLocation loopTitles:loopTitles];
}
- (void)loopImageURLs:(NSArray *)imageURLs placeholderImage:(UIImage *)placeholderImage {
    [self loopImageURLs:imageURLs loopTitles:nil placeholderImage:placeholderImage];
}
- (void)loopImageURLs:(NSArray *)imageURLs loopTitles:(NSArray *)loopTitles placeholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    [self loopImages:imageURLs imageInfoType:kImageInfoTypeURL loopTitles:loopTitles];
}
- (void)loopImages:(NSArray *)loopImages imageInfoType:(ImageInfoTypes)imageInfoType loopTitles:(NSArray *)loopTitles {

    self.imageInfoType = imageInfoType;
    self.loopImageInfos = loopImages;
    self.loopTitles = loopTitles;
    
    //设置当前显示的图片索引
    self.currentImageIndex = 0;
}

#pragma mark - 设置PageControl信息
- (void)setDisplayIndicatePageControl:(BOOL)displayIndicatePageControl {
    
    //重复设同一值直接返回
    if (_displayIndicatePageControl == displayIndicatePageControl) return;
    
    _displayIndicatePageControl = displayIndicatePageControl;
    
    if (displayIndicatePageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        [pageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
        [pageControl setPageIndicatorTintColor:[UIColor orangeColor]];
        [pageControl setNumberOfPages:self.loopImageInfos.count];
        [self addSubview:pageControl];
        self.pageControl = pageControl;
    } else {
        [self.pageControl removeFromSuperview];
        self.pageControl = nil;
    }
}
- (void)setIndicatePagePosition:(CGPoint)indicatePagePosition {
    
    _indicatePagePosition = indicatePagePosition;
    if (self.isDisplayIndicatePageControl) {
        CGRect pageControlFrame = self.pageControl.frame;
        pageControlFrame.origin = indicatePagePosition;
        self.pageControl.frame = pageControlFrame;
    }
}

#pragma mark - 约束Title、创建Label
- (void)setLoopTitles:(NSArray *)loopTitles {
    
    //如果同上次设定结果相同则直接返回
    if (_loopTitles == loopTitles) return;
    
    _loopTitles = loopTitles;
    
    //移除以前
    [self.preLabel removeFromSuperview];
    self.preLabel = nil;
    [self.middleLabel removeFromSuperview];
    self.middleLabel = nil;
    [self.nextLabel removeFromSuperview];
    self.nextLabel = nil;
    
    //没有title直接返回
    if (loopTitles.count == 0) return;
    
    /** 给定的title数组比loopImageInfos数组短时，将扩充title至loopImageInfos长度，多出部分置@“” */
    NSInteger differCount = self.loopImageInfos.count - loopTitles.count;
    if (differCount > 0) {
        NSMutableArray *tempTitles = [NSMutableArray array];
        [tempTitles addObjectsFromArray:loopTitles];
        for (int index = 0; index<differCount; index++) {
            [tempTitles addObject:@""];
        }
        _loopTitles = tempTitles;
    }
    
    //没有容器则直接返回
    if (self.containerView == nil) return;
    
    /** titles不为nil是加载出三个Label */
    UILabel *preLabel = [[UILabel alloc] init];
    [preLabel setFrame:_loopTitleViewFrame];
    [preLabel setFont:_loopTitleFont];
    [preLabel setTextAlignment:_loopTitleAlignment];
    [preLabel setBackgroundColor:_loopTitleViewBackgroundColor];
    [self.preImageView addSubview:preLabel];
    self.preLabel = preLabel;
    
    UILabel *middleLabel = [[UILabel alloc] init];
    [middleLabel setFrame:_loopTitleViewFrame];
    [middleLabel setFont:_loopTitleFont];
    [middleLabel setTextAlignment:_loopTitleAlignment];
    [middleLabel setBackgroundColor:_loopTitleViewBackgroundColor];
    [self.middleImageView addSubview:middleLabel];
    self.middleLabel = middleLabel;
    
    UILabel *nextLabel = [[UILabel alloc] init];
    [nextLabel setFrame:_loopTitleViewFrame];
    [nextLabel setFont:_loopTitleFont];
    [nextLabel setTextAlignment:_loopTitleAlignment];
    [nextLabel setBackgroundColor:_loopTitleViewBackgroundColor];
    [self.nextImageView addSubview:nextLabel];
    self.nextLabel = nextLabel;
}
- (void)setLoopImageInfos:(NSArray *)loopImageInfos {
    
    _loopImageInfos = loopImageInfos;
    if (self.isDisplayIndicatePageControl) {
        [self.pageControl setNumberOfPages:loopImageInfos.count];
    }
}

#pragma mark - 设置当前显示图片
- (void)setCurrentImageIndex:(NSInteger)currentImageIndex {

    _currentImageIndex = currentImageIndex;
    
    //0.page显示的话设置当前页码
    if (self.isDisplayIndicatePageControl) {
        [self.pageControl setCurrentPage:currentImageIndex];
    }
  
    //1. 根据当前Image的索引确定preImageView和nextImageView的Image的索引值
        //上一张图片索引
    NSInteger preImageIndex = currentImageIndex - 1;
    if (preImageIndex < 0) {  //上一张图片应为最后一张
        preImageIndex = self.loopImageInfos.count - 1;
    }
    
        //下一张图片索引
    NSInteger nextImageIndex = currentImageIndex + 1;
    if (nextImageIndex > self.loopImageInfos.count-1) {    //下一张图片应为第一张
        nextImageIndex = 0;
    }
    
    //2.为ImageView和Label设置新的内容
    switch (self.imageInfoType) {
        case kImageInfoTypeLocation: {
            [self.preImageView setImage:[UIImage imageNamed:self.loopImageInfos[preImageIndex]]];
            [self.middleImageView setImage:[UIImage imageNamed:self.loopImageInfos[currentImageIndex]]];
            [self.nextImageView setImage:[UIImage imageNamed:self.loopImageInfos[nextImageIndex]]];
            break;
        }
        case kImageInfoTypeURL: {
            [self.preImageView sd_setImageWithURL:[NSURL URLWithString:self.loopImageInfos[preImageIndex]] placeholderImage:_placeholderImage];
            [self.middleImageView sd_setImageWithURL:[NSURL URLWithString:self.loopImageInfos[currentImageIndex]] placeholderImage:_placeholderImage];
            [self.nextImageView sd_setImageWithURL:[NSURL URLWithString:self.loopImageInfos[nextImageIndex]] placeholderImage:_placeholderImage];
            break;
        }
        default: {
            NSAssert(NO, @"I'm very sorry, please send email to me and meet question!(memorywarning@gmail.com)");
            break;
        }
    }
    if (self.loopTitles.count > 0) {  //有标题时才添加
        
        [self.preLabel setText:self.loopTitles[preImageIndex]];
        [self.middleLabel setText:self.loopTitles[currentImageIndex]];
        [self.nextLabel setText:self.loopTitles[nextImageIndex]];
        
        //Label有内容则显示，无内容则不显示
        self.preLabel.hidden = ({
            self.preLabel.text.length ? NO : YES;
        });
        self.middleLabel.hidden = ({
            self.middleLabel.text.length ? NO : YES;
        });
        self.nextLabel.hidden = ({
            self.nextLabel.text.length ? NO : YES;
        });
    }
    
    //3.确保当前ImageView视图永远在containerView中间位置
    [self.containerView setContentOffset:CGPointMake(CGRectGetWidth(self.containerView.frame), 0) animated:NO];
}

#pragma mark - 定时器调度
- (void)scrollToNextImageView {
    
    //动画滚动到下一个ImageView（对，下一个永远就是下一个，就是在固定的位置）
    [self.containerView setContentOffset:CGPointMake(CGRectGetWidth(self.containerView.frame)*2, 0) animated:YES];
}

#pragma mark - 点击视图
- (void)tapView {

    if (self.selectImage) {
        self.selectImage(self.currentImageIndex);
    }
    
    if ([self.delegate respondsToSelector:@selector(loopView:didSelectImageIndex:)]) {
        [self.delegate loopView:self didSelectImageIndex:self.currentImageIndex];
    }
}

#pragma mark - 设置标题属性
- (void)setLoopTitleFont:(UIFont *)loopTitleFont {
    
    _loopTitleFont = loopTitleFont;
    
    [self.preLabel setFont:loopTitleFont];
    [self.middleLabel setFont:loopTitleFont];
    [self.nextLabel setFont:loopTitleFont];
}
- (void)setLoopTitleViewFrame:(CGRect)loopTitleViewFrame {

    _loopTitleViewFrame = loopTitleViewFrame;
    
    self.preLabel.frame = loopTitleViewFrame;
    self.middleLabel.frame = loopTitleViewFrame;
    self.nextLabel.frame = loopTitleViewFrame;
}
- (void)setLoopTitleViewBackgroundColor:(UIColor *)loopTitleViewBackgroundColor {
    
    _loopTitleViewBackgroundColor = loopTitleViewBackgroundColor;
    
    [self.preLabel setBackgroundColor:loopTitleViewBackgroundColor];
    [self.middleLabel setBackgroundColor:loopTitleViewBackgroundColor];
    [self.nextLabel setBackgroundColor:loopTitleViewBackgroundColor];
}
- (void)setLoopTitleAlignment:(NSTextAlignment)loopTitleAlignment {
    
    _loopTitleAlignment = loopTitleAlignment;
    
    [self.preLabel setTextAlignment:loopTitleAlignment];
    [self.middleLabel setTextAlignment:loopTitleAlignment];
    [self.nextLabel setTextAlignment:loopTitleAlignment];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}
/** 减速完成 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //当前图片索引
    NSInteger currentImageIndex = self.currentImageIndex;
    if (scrollView.contentOffset.x >= CGRectGetWidth(scrollView.frame) * 2) {  //已经滚动到下一张
        currentImageIndex++;
    }
    
    if (scrollView.contentOffset.x <= 0) {   //已经到上一张了
        currentImageIndex--;
    }
    
    if (currentImageIndex < 0) {    //当前图片应为最后一张
        currentImageIndex = self.loopImageInfos.count-1;
    }
    
    if (currentImageIndex > self.loopImageInfos.count-1) {   //当前图片应为第一张
        currentImageIndex = 0;
    }
    
    //设置当前要显示的视图索引
    self.currentImageIndex = currentImageIndex;
}
/** 拖动时停止计时器调度 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.loopTimer setFireDate:[NSDate distantFuture]];  //计时器停止
}
/** 拖动结束后计时器调度开始 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self.loopTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.loopVelocity]];   //计时器开始调度
}

#pragma mark - 调整子控件顺序
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.isDisplayIndicatePageControl) {
        [self.pageControl setFrame:CGRectMake(self.indicatePagePosition.x, self.indicatePagePosition.y, 0, 0)];
        [self bringSubviewToFront:self.pageControl];
    }
    
    //禁止对loopLabel的x 和 width进行修改
    if (self.loopTitles.count>0) {
        [self.preLabel setFrame:CGRectMake(0, self.loopTitleViewFrame.origin.y, CGRectGetWidth(self.preImageView.frame), self.loopTitleViewFrame.size.height)];
        [self.middleLabel setFrame:self.preLabel.frame];
        [self.nextLabel setFrame:self.middleLabel.frame];
    }
}

#pragma mark - 定时器开启、失效
- (void)startLoop {
    if (self.loopTimer == nil) {
        NSTimer *scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.loopVelocity
                                                                target:self
                                                              selector:@selector(scrollToNextImageView)
                                                              userInfo:nil
                                                               repeats:YES];
        self.loopTimer = scrollTimer;
    }
}

- (void)stopLoop {
    
    if (self.loopTimer) {
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }
}

- (void)dealloc {
    
    NSLog(@"------------------");
}
@end

//
//  FDSwipeCardView.m
//  FDSwipeCardViewDemo
//
//  Created by 本来 on 17/1/12.
//  Copyright © 2017年 Fergus.Ding. All rights reserved.
//

#import "FDSwipeCardView.h"

@interface FDSwipeCardView ()

@property (strong, nonatomic) UIImageView *topItemView;
@property (strong, nonatomic) UIImageView *bottomItemView;
@property (strong, nonatomic) UILabel *pagesIndicatorLabel;
@property (assign, nonatomic) CGPoint topOriginCenter;

@end

@implementation FDSwipeCardView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self configureItemVC];
    [self configPagesIndicator];
    [self updatePagesIndicator];
}

#pragma mark - Private

- (void)configureItemVC {
    if (![self.imageNames count]) {  // 没有数据
        return;
    }
    
    self.currentIndex = self.currentIndex >= [self.imageNames count] ? 0 : self.currentIndex;
    UIImageView *topItemView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width - 40, self.frame.size.height - 20 - 56)];
    topItemView.image = [self imageAtIndex:self.currentIndex];
    topItemView.layer.masksToBounds = YES;
    topItemView.layer.cornerRadius = 10.0;
    [self addSubview:topItemView];
    topItemView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [topItemView addGestureRecognizer:panGesture];
    self.topOriginCenter = topItemView.center;
    self.topItemView = topItemView;
    
    if ([self.imageNames count] > 1) {    // 只有一个商品需要评论时，不显示下面的view
        NSInteger index = [self.imageNames count] - 1 == self.currentIndex ? self.currentIndex - 1 : self.currentIndex + 1;
        UIImageView *bottomItemView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width - 40, self.frame.size.height - 20 - 56)];
        bottomItemView.image = [self imageAtIndex:index];
        bottomItemView.layer.masksToBounds = YES;
        bottomItemView.layer.cornerRadius = 10.0;
        [self insertSubview:bottomItemView belowSubview:topItemView];
        bottomItemView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *panGesture1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        [bottomItemView addGestureRecognizer:panGesture1];
        bottomItemView.transform = CGAffineTransformMakeScale(305.0 / 335, 480.0 / 527);
        bottomItemView.center = CGPointMake(self.topOriginCenter.x + 25, self.topOriginCenter.y);
        self.bottomItemView = bottomItemView;
    }
}

- (void)configPagesIndicator {
    UILabel *pagesIndicatorLabel = [[UILabel alloc] init];
    pagesIndicatorLabel.textColor = [UIColor whiteColor];
    pagesIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    pagesIndicatorLabel.font = [UIFont systemFontOfSize:12];
    pagesIndicatorLabel.backgroundColor = [UIColor lightGrayColor];
    pagesIndicatorLabel.layer.cornerRadius = 8.0;
    pagesIndicatorLabel.layer.masksToBounds = YES;
    [self addSubview:pagesIndicatorLabel];
    self.pagesIndicatorLabel = pagesIndicatorLabel;
}

- (void)updatePagesIndicator {
    self.pagesIndicatorLabel.text = [NSString stringWithFormat:@"%ld/%lu", self.currentIndex + 1, (unsigned long)[self.imageNames count]];
    CGSize size = [_pagesIndicatorLabel.text sizeWithAttributes:@{NSFontAttributeName: self.pagesIndicatorLabel.font}];
    
    self.pagesIndicatorLabel.frame = CGRectMake((self.frame.size.width - size.width) / 2, self.frame.size.height - size.height - 36, size.width + 20, size.height);
}

- (NSInteger)indexOfBottomItemWithMovePoint:(CGPoint)movePoint {
    NSInteger index;
    if ((self.currentIndex == 0 && movePoint.x >= 0)) {
        index = self.currentIndex + 1;
    } else if ((self.currentIndex == [self.imageNames count] - 1 && movePoint.x < 0)) {
        index = self.currentIndex - 1;
    } else {
        if (movePoint.x < 0) {
            index = self.currentIndex + 1;
        } else {
            index = self.currentIndex - 1;
        }
    }
    return index;
}

- (UIImage *)imageAtIndex:(NSInteger)index {
    return [UIImage imageNamed:self.imageNames[index]];
}

#pragma mark - Gesture Recongnizer

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    if ([self.imageNames count] == 1) { //当只有一个item view时，不响应手势
        return;
    }
    
    UIView *topView = panGestureRecognizer.view;
    if (![topView isEqual:self.topItemView]) { //只对上层view做手势响应
        return;
    }
    
    static BOOL isLeft;
    CGPoint movePoint = [panGestureRecognizer translationInView:topView];
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSInteger index = [self indexOfBottomItemWithMovePoint:movePoint];
        self.bottomItemView.image = [self imageAtIndex:index];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        isLeft = (movePoint.x < 0);
        
        // 计算topView的center
        topView.center = CGPointMake(topView.center.x + movePoint.x, topView.center.y);
        
        // 计算topView的旋转角度， 最大旋转角度为左上或者右上的角与导航栏底部相交
        CGFloat angle = (topView.center.x - topView.frame.size.width / 2.0) / topView.frame.size.width / 4.0;
        CGFloat maxAngle = atan(topView.frame.size.width / 2.0 / (topView.frame.size.height / 2.0)) - acos((topView.frame.size.height / 2.0 + 20) / hypot(topView.frame.size.width / 2.0, topView.frame.size.height / 2.0));
        if (angle < 0) {    // 逆时针旋转
            angle = MAX(angle, -maxAngle);
        } else {    // 顺时针旋转
            angle = MIN(angle, maxAngle);
        }
        topView.transform = CGAffineTransformMakeRotation(angle);
        
        // 计算bottomView的center和transform
        CGFloat distance = ABS(topView.center.x - self.topOriginCenter.x) > self.topOriginCenter.x ? self.topOriginCenter.x : ABS(topView.center.x - self.topOriginCenter.x);
        CGFloat ratio = distance / self.topOriginCenter.x;
        self.bottomItemView.center = CGPointMake(self.topOriginCenter.x  + (1 - ratio) * 24, self.topOriginCenter.y);
        self.bottomItemView.transform = CGAffineTransformMakeScale(305.0 / 335 + (1 - 305.0 / 335) * ratio, 480.0 / 527 + (1 - 480.0 / 527) * ratio);
        
        [panGestureRecognizer setTranslation:CGPointZero inView:topView];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        BOOL distanceBound = topView.center.x >= 0 && topView.center.x <= [UIScreen mainScreen].bounds.size.width;   // 移动的最大距离
        BOOL isSpeedLessThan800 = ABS([panGestureRecognizer velocityInView:topView].x) < 800 ? YES : NO;     // 水平速度未超过800
        BOOL isFirstPanToRight = self.currentIndex == 0 && !isLeft;                  // 当前显示第一个并且向右滑
        BOOL isFianlPanToLeft = self.currentIndex == [self.imageNames count] - 1 && isLeft;    // 当前显示最后一个并且向左滑
        if ((distanceBound && isSpeedLessThan800) || isFirstPanToRight || isFianlPanToLeft) {   // 以上三种情况都返回最初状态
            [UIView animateWithDuration:0.5 animations:^{
                topView.center = self.topOriginCenter;
                topView.transform = CGAffineTransformIdentity;
                
                self.bottomItemView.center = CGPointMake(self.topOriginCenter.x + 24, self.topOriginCenter.y);
                self.bottomItemView.transform = CGAffineTransformMakeScale(305.0 / 335, 480.0 / 527);
            }];
        } else {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                topView.center = CGPointMake(isLeft ? -500 : 1000, topView.center.y);
            } completion:^(BOOL finished) {
                [topView removeFromSuperview];
                topView.center = CGPointMake(self.topOriginCenter.x + 24, self.topOriginCenter.y);
                topView.transform = CGAffineTransformMakeScale(305.0 / 335, 480.0 / 527);
                [self insertSubview:topView belowSubview:self.bottomItemView];
                
                self.bottomItemView.center = self.topOriginCenter;
                self.bottomItemView.transform = CGAffineTransformIdentity;
                
                UIImageView *tempItemView = self.topItemView;
                self.topItemView = self.bottomItemView;
                self.bottomItemView = tempItemView;
                
                if (isLeft) {
                    self.currentIndex = self.currentIndex + 1;
                } else {
                    self.currentIndex = self.currentIndex - 1;
                }
                NSInteger index = [self indexOfBottomItemWithMovePoint:movePoint];
                self.bottomItemView.image = [self imageAtIndex:index];
                [self updatePagesIndicator];
            }];
        }
    }
}

@end

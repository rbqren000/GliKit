//
//  GKPartialPresentTransitionDelegate.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPartialPresentTransitionDelegate.h"
#import "UIViewController+GKTransition.h"
#import "UIImage+GKUtils.h"
#import "UIViewController+GKUtils.h"
#import "UIView+GKUtils.h"
#import "GKPartialPresentationController.h"
#import "UIScreen+GKUtils.h"
#import "GKScrollViewController.h"
#import "GKBaseDefines.h"

@implementation GKPartialPresentProps

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitionDuration = 0.25;
        self.cancelable = YES;
        self.transitionStyle = GKPresentTransitionStyleFromBottom;
        self.frameUseSafeArea = YES;
        self.interactiveDismissible = YES;
        self.corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    }
    return self;
}

- (UIColor *)backgroundColor
{
    if(!_backgroundColor){
        _backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _backgroundColor;
}

- (CGRect)frame
{
    if(_frame.size.width > 0 && _frame.size.height > 0)
        return _frame;
    
    //弹窗大小位置
    CGSize size = self.contentSize;
    CGSize parentSize = UIScreen.gkSize;
    switch (self.transitionStyle) {
        case GKPresentTransitionStyleFromTop : {
            if(self.frameUseSafeArea){
                size.height += UIApplication.sharedApplication.keyWindow.gkSafeAreaInsets.top;
            }
            return CGRectMake((parentSize.width - size.width) / 2.0, 0, size.width, size.height);
        }
        case GKPresentTransitionStyleFromLeft : {
            if(self.frameUseSafeArea){
                size.width += UIApplication.sharedApplication.keyWindow.gkSafeAreaInsets.left;
            }
            return CGRectMake(size.width, (parentSize.height - size.height) / 2.0, size.width, size.height);
        }
        case GKPresentTransitionStyleFromBottom : {
            if(self.frameUseSafeArea){
                size.height += UIApplication.sharedApplication.keyWindow.gkSafeAreaInsets.bottom;
            }
            return CGRectMake((parentSize.width - size.width) / 2.0, parentSize.height - size.height, size.width, size.height);
        }
        case GKPresentTransitionStyleFromRight : {
            if(self.frameUseSafeArea){
                size.width += UIApplication.sharedApplication.keyWindow.gkSafeAreaInsets.right;
            }
            return CGRectMake(parentSize.width - size.width, (parentSize.height - size.height) / 2.0, size.width, size.height);
        }
    }
}

@end

///自定义Present类型的过度动画，用于用户滑动触发的过渡动画
@interface GKPartialPresentInteractiveTransition : UIPercentDrivenInteractiveTransition

///关联的 GKPartialPresentTransitionDelegate
@property(nonatomic, weak) GKPartialPresentTransitionDelegate *delegate;

///平滑手势
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@interface GKPartialPresentTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

///
@property(nonatomic,weak) GKPartialPresentProps *props;

@end

@interface GKPartialPresentTransitionDelegate()

///动画
@property(nonatomic, strong) GKPartialPresentTransitionAnimator *animator;

///显示的viewController
@property(nonatomic, weak) UIViewController *viewController;

///是否是直接dismiss
@property(nonatomic, assign) BOOL dismissDirectly;

///当前手势
@property(nonatomic, weak) UIPanGestureRecognizer *activedPanGestureRecognizer;

///是否正在交互中
@property(nonatomic, assign) BOOL interacting;

@end

@implementation GKPartialPresentTransitionDelegate


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.dismissDirectly = YES;
    if(!self.animator){
        self.animator = [[GKPartialPresentTransitionAnimator alloc] init];
        self.animator.props = self.props;
    }
    
    return self.animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if(!self.animator){
        self.animator = [[GKPartialPresentTransitionAnimator alloc] init];
        self.animator.props = self.props;
    }
    return self.animator;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    GKPartialPresentationController *controller = [[GKPartialPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    controller.transitionDelegate = self;
    return controller;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if(!self.dismissDirectly){
        self.dismissDirectly = YES;
        GKPartialPresentInteractiveTransition *interactive = [[GKPartialPresentInteractiveTransition alloc] init];
        interactive.delegate = self;
        interactive.panGestureRecognizer = self.activedPanGestureRecognizer;
        
        return interactive;
    }
    
    return nil;
}

- (void)showViewController:(UIViewController *)viewController completion:(void (^)(void))completion
{
    if(viewController.presentingViewController)
        return;
    
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.gkTransitioningDelegate = self;
    self.viewController = viewController;
    if(self.props.interactiveDismissible){
        [viewController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
        
        if(self.props.transitionStyle == GKPresentTransitionStyleFromBottom){
            UIViewController *vc = self.viewController;
            if([vc isKindOfClass:UINavigationController.class]){
                UINavigationController *nav = (UINavigationController*)vc;
                vc = nav.viewControllers.firstObject;
            }
            if([vc isKindOfClass:GKScrollViewController.class]){
                GKScrollViewController *scrollViewController = (GKScrollViewController*)vc;
                self.scrollView = scrollViewController.scrollView;
                
                WeakObj(self)
                scrollViewController.scrollViewDidChange = ^(UIScrollView *scrollView) {
                    selfWeak.scrollView = scrollView;
                };
            }
        }
    }
    
    [UIApplication.sharedApplication.delegate.window.rootViewController.gkTopestPresentedViewController presentViewController:viewController animated:YES completion:completion];
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    if(_scrollView != scrollView){
        [_scrollView.panGestureRecognizer removeTarget:self action:@selector(handlePan:)];
        _scrollView = scrollView;
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(handlePan:)];
    }
}

///平移手势
- (void)handlePan:(UIPanGestureRecognizer*) pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan : {
            if(pan == self.scrollView.panGestureRecognizer){
                if(self.scrollView.contentOffset.y <= 0){
                    self.scrollView.contentOffset = CGPointZero;
                    [self startInteractiveTransition:pan];
                }
            }else{
                [self startInteractiveTransition:pan];
            }
        }
            break;
        case UIGestureRecognizerStateChanged : {
            if(pan == self.scrollView.panGestureRecognizer && !self.interacting){
                if(self.scrollView.contentOffset.y <= 0){
                    self.scrollView.contentOffset = CGPointZero;
                    [self startInteractiveTransition:pan];
                }
            }
        }
            break;
        default: {
            self.interacting = NO;
        }
            break;
    }
}

///开始交互动画
- (void)startInteractiveTransition:(UIPanGestureRecognizer*) pan
{
    ///回收键盘
    self.interacting = YES;
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    self.dismissDirectly = NO;
    self.activedPanGestureRecognizer = pan;
    [self.viewController dismissViewControllerAnimated:YES completion:self.props.dismissCallback];
}

@end

@interface GKPartialPresentTransitionAnimator ()

@end

@implementation GKPartialPresentTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.props.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if(!transitionContext.isInteractive){
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        UIView *containerView = transitionContext.containerView;
        
        ///是否是弹出
        BOOL isPresenting = toViewController.presentingViewController == fromViewController;
        
        UIView *view = nil;
        CGPoint fromCenter;
        CGPoint toCenter;
        CGRect frame = self.props.frame;
        
        CGPoint center;
        switch (self.props.transitionStyle){
                
            case GKPresentTransitionStyleFromTop : {
                center = CGPointMake(CGRectGetMidX(frame), -frame.size.height / 2);
            }
                break;
            case GKPresentTransitionStyleFromBottom : {
                center = CGPointMake(CGRectGetMidX(frame), containerView.gkBottom + frame.size.height / 2);
            }
                break;
            case GKPresentTransitionStyleFromLeft : {
                center = CGPointMake(-frame.size.width / 2, CGRectGetMidY(frame));
            }
                break;
            case GKPresentTransitionStyleFromRight : {
                center = CGPointMake(containerView.gkRight + frame.size.width / 2, CGRectGetMidY(frame));
            }
                break;
        }
        
        if(isPresenting){
            view = [transitionContext viewForKey:UITransitionContextToViewKey];
            view.frame = frame;
            fromCenter = center;
            toCenter = view.center;
            [containerView addSubview:view];
        }else{
            
            view = [transitionContext viewForKey:UITransitionContextFromViewKey];
            fromCenter = view.center;
            toCenter = center;
        }
        
        NSString *keyPath = @"position";
        [CATransaction begin];
        CATransaction.completionBlock =^ {
            
            [view.layer removeAnimationForKey:keyPath];
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!wasCancelled];
        };
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
        animation.duration = [self transitionDuration:transitionContext];
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeBoth;
        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0 :0 :0.2 :1];
        
        animation.fromValue = @(fromCenter);
        animation.toValue = @(toCenter);
        [view.layer addAnimation:animation forKey:keyPath];
        
        [CATransaction commit];
    }
}


@end

@interface GKPartialPresentInteractiveTransition()

@property(nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

///交互前的frame
@property(nonatomic, assign) CGRect frame;

///要交互的视图
@property(nonatomic, weak) UIView *view;

@end

@implementation GKPartialPresentInteractiveTransition

- (void)setPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if(_panGestureRecognizer != panGestureRecognizer){
        _panGestureRecognizer = panGestureRecognizer;
        
        //添加手势监听
        [_panGestureRecognizer addTarget:self action:@selector(handlePan:)];
    }
}

- (void)dealloc
{
    //移除手势
    [self.panGestureRecognizer removeTarget:self action:@selector(handlePan:)];
}

// MARK: - super method

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    self.frame = self.delegate.props.frame;
    self.view = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    [super startInteractiveTransition:transitionContext];
}

- (CGFloat)percentForGesture:(UIPanGestureRecognizer *)gesture
{
    UIView *containerView = self.transitionContext.containerView;
    
    CGPoint point = [gesture translationInView:containerView];
    CGFloat percent;
    switch (self.delegate.props.transitionStyle) {
        case GKPresentTransitionStyleFromTop : {
            percent = point.y / self.view.gkHeight;
        }
            break;
        case GKPresentTransitionStyleFromBottom : {
            percent = point.y / self.view.gkHeight;
        }
            break;
        case GKPresentTransitionStyleFromRight : {
            percent = point.x / self.view.gkWidth;
        }
            break;
        case GKPresentTransitionStyleFromLeft : {
            percent = point.x / self.view.gkWidth;
        }
            break;
    }
    
    return percent;
}

///平移手势
- (void)handlePan:(UIPanGestureRecognizer*) pan
{
    switch (pan.state){
        case UIGestureRecognizerStateBegan :
        case UIGestureRecognizerStateChanged: {
            
            CGFloat percent = [self percentForGesture:pan];
            CGRect frame = self.view.frame;
            
            switch (self.delegate.props.transitionStyle) {
                case GKPresentTransitionStyleFromTop : {
                    CGFloat centerY = self.frame.origin.y + frame.size.height / 2 + frame.size.height * percent;
                    if(centerY > CGRectGetMidY(self.frame)) {
                        centerY = CGRectGetMidY(self.frame);
                    }
                    self.view.gkCenterY = centerY;
                }
                    break;
                case GKPresentTransitionStyleFromBottom : {
                    if(pan == self.delegate.scrollView.panGestureRecognizer){
                        if(self.percentComplete > 0 || self.delegate.scrollView.contentOffset.y <= 0){
                            self.delegate.scrollView.contentOffset = CGPointZero;
                        }else{
                            percent = 0;
                        }
                    }
                    CGFloat centerY = self.frame.origin.y + frame.size.height / 2 + frame.size.height * percent;
                    if(centerY < CGRectGetMidY(self.frame)) {
                        centerY = CGRectGetMidY(self.frame);
                    }
                    self.view.gkCenterY = centerY;
                }
                    break;
                case GKPresentTransitionStyleFromRight : {
                    CGFloat centerX = self.frame.origin.x + frame.size.width / 2 + frame.size.width * percent;
                    if(centerX < CGRectGetMidX(self.frame)) {
                        centerX = CGRectGetMidX(self.frame);
                    }
                    self.view.gkCenterX = centerX;
                }
                    break;
                case GKPresentTransitionStyleFromLeft : {
                    CGFloat centerX = self.frame.origin.x + frame.size.width / 2 + frame.size.width * percent;
                    if(centerX > CGRectGetMidX(self.frame)) {
                        centerX = CGRectGetMidX(self.frame);
                    }
                    self.view.gkCenterX = centerX;
                }
                    break;
            }
            [self updateInteractiveTransition:percent];
        }
            break;
        default: {
            [self interactiveComplete:pan];
        }
            break;
    }
}

- (void)interactiveComplete:(UIPanGestureRecognizer*) pan
{
    UIView *containerView = self.transitionContext.containerView;
    
    BOOL finished = [self percentForGesture:pan] >= 0.5;
    if(!finished){
        //快速滑动也算完成
        CGPoint velocity = [pan velocityInView:containerView];
        switch (self.delegate.props.transitionStyle) {
            case GKPresentTransitionStyleFromTop :
                finished = velocity.y < -1000;
                break;
            case GKPresentTransitionStyleFromBottom :
                finished = velocity.y > 1000;
                break;
            case GKPresentTransitionStyleFromRight :
                finished = velocity.x > 1000;
                break;
            case GKPresentTransitionStyleFromLeft :
                finished = velocity.x < -1000;
                break;
        }
    }
    
    if(finished){
        [self finishInteractiveTransition];
    }else{
        [self cancelInteractiveTransition];
    }
    
    [CATransaction begin];
    
    NSString *keyPath = @"position";
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.duration = self.duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0 :0 :0.2 :1];

    CGPoint center;
    if(finished){
        switch (self.delegate.props.transitionStyle) {
            case GKPresentTransitionStyleFromTop : {
                center = CGPointMake(self.view.gkCenterX, -self.view.gkHeight / 2);
            }
                break;
            case GKPresentTransitionStyleFromBottom : {
                center = CGPointMake(self.view.gkCenterX, containerView.gkBottom + self.view.gkHeight / 2);
            }
                break;
            case GKPresentTransitionStyleFromLeft : {
                center = CGPointMake(-self.view.gkWidth / 2, self.view.gkCenterY);
            }
                break;
            case GKPresentTransitionStyleFromRight : {
                center = CGPointMake(containerView.gkRight + self.view.gkWidth / 2, self.view.gkCenterY);
            }
                break;
        }
        
    }else{
        center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
    
    animation.fromValue = @(self.view.center);
    animation.toValue = @(center);
    
    CATransaction.completionBlock =^ {
        self.view.center = [animation.toValue CGPointValue];
        [self.transitionContext completeTransition:finished];
        [self.view.layer removeAnimationForKey:keyPath];
    };
    [self.view.layer addAnimation:animation forKey:keyPath];
    [CATransaction commit];
}

@end

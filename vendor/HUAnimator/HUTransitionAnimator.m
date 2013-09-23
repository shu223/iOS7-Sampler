//
//  HUOldStylePushPopAnimator.m
//  EasyBeats
//
//  Created by Christian Inkster on 13/09/13.
//
//

#import "HUTransitionAnimator.h"



@implementation HUTransitionAnimator

#define OLDPUSHANIMATION_TIME 0.25
/// returns the duration of the oldPushAnimation
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return OLDPUSHANIMATION_TIME;
}

/**
 oldPushTransition
 Simulates the original push and pop transitions available in iOS 6 and earlier.
 @param transitionContext
 */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [transitionContext initialFrameForViewController:fromVC];
    
    
    
    if (self.presenting) {
        
        fromVC.view.frame = endFrame;
        [transitionContext.containerView addSubview:fromVC.view];
        
        UIView *toView = [toVC view];
        [transitionContext.containerView addSubview:toView];
        
        //get the original position of the frame
        CGRect startFrame = toView.frame;
        //save the unmodified frame as our end frame
        endFrame = startFrame;
        
        //now move the start frame to the left by our width
        startFrame.origin.x += CGRectGetWidth(startFrame);
        toView.frame = startFrame;
        
        //now set up the destination for the outgoing view
        UIView *fromView = [fromVC view];
        CGRect outgoingEndFrame = fromView.frame;
        outgoingEndFrame.origin.x -= CGRectGetWidth(outgoingEndFrame);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            toView.frame = endFrame;
            toView.alpha = 1;
            fromView.frame = outgoingEndFrame;
            fromView.alpha = 0;
        } completion:^(BOOL finished) {
            fromView.alpha = 1;
            [toView setNeedsUpdateConstraints];
            [transitionContext completeTransition:YES];
            
        }];
  
    }
    else {
        UIView *toView = [toVC view];
        
        //incoming view
        CGRect toFrame = [transitionContext finalFrameForViewController:toVC];
        toFrame.origin.x -= CGRectGetWidth(toFrame);
        toView.frame = toFrame;
        toFrame = [transitionContext finalFrameForViewController:toVC];
        
        [transitionContext.containerView addSubview:toView];
        [transitionContext.containerView addSubview:fromVC.view];
        
        //outgoing view
        endFrame.origin.x += CGRectGetWidth(endFrame);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toView.frame = toFrame;
            toView.alpha = 1;
            fromVC.view.frame = endFrame;
            fromVC.view.alpha = 0;
        } completion:^(BOOL finished) {
            fromVC.view.alpha = 1;
            [transitionContext completeTransition:YES];
        }];
    }
    
}




@end

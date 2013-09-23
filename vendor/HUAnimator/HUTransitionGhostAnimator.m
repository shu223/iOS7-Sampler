//
//  HUTransitionGhostAnimator.m
//  EasyBeats
//
//  Created by Christian Inkster on 16/09/13.
//
//

#import "HUTransitionGhostAnimator.h"

@implementation HUTransitionGhostAnimator

#define GHOSTANIMATION_TIME1 0.1
#define GHOSTANIMATION_TIME2 0.20
/// returns the duration of the oldPushAnimation
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return GHOSTANIMATION_TIME1+GHOSTANIMATION_TIME2;
}

/**
 ghostPushTransition
 Simulates the original push and pop transitions available in iOS 6 and earlier, but gives a short ghosting effect first
 @param transitionContext
 */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [transitionContext initialFrameForViewController:fromVC];
    
    
    
    if (self.presenting) {
        
        //lets get a snapshot of the outgoing view
        UIView *ghost = [fromVC.view snapshotViewAfterScreenUpdates:NO];
        
        //get the container view
        UIView *containerView = [transitionContext containerView];
        
        //put the ghost in the container
        [containerView addSubview:ghost];
        
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
        
        [UIView animateKeyframesWithDuration:GHOSTANIMATION_TIME1 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            CGRect ghostRect = ghost.frame;
            ghostRect.origin.x += 25;
            
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.3 animations:^{
                ghost.frame = ghostRect;
            }];
            ghostRect.origin.x -= 100;
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                ghost.frame = ghostRect;
            }];
            
            ghost.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:GHOSTANIMATION_TIME2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                toView.frame = endFrame;
                toView.alpha = 1;
                fromView.frame = outgoingEndFrame;
                fromView.alpha = 0;
            } completion:^(BOOL finished) {
                fromView.alpha = 1;
                [toView setNeedsUpdateConstraints];
                [transitionContext completeTransition:YES];
                
            }];
        }];
    }
    else {
        UIView *toView = [toVC view];
        
        //incoming view
        CGRect toFrame = endFrame;
        toFrame.origin.x -= CGRectGetWidth(toFrame);
        toView.frame = toFrame;
        toFrame = endFrame;
        
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

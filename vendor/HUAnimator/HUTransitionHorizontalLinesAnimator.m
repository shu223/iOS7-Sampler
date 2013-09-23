//
//  HUTransitionHorizontalLinesAnimator.m
//  EasyBeats
//
//  Created by Christian Inkster on 16/09/13.
//
//

#import "HUTransitionHorizontalLinesAnimator.h"


@implementation HUTransitionHorizontalLinesAnimator

#define HLANIMATION_TIME1 0.01
#define HLANIMATION_TIME2 4.70
/// returns the duration of the verticalLinesAnimation
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return HLANIMATION_TIME1+HLANIMATION_TIME2;
}


#define HLINEHEIGHT 4.0
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //get the container view
    UIView *containerView = [transitionContext containerView];
    
    //lets get a snapshot of the outgoing view
    UIView *mainSnap = [fromVC.view snapshotViewAfterScreenUpdates:NO];
    //cut it into vertical slices
    NSArray *outgoingLineViews = [self cutView:mainSnap intoSlicesOfHeight:HLINEHEIGHT yOffset:fromVC.view.frame.origin.y];
    
    //add the slices to the content view.
    for (UIView *v in outgoingLineViews) {
        [containerView addSubview:v];
    }
    
    
    UIView *toView = [toVC view];
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView addSubview:toView];
    
    
    CGFloat toViewStartX = toView.frame.origin.x;
    toView.alpha = 0;
    fromVC.view.hidden = YES;
    
    BOOL presenting = self.presenting;
    
    [UIView animateWithDuration:HLANIMATION_TIME1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //This is basically a hack to get the incoming view to render before I snapshot it.
    } completion:^(BOOL finished) {
        
        toVC.view.alpha = 1;
        UIView *mainInSnap = [toView snapshotViewAfterScreenUpdates:YES];
        //cut it into vertical slices
        NSArray *incomingLineViews = [self cutView:mainInSnap intoSlicesOfHeight:HLINEHEIGHT yOffset:toView.frame.origin.y];
        
        //move the slices in to start position (incoming comes from the right)
        [self repositionViewSlices:incomingLineViews moveLeft:!presenting];
        
        //add the slices to the content view.
        for (UIView *v in incomingLineViews) {
            [containerView addSubview:v];
        }
        toView.hidden = YES;
        
        [UIView animateWithDuration:HLANIMATION_TIME2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self repositionViewSlices:outgoingLineViews moveLeft:presenting];
            [self resetViewSlices:incomingLineViews toXOrigin:toViewStartX];
        } completion:^(BOOL finished) {
            fromVC.view.hidden = NO;
            toView.hidden = NO;
            [toView setNeedsUpdateConstraints];
            for (UIView *v in incomingLineViews) {
                [v removeFromSuperview];
            }
            for (UIView *v in outgoingLineViews) {
                [v removeFromSuperview];
            }
            [transitionContext completeTransition:YES];
        }];
        
    }];
    
}

/**
 cuts a \a view into an array of smaller views of \a height
 @param view the view to be sliced up
 @param height The height of each slice
 @returns A mutable array of the sliced views with their frames representative of their position in the sliced view.
 */
-(NSMutableArray *)cutView:(UIView *)view intoSlicesOfHeight:(float)height yOffset:(float)yOffset{
    
    CGFloat lineWidth = CGRectGetWidth(view.frame);
    
    NSMutableArray *lineViews = [NSMutableArray array];
    
    for (int y=0; y<CGRectGetHeight(view.frame); y+=height) {
        CGRect subrect = CGRectMake(0, y, lineWidth, height);
        
        
        UIView *subsnapshot;
        subsnapshot = [view resizableSnapshotViewFromRect:subrect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        subrect.origin.y += yOffset;
        subsnapshot.frame = subrect;
        
        [lineViews addObject:subsnapshot];
    }
    return lineViews;
    
}

/**
 repositions an array of \a views to the left or right by their frames width
 @param views The array of views to reposition
 @param left should the frames be moved to the left
 */
-(void)repositionViewSlices:(NSArray *)views moveLeft:(BOOL)left{
    

    CGRect frame;
    float width;
    for (UIView *line in views) {
        frame = line.frame;
        width = CGRectGetWidth(frame) * RANDOM_FLOAT(1.0, 8.0);
        
        frame.origin.x += (left)?-width:width;
        
        //save the new position
        line.frame = frame;
    }
}

/**
 resets the views back to a specified x origin.
 @param views The array of uiview objects to reposition
 @param x The x origin to set all the views frames to.
 */
-(void)resetViewSlices:(NSArray *)views toXOrigin:(CGFloat)x{
    
    CGRect frame;
    for (UIView *line in views) {
        frame = line.frame;
        
        frame.origin.x = x;
        
        //save the new position
        line.frame = frame;
        
    }
}



@end

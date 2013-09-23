//
//  HUTransitionVerticalLinesAnimator.m
//  EasyBeats
//
//  Created by Christian Inkster on 16/09/13.
//
//

#import "HUTransitionVerticalLinesAnimator.h"



@implementation HUTransitionVerticalLinesAnimator

#define VLANIMATION_TIME1 0.01
#define VLANIMATION_TIME2 4.0
/// returns the duration of the verticalLinesAnimation
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return VLANIMATION_TIME1+VLANIMATION_TIME2;
}


#define VLINEWIDTH 4.0
/**
 verticalLinesTransition
 snapshots the outgoing view, slices it into vertical lines, then animates them at random rates off the screen.
 @param transitionContext
 */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //get the container view
    UIView *containerView = [transitionContext containerView];
    
    //lets get a snapshot of the outgoing view
    UIView *mainSnap = [fromVC.view snapshotViewAfterScreenUpdates:NO];
    //cut it into vertical slices
    NSArray *outgoingLineViews = [self cutView:mainSnap intoSlicesOfWidth:VLINEWIDTH];
    
    //add the slices to the content view.
    for (UIView *v in outgoingLineViews) {
        [containerView addSubview:v];
    }
    
    
    UIView *toView = [toVC view];
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView addSubview:toView];
    
    
    CGFloat toViewStartY = toView.frame.origin.y;
    toView.alpha = 0;
    fromVC.view.hidden = YES;
    
    
    [UIView animateWithDuration:VLANIMATION_TIME1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //This is basically a hack to get the incoming view to render before I snapshot it.
    } completion:^(BOOL finished) {
        
        toVC.view.alpha = 1;
        UIView *mainInSnap = [toView snapshotViewAfterScreenUpdates:YES];
        //cut it into vertical slices
        NSArray *incomingLineViews = [self cutView:mainInSnap intoSlicesOfWidth:VLINEWIDTH];
        
        //move the slices in to start position (mess them up)
        [self repositionViewSlices:incomingLineViews moveFirstFrameUp:NO];
        
        //add the slices to the content view.
        for (UIView *v in incomingLineViews) {
            [containerView addSubview:v];
        }
        toView.hidden = YES;
        
        [UIView animateWithDuration:VLANIMATION_TIME2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self repositionViewSlices:outgoingLineViews moveFirstFrameUp:YES];
            [self resetViewSlices:incomingLineViews toYOrigin:toViewStartY];
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
 cuts a \a view into an array of smaller views of \a width
 @param view the view to be sliced up
 @param width The width of each slice
 @returns A mutable array of the sliced views with their frames representative of their position in the sliced view.
 */
-(NSMutableArray *)cutView:(UIView *)view intoSlicesOfWidth:(float)width{
    
    CGFloat lineHeight = CGRectGetHeight(view.frame);
    
    NSMutableArray *lineViews = [NSMutableArray array];
    
    for (int x=0; x<CGRectGetWidth(view.frame); x+=width) {
        CGRect subrect = CGRectMake(x, 0, width, lineHeight);
        
        
        UIView *subsnapshot;
        subsnapshot = [view resizableSnapshotViewFromRect:subrect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        subsnapshot.frame = subrect;
        
        [lineViews addObject:subsnapshot];
    }
    return lineViews;
    
}

/**
 repositions an array of \a views alternatively up and down by their frames height
 @param views The array of views to reposition
 @param startUp start with the first view moving up (YES) or down (NO)
 */
-(void)repositionViewSlices:(NSArray *)views moveFirstFrameUp:(BOOL)startUp{
    
    BOOL up = startUp;
    CGRect frame;
    float height;
    for (UIView *line in views) {
        frame = line.frame;
        height = CGRectGetHeight(frame) * RANDOM_FLOAT(1.0, 4.0);
        
        frame.origin.y += (up)?-height:height;
        
        //save the new position
        line.frame = frame;
        
        up = !up;
    }
}

/**
 resets the views back to a specified y origin.
 @param views The array of uiview objects to reposition
 @param y The y origin to set all the views frames to.
 */
-(void)resetViewSlices:(NSArray *)views toYOrigin:(CGFloat)y{
    
    CGRect frame;
    for (UIView *line in views) {
        frame = line.frame;
        
        frame.origin.y = y;
        
        //save the new position
        line.frame = frame;
        
    }
}



@end

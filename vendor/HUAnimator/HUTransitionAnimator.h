//
//  HUTransitionAnimator.h
//  HUSoft
//
//  Created by Christian Inkster on 13/09/13.
//
//

/**
 Class that demonstrates a few navigation push pop animations.
 
 To use add the following to your navigationcontroller.delegate
 
 For the standard IOS 6 style push pop use the following.
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    
    HUTransitionAnimator *animator = [[HUTransitionAnimator alloc] init];
    animator.presenting = (operation == UINavigationControllerOperationPop)?NO:YES;
    return animator;
    
}
 
 I've also included a couple of other ones I experimented with.  To try them just replace [HUTransitionAnimator alloc] with [HUTransitionVerticalLinesAnimator alloc] or whichever class you like.
*/



#import <Foundation/Foundation.h>

/**
 Standard random float code
 @param min
 @param max
 @result random number between min and max
 */
#define RANDOM_FLOAT(MIN,MAX) (((CGFloat)arc4random() / 0x100000000) * (MAX - MIN) + MIN);


@interface HUTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL presenting;
@end


/**
 The imports for the subclasses, just included here to make switching easier in the Tokyo iOS Meetup Demo.
 */
#import "HUTransitionGhostAnimator.h"
#import "HUTransitionVerticalLinesAnimator.h"
#import "HUTransitionHorizontalLinesAnimator.h"
#import "ZBFallenBricksAnimator.h"
#import "UIViewController+Animator.h"

static NSInteger const row = 5;
static NSInteger const column = 5;

@implementation ZBFallenBricksAnimator
{
	NSMutableArray *views;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
	return 2.0;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
	if (!views) {
		views = [[NSMutableArray alloc] init];
	}

	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	CGFloat width = containerView.bounds.size.width / row;
	CGFloat height = containerView.bounds.size.height / column;
	NSInteger index = [toVC.view.subviews count];
	for (NSInteger i = 0; i < row; i++) {
		for (NSInteger j = 0; j < column; j++) {
			CGRect aRect = CGRectMake(j * width, i * height, width, height);
            UIView *aView = [fromVC.view resizableSnapshotViewFromRect:aRect
                                                    afterScreenUpdates:NO
                                                         withCapInsets:UIEdgeInsetsZero];
			aView.frame = aRect;
			CGFloat angle = ((j + i) % 2 ? 1 : -1) * (rand() % 5 / 10.0);
			aView.transform = CGAffineTransformMakeRotation(angle);
			aView.layer.borderWidth = 0.5;
			aView.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
			[views addObject:aView];
			[toVC.view insertSubview:aView atIndex:index];
		}
	}
	[fromVC.view removeFromSuperview];
	[containerView addSubview:toVC.view];	

	UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:toVC.view];
	UIDynamicBehavior *behaviour = [[UIDynamicBehavior alloc] init];
	UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:views];
	UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:views];
	collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
	collisionBehavior.collisionMode = UICollisionBehaviorModeBoundaries;

	[behaviour addChildBehavior:gravityBehaviour];
	[behaviour addChildBehavior:collisionBehavior];

	for (UIView *aView in views) {
		UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[aView]];
		itemBehaviour.elasticity = (rand() % 5) / 8.0;
		itemBehaviour.density = (rand() % 5 / 3.0);
//		itemBehaviour.allowsRotation = YES;
		[behaviour addChildBehavior:itemBehaviour];
	}

	[animator addBehavior:behaviour];
	toVC.animator = animator;

	[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
		for (UIView *aView in views) {
			aView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		for (UIView *view in views) {
			[view removeFromSuperview];
		}
		[views removeAllObjects];
		[transitionContext completeTransition:YES];
	}];
}
@end

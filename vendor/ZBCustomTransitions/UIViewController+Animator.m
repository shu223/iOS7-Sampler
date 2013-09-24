#import "UIViewController+Animator.h"
#import <objc/runtime.h>

@implementation UIViewController (Animator)

- (id)animator
{
	return objc_getAssociatedObject(self, "animator");
}

- (void)setAnimator:(id)animator
{
	objc_setAssociatedObject(self, "animator", animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

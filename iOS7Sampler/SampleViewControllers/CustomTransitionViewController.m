//
//  CustomTransitionViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/21/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "CustomTransitionViewController.h"
#import "HUTransitionAnimator.h"


typedef enum {
    TransitionTypeNormal,
    TransitionTypeVerticalLines,
    TransitionTypeHorizontalLines,
} TransitionType;


@interface CustomTransitionViewController ()
<UINavigationControllerDelegate>
{
    TransitionType type;
}
@end


@implementation CustomTransitionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    type = TransitionTypeNormal;
    
    self.navigationController.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// =============================================================================
#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    HUTransitionAnimator *animator;
    
    switch (type) {
        case TransitionTypeVerticalLines:
            animator = [[HUTransitionVerticalLinesAnimator alloc] init];
            break;
        case TransitionTypeHorizontalLines:
            animator = [[HUTransitionHorizontalLinesAnimator alloc] init];
            break;
        default:
            animator = nil;
    }
    
    animator.presenting = (operation == UINavigationControllerOperationPop) ? NO : YES;

    return animator;
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)pop:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0:
            type = TransitionTypeVerticalLines;
            break;
            
        case 1:
            type = TransitionTypeHorizontalLines;
            break;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

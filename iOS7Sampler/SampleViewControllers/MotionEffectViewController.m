//
//  MotionEffectViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/21/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "MotionEffectViewController.h"


@interface MotionEffectViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *charaImageView;
@end


@implementation MotionEffectViewController

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

    [self registerEffectForView:self.bgImageView depth:14];
    [self registerEffectForView:self.charaImageView depth:50.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// =============================================================================
#pragma mark - Private

- (void)registerEffectForView:(UIView *)aView depth:(CGFloat)depth;
{
	UIInterpolatingMotionEffect *effectX;
	UIInterpolatingMotionEffect *effectY;
    effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                              type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                              type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	
	
	effectX.maximumRelativeValue = @(depth);
	effectX.minimumRelativeValue = @(-depth);
	effectY.maximumRelativeValue = @(depth);
	effectY.minimumRelativeValue = @(-depth);
	
	[aView addMotionEffect:effectX];
	[aView addMotionEffect:effectY];
}


@end

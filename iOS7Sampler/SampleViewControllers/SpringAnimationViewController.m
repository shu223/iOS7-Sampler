//
//  SpringAnimationViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 2/10/14.
//  Copyright (c) 2014 Shuichi Tsutsumi. All rights reserved.
//

#import "SpringAnimationViewController.h"


@interface SpringAnimationViewController ()
{
    CGPoint orgPos;
    CGPoint targetPos;
}
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *paramLabel1;
@property (nonatomic, weak) IBOutlet UILabel *paramLabel2;
@property (nonatomic, weak) IBOutlet UISlider *paramSlider1;
@property (nonatomic, weak) IBOutlet UISlider *paramSlider2;
@end


@implementation SpringAnimationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidLayoutSubviews {

    orgPos = self.imageView.center;
    targetPos = CGPointMake(orgPos.x + 240, orgPos.y);
    
    [self updateLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


// =============================================================================
#pragma mark - Private

- (void)updateLabels {
    
    self.paramLabel1.text = [NSString stringWithFormat:@"%.2f", self.paramSlider1.value];
    self.paramLabel2.text = [NSString stringWithFormat:@"%.2f", self.paramSlider2.value];
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)startButtonTapped:(UIButton *)sender {
    
    sender.enabled = NO;
    self.imageView.center = orgPos;
    
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:self.paramSlider1.value
          initialSpringVelocity:self.paramSlider2.value
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         self.imageView.center = targetPos;
                     }
                     completion:^(BOOL finished) {
                         
                         sender.enabled = YES;
                     }];
}

- (IBAction)sliderChanged:(UISlider *)sender {
    
    [self updateLabels];
}

@end

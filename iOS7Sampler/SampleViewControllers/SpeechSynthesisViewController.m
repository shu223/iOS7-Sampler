//
//  SpeechSynthesisViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/21/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "SpeechSynthesisViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface SpeechSynthesisViewController ()
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@end


@implementation SpeechSynthesisViewController

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
    
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)say {

    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.textField.text];
    [self.synthesizer speakUtterance:utterance];
}

@end

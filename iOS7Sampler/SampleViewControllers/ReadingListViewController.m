//
//  ReadingListViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 10/2/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "ReadingListViewController.h"
#import <SafariServices/SafariServices.h>


@interface ReadingListViewController ()

@end


@implementation ReadingListViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)addToReadingList {

    NSURL *url = [NSURL URLWithString:@"https://github.com/shu223/iOS7-Sampler"];
    NSError *err;
    
    BOOL result = [[SSReadingList defaultReadingList] addReadingListItemWithURL:url
                                                                          title:@"iOS7 Sampler"
                                                                    previewText:@"Code examples for the new functions of iOS 7."
                                                                          error:&err];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    
    if (!result) {
        
        alert.title = @"Failed!";
        alert.message = [NSString stringWithFormat:@"Error:%@", err.description];
    }
    else {
        
        alert.title = @"Done!";
        alert.message = @"Added to the Safari Reading List.";
    }
    
    [alert show];
}

@end

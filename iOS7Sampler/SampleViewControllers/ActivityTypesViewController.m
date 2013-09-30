//
//  ActivityTypesViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/21/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "ActivityTypesViewController.h"


@interface ActivityTypesViewController ()

@end


@implementation ActivityTypesViewController

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
#pragma mark - Private

- (NSArray *)iOS6Activities {
    
    NSArray *activities = @[UIActivityTypePostToFacebook,
                            UIActivityTypePostToTwitter,
                            UIActivityTypePostToWeibo,
                            UIActivityTypeMail,
                            UIActivityTypeMessage,
                            UIActivityTypePrint,
                            UIActivityTypeSaveToCameraRoll,
                            UIActivityTypeCopyToPasteboard,
                            UIActivityTypeAssignToContact];
    
    return activities;
}

- (UIImage *)createRandomImage {

    NSUInteger num = arc4random() % 40 + 1;
    NSString *filename = [NSString stringWithFormat:@"m%lu", (unsigned long)num];
    UIImage *image = [UIImage imageNamed:filename];
    
    return image;
}


// =============================================================================
#pragma mark - IBAction

/*
 UIActivityTypeAirDrop
 The object makes the provided content available via AirDrop.
 When using this service, you can provide NSString, NSAttributedString, UIImage, ALAsset, and NSURL objects as data for the activity items. You may also specify NSURL objects whose contents use the assets-library scheme. You may also provide NSArray or NSDictionary objects that contain the listed data types.
 */
- (IBAction)showAirDropActivty {
    
    UIImage *image = [self createRandomImage];
    UIActivityViewController *activityCtr = [[UIActivityViewController alloc] initWithActivityItems:@[image]
                                                                              applicationActivities:nil];

    // exclude activity types which can be used after iOS6
    NSMutableArray *excludedActivities = [self iOS6Activities].mutableCopy;
    [excludedActivities addObject:UIActivityTypeAddToReadingList];
    [excludedActivities addObject:UIActivityTypePostToFlickr];
    [excludedActivities addObject:UIActivityTypePostToTencentWeibo];
    [excludedActivities addObject:UIActivityTypePostToVimeo];
    [activityCtr setExcludedActivityTypes:excludedActivities];

    [self presentViewController:activityCtr
                       animated:YES
                     completion:nil];
}


/*
 UIActivityTypeAddToFlickr
 The object posts the provided image to the user’s Flickr account.
 When using this service, you can provide UIImage, ALAsset, NSURL objects whose contents use the file scheme and point to an image, and NSData objects whose contents are image data as data for the activity items. You may also specify NSURL objects whose contents use the assets-library scheme.
 */
- (IBAction)showFlickrActivty {
    
    UIImage *image = [self createRandomImage];
    UIActivityViewController *activityCtr = [[UIActivityViewController alloc] initWithActivityItems:@[image]
                                                                              applicationActivities:nil];
    
    // exclude activity types which can be used after iOS6
    NSMutableArray *excludedActivities = [self iOS6Activities].mutableCopy;
    [excludedActivities addObject:UIActivityTypeAirDrop];
    [excludedActivities addObject:UIActivityTypeAddToReadingList];
    [excludedActivities addObject:UIActivityTypePostToTencentWeibo];
    [excludedActivities addObject:UIActivityTypePostToVimeo];
    [activityCtr setExcludedActivityTypes:excludedActivities];
    
    [self presentViewController:activityCtr
                       animated:YES
                     completion:nil];
}


/*
 UIActivityTypePostToVimeo
 The object posts the provided video to the user’s Vimeo account.
 When using this service, you can provide ALAsset, NSURL objects whose contents use the file scheme and point to a video, and NSData objects whose contents are video data as data for the activity items. You may also specify NSURL objects whose contents use the assets-library scheme.
 */
- (IBAction)showVimeoActivity {
    
    NSLog(@"Sorry, this sample is not available yet.");
}


/*
 UIActivityTypeAddToReadingList
 The object adds the URL to Safari’s reading list.
 When using this service, you can provide an NSURL object whose contents uses the http or https scheme that points to the page to add.
 */
- (IBAction)showReadingListActivity {
    
    NSURL *url = [NSURL URLWithString:@"http://d.hatena.ne.jp/shu223/"];
    UIActivityViewController *activityCtr = [[UIActivityViewController alloc] initWithActivityItems:@[url]
                                                                              applicationActivities:nil];
    
    // exclude activity types which can be used after iOS6
    NSMutableArray *excludedActivities = [self iOS6Activities].mutableCopy;
    [excludedActivities addObject:UIActivityTypeAirDrop];
    [excludedActivities addObject:UIActivityTypePostToFlickr];
    [excludedActivities addObject:UIActivityTypePostToTencentWeibo];
    [excludedActivities addObject:UIActivityTypePostToVimeo];
    [activityCtr setExcludedActivityTypes:excludedActivities];
    
    [self presentViewController:activityCtr
                       animated:YES
                     completion:nil];
}

@end

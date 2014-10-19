//
//  MasterViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/21/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "MasterViewController.h"
#import "BrowseCodeViewController.h"


#define kItemKeyTitle       @"title"
#define kItemKeyDescription @"description"
#define kItemKeyClassPrefix @"prefix"


@interface MasterViewController ()
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *currentClassName;
@end


@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = @[
                   // Dynamic Behaviors
                   @{kItemKeyTitle: @"Dynamic Behaviors",
                     kItemKeyDescription: @"UIDynamicAnimator, UICollisionBehavior, etc...",
                     kItemKeyClassPrefix: @"DynamicBehaviors",
                     },
                   
                   // Speech Synthesis
                   @{kItemKeyTitle: @"Speech Synthesis",
                     kItemKeyDescription: @"Synthesized speech from text using AVSpeechSynthesizer and AVSpeechUtterance.",
                     kItemKeyClassPrefix: @"SpeechSynthesis",
                     },

                   // Custom Transition
                   @{kItemKeyTitle: @"Custom Transition",
                     kItemKeyDescription: @"UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate",
                     kItemKeyClassPrefix: @"CustomTransition",
                     },

                   // 3D Map
                   @{kItemKeyTitle: @"3D Map",
                     kItemKeyDescription: @"3D Map using MKMapCamera",
                     kItemKeyClassPrefix: @"Map3D",
                     },
                   
                   // iBeacon (monitoring)
                   @{kItemKeyTitle: @"iBeacon",
                     kItemKeyDescription: @"Region monitoring demo using iBeacon.",
                     kItemKeyClassPrefix: @"Beacon",
                     },

                   // 120fps Video Recording
                   @{kItemKeyTitle: @"120 fps SLO-MO video recording",
                     kItemKeyDescription: @"SLO-MO video recorder using AVFoundation. It works with 120fps on iPhone5s.",
                     kItemKeyClassPrefix: @"SloMoVideoRecord",
                     },
                   
                   // Smile Detection
                   @{kItemKeyTitle: @"Smile Detection",
                     kItemKeyDescription: @"Smile Detection using CIDetectorSmile and new properties of CIFeature such as \"bounds\".",
                     kItemKeyClassPrefix: @"SmileDetection",
                     },
                   
                   // Image Filters
                   @{kItemKeyTitle: @"Image Filters",
                     kItemKeyDescription: @"New filters of CIFilter such as CIPhotoEffectProcess, CIVignetteEffect, CILinearToSRGBToneCurve, ...",
                     kItemKeyClassPrefix: @"ImageFilters",
                     },
                   
                   // Sprite Kit
                   @{kItemKeyTitle: @"Sprite Kit",
                     kItemKeyDescription: @"A sample of Sprite Kit using SKView, SKScene, SKSpriteNode, SKAction.",
                     kItemKeyClassPrefix: @"SpriteKit",
                     },

                   // Map Directions
                   @{kItemKeyTitle: @"Map Directions",
                     kItemKeyDescription: @"Requesting and draw directions using MKDirections, MKDirectionsResponse and MKPolylineRenderer.",
                     kItemKeyClassPrefix: @"MapDirections",
                     },

                   // Motion Effect
                   @{kItemKeyTitle: @"Motion Effects (Parallax)",
                     kItemKeyDescription: @"Parallax effect using UIMotionEffect",
                     kItemKeyClassPrefix: @"MotionEffect",
                     },
                   
                   // MultipeerConnectivity
                   @{kItemKeyTitle: @"Multipeer Connectivity",
                     kItemKeyDescription: @"Creating a local network sharing connection over Wi-Fi or Bluetooth LE.",
                     kItemKeyClassPrefix: @"MultipeerConnectivity",
                     },

                   // Added Activity Types
                   @{kItemKeyTitle: @"AirDrop/Flickr/Vimeo/ReadingList",
                     kItemKeyDescription: @"New Activity Types: AirDrop, Post to Flickr / Vimeo, Add to ReadingList",
                     kItemKeyClassPrefix: @"ActivityTypes",
                     },
                   
                   // QR Code Generator
                   @{kItemKeyTitle: @"QR Code Generator",
                     kItemKeyDescription: @"Generating QR Code with CIQRCodeGenerator.",
                     kItemKeyClassPrefix: @"QRCode",
                     },

                   // Motion Activity Tracking
                   @{kItemKeyTitle: @"Motion Activity Tracking",
                     kItemKeyDescription: @"Counting steps and monitoring the activity using CMStepCounter and CMMotionActivityManager. It works only on devices with M7 or M8 chips.",
                     kItemKeyClassPrefix: @"ActivityTracking",
                     },

                   // Static Map Snapshots
                   @{kItemKeyTitle: @"Static Map Snapshots",
                     kItemKeyDescription: @"Creating a snapshot with MKMapSnapshotOptions, MKMapSnapshotter.",
                     kItemKeyClassPrefix: @"MapSnapshot",
                     },

                   // Reading List
                   @{kItemKeyTitle: @"Safari Reading List",
                     kItemKeyDescription: @"Adding an item to the Safari Reading List with the new Safari Services framework.",
                     kItemKeyClassPrefix: @"ReadingList",
                     },
                   
                   // New Fonts
                   @{kItemKeyTitle: @"New Fonts",
                     kItemKeyDescription: @"Displaying new fonts with their FontNames which are needed for \"fontWithName:size:\" method of UIFont.",
                     kItemKeyClassPrefix: @"Fonts",
                     },
                   
                   // Spring Animation
                   @{kItemKeyTitle: @"Spring Animation",
                     kItemKeyDescription: @"Performs animations using a timing curve described by the motion of a spring.",
                     kItemKeyClassPrefix: @"SpringAnimation",
                     },

                   // Web Pagination
                   @{kItemKeyTitle: @"Web Pagination",
                     kItemKeyDescription: @"Pagination sample for web pages. It uses new property \"paginationMode\" of UIWebView.",
                     kItemKeyClassPrefix: @"WebPagination",
                     },
                   ];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Needed after custome transition
    self.navigationController.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


// =============================================================================
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
	NSDictionary *info = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = info[kItemKeyTitle];
    cell.detailTextLabel.text = info[kItemKeyDescription];
    
    return cell;
}


// =============================================================================
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *item = self.items[indexPath.row];
    NSString *className = [item[kItemKeyClassPrefix] stringByAppendingString:@"ViewController"];
    
    if (NSClassFromString(className)) {

        Class aClass = NSClassFromString(className);
        id instance = [[aClass alloc] init];
        
        if ([instance isKindOfClass:[UIViewController class]]) {
            
            self.currentClassName = className;
            
            UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"ViewCode"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(viewCodeButtonTapped:)];
            [(UIViewController *)instance navigationItem].rightBarButtonItem = barBtnItem;
            [(UIViewController *)instance setTitle:item[kItemKeyTitle]];
            [self.navigationController pushViewController:(UIViewController *)instance
                                                 animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// =============================================================================
#pragma mark - Actions

- (void)viewCodeButtonTapped:(id)sender {

    NSString *urlStr = [NSString stringWithFormat:@"http://github.com/shu223/iOS7-Sampler/blob/master/iOS7Sampler/SampleViewControllers/%@.m",
                        self.currentClassName];
    NSLog(@"url:%@", urlStr);
    
    BrowseCodeViewController *codeCtr = [[BrowseCodeViewController alloc] init];

    [codeCtr setTitle:self.currentClassName];
    [codeCtr setUrlString:urlStr];

    [self.navigationController pushViewController:codeCtr
                                         animated:YES];
}

@end

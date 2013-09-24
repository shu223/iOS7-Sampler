//
//  MapSnapshotViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/24/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "MapSnapshotViewController.h"
#import <MapKit/MapKit.h>
#import "SVProgressHUD.h"


@interface MapSnapshotViewController ()
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end


@implementation MapSnapshotViewController

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
    
    // map setup
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(37.78275123, -122.40416442);
    self.mapView.camera.altitude = 200;
    self.mapView.camera.pitch = 70;
    self.mapView.showsBuildings = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)createSnapshot {

    [SVProgressHUD showWithStatus:@"Creating a screenshot..."
                         maskType:SVProgressHUDMaskTypeGradient];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.size = CGSizeMake(512, 512);
    options.scale = [[UIScreen mainScreen] scale];
    options.camera = self.mapView.camera;
    options.mapType = MKMapTypeStandard;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *e)
    {
        if (e) {
            NSLog(@"error:%@", e);
        }
        else {
            
            [SVProgressHUD showSuccessWithStatus:@"done!"];
            
            self.imageView.image = snapshot.image;
        }
    }];
}

@end

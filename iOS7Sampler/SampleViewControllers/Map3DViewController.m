//
//  Map3DViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/24/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "Map3DViewController.h"
#import <MapKit/MapKit.h>


@interface Map3DViewController ()
<MKMapViewDelegate>
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@end


@implementation Map3DViewController

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
    
    self.mapView.delegate = self;
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

@end

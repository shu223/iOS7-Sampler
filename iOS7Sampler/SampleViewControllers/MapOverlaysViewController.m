//
//  MapOverlaysViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/24/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "MapOverlaysViewController.h"
#import <MapKit/MapKit.h>


@interface MapOverlaysViewController ()
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@end


@implementation MapOverlaysViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

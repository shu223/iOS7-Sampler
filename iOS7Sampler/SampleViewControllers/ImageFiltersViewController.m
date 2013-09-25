//
//  ImageFiltersViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/25/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "ImageFiltersViewController.h"


@interface ImageFiltersViewController ()
<UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *orgImage;
@property (nonatomic, strong) NSArray *items;
@end


@implementation ImageFiltersViewController

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

    self.orgImage = [UIImage imageNamed:@"sample.jpg"];
    self.imageView.image = self.orgImage;
    
    self.items = @[@"Original",
//                   @"CIBlendWithAlphaMask",
//                   @"CIColorClamp",
//                   @"CIColorCrossPolynomial",
//                   @"CIColorCubeWithColorSpace",
//                   @"CIColorPolynomial",
//                   @"CIConvolution3X3",
//                   @"CIConvolution5X5",
//                   @"CIConvolution7X7",
//                   @"CIConvolution9Horizontal",
//                   @"CIConvolution9Vertical",
                   @"CILinearToSRGBToneCurve",
                   @"CIPhotoEffectChrome",
                   @"CIPhotoEffectFade",
                   @"CIPhotoEffectInstant",
                   @"CIPhotoEffectMono",
                   @"CIPhotoEffectNoir",
                   @"CIPhotoEffectProcess",
                   @"CIPhotoEffectTonal",
                   @"CIPhotoEffectTransfer",
                   @"CISRGBToneCurveToLinear",
                   @"CIVignetteEffect",
                   ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// =============================================================================
#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.items.count;
}


// =============================================================================
#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.items[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (row == 0) {

        self.imageView.image = self.orgImage;
        
        return;
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:self.orgImage];
    
    CIFilter *filter = [CIFilter filterWithName:self.items[row]
                                  keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];

    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    self.imageView.image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
}

@end

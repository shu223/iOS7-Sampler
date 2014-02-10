//
//  WebPaginationViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 2/10/14.
//  Copyright (c) 2014 Shuichi Tsutsumi. All rights reserved.
//

#import "WebPaginationViewController.h"
#import "SVProgressHUD.h"


#define kURL @"http://d.hatena.ne.jp/shu223/touch?smartphone_view=0"


@interface WebPaginationViewController ()
<UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end


@implementation WebPaginationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.pagingEnabled = YES;
    
    [SVProgressHUD showWithStatus:@"Loading..."
                         maskType:SVProgressHUDMaskTypeGradient];
    
    NSURL *url = [NSURL URLWithString:kURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// =============================================================================
#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    
    // Change pagination mode
    
    switch (sender.selectedSegmentIndex) {
        case 0:
        default:
            // default
            [self.webView setPaginationMode:UIWebPaginationModeUnpaginated];
            break;
        case 1:
            [self.webView setPaginationMode:UIWebPaginationModeTopToBottom];
            break;
        case 2:
            [self.webView setPaginationMode:UIWebPaginationModeBottomToTop];
            break;
        case 3:
            [self.webView setPaginationMode:UIWebPaginationModeLeftToRight];
            break;
        case 4:
            [self.webView setPaginationMode:UIWebPaginationModeRightToLeft];
            break;
    }
    
    NSLog(@"gapBetweenPages:%f", self.webView.gapBetweenPages);
    NSLog(@"pagaCount:%lu", (unsigned long)self.webView.pageCount);
    NSLog(@"pageLength:%f", self.webView.pageLength);
}

@end

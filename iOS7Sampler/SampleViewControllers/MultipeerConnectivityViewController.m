//
//  MultipeerConnectivityViewController.m
//  iOS7Sampler
//
//  Created by Andrew Frederick on 9/27/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "MultipeerConnectivityViewController.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

// Service name must be < 16 characters
static NSString * const kServiceName = @"multipeer";
static NSString * const kMessageKey = @"message";

@interface MultipeerConnectivityViewController () <MCBrowserViewControllerDelegate,
                                                   MCSessionDelegate>

// Required for both Browser and Advertiser roles
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;

// Browser using provided Apple UI
@property (nonatomic, strong) MCBrowserViewController *browserView;

// Advertiser assistant for declaring intent to receive invitations
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;

@property (weak, nonatomic) IBOutlet UIButton *launchBrowserButton;
@property (weak, nonatomic) IBOutlet UIButton *launchAdvertiserButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

- (IBAction)launchBrowserPressed:(id)sender;
- (IBAction)launchAdvertiser:(id)sender;
- (IBAction)sendMessageButtonPressed:(id)sender;

@end

@implementation MultipeerConnectivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _messageTextField.hidden = YES;
    _sendMessageButton.hidden = YES;
    _activityView.hidden = YES;
}

- (IBAction)launchBrowserPressed:(id)sender {
    _peerID = [[MCPeerID alloc] initWithDisplayName:@"Browser Name"];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    _browserView = [[MCBrowserViewController alloc] initWithServiceType:kServiceName
                                                                session:_session];
    _browserView.delegate = self;
    [self presentViewController:_browserView animated:YES completion:nil];
    
    _launchAdvertiserButton.hidden = YES;
    _launchBrowserButton.hidden = YES;
}

- (IBAction)launchAdvertiser:(id)sender {
    _peerID = [[MCPeerID alloc] initWithDisplayName:@"Advertiser Name"];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceName
                                                                discoveryInfo:nil
                                                                      session:_session];
    [_advertiserAssistant start];
    
    _launchAdvertiserButton.hidden = YES;
    _launchBrowserButton.hidden = YES;
    _activityView.hidden = NO;
}

- (IBAction)sendMessageButtonPressed:(id)sender {
    NSString *message = _messageTextField.text;
    NSDictionary *dataDict = @{ kMessageKey : message };
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dataDict
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:NULL];
    NSError *error;
    [self.session sendData:data
                   toPeers:[_session connectedPeers]
                  withMode:MCSessionSendDataReliable
                     error:&error];
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [_browserView.browser stopBrowsingForPeers];
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [_browserView.browser stopBrowsingForPeers];
        _launchAdvertiserButton.hidden = NO;
        _launchBrowserButton.hidden = NO;
    }];
}

#pragma mark - MCSessionDelegate

// MCSessionDelegate methods are called on a background queue, if you are going to update UI
// elements you must perform the actions on the main queue.

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected: {
            dispatch_async(dispatch_get_main_queue(), ^{
                _messageTextField.hidden = NO;
                _sendMessageButton.hidden = NO;
                _activityView.hidden = YES;
            });
            
            // This line only necessary for the advertiser. We want to stop advertising our services
            // to other browsers when we successfully connect to one.
            [_advertiserAssistant stop];
            break;
        }
        case MCSessionStateNotConnected: {
            dispatch_async(dispatch_get_main_queue(), ^{
                _launchAdvertiserButton.hidden = NO;
                _launchBrowserButton.hidden = NO;
                _messageTextField.hidden = YES;
                _sendMessageButton.hidden = YES;
            });
            break;
        }
        default:
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSPropertyListFormat format;
    NSDictionary *receivedData = [NSPropertyListSerialization propertyListWithData:data
                                                                           options:0
                                                                            format:&format
                                                                             error:NULL];
    NSString *message = receivedData[kMessageKey];
    if ([message length]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Received message"
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [messageAlert show];
        });
    }
}

// Required MCSessionDelegate protocol methods but are unused in this application.

- (void)                      session:(MCSession *)session
    didStartReceivingResourceWithName:(NSString *)resourceName
                             fromPeer:(MCPeerID *)peerID
                         withProgress:(NSProgress *)progress {
    
}

- (void)     session:(MCSession *)session
    didReceiveStream:(NSInputStream *)stream
            withName:(NSString *)streamName
            fromPeer:(MCPeerID *)peerID {
    
}

- (void)                       session:(MCSession *)session
    didFinishReceivingResourceWithName:(NSString *)resourceName
                              fromPeer:(MCPeerID *)peerID
                                 atURL:(NSURL *)localURL
                             withError:(NSError *)error {
    
}

@end

//
//  DJIViewController.m
//  DJIVideoPreviewer
//
//  Created by DJI on 03/28/2017.
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIViewController.h"
#import <DJIVideoPreviewer/VideoPreviewer.h>
#import "VideoPreviewerSDKAdapter.h"
#import <DJISDK/DJISDK.h>

@interface DJIViewController ()<DJISDKManagerDelegate>
@property (strong, nonatomic) IBOutlet UIView *fpvView;
@property(nonatomic) VideoPreviewerSDKAdapter *previewerAdapter;

@end

@implementation DJIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[VideoPreviewer instance] setView:self.fpvView];
    [DJISDKManager registerAppWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Call unSetView during exiting to release the memory.
    [[VideoPreviewer instance] unSetView];
    
    if (self.previewerAdapter) {
        [self.previewerAdapter stop];
        self.previewerAdapter = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Custom Methods
- (DJICamera*) fetchCamera {
    
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]){
        return ((DJIHandheld *)[DJISDKManager product]).camera;
    }
    
    return nil;
}


- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - DJISDKManagerDelegate Method
- (void)appRegisteredWithError:(NSError *)error
{
    NSString* message = @"Register App Successed!";
    if (error) {
        message = @"Register App Failed! Please enter your App Key and check the network.";
    }else
    {
        NSLog(@"registerAppSuccess");
        
        [DJISDKManager startConnectionToProduct];
//        [DJISDKManager enableBridgeModeWithBridgeAppIP: @"10.81.2.36"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[VideoPreviewer instance] start];
            self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithDefaultSettings];
            [self.previewerAdapter start];
        });
    }
    
    [self showAlertViewWithTitle:@"Register App" withMessage:message];
    
}

@end

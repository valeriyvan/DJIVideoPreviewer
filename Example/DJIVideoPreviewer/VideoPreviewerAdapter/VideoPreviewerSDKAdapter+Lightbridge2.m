//
//  VideoPreviewerSDKAdapter.m
//  VideoPreviewer
//
//  Copyright © 2017 DJI. All rights reserved.
//

#import "VideoPreviewerSDKAdapter+Lightbridge2.h"
#import <DJISDK/DJISDK.h>
#import <DJIVideoPreviewer/VideoPreviewer.h>

#define IS_FLOAT_EQUAL(a, b) (fabs(a - b) < 0.0005)
#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;

@implementation VideoPreviewerSDKAdapter (Lightbridge2)

- (DJIKeyedValue *)startListeningAndGetValueForChangesOnKey:(DJIKey *)key
                                              withListener:(id)listener
                                            andUpdateBlock:(DJIKeyedListenerUpdateBlock)updateBlock {
    [[DJISDKManager keyManager] startListeningForChangesOnKey:key withListener:listener andUpdateBlock:updateBlock];
    return [[DJISDKManager keyManager] getValueForKey:key];
}

-(void)startLightbridgeListen {
    DJIAirLinkKey *extEnabledKey = [DJIAirLinkKey keyWithIndex:0
                                                    subElement:DJIAirLinkLightbridgeLinkSubComponent
                                                      subIndex:0
                                                      andParam:DJILightbridgeLinkParamEXTVideoInputPortEnabled];
    WeakRef(target);
    DJIKeyedValue *extEnabled = [self startListeningAndGetValueForChangesOnKey:extEnabledKey
                                                                           withListener:self
                                                                         andUpdateBlock:
                                 ^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
                                     WeakReturn(target);
                                     target.isEXTPortEnabled = newValue.value;
                                     [target updateVideoFeed];
                                 }];
    self.isEXTPortEnabled = extEnabled.value;

    DJIAirLinkKey *LBPercentKey = [DJIAirLinkKey keyWithIndex:0
                                                   subElement:DJIAirLinkLightbridgeLinkSubComponent
                                                     subIndex:0
                                                     andParam:DJILightbridgeLinkParamBandwidthAllocationForLBVideoInputPort];
    DJIKeyedValue *LBPercent = [self startListeningAndGetValueForChangesOnKey:LBPercentKey
                                                                          withListener:self
                                                                        andUpdateBlock:
                                ^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
                                    WeakReturn(target);
                                    target.LBEXTPercent = newValue.value;
                                    [target updateVideoFeed];
                                }];
    self.LBEXTPercent = LBPercent.value;

    DJIAirLinkKey *HDMIPercentKey = [DJIAirLinkKey keyWithIndex:0
                                                     subElement:DJIAirLinkLightbridgeLinkSubComponent
                                                       subIndex:0
                                                       andParam:DJILightbridgeLinkParamBandwidthAllocationForHDMIVideoInputPort];
    DJIKeyedValue *HDMIPercent = [self startListeningAndGetValueForChangesOnKey:HDMIPercentKey
                                                                            withListener:self
                                                                          andUpdateBlock:
                                  ^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
                                      WeakReturn(target);
                                      target.HDMIAVPercent = newValue.value;
                                      [target updateVideoFeed];
                                  }];
    self.HDMIAVPercent = HDMIPercent.value;

    [self updateVideoFeed];
}

-(void)stopLightbridgeListen {
    [[DJISDKManager keyManager] stopAllListeningOfListeners:self];
}

-(void)updateVideoFeed {
    if (self.isEXTPortEnabled == nil) {
        [self swapToPrimaryVideoFeedIfNecessary];
        return;
    }

    if ([self.isEXTPortEnabled boolValue]) {
        if (self.LBEXTPercent == nil) {
            [self swapToPrimaryVideoFeedIfNecessary];
            return;
        }

        if (IS_FLOAT_EQUAL(self.LBEXTPercent.floatValue, 1.0)) {
            // All in primary source
            if (![self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
        else if (IS_FLOAT_EQUAL(self.LBEXTPercent.floatValue, 0.0)) {
            if ([self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
    }
    else {
        if (self.HDMIAVPercent == nil)  {
            [self swapToPrimaryVideoFeedIfNecessary];
            return;
        }
        
        if (IS_FLOAT_EQUAL(self.HDMIAVPercent.floatValue, 1.0)) {
            // All in primary source
            if (![self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
        else if (IS_FLOAT_EQUAL(self.HDMIAVPercent.floatValue, 0.0)) {
            if ([self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
    }
}

-(BOOL)isUsingPrimaryVideoFeed {
    return (self.videoFeed == [DJISDKManager videoFeeder].primaryVideoFeed);
}

-(void)swapVideoFeed {
    [self.videoPreviewer pause];
    [self.videoFeed removeListener:self];
    if ([self isUsingPrimaryVideoFeed]) {
        self.videoFeed = [DJISDKManager videoFeeder].secondaryVideoFeed;
    }
    else {
        self.videoFeed = [DJISDKManager videoFeeder].primaryVideoFeed;
    }
    [self.videoFeed addListener:self withQueue:nil];
    [self.videoPreviewer safeResume];
}

-(void)swapToPrimaryVideoFeedIfNecessary {
    if (![self isUsingPrimaryVideoFeed]) {
        [self swapVideoFeed];
    }
}

@end

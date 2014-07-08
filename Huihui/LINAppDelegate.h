//
//  LINAppDelegate.h
//  Huihui
//
//  Created by Lin on 3/24/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNetworkKit.h"
#import "Addrmacro.h"
#import "GexinSdk.h"

typedef enum {
    SdkStatusStoped,
    SdkStatusStarting,
    SdkStatusStarted
} SdkStatus;

@interface LINAppDelegate : UIResponder <UIApplicationDelegate, GexinSdkDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) GexinSdk *gexinPusher;
@property (assign, nonatomic) SdkStatus sdkStatus;

@end

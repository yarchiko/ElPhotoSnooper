//
//  AppDelegate.m
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import "AppDelegate.h"
#import "EPSConstants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self createDefaultSettings];
    
    return YES;
}

- (void)createDefaultSettings {
    NSDictionary* defaults = @{INSTAGRAM_USER_ACCESS_TOKEN:@""};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

@end

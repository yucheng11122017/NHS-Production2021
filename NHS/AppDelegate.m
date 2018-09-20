//
//  AppDelegate.m
//  NHS
//
//  Created by Nicholas on 7/23/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "AppDelegate.h"
#import "ELCUIApplication.h"
#import "AppConstants.h"
#import "SVProgressHUD.h"

#define serverReachabilityCheckIntervalSecs 2.0


@interface AppDelegate ()

@end

@implementation AppDelegate


//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//
//
//
//    return YES;
//}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // To silent all the layout constraints warnings at console
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    // Override point for customization after application launch.
    
    // Auto-timeout feature: set listener to Idle Timer
    NSLog(@"adding observer to observe for kApplicationDidTimeoutNotification");
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidTimeout:)
     name:kApplicationDidTimeoutNotification
     object:nil];
    ((ELCUIApplication *)[UIApplication sharedApplication]).didIdleTimerTimeout = NO; // initial value
    
    // Initiate timer to check server reachability
//    self.serverReachabilityTimer =
//    [NSTimer timerWithTimeInterval:serverReachabilityCheckIntervalSecs
//                            target:self
//                          selector:@selector(checkReachabilityInBackground)
//                          userInfo:nil
//                           repeats:YES];
//
//    [[NSRunLoop mainRunLoop] addTimer:self.serverReachabilityTimer
//                              forMode:NSRunLoopCommonModes];
    
    // disable swipe back gesture to pop view controller stack
    UINavigationController *rootVC =  (UINavigationController *)self.window.rootViewController;
    [rootVC.interactivePopGestureRecognizer setEnabled:NO];
    
    // set up progress HUD
    [SVProgressHUD setMinimumDismissTimeInterval:0.2];
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeBlack)];
    
    return YES;
}

- (void)applicationDidTimeout:(NSNotification *)notification {
    NSLog(@"received kApplicationDidTimeoutNotification notification");
    
    // log out
    UINavigationController *navController =
    (UINavigationController *)self.window.rootViewController;
    [navController popToRootViewControllerAnimated:YES];
}




#pragma mark - UIStateRestoration

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//
//  AppDelegate.h
//  NHS
//
//  Created by Nicholas on 7/23/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property(nonatomic, strong) ServerReachability *serverReachabilityModule;
@property(nonatomic, strong) NSTimer *serverReachabilityTimer;



@end


//
//  ELCUIApplication.m
//
//  Created by Brandon Trebitowski on 9/19/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
// inspired by
// http://www.hkwebentrepreneurs.com/2013/11/ios-prevent-back-button-navigating-to.html

#import "ELCUIApplication.h"
#import "Reachability.h"

@interface ELCUIApplication ()

@property(strong, nonatomic) NSTimer *idleTimer;
@property(strong, nonatomic) NSTimer *networkReachabilityCheckTimer;

@end

@implementation ELCUIApplication

/* sendEvent is overridden to catch all touch events.
 Touch events invalidate the idle timer if it is active.*/
- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];

    if (![self.idleTimer isValid])
        return;

    // Check to see if there was a touch event
    NSSet *allTouches = [event allTouches];

    if ([allTouches count] > 0) {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan) {
            [self resetIdleTimer];
        }
    }
}

- (void)resetIdleTimer {

    [self stopIdleTimer]; // stop it if it already exists

    // Schedule a timer to fire in (kApplicationTimeoutInMinutes * 60) seconds
    int timeout = kApplicationTimeoutInMinutes * 60;
    self.idleTimer =
        [NSTimer scheduledTimerWithTimeInterval:timeout
                                         target:self
                                       selector:@selector(idleTimerExceeded)
                                       userInfo:nil
                                        repeats:NO];
}

// stop it if it already exists
- (void)stopIdleTimer {
    if (self.idleTimer) {
        [self.idleTimer invalidate];
    }
    self.didIdleTimerTimeout = NO;
}

- (void)resetNetworkReachabilityTimer {
    if (self.networkReachabilityCheckTimer)
        [self.networkReachabilityCheckTimer invalidate];
}

- (void)networkReachabilityTimerExceeded {
    //    NSLog(@"checking network reachability...");
    //    [[NSNotificationCenter defaultCenter] postNotificationName:
    //    kReachabilityChangedNotification
    //                                                        object: nil];
}

- (void)idleTimerExceeded {
    /* Post a notification so anyone who subscribes to it can be notified when
     * the application times out */
    NSLog(@"time out!! Please log in again.");
    self.didIdleTimerTimeout = YES;
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kApplicationDidTimeoutNotification
                      object:nil];
}

@end

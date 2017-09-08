//
//  ScreeningDictionary.h
//  NHS
//
//  Created by Nicholas Wong on 9/6/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreeningDictionary : NSObject

+ (ScreeningDictionary *)sharedInstance;

@property (strong, nonatomic) NSDictionary *dictionary;

- (void) fetchFromServer;
- (void) updateDictionary;
- (void) setDictionary:(NSDictionary *)dictionary;
- (void) prepareAdditionalSvcs;

@end

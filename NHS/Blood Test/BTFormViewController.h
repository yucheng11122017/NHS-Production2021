//
//  BTFormViewController.h
//  NHS
//
//  Created by Nicholas Wong on 9/13/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"

@interface BTFormViewController : XLFormViewController

@property (strong, nonatomic) NSString *residentNRIC;
@property (strong, nonatomic) NSNumber *residentID;

- (void) setResidentNRIC:(NSString *)residentNRIC;
- (void) setResidentID:(NSNumber *)residentID;


@end

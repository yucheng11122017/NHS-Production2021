//
//  FollowUpFormViewController.h
//  NHS
//
//  Created by Nicholas Wong on 9/18/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"

@interface FollowUpFormViewController : XLFormViewController

@property (strong, nonatomic) NSString *residentNRIC;
@property (strong, nonatomic) NSNumber *residentID;
@property (strong, nonatomic) NSNumber *typeOfFollowUp;
@property (strong, nonatomic) NSDictionary *residentParticulars;


- (void) setResidentNRIC:(NSString *)residentNRIC;
- (void) setResidentID:(NSNumber *)residentID;
- (void) setTypeOfFollowUp:(NSNumber *)typeOfFollowUp;
- (void) setResidentParticulars:(NSDictionary *)dictionary;

@end

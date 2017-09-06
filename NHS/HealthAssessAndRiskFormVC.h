//
//  HealthAssessAndRiskFormVC.h
//  NHS
//
//  Created by Nicholas Wong on 8/8/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface HealthAssessAndRiskFormVC : XLFormViewController

@property (strong, nonatomic) NSNumber* formID;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
// Public Methods
- (void) setFormID:(NSNumber *)formID;

@end

//
//  ProfilingFormVC.h
//  NHS
//
//  Created by Nicholas Wong on 9/27/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface ProfilingFormVC : XLFormViewController

@property (strong, nonatomic) NSNumber* formID;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
// Public Methods
- (void) setFormID:(NSNumber *)formID;

@end

//
//  AdvancedGeriatricsFormVC.h
//  NHS
//
//  Created by Nicholas Wong on 9/7/18.
//  Copyright © 2018 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface AdvancedGeriatricsFormVC : XLFormViewController <XLFormViewControllerDelegate>

@property (strong, nonatomic) NSNumber* formNo;
// Public Methods
- (void) setFormNo:(NSNumber *)formNo;


@end

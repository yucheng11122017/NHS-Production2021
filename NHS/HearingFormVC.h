//
//  HearingFormVC.h
//  NHS
//
//  Created by rehabpal on 6/9/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface HearingFormVC : XLFormViewController <XLFormViewControllerDelegate>

@property (strong, nonatomic) NSNumber* formNo;
// Public Methods
- (void) setFormNo:(NSNumber *)formNo;


@end

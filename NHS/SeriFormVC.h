//
//  SeriFormVC.h
//  NHS
//
//  Created by Nicholas Wong on 8/21/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface SeriFormVC : XLFormViewController <XLFormViewControllerDelegate>

@property (strong, nonatomic) NSNumber* formNo;

// Public Methods
- (void) setFormNo:(NSNumber *)formNo;


@end

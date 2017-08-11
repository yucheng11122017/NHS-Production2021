//
//  ResidentParticularsVC.h
//  NHS
//
//  Created by Nicholas Wong on 8/4/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface ResidentParticularsVC : XLFormViewController

@property (strong, nonatomic) NSDictionary* residentParticularsDict;

// Public Methods
- (void) setResidentParticularsDict:(NSDictionary *)residentParticularsDict;

@end

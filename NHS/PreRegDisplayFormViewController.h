//
//  PreRegDisplayFormViewController.h
//  NHS
//
//  Created by Mac Pro on 8/7/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"

@interface PreRegDisplayFormViewController : XLFormViewController

@property (strong, nonatomic) NSNumber* patientID;

- (void) setPatientID:(NSNumber *)patientID;

@end


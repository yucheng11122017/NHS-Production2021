//
//  PreRegPatientDetailsViewController.h
//  NHS
//
//  Created by Nicholas on 7/25/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreRegPatientDetailsViewController : UIViewController


@property (strong, nonatomic) NSNumber* patientID;

- (void) setPatientID:(NSNumber *)patientID;

@end

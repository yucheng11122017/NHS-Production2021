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

@property (strong, nonatomic) NSNumber *typeOfFollowUp;
@property (strong, nonatomic) NSDictionary *residentParticulars;
@property (strong, nonatomic) NSDictionary *downloadedForm;
@property (strong, nonatomic) NSNumber *viewForm;

- (void) setTypeOfFollowUp:(NSNumber *)typeOfFollowUp;
- (void) setResidentParticulars:(NSDictionary *)dictionary;
- (void) setViewForm: (NSNumber *) viewForm;
- (void) setDownloadedForm: (NSDictionary *) dictionary;

@end

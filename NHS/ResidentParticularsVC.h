//
//  ResidentParticularsVC.h
//  NHS
//
//  Created by Nicholas Wong on 8/4/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface ResidentParticularsVC : XLFormViewController <XLFormViewControllerDelegate>

@property (strong, nonatomic) NSDictionary* residentParticularsDict;
@property (strong, nonatomic) NSNumber * loadDataFlag;

// Public Methods
- (void) setResidentParticularsDict:(NSDictionary *)residentParticularsDict;
- (void) setLoadDataFlag:(NSNumber*) loadDataFlag;


typedef enum patientDataSource {
    server,
    local
} patientDataSource;


@end

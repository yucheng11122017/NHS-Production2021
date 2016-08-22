//
//  PreRegFormViewController.h
//  NHS
//
//  Created by Nicholas on 7/30/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"

@interface PreRegFormViewController : XLFormViewController

@property (strong, nonatomic) NSNumber* patientDataLocalOrServer;
@property (strong, nonatomic) NSNumber* patientLocalFileIndex;
@property (strong, nonatomic) NSNumber * loadDataFlag;

- (void) setPatientLocalFileIndex:(NSNumber *) patientLocalFileIndex;
- (void) setAsPatientDataLocal:(NSNumber *) patientDataLocalOrServer;
- (void) setLoadDataFlag:(NSNumber*) loadDataFlag;

typedef enum patientDataSource {
    server,
    local
} patientDataSource;


@end

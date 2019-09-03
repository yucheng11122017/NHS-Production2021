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
@property (strong, nonatomic) NSDictionary* phlebEligibDict;
@property (strong, nonatomic) NSDictionary* modeOfScreeningDict;
@property (strong, nonatomic) NSDictionary* consentDisclosureDict;
@property (strong, nonatomic) NSDictionary* consentResearchDict;
@property (strong, nonatomic) NSDictionary* mammogramInterestDict;
@property (strong, nonatomic) NSArray* signImagesArray;
@property (strong, nonatomic) NSNumber * loadDataFlag;

// Public Methods
- (void) setResidentParticularsDict:(NSDictionary *)residentParticularsDict;
//- (void) setphlebEligibDict:(NSDictionary *)phlebEligibDict;
- (void) setModeOfScreeningDict:(NSDictionary *)modeOfScreeningDict;
- (void) setConsentDisclosureDict:(NSDictionary *)consentDisclosureDict;
- (void) setConsentResearchDict:(NSDictionary *)consentResearchDict;
- (void) setMammogramInterestDict:(NSDictionary *)mammogramInterestDict;
- (void) setSignImagesArray:(NSArray *)signImagesArray;
- (void) setLoadDataFlag:(NSNumber*) loadDataFlag;


typedef enum patientDataSource {
    server,
    local
} patientDataSource;


@end

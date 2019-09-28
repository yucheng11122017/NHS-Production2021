//
//  ResidentProfile.h
//  NHS
//
//  Created by Nicholas Wong on 9/6/18.
//  Copyright © 2018 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResidentProfile : NSObject


@property (strong, nonatomic) NSDictionary *fullDict;
@property BOOL profilingDone;
@property BOOL consentImgExists;
@property BOOL researchConsentImgExists;

+(id) sharedManager;
- (void) updateProfile: (NSDictionary *) fullDict;

- (BOOL) isEligiblePhleb;
- (BOOL) isEligibleFallRisk;
- (BOOL) isEligibleFallRiskAssessment;
- (BOOL) isEligibleGeriatricDementiaAssmt;
- (BOOL) isEligibleHearing;
- (BOOL) isEligibleSmf;
- (BOOL) isEligibleAdvancedVision;
- (BOOL) isEligibleCHAS;
- (BOOL) isEligibleReceiveFIT;
- (BOOL) isEligibleReferMammo;
- (BOOL) isEligibleReferPapSmear;
- (BOOL) isEligibleSocialWork;
- (BOOL) isEligiblePHQ9;
- (BOOL) diabetesCheck;
- (BOOL) hyperlipidemiaCheck;
- (BOOL) hypertensionCheck;
- (BOOL) cardiovascularDiseaseCheck;
- (BOOL) dentalCheck;
- (BOOL) alcoholCheck;
- (BOOL) smokingCheck;
- (BOOL) hasIncome;
- (BOOL) canReceiveSpecVoucher;
- (BOOL) isFemale;
- (BOOL) hasConsentImage;
- (BOOL) consentForResearch;
- (BOOL) hasResearchConsentImage;
- (NSString *) getFallRiskStatus;
- (BOOL) hasValidCHAS;

@end

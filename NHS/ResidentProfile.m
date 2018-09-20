//
//  ResidentProfile.m
//  NHS
//
//  Created by Nicholas Wong on 9/6/18.
//  Copyright © 2018 NUS. All rights reserved.
//

#import "ResidentProfile.h"
#import "AppConstants.h"

@interface ResidentProfile ()

@end

@implementation ResidentProfile

#pragma mark Singleton and Init stuff
+(id)sharedManager {
    static ResidentProfile *profile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        profile = [[self alloc] init];
    });
    
    return profile;
}

-(id)init {
    if (self = [super init]) {
        _profilingDone = false;
    }
    
    return self;
}

- (void) updateProfile: (NSDictionary *) responseObject {
    _fullDict = responseObject;
}

- (BOOL) isEligibleFallRisk {
    NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                  stringForKey:kResidentAge];
    
    if ([age integerValue] >= 60) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isEligiblePhleb {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *phlebEligibDict = [_fullDict objectForKey:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT];
            NSNumber *wantFreeBT = [phlebEligibDict objectForKey:kWantFreeBt];
            NSNumber *chronicCond = [phlebEligibDict objectForKey:kChronicCond];
            NSNumber *regFollowUp = [phlebEligibDict objectForKey:kRegFollowup];
            NSNumber *noBloodTest = [phlebEligibDict objectForKey:kNoBloodTest];
            
            NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                          stringForKey:kResidentAge];
            NSString *citizenship = [[NSUserDefaults standardUserDefaults]
                                     stringForKey:kCitizenship];
            
            if (wantFreeBT == (id)[NSNull null] || chronicCond == (id)[NSNull null] || noBloodTest == (id)[NSNull null]) return NO;
            
            if ([wantFreeBT boolValue] &&
                [age intValue] >= 40 &&
                ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) &&
                ![chronicCond boolValue]) {
                return YES;
            }
            
            if ([phlebEligibDict objectForKey:kRegFollowup] == [NSNull null])   //only the above condition NOT require checkig followUp field. Otherwise, this field must be filled in order to be eligible
                return NULL;
            
            if ([wantFreeBT boolValue] &&
                       [age intValue] >= 40 &&
                       ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) &&
                       [chronicCond boolValue] &&
                       ![regFollowUp boolValue]) {
                return YES;
            }
        }
       
    }
    return NO;
}

- (BOOL) isEligibleAdvFallRisk {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_FALL_RISK_ELIGIBLE] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *fallRiskDict = [_fullDict objectForKey:SECTION_FALL_RISK_ELIGIBLE];
            NSString *fallRiskStatus = [fallRiskDict objectForKey:kFallRiskStatus];
            if (fallRiskStatus != (id)[NSNull null] && [fallRiskStatus isEqualToString:@"High Risk"]) return YES;
        }
        if ([_fullDict objectForKey:SECTION_GERIATRIC_DEMENTIA_ELIGIBLE] != (id)[NSNull null]) {
            NSDictionary *dementiaEligibleDict = _fullDict[SECTION_GERIATRIC_DEMENTIA_ELIGIBLE];
            NSNumber *cognitiveImpair = dementiaEligibleDict[kCognitiveImpair];
            NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                               stringForKey:kResidentAge];
            
            if (cognitiveImpair == (id)[NSNull null]) return NO;
            if ([cognitiveImpair integerValue] != 0 && [age integerValue] >= 60) {  // 2 conditions must be met
                return YES;
            }
        }
    }
    
    
    return NO;
}

- (BOOL) isEligibleGeriatricDementiaAssmt {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_FALL_RISK_ELIGIBLE] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *fallRiskDict = [_fullDict objectForKey:SECTION_FALL_RISK_ELIGIBLE];
            NSString *fallRiskStatus = [fallRiskDict objectForKey:kFallRiskStatus];
            if (fallRiskStatus != (id)[NSNull null] && [fallRiskStatus isEqualToString:@"High Risk"]) return YES;
        }
        if ([_fullDict objectForKey:SECTION_GERIATRIC_DEMENTIA_ELIGIBLE] != (id)[NSNull null]) {
            NSDictionary *dementiaEligibleDict = _fullDict[SECTION_GERIATRIC_DEMENTIA_ELIGIBLE];
            NSNumber *cognitiveImpair = dementiaEligibleDict[kCognitiveImpair];
            NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                          stringForKey:kResidentAge];
            
            if (cognitiveImpair == (id)[NSNull null]) return NO;
            if ([cognitiveImpair boolValue] != 0 && [age integerValue] >= 60) {  // 2 conditions must be met
                return YES;
            }
        }
    }
    
    
    return NO;
}

- (BOOL) isEligibleHearing {
    NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                  stringForKey:kResidentAge];
    
    if ([age integerValue] >= 60) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isEligibleSmf {
    NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                  stringForKey:kResidentAge];
    
    if ([age integerValue] >= 60) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isEligibleAdvancedVision {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_SNELLEN_TEST] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *snellenTestDict = [_fullDict objectForKey:SECTION_SNELLEN_TEST];
            NSNumber *six12 = [snellenTestDict objectForKey:kSix12];
            NSNumber *tunnel = [snellenTestDict objectForKey:kTunnel];
            NSNumber *visitEye12mths = [snellenTestDict objectForKey:kVisitEye12Mths];
            
            if (six12 == (id)[NSNull null] || tunnel == (id)[NSNull null] || visitEye12mths == (id)[NSNull null]) return NO;
            if (([six12 boolValue] || [tunnel boolValue]) && ![visitEye12mths boolValue])
                return YES;
        }
    }
    
    
    return NO;
}

- (BOOL) isEligibleCHAS {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_CHAS_PRELIM] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *chasPrelimDict = [_fullDict objectForKey:SECTION_CHAS_PRELIM];
            NSString *haveChasCard = [chasPrelimDict objectForKey:kDoesNotOwnChasPioneer];
            NSNumber *expiringSoon = [chasPrelimDict objectForKey:kExpiringSoon];
            NSNumber *wantChas = [chasPrelimDict objectForKey:kWantChas];
            
            if (haveChasCard == (id)[NSNull null] || wantChas == (id)[NSNull null]) return NO;
            
            BOOL req1 = false;
            BOOL req2 = false;
            
            if ([haveChasCard containsString:@"None"]) req1 = true;
            else {  //already have CHAS card
                if (expiringSoon == (id)[NSNull null]) return NO;
                if ([expiringSoon boolValue]) req1 = true;
                else req1 = false;
            }
            if ([wantChas boolValue]) req2 = true;
            else req2 = false;
            
            if (req1 && req2) return YES;
        }
    }
    return NO;
}

- (BOOL) isEligibleReceiveFIT {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_FIT_ELIGIBLE] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *eligibleFITDict = [_fullDict objectForKey:SECTION_FIT_ELIGIBLE];
            NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                          stringForKey:kResidentAge];
            NSString *citizenship = [[NSUserDefaults standardUserDefaults]
                                     stringForKey:kCitizenship];
            
            NSNumber *fitLast12Mths = [eligibleFITDict objectForKey:kFitLast12Mths];
            NSNumber *colonscopy10Yrs = [eligibleFITDict objectForKey:kColonoscopy10Yrs];
            NSNumber *wantFITKit = [eligibleFITDict objectForKey:kWantFitKit];
            
            if (fitLast12Mths == (id)[NSNull null] || colonscopy10Yrs == (id)[NSNull null] || wantFITKit == (id)[NSNull null]) return NO;
            // NO NO YES
            if (([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) &&
                ![fitLast12Mths boolValue] && ![colonscopy10Yrs boolValue] && [wantFITKit boolValue] && [age integerValue] >= 50)
                return YES;
        }
    }
    
    
    return NO;
}

- (BOOL) isEligibleReferMammo {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_MAMMOGRAM_ELIGIBLE] != (id)[NSNull null]) { //if the section has at least one entry...
            if ([_fullDict objectForKey:SECTION_CHAS_PRELIM] != (id)[NSNull null]) {
                NSDictionary *mammogramEligible = [_fullDict objectForKey:SECTION_MAMMOGRAM_ELIGIBLE];
                NSDictionary *chasPrelimDict =[_fullDict objectForKey:SECTION_CHAS_PRELIM];
                NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                              stringForKey:kResidentAge];
                NSString *citizenship = [[NSUserDefaults standardUserDefaults]
                                         stringForKey:kCitizenship];
                
                
                NSNumber *mammo2Years = [mammogramEligible objectForKey:kMammo2Yrs];
                NSString *hasChas = [chasPrelimDict objectForKey:kDoesNotOwnChasPioneer];
                NSNumber *wantMammo = [mammogramEligible objectForKey:kWantMammo];
                
                if (mammo2Years == (id)[NSNull null] || hasChas == (id)[NSNull null] || wantMammo == (id)[NSNull null]) return NO;
                // NO NO YES
                if ([citizenship isEqualToString:@"Singaporean"] &&                 //Singaporean
                    [age integerValue] >= 50 && [age integerValue] < 70 &&          //age 50-69
                    ![mammo2Years boolValue] &&                                   // didn't do Mammogram in 2 years
                    ![hasChas containsString:@"None"] &&                            // owns a CHAS card
                    [wantMammo boolValue])                                        // want mammogram
                    return YES;
            }
        }
    }
    return NO;
}

- (BOOL) isEligibleReferPapSmear {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_PAP_SMEAR_ELIGIBLE] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *papSmearEligibDict = [_fullDict objectForKey:SECTION_PAP_SMEAR_ELIGIBLE];
    
            NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                          stringForKey:kResidentAge];
            NSString *citizenship = [[NSUserDefaults standardUserDefaults]
                                     stringForKey:kCitizenship];
            
            
            NSNumber *pap3Years = [papSmearEligibDict objectForKey:kPap3Yrs];
            NSNumber *engagedSex = [papSmearEligibDict objectForKey:kEngagedSex];
            NSNumber *wantPap = [papSmearEligibDict objectForKey:kWantPap];
            
            if (pap3Years == (id)[NSNull null] || engagedSex == (id)[NSNull null] || wantPap == (id)[NSNull null]) return NO;
            // NO NO YES
            if (([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) &&                 //Singaporean/PR
                [age integerValue] >= 25 && [age integerValue] < 70 &&          //age 25-69
                ![pap3Years boolValue] &&                                     // didn't do Pap Smear in 3 years
                [engagedSex boolValue] &&                                     // engaged sex before
                [wantPap boolValue])                                          // want pap smear
                return YES;
        }
    }
    return NO;
}

- (BOOL) isEligibleSocialWork {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_FIN_ASSMT] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *finAssmtDict = [_fullDict objectForKey:SECTION_FIN_ASSMT];
            
            NSNumber *copeFin = [finAssmtDict objectForKey:kCopeFin];
            NSNumber *receiveFinAssit = [finAssmtDict objectForKey:kReceiveFinAssist];
            NSNumber *seekFinAssist = [finAssmtDict objectForKey:kSeekFinAssist];
            
            if (copeFin == (id)[NSNull null] || receiveFinAssit == (id)[NSNull null] || seekFinAssist == (id)[NSNull null]) return NO;
            // NO NO YES
            if(![copeFin boolValue] &&
                ![receiveFinAssit boolValue] &&
                ![seekFinAssist boolValue])
                return YES;
        }
        if ([_fullDict objectForKey:SECTION_SOCIAL_ASSMT] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *socAssmtDict = [_fullDict objectForKey:SECTION_SOCIAL_ASSMT];
            NSNumber *socialAssmtScore = [socAssmtDict objectForKey:kSocialAssmtScore];
            
            if (socialAssmtScore != (id)[NSNull null] && [socialAssmtScore integerValue] <= 16) return YES;
        }
        
        if ([_fullDict objectForKey:SECTION_DEPRESSION] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *depressionDict = [_fullDict objectForKey:SECTION_DEPRESSION];
            NSNumber *phq2Score = [depressionDict objectForKey:kPhqQ2Score];
            if (phq2Score != (id)[NSNull null] && [phq2Score integerValue] > 3) return YES;
        }
        
        if ([_fullDict objectForKey:SECTION_SUICIDE_RISK] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *suicideRiskDict = [_fullDict objectForKey:SECTION_SUICIDE_RISK];
            NSNumber *possibleSuicide = [suicideRiskDict objectForKey:kPossibleSuicide];
            if (possibleSuicide != (id)[NSNull null] && [possibleSuicide boolValue]) return YES;
        }
    }
    return NO;
}

- (BOOL) isEligiblePHQ9 {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {

        if ([_fullDict objectForKey:SECTION_DEPRESSION] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *depressionDict = [_fullDict objectForKey:SECTION_DEPRESSION];
            NSNumber *phq2Score = [depressionDict objectForKey:kPhqQ2Score];
            if (phq2Score != (id)[NSNull null] && [phq2Score integerValue] > 3) return YES;
        }
        
    }
    return NO;
}

- (BOOL) diabetesCheck {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {

        if ([_fullDict objectForKey:SECTION_DIABETES] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *diabetesDict = [_fullDict objectForKey:SECTION_DIABETES];
            NSNumber *hasInformed = [diabetesDict objectForKey:kHasInformed];
            
            if (hasInformed != (id)[NSNull null] && [hasInformed boolValue]) return YES;
        }
        
        if ([_fullDict objectForKey:SECTION_CLINICAL_RESULTS] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *clinicalResultsDict = [_fullDict objectForKey:SECTION_CLINICAL_RESULTS];
            NSNumber *isDiabetic = [clinicalResultsDict objectForKey:kIsDiabetic];
            if (isDiabetic != (id)[NSNull null] && [isDiabetic boolValue]) return YES;
        }
        
        if ([_fullDict objectForKey:SECTION_RISK_STRATIFICATION] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *riskStratDict = [_fullDict objectForKey:SECTION_RISK_STRATIFICATION];
            NSNumber *diabeticFriend = [riskStratDict objectForKey:kDiabeticFriend];
            NSNumber *delivered4kg = [riskStratDict objectForKey:kDelivered4kgOrGestational];
            
            if (diabeticFriend != (id)[NSNull null] && [diabeticFriend boolValue]) return YES;      //either condition is fine
            else if (delivered4kg != (id)[NSNull null] && [delivered4kg boolValue]) return YES;
        }
    }
    return NO;
}

- (BOOL) hyperlipidemiaCheck {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        
        if ([_fullDict objectForKey:SECTION_HYPERLIPIDEMIA] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *hyperlipidDict = [_fullDict objectForKey:SECTION_HYPERLIPIDEMIA];
            NSNumber *hasInformed = [hyperlipidDict objectForKey:kHasInformed];
            if (hasInformed != (id)[NSNull null] && [hasInformed boolValue]) return YES;
        }
        
    }
    return NO;
}

- (BOOL) hypertensionCheck {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        
        if ([_fullDict objectForKey:SECTION_HYPERTENSION] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *hypertensionDict = [_fullDict objectForKey:SECTION_HYPERTENSION];
            NSNumber *hasInformed = [hypertensionDict objectForKey:kHasInformed];
            if (hasInformed != (id)[NSNull null] && [hasInformed boolValue]) return YES;
        }
        
        if ([_fullDict objectForKey:SECTION_CLINICAL_RESULTS] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *hypertensionDict = [_fullDict objectForKey:SECTION_CLINICAL_RESULTS];
            NSNumber *bp1Sys = [hypertensionDict objectForKey:kBp1Sys];
            NSNumber *bp2Sys = [hypertensionDict objectForKey:kBp2Sys];
            if (bp1Sys == (id)[NSNull null] || bp2Sys == (id)[NSNull null]) return NO;
            else {
                double avg = ([bp1Sys integerValue]+[bp2Sys integerValue])/2.0;
                if (avg >= 130) return YES;
            }
        }
        
    }
    return NO;
}

- (BOOL) cardiovascularDiseaseCheck {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_RISK_STRATIFICATION] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *riskStratDict = [_fullDict objectForKey:SECTION_RISK_STRATIFICATION];
            
            NSNumber *heartAttack = [riskStratDict objectForKey:kHeartAttack];
            NSNumber *stroke = [riskStratDict objectForKey:kStroke];
            NSNumber *aneurysm = [riskStratDict objectForKey:kAneurysm];
            
            if (heartAttack == (id)[NSNull null] || stroke == (id)[NSNull null] || aneurysm == (id)[NSNull null]) return NO;
            // NO NO YES
            if ([heartAttack boolValue] ||
                [stroke boolValue] ||
                [aneurysm boolValue])
                return YES;
        }
    }
    return NO;
}

- (BOOL) dentalCheck {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_BASIC_DENTAL] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *dentalDict = [_fullDict objectForKey:SECTION_BASIC_DENTAL];
            
            NSNumber *undergoneDental = [dentalDict objectForKey:kDentalUndergone];
            NSString *referredByDentist = [dentalDict objectForKey:kDentistReferred];
            
            if (undergoneDental != (id)[NSNull null] && [undergoneDental boolValue] ) return YES;
        
            if (referredByDentist != (id)[NSNull null]) {
                if (![referredByDentist containsString:@"NIL"]) return YES;     //cannot have "NIL" in the referral
            }

        }
    }
    return NO;
}

- (BOOL) alcoholCheck {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_DIET] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *dietDict = [_fullDict objectForKey:SECTION_DIET];
            
            NSString *alcohol = [dietDict objectForKey:kAlcohol];
            
            if (alcohol != (id)[NSNull null] && [alcohol isEqualToString:@"More than 2 standard drinks per day on average"] ) return YES;
        }
    }
    return NO;
}

- (BOOL) smokingCheck {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_RISK_STRATIFICATION] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *riskStratDict = [_fullDict objectForKey:SECTION_RISK_STRATIFICATION];
            
            NSString *smoke = [riskStratDict objectForKey:kSmoke];
            
            if (smoke != (id)[NSNull null] && [smoke boolValue] ) return YES;
        }
    }
    return NO;
}

- (BOOL) hasIncome {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_PROFILING_SOCIOECON] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *financeDict = [_fullDict objectForKey:SECTION_PROFILING_SOCIOECON];
            
            NSNumber *avgMthHouseIncome = [financeDict objectForKey:kAvgMthHouseIncome];
            
            if (avgMthHouseIncome != (id)[NSNull null] && [avgMthHouseIncome integerValue] > 0 ) return YES;
            else return NO;
        }
    }
    return NO;
}

- (BOOL) canReceiveSpecVoucher {
    if (_fullDict != nil && _fullDict != (id)[NSNull null]) {
        if ([_fullDict objectForKey:SECTION_SNELLEN_TEST] != (id)[NSNull null]) { //if the section has at least one entry...
            NSDictionary *snellenEyeDict = [_fullDict objectForKey:SECTION_SNELLEN_TEST];
            NSNumber *needSpecs = [snellenEyeDict objectForKey:kSpecs];
            if (needSpecs == (id)[NSNull null]) return NO;
            
            if ([needSpecs boolValue]) {
                if ([_fullDict objectForKey:SECTION_PROFILING_SOCIOECON] != (id)[NSNull null]) { //if the section has at least one entry...
                    NSDictionary *financeDict = [_fullDict objectForKey:SECTION_PROFILING_SOCIOECON];
                    NSNumber *avgIncomePerHead = [financeDict objectForKey:kAvgIncomePerHead];
                    
                    if (avgIncomePerHead != (id)[NSNull null] && [avgIncomePerHead integerValue] <= 1500) {
                        return YES;
                    }
                } else if ([_fullDict objectForKey:SECTION_FIN_ASSMT] != (id)[NSNull null]) {
                    NSDictionary *financeAssmtDict = [_fullDict objectForKey:SECTION_FIN_ASSMT];
                    NSNumber *copeFin = [financeAssmtDict objectForKey:kCopeFin];
                    
                    if (copeFin != (id)[NSNull null] && ![copeFin boolValue])   //cannot cope financially
                        return YES;
                    else
                        return NO;
                }
            }
        }
    }
    return NO;
}

- (BOOL) isFemale {
    NSString *gender = [[NSUserDefaults standardUserDefaults]
                             stringForKey:kGender];
    if ([gender containsString:@"F"]) return YES;
    else return NO;
}




@end

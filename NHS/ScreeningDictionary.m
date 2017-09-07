//
//  ScreeningDictionary.m
//  NHS
//
//  Created by Nicholas Wong on 9/6/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "ScreeningDictionary.h"
#import "ServerComm.h"
#import "AppConstants.h"
#import "SVProgressHUD.h"

@implementation ScreeningDictionary


#pragma mark Singleton

// thread-safe singleton
+ (ScreeningDictionary *)sharedInstance {
    
    // structure used to test if the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedTherapistInstance as nill (first call only).
    // static var doesn't get reset after first invocation.
    __strong static id sharedInstance = nil;
    
    // executes a block object once and only once for the lifetime of the
    // application
    dispatch_once(&p, ^{
        sharedInstance = [[self alloc] init];
    });
    
    // return the same object each time
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if(self) {
        self.dictionary = [[NSDictionary alloc] init];
    }
    
    return self;
}

- (void) fetchFromServer {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [SVProgressHUD showWithStatus:@"Downloading data..."];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    [client getSingleScreeningResidentDataWithResidentID:resident_id
                                           progressBlock:[self progressBlock]
                                            successBlock:[self downloadSingleResidentDataSuccessBlock]
                                            andFailBlock:[self downloadErrorBlock]];
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        //do nothing for now
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSingleResidentDataSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        _dictionary = responseObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_TABLE object:self];
        NSLog(@"fetched!");
        [self saveCoreData];
        [self prepareAdditionalSvcs];
        // save all the qualify stuffs for additional services
        
        [SVProgressHUD dismiss];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))downloadErrorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSString *errorString =[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSLog(@"error: %@", errorString);
        [SVProgressHUD showErrorWithStatus:@"Download failed"];
    };
}



- (void) saveCoreData {
    
    NSDictionary *particularsDict =[_dictionary objectForKey:SECTION_RESI_PART];
    NSDictionary *profilingDict =[_dictionary objectForKey:SECTION_PROFILING_SOCIOECON];
    
    // Calculate age
    NSMutableString *str = [particularsDict[kBirthDate] mutableCopy];
    NSString *yearOfBirth = [str substringWithRange:NSMakeRange(0, 4)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
    
    
    //    [[NSUserDefaults standardUserDefaults] setObject:_sampleResidentDict[kGender] forKey:kGender];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:age] forKey:kResidentAge];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kResidentId] forKey:kResidentId];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kScreenLocation] forKey:kNeighbourhood];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kName] forKey:kName];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kNRIC] forKey:kNRIC];
    
    // For Current Socioecon Situation
    if (profilingDict != (id)[NSNull null] && profilingDict[kEmployStat] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:profilingDict[kEmployStat] forKey:kEmployStat];
    if (profilingDict != (id)[NSNull null] && profilingDict[kAvgMthHouseIncome] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:profilingDict[kAvgMthHouseIncome] forKey:kAvgMthHouseIncome];
    
    // For demographics
    if (particularsDict[kCitizenship] != (id) [NSNull null])        //check for null first
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kCitizenship] forKey:kCitizenship];
    if (particularsDict[kReligion] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kReligion] forKey:kReligion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) prepareAdditionalSvcs {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    /* CHAS */
    NSDictionary *chasDict = [_dictionary objectForKey:SECTION_CHAS_PRELIM];
    BOOL noChas=false, lowIncome=false, wantChas=false;
    
    if (chasDict != (id)[NSNull null]) {
        
        if (chasDict[kDoesntOwnChasPioneer] != (id)[NSNull null])
            noChas = [chasDict[kDoesntOwnChasPioneer] boolValue];
        if (chasDict[kLowHouseIncome] != (id)[NSNull null])
            lowIncome = [chasDict[kLowHouseIncome] boolValue];
        if (chasDict[kWantChas] != (id)[NSNull null])
            wantChas = [chasDict[kWantChas] boolValue];
        if (noChas && lowIncome && wantChas && [[defaults objectForKey:kCitizenship] isEqualToString:@"Singaporean"]) { //7th Sept - added new criteria to be a Singaporaen for CHAS
            [defaults setObject:@"1" forKey:kQualifyCHAS];
        }
    }
    
    
    /* Colonoscopy */
    NSDictionary *colonDict = [_dictionary objectForKey:SECTION_COLONOSCOPY_ELIGIBLE];
    BOOL sporeanPr = false, age50 = false, relColorectCancer=false, colon3Yrs=false, wantColRef=false;
    
    if ([[defaults objectForKey:kCitizenship] isEqualToString:@"Singaporean"] || [[defaults objectForKey:kCitizenship] isEqualToString:@"PR"]) {
        sporeanPr = true;
    } else {
        sporeanPr = false;
    }
    
    if ([[defaults objectForKey:kResidentAge] intValue] > 49)
        age50 = true;
    else
        age50 = false;
    
    if (colonDict != (id)[NSNull null]) {
        
        
        if (colonDict[kRelWColorectCancer] != (id)[NSNull null])
            relColorectCancer = [colonDict[kRelWColorectCancer] boolValue];
        if (colonDict[kColonoscopy3yrs] != (id)[NSNull null])
            colon3Yrs = [colonDict[kColonoscopy3yrs] boolValue];
        if (colonDict[kWantColonoscopyRef] != (id)[NSNull null])
            wantColRef = [colonDict[kWantColonoscopyRef] boolValue];
        
        if (sporeanPr && age50 && relColorectCancer && colon3Yrs && wantColRef)
            [defaults setObject:@"1" forKey:kQualifyColonsc];
    }
    
    /* FIT Kit */
    //SporeanPr and age50 from above.
    NSDictionary *fitDict = [_dictionary objectForKey:SECTION_FIT_ELIGIBLE];
    BOOL fit12Mths=false, colon10Yrs=false, wantFitKit=false;
    if (fitDict != (id)[NSNull null]) {
        
        if (fitDict[kFitLast12Mths] != (id)[NSNull null])
            fit12Mths = [fitDict[kFitLast12Mths] boolValue];
        if (fitDict[kColonoscopy10Yrs] != (id)[NSNull null])
            colon10Yrs = [fitDict[kColonoscopy10Yrs] boolValue];
        if (fitDict[kWantFitKit] != (id)[NSNull null])
            wantFitKit = [fitDict[kWantFitKit] boolValue];
        
        if (sporeanPr && age50 && fit12Mths && colon10Yrs && wantFitKit)
            [defaults setObject:@"1" forKey:kQualifyFIT];
    }
    
    /* Mammogram */
    NSDictionary *mammoDict = [_dictionary objectForKey:SECTION_MAMMOGRAM_ELIGIBLE];
    BOOL sporean = false, age5069, noMammo2Yrs = false, hasChas = false, wantMammo;
    
    if ([[defaults objectForKey:kCitizenship] isEqualToString:@"Singaporean"]) {
        sporean = true;
    } else {
        sporean = false;
    }
    
    if ([[defaults objectForKey:kResidentAge] intValue] >= 50 && [[defaults objectForKey:kResidentAge] intValue] <= 69)
        age5069 = true;
    else
        age5069 = false;
    
    if (mammoDict != (id)[NSNull null]) {
        
        
        if (mammoDict[kMammo2Yrs] != (id)[NSNull null])
            noMammo2Yrs = [mammoDict[kMammo2Yrs] boolValue];
        if (mammoDict[kHasChas] != (id)[NSNull null])
            hasChas = [mammoDict[kHasChas] boolValue];
        if (mammoDict[kWantMammo] != (id)[NSNull null])
            wantMammo = [mammoDict[kWantMammo] boolValue];
        
        if (sporean && age5069 && noMammo2Yrs && hasChas && kWantMammo)
            [defaults setObject:@"1" forKey:kQualifyMammo];
        
    }
    
    
    
    /* Pap Smear */
    NSDictionary *papSmearDict = [_dictionary objectForKey:SECTION_PAP_SMEAR_ELIGIBLE];
    BOOL age2569, noPapSmear3Yrs = false, hadSex = false, wantPapSmear = false;
    
    if ([[defaults objectForKey:kResidentAge] intValue] >= 25 && [[defaults objectForKey:kResidentAge] intValue] <= 69)
        age2569 = true;
    else
        age2569 = false;
    
    if (papSmearDict != (id)[NSNull null]) {
        
        
        if (papSmearDict[kPap3Yrs] != (id)[NSNull null])
            noPapSmear3Yrs = [papSmearDict[kPap3Yrs] boolValue];
        
        if (papSmearDict[kEngagedSex] != (id)[NSNull null])
            hadSex = [papSmearDict[kEngagedSex] boolValue];
        
        if (papSmearDict[kWantPap] != (id)[NSNull null])
            wantPapSmear = [papSmearDict[kWantPap] boolValue];
        
        if (sporean && age2569 && noPapSmear3Yrs && hadSex && wantPapSmear)
            [defaults setObject:@"1" forKey:kQualifyPapSmear];
    }
    
    /* SERI Eligibility */
    NSDictionary *seriEligibDict = [_dictionary objectForKey:SECTION_SNELLEN_TEST];
    BOOL six12 = false, tunnel = false, visitEye12Mth = false;
    
    if (seriEligibDict != (id)[NSNull null]) {
        
        
        if (seriEligibDict[kSix12] != (id)[NSNull null])
            six12 = [seriEligibDict[kSix12] boolValue];
        
        if (seriEligibDict[kTunnel] != (id)[NSNull null])
            tunnel = [seriEligibDict[kTunnel] boolValue];
        
        if (seriEligibDict[kVisitEye12Mths] != (id)[NSNull null])
            visitEye12Mth = [seriEligibDict[kVisitEye12Mths] boolValue];
        
        if (six12 && tunnel && visitEye12Mth)
            [defaults setObject:@"1" forKey:kQualifySeri];
    }
    
    /* Fall Risk Assessment */
    NSDictionary *fallRiskEligibDict = [_dictionary objectForKey:SECTION_FALL_RISK_ELIGIBLE];
    BOOL age65Above = false, fallen12Mths = false, scaredFall = false, feelFall = false;
    
    if ([[defaults objectForKey:kResidentAge] intValue] >= 65)
        age65Above = true;
    else
        age65Above = false;
    
    
    if (fallRiskEligibDict != (id)[NSNull null]) {
        
        if (fallRiskEligibDict[kFallen12Mths] != (id)[NSNull null])
            fallen12Mths = [fallRiskEligibDict[kFallen12Mths] boolValue];
        
        if (fallRiskEligibDict[kScaredFall] != (id)[NSNull null])
            scaredFall = [fallRiskEligibDict[kScaredFall] boolValue];
        
        if (fallRiskEligibDict[kFeelFall] != (id)[NSNull null])
            feelFall = [fallRiskEligibDict[kFeelFall] boolValue];
        
        if (age65Above && fallen12Mths && scaredFall && feelFall)
            [defaults setObject:@"1" forKey:kQualifyFallAssess];
        
    }
    
    /* Dementia Assessment */
    NSDictionary *dementiaEligibDict = [_dictionary objectForKey:SECTION_GERIATRIC_DEMENTIA_ELIGIBLE];
    BOOL cognitiveImpair = false;
    
    if (dementiaEligibDict != (id)[NSNull null]) {
        
        if (dementiaEligibDict[kCognitiveImpair] != (id)[NSNull null])
            cognitiveImpair = [dementiaEligibDict[kCognitiveImpair] boolValue];
        
        if (age65Above && cognitiveImpair) {
            [defaults setObject:@"1" forKey:kQualifyDementia];
        }
    }
    /*
     
     
     else if ([rowDescriptor.tag isEqualToString:kCognitiveImpair]) {
     [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ELIGIBLE andFieldName:kCognitiveImpair andNewContent:newValue];
     }*/
    
}


@end

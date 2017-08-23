//
//  ServerComm.m
//  NHS
//
//  Created by Nicholas on 7/25/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ServerComm.h"

//#define baseURL @"https://nus-nhs.ml/"        //for Development
#define baseURL @"https://nhs-som.nus.edu.sg/"

@interface ServerComm ()

@end

@implementation ServerComm

#pragma mark Singleton

// thread-safe singleton
+ (ServerComm *)sharedServerCommInstance {
    
    // structure used to test if the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedTherapistInstance as nill (first call only).
    // static var doesn't get reset after first invocation.
    __strong static id _sharedServerCommInstance = nil;
    
    // executes a block object once and only once for the lifetime of the
    // application
    dispatch_once(&p, ^{
        _sharedServerCommInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
    
    // return the same object each time
    return _sharedServerCommInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if(self) {
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
        
    }
    
    return self;
}

#pragma mark - Patient

- (void)getPatient:(void (^)(NSProgress *downloadProgress))progressBlock
      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 1700;
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    [self POST:[dict objectForKey:@"op_code"]
   parameters:NULL
     progress:progressBlock
      success:successBlock
      failure:[self checkForBadHTTP:failBlock]];
}

- (void)getPatientDataWithPatientID:(NSNumber *) patientID
         progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 52;
    NSDictionary *url = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dict;
    NSDictionary *dataDict;
    
    dict = @{@"resident_id" : patientID};
    dataDict = @{@"data": dict};
    
    NSLog(@"%@",dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
   parameters:dataDict
     progress:progressBlock
      success:successBlock
      failure:[self checkForBadHTTP:failBlock]];
}

- (void) deleteResidentWithResidentID: (NSNumber *) residentID
            progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
            successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
            andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    NSInteger opCode = 99;
    
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dict;
    NSDictionary *dataDict;
    
    dict = @{@"resident_id" : residentID};
    dataDict = @{@"data": dict};
    
    NSLog(@"%@",dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
    
}

#pragma mark - Resident Particulars

//updated
- (void)postNewResidentWithDict:(NSDictionary *) personalInfoDict
                   progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                    successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                    andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 1701;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    NSDictionary *dataDict;
    
    dataDict = @{@"data": personalInfoDict};
    
    NSLog(@"%@", dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void)postDataGivenSectionAndFieldName:(NSDictionary *) dict
                 progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                  successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                  andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 1703;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    NSDictionary *dataDict;
    
    dataDict = @{@"data": dict};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void)postSpokenLangWithDict:(NSDictionary *) spokenLangDict
                 progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                  successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                  andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 54;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    NSDictionary *dataDict;
    
    dataDict = @{@"data": spokenLangDict};
    
    NSLog(@"%@", dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void)postContactInfoWithDict:(NSDictionary *) contactInfoDict
                  progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                   successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                   andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 55;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    NSDictionary *dataDict;
    
    dataDict = @{@"data": contactInfoDict};
    
    NSLog(@"%@", dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void)postReqServWithDict:(NSDictionary *) reqServDict
              progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
               successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
               andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 56;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    NSDictionary *dataDict;
    
    dataDict = @{@"data": reqServDict};
    
    NSLog(@"%@", dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void)postOthersWithDict:(NSDictionary *) othersDict
             progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
              successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
              andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 57;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    NSDictionary *dataDict;
    
    dataDict = @{@"data": othersDict};
    
    NSLog(@"%@", dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}



#pragma mark - Screening API
- (void)getAllScreeningResidents:(void (^)(NSProgress *downloadProgress))progressBlock
      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 101;
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    [self POST:[dict objectForKey:@"op_code"]
   parameters:NULL
     progress:progressBlock
      success:successBlock
      failure:[self checkForBadHTTP:failBlock]];
}

- (void)getSingleScreeningResidentDataWithResidentID:(NSNumber *) residentID
                      progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                       andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 102;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dict;
    NSDictionary *dataDict;
    
    dict = @{@"resident_id" : residentID};
    dataDict = @{@"data": dict};
    
    NSLog(@"%@",dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postNeighbourhoodWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 103;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"neighbourhood":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postResidentParticularsWithDict: (NSDictionary *) dictionary
                           progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                            successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                            andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 104;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"resi_particulars":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
    
}


- (void) postClinicalResultsWithDict: (NSDictionary *) dictionary
                           progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                            successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                            andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 105;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": dictionary};  //exceptional
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postRiskFactorsWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 106;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"risk_factors":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postDiabetesWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 107;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"diabetes":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postHyperlipidWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 108;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"hyperlipid":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postHypertensionWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 109;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"hypertension":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postCancerWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 110;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"cancer":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postOtherMedIssuesWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 111;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"others":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postPriCareSourceWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 112;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"primary_care":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postMyHealthMyNeighbourhoodWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 113;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"self_rated":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postDemographicsWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 114;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"demographics":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postCurrPhyIssuesWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 115;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"adls":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postCurrSocioSituationWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 116;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"socioecon":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postSociSuppAssessWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 117;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"social_support":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postRefForDocConsultWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 118;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"consult_record":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postSubmitRemarksWithDict: (NSDictionary *) dictionary
                        progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                         successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                         andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 119;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"submit_remarks":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
        success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

#pragma mark - Blood Test API
//- (void) getAllBloodTestResidents:(void (^)(NSProgress *downloadProgress))progressBlock
//                       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
//                       andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
//    
//    NSInteger opCode = 403;
//    NSDictionary *url = [[NSDictionary alloc]
//                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
////    NSDictionary *dataDict;
//    
////    dataDict = @{@"data": @{@"resident_id":residentID}};
//    
//    [self POST:[url objectForKey:@"op_code"]
//    parameters:NULL
//      progress:progressBlock
//       success:successBlock
//       failure:[self checkForBadHTTP:failBlock]];
//}
//
//- (void) getBloodTestWithResidentID: (NSNumber *) residentID
//                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
//                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
//                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
//    
//    NSInteger opCode = 401;
//    NSDictionary *url = [[NSDictionary alloc]
//                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
//    NSDictionary *dataDict;
//    
//    dataDict = @{@"data": @{@"resident_id":residentID}};
//    
//    [self POST:[url objectForKey:@"op_code"]
//    parameters:dataDict
//      progress:progressBlock
//       success:successBlock
//       failure:[self checkForBadHTTP:failBlock]];
//}
//
//- (void) postBloodTestResultWithDict: (NSDictionary *) dictionary
//                       progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
//                        successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
//                        andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
//    
//    NSInteger opCode = 402;
//    NSDictionary *url = [[NSDictionary alloc]
//                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
//    NSDictionary *dataDict;
//    
//    dataDict = @{@"data": @{@"blood_test":dictionary}};
//    
//    [self POST:[url objectForKey:@"op_code"]
//    parameters:dataDict
//      progress:progressBlock
//       success:successBlock
//       failure:[self checkForBadHTTP:failBlock]];
//}

#pragma mark - Follow Up API
- (void) getAllFollowedUpResidents:(void (^)(NSProgress *downloadProgress))progressBlock
                     successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                     andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 500;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:NULL
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) getFollowUpDetailsWithResidentID: (NSString *) residentID
                      progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                       andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 501;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"resident_id":residentID}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

#pragma mark Phone Call
- (void) postCallerInfoWithDict: (NSDictionary *) dictionary
                       progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                        successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                        andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 202;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"calls_caller":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postCallMgmtPlanWithDict: (NSDictionary *) dictionary
                  progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                   successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                   andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 203;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"calls_mgmt_plan":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

#pragma mark Home Visit
- (void) postVolunteerInfoWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 302;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"house_volunteer":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postClinicalWithDict: (NSDictionary *) dictionary
                progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                  successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                 andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 303;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"house_clinical":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}


- (void) postCbgWithDict: (NSDictionary *) dictionary
           progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
             successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
            andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 304;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"house_cbg":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}


- (void) postBpRecordWithArray: (NSArray *) array
                progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                  successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                 andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 305;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"house_bp_record":array}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postMedicalSocialIssuesWithDict: (NSDictionary *) dictionary
                           progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                             successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                            andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 306;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"house_med_soc":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void) postMgmtPlanWithDict: (NSDictionary *) dictionary
                progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                  successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                 andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 307;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"house_mgmt_plan":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

#pragma mark Social Work

- (void) postSocialWorkFollowUpWithDict: (NSDictionary *) dictionary
                  progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                   successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                   andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 600;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dataDict;
    
    dataDict = @{@"data": @{@"social_wk_followup":dictionary}};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

#pragma mark -


// returns a base64 encoded string of given NSData.
- (NSString *)base64forData:(NSData *)theData {
    const uint8_t *input = (const uint8_t *)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    NSInteger i;
    for (i = 0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] = table[(value >> 18) & 0x3F];
        output[theIndex + 1] = table[(value >> 12) & 0x3F];
        output[theIndex + 2] =
        (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[theIndex + 3] =
        (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}



#pragma mark - Block to check handle HTTP status

- (void (^)(NSURLSessionDataTask *task, NSError *error))checkForBadHTTP:(void(^)(NSURLSessionDataTask *task, NSError *error))callback {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        int errorCode = (int)[[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
        if (errorCode == 403) {
//            [self delayInSeconds:1.0 toCall:^(void) {
//                [self redirectBackToLoginScreen];
//            }];
        } else {
            callback(task, error);
        }
    };
}




@end

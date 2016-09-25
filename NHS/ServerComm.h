//
//  ServerComm.h
//  NHS
//
//  Created by Nicholas on 7/25/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface ServerComm : AFHTTPSessionManager
// singleton
+ (ServerComm *)sharedServerCommInstance;

//#pragma mark Therapist Info methods
//- (void)loginWithUserName:(NSString *)userName
//                  passkey:(NSString *)passkey
//                notifName:(NSString *)notifName;
//
//- (void)changePasswordForTherapistName:(NSString *)userName
//                       fromOldPassword:(NSString *)oldPassword
//                         toNewPassword:(NSString *)newPassword
//                             notifName:(NSString *)notifName;
//
//- (void)submitPasswordResetRequestForTherapistName:(NSString *)userName
//                                         notifName:(NSString *)notifName;

#pragma mark - Patient

- (void)getPatient:(void (^)(NSProgress *downloadProgress))progressBlock
      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void)getPatientDataWithPatientID:(NSNumber *) patientID
                      progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                       andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) deleteResidentWithResidentID: (NSNumber *) residentID
                       progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                        successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                        andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;


#pragma mark - Pre-Registration

- (void)postPersonalInfoWithDict:(NSDictionary *) personalInfoDict
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void)postSpokenLangWithDict:(NSDictionary *) spokenLangDict
                  progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                   successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                   andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void)postContactInfoWithDict:(NSDictionary *) contactInfoDict
                  progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                   successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                   andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void)postReqServWithDict:(NSDictionary *) reqServDict
                  progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                   successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                   andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void)postOthersWithDict:(NSDictionary *) othersDict
              progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
               successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
               andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;


#pragma mark - Screening API
- (void)getAllScreeningResidents:(void (^)(NSProgress *downloadProgress))progressBlock
successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                    andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void)getSingleScreeningResidentDataWithResidentID:(NSNumber *) residentID
                                       progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                                        successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                                        andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postNeighbourhoodWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postResidentParticularsWithDict: (NSDictionary *) dictionary
                           progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                            successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                            andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postClinicalResultsWithDict: (NSDictionary *) dictionary
                       progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                        successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                        andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postRiskFactorsWithDict: (NSDictionary *) dictionary
                   progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                    successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                    andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postDiabetesWithDict: (NSDictionary *) dictionary
                progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                 successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                 andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postHyperlipidWithDict: (NSDictionary *) dictionary
                  progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                   successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                   andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postHypertensionWithDict: (NSDictionary *) dictionary
                    progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                     successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                     andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postCancerWithDict: (NSDictionary *) dictionary
              progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
               successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
               andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postOtherMedIssuesWithDict: (NSDictionary *) dictionary
                      progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                       andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postPriCareSourceWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postMyHealthMyNeighbourhoodWithDict: (NSDictionary *) dictionary
                               progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                                successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                                andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postDemographicsWithDict: (NSDictionary *) dictionary
                    progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                     successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                     andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postCurrPhyIssuesWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postCurrSocioSituationWithDict: (NSDictionary *) dictionary
                          progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                           successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                           andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postSociSuppAssessWithDict: (NSDictionary *) dictionary
                      progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                       andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postRefForDocConsultWithDict: (NSDictionary *) dictionary
                        progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                         successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                         andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postSubmitRemarksWithDict: (NSDictionary *) dictionary
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;


#pragma mark - Blood Test API
- (void) getAllBloodTestResidents:(void (^)(NSProgress *downloadProgress))progressBlock
                     successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                     andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) getBloodTestWithResidentID: (NSNumber *) residentID
                      progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                       andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postBloodTestResultWithDict: (NSDictionary *) dictionary
                       progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                        successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                        andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

#pragma mark - Follow Up API
- (void) getAllFollowedUpResidents:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) getFollowUpDetailsWithResidentID: (NSNumber *) residentID
                            progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                             successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                             andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

#pragma mark Phone Calls
- (void) postCallerInfoWithDict: (NSDictionary *) dictionary
                  progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                   successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                   andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) postCallMgmtPlanWithDict: (NSDictionary *) dictionary
                    progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                     successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                     andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;


@end

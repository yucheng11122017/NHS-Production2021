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
//#pragma mark - Activity Selection methods
//
//- (void)getAllActivitySelectionsForPatientID:(NSInteger)patientID
//                                   notifName:(NSString *)notifName;
//
//- (void)updateAllSelectionsForActivityType:(NSInteger)activityType
//                                activityID:(NSInteger)activityID
//                                 isEnabled:(BOOL)isEnabled
//                             progressLevel:(NSInteger)progressLevelID
//                                 numOfReps:(NSInteger)numOfReps
//                                      sets:(NSInteger)numOfSets
//                                   remarks:(NSString *)remarks
//                               targetAngle:(NSInteger)targetAngle
//                              holdDuration:(NSInteger)holdDuration
//                                  duration:(NSInteger)duration
//                                forPatient:(NSInteger)patientID
//                                 notifName:(NSString *)notifName;
//
//#pragma mark Activity Record Methods
//
//- (void)getListOfTimestampsAndWeekNumbersForAllActivitiesForPatientID:
//(NSInteger)patientID
//                                                            notifName:
//(NSString *)
//notifName;
//
//- (void)getActivityRecordForPatientID:(NSInteger)patientID
//                             Activity:(NSInteger)activityID
//                           WeekNumber:(NSInteger)weekNumber
//                               ofYear:(NSInteger)year
//                            notifName:(NSString *)notifName;
//
//- (void)getFuncActivityRecordForPatientID:(NSInteger)patientID
//                                 Activity:(NSInteger)activityID
//                               WeekNumber:(NSInteger)weekNumber
//                                   ofYear:(NSInteger)year
//                                notifName:(NSString *)notifName;
//
//- (void)getListOfDaysAndTimesOfStrengtheningActivity:(NSInteger)activityID
//                                        ForPatientID:(NSInteger)patientID
//                                              inWeek:(NSInteger)weekNumber
//                                              ofYear:(NSInteger)yearNumber
//                                           notifName:(NSString *)notifName;
//
//- (void)getListOfDaysAndTimesOfBalanceActivity:(NSInteger)activityID
//                                  ForPatientID:(NSInteger)patientID
//                                        inWeek:(NSInteger)weekNumber
//                                        ofYear:(NSInteger)yearNumber
//                                     notifName:(NSString *)notifName;
//
//- (void)getListOfDaysAndTimesOfFunctionalActivity:(NSInteger)activityID
//                                     ForPatientID:(NSInteger)patientID
//                                           inWeek:(NSInteger)weekNumber
//                                           ofYear:(NSInteger)yearNumber
//                                        notifName:(NSString *)notifName;
//
//- (void)getBalActivityRecordURLsForActivity:(NSInteger)activityID
//                               ForPatientID:(NSInteger)patientID
//                                     inWeek:(NSInteger)weekNumber
//                                     ofYear:(NSInteger)yearNumber
//                                  notifName:(NSString *)notifName;
//
//#pragma mark HR-BP Records
//
//- (void)insertHrBpRecordForPatientID:(NSInteger)patientID
//                      withSystolicBP:(NSInteger)bp_systolic
//                         diastolicBP:(NSInteger)bp_diastolic
//                        andHeartRate:(NSInteger)heartRate
//                              atTime:(NSString *)timeOfEntry
//                           notifName:(NSString *)notifName;
//
//- (void)retrieveHrBpRecordsForPatient:(NSInteger)patientID
//                            notifName:(NSString *)notifName;
//
//- (void)sendEmailToAdminWithSubject:(NSString *)subject
//                               body:(NSString *)body
//                          notifName:(NSString *)notifName;
//
//#pragma mark Call Notes
//
//- (void)insertFacetimeCalltoPatient:(NSInteger)patientID
//                FromButtonPressTime:(NSString *)buttonPressTime
//                      toCallEndTime:(NSString *)callEndTime
//                  withTherapistNote:(NSString *)therapistNote
//                    andWasAppKilled:(BOOL)wasAppKilled
//                          notifName:(NSString *)notifName;
//
//- (void)retrieveAllTherapistNotesForPatient:(NSInteger)patientID
//                                  notifName:(NSString *)notifName;
//
//- (void)updateNoteforPatient:(NSInteger)patientID
//         atOriginalStartTime:(NSString *)originalCallStartTime
//        updatedCallStartTime:(NSString *)updatedCallStartTime
//          updatedCallEndTime:(NSString *)updatedCallEndTime
//             withUpdatedNote:(NSString *)updatedNote
//                   notifName:(NSString *)notifName;
//
//- (void)emailCallNote:(NSString *)callNote
//       forPatientName:(NSString *)patientName
//           atDateTime:(NSString *)dateTime
//            notifName:(NSString *)notifName;
//
//#pragma mark seen graphs
//
//- (void)getListOfSeenGraphsOfPatient:(NSInteger)patientID
//                           notifName:(NSString *)notifName;
//
//- (void)tellServerThatTheGraphForPatient:(NSInteger)patientID
//                                activity:(NSInteger)activityID
//                ofStrengtheningOrBalance:(BOOL)isStrengtheningOrBalance
//                withLatestExerciseDateOf:(NSString *)latestExerciseDate
//                         andNumberOfReps:(NSInteger)numberOfReps
//                    wasSeenWithNotifName:(NSString *)notifName;

@end
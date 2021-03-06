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

@property (strong,nonatomic) AFHTTPSessionManager *uploadManager;
@property (strong, nonatomic) AFHTTPSessionManager *downloadManager;
@property (strong, nonatomic) NSNumber *ongoingDownloads;

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

- (void)getResidentGivenNRIC: (NSString *) nric
           withProgressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void) deleteResidentWithResidentID: (NSNumber *) residentID
                       progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                        successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                        andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;


#pragma mark - Resident Particulars

- (void)postNewResidentWithDict:(NSDictionary *) personalInfoDict
                     progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

- (void)postDataGivenSectionAndFieldName:(NSDictionary *) dict
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

- (void)generateSerialIdForResidentID:(NSNumber *) residentID
                        progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                         successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                         andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock;

#pragma mark - Image DL & UL
-(NSString *)getRetrievedGenogramImagePath;
-(NSString *)getdDownloadedImagePath;

-(void)uploadImage:(UIImage *) image forResident: (NSNumber *) residentID
          withNric:(NSString *)nric
   andWithFileType:(NSString *) fileType
 withProgressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
 completionHandler:(void (^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))uploadCompletionHandler;

-(void)downloadImageWithResident:(NSNumber *) residentID
                        withNric:(NSString *)nric
                     andFiletype:(NSString *) filetype;

#pragma mark - Genogram stuffs
//-(NSString *)getRetrievedGenogramImagePath;
//
//-(void)retrieveGenogramImageForResident:(NSNumber *)residentID
//                               withNric:(NSString *)nric;
//
//-(void)saveGenogram:(UIImage *) genogram
//        forResident: (NSNumber *) residentID
//           withNric:(NSString *) nric;

#pragma mark - Consent Form
//-(void)saveConsentFormImage:(UIImage *) consentForm
//        forResident: (NSNumber *) residentID
//           withNric:(NSString *) nric;
//
//-(NSString *)getRetrievedConsentImagePath;
//
//-(void)retrieveConsentImageForResident:(NSNumber *) residentID
//                              withNric:(NSString *)nric;

#pragma mark - Research Consent Form
//-(void)saveResearchConsentFormImage:(UIImage *) consentForm
//                        forResident:(NSNumber *) residentID
//                           withNric:(NSString *)nric;
//
//-(NSString *)getRetrievedResearchConsentImagePath;
//
//-(void)retrieveResearchConsentImageForResident:(NSNumber *) residentID
//                                      withNric:(NSString *)nric;

#pragma mark - Autorefractor Image
-(void)saveAutorefractorFormImage:(UIImage *) consentForm
                      forResident:(NSNumber *) residentID
                         withNric:(NSString *)nric;

-(NSString *)getRetrievedAutorefractorFormImagePath;

-(void)retrieveAutorefractorFormImageForResident:(NSNumber *) residentID
                                        withNric:(NSString *)nric;


#pragma mark - PDF Report
- (NSString *) getretrievedReportFilepath;
-(void)retrievePdfReportForResident:(NSNumber *) residentID;

@end

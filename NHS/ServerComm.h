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

#pragma mark - Genogram stuffs
-(NSString *)getretrievedGenogramImagePath;

-(void)retrieveGenogramImageForResident:(NSNumber *)residentID
                               withNric:(NSString *)nric;

-(void)saveGenogram:(UIImage *) genogram
        forResident: (NSNumber *) residentID
           withNric:(NSString *) nric;

#pragma mark - PDF Report
- (NSString *) getretrievedReportFilepath;
-(void)retrievePdfReportForResident:(NSNumber *) residentID;

@end

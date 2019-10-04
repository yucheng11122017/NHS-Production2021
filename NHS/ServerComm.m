//
//  ServerComm.m
//  NHS
//
//  Created by Nicholas on 7/25/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ServerComm.h"
#import "AppConstants.h"
#import "SVProgressHUD.h"
#import "ResidentProfile.h"

//#define baseURL @"https://nus-nhs.ml/"        //for Development
//#define baseURL @"https://nhs-som.nus.edu.sg/"
#define baseURL @"https://pd.homerehab.com.sg/"
#define GENOGRAM_LOADED_NOTIF @"Genogram image downloaded"
#define CONSENT_LOADED_NOTIF @"Consent image downloaded"
#define RESEARCH_CONSENT_LOADED_NOTIF @"Research Consent image downloaded"
#define IMAGE_LOADED_NOTIF @"Image downloaded"
#define IMAGE_FAILED_NOTIF @"Image failed"
#define AUTOREFRACTOR_LOADED_NOTIF @"Autorefractor image downloaded"
#define PDFREPORT_LOADED_NOTIF @"Pdf report downloaded"

@interface ServerComm ()

@property (strong, nonatomic) NSString *retrievedGenogramImagePath;
@property (strong, nonatomic) NSString *retrievedConsentImagePath;
@property (strong, nonatomic) NSString *retrievedResearchConsentImagePath;
@property (strong, nonatomic) NSString *retrievedAutorefractorFormImagePath;
@property (strong, nonatomic) NSString *retrievedPdfReportFilepath;
@property (strong, nonatomic) NSString *downloadedImagePath;



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

- (void)getResidentGivenNRIC: (NSString *) nric
           withProgressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 1708;
    NSDictionary *url = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    NSDictionary *dict;
    NSDictionary *dataDict;
    
    dict = @{@"nric": nric};
    dataDict = @{@"data": dict};
    
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
    NSInteger opCode = 1704;
    
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dict;
    NSDictionary *dataDict;
    
    dict = @{kResidentId: residentID};
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
#pragma mark - Screening API
- (void)getAllScreeningResidents:(void (^)(NSProgress *downloadProgress))progressBlock
      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 1700;    //updated for 1700
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
    
    NSInteger opCode = 1702;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *dict;
    NSDictionary *dataDict;
    
    dict = @{kResidentId : residentID};
    dataDict = @{@"data": dict};
    
    NSLog(@"%@",dataDict);
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

- (void)generateSerialIdForResidentID:(NSNumber *) residentID
                           progressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
                            successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                            andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 1706;
    NSDictionary *url = [[NSDictionary alloc]
                         initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    NSDictionary *dict = @{kResidentId:residentID};
    
    NSDictionary* dataDict = @{@"data": dict};
    
    [self POST:[url objectForKey:@"op_code"]
    parameters:dataDict
      progress:progressBlock
       success:successBlock
       failure:[self checkForBadHTTP:failBlock]];
}

#pragma mark - Image DL & UL


-(NSString *)getRetrievedGenogramImagePath{
    return [self.retrievedGenogramImagePath copy];
}

-(NSString *)getdDownloadedImagePath{
    return [self.downloadedImagePath copy];
}


-(void)uploadImage:(UIImage *) image forResident: (NSNumber *) residentID
          withNric:(NSString *)nric
   andWithFileType:(NSString *) fileType
 withProgressBlock:(void (^)(NSProgress *downloadProgress))progressBlock
 completionHandler:(void (^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))uploadCompletionHandler {
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    
    // Save image.
    BOOL writeSuccess = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    if(!writeSuccess)
    NSLog(@"error writing to file");
    
    //upload image to server
    NSURL *URL = [NSURL URLWithString:@"https://pd.homerehab.com.sg/uploadImage"];
    
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    
    NSDictionary *input = @{@"resident_id": residentID,
                            kNRIC: nric,
                            kFileType: fileType
                            };
    NSDictionary *data = @{@"data": input};
    
    //initialize upload manager (AFNetworking)
    self.uploadManager = [AFHTTPSessionManager manager];
    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    [self.uploadManager.operationQueue setMaxConcurrentOperationCount:2];
    self.uploadManager.securityPolicy.allowInvalidCertificates = NO;
    
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *req = [serializer multipartFormRequestWithMethod:@"POST"
                                                                URLString:[URL absoluteString]
                                                               parameters:data
                                                constructingBodyWithBlock:
                                ^(id<AFMultipartFormData>  _Nonnull formData) {
                                    [formData appendPartWithFileURL:filePathUrl name:@"userfile" error:nil];
                                }
                                                                    error:nil];
    
    NSURLSessionUploadTask *uploadTask = [self.uploadManager uploadTaskWithStreamedRequest:req
                                                                                  progress:progressBlock
                                                                         completionHandler:uploadCompletionHandler];
    [uploadTask resume];
}

-(void)downloadImageWithResident:(NSNumber *) residentID
                             withNric:(NSString *)nric
                          andFiletype:(NSString *) filetype {
    
    //setup input parameters
    NSDictionary *input = @{@"resident_id": residentID,
                            kNRIC: nric,
                            kFileType:filetype
                            };
    NSDictionary *data = @{@"data": input};
    NSError *error;
    
    //prep download manager
    self.downloadManager = [AFHTTPSessionManager manager];
    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    self.downloadManager.securityPolicy.allowInvalidCertificates = NO;
    
    
    
    //send req
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *req = [serializer requestWithMethod:@"POST" URLString:@"https://pd.homerehab.com.sg/downloadImage" parameters:data error:&error];
    
    NSURLSessionDownloadTask *dwlTsk = [self.downloadManager downloadTaskWithRequest:req
                                                                            progress:
                                        ^(NSProgress * _Nonnull downloadProgress) {
                                            [SVProgressHUD showProgress:downloadProgress.fractionCompleted status:@"Downloading Image..."];
//                                                                                        NSLog(@"Download Progress… %f", downloadProgress.fractionCompleted);
                                        }
                                                                         destination:
                                        ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                                  inDomain:NSUserDomainMask
                                                                                                         appropriateForURL:nil
                                                                                                                    create:NO
                                                                                                                     error:nil];
//                                            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                            return [documentsDirectoryURL URLByAppendingPathComponent:[filetype stringByAppendingString:@".png"]];
                                            
                                        }
                                                                   completionHandler:
                                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                            
                                            self.downloadedImagePath = filePath.path;
                                            if (error) {
                                                [SVProgressHUD setMaximumDismissTimeInterval:1.0];
                                                [SVProgressHUD showErrorWithStatus:@"Download failed!"];
                                                NSLog(@"Error: %@", error);
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_FAILED_NOTIF
                                                                                                    object:self
                                                                                                  userInfo:nil];
                                            } else {
                                                _ongoingDownloads = [NSNumber numberWithInteger:[_ongoingDownloads integerValue] - 1];
                                                
                                                NSLog(@"REMAINING DOWNLOADS: %@", _ongoingDownloads);
                                                if ([_ongoingDownloads isEqualToNumber:@0]) {
                                                    [SVProgressHUD showSuccessWithStatus:@"Signatures downloaded!"];
                                                    [SVProgressHUD setMaximumDismissTimeInterval:2.0];
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_LOADED_NOTIF object:nil];
                                                    
                                                }
                                                
                                                NSLog(@"Success: Image downloaded at: %@", [filePath absoluteString]);
                                                
                                                NSDictionary *userInfo = NSDictionaryOfVariableBindings(response, filePath);
                                                
//                                                // send out notification!
//                                                [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_LOADED_NOTIF
//                                                                                                    object:self
//                                                                                                  userInfo:userInfo];
                                            }
                                        }];
    
    [dwlTsk resume];
    
}


//
//-(NSString *)getRetrievedGenogramImagePath{
//    return [self.retrievedGenogramImagePath copy];
//}
//
//-(void)retrieveGenogramImageForResident:(NSNumber *) residentID
//                               withNric:(NSString *)nric {
//
//    //setup input parameters
//    NSDictionary *input = @{kResidentId: residentID, kNRIC:nric};
//    NSDictionary *data = @{@"data": input};
//    NSError *error;
//
//    //prep download manager
//    self.downloadManager = [AFHTTPSessionManager manager];
//    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
//    self.downloadManager.securityPolicy.allowInvalidCertificates = NO;
//
//    //send req
//    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
//    NSMutableURLRequest *req = [serializer requestWithMethod:@"POST" URLString:@"https://pd.homerehab.com.sg/downloadGenogram" parameters:data error:&error];
//
//    NSURLSessionDownloadTask *dwlTsk = [self.downloadManager downloadTaskWithRequest:req
//                                                                            progress:[self downloadGenogramProgressBlock]
//                                                                         destination:
//                                        ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//                                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
//                                                                                                                  inDomain:NSUserDomainMask
//                                                                                                         appropriateForURL:nil
//                                                                                                                    create:NO
//                                                                                                                     error:nil];
//
//                                            NSURL *fileUrl = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//
//                                            /** Delete existing file if any! */
//                                            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileUrl relativePath]];
//
//                                            if (fileExists) {
//                                                NSError *error;
//                                                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[fileUrl relativePath] error:&error];
//
//                                                if (success)
//                                                    NSLog(@"Deleted existing file!");
//                                                else
//                                                    NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
//                                            }
//
//                                            return fileUrl;
//                                        }
//                                                                   completionHandler:
//                                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//
//                                            [SVProgressHUD dismiss];
//                                            NSLog(@"Filepath: %@", filePath.path);
//                                            self.retrievedGenogramImagePath = filePath.path;
//                                            if (error) {
//                                                NSLog(@"Error: %@", error);
//                                            } else {
////                                                NSLog(@"Success: %@ genodownloaded at: %@", response, [filePath absoluteString]);
//
//                                                NSDictionary *userInfo = NSDictionaryOfVariableBindings(response, filePath);
//
//                                                // send out notification!
//                                                [[NSNotificationCenter defaultCenter] postNotificationName:GENOGRAM_LOADED_NOTIF
//                                                                                                    object:self
//                                                                                                  userInfo:userInfo];
//                                            }
//                                        }];
//
//    [dwlTsk resume];
//
//}
//
//-(void)saveGenogram:(UIImage *)genogram forResident:(NSNumber *) residentID withNric:(NSString *)nric {
//
//    // Create path.
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
//
//    // Save image.
//    BOOL writeSuccess = [UIImagePNGRepresentation(genogram) writeToFile:filePath atomically:YES];
//
//    if(!writeSuccess)
//        NSLog(@"error writing to file");
//
//    //upload image to server
//    NSURL *URL = [NSURL URLWithString:@"https://pd.homerehab.com.sg/uploadGenogram"];
//
//    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
//
//    NSDictionary *input = @{@"resident_id": residentID, @"nric": nric};
//    NSDictionary *data = @{@"data": input};
//
//    //initialize upload manager (AFNetworking)
//    self.uploadManager = [AFHTTPSessionManager manager];
//    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
//    [self.uploadManager.operationQueue setMaxConcurrentOperationCount:2];
//    self.uploadManager.securityPolicy.allowInvalidCertificates = NO;
//
//
//    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
//    NSMutableURLRequest *req = [serializer multipartFormRequestWithMethod:@"POST"
//                                                                URLString:[URL absoluteString]
//                                                               parameters:data
//                                                constructingBodyWithBlock:
//                                ^(id<AFMultipartFormData>  _Nonnull formData) {
//                                    [formData appendPartWithFileURL:filePathUrl name:@"userfile" error:nil];
//                                }
//                                                                    error:nil];
//
//    NSURLSessionUploadTask *uploadTask = [self.uploadManager uploadTaskWithStreamedRequest:req
//                                                                                  progress:[self uploadProgressBlock]
//                                                                         completionHandler:[self completionBlock]];
//    [uploadTask resume];
//}

#pragma mark - Consent Form
//-(void)saveConsentFormImage:(UIImage *) consentForm
//                forResident:(NSNumber *) residentID
//                   withNric:(NSString *)nric {
//
//    // Create path.
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
//
//    // Save image.
//    BOOL writeSuccess = [UIImagePNGRepresentation(consentForm) writeToFile:filePath atomically:YES];
//
//    if(!writeSuccess)
//        NSLog(@"error writing to file");
//
//    //upload image to server
//    NSURL *URL = [NSURL URLWithString:@"https://pd.homerehab.com.sg/uploadConsent"];
//
//    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
//
//    NSDictionary *input = @{@"resident_id": residentID, @"nric": nric};
//    NSDictionary *data = @{@"data": input};
//
//    //initialize upload manager (AFNetworking)
//    self.uploadManager = [AFHTTPSessionManager manager];
//    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
//    [self.uploadManager.operationQueue setMaxConcurrentOperationCount:2];
//    self.uploadManager.securityPolicy.allowInvalidCertificates = NO;
//
//
//    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
//    NSMutableURLRequest *req = [serializer multipartFormRequestWithMethod:@"POST"
//                                                                URLString:[URL absoluteString]
//                                                               parameters:data
//                                                constructingBodyWithBlock:
//                                ^(id<AFMultipartFormData>  _Nonnull formData) {
//                                    [formData appendPartWithFileURL:filePathUrl name:@"userfile" error:nil];
//                                }
//                                                                    error:nil];
//
//    NSURLSessionUploadTask *uploadTask = [self.uploadManager uploadTaskWithStreamedRequest:req
//                                                                                  progress:[self uploadProgressBlock]
//                                                                         completionHandler:[self completionBlock]];
//    [uploadTask resume];
//}
//
//-(NSString *)getRetrievedConsentImagePath{
//    return [self.retrievedConsentImagePath copy];
//}
//
//-(void)retrieveConsentImageForResident:(NSNumber *) residentID
//                               withNric:(NSString *)nric {
//
//    //setup input parameters
//    NSDictionary *input = @{kResidentId: residentID, kNRIC:nric};
//    NSDictionary *data = @{@"data": input};
//    NSError *error;
//
//    //prep download manager
//    self.downloadManager = [AFHTTPSessionManager manager];
//    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
//    self.downloadManager.securityPolicy.allowInvalidCertificates = NO;
//
//    //send req
//    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
//    NSMutableURLRequest *req = [serializer requestWithMethod:@"POST" URLString:@"https://pd.homerehab.com.sg/downloadConsent" parameters:data error:&error];
//
//    NSURLSessionDownloadTask *dwlTsk = [self.downloadManager downloadTaskWithRequest:req
//                                                                            progress:[self downloadConsentProgressBlock]
//                                                                         destination:
//                                        ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//                                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
//                                                                                                                  inDomain:NSUserDomainMask
//                                                                                                         appropriateForURL:nil
//                                                                                                                    create:NO
//                                                                                                                     error:nil];
//
//                                            NSURL *fileUrl = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//
//                                            /** Delete existing file if any! */
//                                            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileUrl relativePath]];
//
//                                            if (fileExists) {
//                                                NSError *error;
//                                                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[fileUrl relativePath] error:&error];
//
//                                                if (success)
//                                                    NSLog(@"Deleted existing file!");
//                                                else
//                                                    NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
//                                            }
//
//                                            return fileUrl;
//                                        }
//                                                                   completionHandler:
//                                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//
//                                            [SVProgressHUD dismiss];
//                                            NSLog(@"Filepath: %@", filePath.path);
//                                            self.retrievedConsentImagePath = filePath.path;
//                                            if (error) {
//                                                NSLog(@"Error: %@", error);
//                                            } else {
//                                                //                                                NSLog(@"Success: %@ genodownloaded at: %@", response, [filePath absoluteString]);
//
//                                                NSDictionary *userInfo = NSDictionaryOfVariableBindings(response, filePath);
//
//                                                // send out notification!
//                                                [[NSNotificationCenter defaultCenter] postNotificationName:CONSENT_LOADED_NOTIF
//                                                                                                    object:self
//                                                                                                  userInfo:userInfo];
//                                            }
//                                        }];
//
//    [dwlTsk resume];
//
//}

#pragma mark - Research Consent Form
//-(void)saveResearchConsentFormImage:(UIImage *) consentForm
//                        forResident:(NSNumber *) residentID
//                           withNric:(NSString *)nric {
//
//    // Create path.
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
//
//    // Save image.
//    BOOL writeSuccess = [UIImagePNGRepresentation(consentForm) writeToFile:filePath atomically:YES];
//
//    if(!writeSuccess)
//        NSLog(@"error writing to file");
//
//    //upload image to server
//    NSURL *URL = [NSURL URLWithString:@"https://pd.homerehab.com.sg/uploadConsentResearch"];
//
//    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
//
//    NSDictionary *input = @{@"resident_id": residentID, @"nric": nric};
//    NSDictionary *data = @{@"data": input};
//
//    //initialize upload manager (AFNetworking)
//    self.uploadManager = [AFHTTPSessionManager manager];
//    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
//    [self.uploadManager.operationQueue setMaxConcurrentOperationCount:2];
//    self.uploadManager.securityPolicy.allowInvalidCertificates = NO;
//
//
//    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
//    NSMutableURLRequest *req = [serializer multipartFormRequestWithMethod:@"POST"
//                                                                URLString:[URL absoluteString]
//                                                               parameters:data
//                                                constructingBodyWithBlock:
//                                ^(id<AFMultipartFormData>  _Nonnull formData) {
//                                    [formData appendPartWithFileURL:filePathUrl name:@"userfile" error:nil];
//                                }
//                                                                    error:nil];
//
//    NSURLSessionUploadTask *uploadTask = [self.uploadManager uploadTaskWithStreamedRequest:req
//                                                                                  progress:[self uploadProgressBlock]
//                                                                         completionHandler:[self researchCompletionBlock]];
//    [uploadTask resume];
//}
//
//-(NSString *)getRetrievedResearchConsentImagePath{
//    return [self.retrievedResearchConsentImagePath copy];
//}
//
//-(void)retrieveResearchConsentImageForResident:(NSNumber *) residentID
//                                      withNric:(NSString *)nric {
//
//    //setup input parameters
//    NSDictionary *input = @{kResidentId: residentID, kNRIC:nric};
//    NSDictionary *data = @{@"data": input};
//    NSError *error;
//
//    //prep download manager
//    self.downloadManager = [AFHTTPSessionManager manager];
//    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
//    self.downloadManager.securityPolicy.allowInvalidCertificates = NO;
//
//    //send req
//    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
//    NSMutableURLRequest *req = [serializer requestWithMethod:@"POST" URLString:@"https://pd.homerehab.com.sg/downloadConsentResearch" parameters:data error:&error];
//
//    NSURLSessionDownloadTask *dwlTsk = [self.downloadManager downloadTaskWithRequest:req
//                                                                            progress:[self downloadResearchConsentProgressBlock]
//                                                                         destination:
//                                        ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//                                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
//                                                                                                                  inDomain:NSUserDomainMask
//                                                                                                         appropriateForURL:nil
//                                                                                                                    create:NO
//                                                                                                                     error:nil];
//
//                                            NSURL *fileUrl = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//
//                                            /** Delete existing file if any! */
//                                            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileUrl relativePath]];
//
//                                            if (fileExists) {
//                                                NSError *error;
//                                                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[fileUrl relativePath] error:&error];
//
//                                                if (success)
//                                                    NSLog(@"Deleted existing file!");
//                                                else
//                                                    NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
//                                            }
//
//                                            return fileUrl;
//                                        }
//                                                                   completionHandler:
//                                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//
//                                            [SVProgressHUD dismiss];
//                                            NSLog(@"Filepath: %@", filePath.path);
//                                            self.retrievedResearchConsentImagePath = filePath.path;
//                                            if (error) {
//                                                NSLog(@"Error: %@", error);
//                                            } else {
//                                                //                                                NSLog(@"Success: %@ genodownloaded at: %@", response, [filePath absoluteString]);
//
//                                                NSDictionary *userInfo = NSDictionaryOfVariableBindings(response, filePath);
//
//                                                // send out notification!
//                                                [[NSNotificationCenter defaultCenter] postNotificationName:RESEARCH_CONSENT_LOADED_NOTIF
//                                                                                                    object:self
//                                                                                                  userInfo:userInfo];
//                                            }
//                                        }];
//
//    [dwlTsk resume];
//
//}


#pragma mark - Autorefractor Image
-(void)saveAutorefractorFormImage:(UIImage *) consentForm
                      forResident:(NSNumber *) residentID
                         withNric:(NSString *)nric {
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    
    // Save image.
    BOOL writeSuccess = [UIImagePNGRepresentation(consentForm) writeToFile:filePath atomically:YES];
    
    if(!writeSuccess)
        NSLog(@"error writing to file");
    
    //upload image to server
    NSURL *URL = [NSURL URLWithString:@"https://pd.homerehab.com.sg/uploadSeriAr"];
    
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    
    NSDictionary *input = @{@"resident_id": residentID, @"nric": nric};
    NSDictionary *data = @{@"data": input};
    
    //initialize upload manager (AFNetworking)
    self.uploadManager = [AFHTTPSessionManager manager];
    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    [self.uploadManager.operationQueue setMaxConcurrentOperationCount:2];
    self.uploadManager.securityPolicy.allowInvalidCertificates = NO;
    
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *req = [serializer multipartFormRequestWithMethod:@"POST"
                                                                URLString:[URL absoluteString]
                                                               parameters:data
                                                constructingBodyWithBlock:
                                ^(id<AFMultipartFormData>  _Nonnull formData) {
                                    [formData appendPartWithFileURL:filePathUrl name:@"userfile" error:nil];
                                }
                                                                    error:nil];
    
    NSURLSessionUploadTask *uploadTask = [self.uploadManager uploadTaskWithStreamedRequest:req
                                                                                  progress:[self uploadProgressBlock]
                                                                         completionHandler:[self completionBlock]];
    [uploadTask resume];
}

-(NSString *)getRetrievedAutorefractorFormImagePath{
    return [self.retrievedAutorefractorFormImagePath copy];
}

-(void)retrieveAutorefractorFormImageForResident:(NSNumber *) residentID
                                        withNric:(NSString *)nric {
    
    //setup input parameters
    NSDictionary *input = @{kResidentId: residentID, kNRIC:nric};
    NSDictionary *data = @{@"data": input};
    NSError *error;
    
    //prep download manager
    self.downloadManager = [AFHTTPSessionManager manager];
    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    self.downloadManager.securityPolicy.allowInvalidCertificates = NO;
    
    //send req
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *req = [serializer requestWithMethod:@"POST" URLString:@"https://pd.homerehab.com.sg/downloadSeriAr" parameters:data error:&error];
    
    NSURLSessionDownloadTask *dwlTsk = [self.downloadManager downloadTaskWithRequest:req
                                                                            progress:[self downloadSeriArProgressBlock]
                                                                         destination:
                                        ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                                  inDomain:NSUserDomainMask
                                                                                                         appropriateForURL:nil
                                                                                                                    create:NO
                                                                                                                     error:nil];
                                            
                                            NSURL *fileUrl = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                            
                                            /** Delete existing file if any! */
                                            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileUrl relativePath]];
                                            
                                            if (fileExists) {
                                                NSError *error;
                                                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[fileUrl relativePath] error:&error];
                                                
                                                if (success)
                                                    NSLog(@"Deleted existing file!");
                                                else
                                                    NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                                            }
                                            
                                            return fileUrl;
                                        }
                                                                   completionHandler:
                                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                            
                                            [SVProgressHUD dismiss];
                                            NSLog(@"Filepath: %@", filePath.path);
                                            self.retrievedAutorefractorFormImagePath = filePath.path;
                                            if (error) {
                                                NSLog(@"Error: %@", error);
                                            } else {
                                                //                                                NSLog(@"Success: %@ genodownloaded at: %@", response, [filePath absoluteString]);
                                                
                                                NSDictionary *userInfo = NSDictionaryOfVariableBindings(response, filePath);
                                                
                                                // send out notification!
                                                [[NSNotificationCenter defaultCenter] postNotificationName:AUTOREFRACTOR_LOADED_NOTIF
                                                                                                    object:self
                                                                                                  userInfo:userInfo];
                                            }
                                        }];
    
    [dwlTsk resume];
    
}

#pragma mark - PDF File
-(void)retrievePdfReportForResident:(NSNumber *) residentID {
    
    //setup input parameters
    NSDictionary *input = @{kResidentId: residentID};
    NSDictionary *data = @{@"data": input};
    NSError *error;
    
    //prep download manager
    self.downloadManager = [AFHTTPSessionManager manager];
    self.uploadManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    self.downloadManager.securityPolicy.allowInvalidCertificates = NO;
    
    //send req
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *req = [serializer requestWithMethod:@"POST" URLString:@"https://pd.homerehab.com.sg/1707" parameters:data error:&error];
    
    NSURLSessionDownloadTask *dwlTsk = [self.downloadManager downloadTaskWithRequest:req
                                                                            progress:nil
                                                                         destination:
                                        ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                                  inDomain:NSUserDomainMask
                                                                                                         appropriateForURL:nil
                                                                                                                    create:NO
                                                                                                                     error:nil];
                                            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                        }
                                                                   completionHandler:
                                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                            
                                            [SVProgressHUD dismiss];
                                            self.retrievedPdfReportFilepath = nil;  //remove the previous one first.
                                            self.retrievedPdfReportFilepath = filePath.path;
                                            if (error) {
                                                NSLog(@"Error: %@", error);
                                                [[NSNotificationCenter defaultCenter] postNotificationName:PDFREPORT_LOADED_NOTIF
                                                                                                    object:self
                                                                                                  userInfo:@{@"status":@"error"}];
                                            } else {
                                                //                                                NSLog(@"Success: %@ genodownloaded at: %@", response, [filePath absoluteString]);
                                                
                                                NSDictionary *userInfo = NSDictionaryOfVariableBindings(response, filePath);
                                                
                                                // send out notification!
                                                [[NSNotificationCenter defaultCenter] postNotificationName:PDFREPORT_LOADED_NOTIF
                                                                                                    object:self
                                                                                                  userInfo:userInfo];
                                            }
                                        }];
    
    [dwlTsk resume];
    
}

-(NSString *)getretrievedReportFilepath{
    return [self.retrievedPdfReportFilepath copy];
}

#pragma mark - Blocks

- (void (^)(NSProgress *uploadProgress))uploadProgressBlock {
    return ^(NSProgress *uploadProgress) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showProgress:uploadProgress.fractionCompleted status:@"Uploading..."];
    };
}

- (void (^)(NSProgress *downloadProgress))downloadGenogramProgressBlock {
    return ^(NSProgress *downloadProgress) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showProgress:downloadProgress.fractionCompleted status:@"Downloading Genogram..."];
    };
}

- (void (^)(NSProgress *downloadProgress))downloadConsentProgressBlock {
    return ^(NSProgress *downloadProgress) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showProgress:downloadProgress.fractionCompleted status:@"Downloading Consent Form..."];
    };
}

- (void (^)(NSProgress *downloadProgress))downloadResearchConsentProgressBlock {
    return ^(NSProgress *downloadProgress) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showProgress:downloadProgress.fractionCompleted status:@"Downloading Research Consent Form..."];
    };
}

- (void (^)(NSProgress *downloadProgress))downloadSeriArProgressBlock {
    return ^(NSProgress *downloadProgress) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showProgress:downloadProgress.fractionCompleted status:@"Downloading Autorefractor Form..."];
    };
}


- (void (^)(NSURLResponse *response, id responseObject, NSError *error))completionBlock {   //now that I'm not using it for genogram anymore, it's only for consent
    return ^(NSURLResponse *response, NSDictionary *responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD setMinimumDismissTimeInterval:1.0];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showErrorWithStatus:@"Upload failed!"];
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
            [SVProgressHUD setMinimumDismissTimeInterval:1.0];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showSuccessWithStatus:@"Upload successful!"];
            [[ResidentProfile sharedManager] setConsentImgExists:YES];
        }
    };
}

- (void (^)(NSURLResponse *response, id responseObject, NSError *error))researchCompletionBlock {   //now that I'm not using it for genogram anymore, it's only for consent
    return ^(NSURLResponse *response, NSDictionary *responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD setMinimumDismissTimeInterval:1.0];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showErrorWithStatus:@"Upload failed!"];
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
            [SVProgressHUD setMinimumDismissTimeInterval:1.0];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showSuccessWithStatus:@"Upload successful!"];
            [[ResidentProfile sharedManager] setResearchConsentImgExists:YES];
        }
    };
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

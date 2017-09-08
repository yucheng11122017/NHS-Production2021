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

//#define baseURL @"https://nus-nhs.ml/"        //for Development
#define baseURL @"https://nhs-som.nus.edu.sg/"
#define GENOGRAM_LOADED_NOTIF @"Genogram image downloaded"

@interface ServerComm ()

@property (strong, nonatomic) NSString *retrievedGenogramImagePath;


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

-(NSString *)getretrievedGenogramImagePath{
    return [self.retrievedGenogramImagePath copy];
}

-(void)retrieveGenogramImageForResident:(NSNumber *) residentID
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
    NSMutableURLRequest *req = [serializer requestWithMethod:@"POST" URLString:@"https://nhs-som.nus.edu.sg/downloadGenogram" parameters:data error:&error];
    
    NSURLSessionDownloadTask *dwlTsk = [self.downloadManager downloadTaskWithRequest:req
                                                                            progress:[self downloadProgressBlock]
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
                                            self.retrievedGenogramImagePath = filePath.path;
                                            if (error) {
                                                NSLog(@"Error: %@", error);
                                            } else {
//                                                NSLog(@"Success: %@ genodownloaded at: %@", response, [filePath absoluteString]);
                                                
                                                NSDictionary *userInfo = NSDictionaryOfVariableBindings(response, filePath);
                                                
                                                // send out notification!
                                                [[NSNotificationCenter defaultCenter] postNotificationName:GENOGRAM_LOADED_NOTIF
                                                                                                    object:self
                                                                                                  userInfo:userInfo];
                                            }
                                        }];
    
    [dwlTsk resume];
    
}

-(void)saveGenogram:(UIImage *)genogram forResident:(NSNumber *) residentID withNric:(NSString *)nric {
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    
    // Save image.
    BOOL writeSuccess = [UIImagePNGRepresentation(genogram) writeToFile:filePath atomically:YES];
    
    if(!writeSuccess)
        NSLog(@"error writing to file");
    
    //upload image to server
    NSURL *URL = [NSURL URLWithString:@"https://nhs-som.nus.edu.sg/uploadGenogram"];
    
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
#pragma mark - Blocks

- (void (^)(NSProgress *uploadProgress))uploadProgressBlock {
    return ^(NSProgress *uploadProgress) {
        [SVProgressHUD showProgress:uploadProgress.fractionCompleted status:@"Uploading..."];
    };
}

- (void (^)(NSProgress *downloadProgress))downloadProgressBlock {
    return ^(NSProgress *downloadProgress) {
        [SVProgressHUD showProgress:downloadProgress.fractionCompleted status:@"Downloading Genogram..."];
    };
}


- (void (^)(NSURLResponse *response, id responseObject, NSError *error))completionBlock {
    return ^(NSURLResponse *response, NSDictionary *responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD showErrorWithStatus:@"Upload failed!"];
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
            [SVProgressHUD showSuccessWithStatus:@"Upload successful!"];
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

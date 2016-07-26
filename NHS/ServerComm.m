//
//  ServerComm.m
//  NHS
//
//  Created by Nicholas on 7/25/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ServerComm.h"

#define baseURL @"https://nus-nhs.ml/"

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
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
        
    }
    
    return self;
}

#pragma mark - Patient

- (void)getPatient:(void (^)(NSProgress *downloadProgress))progressBlock
      successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
      andFailBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failBlock {
    
    NSInteger opCode = 51;
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    
    [self GET:[dict objectForKey:@"op_code"]
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
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[@(opCode) stringValue], @"op_code", nil];
    NSDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *param2 = [[NSMutableDictionary alloc] init];
    
    param = @{@"resident_id" : patientID};
    param2 = @{@"data": param};
    
    [self GET:[dict objectForKey:@"op_code"]
   parameters:param2
     progress:progressBlock
      success:successBlock
      failure:[self checkForBadHTTP:failBlock]];
}

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

//
//  FollowUpEntity.h
//  NHS
//
//  Created by Nicholas Wong on 9/27/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FollowUpEntity : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *date;
@property (nonatomic, copy, readonly) NSString *imageName;
@property (nonatomic, copy, readonly) NSString *id;
@property (nonatomic, copy, readonly) NSString *index;

@end

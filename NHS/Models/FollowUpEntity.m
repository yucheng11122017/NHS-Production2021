//
//  FollowUpEntity.m
//  NHS
//
//  Created by Nicholas Wong on 9/27/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "FollowUpEntity.h"

@implementation FollowUpEntity

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = super.init;
    if (self) {
        _identifier = [self uniqueIdentifier];
        _title = dictionary[@"title"];
        _content = dictionary[@"content"];
        _username = dictionary[@"username"];
        _date = dictionary[@"date"];
        _imageName = dictionary[@"imageName"];
    }
    return self;
}

- (NSString *)uniqueIdentifier
{
    static NSInteger counter = 0;
    return [NSString stringWithFormat:@"unique-id-%@", @(counter++)];
}


@end

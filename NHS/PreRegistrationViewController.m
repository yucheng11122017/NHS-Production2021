//
//  PreRegistrationViewController.m
//  NHS
//
//  Created by Nicholas on 23/7/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "PreRegistrationViewController.h"
#import "NSJSONSerialization+ANDYJSONFile.h"

@interface PreRegistrationViewController ()

@end


@implementation PreRegistrationViewController

@synthesize dataSource = _dataSource;

- (FORMDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    
    FORMLayout *layout = [FORMLayout new];
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"Pre-registration.json"];
    _dataSource = [[FORMDataSource alloc] initWithJSON:JSON
                                        collectionView:self.collectionView
                                                layout:layout
                                                values:nil
                                              disabled:NO];
    
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
}

@end


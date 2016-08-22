//
//  ScreeningSectionTableViewController.h
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreeningSectionTableViewController : UITableViewController


@property (strong, nonatomic) NSNumber* residentID;

- (void) setResidentID:(NSNumber *)residentID;


@end

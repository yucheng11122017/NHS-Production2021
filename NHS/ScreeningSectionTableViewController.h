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
@property (strong, nonatomic) NSNumber* residentLocalFileIndex;
@property (strong, nonatomic) NSMutableArray *completionCheck;


- (void) setResidentLocalFileIndex:(NSNumber *) residentLocalFileIndex;
- (void) setResidentID:(NSNumber *)residentID;
//- (void) updateChecklistWithRowNumber:(NSNumber*)row
//                   value:(NSNumber*)value;


@end

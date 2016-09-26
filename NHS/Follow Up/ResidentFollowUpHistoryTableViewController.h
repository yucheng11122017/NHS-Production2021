//
//  ResidentFollowUpHistoryTableViewController.h
//  NHS
//
//  Created by Nicholas Wong on 9/13/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResidentFollowUpHistoryTableViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *completeFollowUpHistory;
@property (strong, nonatomic) NSNumber *residentID;

- (void) setCompleteFollowUpHistory: (NSDictionary *) dictionary;
- (void) setResidentID: (NSNumber *) residentID;
@end

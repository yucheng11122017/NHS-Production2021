//
//  PatientScreeningListTableViewController.h
//  NHS
//
//  Created by Nicholas on 23/7/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientScreeningListTableViewController : UITableViewController

@property NSMutableArray *screeningResidents;
@property NSString *neighbourhood;

- (void) setNeighbourhood:(NSString *)neighbourhood;


@end

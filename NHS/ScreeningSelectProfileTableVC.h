//
//  SelectProfileTableVC.h
//  NHS
//
//  Created by Nicholas Wong on 8/3/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreeningSelectProfileTableVC : UITableViewController <UITableViewDelegate, UITableViewDataSource>



@property (strong, nonatomic) NSDictionary* residentDetails;

// Public Methods
- (void) setResidentDetails:(NSDictionary *)residentDetails;


@end

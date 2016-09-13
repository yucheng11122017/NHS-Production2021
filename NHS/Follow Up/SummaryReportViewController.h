//
//  SummaryReportViewController.h
//  NHS
//
//  Created by Nicholas Wong on 9/13/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryReportViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *fullScreeningForm;
@property (strong, nonatomic) NSDictionary *bloodTestResult;

- (void) setFullScreeningForm:(NSMutableDictionary *)fullScreeningForm;
- (void) setBloodTestResult: (NSDictionary *) dictionary;

@end

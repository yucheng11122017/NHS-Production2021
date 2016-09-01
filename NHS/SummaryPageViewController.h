//
//  SummaryPageViewController.h
//  NHS
//
//  Created by Nicholas Wong on 8/31/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryPageViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *fullScreeningForm;

- (void) setFullScreeningForm: (NSMutableDictionary *) dictionary;


@end

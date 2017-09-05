//
//  ScreeningFormViewController.h
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"

@interface ScreeningFormViewController : XLFormViewController <XLFormViewControllerDelegate>

@property (strong, nonatomic) NSNumber* sectionID;
@property (strong, nonatomic) NSNumber* formType;
@property (strong, nonatomic) NSDictionary *preRegParticularsDict;
@property (strong, nonatomic) NSMutableDictionary *fullScreeningForm;

- (void) setSectionID:(NSNumber *)sectionID;
- (void) setFormType:(NSNumber *)formType;
- (void) setFullScreeningForm: (NSMutableDictionary *) dictionary;


@end

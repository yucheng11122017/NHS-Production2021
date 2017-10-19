//
//  QuestionnaireFormVC.h
//  NHS
//
//  Created by Nicholas Wong on 10/19/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface QuestionnaireFormVC : XLFormViewController <XLFormViewControllerDelegate>

@property (strong, nonatomic) NSNumber* formNo;

- (void) setFormNo:(NSNumber *)formNo;

@end

//
//  ScreeningFormViewController.h
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"

@interface ScreeningFormViewController : XLFormViewController

@property (strong, nonatomic) NSNumber* sectionID;

- (void) setSectionID:(NSNumber *)sectionID;

@end

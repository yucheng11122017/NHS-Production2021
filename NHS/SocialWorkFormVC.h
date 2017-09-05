//
//  SocialWorkFormVC.h
//  NHS
//
//  Created by Nicholas Wong on 8/9/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "XLFormViewController.h"

@interface SocialWorkFormVC : XLFormViewController <XLFormDescriptorDelegate>


@property (strong, nonatomic) NSNumber* formNo;




// Public Methods
- (void) setFormNo:(NSNumber *)formNo;


@end

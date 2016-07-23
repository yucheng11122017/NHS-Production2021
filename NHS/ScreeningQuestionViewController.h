//
//  ScreeningQuestionViewController.h
//  NHS
//
//  Created by Nicholas on 23/7/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "FORMViewController.h"

@interface ScreeningQuestionViewController : FORMViewController


@property (strong, nonatomic) NSNumber* questionsFromSection;
@property (strong, nonatomic) NSString* JSONFilename;

- (void) setQuestionsFromSection:(NSNumber *)questionsFromSection;


@end


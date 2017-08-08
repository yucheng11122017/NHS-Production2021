//
//  HealthAssessAndRiskFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/8/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "HealthAssessAndRiskFormVC.h"
#import "ServerComm.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"

NSString *const kQ1 = @"q1";
NSString *const kQ2 = @"q2";
NSString *const kQ3 = @"q3";
NSString *const kQ4 = @"q4";
NSString *const kQ5 = @"q5";
NSString *const kQ6 = @"q6";
NSString *const kQ7 = @"q7";
NSString *const kQ8 = @"q8";
NSString *const kQ9 = @"q9";
NSString *const kQ10 = @"q10";
NSString *const kQ11 = @"q11";
NSString *const kQ12 = @"q12";
NSString *const kQ13 = @"q13";
NSString *const kQ14 = @"q14";
NSString *const kQ15 = @"q15";



@interface HealthAssessAndRiskFormVC ()



@end

@implementation HealthAssessAndRiskFormVC

- (void)viewDidLoad {
    
    XLFormViewController *form;
    
    //must init first before [super viewDidLoad]
    int formNumber = [_formID intValue];
    switch (formNumber) {
        case 0:
            form = [self initDiabetesMellitus];
            break;
        case 1:
            form = [self initHyperlipidemia];
            break;
        case 2:
            form = [self initHypertension];
            break;
        case 3:
            form = [self initGeriatricDepreAssess];
            break;
        case 4:
            form = [self initRiskStratifaction];
            NSLog(@"You're at the right place!");
            break;
        default:
            break;
    }
    
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id) initDiabetesMellitus {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    //    NSDictionary *diabetesDict = [self.fullScreeningForm objectForKey:@"diabetes"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Diabetes Mellitus"];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ1
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"1) (a) Has a western-trained doctor ever told you that you have diabetes? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasInformedRow.selectorOptions = @[@"YES", @"NO"];
    
    //value
    //    if (![[diabetesDict objectForKey:@"has_informed"] isEqualToString:@""]) {
    //        hasInformedRow.value = [[diabetesDict objectForKey:@"has_informed"] isEqualToString:@"1"]? @"YES":@"NO";
    //    }
    //
    hasInformedRow.required = YES;
    [section addFormRow:hasInformedRow];
    
    XLFormRowDescriptor *hasCheckedBloodQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ2
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"If no to (a), have you checked your blood sugar in the past 3 years?"];
    hasCheckedBloodQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasCheckedBloodQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformedRow];
    [section addFormRow:hasCheckedBloodQRow];
    
    XLFormRowDescriptor *hasCheckedBloodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMCheckedBlood rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    hasCheckedBloodRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"No"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Yes, 2 yrs ago"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Yes, 3 yrs ago"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Yes < 1 yr ago"]];
    hasCheckedBloodRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformedRow];
    
    //value
    //    NSArray *options = hasCheckedBloodRow.selectorOptions;
    //    if (![[diabetesDict objectForKey:@"checked_blood"]isEqualToString:@""]) {
    //        hasCheckedBloodRow.value = [options objectAtIndex:[[diabetesDict objectForKey:@"checked_blood"] integerValue]];
    //    }
    [section addFormRow:hasCheckedBloodRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you seeing your doctor regularly for your diabetes?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDMSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    //    if (![[diabetesDict objectForKey:@"seeing_doc_regularly"] isEqualToString:@""]) {
    //        row.value = [[diabetesDict objectForKey:@"seeing_doc_regularly"] isEqualToString:@"1"]? @"YES":@"NO";
    //    }
    
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you currently prescribed medication for your diabetes?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDMCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    //    if (![[diabetesDict objectForKey:@"currently_prescribed"] isEqualToString:@""]) {
    //        row.value = [[diabetesDict objectForKey:@"currently_prescribed"] isEqualToString:@"1"]? @"YES":@"NO";
    //    }
    
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ5
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you taking your diabetes meds regularly? (≥ 90% of time)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    // Segmented Control
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDMTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    //    if (![[diabetesDict objectForKey:@"taking_regularly"] isEqualToString:@""]) {
    //        row.value = [[diabetesDict objectForKey:@"taking_regularly"] isEqualToString:@"1"]? @"YES":@"NO";
    //    }
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initHyperlipidemia {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    //    NSDictionary *diabetesDict = [self.fullScreeningForm objectForKey:@"diabetes"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Hyperlipidemia - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Hyperlipidemia"];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ6
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Has a western-trained doctor ever told you that you have high cholesterol? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformed = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasInformed.selectorOptions = @[@"YES", @"NO"];
    hasInformed.required = YES;
    
    //value
    //    if (![[hyperlipidDict objectForKey:@"has_informed"] isEqualToString:@""]) {
    //        hasInformed.value = [[hyperlipidDict objectForKey:@"has_informed"] isEqualToString:@"1"]? @"YES":@"NO";
    //    }
    
    [section addFormRow:hasInformed];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ7
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you checked your blood cholesterol in the past 3 years?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCheckedBlood
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"No"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Yes"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Yes, 3 yrs ago"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Yes, < 1 yr ago"]];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed];
    
    //value
    //    NSArray *options = row.selectorOptions;
    //    if (![[hyperlipidDict objectForKey:@"checked_blood"]isEqualToString:@""]) {
    //        row.value = [options objectAtIndex:[[hyperlipidDict objectForKey:@"checked_blood"] integerValue]];
    //    }
    
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ8
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you seeing your doctor regularly? (regular = every 6 mths or less, or as per doctor scheduled to follow up)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    //    if (![[hyperlipidDict objectForKey:@"seeing_doc_regularly"] isEqualToString:@""]) {
    //        row.value = [[hyperlipidDict objectForKey:@"seeing_doc_regularly"] isEqualToString:@"1"]? @"YES":@"NO";
    //    }
    
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ9
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you curently prescribed medication for your high cholesterol?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    XLFormRowDescriptor *prescribed = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    prescribed.selectorOptions = @[@"YES", @"NO"];
    prescribed.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    
    //value
    //    if (![[hyperlipidDict objectForKey:@"currently_prescribed"] isEqualToString:@""]) {
    //        prescribed.value = [[hyperlipidDict objectForKey:@"currently_prescribed"] isEqualToString:@"1"]? @"YES":@"NO";
    //    }
    
    [section addFormRow:prescribed];
    
    XLFormRowDescriptor *takeRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ10
                                                                                   rowType:XLFormRowDescriptorTypeInfo
                                                                                     title:@"Are you taking your cholesterol medication regularly?"];
    takeRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    takeRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribed];
    [section addFormRow:takeRegularlyQRow];
    
    // Segmented Control
    XLFormRowDescriptor *takeRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    takeRegularlyRow.selectorOptions = @[@"YES", @"NO"];
    
    //value
    //    if (![[hyperlipidDict objectForKey:@"taking_regularly"] isEqualToString:@""]) {
    //        takeRegularlyRow.value = [[hyperlipidDict objectForKey:@"taking_regularly"] isEqualToString:@"1"]? @"YES":@"NO";
    //    }
    takeRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribed];
    
    [section addFormRow:takeRegularlyRow];
    
    
    hasInformed.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqualToString:@"NO"]) {
                takeRegularlyQRow.hidden = @(1);
                takeRegularlyRow.hidden = @(1);
            } else {
                if ([prescribed.value isEqualToString:@"YES"]) {
                    takeRegularlyQRow.hidden = @(0);
                    takeRegularlyRow.hidden = @(0);
                }
            }
        }
    };
    
    prescribed.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqualToString:@"YES"]) {
                takeRegularlyQRow.hidden = @(0);
                takeRegularlyRow.hidden = @(0);
            } else {
                takeRegularlyQRow.hidden = @(1);
                takeRegularlyRow.hidden = @(1);
            }
        }
    };
    return [super initWithForm:formDescriptor];
}


-(id) initHypertension {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
//    NSDictionary *hypertensionDict = [self.fullScreeningForm objectForKey:@"hypertension"];
    
    // Hypertension - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Hypertension"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ1
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Has a western-trained doctor ever told you that you have high BP? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformed_HT = [XLFormRowDescriptor formRowDescriptorWithTag:kHTHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasInformed_HT.selectorOptions = @[@"YES", @"NO"];
    hasInformed_HT.required = YES;

    //value
//    if (![[hypertensionDict objectForKey:@"has_informed"] isEqualToString:@""]) {
//        hasInformed_HT.value = [[hypertensionDict objectForKey:@"has_informed"] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    [section addFormRow:hasInformed_HT];

    XLFormRowDescriptor *checkedBPQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ2
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you checked your BP in the last 1 year?"];
    checkedBPQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    checkedBPQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed_HT];
    [section addFormRow:checkedBPQRow];

    XLFormRowDescriptor *checkedBP = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCheckedBp rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    checkedBP.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[hypertensionDict objectForKey:@"checked_bp"] isEqualToString:@""]) {
//        checkedBP.value = [[hypertensionDict objectForKey:@"checked_bp"] isEqualToString:@"1"]? @"YES":@"NO";
//    }
//    checkedBP.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed_HT];
    [section addFormRow:checkedBP];


    XLFormRowDescriptor *seeDocRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you seeing your doctor regularly for your high BP?"];
    seeDocRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    seeDocRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:seeDocRegularlyQRow];
    XLFormRowDescriptor *seeDocRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    seeDocRegularlyRow.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[hypertensionDict objectForKey:@"seeing_doc_regularly"] isEqualToString:@""]) {
//        seeDocRegularlyRow.value = [[hypertensionDict objectForKey:@"seeing_doc_regularly"] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    seeDocRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:seeDocRegularlyRow];


    XLFormRowDescriptor *prescribedQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you curently prescribed medication for your high BP?"];
    prescribedQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    prescribedQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:prescribedQRow];

    XLFormRowDescriptor *prescribedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    prescribedRow.selectorOptions = @[@"YES", @"NO"];
    prescribedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];

    //value
//    if (![[hypertensionDict objectForKey:@"currently_prescribed"] isEqualToString:@""]) {
//        prescribedRow.value = [[hypertensionDict objectForKey:@"currently_prescribed"] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    [section addFormRow:prescribedRow];

    XLFormRowDescriptor *takeRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ5
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you taking your BP medication regularly?"];
    takeRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    takeRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:takeRegularlyQRow];

    // Segmented Control
    XLFormRowDescriptor *takeRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    takeRegularlyRow.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[hypertensionDict objectForKey:@"taking_regularly"] isEqualToString:@""]) {
//        takeRegularlyRow.value = [[hypertensionDict objectForKey:@"taking_regularly"] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    takeRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:takeRegularlyRow];

    checkedBP.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqualToString:@"NO"]) {
                takeRegularlyQRow.hidden = @(1);
                takeRegularlyRow.hidden = @(1);
            } else {
//                if ([prescribedRow.value isEqualToString:@"YES"]) {
                    takeRegularlyQRow.hidden = @(0);
                    takeRegularlyRow.hidden = @(0);
//                }
            }
        }
    };

//    prescribedRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([newValue isEqualToString:@"YES"]) {
//                takeRegularlyQRow.hidden = @(0);
//                takeRegularlyRow.hidden = @(0);
//            } else {
//                takeRegularlyQRow.hidden = @(1);
//                takeRegularlyRow.hidden = @(1);
//            }
//        }
//    };

    return [super initWithForm:formDescriptor];
}

- (id) initGeriatricDepreAssess {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Geriatric Depression Assessment"];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ1
                                                rowType:XLFormRowDescriptorTypeStepCounter
                                                  title:@"Score for PHQ-2 question 1"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@YES forKey:@"stepControl.wraps"];
    [row.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
    [row.cellConfigAtConfigure setObject:@0 forKey:@"stepControl.minimumValue"];
    [row.cellConfigAtConfigure setObject:@3 forKey:@"stepControl.maximumValue"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ2
                                                rowType:XLFormRowDescriptorTypeStepCounter
                                                  title:@"Score for PHQ-2 question 2"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@YES forKey:@"stepControl.wraps"];
    [row.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
    [row.cellConfigAtConfigure setObject:@0 forKey:@"stepControl.minimumValue"];
    [row.cellConfigAtConfigure setObject:@3 forKey:@"stepControl.maximumValue"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhq9Score
                                                rowType:XLFormRowDescriptorTypeNumber
                                                  title:@"Total score for PHQ-9 field"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUpReq
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"Does resident require further follow up?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

-(id) initRiskStratifaction {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Risk Stratification"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabeticFriend
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"Do you have a first degree relative with diabetes mellitus?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDelivered4kgOrGestational
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"Have you delivered a baby 4 kg or more; or were previously diagnosed with gestational diabetes mellitus?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCardioHistory
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"Do you have a history of cardiovascular disease (heart/vascular problems e.g. angina, myocardial infarction, aneurysms)?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmoke
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"Do you smoke?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.required = YES;
    [section addFormRow:row];


    
    return [super initWithForm:formDescriptor];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  HealthAssessAndRiskFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/8/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "HealthAssessAndRiskFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "KAStatusBar.h"
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



@interface HealthAssessAndRiskFormVC () {
    BOOL internetDCed;
    BOOL firstDataFetch;
}

@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSNumber *residentID;

@end

@implementation HealthAssessAndRiskFormVC

- (void)viewDidLoad {

    internetDCed = false;
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
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
            form = [self initRiskStratification];
            break;
        default:
            break;
    }
    [self.form setAddAsteriskToRequiredRowsTitle:NO];
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
    NSDictionary *diabetesDict = [self.fullScreeningForm objectForKey:SECTION_DIABETES];
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Diabetes Mellitus"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ1
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"1) (a) Has a western-trained doctor ever told you that you have diabetes? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasInformedRow.selectorOptions = @[@"YES", @"NO"];
    
    hasInformedRow.required = YES;
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        hasInformedRow.value = [self getYesNoFromOneZero:diabetesDict[kHasInformed]];
    }
    
    [section addFormRow:hasInformedRow];
    
    XLFormRowDescriptor *hasCheckedBloodQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ2
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"If no to (a), have you checked your blood sugar in the past 3 years?"];
    [self setDefaultFontWithRow:hasCheckedBloodQRow];
    hasCheckedBloodQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasCheckedBloodQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformedRow];
    [section addFormRow:hasCheckedBloodQRow];
    
    XLFormRowDescriptor *hasCheckedBloodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMCheckedBlood rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    hasCheckedBloodRow.selectorOptions = @[@"No",@"Yes, 2 yrs ago",@"Yes, 3 yrs ago",@"Yes < 1 yr ago"];
    hasCheckedBloodRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformedRow];
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kCheckedBlood] != (id)[NSNull null]) {
        hasCheckedBloodRow.value = diabetesDict[kCheckedBlood];
    }
    [section addFormRow:hasCheckedBloodRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you seeing your doctor regularly for your diabetes?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDMSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:diabetesDict[kSeeingDocRegularly]];
    }
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you currently prescribed medication for your diabetes?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDMCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kCurrentlyPrescribed] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:diabetesDict[kCurrentlyPrescribed]];
    }
    
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ5
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you taking your diabetes meds regularly? (≥ 90% of time)"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    // Segmented Control
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDMTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kTakingRegularly] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:diabetesDict[kTakingRegularly]];
    }
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initHyperlipidemia {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *hyperlipidDict = [self.fullScreeningForm objectForKey:SECTION_HYPERLIPIDEMIA];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Hyperlipidemia - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Hyperlipidemia"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ6
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Has a western-trained doctor ever told you that you have high cholesterol? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformed = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:hasInformed];
    hasInformed.selectorOptions = @[@"YES", @"NO"];
    hasInformed.required = YES;
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        hasInformed.value = [self getYesNoFromOneZero:hyperlipidDict[kHasInformed]];
    }
    
    [section addFormRow:hasInformed];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ7
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you checked your blood cholesterol in the past 3 years?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCheckedBlood
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[@"No",
                            @"Yes, 2 yrs ago",
                            @"Yes, 3 yrs ago",
                            @"Yes < 1 yr ago"];

    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kCheckedBlood] != (id)[NSNull null]) {
        row.value = hyperlipidDict[kCheckedBlood];
    }
    
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ8
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you seeing your doctor regularly? (regular = every 6 mths or less, or as per doctor scheduled to follow up)"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:hyperlipidDict[kSeeingDocRegularly]];
    }
    
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ9
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you curently prescribed medication for your high cholesterol?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    XLFormRowDescriptor *prescribed = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    prescribed.selectorOptions = @[@"YES", @"NO"];
    prescribed.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kCurrentlyPrescribed] != (id)[NSNull null]) {
        prescribed.value = [self getYesNoFromOneZero:hyperlipidDict[kCurrentlyPrescribed]];
    }
    
    [section addFormRow:prescribed];
    
    XLFormRowDescriptor *takeRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ10
                                                                                   rowType:XLFormRowDescriptorTypeInfo
                                                                                     title:@"Are you taking your cholesterol medication regularly?"];
    [self setDefaultFontWithRow:takeRegularlyQRow];
    takeRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    takeRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribed];
    [section addFormRow:takeRegularlyQRow];
    
    // Segmented Control
    XLFormRowDescriptor *takeRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:row];
    takeRegularlyRow.selectorOptions = @[@"YES", @"NO"];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kTakingRegularly] != (id)[NSNull null]) {
        takeRegularlyRow.value = [self getYesNoFromOneZero:hyperlipidDict[kTakingRegularly]];
    }
    
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
    
    NSDictionary *hypertensionDict = [self.fullScreeningForm objectForKey:SECTION_HYPERTENSION];
    
    // Hypertension - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Hypertension"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ1
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Has a western-trained doctor ever told you that you have high BP? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformed_HT = [XLFormRowDescriptor formRowDescriptorWithTag:kHTHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:row];
    hasInformed_HT.selectorOptions = @[@"YES", @"NO"];
    hasInformed_HT.required = YES;

    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        hasInformed_HT.value = [self getYesNoFromOneZero:hypertensionDict[kHasInformed]];
    }

    [section addFormRow:hasInformed_HT];

    XLFormRowDescriptor *checkedBPQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ2
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you checked your BP in the last 1 year?"];
    [self setDefaultFontWithRow:checkedBPQRow];
    checkedBPQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    checkedBPQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed_HT];
    [section addFormRow:checkedBPQRow];

    XLFormRowDescriptor *checkedBP = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCheckedBp rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:checkedBP];
    checkedBP.selectorOptions = @[@"YES", @"NO"];

    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kCheckedBp] != (id)[NSNull null]) {
        checkedBP.value = [self getYesNoFromOneZero:hypertensionDict[kCheckedBp]];
    }
    [section addFormRow:checkedBP];


    XLFormRowDescriptor *seeDocRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you seeing your doctor regularly for your high BP?"];
    [self setDefaultFontWithRow:seeDocRegularlyQRow];
    seeDocRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    seeDocRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:seeDocRegularlyQRow];
    XLFormRowDescriptor *seeDocRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    seeDocRegularlyRow.selectorOptions = @[@"YES", @"NO"];

    //value
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        seeDocRegularlyRow.value = [self getYesNoFromOneZero:hypertensionDict[kSeeingDocRegularly]];
    }

    seeDocRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:seeDocRegularlyRow];


    XLFormRowDescriptor *prescribedQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you curently prescribed medication for your high BP?"];
    [self setDefaultFontWithRow:prescribedQRow];
    prescribedQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    prescribedQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:prescribedQRow];

    XLFormRowDescriptor *prescribedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:prescribedRow];
    prescribedRow.selectorOptions = @[@"YES", @"NO"];
    prescribedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];

    //value
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kHTCurrentlyPrescribed] != (id)[NSNull null]) {
        prescribedRow.value = [self getYesNoFromOneZero:hypertensionDict[kCurrentlyPrescribed]];
    }


    [section addFormRow:prescribedRow];

    XLFormRowDescriptor *takeRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ5
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you taking your BP medication regularly?"];
    [self setDefaultFontWithRow:takeRegularlyQRow];
    takeRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    takeRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:takeRegularlyQRow];

    // Segmented Control
    XLFormRowDescriptor *takeRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:takeRegularlyRow];
    takeRegularlyRow.selectorOptions = @[@"YES", @"NO"];

    //value
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kHTTakingRegularly] != (id)[NSNull null]) {
        takeRegularlyRow.value = [self getYesNoFromOneZero:hypertensionDict[kTakingRegularly]];
    }

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


    return [super initWithForm:formDescriptor];
}

- (id) initGeriatricDepreAssess {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Geriatric Depression Assessment"];
    [formDescriptor addFormSection:section];
    
    NSDictionary *geriaDepreAssmtDict = [self.fullScreeningForm objectForKey:SECTION_DEPRESSION];
    
    
    XLFormRowDescriptor* phqQ1Row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ1
                                                rowType:XLFormRowDescriptorTypeStepCounter
                                                  title:@"PHQ-2 question 1 Score"];
    [self setDefaultFontWithRow:phqQ1Row];
    phqQ1Row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [phqQ1Row.cellConfigAtConfigure setObject:@YES forKey:@"stepControl.wraps"];
    [phqQ1Row.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
    [phqQ1Row.cellConfigAtConfigure setObject:@0 forKey:@"stepControl.minimumValue"];
    [phqQ1Row.cellConfigAtConfigure setObject:@3 forKey:@"stepControl.maximumValue"];
    
    //value
    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ1] != (id)[NSNull null]) {
        phqQ1Row.value = geriaDepreAssmtDict[kPhqQ1];
    }
    
    [section addFormRow:phqQ1Row];

    XLFormRowDescriptor* phqQ2Row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ2
                                                rowType:XLFormRowDescriptorTypeStepCounter
                                                  title:@"PHQ-2 question 2 Score"];
    [self setDefaultFontWithRow:phqQ2Row];
    phqQ2Row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [phqQ2Row.cellConfigAtConfigure setObject:@YES forKey:@"stepControl.wraps"];
    [phqQ2Row.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
    [phqQ2Row.cellConfigAtConfigure setObject:@0 forKey:@"stepControl.minimumValue"];
    [phqQ2Row.cellConfigAtConfigure setObject:@3 forKey:@"stepControl.maximumValue"];
    
    //value
    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ2] != (id)[NSNull null]) {
        phqQ2Row.value = geriaDepreAssmtDict[kPhqQ2];
    }
    
    [section addFormRow:phqQ2Row];

    XLFormRowDescriptor* phq9ScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhq9Score
                                                rowType:XLFormRowDescriptorTypeNumber
                                                  title:@"Total score for PHQ-9"];
    [self setDefaultFontWithRow:phq9ScoreRow];
    phq9ScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    phq9ScoreRow.disabled = @(1);
    
    //value
    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhq9Score] != (id)[NSNull null]) {
        phq9ScoreRow.value = geriaDepreAssmtDict[kPhq9Score];
    }
    
    [section addFormRow:phq9ScoreRow];
    
    phqQ1Row.onChangeBlock= ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue intValue] > 1) phq9ScoreRow.disabled = @(0);
            else {
                if ([phqQ2Row.value intValue] < 2) {
                    phq9ScoreRow.disabled = @(1);
                }
            }
            [self reloadFormRow:phq9ScoreRow];
        }
    };
    
    phqQ2Row.onChangeBlock= ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue intValue] > 1) phq9ScoreRow.disabled = @(0);
            else {
                if ([phqQ1Row.value intValue] < 2) {
                    phq9ScoreRow.disabled = @(1);
                }
            }
            [self reloadFormRow:phq9ScoreRow];
        }
    };

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUpReq
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"Does resident require further follow up?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kFollowUpReq] != (id)[NSNull null]) {
        row.value = geriaDepreAssmtDict[kFollowUpReq];
    }
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

-(id) initRiskStratification {
    
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Risk Stratification"];
    [formDescriptor addFormSection:section];
    
    NSDictionary *riskStratDict = [self.fullScreeningForm objectForKey:SECTION_RISK_STRATIFICATION];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabeticFriend
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Do you have a first degree relative with diabetes mellitus? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"YES", @"NO"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kDiabeticFriend] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kDiabeticFriend]];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDelivered4kgOrGestational
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Have you delivered a baby 4 kg or more; or were previously diagnosed with gestational diabetes mellitus? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"YES", @"NO"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kDelivered4kgOrGestational] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kDelivered4kgOrGestational]];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHeartAttack
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Have you ever suffered from a \"heart attack\" or been told by your doctor that you have coronary heart disease (heart disease caused by narrowed blood vessels supplying the heart muscle)? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"YES", @"NO"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kHeartAttack] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kHeartAttack]];
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kStroke
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Have you ever been diagnosed by your doctor to have a stroke? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"YES", @"NO"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kStroke] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kStroke]];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAneurysm
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Has your doctor told you that the blood vessels to your limbs are diseased and have become narrower (peripheral artery disease) or that any other major blood vessels in your body have weakened walls that have “ballooned out” (aneurysm)? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"YES", @"NO"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kAneurysm] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kAneurysm]];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKidneyDisease
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Has your doctor told you that the blood vessels to your limbs are diseased and have become narrower (peripheral artery disease) or that any other major blood vessels in your body have weakened walls that have “ballooned out” (aneurysm)? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"YES", @"NO"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kKidneyDisease] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kKidneyDisease]];
    }
    
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmoke
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Do you smoke? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"YES", @"NO"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kSmoke] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kSmoke]];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokeYes
                                                rowType:XLFormRowDescriptorTypeSelectorPush
                                                  title:@"Choose one only"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"at least 1 cigarette (or equivalent) per day on average",
                            @"less than 1 cigarette (or equivalent) per day on average"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kSmokeYes] != (id)[NSNull null]) {
        row.value = riskStratDict[kSmokeYes];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokeNo
                                                rowType:XLFormRowDescriptorTypeSelectorPush
                                                  title:@"Choose one only"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"I have stopped smoking completely",
                            @"I have never smoked before"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kSmokeNo] != (id)[NSNull null]) {
        row.value = riskStratDict[kSmokeNo];
    }
    
    [section addFormRow:row];

    return [super initWithForm:formDescriptor];
}


#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    NSString* ansFromYesNo;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"YES"])
            ansFromYesNo = @"1";
        else if ([newValue isEqualToString:@"NO"])
            ansFromYesNo = @"0";
    }
    
    /* Diabetes Mellitus */
    
    if ([rowDescriptor.tag isEqualToString:kDMHasInformed]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kHasInformed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kDMCheckedBlood]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kCheckedBlood andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDMSeeingDocRegularly]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kSeeingDocRegularly andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kDMCurrentlyPrescribed]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kCurrentlyPrescribed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kDMTakingRegularly]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kTakingRegularly andNewContent:ansFromYesNo];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kLipidHasInformed]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kHasInformed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kLipidCheckedBlood]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kCheckedBlood andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kLipidSeeingDocRegularly]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kSeeingDocRegularly andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kLipidCurrentlyPrescribed]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kCurrentlyPrescribed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kLipidTakingRegularly]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kTakingRegularly andNewContent:ansFromYesNo];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kHTHasInformed]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kHasInformed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHTCheckedBp]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kCheckedBp andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHTSeeingDocRegularly]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kSeeingDocRegularly andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHTCurrentlyPrescribed]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kCurrentlyPrescribed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHTTakingRegularly]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kTakingRegularly andNewContent:ansFromYesNo];
    }
    
    /* Geriatric Dementia Assessment */
    else if ([rowDescriptor.tag isEqualToString:kPhqQ1]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhqQ1 andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ2]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhqQ2 andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPhq9Score]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhq9Score andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kFollowUpReq]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kFollowUpReq andNewContent:newValue];
    }
    
    
    /* Risk Stratification */
    else if ([rowDescriptor.tag isEqualToString:kDiabeticFriend]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kDiabeticFriend andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kDelivered4kgOrGestational]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kDelivered4kgOrGestational andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kSmoke]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kSmoke andNewContent:ansFromYesNo];
    }
    
    
}

-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {    //works great for textField and textView
    
    //Check for validation first!
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0) {
        
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            
            if ([validationStatus.rowDescriptor isEqual:rowDescriptor]) {
                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
                cell.backgroundColor = [UIColor orangeColor];
                [UIView animateWithDuration:0.3 animations:^{
                    cell.backgroundColor = [UIColor whiteColor];
                }];
                [self showFormValidationError:[validationErrors objectAtIndex:idx]];    //only show error if it's this specific row
                return;
            }
        }];
    }
    
//    /* Phlebotomy */
//    if ([rowDescriptor.tag isEqualToString:kFastingBloodGlucose]) {
//        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY andFieldName:kFastingBloodGlucose andNewContent:rowDescriptor.value];
//    }
}

    
#pragma mark - Reachability
/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        switch (netStatus) {
            case NotReachable: {
                internetDCed = true;
                NSLog(@"Can't connect to server!");
                [self.form setDisabled:YES];
                [self.tableView reloadData];
                [self.tableView endEditing:YES];
                [SVProgressHUD setMaximumDismissTimeInterval:2.0];
                [SVProgressHUD showErrorWithStatus:@"No Internet!"];
                
                
                break;
            }
            case ReachableViaWiFi:
            case ReachableViaWWAN:
                NSLog(@"Connected to server!");
                [self.form setDisabled:NO];
                [self.tableView reloadData];
                
                if (internetDCed) { //previously disconnected
                    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
                    [SVProgressHUD showSuccessWithStatus:@"Back Online!"];
                    internetDCed = false;
                }
                break;
                
            default:
                break;
        }
    }
    
}


#pragma mark - Post data to server methods

- (void) postSingleFieldWithSection:(NSString *) section andFieldName: (NSString *) fieldName andNewContent: (NSString *) content {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    if ((content != (id)[NSNull null]) && (content != nil)) {   //make sure don't insert nil or null value to a dictionary
        
        NSDictionary *dict = @{kResidentId:resident_id,
                               kSectionName:section,
                               kFieldName:fieldName,
                               kNewContent:content
                               };
        
        NSLog(@"Uploading %@ for $%@$ field", content, fieldName);
        [KAStatusBar showWithStatus:@"Syncing..." andBarColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:0 alpha:1.0]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [_pushPopTaskArray addObject:dict];
        
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postDataGivenSectionAndFieldName:dict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
    }
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        
        [_pushPopTaskArray removeObjectAtIndex:0];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
        
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"<<< SUBMISSION FAILED >>>");
        
        NSDictionary *retryDict = [_pushPopTaskArray firstObject];
        
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSLog(@"error: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
        
        
        NSLog(@"\n\nRETRYING...");
        
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postDataGivenSectionAndFieldName:retryDict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
    
    };
}

- (NSString *) getYesNoFromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"])
            return @"YES";
        else if ([value isEqualToString:@"0"])
            return @"NO";
        
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1])
            return @"YES";
        else if ([value isEqual:@0])
            return @"NO";
        
    }
    return @"";
}

#pragma mark - UIFont methods
- (void) setDefaultFontWithRow: (XLFormRowDescriptor *) row {
    UIFont *font = [UIFont fontWithName:DEFAULT_FONT_NAME size:DEFAULT_FONT_SIZE];
    UIFont *boldedFont = [self boldFontWithFont:font];
    [row.cellConfig setObject:boldedFont forKey:@"textLabel.font"];
}

- (UIFont *)boldFontWithFont:(UIFont *)font
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

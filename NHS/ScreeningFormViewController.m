//
//  ScreeningFormViewController.m
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ScreeningFormViewController.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "KAStatusBar.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"
#import "ScreeningDictionary.h"
#import "ResidentProfile.h"

//XLForms stuffs
#import "XLForm.h"


typedef enum rowTypes {
    Text,
    YesNo,
    TextView,
    Checkbox,
    SelectorPush,
    SelectorActionSheet,
    SegmentedControl,
    Number,
    Switch,
    YesNoNA
} rowTypes;


typedef enum formName {
    Triage,
    Phleb,
    Profiling,
    BasicVision,
    AdvGer,
    FallRiskAssess,
    Dental,
    Hearing,
    AdvVision,
    EmerSvcs,
    AddSvcs,
    SocialWk,
    SummaryNHealthEdu
} formName;


NSString *const kQuestionOne = @"q1";
NSString *const kQuestionTwo = @"q2";
NSString *const kQuestionThree = @"q3";
NSString *const kQuestionFour = @"q4";
NSString *const kQuestionFive = @"q5";
NSString *const kQuestionSix = @"q6";
NSString *const kQuestionSeven = @"q7";
NSString *const kQuestionEight = @"q8";
NSString *const kQuestionNine = @"q9";
NSString *const kQuestionTen = @"q10";
NSString *const kQuestionEleven = @"q11";
NSString *const kQuestionTwelve = @"q12";
NSString *const kQuestionThirteen = @"q13";
NSString *const kQuestionFourteen = @"q14";
NSString *const kQuestionFifteen = @"q15";

@interface ScreeningFormViewController () {
    NSString *gender;
    NSArray *spoken_lang_value;
    XLFormRowDescriptor *preEdScoreRow, *postEdScoreRow, *showPostEdSectionBtnRow, *phqTotalScoreRow, *spbbScoreRow, *fallRiskRow;
    XLFormRowDescriptor *systolic_1, *diastolic_1, *systolic_2, *diastolic_2, *systolic_3, *diastolic_3, *systolic_avg, *diastolic_avg;
    XLFormSectionDescriptor *preEdSection, *postEdSection;
    NSString *neighbourhood, *citizenship;
    NSNumber *age;
    BOOL noChas, lowIncome, wantChas;
    BOOL age40, chronicCond_noBloodTest, wantFreeBt; //for phleb
    BOOL sporeanPr, age50, relColorectCancer, colon3Yrs, wantColRef, disableFIT;
    BOOL age65, feelFall, scaredFall, fallen12Mths;
    BOOL internetDCed;
    BOOL isFormFinalized;
    BOOL tableDidEndEditing;
}

@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSMutableDictionary *fullScreeningForm;
@property (strong, nonatomic) NSMutableArray *phqQuestionsArray;


@end

@implementation ScreeningFormViewController

- (void)viewDidLoad {
    
    isFormFinalized = false;    //by default
    
    XLFormViewController *form;

    citizenship = [[NSUserDefaults standardUserDefaults]
                            stringForKey:kCitizenship];
    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                             stringForKey:kResidentAge];
    gender = [[NSUserDefaults standardUserDefaults]
              stringForKey:kGender];
    neighbourhood = [[NSUserDefaults standardUserDefaults]
              stringForKey:kNeighbourhood];
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    _fullScreeningForm = [[NSMutableDictionary alloc] initWithDictionary:[[[ScreeningDictionary sharedInstance] dictionary] mutableCopy]];
    
    internetDCed = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    //must init first before [super viewDidLoad]
    switch([self.sectionID integerValue]) {
        
        case Triage: form = [self initTriage];
            break;
//        case Phleb: form = [self initPhlebotomy];
//            break;
        case Dental: form = [self initDentalCheckup];
            break;
//        case Hearing: form = [self initHearing];
//            break;
//        case 2: form = [self initProfiling];
//            break;
//        case 3: form = [self initGeriaDepressAssess];
//            hasShownDepressAlertBox = false;
//            break;
        case FallRiskAssess: form = [self initPhysioNotes];
            break;
        case BasicVision: form = [self initSnellenEyeTest];
            break;
        case EmerSvcs: form = [self initEmergencySvcs];
            break;
        case AddSvcs: form = [self initAdditionalSvcs];
            break;
        
        
//        case 11: form = [self initFallRiskAssessment];
//            break;
//        case 12: form = [self initDementiaAssessment];
//            break;
        case SummaryNHealthEdu: form = [self initSummaryAndHealthEdu];
            break;
    }
    
    tableDidEndEditing = false;
    self.form.addAsteriskToRequiredRowsTitle = YES;
    
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    
    if (isFormFinalized) {
        if ([self.sectionID integerValue] != SummaryNHealthEdu) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        }
        [self.form setDisabled:YES];
        [self.tableView endEditing:YES];    //to really disable the table
        [self.tableView reloadData];
    }
    else {
        [self.form setDisabled:NO];
        [self.tableView reloadData];
        if ([self.sectionID integerValue] != SummaryNHealthEdu) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finalize" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeBtnPressed:)];
        }
    }
    
    [super viewDidLoad];
    
}

- (void) viewWillDisappear:(BOOL)animated {
//    [self saveEntriesIntoDictionary];
    [KAStatusBar dismiss];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    NSMutableDictionary *completionCheckUserInfo = [[NSMutableDictionary alloc] init];
    [completionCheckUserInfo setObject:self.sectionID forKey:@"section"];
    //Do a quick validation!
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [completionCheckUserInfo setObject:@0 forKey:@"value"];
    } else {
        [completionCheckUserInfo setObject:@1 forKey:@"value"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCompletionCheck"
                                                        object:nil
                                                      userInfo:completionCheckUserInfo];
    
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Forms methods
- (id) initTriage {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Triage"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *triageDict = [self.fullScreeningForm objectForKey:SECTION_CLINICAL_RESULTS];

    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckClinicalResults];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *diabeticRow = [XLFormRowDescriptor formRowDescriptorWithTag:kIsDiabetic rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is resident diabetic?"];
    diabeticRow.selectorOptions = @[@"Yes", @"No"];
    diabeticRow.required = YES;
    [self setDefaultFontWithRow:diabeticRow];
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kIsDiabetic] != (id)[NSNull null])
        diabeticRow.value = [self getYesNofromOneZero:triageDict[kIsDiabetic]];
    
    [section addFormRow:diabeticRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCbg rowType:XLFormRowDescriptorTypeDecimal title:@"CBG (mmol/L)"];
    row.required = NO;
    
    NSString *didPhleb = [[_fullScreeningForm objectForKey:SECTION_RESI_PART] objectForKey:kDidPhleb];
    
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kIsDiabetic] != (id)[NSNull null]) {
        diabeticRow.value = [self getYesNofromOneZero:triageDict[kIsDiabetic]];
        if ([diabeticRow.value isEqualToString:@"Yes"]) {
            if (didPhleb == (id)[NSNull null] || [didPhleb containsString:@"No"]) {
                row.required = YES;
                row.disabled = @0;
            }
        } else {
            row.disabled = @1;
            row.required = NO;
        }
    }
    [self setDefaultFontWithRow:row];
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kCbg] != (id)[NSNull null]) {
        row.value = triageDict[kCbg];
        [self updateAnswerColor:row];
    }
    
    diabeticRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                NSString *didPhleb = [[_fullScreeningForm objectForKey:SECTION_RESI_PART] objectForKey:kDidPhleb];
                if (didPhleb == (id)[NSNull null] || [didPhleb containsString:@"No"]) {
                    row.disabled = @NO;
                    row.required = YES;
                }
            } else {
                row.disabled = @YES;
                row.required = NO;
            }
            [self reloadFormRow:row];
        }
    };
    
    [section addFormRow:row];
    
    // BP1,2,3 - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    systolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp1Sys rowType:XLFormRowDescriptorTypeInteger title:@"BP 1 (Systolic)"];
    systolic_1.required = YES;
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBp1Sys] != (id)[NSNull null]) {
        systolic_1.value = triageDict[kBp1Sys];
        [self updateAnswerColor:systolic_1];
    }
    
    
    
    [self setDefaultFontWithRow:systolic_1];
    [section addFormRow:systolic_1];
    
    diastolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp1Dias rowType:XLFormRowDescriptorTypeInteger title:@"BP 1 (Diastolic)"];
    diastolic_1.required = YES;

    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBp1Dias] != (id)[NSNull null]) diastolic_1.value = triageDict[kBp1Dias];
    
    [self setDefaultFontWithRow:diastolic_1];
    [section addFormRow:diastolic_1];
    
    systolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp2Sys rowType:XLFormRowDescriptorTypeInteger title:@"BP 2 (Systolic)"];
    systolic_2.required = YES;
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBp2Sys] != (id)[NSNull null]) {
        systolic_2.value = triageDict[kBp2Sys];
        [self updateAnswerColor:systolic_2];
    }
    
    [self setDefaultFontWithRow:systolic_2];
    [section addFormRow:systolic_2];
    
    diastolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp2Dias rowType:XLFormRowDescriptorTypeInteger title:@"BP 2 (Diastolic)"];
    diastolic_2.required = YES;
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBp2Dias] != (id)[NSNull null]) diastolic_2.value = triageDict[kBp2Dias];
    
    [self setDefaultFontWithRow:diastolic_2];
    [section addFormRow:diastolic_2];
    
    systolic_3 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp3Sys rowType:XLFormRowDescriptorTypeInteger title:@"BP 3 (Systolic)"];
    systolic_3.disabled = [NSNumber numberWithBool:![self checkIfShouldEnable3rdBP]];
    systolic_3.required = NO;
    //    [systolic_3.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBp3Sys] != (id)[NSNull null]) {
        systolic_3.value = triageDict[kBp3Sys];
        [self updateAnswerColor:systolic_3];
    }
    
    [self setDefaultFontWithRow:systolic_3];
    [section addFormRow:systolic_3];
    
    diastolic_3 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp3Dias rowType:XLFormRowDescriptorTypeInteger title:@"BP 3 (Diastolic)"];
    diastolic_3.disabled = [NSNumber numberWithBool:![self checkIfShouldEnable3rdBP]];
    //    [diastolic_3.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    diastolic_3.required = NO;
    
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBp3Dias] != (id)[NSNull null]) diastolic_3.value = triageDict[kBp3Dias];
    
    [self setDefaultFontWithRow:diastolic_3];
    [section addFormRow:diastolic_3];
    
    
    //Make them coupled together, such that if one enabled, both enabled.
    systolic_3.disabled = [NSNumber numberWithBool:[self checkIfShouldEnable3rdBP]];
    if ([systolic_3.disabled isEqual:@NO]) {
        diastolic_3.disabled = @NO;
        diastolic_3.required = YES;
        systolic_3.required = YES;
    } else {
        diastolic_3.disabled = [NSNumber numberWithBool:[self checkIfShouldEnable3rdBP]];
        if ([diastolic_3.disabled isEqual:@NO]) {
            systolic_3.disabled = @NO;
            systolic_3.required = YES;
            diastolic_3.required = YES;
        }
    }
    
    systolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBp12AvgSys rowType:XLFormRowDescriptorTypeText title:@"Average BP (Systolic)"];
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBp12AvgSys] != (id)[NSNull null]) {
        systolic_avg.value = triageDict[kBp12AvgSys];
        [self updateAnswerColor:systolic_avg];
    }
    
    systolic_avg.disabled = @(1);   //permanent
    [self setDefaultFontWithRow:systolic_avg];
    
    [section addFormRow:systolic_avg];
    
    __weak __typeof(self)weakSelf = self;
    systolic_1.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            BOOL flag = [weakSelf checkIfShouldEnable3rdBP];

            systolic_3.disabled = [NSNumber numberWithBool:!flag];
            diastolic_3.disabled =[NSNumber numberWithBool:!flag];
            
            systolic_3.required = ![systolic_3.disabled boolValue];
            diastolic_3.required = ![diastolic_3.disabled boolValue];
            [self updateFormRow:systolic_3];
            [self updateFormRow:diastolic_3];
        }
    };
    
    systolic_2.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            BOOL flag = [weakSelf checkIfShouldEnable3rdBP];
            
            systolic_3.disabled = [NSNumber numberWithBool:!flag];
            diastolic_3.disabled =[NSNumber numberWithBool:!flag];
            
            systolic_3.required = ![systolic_3.disabled boolValue];
            diastolic_3.required = ![diastolic_3.disabled boolValue];
            [self updateFormRow:systolic_3];
            [self updateFormRow:diastolic_3];
        }
        
    };
    
    
    diastolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBp12AvgDias rowType:XLFormRowDescriptorTypeText title:@"Average BP (Diastolic)"];
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBp12AvgDias] != (id)[NSNull null]) diastolic_avg.value = triageDict[kBp12AvgDias];
    
    [self setDefaultFontWithRow:diastolic_avg];
    diastolic_avg.disabled = @(1);
    [section addFormRow:diastolic_avg];
    
    
    diastolic_1.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            BOOL flag = [weakSelf checkIfShouldEnable3rdBP];
            
            systolic_3.disabled = [NSNumber numberWithBool:!flag];
            diastolic_3.disabled =[NSNumber numberWithBool:!flag];
            
            systolic_3.required = ![systolic_3.disabled boolValue];
            diastolic_3.required = ![diastolic_3.disabled boolValue];
            [self updateFormRow:systolic_3];
            [self updateFormRow:diastolic_3];
        }
        
    };
    
    diastolic_2.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            BOOL flag = [weakSelf checkIfShouldEnable3rdBP];
            
            systolic_3.disabled = [NSNumber numberWithBool:!flag];
            diastolic_3.disabled =[NSNumber numberWithBool:!flag];
            
            systolic_3.required = ![systolic_3.disabled boolValue];
            diastolic_3.required = ![diastolic_3.disabled boolValue];
            [self updateFormRow:systolic_3];
            [self updateFormRow:diastolic_3];
        }
    };
    
    // Waist-Hip Ratio - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    XLFormRowDescriptor *waist;
    waist = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistCircum rowType:XLFormRowDescriptorTypeDecimal title:@"Waist Circumference (cm)"];
    waist.required = YES;

    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kWaistCircum] != (id)[NSNull null]) waist.value = triageDict[kWaistCircum];
    
    [self setDefaultFontWithRow:waist];
    [section addFormRow:waist];
    
    XLFormRowDescriptor *hip;
    hip = [XLFormRowDescriptor formRowDescriptorWithTag:kHipCircum rowType:XLFormRowDescriptorTypeDecimal title:@"Hip Circumference (cm)"];
    hip.required = YES;

    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kHipCircum] != (id)[NSNull null]) hip.value = triageDict[kHipCircum];
    
    [self setDefaultFontWithRow:hip];
    [section addFormRow:hip];
    
    XLFormRowDescriptor *waistHipRatio;
    waistHipRatio = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistHipRatio rowType:XLFormRowDescriptorTypeText title:@"Waist : Hip Ratio"];
    waistHipRatio.required = YES;
    [self setDefaultFontWithRow:waistHipRatio];

    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kWaistHipRatio] != (id)[NSNull null]) waistHipRatio.value = triageDict[kWaistHipRatio];
    
    waistHipRatio.disabled = @(1);
    [section addFormRow:waistHipRatio];
    
    waist.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([waist.value integerValue] != 0 && [hip.value integerValue] != 0) {
                waistHipRatio.value = [NSString stringWithFormat:@"%.2f", [waist.value doubleValue] / [hip.value doubleValue]];
                [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kWaistHipRatio andNewContent:waistHipRatio.value];
                [self updateFormRow:waistHipRatio];
            }
        }
    };
    hip.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([waist.value integerValue] != 0 && [hip.value integerValue] != 0) {
                waistHipRatio.value = [NSString stringWithFormat:@"%.2f", [waist.value doubleValue] / [hip.value doubleValue]];
                [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kWaistHipRatio andNewContent:waistHipRatio.value];
                [self updateFormRow:waistHipRatio];
            }
        }
    };

    // Diabetic or not - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    // BMI calculation - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *height;
    height = [XLFormRowDescriptor formRowDescriptorWithTag:kHeightCm rowType:XLFormRowDescriptorTypeDecimal title:@"Height (cm)"];
    height.required = YES;
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kHeightCm] != (id)[NSNull null]) height.value = triageDict[kHeightCm];
    
    
    [self setDefaultFontWithRow:height];
    [section addFormRow:height];
    
    XLFormRowDescriptor *weight;
    weight = [XLFormRowDescriptor formRowDescriptorWithTag:kWeightKg rowType:XLFormRowDescriptorTypeDecimal title:@"Weight (kg)"];
    weight.required = YES;
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kWeightKg] != (id)[NSNull null]) weight.value = triageDict[kWeightKg];
    
    [self setDefaultFontWithRow:weight];
    [section addFormRow:weight];
    
    XLFormRowDescriptor *bmi;
    bmi = [XLFormRowDescriptor formRowDescriptorWithTag:kBmi rowType:XLFormRowDescriptorTypeText title:@"BMI"];
    
    //value
    if (triageDict != (id)[NSNull null] && [triageDict objectForKey:kBmi] != (id)[NSNull null]) {
        bmi.value = triageDict[kBmi];
        [self updateAnswerColor:bmi];
    }
    
    bmi.disabled = @(1);
    [self setDefaultFontWithRow:bmi];
    [section addFormRow:bmi];
    
    weight.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([weight.value integerValue] != 0 && [height.value integerValue] != 0) {
                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
                
                [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBmi andNewContent:[self removePostfixIfAny:bmi.value]];
                [self updateAnswerColor:bmi];
                [self updateFormRow:bmi];
            }
        }
    };
    height.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([weight.value integerValue] != 0 && [height.value integerValue] != 0) {
                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
                [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBmi andNewContent:[self removePostfixIfAny:bmi.value]];
                [self updateAnswerColor:bmi];
                [self updateFormRow:bmi];
            }
        }
    };
    
    return [super initWithForm:formDescriptor];
    
}



- (id) initSnellenEyeTest {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"4. Basic Vision"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *snellenTestDict = _fullScreeningForm[SECTION_SNELLEN_TEST];
 
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSnellenTest];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Please ask the resident if he/she uses spectacles.";
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpecs rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"1. Does the resident use spectacles?"];
    if (snellenTestDict != (id)[NSNull null] && [snellenTestDict objectForKey:kSpecs] != (id)[NSNull null])
        row.value = [self getYesNofromOneZero:snellenTestDict[kSpecs]];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"SPECTACLES"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *rightEye = [XLFormRowDescriptor formRowDescriptorWithTag:kRightEye rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"2. Right Eye: 6/"];
    rightEye.required = YES;
    rightEye.selectorOptions = @[@"6",
                            @"9",
                            @"12",
                            @"18",
                            @"24",
                            @"36",
                            @"60"
                            ];
    [self setDefaultFontWithRow:rightEye];
    if (snellenTestDict != (id)[NSNull null] && [snellenTestDict objectForKey:kRightEye] != (id)[NSNull null]) rightEye.value = snellenTestDict[kRightEye];
    [section addFormRow:rightEye];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRightEyePlus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Adjustment (Right)"];
    row.selectorOptions = @[@"-2", @"-1", @"0", @"+1", @"+2"];
    row.required = NO;
    [self setDefaultFontWithRow:row];
    
    if (snellenTestDict != (id)[NSNull null] && [snellenTestDict objectForKey:kRightEyePlus] != (id)[NSNull null])
        row.value = snellenTestDict[kRightEyePlus];
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *leftEye = [XLFormRowDescriptor formRowDescriptorWithTag:kLeftEye rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"3. Left Eye: 6/"];
    leftEye.required = YES;
    leftEye.selectorOptions = @[@"6",
                            @"9",
                            @"12",
                            @"18",
                            @"24",
                            @"36",
                            @"60"
                            ];
    [self setDefaultFontWithRow:leftEye];
    if (snellenTestDict != (id)[NSNull null] && [snellenTestDict objectForKey:kLeftEye] != (id)[NSNull null]) leftEye.value = snellenTestDict[kLeftEye];
    [section addFormRow:leftEye];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLeftEyePlus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Adjustment (Left)"];
    row.selectorOptions = @[@"-2", @"-1", @"0", @"+1", @"+2"];
    row.required = NO;
    [self setDefaultFontWithRow:row];
    
    if (snellenTestDict != (id)[NSNull null] && [snellenTestDict objectForKey:kLeftEyePlus] != (id)[NSNull null])
        row.value = snellenTestDict[kLeftEyePlus];
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *six12Row = [XLFormRowDescriptor formRowDescriptorWithTag:kSix12 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"4. Does either eye (or both) have vision poorer than 6/12?"];
    six12Row.disabled = @YES;   //auto-generated
    six12Row.required = YES;
    six12Row.selectorOptions = @[@"Yes", @"No"];
    [six12Row.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    six12Row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:six12Row];
    
    rightEye.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if (newValue != nil && newValue != (id)[NSNull null]) {
                if ([newValue intValue] > 12) {
                    six12Row.value = @"Yes";
                } else {
                    if (leftEye.value != nil && leftEye.value != (id)[NSNull null]) {
                        if ([leftEye.value intValue] <= 12) {
                            six12Row.value = @"No";
                        }
                     }
                }
                [self reloadFormRow:six12Row];
            }
        }
    };

    leftEye.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if (newValue != nil && newValue != (id)[NSNull null]) {
                if ([newValue intValue] > 12) {
                    six12Row.value = @"Yes";
                } else {
                    if (rightEye.value != nil && rightEye.value != (id)[NSNull null]) {
                        if ([rightEye.value intValue] <= 12) {
                            six12Row.value = @"No";
                        }
                    }
                }
                [self reloadFormRow:six12Row];
            }
        }
    };
    //value
    if (snellenTestDict != (id)[NSNull null] && [snellenTestDict objectForKey:kSix12] != (id)[NSNull null]) six12Row.value = [self getYesNofromOneZero:snellenTestDict[kSix12]];
    
    [section addFormRow:six12Row];
    
    XLFormRowDescriptor *tunnelRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTunnel rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"5. Does resident have genuine visual complaints (e.g. floaters, tunnel vision, bright spots etc.)?"];
    tunnelRow.required = YES;
    tunnelRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    tunnelRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:tunnelRow];
    
    //value
    if (snellenTestDict != (id)[NSNull null] && [snellenTestDict objectForKey:kTunnel] != (id)[NSNull null]) tunnelRow.value = [self getYesNofromOneZero:snellenTestDict[kTunnel]];
    [section addFormRow:tunnelRow];
    
    XLFormRowDescriptor *visitEye12Mths = [XLFormRowDescriptor formRowDescriptorWithTag:kVisitEye12Mths rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"6. Has the resident visited an eye specialist in the past 12 months?"];
    visitEye12Mths.required = YES;
    visitEye12Mths.cellConfig[@"textLabel.numberOfLines"] = @0;
    visitEye12Mths.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:visitEye12Mths];
    
    //value
    if (snellenTestDict != (id)[NSNull null] && [snellenTestDict objectForKey:kVisitEye12Mths] != (id)[NSNull null]) visitEye12Mths.value = [self getYesNofromOneZero:snellenTestDict[kVisitEye12Mths]];
    [section addFormRow:visitEye12Mths];

    [self checkForSeriEligibilityWithRow3:six12Row andRow4:tunnelRow andRow5:visitEye12Mths];
    
    six12Row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            [self checkForSeriEligibilityWithRow3:rowDescriptor andRow4:tunnelRow andRow5:visitEye12Mths];
        }
    };
    
    tunnelRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            [self checkForSeriEligibilityWithRow3:six12Row andRow4:rowDescriptor andRow5:visitEye12Mths];
        }
    };
    
    visitEye12Mths.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            [self checkForSeriEligibilityWithRow3:six12Row andRow4:tunnelRow andRow5:rowDescriptor];
        }
    };
    
    return [super initWithForm:formDescriptor];
    
}

-(id) initEmergencySvcs {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Emergency Services"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *emerSvsDict = [self.fullScreeningForm objectForKey:SECTION_EMERGENCY_SERVICES];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckEmergencyServices];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *didEmerSvcsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kUndergoneEmerSvcs rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Undergone Emergency Services?"];
    didEmerSvcsRow.required = YES;
    if (emerSvsDict != (id)[NSNull null] && [emerSvsDict objectForKey:kUndergoneEmerSvcs] != (id)[NSNull null])
        didEmerSvcsRow.value = [self getYesNofromOneZero:emerSvsDict[kUndergoneEmerSvcs]];
    
    [self setDefaultFontWithRow:didEmerSvcsRow];
    didEmerSvcsRow.selectorOptions = @[@"Yes", @"No"];
    didEmerSvcsRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:didEmerSvcsRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Doctor's Notes"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *docNotesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDocNotes
                                                rowType:XLFormRowDescriptorTypeTextView];
    [docNotesRow.cellConfigAtConfigure setObject:@"Type your notes here..." forKey:@"textView.placeholder"];
    docNotesRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", didEmerSvcsRow];
    //value
    if (emerSvsDict != (id)[NSNull null] && [emerSvsDict objectForKey:kDocNotes] != (id)[NSNull null]) docNotesRow.value = emerSvsDict[kDocNotes];
    
    [section addFormRow:docNotesRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *docNameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDocName
                                                rowType:XLFormRowDescriptorTypeName title:@"Name of Doctor"];
    [self setDefaultFontWithRow:docNameRow];
    docNameRow.required = NO;
    docNameRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", didEmerSvcsRow];
    
    //value
    if (emerSvsDict != (id)[NSNull null] && [emerSvsDict objectForKey:kDocName] != (id)[NSNull null]) docNameRow.value = emerSvsDict[kDocName];
    
    [section addFormRow:docNameRow];
    
    XLFormRowDescriptor *docReferredRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDocReferred rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Provided with Referral Letter?"];
    docReferredRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:docReferredRow];
    docReferredRow.required = NO;
    docReferredRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", didEmerSvcsRow];
    
    //value
    if (emerSvsDict != (id)[NSNull null] && [emerSvsDict objectForKey:kDocReferred] != (id)[NSNull null]) docReferredRow.value = [self getYesNofromOneZero:emerSvsDict[kDocReferred]];
    [section addFormRow:docReferredRow];
    

    return [super initWithForm:formDescriptor];
}

- (id) initPhysioNotes {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"6. Fall Risk Assessment"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *physioDict = _fullScreeningForm[SECTION_PHYSIOTHERAPY];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckPhysiotherapy];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Physiotherapy Notes"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *sitToStandQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"sts_q"
                                                                                    rowType:XLFormRowDescriptorTypeInfo
                                                                                      title:@"a. 5x Sit-to-Stand"];
    sitToStandQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:sitToStandQRow];
    [section addFormRow:sitToStandQRow];
    
    
    XLFormRowDescriptor *sitToStandRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSitStand
                                                                                   rowType:XLFormRowDescriptorTypeSelectorPush
                                                                                     title:@""];
    sitToStandRow.noValueDisplayText = @"Tap here";
//    sitToStandRow.required = YES;
    sitToStandRow.selectorOptions = @[@"0 Not able to complete 5 sit-to-stand/Unattempted",
                                      @"1 Complete in >16.7s",
                                      @"2 Complete in 16.6-13.7s",
                                      @"3 Complete in 13.6-11.2s",
                                      @"4 Complete in <11.2s"];
    
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kSitStand] != (id)[NSNull null])
        sitToStandRow.value = [self getSTSValueFromArray:physioDict[kSitStand]];
    
    [section addFormRow:sitToStandRow];
    
    XLFormRowDescriptor *balanceQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"balance_q"
                                                                                rowType:XLFormRowDescriptorTypeInfo
                                                                                  title:@"b. Balance \ni) Side-by-side (10 sec max) \nii) Semi-tandem (10 sec max) \niii) Tandem (10 sec max)"];
    balanceQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:balanceQRow];
    [section addFormRow:balanceQRow];
    
    
    XLFormRowDescriptor *balanceRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBalance
                                                                               rowType:XLFormRowDescriptorTypeSelectorPush
                                                                                 title:@""];
    balanceRow.noValueDisplayText = @"Tap here";
//    balanceRow.required = YES;
    balanceRow.selectorOptions = @[@"0 Side-by-side <10s or unable to perform/Unattempted",
                                      @"1 Side-by-side 10s, <10s semi-tandem",
                                      @"2 Semi-tandem 10s, tandem 0-2s",
                                      @"3 Semi-tandem 10s, tandem 3-9s",
                                      @"4 Tandem ≥ 10s"];
    
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kBalance] != (id)[NSNull null])
        balanceRow.value = [self getBalanceValueFromArray:physioDict[kBalance]];
    
    [section addFormRow:balanceRow];
    
    XLFormRowDescriptor *gaitSpeedQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"gs_q"
                                                                             rowType:XLFormRowDescriptorTypeInfo
                                                                               title:@"c. 8-Feet Walk (Gait speed test)"];
    gaitSpeedQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:gaitSpeedQRow];
    [section addFormRow:gaitSpeedQRow];
    
    
    XLFormRowDescriptor *gaitSpeedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kGaitSpeed
                                                                            rowType:XLFormRowDescriptorTypeSelectorPush
                                                                              title:@""];
    gaitSpeedRow.noValueDisplayText = @"Tap here";
//    gaitSpeedRow.required = YES;
    gaitSpeedRow.selectorOptions = @[@"0 Not attempted/not able",
                                   @"1 Completed in >5.7s",
                                   @"2 Completed in 4.1-5.7s",
                                   @"3 Completed in 3.2-4.0s",
                                   @"4 Completed in <3.1s"];
    
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kGaitSpeed] != (id)[NSNull null])
        gaitSpeedRow.value = [self getGaitSpeedValueFromArray:physioDict[kGaitSpeed]];
    
    [section addFormRow:gaitSpeedRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"NOTE: Score is auto-calculated";
    [formDescriptor addFormSection:section];
    
    spbbScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpbbScore
                                                         rowType:XLFormRowDescriptorTypeNumber
                                                           title:@"Total SPBB Score (max score 12)"];
    spbbScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    spbbScoreRow.disabled = @1;
    [self setDefaultFontWithRow:spbbScoreRow];
    [spbbScoreRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kSpbbScore] != (id)[NSNull null])
        spbbScoreRow.value = physioDict[kSpbbScore];
    
    [section addFormRow:spbbScoreRow];
    
    // only for Kampong Glam
    if ([neighbourhood containsString:@"Kampong"]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:@""];
        [formDescriptor addFormSection:section];
        
        XLFormRowDescriptor *tugQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"tug_q"
                                                                             rowType:XLFormRowDescriptorTypeInfo
                                                                               title:@"Timed Up and Go (seconds) (0 if unattempted)"];
        tugQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
        [self setDefaultFontWithRow:tugQRow];
        [section addFormRow:tugQRow];
        
        
        XLFormRowDescriptor *tugRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTimeUpGo
                                                                            rowType:XLFormRowDescriptorTypeDecimal
                                                                              title:@""];
//        tugRow.required = YES;
        [self setDefaultFontWithRow:tugRow];
        [tugRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        //value
        if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kTimeUpGo] != (id)[NSNull null])
            tugRow.value = physioDict[kTimeUpGo];
        
        [section addFormRow:tugRow];
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *supineSysBpQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q6"
                                                                         rowType:XLFormRowDescriptorTypeInfo
                                                                           title:@"Postural Systolic Blood Pressure (Supine)"];
    supineSysBpQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:supineSysBpQRow];
    [section addFormRow:supineSysBpQRow];
    
    
    XLFormRowDescriptor *supineSysBpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSupineBpSys
                                                                        rowType:XLFormRowDescriptorTypeInteger
                                                                          title:@""];
//    supineSysBpRow.required = YES;
    [self setDefaultFontWithRow:supineSysBpRow];
    [supineSysBpRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kSupineBpSys] != (id)[NSNull null])
        supineSysBpRow.value = physioDict[kSupineBpSys];
    
    [section addFormRow:supineSysBpRow];
    
    XLFormRowDescriptor *supineDiasBpQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q7"
                                                                                 rowType:XLFormRowDescriptorTypeInfo
                                                                                   title:@"Postural Diastolic Blood Pressure (Supine)"];
    supineDiasBpQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:supineDiasBpQRow];
    [section addFormRow:supineDiasBpQRow];
    
    
    XLFormRowDescriptor *supineDiasBpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSupineBpDias
                                                                                rowType:XLFormRowDescriptorTypeInteger
                                                                                  title:@""];
//    supineDiasBpRow.required = YES;
    [self setDefaultFontWithRow:supineDiasBpRow];
    [supineDiasBpRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kSupineBpDias] != (id)[NSNull null])
        supineDiasBpRow.value = physioDict[kSupineBpDias];
    
    [section addFormRow:supineDiasBpRow];
    
    XLFormRowDescriptor *standSysBpQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q8"
                                                                                  rowType:XLFormRowDescriptorTypeInfo
                                                                                    title:@"Postural Systolic Blood Pressure (Standing)"];
    standSysBpQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:standSysBpQRow];
    [section addFormRow:standSysBpQRow];
    
    
    XLFormRowDescriptor *standSysBpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kStandBpSys
                                                                                 rowType:XLFormRowDescriptorTypeInteger
                                                                                   title:@""];
//    standSysBpRow.required = YES;
    [self setDefaultFontWithRow:standSysBpRow];
    [standSysBpRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kStandBpSys] != (id)[NSNull null])
        standSysBpRow.value = physioDict[kStandBpSys];
    
    [section addFormRow:standSysBpRow];
    
    XLFormRowDescriptor *standDiasBpQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q9"
                                                                                  rowType:XLFormRowDescriptorTypeInfo
                                                                                    title:@"Postural Diastolic Blood Pressure (Standing)"];
    standDiasBpQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:standDiasBpQRow];
    [section addFormRow:standDiasBpQRow];
    
    
    XLFormRowDescriptor *standDiasBpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kStandBpDias
                                                                                 rowType:XLFormRowDescriptorTypeInteger
                                                                                   title:@""];
//    standDiasBpRow.required = YES;
    [self setDefaultFontWithRow:standDiasBpRow];
    [standDiasBpRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kStandBpDias] != (id)[NSNull null])
        standDiasBpRow.value = physioDict[kStandBpDias];
    
    [section addFormRow:standDiasBpRow];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Fall Risk "];
    [formDescriptor addFormSection:section];
    
    fallRiskRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFallRisk
                                                         rowType:XLFormRowDescriptorTypeText
                                                           title:@"Fall Risk"];
    fallRiskRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    fallRiskRow.disabled = @1;
    fallRiskRow.value = @"HIGH RISK";
    [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kFallRisk andNewContent:@"HIGH RISK"];
    [self setDefaultFontWithRow:fallRiskRow];
    [fallRiskRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
//    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kFallRisk] != (id)[NSNull null])
//        fallRiskRow.value = physioDict[kFallRisk];
    
    [section addFormRow:fallRiskRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *physioNotesQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"physionotes_q"
                                                                         rowType:XLFormRowDescriptorTypeInfo
                                                                           title:@"Falls in the past 1 year"];
    physioNotesQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:physioNotesQRow];
    [section addFormRow:physioNotesQRow];
    
    XLFormRowDescriptor *physioNotesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhysioNotes
                                                        rowType:XLFormRowDescriptorTypeTextView
                                                          title:@""];
//    physioNotesRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    physioNotesRow.required = YES;
    [self setDefaultFontWithRow:physioNotesRow];
//    [physioNotesRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kPhysioNotes] != (id)[NSNull null])
        physioNotesRow.value = physioDict[kPhysioNotes];
    
    [section addFormRow:physioNotesRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *keyResultsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"keyresults_q"
                                                                                 rowType:XLFormRowDescriptorTypeInfo
                                                                                   title:@"Key results for the tests"];
    keyResultsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:keyResultsQRow];
    [section addFormRow:keyResultsQRow];
    
    
    XLFormRowDescriptor *keyResultsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kKeyResults
                                                                                rowType:XLFormRowDescriptorTypeTextView
                                                                                  title:@""];
    //    physioNotesRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    keyResultsRow.required = YES;
    [self setDefaultFontWithRow:keyResultsRow];
    //    [physioNotesRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kKeyResults] != (id)[NSNull null])
        keyResultsRow.value = physioDict[kKeyResults];
    
    [section addFormRow:keyResultsRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *externalRisksQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"externalrisks_q"
                                                                                rowType:XLFormRowDescriptorTypeInfo
                                                                                  title:@"External risks factors (Environmental/Footwear)"];
    externalRisksQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:externalRisksQRow];
    [section addFormRow:externalRisksQRow];
    
    XLFormRowDescriptor *externalRisksRow = [XLFormRowDescriptor formRowDescriptorWithTag:kExternalRisks
                                                                                rowType:XLFormRowDescriptorTypeTextView
                                                                                  title:@""];
    //    physioNotesRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    externalRisksRow.required = YES;
    [self setDefaultFontWithRow:externalRisksRow];
    //    [physioNotesRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kExternalRisks] != (id)[NSNull null])
        externalRisksRow.value = physioDict[kExternalRisks];
    
    [section addFormRow:externalRisksRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *otherFactorsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"otherfactors_q"
                                                                                   rowType:XLFormRowDescriptorTypeInfo
                                                                                     title:@"Other factors (eg. pain impairing mobility, vision, problems)"];
    otherFactorsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:otherFactorsQRow];
    [section addFormRow:otherFactorsQRow];
    
    XLFormRowDescriptor *otherFactorsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kOtherFactors
                                                                                rowType:XLFormRowDescriptorTypeTextView
                                                                                  title:@""];
    //    physioNotesRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    otherFactorsRow.required = YES;
    [self setDefaultFontWithRow:otherFactorsRow];
    //    [physioNotesRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kOtherFactors] != (id)[NSNull null])
        otherFactorsRow.value = physioDict[kOtherFactors];
    
    [section addFormRow:otherFactorsRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *recommendationsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"recommendations_q"
                                                                                  rowType:XLFormRowDescriptorTypeInfo
                                                                                    title:@"Recommendations"];
    recommendationsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:recommendationsQRow];
    [section addFormRow:recommendationsQRow];
    
    XLFormRowDescriptor *recommendationsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRecommendations
                                                                                rowType:XLFormRowDescriptorTypeTextView
                                                                                  title:@""];
    //    physioNotesRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    recommendationsRow.required = YES;
    [self setDefaultFontWithRow:recommendationsRow];
    //    [physioNotesRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kRecommendations] != (id)[NSNull null])
        recommendationsRow.value = physioDict[kRecommendations];
    
    [section addFormRow:recommendationsRow];
    
    
    XLFormRowDescriptor *moreCommentsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"more_comments_q"
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"Additional Comments"];
    moreCommentsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:moreCommentsQRow];
    [section addFormRow:moreCommentsQRow];
    
    XLFormRowDescriptor *moreCommentsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMoreComments
                                                                                    rowType:XLFormRowDescriptorTypeTextView
                                                                                      title:@""];
    //    physioNotesRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    //    recommendationsRow.required = YES;
    [self setDefaultFontWithRow:moreCommentsRow];
    //    [physioNotesRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kMoreComments] != (id)[NSNull null])
        moreCommentsRow.value = physioDict[kMoreComments];
    
    [section addFormRow:moreCommentsRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGivenReferral rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Resident given referral?"];
    row.noValueDisplayText = @"Tap here";
    row.required = NO;
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"NIL", @"Cluster Operator"];
    
    //value
    if (physioDict != (id)[NSNull null] && [physioDict objectForKey:kGivenReferral] != (id)[NSNull null]) {
        row.value = [physioDict objectForKey:kGivenReferral];
    }
    
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
}


-(id) initAdditionalSvcs {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Financial and Cancer Services"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *addSvcsDict = _fullScreeningForm[SECTION_ADD_SERVICES];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckAdd];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"CHAS"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAppliedChas rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Applied for CHAS under NHS?"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    BOOL chasEligibility = [[ResidentProfile sharedManager] isEligibleCHAS];
    
    if (chasEligibility) {
        row.disabled = @NO;
        row.required = YES;
    }
    else {
        row.disabled = @YES;
        row.required = NO;
    }
    
    //value
    if (addSvcsDict != (id)[NSNull null] && [addSvcsDict objectForKey:kAppliedChas] != (id)[NSNull null]) row.value = [self getYesNofromOneZero:addSvcsDict[kAppliedChas]];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"FIT"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReceiveFit rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Receiving FIT kit from NHS?"];
    row.required = NO;
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    BOOL fitEligibility = [[ResidentProfile sharedManager] isEligibleReceiveFIT];
    
    if (fitEligibility) {
        row.disabled = @NO;
        row.required = YES;
    }
    else {
        row.disabled = @YES;
        row.required = NO;
    }
    
    //value
    if (addSvcsDict != (id)[NSNull null] && [addSvcsDict objectForKey:kReceiveFit] != (id)[NSNull null]) row.value = [self getYesNofromOneZero:addSvcsDict[kReceiveFit]];
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mammogram"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferMammo rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred for mammogram by NHS?"];
    row.required = NO;
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    BOOL mammoEligibility = [[ResidentProfile sharedManager] isEligibleReferMammo];
    
    if (mammoEligibility) {
        row.disabled = @NO;
        row.required = YES;
    }
    else {
        row.disabled = @YES;
        row.required = NO;
    }
    
    //value
    if (addSvcsDict != (id)[NSNull null] && [addSvcsDict objectForKey:kReferMammo] != (id)[NSNull null]) row.value = [self getYesNofromOneZero:addSvcsDict[kReferMammo]];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"PAP Smear"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferPapSmear rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred for PAP smear by NHS?"];
    row.required = NO;
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    BOOL papSmearEligibility = [[ResidentProfile sharedManager] isEligibleReferPapSmear];
    
    if (papSmearEligibility) {
        row.disabled = @NO;
        row.required = YES;
    }
    else {
        row.disabled = @YES;
        row.required = NO;
    }
    
    //value
    if (addSvcsDict != (id)[NSNull null] && [addSvcsDict objectForKey:kReferPapSmear] != (id)[NSNull null]) row.value = [self getYesNofromOneZero:addSvcsDict[kReferPapSmear]];
    
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
}


- (id) initDentalCheckup {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"6. Dental"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *dentalCheckDict = [_fullScreeningForm objectForKey:SECTION_BASIC_DENTAL];

    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckBasicDental];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *dentalUndergoneRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDentalUndergone rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Undergone dental check-up?"];
    dentalUndergoneRow.required = YES;
    dentalUndergoneRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:dentalUndergoneRow];
    
    //value
    if (dentalCheckDict != (id)[NSNull null] && [dentalCheckDict objectForKey:kDentalUndergone] != (id)[NSNull null]) dentalUndergoneRow.value = [self getYesNofromOneZero:dentalCheckDict[kDentalUndergone]];
    
    [section addFormRow:dentalUndergoneRow];
    
    XLFormRowDescriptor *usesDenturesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kUsesDentures
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Does resident currently uses dentures?"];
    usesDenturesRow.selectorOptions = @[@"Yes", @"No"];
    usesDenturesRow.required = YES;
    usesDenturesRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    usesDenturesRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", dentalUndergoneRow];
    [self setDefaultFontWithRow:usesDenturesRow];
    
    //value
    if (dentalCheckDict != (id)[NSNull null] && [dentalCheckDict objectForKey:kUsesDentures] != (id)[NSNull null])
        usesDenturesRow.value = [self getYesNofromOneZero:dentalCheckDict[kUsesDentures]];
    [section addFormRow:usesDenturesRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"oral_health_q"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Oral health rating (ask dentist)"];
//    row.selectorOptions = @[@"Yes", @"No"];
//    row.required = YES;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", dentalUndergoneRow];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    
    XLFormRowDescriptor *oralHealthRow = [XLFormRowDescriptor formRowDescriptorWithTag:kOralHealth
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    oralHealthRow.selectorOptions = @[@"Healthy", @"Self-care advised", @"Unhealthy (referral required)"];
    oralHealthRow.noValueDisplayText = @"Tap here for options";
    oralHealthRow.required = YES;
    oralHealthRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    [section addFormRow:oralHealthRow];
    
    
    XLFormRowDescriptor *dentistReferredRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDentistReferred
                                                rowType:XLFormRowDescriptorTypeSelectorPush title:@"Referred to?"];
    dentistReferredRow.selectorOptions = @[@"NIL", @"CHAS Dentist", @"NDCS Care Partners / Unity Denticare", @"NDCS via polyclinic referral"];
    dentistReferredRow.required = YES;
    
    //value for Oral Health
    if (dentalCheckDict != (id)[NSNull null] && [dentalCheckDict objectForKey:kOralHealth] != (id)[NSNull null]) {
        oralHealthRow.value = dentalCheckDict[kOralHealth];
        if ([oralHealthRow.value containsString:@"Unhealthy"]) {
            dentistReferredRow.required = YES;
        } else dentistReferredRow.required = NO;
    }
    
    dentistReferredRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Unhealthy'", oralHealthRow];
    [self setDefaultFontWithRow:dentistReferredRow];
    
    
    
    //value
    if (dentalCheckDict != (id)[NSNull null] && [dentalCheckDict objectForKey:kDentistReferred] != (id)[NSNull null])
        dentistReferredRow.value = dentalCheckDict[kDentistReferred];
    
    [section addFormRow:dentistReferredRow];
    
    oralHealthRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            if ([newValue containsString:@"Unhealthy"]) {
                dentistReferredRow.required = YES;
            } else {
                dentistReferredRow.required = NO;
            }
        }
        [self reloadFormRow:dentistReferredRow];
    };
    
    dentalUndergoneRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"No"]) {
                usesDenturesRow.disabled = @YES;
                usesDenturesRow.required = NO;
                oralHealthRow.disabled = @YES;
                oralHealthRow.required = NO;
                dentistReferredRow.disabled = @YES;
                dentistReferredRow.required = NO;
            } else {
                usesDenturesRow.disabled = @NO;
                usesDenturesRow.required = YES;
                oralHealthRow.disabled = @NO;
                oralHealthRow.required = YES;
                dentistReferredRow.disabled = @NO;
                dentistReferredRow.required = YES;
            }
        }
    };
    
    return [super initWithForm:formDescriptor];
}


- (id) initHealthEducation {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Health Education"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *preEduDict = [_fullScreeningForm objectForKey:SECTION_PRE_HEALTH_EDU];
    NSDictionary *postEduDict = [_fullScreeningForm objectForKey:SECTION_POST_HEALTH_EDU];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckEd];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }

    
    preEdSection = [XLFormSectionDescriptor formSectionWithTitle:@"Pre-education Knowledge Quiz"];
    [formDescriptor addFormSection:preEdSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu1 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"1. A person always knows when they have heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu1]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu2 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"2. If you have a family history of heart disease, you are at risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu2]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu3 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"3. The older a person is, the greater their risk of having heart disease "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu3]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu4 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"4. Smoking is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu4]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu5 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"5. A person who stops smoking will lower their risk of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu5]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu6 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"6. High blood pressure is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu6]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu7 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"7. Keeping blood pressure under control will reduce a person’s risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu7]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu8 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"8. High cholesterol is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu8]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu9 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"9. Eating fatty foods does not affect blood cholesterol levels"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu9]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu10 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"10. If your ‘good’ cholesterol (HDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu10]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu11 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"11. If your ‘bad’ cholesterol (LDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu11]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu12 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"12. Being overweight increases a person’s risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu12]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu13 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"13. Regular physical activity will lower a person’s chance of getting heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu13]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu14 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"14. Only exercising at a gym or in an exercise class will lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu14]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu15 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"15. Walking is considered exercise that will help lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu15]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu16 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"16. Diabetes is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu16]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu17 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"17. High blood sugar puts a strain on the heart"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu17]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu18 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"18. If your blood sugar is high over several months it can cause your cholesterol level to go up and increase your risk of heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu18]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu19 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"19. A person who has diabetes can reduce their risk of developing heart disease if they keep their blood sugar levels under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu19]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu20 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"20. People with diabetes rarely have high cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu20]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu21 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"21. If a person has diabetes, keeping their cholesterol under control will help to lower their chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu21]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu22 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"22. People with diabetes tend to have low HDL (good) cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu22]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu23 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"23. A person who has diabetes can reduce their risk of developing heart disease if they keep their blood pressure under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu23]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu24 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"24. A person who has diabetes can reduce their risk of developing heart disease if they keep their weight under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu24]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdu25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"25. Men with diabetes have a higher risk of heart disease than women with diabetes "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu25]];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"preEdScoreButton" rowType:XLFormRowDescriptorTypeButton title:@"Calculate Pre-education Score"];
    row.action.formSelector = @selector(calculateScore:);
    row.required = YES;
    [preEdSection addFormRow:row];
    
    preEdScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdScore rowType:XLFormRowDescriptorTypeInteger title:@"Pre-education Score"];
    preEdScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    preEdScoreRow.noValueDisplayText = @"-/-";
    preEdScoreRow.disabled = @YES;
    [self setDefaultFontWithRow:preEdScoreRow];
    if (preEduDict != (id)[NSNull null]) preEdScoreRow.value = preEduDict[kPreEdScore];
    [preEdSection addFormRow:preEdScoreRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    showPostEdSectionBtnRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"start_post_ed_button" rowType:XLFormRowDescriptorTypeButton title:@"Start Post-education asessment"];
    showPostEdSectionBtnRow.action.formSelector = @selector(showPostEdSection:);
    showPostEdSectionBtnRow.hidden = @YES;
    showPostEdSectionBtnRow.required = NO;
    [section addFormRow:showPostEdSectionBtnRow];
    
    postEdSection = [XLFormSectionDescriptor formSectionWithTitle:@"Post-Education Knowledge Quiz"];
    [formDescriptor addFormSection:postEdSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu1 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person always knows when they have heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu1]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu2 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If you have a family history of heart disease, you are at risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu2]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu3 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"The older a person is, the greater their risk of having heart disease "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu3]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu4 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Smoking is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu4]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu5 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person who stops smoking will lower their risk of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu5]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu6 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"High blood pressure is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu6]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu7 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Keeping blood pressure under control will reduce a person’s risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu7]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu8 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"High cholesterol is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu8]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu9 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Eating fatty foods does not affect blood cholesterol levels"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu9]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu10 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If your ‘good’ cholesterol (HDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu10]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu11 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If your ‘bad’ cholesterol (LDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu11]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu12 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Being overweight increases a person’s risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu12]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu13 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Regular physical activity will lower a person’s chance of getting heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu13]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu14 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Only exercising at a gym or in an exercise class will lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu14]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu15 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Walking is considered exercise that will help lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu15]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu16 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Diabetes is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu16]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu17 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"High blood sugar puts a strain on the heart"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu17]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu18 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If your blood sugar is high over several months it can cause your cholesterol level to go up and increase your risk of heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu18]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu19 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their blood sugar levels under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu19]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu20 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"People with diabetes rarely have high cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu20]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu21 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If a person has diabetes, keeping their cholesterol under control will help to lower their chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu21]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu22 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"People with diabetes tend to have low HDL (good) cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu22]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu23 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their blood pressure under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu23]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu24 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their weight under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu24]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdu25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Men with diabetes have a higher risk of heart disease than women with diabetes "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    if (postEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:postEduDict[kEdu25]];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"postEdScoreButton" rowType:XLFormRowDescriptorTypeButton title:@"Calculate Post-education Score"];
    row.action.formSelector = @selector(calculateScore:);
    row.required = NO;
    [postEdSection addFormRow:row];
    
    postEdScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPostEdScore rowType:XLFormRowDescriptorTypeInteger title:@"Post-education Score"];
    postEdScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    postEdScoreRow.noValueDisplayText = @"-/-";
    postEdScoreRow.required = YES;
    postEdScoreRow.disabled = @YES;
    [self setDefaultFontWithRow:postEdScoreRow];
    if (postEduDict != (id)[NSNull null]) postEdScoreRow.value = postEduDict[kPostEdScore];
    [postEdSection addFormRow:postEdScoreRow];
    
    XLFormRowDescriptor *dateHealthEdRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDateEd rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"Completed on:"];
    dateHealthEdRow.required = YES;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood] containsString:@"Eunos"]) {
        dateHealthEdRow.selectorOptions = @[@"9 September", @"10 September"];
    } else {
        dateHealthEdRow.selectorOptions = @[@"7 October", @"8 October"];
    }
    dateHealthEdRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:dateHealthEdRow];
    
    //value
    if (preEduDict != (id)[NSNull null])
        dateHealthEdRow.value = preEduDict[kDateEd];
    
    [postEdSection addFormRow:dateHealthEdRow];
    
    
    [postEdSection setHidden:@YES]; //keep hidden first
    
    return [super initWithForm:formDescriptor];
}

- (id) initSummaryAndHealthEdu {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Summary & Health Education"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Instructions"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"instructions" rowType:XLFormRowDescriptorTypeInfo title:@"Collect these items:\n- Resident's Health Report\n- iPad\n- NHS Health Education Booklet"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Summary"];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Counsel the resident on the following topics using the NHS Health Education Booklet.\n\nThese topics were auto-selected based on your resident's medical history.\n\nIf your resident has questions that you can't answer, PLEASE ASK an NHS committee member!"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"health_planning" rowType:XLFormRowDescriptorTypeInfo title:@"Health Planning"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"diabetes" rowType:XLFormRowDescriptorTypeInfo title:@"Diabetes"];
    [self setDefaultFontWithRow:row];
    BOOL diabetesShowHide = [[ResidentProfile sharedManager] diabetesCheck];
    row.hidden = [NSNumber numberWithBool:!diabetesShowHide];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"hyperlipidemia" rowType:XLFormRowDescriptorTypeInfo title:@"Hyperlipidaemia"];
    [self setDefaultFontWithRow:row];
    BOOL hyperlipidShowHide = [[ResidentProfile sharedManager] hyperlipidemiaCheck];
    row.hidden = [NSNumber numberWithBool:!hyperlipidShowHide];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"hypertension" rowType:XLFormRowDescriptorTypeInfo title:@"Hypertension"];
    [self setDefaultFontWithRow:row];
    BOOL hypertensionShowHide = [[ResidentProfile sharedManager] hypertensionCheck];
    row.hidden = [NSNumber numberWithBool:!hypertensionShowHide];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"cardio_disease" rowType:XLFormRowDescriptorTypeInfo title:@"Cardiovascular disease"];
    [self setDefaultFontWithRow:row];
    BOOL cardioDiseaseShowHide = [[ResidentProfile sharedManager] cardiovascularDiseaseCheck];
    row.hidden = [NSNumber numberWithBool:!cardioDiseaseShowHide];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"dental" rowType:XLFormRowDescriptorTypeInfo title:@"Dental"];
    [self setDefaultFontWithRow:row];
    BOOL dentalShowHide = [[ResidentProfile sharedManager] dentalCheck];
    row.hidden = [NSNumber numberWithBool:!dentalShowHide];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"alcohol" rowType:XLFormRowDescriptorTypeInfo title:@"Alcohol"];
    [self setDefaultFontWithRow:row];
    BOOL alcoholShowHide = [[ResidentProfile sharedManager] alcoholCheck];
    row.hidden = [NSNumber numberWithBool:!alcoholShowHide];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"smoking" rowType:XLFormRowDescriptorTypeInfo title:@"Smoking"];
    [self setDefaultFontWithRow:row];
    BOOL smokingShowHide = [[ResidentProfile sharedManager] smokingCheck];
    row.hidden = [NSNumber numberWithBool:!smokingShowHide];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"instructions_2" rowType:XLFormRowDescriptorTypeInfo title:@"Go through the resident's Health Report.\n\nTick the relevant items on the Action Plan and remind the resident."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = @1;
    [section addFormRow:row];
    
    
    //Only show if it's door-to-door
    NSDictionary *modeOfScreeningDict = [_fullScreeningForm objectForKey:SECTION_MODE_OF_SCREENING];
    if (modeOfScreeningDict != (id)[NSNull null]) {
        NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
        if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
            row.hidden = @0;
        }
    }

    

    return [super initWithForm:formDescriptor];
}
#pragma mark - Buttons

-(void)editBtnPressed:(UIBarButtonItem * __unused)button
{
    if ([self.form isDisabled]) {
        [self.form setDisabled:NO];     //enable the form
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finalize" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeBtnPressed:)];
        
        NSString *fieldName;
        
        switch ([self.sectionID intValue]) {
            case Phleb: fieldName = kCheckPhleb;
                break;
            case Triage: fieldName = kCheckClinicalResults;
                break;
            case BasicVision: fieldName = kCheckSnellenTest;
                break;
            case FallRiskAssess: fieldName = kCheckPhysiotherapy;
                break;
            case Dental: fieldName = kCheckBasicDental;
                break;
            case Hearing: fieldName = kCheckHearing;
                break;
            case AddSvcs: fieldName = kCheckAddServices;
                break;
            case EmerSvcs: fieldName = kCheckEmergencyServices;
                break;
//            case SummaryNHealthEdu: fieldName = kCheckEd;
//                break;
            default:
                break;
                
        }
        
        [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:fieldName andNewContent:@"0"]; //un-finalize it
    }

}

- (void) finalizeBtnPressed: (UIBarButtonItem * __unused) button {

    NSLog(@"%@", [self.form formValues]);
    
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor orangeColor];
            [UIView animateWithDuration:0.3 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }];
        [self showFormValidationError:[validationErrors firstObject]];
        
        return;
    } else {
        NSString *fieldName;
        
        switch ([self.sectionID intValue]) {
            case Phleb: fieldName = kCheckPhleb;
                break;
            case Triage: fieldName = kCheckClinicalResults;
                break;
            case BasicVision: fieldName = kCheckSnellenTest;
                break;
            case FallRiskAssess: fieldName = kCheckPhysiotherapy;
                break;
            case Dental: fieldName = kCheckBasicDental;
                break;
            case Hearing: fieldName = kCheckHearing;
                break;
            case AddSvcs: fieldName = kCheckAddServices;
                break;
            case EmerSvcs: fieldName = kCheckEmergencyServices;
                break;
//            case HealthEdu: fieldName = kCheckEd;
//                break;
            default:
                break;
        }
        
        [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:fieldName andNewContent:@"1"];
        [SVProgressHUD setMaximumDismissTimeInterval:1.0];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showSuccessWithStatus:@"Completed!"];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        [self.form setDisabled:YES];
        [self.tableView endEditing:YES];    //to really disable the table
        [self.tableView reloadData];
    }


}


#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    NSString* ansFromTF, *ansFromYesNo;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"True"])
            ansFromTF = @"1";
        else if ([newValue isEqualToString:@"False"])
            ansFromTF = @"0";
    }
    
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Yes"])
            ansFromYesNo = @"1";
        else if ([newValue isEqualToString:@"No"])
            ansFromYesNo = @"0";
    }
    
    NSString* ansFromPassFail;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Pass"])
            ansFromPassFail = @"1";
        else if ([newValue isEqualToString:@"Fail"])
            ansFromPassFail = @"0";
    }
    
    /* Mode of Screening */
    
    if ([rowDescriptor.tag isEqualToString:kScreenMode]) {
        [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kScreenMode andNewContent:newValue];
        
    } else if ([rowDescriptor.tag isEqualToString:kApptDate]) {
        [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kApptDate andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kApptTime]) {
        [self processApptTimeSubmissionWithNewValue: newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kPhlebAppt]) {
        [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kPhlebAppt andNewContent:newValue];
    }
    
    /* Phlebotomy */
    else if ([rowDescriptor.tag isEqualToString:kChronicCond]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kChronicCond andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kNoBloodTest]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kNoBloodTest andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kWantFreeBt]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kWantFreeBt andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kDidPhleb]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kDidPhleb andNewContent:ansFromYesNo];
    }
    
    /* Triage */
    else if ([rowDescriptor.tag isEqualToString:kIsDiabetic]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kIsDiabetic andNewContent:ansFromYesNo];
    }
    
    /* 4. Basic Vision */
    else if ([rowDescriptor.tag isEqualToString:kSpecs]) {
        [self postSingleFieldWithSection:SECTION_SNELLEN_TEST andFieldName:kSpecs andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kRightEye]) {
        [self postSingleFieldWithSection:SECTION_SNELLEN_TEST andFieldName:kRightEye andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kLeftEye]) {
        [self postSingleFieldWithSection:SECTION_SNELLEN_TEST andFieldName:kLeftEye andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kSix12]) {
        [self postSingleFieldWithSection:SECTION_SNELLEN_TEST andFieldName:kSix12 andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kTunnel]) {
        [self postSingleFieldWithSection:SECTION_SNELLEN_TEST andFieldName:kTunnel andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kVisitEye12Mths]) {
        [self postSingleFieldWithSection:SECTION_SNELLEN_TEST andFieldName:kVisitEye12Mths andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kRightEyePlus]) {
        [self postSingleFieldWithSection:SECTION_SNELLEN_TEST andFieldName:kRightEyePlus andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kLeftEyePlus]) {
        [self postSingleFieldWithSection:SECTION_SNELLEN_TEST andFieldName:kLeftEyePlus andNewContent:newValue];
    }
    
    /* 6. Fall Risk Assessment */
    else if ([rowDescriptor.tag isEqualToString:kSitStand]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kSitStand andNewContent:[newValue substringToIndex:1]];
        [self calculateSpbbScore];
    } else if ([rowDescriptor.tag isEqualToString:kBalance]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kBalance andNewContent:[newValue substringToIndex:1]];
        [self calculateSpbbScore];
    } else if ([rowDescriptor.tag isEqualToString:kGaitSpeed]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kGaitSpeed andNewContent:[newValue substringToIndex:1]];
        [self calculateSpbbScore];
    } else if ([rowDescriptor.tag isEqualToString:kGivenReferral]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kGivenReferral andNewContent:newValue];
    }
    
    /* Additional Services */
    else if ([rowDescriptor.tag isEqualToString:kAppliedChas]) {
        [self postSingleFieldWithSection:SECTION_ADD_SERVICES andFieldName:kAppliedChas andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kReceiveFit]) {
        [self postSingleFieldWithSection:SECTION_ADD_SERVICES andFieldName:kReceiveFit andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kReferMammo]) {
        [self postSingleFieldWithSection:SECTION_ADD_SERVICES andFieldName:kReferMammo andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kReferPapSmear]) {
        [self postSingleFieldWithSection:SECTION_ADD_SERVICES andFieldName:kReferPapSmear andNewContent:ansFromYesNo];
    }
    
    /* Basic Dental Check-up */
    else if ([rowDescriptor.tag isEqualToString:kDentalUndergone]) {
        [self postSingleFieldWithSection:SECTION_BASIC_DENTAL andFieldName:kDentalUndergone andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kUsesDentures]) {
        [self postSingleFieldWithSection:SECTION_BASIC_DENTAL andFieldName:kUsesDentures andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kOralHealth]) {
        [self postSingleFieldWithSection:SECTION_BASIC_DENTAL andFieldName:kOralHealth andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDentistReferred]) {
        [self postSingleFieldWithSection:SECTION_BASIC_DENTAL andFieldName:kDentistReferred andNewContent:newValue];
    }
    
    /* 10. Emergency Services  */
     else if ([rowDescriptor.tag isEqualToString:kUndergoneEmerSvcs]) {
         [self postSingleFieldWithSection:SECTION_EMERGENCY_SERVICES andFieldName:kUndergoneEmerSvcs andNewContent:ansFromYesNo];
     } else if ([rowDescriptor.tag isEqualToString:kDocReferred]) {
         [self postSingleFieldWithSection:SECTION_EMERGENCY_SERVICES andFieldName:kDocReferred andNewContent:ansFromYesNo];
     }
    
    /* Fall Risk Assessment */
//    else if ([rowDescriptor.tag isEqualToString:kPsfuFRA]) {
//        [self postSingleFieldWithSection:SECTION_FALL_RISK_ASSMT andFieldName:kPsfuFRA andNewContent:rowDescriptor.value];
//    } else if ([rowDescriptor.tag isEqualToString:kBalance]) {
//        [self postSingleFieldWithSection:SECTION_FALL_RISK_ASSMT andFieldName:kBalance andNewContent:rowDescriptor.value];
//    } else if ([rowDescriptor.tag isEqualToString:kGaitSpeed]) {
//        [self postSingleFieldWithSection:SECTION_FALL_RISK_ASSMT andFieldName:kGaitSpeed andNewContent:rowDescriptor.value];
//    } else if ([rowDescriptor.tag isEqualToString:kChairStand]) {
//        [self postSingleFieldWithSection:SECTION_FALL_RISK_ASSMT andFieldName:kChairStand andNewContent:rowDescriptor.value];
//    } else if ([rowDescriptor.tag isEqualToString:kReqFollowupFRA]) {
//        [self postSingleFieldWithSection:SECTION_FALL_RISK_ASSMT andFieldName:kReqFollowupFRA andNewContent:ansFromYesNo];
//    } else if ([rowDescriptor.tag isEqualToString:kTotal]) {
//        [self postSingleFieldWithSection:SECTION_FALL_RISK_ASSMT andFieldName:kTotal andNewContent:rowDescriptor.value];
//    }
    
    
    /* Geriatric Dementia Assessment */
//    else if ([rowDescriptor.tag isEqualToString:kPsfuGDA]) {
//        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kPsfuGDA andNewContent:rowDescriptor.value];
//    }     else if ([rowDescriptor.tag isEqualToString:kEduStatus]) {
//        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kEduStatus andNewContent:rowDescriptor.value];
//    }     else if ([rowDescriptor.tag isEqualToString:kReqFollowupGDA]) {
//        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kReqFollowupGDA andNewContent:ansFromYesNo];
//    }
    
    
    /* Pre-Health Education */
//    else if ([rowDescriptor.tag isEqualToString:kPreEdu1]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu1 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu2]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu2 andNewContent:ansFromTF];
//    }else if ([rowDescriptor.tag isEqualToString:kPreEdu3]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu3 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu4]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu4 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu5]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu5 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu6]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu6 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu7]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu7 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu8]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu8 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu9]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu9 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu10]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu10 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu11]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu11 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu12]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu12 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu13]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu13 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu14]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu14 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu15]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu15 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu16]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu16 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu17]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu17 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu18]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu18 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu19]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu19 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu20]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu20 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu21]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu21 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu22]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu22 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu23]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu23 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu24]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu24 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdu25]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kEdu25 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPreEdScore]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kPreEdScore andNewContent:newValue];
//    } else if ([rowDescriptor.tag isEqualToString:kDateEd]) {
//        [self postSingleFieldWithSection:SECTION_PRE_HEALTH_EDU andFieldName:kDateEd andNewContent:newValue];
//    }
    
    /* Post-Health Education */
//    else if ([rowDescriptor.tag isEqualToString:kPostEdu1]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu1 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu2]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu2 andNewContent:ansFromTF];
//    }else if ([rowDescriptor.tag isEqualToString:kPostEdu3]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu3 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu4]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu4 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu5]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu5 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu6]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu6 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu7]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu7 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu8]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu8 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu9]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu9 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu10]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu10 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu11]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu11 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu12]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu12 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu13]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu13 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu14]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu14 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu15]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu15 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu16]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu16 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu17]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu17 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu18]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu18 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu19]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu19 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu20]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu20 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu21]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu21 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu22]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu22 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu23]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu23 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu24]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu24 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdu25]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kEdu25 andNewContent:ansFromTF];
//    } else if ([rowDescriptor.tag isEqualToString:kPostEdScore]) {
//        [self postSingleFieldWithSection:SECTION_POST_HEALTH_EDU andFieldName:kPostEdScore andNewContent:newValue];
//    }
}

-(void)beginEditing:(XLFormRowDescriptor *)rowDescriptor {
    if ([rowDescriptor.tag containsString:@"sys"] || [rowDescriptor.tag isEqualToString:kCbg]) {
        if (rowDescriptor.value > 0) {
            double value = [rowDescriptor.value doubleValue];
            rowDescriptor.value = [NSDecimalNumber numberWithDouble:value];
            [self updateFormRow:rowDescriptor];
        }
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
    
    tableDidEndEditing = true;

    /* Phlebotomy */
    if ([rowDescriptor.tag isEqualToString:kFastingBloodGlucose]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY andFieldName:kFastingBloodGlucose andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kTriglycerides]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY andFieldName:kTriglycerides andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kLDL]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY andFieldName:kLDL andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kHDL]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY andFieldName:kHDL andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCholesterolHdlRatio]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY andFieldName:kCholesterolHdlRatio andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kTotCholesterol]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY andFieldName:kTotCholesterol andNewContent:rowDescriptor.value];
    }
    
    /* Mode Of Screening */
    else if ([rowDescriptor.tag isEqualToString:kNotes]) {
        [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kNotes andNewContent:rowDescriptor.value];
    }
    
    /* Triage */
    else if ([rowDescriptor.tag isEqualToString:kBp1Sys]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp1Sys andNewContent:[self removePostfixIfAny:rowDescriptor.value]];
        [self calculateBpAvg];
    } else if ([rowDescriptor.tag isEqualToString:kBp1Dias]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp1Dias andNewContent:[self removePostfixIfAny:rowDescriptor.value]];
        [self calculateBpAvg];
    } else if ([rowDescriptor.tag isEqualToString:kHeightCm]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kHeightCm andNewContent:rowDescriptor.value];
    }else if ([rowDescriptor.tag isEqualToString:kWeightKg]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kWeightKg andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kWaistCircum]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kWaistCircum andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kHipCircum]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kHipCircum andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kWaistHipRatio]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kWaistHipRatio andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCbg]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kCbg andNewContent:[self removePostfixIfAny:rowDescriptor.value]];
    } else if ([rowDescriptor.tag isEqualToString:kBp2Sys]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp2Sys andNewContent:[self removePostfixIfAny:rowDescriptor.value]];
        [self calculateBpAvg];
    } else if ([rowDescriptor.tag isEqualToString:kBp2Dias]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp2Dias andNewContent:[self removePostfixIfAny:rowDescriptor.value]];
        [self calculateBpAvg];
    } else if ([rowDescriptor.tag isEqualToString:kBp3Sys]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp3Sys andNewContent:[self removePostfixIfAny:rowDescriptor.value]];
        [self calculateBpAvg];
    } else if ([rowDescriptor.tag isEqualToString:kBp3Dias]) {
        [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp3Dias andNewContent:[self removePostfixIfAny:rowDescriptor.value]];
        [self calculateBpAvg];
    }
    
    /* Doctor's Consult */
    else if ([rowDescriptor.tag isEqualToString:kDocNotes]) {
        [self postSingleFieldWithSection:SECTION_EMERGENCY_SERVICES andFieldName:kDocNotes andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kDocName]) {
        [self postSingleFieldWithSection:SECTION_EMERGENCY_SERVICES andFieldName:kDocName andNewContent:rowDescriptor.value];
    }
    
    /* Geriatric Dementia Assessment */
    else if ([rowDescriptor.tag isEqualToString:kAmtScore]) {
        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kAmtScore andNewContent:rowDescriptor.value];
    }
    
    /* Fall Risk Assessment */
    else if ([rowDescriptor.tag isEqualToString:kTimeUpGo]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kTimeUpGo andNewContent:rowDescriptor.value];
//        [self checkFallRisk];
    } else if ([rowDescriptor.tag isEqualToString:kPhysioNotes]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kPhysioNotes andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKeyResults]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kKeyResults andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kExternalRisks]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kExternalRisks andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kOtherFactors]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kOtherFactors andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kRecommendations]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kRecommendations andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kMoreComments]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kMoreComments andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSupineBpSys]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kSupineBpSys andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSupineBpDias]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kSupineBpDias andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kStandBpSys]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kStandBpSys andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kStandBpDias]) {
        [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kStandBpDias andNewContent:rowDescriptor.value];
    }
    
    [self updateAnswerColor:rowDescriptor];
    
}

#pragma mark - Other Methods

- (BOOL) checkIfShouldEnable3rdBP {
    
    // If there's a NULL or blank
    if (systolic_1.value == (id)[NSNull null] || diastolic_1.value == (id)[NSNull null]|| systolic_2.value == (id)[NSNull null] || diastolic_2 == (id)[NSNull null]) {
        return YES;
    }
    
    // If the difference greater than 5 either for SYS or DIAS
    else if (systolic_1.value != (id)[NSNull null] && diastolic_1.value != (id)[NSNull null] && systolic_2.value != (id)[NSNull null] && diastolic_2.value != (id)[NSNull null]) {
        if (abs([systolic_1.value intValue] - [systolic_2.value intValue]) >= 5) return YES;
        else if (abs([diastolic_1.value intValue] - [diastolic_2.value intValue]) >= 5) return YES;
    }
    
    return NO;
}

- (void) calculateBpAvg {
    BOOL use12, use23, use13;
    use12 = use23 = use13 = false;
    
    
    if (![self checkIfShouldEnable3rdBP]) { //means, can settle just among BP1 & BP2
        use12 = true;
    }
    
    //BP1 got blanks
    else if (systolic_1.value == (id)[NSNull null] || diastolic_1.value == (id)[NSNull null] || [systolic_1.value intValue] == 0 || [diastolic_1.value intValue] == 0) {
        if (systolic_2.value != (id)[NSNull null] && diastolic_2.value != (id)[NSNull null] && systolic_3.value != (id)[NSNull null] && diastolic_3.value != (id)[NSNull null]) {
            //use BP2 & BP3
            use23 = true;
        }
    }
    
    //BP2 got blanks
    else if (systolic_2.value == (id)[NSNull null] || diastolic_2.value == (id)[NSNull null] || [systolic_2.value intValue] == 0 || [diastolic_2.value intValue] == 0) {  //BP2 got blanks
        if (systolic_1.value != (id)[NSNull null] && diastolic_1.value != (id)[NSNull null] && systolic_3.value != (id)[NSNull null] && diastolic_3.value != (id)[NSNull null]) {
            //use BP2 & BP3
            use23 = true;
            
        }
    }
    // all 3 BPs have values
    else if (systolic_1.value != (id)[NSNull null] && diastolic_1.value != (id)[NSNull null] && systolic_2.value != (id)[NSNull null] && diastolic_2.value != (id)[NSNull null] && systolic_3.value != (id)[NSNull null] && diastolic_3.value != (id)[NSNull null]) {
        
        //check BP1 & BP3 first < 5 mmHg
        int diff13_sys = abs([systolic_1.value intValue] - [systolic_3.value intValue]);
        int diff13_dias = abs([diastolic_1.value intValue] - [diastolic_3.value intValue]);
        int diff23_sys = abs([systolic_2.value intValue] - [systolic_3.value intValue]);
        int diff23_dias = abs([diastolic_2.value intValue] - [diastolic_3.value intValue]);
        
        if (diff13_sys <5 && diff13_dias <5) {
            if (diff23_sys < 5 && diff23_dias < 5) {
                // if BOTH also within 5 mmHg
                
                NSNumber *systolic_1_Number = [NSNumber numberWithInt:[systolic_1.value intValue]];
                NSNumber *systolic_2_Number = [NSNumber numberWithInt:[systolic_2.value intValue]];
                NSNumber *systolic_3_Number = [NSNumber numberWithInt:[systolic_3.value intValue]];
                
                
                NSArray *unsortedArray = @[systolic_1_Number, systolic_2_Number, systolic_3_Number];
                NSNumber *maxNumber = [unsortedArray valueForKeyPath:@"@max.self"];
                
                if ([systolic_1_Number isEqualToNumber:maxNumber]) {
                    use23 = true;
                } else if ([systolic_2_Number isEqualToNumber:maxNumber]) {
                    use13 = true;
                } else {
                    use12 = true;
                }
            }
            // if ONLY BP1 & BP3 within 5 mmHg
            else {
                use13 = true;
            }
        }
        // if ONLY BP2 & BP3 within 5 mmHg
        else if (diff23_sys < 5 && diff23_dias < 5) {
            use23 = true;
        }
        // neither of the three have readings within 5 mmHg
        else {
            // BP1_sys < 75 OR BP1_dias < 45
            if ([systolic_1.value intValue] < 75 || [diastolic_1.value intValue] < 45) {
                use23 = true;
            }
            // BP2_sys < 75 OR BP2_dias < 45
            else if ([systolic_2.value intValue] < 75 || [diastolic_2.value intValue] < 45) {
                use13 = true;
            }
            // BP3_sys < 75 OR BP3_dias < 45
            else if ([systolic_3.value intValue] < 75 || [diastolic_3.value intValue] < 45) {
                use12 = true;
            }
            // if ALL above 75 for SYS and 45 for DIAS
            else {
                NSNumber *systolic_1_Number = [NSNumber numberWithInt:[systolic_1.value intValue]];
                NSNumber *systolic_2_Number = [NSNumber numberWithInt:[systolic_2.value intValue]];
                NSNumber *systolic_3_Number = [NSNumber numberWithInt:[systolic_3.value intValue]];
                
                
                NSArray *unsortedArray = @[systolic_1_Number, systolic_2_Number, systolic_3_Number];
                NSNumber *maxNumber = [unsortedArray valueForKeyPath:@"@max.self"];
                
                if ([systolic_1_Number isEqualToNumber:maxNumber]) {
                    use23 = true;
                } else if ([systolic_2_Number isEqualToNumber:maxNumber]) {
                    use13 = true;
                } else {
                    use12 = true;
                }
            }
        }
    }
    
    if (use12) {
        systolic_avg.value = [NSNumber numberWithFloat:([systolic_1.value floatValue] + [systolic_2.value floatValue])/2.0];
        diastolic_avg.value = [NSNumber numberWithFloat:([diastolic_1.value floatValue] + [diastolic_2.value floatValue])/2.0];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp12AvgSys andNewContent:systolic_avg.value];
            [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp12AvgDias andNewContent:diastolic_avg.value];
        });
        
    } else if (use23) {
        systolic_avg.value = [NSNumber numberWithFloat:([systolic_2.value floatValue] + [systolic_3.value floatValue])/2.0];
        diastolic_avg.value = [NSNumber numberWithFloat:([diastolic_2.value floatValue] + [diastolic_3.value floatValue])/2.0];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp12AvgSys andNewContent:systolic_avg.value];
            [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp12AvgDias andNewContent:diastolic_avg.value];
        });
    } else if (use13) {
        systolic_avg.value = [NSNumber numberWithFloat:([systolic_1.value floatValue] + [systolic_3.value floatValue])/2.0];
        diastolic_avg.value = [NSNumber numberWithFloat:([diastolic_1.value floatValue] + [diastolic_3.value floatValue])/2.0];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp12AvgSys andNewContent:systolic_avg.value];
            [self postSingleFieldWithSection:SECTION_CLINICAL_RESULTS andFieldName:kBp12AvgDias andNewContent:diastolic_avg.value];
        });
    }
    
    [self reloadFormRow:systolic_avg];
    [self reloadFormRow:diastolic_avg];
}


- (BOOL) checkPhlebEligibility {
    NSDictionary *phlebEligibDict = _fullScreeningForm[SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT];
    age40 = sporeanPr = chronicCond_noBloodTest = wantFreeBt = false;
    
    if ([age integerValue] >= 40)
        age40 = true;
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) {
        sporeanPr = true;
    }
    
    
    if (phlebEligibDict != nil && phlebEligibDict != (id)[NSNull null]) {
        if ([neighbourhood containsString:@"Eunos"]) {
            if ([phlebEligibDict objectForKey:kChronicCond] && [phlebEligibDict objectForKey:kChronicCond] != (id)[NSNull null]) {
                if ([[phlebEligibDict objectForKey:kChronicCond] isEqual:@1]) {
                    chronicCond_noBloodTest = true;
                }
            }
        } else {    //Kampung Glam
            if ([phlebEligibDict objectForKey:kNoBloodTest] && [phlebEligibDict objectForKey:kNoBloodTest] != (id)[NSNull null]) {
                if ([[phlebEligibDict objectForKey:kNoBloodTest] isEqual:@1]) {
                    chronicCond_noBloodTest = true;
                }
            }
        }
        
        if ([phlebEligibDict objectForKey:kWantFreeBt] && [phlebEligibDict objectForKey:kWantFreeBt] != (id)[NSNull null]) {
            if ([[phlebEligibDict objectForKey:kWantFreeBt] isEqual:@1]) {
                wantFreeBt = true;
            }
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (age40 && sporeanPr && chronicCond_noBloodTest && wantFreeBt) {
        [defaults setObject:@"1" forKey:kQualifyPhleb];
        return true;
    } else {
        [defaults setObject:@"0" forKey:kQualifyPhleb];
        return false;
    }
}

- (BOOL) checkDiffBetweenRow1: (XLFormRowDescriptor *) row1 andRow2: (XLFormRowDescriptor *) row2 withDiffOf: (int) diff {
    
    if (row1.value != (id)[NSNull null] && row2.value != (id)[NSNull null]) {
        if (row1.value && row2.value) { //check for nil
            if (abs([row1.value intValue] - [row2.value intValue]) > diff) {
                return true;
            }
        }
    }
    return false;
}

- (void) checkForSeriEligibilityWithRow3: (XLFormRowDescriptor *) six12Row
                                                  andRow4: (XLFormRowDescriptor *) tunnelRow
                                                  andRow5: (XLFormRowDescriptor *) visitEye12MthsRow {
    
    if (([six12Row.value isEqualToString:@"Yes"] && ([tunnelRow.value isEqualToString:@"Yes"])) && ([visitEye12MthsRow.value isEqualToString:@"Yes"])) { // (3 AND 4) AND 5
        NSLog(@"SERI Enabled!");
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifySeri];
    } else {
        NSLog(@"SERI Disabled!");
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifySeri];
    }
}

- (void) calculateSpbbScore {
    NSDictionary *fields = [self.form formValues];
    NSArray *arrayOfVarName = @[kSitStand,kBalance,kGaitSpeed];
    int totalScore = 0;
    for (NSString *str in arrayOfVarName) {
        if ([fields objectForKey:str] != nil && [fields objectForKey:str] != (id)[NSNull null] && ![[fields objectForKey:str] isEqualToString:@""]) {
            totalScore += [[[fields objectForKey:str] substringToIndex:1] intValue];    //the first character is always a number
        }
    }
    
    spbbScoreRow.value = [NSNumber numberWithInt:totalScore];
    [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kSpbbScore andNewContent:[NSString stringWithFormat:@"%d", totalScore]];
    [self reloadFormRow:spbbScoreRow];
//    [self checkFallRisk];
}

- (void) checkFallRisk {
    if ([[self.form formValues] objectForKey:kTimeUpGo] != (id)[NSNull null]) {
        float number = [[[self.form formValues] objectForKey:kTimeUpGo] floatValue];
        NSNumber *spbbScore = spbbScoreRow.value;
        if (spbbScore != (id)[NSNull null]) {
            int spbbScoreInt = [spbbScore intValue];
            
            if (spbbScoreInt > 6 && number < 15) {
                fallRiskRow.value = @"MODERATE RISK";
            } else {
                fallRiskRow.value = @"HIGH RISK";
            }
            [self reloadFormRow:fallRiskRow];
            [self postSingleFieldWithSection:SECTION_PHYSIOTHERAPY andFieldName:kFallRisk andNewContent:fallRiskRow.value];
            
        }
    }

}

- (void) calculateScore: (XLFormRowDescriptor *)sender {
    
    NSDictionary *dict = [self.form formValues];
    int score, eachAns;
    NSString *ans;
    
    score = 0;
    
    if ([sender.title rangeOfString:@"Pre-education"].location != NSNotFound) { // if it's pre-education button
        NSDictionary *correctPreAnswers = @{kPreEdu1:@"False",//1
                                            kPreEdu2:@"True", //2
                                            kPreEdu3:@"True", //3
                                            kPreEdu4: @"True", //4
                                            kPreEdu5: @"True", //5
                                            kPreEdu6: @"True", //6
                                            kPreEdu7: @"True", //7
                                            kPreEdu8: @"True", //8
                                            kPreEdu9:@"False",//9
                                            kPreEdu10:@"False",//10
                                            kPreEdu11:@"True", //11
                                            kPreEdu12:@"True", //12
                                            kPreEdu13:@"True", //13
                                            kPreEdu14:@"False",//14
                                            kPreEdu15:@"True", //15
                                            kPreEdu16:@"True", //16
                                            kPreEdu17:@"True", //17
                                            kPreEdu18:@"True", //18
                                            kPreEdu19:@"True", //19
                                            kPreEdu20:@"False",//20
                                            kPreEdu21:@"True", //21
                                            kPreEdu22:@"True", //22
                                            kPreEdu23:@"True", //23
                                            kPreEdu24:@"True", //24
                                            kPreEdu25:@"False" //25
                                            };
        
        for (NSString *key in dict) {
            if (![key isEqualToString:kPreEdScore] && ![key isEqualToString:kPostEdScore] && ![key isEqualToString:@"preEdScoreButton"] && ![key isEqualToString:@"postEdScoreButton"]) {
                //prevent null cases
                if (dict[key] != [NSNull null]) {//only take non-null values;
                    ans = dict[key];
                    
                    if ([ans isEqualToString:correctPreAnswers[key]]) {
                        eachAns = 1;
                    } else
                        eachAns = 0;
                    
                    score = score + eachAns;
                    ans = @"";
                }
            }
        }
        
        preEdScoreRow.value = [NSString stringWithFormat:@"%d", score];
        [self reloadFormRow:preEdScoreRow];
        [showPostEdSectionBtnRow setHidden:@NO];
        [self reloadFormRow:showPostEdSectionBtnRow];
    } else {
        
        NSDictionary *correctPostAnswers = @{kPostEdu1:@"False",//1
                                             kPostEdu2:@"True", //2
                                             kPostEdu3:@"True", //3
                                             kPostEdu4: @"True", //4
                                             kPostEdu5: @"True", //5
                                             kPostEdu6: @"True", //6
                                             kPostEdu7: @"True", //7
                                             kPostEdu8: @"True", //8
                                             kPostEdu9:@"False",//9
                                             kPostEdu10:@"False",//10
                                             kPostEdu11:@"True", //11
                                             kPostEdu12:@"True", //12
                                             kPostEdu13:@"True", //13
                                             kPostEdu14:@"False",//14
                                             kPostEdu15:@"True", //15
                                             kPostEdu16:@"True", //16
                                             kPostEdu17:@"True", //17
                                             kPostEdu18:@"True", //18
                                             kPostEdu19:@"True", //19
                                             kPostEdu20:@"False",//20
                                             kPostEdu21:@"True", //21
                                             kPostEdu22:@"True", //22
                                             kPostEdu23:@"True", //23
                                             kPostEdu24:@"True", //24
                                             kPostEdu25:@"False" //25
                                             };
        
        
        for (NSString *key in dict) {
            if (![key isEqualToString:kPreEdScore] && ![key isEqualToString:kPostEdScore] && ![key isEqualToString:@"preEdScoreButton"] && ![key isEqualToString:@"postEdScoreButton"]) {
                //prevent null cases
                if (dict[key] != [NSNull null]) {//only take non-null values;
                    ans = dict[key];
                    
                    if ([ans isEqualToString:correctPostAnswers[key]]) {
                        eachAns = 1;
                    } else
                        eachAns = 0;
                    
                    score = score + eachAns;
                    ans = @"";
                }
            }
        }
        
        postEdScoreRow.value = [NSString stringWithFormat:@"%d", score];
        [self reloadFormRow:postEdScoreRow];
    }

    [self deselectFormRow:sender];
    [sender setHidden:@YES];    //make it hidden, no need anymore.
    
}

- (void) showPostEdSection: (XLFormRowDescriptor *) sender {
    [self.form removeFormSection:preEdSection]; //remove it altogther.
    [postEdSection setHidden:@NO];
    [sender setHidden:@YES];    //make button hidden, no need anymore
    
    [self deselectFormRow:sender];
}

- (void) showValidationError {
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
            [UIView animateWithDuration:0.3 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }];
        [self showFormValidationError:[validationErrors firstObject]];
        
        return;
    }
}

#pragma mark - Organize Dictionary Methods

- (NSString *) getStringWithDictionary:(NSDictionary *)dict
                               rowType:(NSInteger)type
                 formDescriptorWithTag:(NSString *)rowTag {
//                             serverAPI:(NSString *)key {

    
    if (([dict objectForKey:rowTag] == [NSNull null]) || (![dict objectForKey:rowTag])) {    //if  NULL or nil, just return
        return @"";
    }
    NSString *fieldEntry, *returnValue;
    
    switch (type) {
        case Text: returnValue = [dict objectForKey:rowTag];
            break;
            
        case YesNo: fieldEntry = [dict objectForKey:rowTag];
            if ([fieldEntry isEqualToString:@"YES"]) returnValue = @"1";
            else if([fieldEntry isEqualToString:@"NO"]) returnValue = @"0";
            else returnValue = @"";
            break;
            
        case TextView: returnValue = [dict objectForKey:rowTag];
            break;
            
        case Checkbox:
            break;
            
        case SelectorPush: returnValue = [NSString stringWithFormat:@"%@",[[dict objectForKey:rowTag] formValue]];
            break;
            
        case SelectorActionSheet: returnValue = [NSString stringWithFormat:@"%@",[[dict objectForKey:rowTag] formValue]];
            break;
            
        case SegmentedControl:
            break;
            
        case Number: returnValue = [NSString stringWithFormat:@"%@",[dict objectForKey:rowTag]];
            break;
            
        case Switch: returnValue = [NSString stringWithFormat:@"%@",[dict objectForKey:rowTag]];
            break;
            
        case YesNoNA: fieldEntry = [dict objectForKey:rowTag];
            if ([fieldEntry isEqualToString:@"YES"]) returnValue = @"1";
            else if([fieldEntry isEqualToString:@"NO"]) returnValue = @"0";
            else if([fieldEntry isEqualToString:@"N.A."]) returnValue = @"2";
            else returnValue = @"";
            break;
            
        default: NSLog(@"default, not found its type");
            break;
    }

    return returnValue;
}



- (NSArray *) getTypeOfSmokeFromIndivValues {
    NSDictionary *dictionary = [self.fullScreeningForm objectForKey:@"risk_factors"];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if([[dictionary objectForKey:@"ciggs"] isEqualToString:@"1"]) [array addObject:@"Cigarettes"];
    if([[dictionary objectForKey:@"pipe"] isEqualToString:@"1"]) [array addObject:@"Pipe"];
    if([[dictionary objectForKey:@"rolled_leaves"] isEqualToString:@"1"]) [array addObject:@"Self-rolled leaves \"ang hoon\""];
    if([[dictionary objectForKey:@"shisha"] isEqualToString:@"1"]) [array addObject:@"Shisha"];
    if([[dictionary objectForKey:@"cigars"] isEqualToString:@"1"]) [array addObject:@"Cigars"];
    if([[dictionary objectForKey:@"e_ciggs"] isEqualToString:@"1"]) [array addObject:@"E-cigarettes"];
    if([[dictionary objectForKey:@"others"] isEqualToString:@"1"]) [array addObject:@"Others"];

    return array;
}

- (NSString *) getSTSValueFromArray: (id) value {
    if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqualToNumber:@0]) return @"0 Not able to complete 5 sit-to-stand/Unattempted";
        else if ([value isEqualToNumber:@1]) return @"1 Complete in >16.7s";
        else if ([value isEqualToNumber:@2]) return @"2 Complete in 16.6-13.7s";
        else if ([value isEqualToNumber:@3]) return @"3 Complete in 13.6-11.2s";
        else if ([value isEqualToNumber:@4]) return @"4 Complete in <11.2s";
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"0"]) return @"0 Not able to complete 5 sit-to-stand/Unattempted";
        else if ([value isEqualToString:@"1"]) return @"1 Complete in >16.7s";
        else if ([value isEqualToString:@"2"]) return @"2 Complete in 16.6-13.7s";
        else if ([value isEqualToString:@"3"]) return @"3 Complete in 13.6-11.2s";
        else if ([value isEqualToString:@"4"]) return @"4 Complete in <11.2s";
    }
    return @"";
}

- (NSString *) getBalanceValueFromArray: (id) value {
    if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqualToNumber:@0]) return @"0 Side-by-side <10s or unable to perform/Unattempted";
        else if ([value isEqualToNumber:@1]) return @"1 Side-by-side 10s, <10s semi-tandem";
        else if ([value isEqualToNumber:@2]) return @"2 Semi-tandem 10s, tandem 0-2s";
        else if ([value isEqualToNumber:@3]) return @"3 Semi-tandem 10s, tandem 3-9s";
        else if ([value isEqualToNumber:@4]) return @"4 Tandem ≥ 10s";
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"0"]) return @"0 Side-by-side <10s or unable to perform/Unattempted";
        else if ([value isEqualToString:@"1"]) return @"1 Side-by-side 10s, <10s semi-tandem";
        else if ([value isEqualToString:@"2"]) return @"2 Semi-tandem 10s, tandem 0-2s";
        else if ([value isEqualToString:@"3"]) return @"3 Semi-tandem 10s, tandem 3-9s";
        else if ([value isEqualToString:@"4"]) return @"4 Tandem ≥ 10s";
    }
    return @"";
}

- (NSString *) getGaitSpeedValueFromArray: (id) value {
    if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqualToNumber:@0]) return @"0 Not attempted/not able";
        else if ([value isEqualToNumber:@1]) return @"1 Completed in >5.7s";
        else if ([value isEqualToNumber:@2]) return @"2 Completed in 4.1-5.7s";
        else if ([value isEqualToNumber:@3]) return @"3 Completed in 3.2-4.0s";
        else if ([value isEqualToNumber:@4]) return @"4 Completed in <3.1s";
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"0"]) return @"0 Not attempted/not able";
        else if ([value isEqualToString:@"1"]) return @"1 Completed in >5.7s";
        else if ([value isEqualToString:@"2"]) return @"2 Completed in 4.1-5.7s";
        else if ([value isEqualToString:@"3"]) return @"3 Completed in 3.2-4.0s";
        else if ([value isEqualToString:@"4"]) return @"4 Completed in <3.1s";
    }
    return @"";
    
}


- (NSArray *) getScreeningTimeArrayFromDict:(NSDictionary *) dictionary andOptions:(NSArray *) options {
    NSMutableArray *screeningTimeArray = [[NSMutableArray alloc] init];
    
    if (dictionary == (id)[NSNull null])    //don't continue if null
        return @[];
    
//    if ([dictionary objectForKey:kTime_8_10] != (id) [NSNull null]) {
//        if([[dictionary objectForKey:kTime_8_10] isEqual:@1])
//            [screeningTimeArray addObject:[options objectAtIndex:0]];
//    }
//    
//    if ([dictionary objectForKey:kTime_10_12] != (id) [NSNull null]) {
//    if([[dictionary objectForKey:kTime_10_12] isEqual:@1])
//        [screeningTimeArray addObject:[options objectAtIndex:1]];
//    }
//    
//    if ([dictionary objectForKey:kTime_12_2] != (id) [NSNull null]) {
//        if([[dictionary objectForKey:kTime_12_2] isEqual:@1])
//            [screeningTimeArray addObject:[options objectAtIndex:2]];
//    }
//    
//    if ([dictionary objectForKey:kTime_2_4] != (id) [NSNull null]) {
//        if([[dictionary objectForKey:kTime_2_4] isEqual:@1]) {
//            if ([options count] > 3)    //if it's another date, could have only 3 options.
//            [screeningTimeArray addObject:[options objectAtIndex:3]];
//        }
//    }
    
    return screeningTimeArray;
}

- (void) processApptTimeSubmissionWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
    if (newValue != oldValue) {
        
        if (newValue != nil && newValue != (id) [NSNull null]) {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                NSMutableSet *oldSet = [NSMutableSet setWithCapacity:[oldValue count]];
                [oldSet addObjectsFromArray:oldValue];
                NSMutableSet *newSet = [NSMutableSet setWithCapacity:[newValue count]];
                [newSet addObjectsFromArray:newValue];
                
                if ([newSet count] > [oldSet count]) {
                    [newSet minusSet:oldSet];
//                    NSArray *array = [newSet allObjects];
//                    [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:[self getFieldNameFromApptTime:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
//                    NSArray *array = [oldSet allObjects];
//                    [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:[self getFieldNameFromApptTime:[array firstObject]] andNewContent:@"0"];
                }
            } else {
//                [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:[self getFieldNameFromApptTime:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
//                [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:[self getFieldNameFromApptTime:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }

}

//- (NSString *) getFieldNameFromApptTime: (NSString *) apptTime {
//    if ([apptTime isEqualToString:@"8am-10am"]) return kTime_8_10;
//    else if ([apptTime isEqualToString:@"10am-12pm"]) return kTime_10_12;
//    else if ([apptTime isEqualToString:@"12pm-2pm"]) return kTime_12_2;
//    else return kTime_2_4;
//}

- (NSString *) getTFfromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"]) {
            return @"True";
        } else {
            return @"False";
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1]) {
            return @"True";
        } else {
            return @"False";
        }
    }
    return @"";
}

- (NSString *) getYesNofromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"]) {
            return @"Yes";
        } else {
            return @"No";
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1]) {
            return @"Yes";
        } else {
            return @"No";
        }
    }
    return @"";
}

- (NSString *) removePostfixIfAny: (id) value {
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([value containsString:@" ("]) {
            NSUInteger i = [value rangeOfString:@" "].location - 1;
            return [value substringToIndex:i];
        }
    }
    
    return value;
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
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showErrorWithStatus:@"No Internet!"];
                
                
                break;
            }
            case ReachableViaWiFi:
            case ReachableViaWWAN:
                NSLog(@"Connected to server!");
                
                if (!isFormFinalized) {
                    [self.form setDisabled:NO];
                    [self.tableView reloadData];
                }

                
                if (internetDCed) { //previously disconnected
                    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
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
        
        
//        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Upload Fail", nil)
//                                                                                  message:@"Form failed to upload!"
//                                                                           preferredStyle:UIAlertControllerStyleAlert];
//        
//        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
//                                                            style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * okAction) {
//                                                              //do nothing for now
//                                                          }]];
//        [self presentViewController:alertController animated:YES completion:nil];

        
    };
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

- (void) updateAnswerColor:(XLFormRowDescriptor *) row {
    
    if (row.value == (id)[NSNull null] || row.value == nil) {
        return;
    }
    
    if ([row.tag containsString:@"sys"] && ![row.tag containsString:@"stand"] && ![row.tag containsString:@"supine"]) {
        if ([row.value integerValue] >= 140) {
            [row.cellConfig setObject:[UIColor redColor] forKey:@"textField.textColor"];
            NSString *str = [NSString stringWithFormat:@"%@", row.value];
            row.value = [str stringByAppendingString:@" (high)"];
            
            if ([row.value integerValue] >= 180) [self showWarningForParameter:@"BP Systolic"];
            
        } else if  ([row.value integerValue] >= 130) {
            [row.cellConfig setObject:[UIColor orangeColor] forKey:@"textField.textColor"];
            NSString *str = [NSString stringWithFormat:@"%@", row.value];
            row.value = [str stringByAppendingString:@" (borderline high)"];
        } else {
            [row.cellConfig setObject:[UIColor blackColor] forKey:@"textField.textColor"];
        }
        [self updateFormRow:row];
    }
    
    else if ([row.tag isEqualToString:kCbg]) {
        if ([row.value doubleValue] >= 11.1) {
            [row.cellConfig setObject:[UIColor redColor] forKey:@"textField.textColor"];
            NSString *str = [NSString stringWithFormat:@"%@", row.value];
            row.value = [str stringByAppendingString:@" (high)"];
            
            if ([row.value doubleValue] >= 15.0) [self showWarningForParameter:@"CBG"];
        } else {
            [row.cellConfig setObject:[UIColor blackColor] forKey:@"textField.textColor"];
            
            if ([row.value doubleValue] <= 2.5) [self showWarningForParameter:@"CBG"];
        }
        [self updateFormRow:row];
    } else if ([row.tag isEqualToString:kBmi]) {
        NSString *str = [NSString stringWithFormat:@"%@", row.value];
        if ([row.value doubleValue] >= 27.5) {
            [row.cellConfig setObject:[UIColor redColor] forKey:@"textField.textColor"];
            row.value = [str stringByAppendingString:@" (obese)"];
        } else if ([row.value doubleValue] > 23.0) {
            [row.cellConfig setObject:[UIColor orangeColor] forKey:@"textField.textColor"];
            row.value = [str stringByAppendingString:@" (overweight)"];
        } else {
            [row.cellConfig setObject:[UIColor blackColor] forKey:@"textField.textColor"];
        }
        [self updateFormRow:row];
    }
}


#pragma mark - Warning
- (void) showWarningForParameter: (NSString *) parameter {
    
    if (!tableDidEndEditing) return;
    else {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Take note", nil)
                                                                                  message:[NSString stringWithFormat:@"The resident’s %@ falls within the emergency range. Please inform the Emergency IC / any nearby committee member immediately.", parameter]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction){
                                                              //do nothing for now
                                                              tableDidEndEditing = false;
                                                              [self.tableView endEditing:YES];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
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

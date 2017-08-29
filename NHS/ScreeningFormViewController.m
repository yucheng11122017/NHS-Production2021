//
//  ScreeningFormViewController.m
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ScreeningFormViewController.h"
#import "PreRegFormViewController.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "KAStatusBar.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"

//XLForms stuffs
#import "XLForm.h"

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

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

typedef enum typeOfForm {
    NewScreeningForm,
    PreRegisteredScreeningForm,
    LoadedDraftScreeningForm,
    ViewScreenedScreeningForm
} typeOfForm;



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

//Demographics

//Current Physical Issues
NSString *const kMultiADL = @"multi_adl";

@interface ScreeningFormViewController () {
    NetworkStatus status;
    NSString *gender;
    NSArray *spoken_lang_value;
    XLFormRowDescriptor *preEdScoreRow, *postEdScoreRow, *showPostEdSectionBtnRow;
    XLFormSectionDescriptor *preEdSection, *postEdSection;
    NSString *neighbourhood, *citizenship;
    NSNumber *age;
    BOOL noChas, lowIncome, wantChas;
    BOOL age40, chronicCond, wantFreeBt; //for phleb
    BOOL sporeanPr, age50, relColorectCancer, colon3Yrs, wantColRef, disableFIT;
    BOOL fit12Mths, colonsc10Yrs, wantFitKit;
    BOOL sporean, age5069 ,noMammo2Yrs, hasChas, wantMammo;
    BOOL age2569, noPapSmear3Yrs, hadSex, wantPapSmear;
    BOOL age65, feelFall, scaredFall, fallen12Mths;
}

@end

@implementation ScreeningFormViewController

- (void)viewDidLoad {
    
    XLFormViewController *form;

    citizenship = [[NSUserDefaults standardUserDefaults]
                            stringForKey:kCitizenship];
    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                             stringForKey:kResidentAge];
    gender = [[NSUserDefaults standardUserDefaults]
              stringForKey:kGender];
    neighbourhood = [[NSUserDefaults standardUserDefaults]
              stringForKey:kNeighbourhood];
    
    
    //must init first before [super viewDidLoad]
    switch([self.sectionID integerValue]) {
//
        case 0: form = [self initPhlebotomy];
            break;
        case 1: form = [self initModeOfScreening];
            break;
        case 2: form = [self initProfiling];
            break;
        case 5: form = [self initTriage];
            break;
        case 6: form = [self initSnellenEyeTest];
            break;
        case 7: form = [self initAdditionalSvcs];
            break;
        case 8: form = [self initRefForDoctorConsult];
            break;
        case 9: form = [self initDentalCheckup];
            break;
        case 11: form = [self initFallRiskAssessment];
            break;
        case 12: form = [self initDementiaAssessment];
            break;
        case 13: form = [self initHealthEducation];
            break;
    }
    
    self.form.addAsteriskToRequiredRowsTitle = YES;
    
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
//    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(returnBtnPressed:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Validate" style:UIBarButtonItemStyleDone target:self action:@selector(validateBtnPressed:)];
//    if ([_formType integerValue] == ViewScreenedScreeningForm) {
//        self.navigationItem.rightBarButtonItem.title = @"Edit";
//        [self.form setDisabled:YES];
//    }
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated {
//    [self saveEntriesIntoDictionary];
    [KAStatusBar dismiss];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFullScreeningForm"
                                                        object:nil
                                                      userInfo:nil];
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

- (id) initPhlebotomy {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Phlebotomy"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    sporeanPr = age40 = false;
    
    NSDictionary *phlebotomyEligibDict = _fullScreeningForm[SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT];
    NSDictionary *phlebotomyDict = _fullScreeningForm[SECTION_PHLEBOTOMY];
    
    // Phlebotomy Eligibility Assessment - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Phlebotomy Eligibility Assessment"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *sporeanPrRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean/PR"];
    [self setDefaultFontWithRow:sporeanPrRow];
    sporeanPrRow.required = NO;
    sporeanPrRow.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) {
        sporeanPrRow.value = @1;
        sporeanPr = YES;
    }
    else {
        sporeanPrRow.value = @0;
        sporeanPr = NO;
    }
    [section addFormRow:sporeanPrRow];
    
    XLFormRowDescriptor *age40Row = [XLFormRowDescriptor formRowDescriptorWithTag:kAge40 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 40 and above?"];
    [self setDefaultFontWithRow:age40Row];
    age40Row.disabled = @(1);
    if ([age integerValue] >= 40) {
        age40Row.value = @1;
        age40 = YES;
    }
    else {
        age40Row.value = @0;
        age40 = NO;
    }
    [section addFormRow:age40Row];
    
    XLFormRowDescriptor *chronicCondRow = [XLFormRowDescriptor formRowDescriptorWithTag:kChronicCond rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"No previously diagnosed chronic condition OR Diagnosed with chronic condition but not under regular follow-up with primary care physician?"];
    if (phlebotomyEligibDict != (id)[NSNull null] && [phlebotomyEligibDict objectForKey:kChronicCond] != (id)[NSNull null]) {
        chronicCondRow.value = phlebotomyEligibDict[kChronicCond];
        chronicCond = [chronicCondRow.value boolValue];
    }
    [self setDefaultFontWithRow:chronicCondRow];
    chronicCondRow.required = YES;
    chronicCondRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:chronicCondRow];
    
    
    
    XLFormRowDescriptor *wantFreeBtRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantFreeBt rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free blood test?"];
    [self setDefaultFontWithRow:wantFreeBtRow];
    if (phlebotomyEligibDict != (id)[NSNull null] && [phlebotomyEligibDict objectForKey:kWantFreeBt] != (id)[NSNull null]) {
        wantFreeBtRow.value = phlebotomyEligibDict[kWantFreeBt];
        wantFreeBt = [wantFreeBtRow.value boolValue];
    }
    wantFreeBtRow.required = YES;
    wantFreeBtRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:wantFreeBtRow];
    
    XLFormRowDescriptor *didPhlebRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDidPhleb rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Undergone Phlebotomy?"];
    if (phlebotomyEligibDict != (id)[NSNull null] && [phlebotomyEligibDict objectForKey:kDidPhleb] != (id)[NSNull null])
        didPhlebRow.value = phlebotomyEligibDict[kDidPhleb];
    
    [self setDefaultFontWithRow:didPhlebRow];
    didPhlebRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    didPhlebRow.disabled = [NSNumber numberWithBool:!(age40 && sporeanPr && chronicCond && kWantFreeBt)];
    [section addFormRow:didPhlebRow];
    
    chronicCondRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1])
                chronicCond = YES;
            else
                chronicCond = NO;
            
            if (sporeanPr && age40 && chronicCond && wantFreeBt) {
                didPhlebRow.disabled = @NO;
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyPhleb];
            } else {
                didPhlebRow.disabled = @YES;
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyPhleb];
            }
            
            [self reloadFormRow:didPhlebRow];
        }
    };
    
    wantFreeBtRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1])
                wantFreeBt = YES;
            else
                wantFreeBt = NO;
            
            if (sporeanPr && age40 && chronicCond && wantFreeBt) {
                didPhlebRow.disabled = @NO;
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyPhleb];
            } else {
                didPhlebRow.disabled = @YES;
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyPhleb];
            }
            [self reloadFormRow:didPhlebRow];
            
        }
    };
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *glucoseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFastingBloodGlucose rowType:XLFormRowDescriptorTypeDecimal title:@"Fasting blood glucose (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) glucoseRow.value = phlebotomyDict[kFastingBloodGlucose];
    [self setDefaultFontWithRow:glucoseRow];
    [section addFormRow:glucoseRow];
    
    XLFormRowDescriptor *triglyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTriglycerides rowType:XLFormRowDescriptorTypeDecimal title:@"Triglycerides (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) triglyRow.value = phlebotomyDict[kTriglycerides];
    [self setDefaultFontWithRow:triglyRow];
    [section addFormRow:triglyRow];
    
    XLFormRowDescriptor *ldlRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLDL rowType:XLFormRowDescriptorTypeDecimal title:@"LDL Cholesterol (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) ldlRow.value = phlebotomyDict[kLDL];
    [self setDefaultFontWithRow:ldlRow];
    [section addFormRow:ldlRow];
    
    XLFormRowDescriptor *hdlRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHDL rowType:XLFormRowDescriptorTypeDecimal title:@"HDL Cholesterol (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) hdlRow.value = phlebotomyDict[kHDL];
    [self setDefaultFontWithRow:hdlRow];
    hdlRow.required = NO;
    [section addFormRow:hdlRow];
    
    XLFormRowDescriptor *totCholesterolRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTotCholesterol rowType:XLFormRowDescriptorTypeDecimal title:@"Total Cholesterol (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) totCholesterolRow.value = phlebotomyDict[kTotCholesterol];
    [self setDefaultFontWithRow:totCholesterolRow];
    [section addFormRow:totCholesterolRow];
    
    XLFormRowDescriptor *cholesHdlRatioRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCholesterolHdlRatio rowType:XLFormRowDescriptorTypeDecimal title:@"Cholesterol/HDL ratio"];
    if (phlebotomyDict != (id)[NSNull null]) cholesHdlRatioRow.value = phlebotomyDict[kCholesterolHdlRatio];
    [self setDefaultFontWithRow:cholesHdlRatioRow];
    [section addFormRow:cholesHdlRatioRow];
    
    //For initial condition
    if ([didPhlebRow.value isEqual:@1]) {
        glucoseRow.disabled = @0;
        triglyRow.disabled = @0;
        hdlRow.disabled = @0;
        ldlRow.disabled = @0;
        totCholesterolRow.disabled = @0;
        cholesHdlRatioRow.disabled = @0;
    } else {
        glucoseRow.disabled = @1;
        triglyRow.disabled = @1;
        hdlRow.disabled = @1;
        ldlRow.disabled = @1;
        totCholesterolRow.disabled = @1;
        cholesHdlRatioRow.disabled = @1;
    }
    
    // For when user make changes
    didPhlebRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                glucoseRow.disabled = @0;
                triglyRow.disabled = @0;
                hdlRow.disabled = @0;
                ldlRow.disabled = @0;
                totCholesterolRow.disabled = @0;
                cholesHdlRatioRow.disabled = @0;
            } else {
                glucoseRow.disabled = @1;
                triglyRow.disabled = @1;
                hdlRow.disabled = @1;
                ldlRow.disabled = @1;
                totCholesterolRow.disabled = @1;
                cholesHdlRatioRow.disabled = @1;
            }
            
            [self reloadFormRow:glucoseRow];
            [self reloadFormRow:triglyRow];
            [self reloadFormRow:hdlRow];
            [self reloadFormRow:ldlRow];
            [self reloadFormRow:totCholesterolRow];
            [self reloadFormRow:cholesHdlRatioRow];
        }
    };
    
    return [super initWithForm:formDescriptor];
}


-(id)initModeOfScreening {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Mode of Screening"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *modeOfScreening = _fullScreeningForm[SECTION_MODE_OF_SCREENING];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *qualifyPhleb = [defaults objectForKey:kQualifyPhleb];
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *screenModeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kScreenMode rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Pick one"];
    if (modeOfScreening != (id)[NSNull null]) screenModeRow.value = modeOfScreening[kScreenMode];
    screenModeRow.selectorOptions = @[@"Centralised", @"Door-to-door"];
    screenModeRow.required = YES;
    [self setDefaultFontWithRow:screenModeRow];
    [section addFormRow:screenModeRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApptDate rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Door-to-Door Date"];
    if (modeOfScreening != (id)[NSNull null]) row.value = modeOfScreening[kApptDate];
    row.noValueDisplayText = @"Tap here";
    [self setDefaultFontWithRow:row];
    
    if ([neighbourhood isEqualToString:@"Eunos Crescent"]) {
        row.selectorOptions = @[@"9 Sept", @"10 Sept"];
    } else {
        row.selectorOptions = @[@"7 Oct", @"8 Oct"];
    }
    row.required = NO;
    row.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApptTime rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Door-to-Door Time"];
    row.selectorOptions= @[@"8am-10am", @"10am-12pm", @"12pm-2pm", @"2pm-4pm"];
    row.value = [self getScreeningTimeArrayFromDict:modeOfScreening andOptions:row.selectorOptions];
//    if (modeOfScreening != (id)[NSNull null]) row.value = modeOfScreening[kApptTime];     //no value for now
    row.noValueDisplayText = @"Tap here";
    
    row.required = NO;
    row.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    XLFormRowDescriptor *phlebApptRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhlebAppt rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Phlebotomy Appointment"];
    phlebApptRow.required = NO;
    
    if ([screenModeRow.value isEqualToString:@"Door-to-door"] && [qualifyPhleb isEqualToString:@"1"])
        phlebApptRow.disabled = @0;
    else
        phlebApptRow.disabled = @1;
    
    
    if ([neighbourhood isEqualToString:@"Eunos Crescent"]) {
        phlebApptRow.selectorOptions = @[@"9 Sept, 8-11am", @"10 Sept, 8-11am"];
    } else {
        phlebApptRow.selectorOptions = @[@"7 Oct, 8-11am", @"8 Oct, 8-11am"];
    }
    phlebApptRow.noValueDisplayText = @"Tap here";
    if (modeOfScreening != (id)[NSNull null]) phlebApptRow.value = modeOfScreening[kPhlebAppt];
    [self setDefaultFontWithRow:phlebApptRow];
    [section addFormRow:phlebApptRow];
    
    screenModeRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *qualifyPhleb = [defaults objectForKey:kQualifyPhleb];
            
            if ([newValue isEqualToString:@"Door-to-door"] && [qualifyPhleb isEqualToString:@"1"]) {    //need to be door-to-door and qualify for phleb too!
                phlebApptRow.disabled = @0;
            } else {
                phlebApptRow.disabled = @1;
            }
            [self reloadFormRow:phlebApptRow];
        }
    };
    
    return [super initWithForm:formDescriptor];
}



-(id) initProfiling {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Profiling"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    noChas = lowIncome = wantChas = false;
    sporeanPr = age50 = relColorectCancer = colon3Yrs = wantColRef = disableFIT = false;
    fit12Mths = colonsc10Yrs = wantFitKit = false;
    age5069 = noMammo2Yrs = hasChas = wantMammo = false;
    age2569 = noPapSmear3Yrs = hadSex = wantPapSmear = false;
    
    NSDictionary *profilingDict = _fullScreeningForm[SECTION_PROFILING_SOCIOECON];
    NSDictionary *chasPrelimDict = _fullScreeningForm[SECTION_CHAS_PRELIM];
    NSDictionary *colonscoEligibDict = _fullScreeningForm[SECTION_COLONOSCOPY_ELIGIBLE];
    NSDictionary *fitEligibDict = _fullScreeningForm[SECTION_FIT_ELIGIBLE];
    NSDictionary *mammoEligibDict = _fullScreeningForm[SECTION_MAMMOGRAM_ELIGIBLE];
    NSDictionary *papSmearEligibDict = _fullScreeningForm[SECTION_PAP_SMEAR_ELIGIBLE];
    NSDictionary *fallRiskEligib = _fullScreeningForm[SECTION_FALL_RISK_ELIGIBLE];
    NSDictionary *geriaDementAssmtDict = _fullScreeningForm[SECTION_GERIATRIC_DEMENTIA_ELIGIBLE];
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kProfilingConsent rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Consent to disclosure of information"];
//    if (profilingDict != (id)[NSNull null] && [profilingDict objectForKey:kProfilingConsent] != (id)[NSNull null]) row.value = profilingDict[kProfilingConsent];
#warning no values for now...
    row.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.required = YES;
    [section addFormRow:row];
    
    // Resident's Socioeconomic status - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Resident's Socioeconomic Status"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *employmentRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStat rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Employment status"];
    if (profilingDict != (id)[NSNull null]) employmentRow.value = profilingDict[kEmployStat];
    [self setDefaultFontWithRow:employmentRow];
    employmentRow.required = NO;
    employmentRow.selectorOptions = @[@"Retired", @"Housewife/Homemaker",@"Self-employed",@"Part-time employed",@"Full-time employed", @"Unemployed", @"Others"];
    [section addFormRow:employmentRow];
    
    XLFormRowDescriptor *unemployReasonsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployReasons rowType:XLFormRowDescriptorTypeTextView title:@""];
    if (profilingDict != (id)[NSNull null]) unemployReasonsRow.value = profilingDict[kEmployReasons];
    [self setDefaultFontWithRow:unemployReasonsRow];
    unemployReasonsRow.required = NO;
    unemployReasonsRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Unemployed'", employmentRow];
    [unemployReasonsRow.cellConfigAtConfigure setObject:@"Reasons for unemployment" forKey:@"textView.placeholder"];
//    [unemployReasonsRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textView.textAlignment"];
    [section addFormRow:unemployReasonsRow];
    
    XLFormRowDescriptor *otherEmployRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployOthers rowType:XLFormRowDescriptorTypeText title:@"Other employment"];
    if (profilingDict != (id)[NSNull null]) otherEmployRow.value = profilingDict[kEmployOthers];
    [self setDefaultFontWithRow:otherEmployRow];
    otherEmployRow.required = NO;
    otherEmployRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", employmentRow];
    [otherEmployRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:otherEmployRow];
    
    XLFormRowDescriptor *noDiscloseIncomeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiscloseIncome rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Resident does not want to disclose income"];
    if (profilingDict != (id)[NSNull null] && [profilingDict objectForKey:kDiscloseIncome] != (id)[NSNull null]) noDiscloseIncomeRow.value = profilingDict[kProfilingConsent];
    [self setDefaultFontWithRow:noDiscloseIncomeRow];
//    noDiscloseIncomeRow.selectorOptions = @[@"Yes", @"No"];
    noDiscloseIncomeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noDiscloseIncomeRow.required = NO;
    [section addFormRow:noDiscloseIncomeRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *mthHouseIncome = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgMthHouseIncome rowType:XLFormRowDescriptorTypeDecimal title:@"Average monthly household income"];
    if (profilingDict != (id)[NSNull null]) mthHouseIncome.value = profilingDict[kAvgMthHouseIncome];
    [self setDefaultFontWithRow:mthHouseIncome];
    [mthHouseIncome.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [mthHouseIncome.cellConfigAtConfigure setObject:@"Enter here" forKey:@"textField.placeholder"];
    mthHouseIncome.cellConfig[@"textLabel.numberOfLines"] = @0;
    mthHouseIncome.required = NO;
    [section addFormRow:mthHouseIncome];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

    XLFormRowDescriptor *noOfPplInHouse = [XLFormRowDescriptor formRowDescriptorWithTag:kNumPplInHouse rowType:XLFormRowDescriptorTypeInteger title:@"No. of people in the household"];
    if (profilingDict != (id)[NSNull null]) noOfPplInHouse.value = profilingDict[kNumPplInHouse];
    [self setDefaultFontWithRow:noOfPplInHouse];
    [noOfPplInHouse.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    noOfPplInHouse.cellConfig[@"textLabel.numberOfLines"] = @0;
    [noOfPplInHouse addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be greater than 0" regex:@"^[1-9][0-9]*$"]];
    noOfPplInHouse.required = NO;
    [section addFormRow:noOfPplInHouse];
    
    XLFormRowDescriptor *avgIncomePerHead = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgIncomePerHead rowType:XLFormRowDescriptorTypeDecimal title:@"Average income per head"];   //auto-calculate
    if (profilingDict != (id)[NSNull null]) avgIncomePerHead.value = profilingDict[avgIncomePerHead];
    [self setDefaultFontWithRow:avgIncomePerHead];
    [avgIncomePerHead.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    avgIncomePerHead.required = NO;
    
    if (mthHouseIncome.value != (id) [NSNull null] && noOfPplInHouse.value != (id)[NSNull null]) {
        if (!isnan([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])) {  //check for not nan first!
            avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", [mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue]];
        }
    }
    
    avgIncomePerHead.disabled = @(1);
    [section addFormRow:avgIncomePerHead];

    mthHouseIncome.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([mthHouseIncome.value integerValue] != 0 && [noOfPplInHouse.value integerValue] != 0) {
                avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", ([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])];
                [self updateFormRow:avgIncomePerHead];
            }
        }
    };
    noOfPplInHouse.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([mthHouseIncome.value integerValue] != 0 && [noOfPplInHouse.value integerValue] != 0) {
                avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", ([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])];
                [self updateFormRow:avgIncomePerHead];
            }
        }
    };
    
    // CHAS Preliminary Eligibiliy Assessment - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"CHAS Preliminary Eligibility Assessment"];
    [formDescriptor addFormSection:section];

    XLFormRowDescriptor *chasNoChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDoesntOwnChasPioneer rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does not currently own a CHAS card (blue/orange) or pioneer generation card"];
    if (chasPrelimDict != (id)[NSNull null] && [chasPrelimDict objectForKey:kDoesntOwnChasPioneer] != (id)[NSNull null]) chasNoChasRow.value = chasPrelimDict[kDoesntOwnChasPioneer];
    [self setDefaultFontWithRow:chasNoChasRow];
    chasNoChasRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    chasNoChasRow.required = NO;
    [section addFormRow:chasNoChasRow];
    
    chasNoChasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                noChas = TRUE;
            } else {
                noChas = FALSE;
            }
            if (noChas && lowIncome && wantChas) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyCHAS];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyCHAS];
            }
            
        }
    };
    
    XLFormRowDescriptor *lowHouseIncomeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLowHouseIncome rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"For households with income: Household monthly income per person is $1800 and below \nOR\nFor households with no income: Annual Value (AV) of home is $21,000 and below"];
    if (chasPrelimDict != (id)[NSNull null] && [chasPrelimDict objectForKey:kLowHouseIncome] != (id)[NSNull null]) lowHouseIncomeRow.value = chasPrelimDict[kLowHouseIncome];
    [self setDefaultFontWithRow:lowHouseIncomeRow];
    lowHouseIncomeRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    lowHouseIncomeRow.required = NO;
    [section addFormRow:lowHouseIncomeRow];
    
    lowHouseIncomeRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                lowIncome = TRUE;
            } else {
                lowIncome = FALSE;
            }
            if (noChas && lowIncome && wantChas) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyCHAS];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyCHAS];
            }
            
        }
    };
    
    XLFormRowDescriptor *wantChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantChas rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want to apply for CHAS?"];
    if (chasPrelimDict != (id)[NSNull null] && [chasPrelimDict objectForKey:kWantChas] != (id)[NSNull null]) wantChasRow.value = chasPrelimDict[kWantChas];
    [self setDefaultFontWithRow:wantChasRow];
    wantChasRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantChasRow.required = NO;
    [section addFormRow:wantChasRow];
    
    wantChasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                wantChas = TRUE;
            } else {
                wantChas = FALSE;
            }
            if (noChas && lowIncome && wantChas) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyCHAS];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyCHAS];
            }
            
        }
    };
    
    // Disable all income related questions if not willing to disclose income
    noDiscloseIncomeRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqual:@(1)]) {
                mthHouseIncome.disabled = @(1);
                noOfPplInHouse.disabled = @(1);
                avgIncomePerHead.disabled = @(1);
                chasNoChasRow.disabled = @(1);
                wantChasRow.disabled = @(1);
                lowHouseIncomeRow.disabled = @(1);

            } else {
                mthHouseIncome.disabled = @(0);
                noOfPplInHouse.disabled = @(0);
                avgIncomePerHead.disabled = @(0);
                chasNoChasRow.disabled = @(0);
                wantChasRow.disabled = @(0);
                lowHouseIncomeRow.disabled = @(0);
            }
            
            [self reloadFormRow:mthHouseIncome];
            [self reloadFormRow:noOfPplInHouse];
            [self reloadFormRow:avgIncomePerHead];
            [self reloadFormRow:chasNoChasRow];
            [self reloadFormRow:wantChasRow];
            [self reloadFormRow:lowHouseIncomeRow];
        }
    };

    // Eligibility Assessment for Colonoscopy - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility Assessment for Colonoscopy"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *sporeanPrRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean/PR"];
    [self setDefaultFontWithRow:sporeanPrRow];
    sporeanPrRow.required = NO;
    sporeanPrRow.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) {
        sporeanPrRow.value = @1;
        sporeanPr = YES;
    }
    else {
        sporeanPrRow.value = @0;
        sporeanPr = NO;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
    }
    [section addFormRow:sporeanPrRow];
    
    XLFormRowDescriptor *age50Row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove50 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 50 and above"];
    [self setDefaultFontWithRow:age50Row];
    age50Row.required = NO;
    age50Row.disabled = @(1);
    if ([age integerValue] >= 50) {
        age50Row.value = @1;
        age50 = YES;
    }
    else {
        age50Row.value = @0;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
        age50 = NO;
    }
    [section addFormRow:age50Row];
    
    XLFormRowDescriptor *relColCancerRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelWColorectCancer rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"First degree relative with colorectal cancer?"];
    if (colonscoEligibDict != (id)[NSNull null] && [colonscoEligibDict objectForKey:kRelWColorectCancer] != (id)[NSNull null]) relColCancerRow.value = colonscoEligibDict[kRelWColorectCancer];
    [self setDefaultFontWithRow:relColCancerRow];
    relColCancerRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    relColCancerRow.required = NO;
    [section addFormRow:relColCancerRow];
    
    
    XLFormRowDescriptor *colon3yrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kColonoscopy3yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done colonoscopy in the past 3 years?"];
    if (colonscoEligibDict != (id)[NSNull null] && [colonscoEligibDict objectForKey:kColonoscopy3yrs] != (id)[NSNull null]) colon3yrsRow.value = colonscoEligibDict[kColonoscopy3yrs];
    [self setDefaultFontWithRow:colon3yrsRow];
    colon3yrsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    colon3yrsRow.required = NO;
    [section addFormRow:colon3yrsRow];
    
    XLFormRowDescriptor *wantColonRefRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantColonoscopyRef rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a referral for free colonoscopy?"];
    if (colonscoEligibDict != (id)[NSNull null] && [colonscoEligibDict objectForKey:kWantColonoscopyRef] != (id)[NSNull null]) wantColonRefRow.value = colonscoEligibDict[kWantColonoscopyRef];
    [self setDefaultFontWithRow:wantColonRefRow];
    wantColonRefRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantColonRefRow.required = NO;
    [section addFormRow:wantColonRefRow];
    
    // Eligibility Assessment for FIT - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility Assessment for FIT"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean/PR"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) {
        sporeanPr = true;
        row.value = @1;
    }
    else {
        sporeanPr = false;
        row.value = @0;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyFIT];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove50 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 50 and above"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.disabled = @(1);
    if ([age integerValue] >= 50) {
        age50 = true;
        row.value = @1;
    }
    else {
        age50 = false;
        row.value = @0;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFIT];
    }
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *fitLast12MthsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFitLast12Mths rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done FIT in the last 12 months?"];
    if (fitEligibDict != (id)[NSNull null] && [fitEligibDict objectForKey:kFitLast12Mths] != (id)[NSNull null]) fitLast12MthsRow.value = fitEligibDict[kFitLast12Mths];
    [self setDefaultFontWithRow:fitLast12MthsRow];
    fitLast12MthsRow.required = NO;
    fitLast12MthsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:fitLast12MthsRow];
    
    fitLast12MthsRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                fit12Mths = TRUE;
            } else {
                fit12Mths = FALSE;
            }
            if (sporeanPr && age50 && fit12Mths && colonsc10Yrs && wantFitKit) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyFIT];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFIT];
            }
            
        }
    };
    
    XLFormRowDescriptor *colonoscopy10YrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kColonoscopy10Yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done colonoscopy in the past 10 years?"];
    if (fitEligibDict != (id)[NSNull null] && [fitEligibDict objectForKey:kColonoscopy10Yrs] != (id)[NSNull null]) colonoscopy10YrsRow.value = fitEligibDict[kColonoscopy10Yrs];
    [self setDefaultFontWithRow:colonoscopy10YrsRow];
    colonoscopy10YrsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    colonoscopy10YrsRow.required = NO;
    [section addFormRow:colonoscopy10YrsRow];
    
    colonoscopy10YrsRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                colonsc10Yrs = TRUE;
            } else {
                colonsc10Yrs = FALSE;
            }
            if (sporeanPr && age50 && fit12Mths && colonsc10Yrs && wantFitKit) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyFIT];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFIT];
            }
            
        }
    };
    
    XLFormRowDescriptor *wantFitKitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantFitKit rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free FIT kit?"];
    if (fitEligibDict != (id)[NSNull null] && [fitEligibDict objectForKey:kWantFitKit] != (id)[NSNull null]) wantFitKitRow.value = fitEligibDict[kWantFitKit];
    [self setDefaultFontWithRow:wantFitKitRow];
    wantFitKitRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantFitKitRow.required = NO;
    [section addFormRow:wantFitKitRow];
    
    wantFitKitRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                wantFitKit = TRUE;
            } else {
                wantFitKit = FALSE;
            }
            if (sporeanPr && age50 && fit12Mths && colonsc10Yrs && wantFitKit) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyFIT];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFIT];
            }
            
        }
    };
    
    relColCancerRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqual:@(1)])  relColorectCancer = true;
            else relColorectCancer = false;
        }
        
        if (sporeanPr && age50 && relColorectCancer && colon3Yrs && wantColRef) {
            disableFIT = true;
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyFIT];
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kQualifyColonsc];
        }
        else disableFIT = false;
        fitLast12MthsRow.disabled = [NSNumber numberWithBool:disableFIT];
        colonoscopy10YrsRow.disabled = [NSNumber numberWithBool:disableFIT];
        wantFitKitRow.disabled = [NSNumber numberWithBool:disableFIT];
        [self reloadFormRow:fitLast12MthsRow];
        [self reloadFormRow:colonoscopy10YrsRow];
        [self reloadFormRow:wantFitKitRow];
        
    };
    
    colon3yrsRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqual:@(1)]) colon3Yrs  = true;
            else colon3Yrs = false;
        }
        
        if (sporeanPr && age50 && relColorectCancer && colon3Yrs && wantColRef) {
            disableFIT = true;
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyFIT];
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kQualifyColonsc];
        }
        else disableFIT = false;
        
        fitLast12MthsRow.disabled = [NSNumber numberWithBool:disableFIT];
        colonoscopy10YrsRow.disabled = [NSNumber numberWithBool:disableFIT];
        wantFitKitRow.disabled = [NSNumber numberWithBool:disableFIT];
        [self reloadFormRow:fitLast12MthsRow];
        [self reloadFormRow:colonoscopy10YrsRow];
        [self reloadFormRow:wantFitKitRow];

    };
    
    wantColonRefRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqual:@(1)]) wantColRef  = true;
            else wantColRef = false;
        }
        
        if (sporeanPr && age50 && relColorectCancer && colon3Yrs && wantColRef) {
            disableFIT = true;
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyFIT];
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kQualifyColonsc];
        }
        else disableFIT = false;
        fitLast12MthsRow.disabled = [NSNumber numberWithBool:disableFIT];
        colonoscopy10YrsRow.disabled = [NSNumber numberWithBool:disableFIT];
        wantFitKitRow.disabled = [NSNumber numberWithBool:disableFIT];
        [self reloadFormRow:fitLast12MthsRow];
        [self reloadFormRow:colonoscopy10YrsRow];
        [self reloadFormRow:wantFitKitRow];

    };
    
    
    
    
    BOOL isMale;
    if ([gender isEqualToString:@"M"]) {
        isMale=true;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyPapSmear];
    }
    else isMale = false;
    
    // Eligibility Assessment for Mammogram - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility Assessment for Mammogram"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"]) {
        sporean = YES;
        row.value = @1;
    }
    else {
        sporean = NO;
        row.value = @0;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
    }
    
//    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeCheck rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 50 to 69"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.disabled = @(1);
    if (([age integerValue] >= 50) && ([age integerValue] < 70)) {
        row.value = @1;
        age5069 = YES;
    }
    else {
        row.value = @0;
        age5069 = NO;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
    }
    
//    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    XLFormRowDescriptor *mammo2YrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMammo2Yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done mammogram in the last 2 years?"];
    if (mammoEligibDict != (id)[NSNull null] && [mammoEligibDict objectForKey:kMammo2Yrs] != (id)[NSNull null]) mammo2YrsRow.value = mammoEligibDict[kMammo2Yrs];
    [self setDefaultFontWithRow:mammo2YrsRow];
    mammo2YrsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    mammo2YrsRow.required = NO;
    mammo2YrsRow.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:mammo2YrsRow];
    
    mammo2YrsRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                noMammo2Yrs = TRUE;
            } else {
                noMammo2Yrs = FALSE;
            }
            if (sporean && age5069 && noMammo2Yrs && hasChas && wantMammo) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyMammo];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyMammo];
            }
                
        }
    };
    
    XLFormRowDescriptor *hasChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHasChas rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has a valid CHAS card (blue/orange)"];
    if (mammoEligibDict != (id)[NSNull null] && [mammoEligibDict objectForKey:kHasChas] != (id)[NSNull null]) hasChasRow.value = mammoEligibDict[kHasChas];
    [self setDefaultFontWithRow:hasChasRow];
    hasChasRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    hasChasRow.required = NO;
    hasChasRow.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:hasChasRow];
    
    hasChasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                hasChas = TRUE;
            } else {
                hasChas = FALSE;
            }
            if (sporean && age5069 && noMammo2Yrs && hasChas && wantMammo) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyMammo];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyMammo];
            }
        }
    };
    
    XLFormRowDescriptor *wantMammoRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantMammo rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free mammogram referral?"];
    if (mammoEligibDict != (id)[NSNull null] && [mammoEligibDict objectForKey:kWantMammo] != (id)[NSNull null]) wantMammoRow.value = mammoEligibDict[kWantMammo];
    [self setDefaultFontWithRow:wantMammoRow];
    wantMammoRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantMammoRow.required = NO;
    wantMammoRow.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:wantMammoRow];
    
    wantMammoRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                wantMammo = TRUE;
            } else {
                wantMammo = FALSE;
            }
            if (sporean && age5069 && noMammo2Yrs && hasChas && wantMammo) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyMammo];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyMammo];
            }
        }
    };
    
    // Eligibility Assessment for pap smear - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility Assessment for Pap Smear"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean/PR"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) {
        sporeanPr = YES;
        row.value = @1;
    }
    else {
        sporeanPr = NO;
        row.value = @0;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyPapSmear];
    }
//    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeCheck2 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 25 to 69"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.disabled = @(1);
    if (([age integerValue] >= 25) && ([age integerValue] < 70)) {
        age5069 = YES;
        row.value = @1;
    }
    else {
        age5069 = NO;
        row.value = @0;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyPapSmear];
    }
//    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPap3Yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done pap smear in the last 3 years?"];
    if (papSmearEligibDict != (id)[NSNull null] && [papSmearEligibDict objectForKey:kPap3Yrs] != (id)[NSNull null]) row.value = papSmearEligibDict[kPap3Yrs];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                noPapSmear3Yrs = TRUE;
            } else {
                noPapSmear3Yrs = FALSE;
            }
            if (sporean && age5069 && noPapSmear3Yrs && hadSex && wantPapSmear) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyPapSmear];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyPapSmear];
            }
            
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEngagedSex rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has engaged in sexual intercourse before"];
    if (papSmearEligibDict != (id)[NSNull null] && [papSmearEligibDict objectForKey:kEngagedSex] != (id)[NSNull null]) row.value = papSmearEligibDict[kEngagedSex];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                hadSex = TRUE;
            } else {
                hadSex = FALSE;
            }
            if (sporean && age5069 && noPapSmear3Yrs && hadSex && wantPapSmear) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyPapSmear];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyPapSmear];
            }
            
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kWantPap rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free pap smear referral?"];
    if (papSmearEligibDict != (id)[NSNull null] && [papSmearEligibDict objectForKey:kWantPap] != (id)[NSNull null]) row.value = papSmearEligibDict[kWantPap];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                wantPapSmear = TRUE;
            } else {
                wantPapSmear = FALSE;
            }
            if (sporean && age5069 && noPapSmear3Yrs && hadSex && wantPapSmear) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyPapSmear];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyPapSmear];
            }
            
        }
    };

    
    // Eligibility for Fall Risk Assessment - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility for Fall Risk Assessment"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove65 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 65 and above?"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.disabled = @(1);
    if ([age integerValue] >= 65) {
        row.value = @1;
        age65 = YES;
    }
    else {
        row.value = @0;
        age65 = NO;
    }
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFallen12Mths rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Have you fallen in the past 12 months?"];
    if (fallRiskEligib != (id)[NSNull null] && [fallRiskEligib objectForKey:kFallen12Mths] != (id)[NSNull null]) row.value = fallRiskEligib[kFallen12Mths];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                fallen12Mths = TRUE;
            } else {
                fallen12Mths = FALSE;
            }
            if (age65 && (fallen12Mths || scaredFall || feelFall)) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyFallAssess];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFallAssess];
            }
            
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kScaredFall rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Do you avoid going out because you are scared of falling?"];
    if (fallRiskEligib != (id)[NSNull null] && [fallRiskEligib objectForKey:kScaredFall] != (id)[NSNull null]) row.value = fallRiskEligib[kScaredFall];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                scaredFall = TRUE;
            } else {
                scaredFall = FALSE;
            }
            if (age65 && (fallen12Mths || scaredFall || feelFall)) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyFallAssess];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFallAssess];
            }
            
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelFall rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Do you feel like you are going to fall when getting up or walking?"];
    if (fallRiskEligib != (id)[NSNull null] && [fallRiskEligib objectForKey:kFeelFall] != (id)[NSNull null]) row.value = fallRiskEligib[kFeelFall];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                feelFall = TRUE;
            } else {
                feelFall = FALSE;
            }
            if (age65 && (fallen12Mths || scaredFall || feelFall)) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyFallAssess];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFallAssess];
            }
            
        }
    };
    
    
    // Eligibility for Geriatric dementia assessment - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility for Geriatric dementia assessment"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove65 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 65 and above?"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.disabled = @(1);
    if ([age integerValue] >= 65) {
        age65 = true;
        row.value = @1;
    }
    else {
        row.value = @0;
        age65 = false;
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCognitiveImpair rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Resident shows signs of cognitive impairment(e.g. forgetfulness, carelessness, lack of awareness)"];
    if (geriaDementAssmtDict != (id)[NSNull null] && [geriaDementAssmtDict objectForKey:kCognitiveImpair] != (id)[NSNull null]) row.value = geriaDementAssmtDict[kCognitiveImpair];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@(1)] && age65) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyDementia];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyDementia];
            }
        }
    };

    return [super initWithForm:formDescriptor];
}


- (id) initTriage {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Triage"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
//    NSDictionary *clinicalResultsDict = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"clinical_results"];
//    NSArray *bpRecordsArray = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"bp_record"];
//
//    if ([_formType integerValue] == ViewScreenedScreeningForm) {
//        [formDescriptor setDisabled:YES];
//    }
    
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *systolic_1;
    systolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp1Sys rowType:XLFormRowDescriptorTypeDecimal title:@"BP 1 (Systolic)"];
    systolic_1.required = YES;
//    systolic_1.value = [[bpRecordsArray objectAtIndex:1] objectForKey:@"systolic_bp"];
    [self setDefaultFontWithRow:systolic_1];
    [section addFormRow:systolic_1];
    
    XLFormRowDescriptor *diastolic_1;
    diastolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp1Dias rowType:XLFormRowDescriptorTypeDecimal title:@"BP 1 (Diastolic)"];
    diastolic_1.required = YES;
//    diastolic_1.value = [[bpRecordsArray objectAtIndex:1] objectForKey:@"diastolic_bp"];
    [self setDefaultFontWithRow:diastolic_1];
    [section addFormRow:diastolic_1];
    
    XLFormRowDescriptor *height;
    height = [XLFormRowDescriptor formRowDescriptorWithTag:kHeightCm rowType:XLFormRowDescriptorTypeDecimal title:@"Height (cm)"];
    height.required = YES;
//    height.value = [clinicalResultsDict objectForKey:@"height_cm"];
    [self setDefaultFontWithRow:height];
    [section addFormRow:height];
    
    XLFormRowDescriptor *weight;
    weight = [XLFormRowDescriptor formRowDescriptorWithTag:kWeightKg rowType:XLFormRowDescriptorTypeDecimal title:@"Weight (kg)"];
    weight.required = YES;
//    weight.value = [clinicalResultsDict objectForKey:@"weight_kg"];
    [self setDefaultFontWithRow:weight];
    [section addFormRow:weight];
    
    XLFormRowDescriptor *bmi;
    bmi = [XLFormRowDescriptor formRowDescriptorWithTag:kBmi rowType:XLFormRowDescriptorTypeText title:@"BMI"];
//    bmi.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kHeight, kWeight]];
    //Initial value only
//    if ([clinicalResultsDict objectForKey:@"bmi"] != [NSNull null]) {
//        if (![[clinicalResultsDict objectForKey:@"bmi"] isEqualToString:@""]) {
//            bmi.value = [clinicalResultsDict objectForKey:@"bmi"];
//        } else {
//            if (!isnan([weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2))) {  //check for not nan first!
//                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
//            }
//        }
//    }
    bmi.disabled = @(1);
    [self setDefaultFontWithRow:bmi];
    [section addFormRow:bmi];
    
    weight.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([weight.value integerValue] != 0 && [height.value integerValue] != 0) {
                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
                [self updateFormRow:bmi];
            }
        }
    };
    height.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([weight.value integerValue] != 0 && [height.value integerValue] != 0) {
                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
                [self updateFormRow:bmi];
            }
        }
    };
    
    XLFormRowDescriptor *waist;
    waist = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistCircum rowType:XLFormRowDescriptorTypeDecimal title:@"Waist Circumference (cm)"];
    waist.required = YES;
//    waist.value = [clinicalResultsDict objectForKey:@"waist_circum"];
    [self setDefaultFontWithRow:waist];
    [section addFormRow:waist];
    
    XLFormRowDescriptor *hip;
    hip = [XLFormRowDescriptor formRowDescriptorWithTag:kHipCircum rowType:XLFormRowDescriptorTypeDecimal title:@"Hip Circumference (cm)"];
    hip.required = YES;
//    hip.value = [clinicalResultsDict objectForKey:@"hip_circum"];
    [self setDefaultFontWithRow:hip];
    [section addFormRow:hip];
    
    XLFormRowDescriptor *waistHipRatio;
    waistHipRatio = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistHipRatio rowType:XLFormRowDescriptorTypeText title:@"Waist : Hip Ratio"];
    waistHipRatio.required = YES;
    [self setDefaultFontWithRow:waistHipRatio];
//    waistHipRatio.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kWaistCircum, kHipCircum]];
    //Initial value
//    if(![[clinicalResultsDict objectForKey:@"waist_hip_ratio"] isEqualToString:@""]) {
//        waistHipRatio.value = [clinicalResultsDict objectForKey:@"waist_hip_ratio"];
//    }
    waistHipRatio.disabled = @(1);
    [section addFormRow:waistHipRatio];
    
    waist.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([waist.value integerValue] != 0 && [hip.value integerValue] != 0) {
                waistHipRatio.value = [NSString stringWithFormat:@"%.2f", [waist.value doubleValue] / [hip.value doubleValue]];
                [self updateFormRow:waistHipRatio];
            }
        }
    };
    hip.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([waist.value integerValue] != 0 && [hip.value integerValue] != 0) {
                waistHipRatio.value = [NSString stringWithFormat:@"%.2f", [waist.value doubleValue] / [hip.value doubleValue]];
                [self updateFormRow:waistHipRatio];
            }
        }
    };
    
    XLFormRowDescriptor *diabeticRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"diabetic" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is resident diabetic?"];
    diabeticRow.selectorOptions = @[@"Yes", @"No"];
    diabeticRow.required = YES;
    [self setDefaultFontWithRow:diabeticRow];
    [section addFormRow:diabeticRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCbg rowType:XLFormRowDescriptorTypeDecimal title:@"CBG (mmol/L)"];
    row.required = NO;
    row.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", diabeticRow];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    XLFormRowDescriptor *systolic_2;
    systolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp2Sys rowType:XLFormRowDescriptorTypeDecimal title:@"BP 2 (Systolic)"];
    systolic_2.required = YES;
//    systolic_2.value = [[bpRecordsArray objectAtIndex:2] objectForKey:@"systolic_bp"];
    [self setDefaultFontWithRow:systolic_2];
    [section addFormRow:systolic_2];
    
    XLFormRowDescriptor *diastolic_2;
    diastolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp2Dias rowType:XLFormRowDescriptorTypeDecimal title:@"BP 2 (Diastolic)"];
    diastolic_2.required = YES;
//    diastolic_2.value = [[bpRecordsArray objectAtIndex:2] objectForKey:@"diastolic_bp"];
    [self setDefaultFontWithRow:diastolic_2];
    [section addFormRow:diastolic_2];
    
    XLFormRowDescriptor *systolic_3;
    systolic_3 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp3Sys rowType:XLFormRowDescriptorTypeDecimal title:@"BP 3 (Systolic)"];
    systolic_3.required = NO;
    [systolic_3.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
//    row.value = [[bpRecordsArray objectAtIndex:3] objectForKey:@"systolic_bp"];
    [self setDefaultFontWithRow:systolic_3];
    [section addFormRow:systolic_3];
    
    XLFormRowDescriptor *diastolic_3;
    diastolic_3 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp3Dias rowType:XLFormRowDescriptorTypeDecimal title:@"BP 3 (Diastolic)"];
    [diastolic_3.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    diastolic_3.required = NO;
//    row.value = [[bpRecordsArray objectAtIndex:3] objectForKey:@"diastolic_bp"];
    [self setDefaultFontWithRow:diastolic_3];
    [section addFormRow:diastolic_3];
    
    XLFormRowDescriptor *systolic_avg;
    systolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBp12AvgSys rowType:XLFormRowDescriptorTypeText title:@"Average BP (Systolic)"];
    systolic_avg.required = YES;
//    if (![[[bpRecordsArray objectAtIndex:0] objectForKey:@"systolic_bp"] isEqualToString:@""]) {
//        systolic_avg.value = [[bpRecordsArray objectAtIndex:0] objectForKey:@"systolic_bp"];
//    }
//    systolic_avg.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kBpSystolic, kBpSystolic2]];
    systolic_avg.disabled = @(1);   //permanent
    [self setDefaultFontWithRow:systolic_avg];
    [section addFormRow:systolic_avg];
    
    systolic_1.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            systolic_avg.value = @(([systolic_1.value doubleValue]+ [systolic_2.value doubleValue])/2);
            [self updateFormRow:systolic_avg];
        }
        
    };
    
    systolic_2.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            if (systolic_3.value > 0) {
                systolic_avg.value = @(([systolic_3.value doubleValue]+ [systolic_2.value doubleValue])/2); //if BP3 is keyed in, take BP 2 and BP 3 instead.
            } else { 
                systolic_avg.value = @(([systolic_1.value doubleValue]+ [systolic_2.value doubleValue])/2);
            }
            [self updateFormRow:systolic_avg];
        }
        
    };
    
    systolic_3.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            if (newValue != (id)[NSNull null]) {
                systolic_avg.value = @(([systolic_3.value integerValue]+ [systolic_2.value integerValue])/2); //if BP3 is keyed in, take BP 2 and BP 3 instead.
            } else {
                systolic_avg.value = @(([systolic_1.value integerValue]+ [systolic_2.value integerValue])/2);
            }
            [self updateFormRow:systolic_avg];
        }
    };
    
    XLFormRowDescriptor *diastolic_avg;
    diastolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBp12AvgDias rowType:XLFormRowDescriptorTypeText title:@"Average BP (Diastolic)"];
    diastolic_avg.required = YES;
//    if (![[[bpRecordsArray objectAtIndex:0] objectForKey:@"diastolic_bp"] isEqualToString:@""]) {
//        diastolic_avg.value = [[bpRecordsArray objectAtIndex:0] objectForKey:@"diastolic_bp"];
//    }
    [self setDefaultFontWithRow:diastolic_avg];
    diastolic_avg.disabled = @(1);
    [section addFormRow:diastolic_avg];
    
//    diastolic_avg.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kBpDiastolic, kBpDiastolic2]];        //somehow must disable first ... @.@"
    
    diastolic_1.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            diastolic_avg.value = @(([diastolic_1.value integerValue]+ [diastolic_2.value integerValue])/2);
            [self updateFormRow:diastolic_avg];
        }
    };
    
    diastolic_2.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            if (diastolic_3.value > 0) {
                diastolic_avg.value = @(([diastolic_3.value integerValue]+ [diastolic_2.value integerValue])/2); //if BP3 is keyed in, take BP 2 and BP 3 instead.
            } else {
                diastolic_avg.value = @(([diastolic_1.value integerValue]+ [diastolic_2.value integerValue])/2);
            }
            [self updateFormRow:diastolic_avg];
        }
    };
    
    diastolic_3.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            if (newValue != (id)[NSNull null]) {
                diastolic_avg.value = @(([diastolic_3.value integerValue]+ [diastolic_2.value integerValue])/2); //if BP3 is keyed in, take BP 2 and BP 3 instead.
            } else {
                diastolic_avg.value = @(([diastolic_1.value integerValue]+ [diastolic_2.value integerValue])/2);
            }
            [self updateFormRow:diastolic_avg];
        }
    };
    
    return [super initWithForm:formDescriptor];
    
}


- (id) initSnellenEyeTest {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Snellen Eye Test"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
 
    //
    //    if ([_formType integerValue] == ViewScreenedScreeningForm) {
    //        [formDescriptor setDisabled:YES];
    //    }
    
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRightEye rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Right Eye: "];
    row.required = YES;
    row.selectorOptions = @[@"6/6", @"6/9", @"6/12", @"6/18", @"6/24", @"6/36", @"6/60"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLeftEye rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Left Eye: "];
    row.required = YES;
    row.selectorOptions = @[@"6/6", @"6/9", @"6/12", @"6/18", @"6/24", @"6/36", @"6/60"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    XLFormRowDescriptor *six12Row = [XLFormRowDescriptor formRowDescriptorWithTag:kSix12 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does either eye (or both) have vision poorer than 6/12?"];
    six12Row.required = YES;
    six12Row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:six12Row];
    [section addFormRow:six12Row];
    
    XLFormRowDescriptor *tunnelRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTunnel rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident have genuine visual complaints (e.g. floaters, tunnel vision, bright spots etc.)?"];
    tunnelRow.required = YES;
    tunnelRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:tunnelRow];
    [section addFormRow:tunnelRow];
    
    XLFormRowDescriptor *visitEye12Mths = [XLFormRowDescriptor formRowDescriptorWithTag:kVisitEye12Mths rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Resident has not visited eye specialist in 12 months"];
    visitEye12Mths.required = YES;
    visitEye12Mths.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:visitEye12Mths];
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





-(id) initAdditionalSvcs {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Additional Services"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"CHAS"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAppliedChas rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Applied for CHAS under NHS?"];
    row.required = NO;
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyCHAS];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Colonoscopy"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferColonos rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred for colonoscopy by NHS?"];
    row.required = NO;
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyColonsc];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"FIT"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReceiveFit rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Receiving FIT kit from NHS?"];
    row.required = NO;
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyFIT];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mammogram"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferMammo rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred for mammogram by NHS?"];
    row.required = NO;
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyMammo];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"PAP Smear"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferPapSmear rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred for PAP smear by NHS?"];
    row.required = NO;
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyPapSmear];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initRefForDoctorConsult {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Referral for Doctor Consult"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
//    NSDictionary *refForDocConsultDict = [self.fullScreeningForm objectForKey:@"consult_record"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTE"];
//    section.footerTitle = @"If it is appropriate to refer the resident doctor consult:\n- If resident is mobile, accompany him/her to the consultation booths at HQ\n- If resident is not mobile, call Ops to send a doctor to the resident's flat\n- Please refer for consult immediately. Teams that wait till they are done with all other units on their list often find that upon return to a previously-covered unit, the resident has gone out";
//    [formDescriptor addFormSection:section];
//    

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Doctor's Notes"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocNotes
                                                rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Type your notes here..." forKey:@"textView.placeholder"];
//    row.value = [refForDocConsultDict objectForKey:kDocNotes];
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocName
                                                rowType:XLFormRowDescriptorTypeName title:@"Name of Doctor"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
//    row.value = [refForDocConsultDict objectForKey:kDocName];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocReferred rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred by doctor?"];
    row.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initDentalCheckup {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Basic Dental Check-up"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *dentalUndergoneRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDentalUndergone rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Undergone dental check-up?"];
    dentalUndergoneRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:dentalUndergoneRow];
    [section addFormRow:dentalUndergoneRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDentistReferred
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred by dentist?"];
    row.selectorOptions = @[@"Yes", @"No"];
    row.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", dentalUndergoneRow];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initFallRiskAssessment {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Fall Risk Assessment"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPsfuFRA rowType:XLFormRowDescriptorTypeBooleanCheck title:@"To be completed during PSFU"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *balanceRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBalance
                                                rowType:XLFormRowDescriptorTypeStepCounter title:@"Balance Test"];
    balanceRow.value = @(0);
    [balanceRow.cellConfigAtConfigure setObject:@(4) forKey:@"stepControl.maximumValue"];
    [balanceRow.cellConfigAtConfigure setObject:@(0) forKey:@"stepControl.minimumValue"];
    [balanceRow.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
    [self setDefaultFontWithRow:balanceRow];
    [section addFormRow:balanceRow];
    
    XLFormRowDescriptor *GaitSpeedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBalance
                                                rowType:XLFormRowDescriptorTypeStepCounter title:@"Gait Speed Test"];
    GaitSpeedRow.value = @(0);
    [GaitSpeedRow.cellConfigAtConfigure setObject:@(4) forKey:@"stepControl.maximumValue"];
    [GaitSpeedRow.cellConfigAtConfigure setObject:@(0) forKey:@"stepControl.minimumValue"];
    [GaitSpeedRow.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
    [self setDefaultFontWithRow:GaitSpeedRow];
    [section addFormRow:GaitSpeedRow];
    
    XLFormRowDescriptor *chairStandRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBalance
                                                rowType:XLFormRowDescriptorTypeStepCounter title:@"Chair Stand Test"];
    chairStandRow.value = @(0);
    [chairStandRow.cellConfigAtConfigure setObject:@(4) forKey:@"stepControl.maximumValue"];
    [chairStandRow.cellConfigAtConfigure setObject:@(0) forKey:@"stepControl.minimumValue"];
    [chairStandRow.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
    [self setDefaultFontWithRow:chairStandRow];
    [section addFormRow:chairStandRow];
    
    XLFormRowDescriptor *totalRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTotal rowType:XLFormRowDescriptorTypeInfo title:@"Total Score for SPPB"];
    [self setDefaultFontWithRow:totalRow];
    
    balanceRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            int total = [newValue intValue] + [GaitSpeedRow.value intValue] + [chairStandRow.value intValue];
            totalRow.value = [NSNumber numberWithInt:total];
            [self reloadFormRow:totalRow];
        }
    };
    
    GaitSpeedRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            int total = [balanceRow.value intValue] + [newValue intValue] + [chairStandRow.value intValue];
            totalRow.value = [NSNumber numberWithInt:total];
            [self reloadFormRow:totalRow];
        }
    };
    
    chairStandRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            int total = [balanceRow.value intValue] + [GaitSpeedRow.value intValue] + [newValue intValue];
            totalRow.value = [NSNumber numberWithInt:total];
            [self reloadFormRow:totalRow];
        }
    };
    
    [section addFormRow:totalRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReqFollowupFRA
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred for further follow-up?"];
    row.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initDementiaAssessment {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Geriatric Dementia Assessment"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPsfuFRA rowType:XLFormRowDescriptorTypeBooleanCheck title:@"To be completed during PSFU"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"Range: 0-10";
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAmtScore rowType:XLFormRowDescriptorTypeInteger title:@"Total score for AMT"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Score between 0 to 10" regex:@"^([0-9]|10)$"]];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if (newValue != [NSNull null]) {
                if ([newValue intValue] < 0 || [newValue intValue] > 255) {
                    [self showValidationError];
                }
            }
        }
    };
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEduStatus rowType:XLFormRowDescriptorTypeSelectorPush title:@"Resident's education status"];
    row.selectorOptions = @[@"1 year", @"2 years", @"3 years", @"4 years", @"5 years", @"6 years", @"more than 6 years", @"No formal education"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReqFollowupGDA rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred for further follow-up?"];
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    
    
    return [super initWithForm:formDescriptor];
}



- (id) initHealthEducation {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Health Education"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    preEdSection = [XLFormSectionDescriptor formSectionWithTitle:@"Pre-education Knowledge Quiz"];
    [formDescriptor addFormSection:preEdSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu1 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"1. A person always knows when they have heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu2 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"2. If you have a family history of heart disease, you are at risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu3 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"3. The older a person is, the greater their risk of having heart disease "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu4 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"4. Smoking is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu5 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"5. A person who stops smoking will lower their risk of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu6 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"6. High blood pressure is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu7 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"7. Keeping blood pressure under control will reduce a person’s risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu8 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"8. High cholesterol is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu9 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"9. Eating fatty foods does not affect blood cholesterol levels"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu10 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"10. If your ‘good’ cholesterol (HDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu11 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"11. If your ‘bad’ cholesterol (LDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu12 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"12. Being overweight increases a person’s risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu13 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"13. Regular physical activity will lower a person’s chance of getting heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu14 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"14. Only exercising at a gym or in an exercise class will lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu15 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"15. Walking is considered exercise that will help lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu16 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"16. Diabetes is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu17 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"17. High blood sugar puts a strain on the heart"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu18 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"18. If your blood sugar is high over several months it can cause your cholesterol level to go up and increase your risk of heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu19 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"19. A person who has diabetes can reduce their risk of developing heart disease if they keep their blood sugar levels under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu20 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"20. People with diabetes rarely have high cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu21 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"21. If a person has diabetes, keeping their cholesterol under control will help to lower their chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu22 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"22. People with diabetes tend to have low HDL (good) cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu23 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"23. A person who has diabetes can reduce their risk of developing heart disease if they keep their blood pressure under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu24 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"24. A person who has diabetes can reduce their risk of developing heart disease if they keep their weight under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"25. Men with diabetes have a higher risk of heart disease than women with diabetes "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"preEdScoreButton" rowType:XLFormRowDescriptorTypeButton title:@"Calculate Pre-education Score"];
    row.action.formSelector = @selector(calculateScore:);
    row.required = NO;
    [preEdSection addFormRow:row];
    
    preEdScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdScore rowType:XLFormRowDescriptorTypeInteger title:@"Pre-education Score"];
    preEdScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    preEdScoreRow.noValueDisplayText = @"-/-";
    preEdScoreRow.disabled = @YES;
    [self setDefaultFontWithRow:preEdScoreRow];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu1 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person always knows when they have heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu2 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If you have a family history of heart disease, you are at risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu3 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"The older a person is, the greater their risk of having heart disease "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu4 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Smoking is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu5 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person who stops smoking will lower their risk of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu6 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"High blood pressure is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu7 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Keeping blood pressure under control will reduce a person’s risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu8 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"High cholesterol is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu9 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Eating fatty foods does not affect blood cholesterol levels"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu10 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If your ‘good’ cholesterol (HDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu11 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If your ‘bad’ cholesterol (LDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu12 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Being overweight increases a person’s risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu13 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Regular physical activity will lower a person’s chance of getting heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu14 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Only exercising at a gym or in an exercise class will lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu15 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Walking is considered exercise that will help lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu16 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Diabetes is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu17 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"High blood sugar puts a strain on the heart"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu18 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If your blood sugar is high over several months it can cause your cholesterol level to go up and increase your risk of heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu19 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their blood sugar levels under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu20 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"People with diabetes rarely have high cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu21 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If a person has diabetes, keeping their cholesterol under control will help to lower their chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu22 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"People with diabetes tend to have low HDL (good) cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu23 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their blood pressure under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu24 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their weight under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Men with diabetes have a higher risk of heart disease than women with diabetes "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"postEdScoreButton" rowType:XLFormRowDescriptorTypeButton title:@"Calculate Post-education Score"];
    row.action.formSelector = @selector(calculateScore:);
    row.required = NO;
    [postEdSection addFormRow:row];
    
    postEdScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPreEdScore rowType:XLFormRowDescriptorTypeInteger title:@"Post-education Score"];
    postEdScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    postEdScoreRow.noValueDisplayText = @"-/-";
    postEdScoreRow.disabled = @YES;
    [self setDefaultFontWithRow:postEdScoreRow];
    [postEdSection addFormRow:postEdScoreRow];
    
    
    
    [postEdSection setHidden:@YES]; //keep hidden first
    
    return [super initWithForm:formDescriptor];
}
#pragma mark - Buttons
//-(void)returnBtnPressed:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}


-(void)validateBtnPressed:(UIBarButtonItem * __unused)button
{
    if ([self.form isDisabled]) {
        [self.form setDisabled:NO];     //enable the form
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem.title = @"Validate";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"formEditedNotification"
                                                            object:nil
                                                          userInfo:nil];
    } else {
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
            //        UIAlertController *alertController;
            //        UIAlertAction *okAction;
            //
            //        alertController = [UIAlertController alertControllerWithTitle:@"Validation success"
            //                                                              message:@"All required fields are not empty."
            //                                                       preferredStyle:UIAlertControllerStyleActionSheet];
            //        alertController.view.backgroundColor = [UIColor greenColor];
            //        okAction = [UIAlertAction actionWithTitle:@"OK"
            //                                                 style:UIAlertActionStyleDefault
            //                                               handler:^(UIAlertAction *action) {
            //                                                   // do destructive stuff here
            //                                               }];
            //
            //        // note: you can control the order buttons are shown, unlike UIActionSheet
            //        [alertController addAction:okAction];
            //        [alertController setModalPresentationStyle:UIModalPresentationPopover];
            //        [self presentViewController:alertController animated:YES completion:nil];
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//            
//            // Set the custom view mode to show any view.
//            hud.mode = MBProgressHUDModeCustomView;
//            // Set an image view with a checkmark.
//            UIImage *image = [[UIImage imageNamed:@"ThumbsUp"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            hud.customView = [[UIImageView alloc] initWithImage:image];
//            // Looks a bit nicer if we make it square.
//            hud.square = YES;
//            
//            hud.backgroundColor = [UIColor clearColor];
//            // Optional label text.
//            hud.label.text = NSLocalizedString(@"Good!", @"HUD done title");
//            [hud hideAnimated:YES afterDelay:1.f];
            [SVProgressHUD setMinimumDismissTimeInterval:1.0f];
            [SVProgressHUD showImage:[[UIImage imageNamed:@"ThumbsUp"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] status:@"Good!"];
            
            
        }
        //    [self.tableView endEditing:YES];
        //    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Set the label text.
        //    hud.label.text = NSLocalizedString(@"Uploading...", @"HUD loading title");
        //    [self submitPersonalInfo:[self preparePersonalInfoDict]];
    }
    
}


#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
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
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kChronicCond andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kWantFreeBt]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kWantFreeBt andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDidPhleb]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kDidPhleb andNewContent:newValue];
    }
    
    
    /* Profiling */
    else if ([rowDescriptor.tag isEqualToString:kProfilingConsent]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kProfilingConsent andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kEmployStat]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kEmployStat andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDiscloseIncome]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kDiscloseIncome andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kAvgIncomePerHead]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kAvgIncomePerHead andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDoesntOwnChasPioneer]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kDoesntOwnChasPioneer andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kLowHouseIncome]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kLowHouseIncome andNewContent:newValue];
//    } else if ([rowDescriptor.tag isEqualToString:kLowHomeValue]) {
//        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kLowHomeValue andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kWantChas]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kWantChas andNewContent:newValue];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kRelWColorectCancer]) {
        [self postSingleFieldWithSection:SECTION_COLONOSCOPY_ELIGIBLE andFieldName:kRelWColorectCancer andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kColonoscopy3yrs]) {
        [self postSingleFieldWithSection:SECTION_COLONOSCOPY_ELIGIBLE andFieldName:kColonoscopy3yrs andNewContent:newValue];
    }else if ([rowDescriptor.tag isEqualToString:kWantColonoscopyRef]) {
        [self postSingleFieldWithSection:SECTION_COLONOSCOPY_ELIGIBLE andFieldName:kWantColonoscopyRef andNewContent:newValue];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kFitLast12Mths]) {
        [self postSingleFieldWithSection:SECTION_FIT_ELIGIBLE andFieldName:kFitLast12Mths andNewContent:newValue];
    }else if ([rowDescriptor.tag isEqualToString:kColonoscopy10Yrs]) {
        [self postSingleFieldWithSection:SECTION_FIT_ELIGIBLE andFieldName:kColonoscopy10Yrs andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kWantFitKit]) {
        [self postSingleFieldWithSection:SECTION_FIT_ELIGIBLE andFieldName:kWantFitKit andNewContent:newValue];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kMammo2Yrs]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_ELIGIBLE andFieldName:kMammo2Yrs andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kHasChas]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_ELIGIBLE andFieldName:kHasChas andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kWantMammo]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_ELIGIBLE andFieldName:kWantMammo andNewContent:newValue];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kPap3Yrs]) {
        [self postSingleFieldWithSection:SECTION_PAP_SMEAR_ELIGIBLE andFieldName:kPap3Yrs andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kEngagedSex]) {
        [self postSingleFieldWithSection:SECTION_PAP_SMEAR_ELIGIBLE andFieldName:kEngagedSex andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kWantPap]) {
        [self postSingleFieldWithSection:SECTION_PAP_SMEAR_ELIGIBLE andFieldName:kWantPap andNewContent:newValue];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kFallen12Mths]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kFallen12Mths andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kScaredFall]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kScaredFall andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kFeelFall]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kFeelFall andNewContent:newValue];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kCognitiveImpair]) {
        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ELIGIBLE andFieldName:kCognitiveImpair andNewContent:newValue];
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
    
    /* Profiling */
    else if ([rowDescriptor.tag isEqualToString:kEmployReasons]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kEmployReasons andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kEmployOthers]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kEmployOthers andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAvgMthHouseIncome]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kAvgMthHouseIncome andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNumPplInHouse]) {
        
        
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kNumPplInHouse andNewContent:rowDescriptor.value];
    }
    
}

#pragma mark - Save Dictionary methods


//
//- (void) saveClinicalResults {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *clinical_results = [[[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"clinical_results"] mutableCopy];
//    NSMutableArray *bp_record = [[[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"bp_record"] mutableCopy];
//    NSMutableDictionary *individualBpRecord;
//    
//    //resident_id here
//    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kHeight] forKey:@"height_cm"];
//    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kWeight] forKey:@"weight_kg"];
//    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kBMI] forKey:@"bmi"];
//    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kWaistCircum] forKey:kWaistCircum];
//    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kHipCircum] forKey:kHipCircum];
//    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kWaistHipRatio] forKey:kWaistHipRatio];
//    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCbg] forKey:kCbg];
//    //also timestamp is here..
//    
//    
//    individualBpRecord = [[bp_record objectAtIndex:0] mutableCopy];
//    //resident_id
//    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpSystolicAvg] forKey:@"systolic_bp"];
//    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpDiastolicAvg] forKey:@"diastolic_bp"];
//    [individualBpRecord setObject:@"0" forKey:@"order_num"];
//    [individualBpRecord setObject:@"1" forKey:@"is_avg"];
//    //also timestamp is here..
//    [bp_record replaceObjectAtIndex:0 withObject:individualBpRecord];
//     
//    individualBpRecord = [[bp_record objectAtIndex:1] mutableCopy];
//    //resident_id
//    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpSystolic] forKey:@"systolic_bp"];
//    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpDiastolic] forKey:@"diastolic_bp"];
//    [individualBpRecord setObject:@"1"forKey:@"order_num"];
//    [individualBpRecord setObject:@"0" forKey:@"is_avg"];
//    //also timestamp is here..
//    [bp_record replaceObjectAtIndex:1 withObject:individualBpRecord];
//      
//    individualBpRecord = [[bp_record objectAtIndex:2] mutableCopy];
//    //resident_id
//    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpSystolic2] forKey:@"systolic_bp"];
//    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpDiastolic2] forKey:@"diastolic_bp"];
//    [individualBpRecord setObject:@"2" forKey:@"order_num"];
//    [individualBpRecord setObject:@"0" forKey:@"is_avg"];
//    //is_avg is missing
//    //also timestamp is here...
//    [bp_record replaceObjectAtIndex:2 withObject:individualBpRecord];
//       
//    individualBpRecord = [[bp_record objectAtIndex:3] mutableCopy];
//    //resident_id
//    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpSystolic3] forKey:@"systolic_bp"];
//    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpDiastolic3] forKey:@"diastolic_bp"];
//    [individualBpRecord setObject:@"3" forKey:@"order_num"];
//    [individualBpRecord setObject:@"0" forKey:@"is_avg"];
//    //also timestamp is here..
//    [bp_record replaceObjectAtIndex:3 withObject:individualBpRecord];
//    
//    NSMutableDictionary *temp = [@{@"clinical_results":clinical_results} mutableCopy];  //just to make it mutable
//    
//    [self.fullScreeningForm setObject:temp forKey:@"clinical_results"];
//    [[self.fullScreeningForm objectForKey:@"clinical_results"] setObject:bp_record forKey:@"bp_record"];
//    
//}


//
//- (void) saveCurrentPhysicalIssues {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *currPhyIssues_dict = [[self.fullScreeningForm objectForKey:@"adls"] mutableCopy];
//    
//    if ([fields objectForKey:kMultiADL] != (id) [NSNull null]) {    //check for null first, if not crash may happen
//        //Clear all first
//        [currPhyIssues_dict setObject:@"0" forKey:@"bathe"];
//        [currPhyIssues_dict setObject:@"0" forKey:@"dress"];
//        [currPhyIssues_dict setObject:@"0" forKey:@"eat"];
//        [currPhyIssues_dict setObject:@"0" forKey:@"hygiene"];
//        [currPhyIssues_dict setObject:@"0" forKey:@"toileting"];
//        [currPhyIssues_dict setObject:@"0" forKey:@"walk"];
//        
//        if ([[fields objectForKey:kMultiADL] count]!=0) {
//            NSArray *adlArray = [fields objectForKey:kMultiADL];
//            for (int i=0; i<[adlArray count]; i++) {
//                if([[[adlArray objectAtIndex:i] formValue] isEqual:@(0)]) [currPhyIssues_dict setObject:@"1" forKey:@"bathe"];
//                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(1)]) [currPhyIssues_dict setObject:@"1" forKey:@"dress"];
//                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(2)]) [currPhyIssues_dict setObject:@"1" forKey:@"eat"];
//                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(3)]) [currPhyIssues_dict setObject:@"1" forKey:@"hygiene"];
//                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(4)]) [currPhyIssues_dict setObject:@"1" forKey:@"toileting"];
//                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(5)]) [currPhyIssues_dict setObject:@"1" forKey:@"walk"];
//            }
//        }
//    }
//    
//    [self.fullScreeningForm setObject:currPhyIssues_dict forKey:@"adls"];
//}
//
//
//- (void) saveRefForDoctorConsult {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *refForDoctorConsult_dict = [[self.fullScreeningForm objectForKey:@"consult_record"] mutableCopy];
//
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kDocConsult] forKey:kDocConsult];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kDocRef] forKey:kDocRef];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kSeri] forKey:kSeri];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kSeriRef] forKey:kSeriRef];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kDental] forKey:kDental];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kDentalRef] forKey:kDentalRef];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kMammoRef] forKey:kMammoRef];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kFitKit] forKey:kFitKit];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kPapSmearRef] forKey:kPapSmearRef];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kPhleb] forKey:kPhleb];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kRefNA] forKey:kRefNA];
//    
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:TextView formDescriptorWithTag:kDocNotes] forKey:kDocNotes];
//    [refForDoctorConsult_dict setObject:[self getStringWithDictionary:fields rowType:TextView formDescriptorWithTag:kDocName] forKey:kDocName];
//    
//    [self.fullScreeningForm setObject:refForDoctorConsult_dict forKey:@"consult_record"];
//}
#pragma mark - Other Methods
- (void) checkForSeriEligibilityWithRow3: (XLFormRowDescriptor *) six12Row
                                                  andRow4: (XLFormRowDescriptor *) tunnelRow
                                                  andRow5: (XLFormRowDescriptor *) visitEye12MthsRow {
    
    if (([six12Row.value isEqual:@1] || ([tunnelRow.value isEqual:@(1)])) && ([visitEye12MthsRow.value isEqual:@(1)])) { // (3 OR 4) AND 5
        NSLog(@"SERI Enabled!");
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kNeedSERI];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kNeedSERI];
    }
}

- (void) calculateScore: (XLFormRowDescriptor *)sender {
    
    NSDictionary *dict = [self.form formValues];
    int score, eachAns, i;
    NSString *ans;
    
    score = i = 0;

    NSDictionary *correctAnswers = @{kEdu1:@"False",//1
                                     kEdu2:@"True", //2
                                     kEdu3:@"True", //3
                                     kEdu4: @"True", //4
                                     kEdu5: @"True", //5
                                     kEdu6: @"True", //6
                                     kEdu7: @"True", //7
                                     kEdu8: @"True", //8
                                     kEdu9:@"False",//9
                                     kEdu10:@"False",//10
                                     kEdu11:@"True", //11
                                     kEdu12:@"True", //12
                                     kEdu13:@"True", //13
                                     kEdu14:@"False",//14
                                     kEdu15:@"True", //15
                                     kEdu16:@"True", //16
                                     kEdu17:@"True", //17
                                     kEdu18:@"True", //18
                                     kEdu19:@"True", //19
                                     kEdu20:@"False",//20
                                     kEdu21:@"True", //21
                                     kEdu22:@"True", //22
                                     kEdu23:@"True", //23
                                     kEdu24:@"True", //24
                                     kEdu25:@"False" //25
                                     };
    
    for (NSString *key in dict) {
        if (![key isEqualToString:kPreEdScore] && ![key isEqualToString:kPostEdScore] && ![key isEqualToString:@"preEdScoreButton"] && ![key isEqualToString:@"postEdScoreButton"]) {
            //prevent null cases
            if (dict[key] != [NSNull null]) {//only take non-null values;
                ans = dict[key];
            
                if ([ans isEqualToString:correctAnswers[key]]) {
                    eachAns = 1;
                } else
                    eachAns = 0;
                
                score = score + eachAns;
                ans = @"";
            }
        }
    }
    i=0;
    if ([sender.title rangeOfString:@"Pre-education"].location != NSNotFound) { // if it's pre-education button
        
        preEdScoreRow.value = [NSString stringWithFormat:@"%d", score];
        [self reloadFormRow:preEdScoreRow];
        [showPostEdSectionBtnRow setHidden:@NO];
        [self reloadFormRow:showPostEdSectionBtnRow];
    } else {
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


- (NSArray *) getScreeningTimeArrayFromDict:(NSDictionary *) dictionary andOptions:(NSArray *) options {
    NSMutableArray *screeningTimeArray = [[NSMutableArray alloc] init];
    
    if ([dictionary objectForKey:kTime_8_10] != (id) [NSNull null]) {
        if([[dictionary objectForKey:kTime_8_10] isEqual:@1])
            [screeningTimeArray addObject:[options objectAtIndex:0]];
    }
    
    if ([dictionary objectForKey:kTime_10_12] != (id) [NSNull null]) {
    if([[dictionary objectForKey:kTime_10_12] isEqual:@1])
        [screeningTimeArray addObject:[options objectAtIndex:1]];
    }
    
    if ([dictionary objectForKey:kTime_12_2] != (id) [NSNull null]) {
        if([[dictionary objectForKey:kTime_12_2] isEqual:@1])
            [screeningTimeArray addObject:[options objectAtIndex:2]];
    }
    
    if ([dictionary objectForKey:kTime_2_4] != (id) [NSNull null]) {
        if([[dictionary objectForKey:kTime_2_4] isEqual:@1])
            [screeningTimeArray addObject:[options objectAtIndex:3]];
    }
    
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
                    NSArray *array = [newSet allObjects];
                    [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:[self getFieldNameFromApptTime:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:[self getFieldNameFromApptTime:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:[self getFieldNameFromApptTime:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:[self getFieldNameFromApptTime:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
//    
//    for (int i=0; i < [optionChosen count]; i++) {
//        if ([optionChosen[i] isEqualToString:@"8am-10pm"]) {
//            [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kTime_8_10 andNewContent:@"1"];
//        } else if ([optionChosen[i] isEqualToString:@"10am-12pm"]) {
//            [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kTime_10_12 andNewContent:@"1"];
//        }else if ([optionChosen[i] isEqualToString:@"2pm-4pm"]) {
//            [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kTime_12_2 andNewContent:@"1"];
//        }else {
//            [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kTime_2_4 andNewContent:@"1"];
//        }
//    }
}

- (NSString *) getFieldNameFromApptTime: (NSString *) apptTime {
    if ([apptTime isEqualToString:@"8am-10am"]) return kTime_8_10;
    else if ([apptTime isEqualToString:@"10am-12pm"]) return kTime_10_12;
    else if ([apptTime isEqualToString:@"12pm-2pm"]) return kTime_12_2;
    else return kTime_2_4;
}

#pragma mark - Download Server API
- (void) processConnectionStatus {
    if(status == NotReachable)
    {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Internet!", nil)
                                                                                  message:@"You're not connected to Internet."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction){
                                                              //                                                              [self.refreshControl endRefreshing];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (status == ReachableViaWiFi || status == ReachableViaWWAN) {
        
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
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
        
        };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"******UNSUCCESSFUL SUBMISSION******!!");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSLog(@"error: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);

        [SVProgressHUD dismiss];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Upload Fail", nil)
                                                                                  message:@"Form failed to upload!"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction) {
                                                              //do nothing for now
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];

        
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



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

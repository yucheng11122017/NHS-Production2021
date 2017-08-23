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
#import "SVProgressHUD.h"
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
    NSString *gender;
    NSArray *spoken_lang_value;
    XLFormRowDescriptor *preEdScoreRow, *postEdScoreRow, *showPostEdSectionBtnRow;
    XLFormSectionDescriptor *preEdSection, *postEdSection;
    NSString *neighbourhood, *citizenship;
    NSNumber *age;
    BOOL noChas, lowIncome, wantChas;
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
    
    //fixed for now
//    neighbourhood = @"KGL";
//    citizenship = @"Singaporean";
//    age = [NSNumber numberWithInt:70];
    
    citizenship = [[NSUserDefaults standardUserDefaults]
                            stringForKey:kCitizenship];
    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                             stringForKey:kResidentAge];
    gender = [[NSUserDefaults standardUserDefaults]
              stringForKey:kGender];
    neighbourhood = [[NSUserDefaults standardUserDefaults]
              stringForKey:kNeighbourhood];
    
    
//    form = [self initModeOfScreening];
    
    //must init first before [super viewDidLoad]
    switch([self.sectionID integerValue]) {
//
        case 0: form = [self initModeOfScreening];
            break;
        case 1: form = [self initPhlebotomy];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFullScreeningForm"
                                                        object:nil
                                                      userInfo:self.fullScreeningForm];
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

- (void) setpreRegParticularsDict :(NSDictionary *)preRegParticularsDict {
    self.preRegParticularsDict = [[NSDictionary alloc] initWithDictionary:preRegParticularsDict];
}

#pragma mark - Forms methods

-(id)initModeOfScreening {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Mode of Screening"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kScreenMode rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Pick one"];
    row.selectorOptions = @[@"Centralised", @"Door-to-door"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApptDate rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Appointment Date"];
    row.noValueDisplayText = @"Tap here";
    [self setDefaultFontWithRow:row];
    
    if ([neighbourhood isEqualToString:@"EC"]) {
        row.selectorOptions = @[@"9 Sept", @"10 Sept"];
    } else {
        row.selectorOptions = @[@"30 Sept", @"1 Oct"];
    }
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApptTime rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Appointment Time"];
    row.noValueDisplayText = @"Tap here";
    row.selectorOptions= @[@"8am", @"10am", @"12pm", @"2pm"];
    row.required = NO;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initPhlebotomy {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Phlebotomy"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kWasTaken rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Taken?"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFastingBloodGlucose rowType:XLFormRowDescriptorTypeDecimal title:@"Fasting blood glucose (mmol/L)"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:15] forKey:@"textLabel.font"];   //the description too long. Default fontsize is 16
    [self setDefaultFontWithRow:row];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTriglycerides rowType:XLFormRowDescriptorTypeDecimal title:@"Triglycerides (mmol/L)"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLDL rowType:XLFormRowDescriptorTypeDecimal title:@"LDL Cholestrol (mmol/L)"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHDL rowType:XLFormRowDescriptorTypeDecimal title:@"HDL Cholestrol (mmol/L)"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCholesterolHdlRatio rowType:XLFormRowDescriptorTypeDecimal title:@"Cholestrol/HDL ratio"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTotCholesterol rowType:XLFormRowDescriptorTypeDecimal title:@"Total Cholestrol (mmol/L)"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}


-(id) initProfiling {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Profiling"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    XLFormRowDescriptor *rowInfo;
    
    noChas = lowIncome = wantChas = false;
    sporeanPr = age50 = relColorectCancer = colon3Yrs = wantColRef = disableFIT = false;
    fit12Mths = colonsc10Yrs = wantFitKit = false;
    age5069 = noMammo2Yrs = hasChas = wantMammo = false;
    age2569 = noPapSmear3Yrs = hadSex = wantPapSmear = false;
    
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kProfilingConsent rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Consent to disclosure of information"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    [section addFormRow:row];
    
    // Resident's Socioeconomic status - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Resident's Socioeconomic Status"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *employmentRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStat rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Employment status"];
    [self setDefaultFontWithRow:employmentRow];
    employmentRow.required = NO;
    employmentRow.selectorOptions = @[@"Retired", @"Housewife/Homemaker",@"Self-employed",@"Part-time employed",@"Full-time employed", @"Unemployed", @"Others"];
    [section addFormRow:employmentRow];
    
    XLFormRowDescriptor *unemployReasonsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployReasons rowType:XLFormRowDescriptorTypeTextView title:@""];
    [self setDefaultFontWithRow:unemployReasonsRow];
    unemployReasonsRow.required = NO;
    unemployReasonsRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Unemployed'", employmentRow];
    [unemployReasonsRow.cellConfigAtConfigure setObject:@"Reasons for unemployment" forKey:@"textView.placeholder"];
//    [unemployReasonsRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textView.textAlignment"];
    [section addFormRow:unemployReasonsRow];
    
    XLFormRowDescriptor *otherEmployRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployOthers rowType:XLFormRowDescriptorTypeText title:@"Other employment"];
    [self setDefaultFontWithRow:otherEmployRow];
    otherEmployRow.required = NO;
    otherEmployRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", employmentRow];
    [otherEmployRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:otherEmployRow];
    
    XLFormRowDescriptor *noDiscloseIncomeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiscloseIncome rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Resident does not want to disclose income"];
    [self setDefaultFontWithRow:noDiscloseIncomeRow];
//    noDiscloseIncomeRow.selectorOptions = @[@"Yes", @"No"];
    noDiscloseIncomeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noDiscloseIncomeRow.required = NO;
    [section addFormRow:noDiscloseIncomeRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *mthHouseIncome = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgMthHouseIncome rowType:XLFormRowDescriptorTypeDecimal title:@"Average monthly household income"];
    [self setDefaultFontWithRow:mthHouseIncome];
    [mthHouseIncome.cellConfigAtConfigure setObject:@"Enter here" forKey:@"textField.placeholder"];
    mthHouseIncome.cellConfig[@"textLabel.numberOfLines"] = @0;
    mthHouseIncome.required = NO;
    [section addFormRow:mthHouseIncome];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

    XLFormRowDescriptor *noOfPplInHouse = [XLFormRowDescriptor formRowDescriptorWithTag:kNumPplInHouse rowType:XLFormRowDescriptorTypeNumber title:@"No. of people in the household"];
    [self setDefaultFontWithRow:noOfPplInHouse];
    [noOfPplInHouse.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    noOfPplInHouse.required = NO;
    [section addFormRow:noOfPplInHouse];
    
    XLFormRowDescriptor *avgIncomePerHead = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgIncomePerHead rowType:XLFormRowDescriptorTypeDecimal title:@"Average income per head"];   //auto-calculate
    [self setDefaultFontWithRow:avgIncomePerHead];
    [avgIncomePerHead.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    avgIncomePerHead.required = NO;
    
    if (!isnan([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])) {  //check for not nan first!
        avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", [mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue]];
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
    
    XLFormRowDescriptor *chasColorRow = [XLFormRowDescriptor formRowDescriptorWithTag:kChasColor rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If resident owns CHAS card, what colour?"];
    [self setDefaultFontWithRow:chasColorRow];
    chasColorRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    chasColorRow.required = NO;
    chasColorRow.selectorOptions = @[@"Blue", @"Orange"];
    [section addFormRow:chasColorRow];
    
    
    
    // Disable all income related questions if not willing to disclose income
    noDiscloseIncomeRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqual:@(1)]) {
                mthHouseIncome.disabled = @(1);
                noOfPplInHouse.disabled = @(1);
                avgIncomePerHead.disabled = @(1);
                chasColorRow.disabled = @(1);
                chasNoChasRow.disabled = @(1);
                wantChasRow.disabled = @(1);
                lowHouseIncomeRow.disabled = @(1);

            } else {
                mthHouseIncome.disabled = @(0);
                noOfPplInHouse.disabled = @(0);
                avgIncomePerHead.disabled = @(0);
                chasColorRow.disabled = @(0);
                chasNoChasRow.disabled = @(0);
                wantChasRow.disabled = @(0);
                lowHouseIncomeRow.disabled = @(0);
            }
            
            [self reloadFormRow:mthHouseIncome];
            [self reloadFormRow:noOfPplInHouse];
            [self reloadFormRow:avgIncomePerHead];
            [self reloadFormRow:chasColorRow];
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
    
    XLFormRowDescriptor *age50Row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove50 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Age 50 and above"];
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
    [self setDefaultFontWithRow:relColCancerRow];
    relColCancerRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    relColCancerRow.required = NO;
    [section addFormRow:relColCancerRow];
    
    
    XLFormRowDescriptor *colon3yrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kColonoscopy3yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done colonoscopy in the past 3 years?"];
    [self setDefaultFontWithRow:colon3yrsRow];
    colon3yrsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    colon3yrsRow.required = NO;
    [section addFormRow:colon3yrsRow];
    
    XLFormRowDescriptor *wantColonRefRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantColonoscopyRef rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a referral for free colonoscopy?"];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove50 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Age 50 and above"];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferPapSmear rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free pap smear referral?"];
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
            if (age65 && fallen12Mths && scaredFall && feelFall) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyFallAssess];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFallAssess];
            }
            
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kScaredFall rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Do you avoid going out because you are scared of falling?"];
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
            if (age65 && fallen12Mths && scaredFall && feelFall) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyFallAssess];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyFallAssess];
            }
            
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelFall rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Do you feel like you are going to fall when getting up or walking?"];
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
            if (age65 && fallen12Mths && scaredFall && feelFall) {
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Resident shows signs of cognitive impairment(e.g. forgetfulness, carelessness, lack of awareness)"];
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
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Clinical Results"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *clinicalResultsDict = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"clinical_results"];
    NSArray *bpRecordsArray = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"bp_record"];
//    
//    if ([_formType integerValue] == ViewScreenedScreeningForm) {
//        [formDescriptor setDisabled:YES];
//    }
    
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *systolic_1;
    systolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp1Sys rowType:XLFormRowDescriptorTypeNumber title:@"BP (1. Systolic number)"];
    systolic_1.required = YES;
    systolic_1.value = [[bpRecordsArray objectAtIndex:1] objectForKey:@"systolic_bp"];
    [self setDefaultFontWithRow:systolic_1];
    [section addFormRow:systolic_1];
    
    XLFormRowDescriptor *diastolic_1;
    diastolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp1Dias rowType:XLFormRowDescriptorTypeNumber title:@"BP (2. Diastolic number)"];
    diastolic_1.required = YES;
    diastolic_1.value = [[bpRecordsArray objectAtIndex:1] objectForKey:@"diastolic_bp"];
    [self setDefaultFontWithRow:diastolic_1];
    [section addFormRow:diastolic_1];
    
    XLFormRowDescriptor *height;
    height = [XLFormRowDescriptor formRowDescriptorWithTag:kHeightCm rowType:XLFormRowDescriptorTypeNumber title:@"Height (cm)"];
    height.required = YES;
    height.value = [clinicalResultsDict objectForKey:@"height_cm"];
    [self setDefaultFontWithRow:height];
    [section addFormRow:height];
    
    XLFormRowDescriptor *weight;
    weight = [XLFormRowDescriptor formRowDescriptorWithTag:kWeightKg rowType:XLFormRowDescriptorTypeNumber title:@"Weight (kg)"];
    weight.required = YES;
    weight.value = [clinicalResultsDict objectForKey:@"weight_kg"];
    [self setDefaultFontWithRow:weight];
    [section addFormRow:weight];
    
    XLFormRowDescriptor *bmi;
    bmi = [XLFormRowDescriptor formRowDescriptorWithTag:kBmi rowType:XLFormRowDescriptorTypeText title:@"BMI"];
//    bmi.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kHeight, kWeight]];
    //Initial value only
    if ([clinicalResultsDict objectForKey:@"bmi"] != [NSNull null]) {
        if (![[clinicalResultsDict objectForKey:@"bmi"] isEqualToString:@""]) {
            bmi.value = [clinicalResultsDict objectForKey:@"bmi"];
        } else {
            if (!isnan([weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2))) {  //check for not nan first!
                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
            }
        }
    }
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
    waist = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistCircum rowType:XLFormRowDescriptorTypeNumber title:@"Waist Circumference (cm)"];
    waist.required = YES;
    waist.value = [clinicalResultsDict objectForKey:@"waist_circum"];
    [self setDefaultFontWithRow:waist];
    [section addFormRow:waist];
    
    XLFormRowDescriptor *hip;
    hip = [XLFormRowDescriptor formRowDescriptorWithTag:kHipCircum rowType:XLFormRowDescriptorTypeNumber title:@"Hip Circumference (cm)"];
    hip.required = YES;
    hip.value = [clinicalResultsDict objectForKey:@"hip_circum"];
    [self setDefaultFontWithRow:hip];
    [section addFormRow:hip];
    
    XLFormRowDescriptor *waistHipRatio;
    waistHipRatio = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistHipRatio rowType:XLFormRowDescriptorTypeText title:@"Waist : Hip Ratio"];
    waistHipRatio.required = YES;
    [self setDefaultFontWithRow:waistHipRatio];
//    waistHipRatio.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kWaistCircum, kHipCircum]];
    //Initial value
    if(![[clinicalResultsDict objectForKey:@"waist_hip_ratio"] isEqualToString:@""]) {
        waistHipRatio.value = [clinicalResultsDict objectForKey:@"waist_hip_ratio"];
    }
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCbg rowType:XLFormRowDescriptorTypeText title:@"CBG (mmol/L)"];
    row.required = YES;
    row.value = [clinicalResultsDict objectForKey:@"cbg"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    XLFormRowDescriptor *systolic_2;
    systolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp2Sys rowType:XLFormRowDescriptorTypeNumber title:@"BP Taking (2nd Systolic)"];
    systolic_2.required = YES;
    systolic_2.value = [[bpRecordsArray objectAtIndex:2] objectForKey:@"systolic_bp"];
    [self setDefaultFontWithRow:systolic_2];
    [section addFormRow:systolic_2];
    
    XLFormRowDescriptor *diastolic_2;
    diastolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBp2Dias rowType:XLFormRowDescriptorTypeNumber title:@"BP Taking (2nd Diastolic)"];
    diastolic_2.required = YES;
    diastolic_2.value = [[bpRecordsArray objectAtIndex:2] objectForKey:@"diastolic_bp"];
    [self setDefaultFontWithRow:diastolic_2];
    [section addFormRow:diastolic_2];
    
    XLFormRowDescriptor *systolic_avg;
    systolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBp12AvgSys rowType:XLFormRowDescriptorTypeText title:@"BP (Avg. of 1st & 2nd systolic)"];
    systolic_avg.required = YES;
    if (![[[bpRecordsArray objectAtIndex:0] objectForKey:@"systolic_bp"] isEqualToString:@""]) {
        systolic_avg.value = [[bpRecordsArray objectAtIndex:0] objectForKey:@"systolic_bp"];
    }
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
            systolic_avg.value = @(([systolic_1.value doubleValue]+ [systolic_2.value doubleValue])/2);
            [self updateFormRow:systolic_avg];
        }
        
    };
    
    XLFormRowDescriptor *diastolic_avg;
    diastolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBp12AvgDias rowType:XLFormRowDescriptorTypeText title:@"BP (Avg. of 1st & 2nd diastolic)"];
    diastolic_avg.required = YES;
    if (![[[bpRecordsArray objectAtIndex:0] objectForKey:@"diastolic_bp"] isEqualToString:@""]) {
        diastolic_avg.value = [[bpRecordsArray objectAtIndex:0] objectForKey:@"diastolic_bp"];
    }
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
            diastolic_avg.value = @(([diastolic_1.value integerValue]+ [diastolic_2.value integerValue])/2);
            [self updateFormRow:diastolic_avg];
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBp3Sys rowType:XLFormRowDescriptorTypeNumber title:@"BP Taking (3rd Systolic)"];
    row.required = NO;
    [row.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    row.value = [[bpRecordsArray objectAtIndex:3] objectForKey:@"systolic_bp"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBp3Dias rowType:XLFormRowDescriptorTypeNumber title:@"BP Taking (3rd Diastolic)"];
    [row.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    row.required = NO;
    row.value = [[bpRecordsArray objectAtIndex:3] objectForKey:@"diastolic_bp"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
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
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRightEye rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"1. Right Eye: "];
    row.required = YES;
    row.selectorOptions = @[@"6/6", @"6/9", @"6/12", @"6/18", @"6/24", @"6/36", @"6/60"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLeftEye rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"2. Left Eye: "];
    row.required = YES;
    row.selectorOptions = @[@"6/6", @"6/9", @"6/12", @"6/18", @"6/24", @"6/36", @"6/60"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    XLFormRowDescriptor *six12Row = [XLFormRowDescriptor formRowDescriptorWithTag:kSix12 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"3. Does either eye (or both) have vision poorer than 6/12?"];
    six12Row.required = YES;
    six12Row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:six12Row];
    [section addFormRow:six12Row];
    
    XLFormRowDescriptor *tunnelRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTunnel rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"4. Does resident have genuine visual complaints (e.g. floaters, tunnel vision, bright spots etc.)?"];
    tunnelRow.required = YES;
    tunnelRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:tunnelRow];
    [section addFormRow:tunnelRow];
    
    XLFormRowDescriptor *visitEye12Mths = [XLFormRowDescriptor formRowDescriptorWithTag:kVisitEye12Mths rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"5. Resident has not visited eye specialist in 12 months"];
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




- (id) initCurrentPhysicalIssues {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Physical Issues"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *adlDict = [self.fullScreeningForm objectForKey:@"adls"];
    
    formDescriptor.assignFirstResponderOnShow = YES;

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Activities of Daily Living"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Can you perform the following activities without assistance? (Tick those activities that the resident CAN perform on his/her own)."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiADL rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Activities"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Bathe/Shower"],
                                    [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Dress"],
                                    [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Eat"],
                                    [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Personal Hygiene and Grooming"],
                                    [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Toileting"],
                                    [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Transfer/Walk"]];
    row.value = [self getADLArrayFromDict:adlDict andOptions:row.selectorOptions];
    [section addFormRow:row];
    row.noValueDisplayText = @"Tap here for options";
    return [super initWithForm:formDescriptor];
}

-(id) initAdditionalSvcs {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Additional Services"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAppliedChas rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Applied for CHAS under NHS?"];
    row.required = NO;
    
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyCHAS];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferColonos rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Referred for colonoscopy by NHS?"];
    row.required = NO;
    
    str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyColonsc];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReceiveFit rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Receiving FIT kit from NHS?"];
    row.required = NO;
    
    str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyFIT];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferMammo rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Referred for mammogram by NHS?"];
    row.required = NO;
    
    str = [[NSUserDefaults standardUserDefaults]objectForKey:kQualifyMammo];
    
    if ([str isEqualToString:@"1"])
        row.disabled = @NO;
    else
        row.disabled = @YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferPapSmear rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Referred for PAP smear by NHS?"];
    row.required = NO;
    
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocReferred rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Referred by doctor?"];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDentalUndergone rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Undergone dental check-up?"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDentistReferred
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Referred by dentist?"];
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
    [GaitSpeedRow.cellConfigAtConfigure setObject:@(3) forKey:@"stepControl.maximumValue"];
    [GaitSpeedRow.cellConfigAtConfigure setObject:@(0) forKey:@"stepControl.minimumValue"];
    [GaitSpeedRow.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
    [self setDefaultFontWithRow:GaitSpeedRow];
    [section addFormRow:GaitSpeedRow];
    
    XLFormRowDescriptor *chairStandRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBalance
                                                rowType:XLFormRowDescriptorTypeStepCounter title:@"Chair Stand Test"];
    chairStandRow.value = @(0);
    [chairStandRow.cellConfigAtConfigure setObject:@(2) forKey:@"stepControl.maximumValue"];
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
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident require further follow up?"];
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
    section.footerTitle = @"greater than 0 and less than 255";
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAmtScore rowType:XLFormRowDescriptorTypeNumber title:@"Total score for AMT"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"greater than 0 and less than 256" regex:@"^([0-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])$"]];
    
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
    row.selectorOptions = @[@"1 year", @"2 years", @"3 years", @"4 years", @"5 years", @"6 years", @"more than 6 years"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReqFollowupGDA rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident require further follow up?"];
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



#pragma mark - Save Dictionary methods

- (void) saveEntriesIntoDictionary {
    switch([self.sectionID integerValue]) {
        case 0: //[self saveNeighbourhood];
            break;
//        case 2: [self saveClinicalResults];
//            break;
//        case 8: [self saveOtherMedicalIssues];
//            break;
//        case 9: [self savePrimaryCareSource];
//            break;
//        case 12: [self saveCurrentPhysicalIssues];
//            break;
//        case 15: [self saveRefForDoctorConsult];
//            break;
    }
}


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
//- (void) saveScreeningOfRiskFactors {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *risk_factors = [[self.fullScreeningForm objectForKey:@"risk_factors"] mutableCopy];
//                                         
//    //resident_id again
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kExYesNo] forKey:kExYesNo];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kExNoWhy] forKey:kExNoWhy];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kExNoOthers] forKey:kExNoOthers];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSmoking] forKey:kSmoking];
//
//    NSArray *smokingTypes = [fields objectForKey:kTypeOfSmoke];
//    if ((smokingTypes != (id)[NSNull null]) && smokingTypes) {
//        for(int i=0; i<[smokingTypes count]; i++) {
//            if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Cigarettes"]) [risk_factors setObject:@"1" forKey:@"ciggs"];
//            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Pipe"]) [risk_factors setObject:@"1" forKey:@"pipe"];
//            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Self-rolled leaves \"ang hoon\""]) [risk_factors setObject:@"1" forKey:@"rolled_leaves"];
//            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Shisha"]) [risk_factors setObject:@"1" forKey:@"shisha"];
//            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Cigars"]) [risk_factors setObject:@"1" forKey:@"cigars"];
//            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"E-cigarettes"]) [risk_factors setObject:@"1" forKey:@"e_ciggs"];
//            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Others"]) [risk_factors setObject:@"1" forKey:@"others"];
//        }
//    }
//    
////    ciggs, pipe, rolled_leaves, shisha, cigars, e_ciggs, others
////    @"Cigarettes", @"Pipe", @"self-rolled leaves \"ang hoon\"", @"Shisha", @"Cigars", @"E-cigarettes", @"Others"
//    
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kSmokingNumYears] forKey:kSmokingNumYears];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kSmokeNumSticks] forKey:kSmokeNumSticks];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSmokeAfterWaking] forKey:kSmokeAfterWaking];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSmokingRefrain] forKey:kSmokingRefrain];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSmokingWhichNotGiveUp] forKey:kSmokingWhichNotGiveUp];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSmokingMornFreq] forKey:kSmokingMornFreq];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSmokingSickInBed] forKey:kSmokingSickInBed];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSmokingAttemptedQuit] forKey:kSmokingAttemptedQuit];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kSmokingNumQuitAttempts] forKey:kSmokingNumQuitAttempts];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSmokingIntentionsToCut] forKey:kSmokingIntentionsToCut];
//    
//    [risk_factors setObject:@"0" forKey:@"smoking_how_by_myself"];
//    [risk_factors setObject:@"0" forKey:@"smoking_how_join_cessation"];
//    [risk_factors setObject:@"0" forKey:@"smoking_how_take_med"];
//    [risk_factors setObject:@"0" forKey:@"smoking_how_encourage"];
//    
//    if ([[fields objectForKey:kSmokingHowQuit] count]!=0) {
//        NSArray *smokingHowQuitArray = [fields objectForKey:kSmokingHowQuit];
//        for (int i=0; i<[smokingHowQuitArray count]; i++) {
//            if([[[smokingHowQuitArray objectAtIndex:i] formValue] isEqual:@(0)]) [risk_factors setObject:@"1" forKey:@"smoking_how_by_myself"];
//            else if([[[smokingHowQuitArray objectAtIndex:i] formValue] isEqual:@(1)]) [risk_factors setObject:@"1" forKey:@"smoking_how_join_cessation"];
//            else if([[[smokingHowQuitArray objectAtIndex:i] formValue] isEqual:@(2)]) [risk_factors setObject:@"1" forKey:@"smoking_how_take_med"];
//            else if([[[smokingHowQuitArray objectAtIndex:i] formValue] isEqual:@(3)]) [risk_factors setObject:@"1" forKey:@"smoking_how_encourage"];
//        }
//    }
//    
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSmokingHowQuitOthers] forKey:kSmokingHowQuitOthers];
//    
//    [risk_factors setObject:@"0" forKey:@"smoking_why_health"];
//    [risk_factors setObject:@"0" forKey:@"smoking_why_side"];
//    [risk_factors setObject:@"0" forKey:@"smoking_why_harm"];
//    [risk_factors setObject:@"0" forKey:@"smoking_why_advice"];
//    [risk_factors setObject:@"0" forKey:@"smoking_why_ex"];
//    
//    
//    if ([[fields objectForKey:kSmokingWhyQuit] count]!=0) {
//        NSArray *smokingWhyQuitArray = [fields objectForKey:kSmokingWhyQuit];
//        for (int i=0; i<[smokingWhyQuitArray count]; i++) {
//            if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(0)]) [risk_factors setObject:@"1" forKey:@"smoking_why_health"];
//            else if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(1)]) [risk_factors setObject:@"1" forKey:@"smoking_why_side"];
//            else if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(2)]) [risk_factors setObject:@"1" forKey:@"smoking_why_harm"];
//            else if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(3)]) [risk_factors setObject:@"1" forKey:@"smoking_why_advice"];
//            else if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(4)]) [risk_factors setObject:@"1" forKey:@"smoking_why_ex"];
//        }
//    }
//
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSmokingWhyQuitOthers] forKey:kSmokingWhyQuitOthers];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kAlcoholHowOften] forKey:kAlcoholHowOften];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kAlcoholNumYears] forKey:kAlcoholNumYears];
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kAlcoholConsumpn] forKey:kAlcoholConsumpn];
//    
//    NSString *alcoholPreference = [self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kAlcoholPreference];
//    
//    //reset all values first
//    [risk_factors setObject:@"0" forKey:@"beer"];
//    [risk_factors setObject:@"0" forKey:@"wine"];
//    [risk_factors setObject:@"0" forKey:@"rice_wine"];
//    [risk_factors setObject:@"0" forKey:@"spirits"];
//    [risk_factors setObject:@"0" forKey:@"stout"];
//    [risk_factors setObject:@"0" forKey:@"no_pref"];
//    
//    if ([alcoholPreference isEqualToString:@"0"]) [risk_factors setObject:@"1" forKey:@"beer"];
//    else if ([alcoholPreference isEqualToString:@"1"]) [risk_factors setObject:@"1" forKey:@"wine"];
//    else if ([alcoholPreference isEqualToString:@"2"]) [risk_factors setObject:@"1" forKey:@"rice_wine"];
//    else if ([alcoholPreference isEqualToString:@"3"]) [risk_factors setObject:@"1" forKey:@"spirits"];
//    else if ([alcoholPreference isEqualToString:@"4"]) [risk_factors setObject:@"1" forKey:@"stout"];
//    else if ([alcoholPreference isEqualToString:@"5"]) [risk_factors setObject:@"1" forKey:@"no_pref"];
//    
//    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kAlcoholIntentToCut] forKey:kAlcoholIntentToCut];
//    
//    [self.fullScreeningForm setObject:risk_factors forKey:@"risk_factors"];
//    
//}


//
//- (void) savePrimaryCareSource {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *primaryCare_dict = [[self.fullScreeningForm objectForKey:@"primary_care"] mutableCopy];
//    
//    [primaryCare_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kCareGiverID] forKey:kCareGiverID];
//    [primaryCare_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kCareProviderID] forKey:kCareProviderID];
//    
//    [primaryCare_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCareGiverOthers] forKey:kCareGiverOthers];
//    [primaryCare_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCareProviderOthers] forKey:kCareProviderOthers];
//    
//    [primaryCare_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kAneVisit] forKey:kAneVisit];
//    [primaryCare_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kHospitalized] forKey:kHospitalized];
//    
//    
//    [self.fullScreeningForm setObject:primaryCare_dict forKey:@"primary_care"];
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

- (NSArray *) getSpokenLangArray: (NSDictionary *) dictionary {
    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
    if ([[dictionary objectForKey:@"lang_canto"] isKindOfClass:[NSString class]]) {

        if([[dictionary objectForKey:@"lang_canto"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
        if([[dictionary objectForKey:@"lang_english"] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
        if([[dictionary objectForKey:@"lang_hindi"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
        if([[dictionary objectForKey:@"lang_hokkien"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
        if([[dictionary objectForKey:@"lang_malay"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
        if([[dictionary objectForKey:@"lang_mandrin"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
        if([[dictionary objectForKey:@"lang_others"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Others"];
        if([[dictionary objectForKey:@"lang_tamil"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
        if([[dictionary objectForKey:@"lang_teochew"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
    }
    else if ([[dictionary objectForKey:@"lang_english"] isKindOfClass:[NSNumber class]]) {
        if([[dictionary objectForKey:@"lang_canto"] isEqual:@(1)]) [spokenLangArray addObject:@"Cantonese"];
        if([[dictionary objectForKey:@"lang_english"] isEqual:@(1)]) [spokenLangArray addObject:@"English"];
        if([[dictionary objectForKey:@"lang_hindi"] isEqual:@(1)]) [spokenLangArray addObject:@"Hindi"];
        if([[dictionary objectForKey:@"lang_hokkien"] isEqual:@(1)]) [spokenLangArray addObject:@"Hokkien"];
        if([[dictionary objectForKey:@"lang_malay"] isEqual:@(1)]) [spokenLangArray addObject:@"Malay"];
        if([[dictionary objectForKey:@"lang_mandrin"] isEqual:@(1)]) [spokenLangArray addObject:@"Mandarin"];
        if([[dictionary objectForKey:@"lang_others"] isEqual:@(1)]) [spokenLangArray addObject:@"Others"];
        if([[dictionary objectForKey:@"lang_tamil"] isEqual:@(1)]) [spokenLangArray addObject:@"Tamil"];
        if([[dictionary objectForKey:@"lang_teochew"] isEqual:@(1)]) [spokenLangArray addObject:@"Teochew"];
    }
    return spokenLangArray;
}

- (NSArray *) getADLArrayFromDict:(NSDictionary *) dictionary andOptions:(NSArray *) options {
    NSMutableArray *adlArray = [[NSMutableArray alloc] init];
    if([[dictionary objectForKey:@"bathe"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:0]];
    if([[dictionary objectForKey:@"dress"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:1]];
    if([[dictionary objectForKey:@"eat"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:2]];
    if([[dictionary objectForKey:@"hygiene"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:3]];
    if([[dictionary objectForKey:@"toileting"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:4]];
    if([[dictionary objectForKey:@"walk"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:5]];
    
    return adlArray;
    
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

- (NSInteger) getAlcoholPrefFromIndivValues {
    NSDictionary *dictionary = [self.fullScreeningForm objectForKey:@"risk_factors"];
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    if([[dictionary objectForKey:@"beer"] isEqualToString:@"1"]) [array addObject:@"Cigarettes"];
//    if([[dictionary objectForKey:@"wine"] isEqualToString:@"1"]) [array addObject:@"Pipe"];
//    if([[dictionary objectForKey:@"rice_wine"] isEqualToString:@"1"]) [array addObject:@"Self-rolled leaves \"ang hoon\""];
//    if([[dictionary objectForKey:@"spirits"] isEqualToString:@"1"]) [array addObject:@"Shisha"];
//    if([[dictionary objectForKey:@"stout"] isEqualToString:@"1"]) [array addObject:@"Cigars"];
//    if([[dictionary objectForKey:@"no_pref"] isEqualToString:@"1"]) [array addObject:@"E-cigarettes"];
    
    if([[dictionary objectForKey:@"beer"] isEqualToString:@"1"]) return 0;
    if([[dictionary objectForKey:@"wine"] isEqualToString:@"1"]) return 1;
    if([[dictionary objectForKey:@"rice_wine"] isEqualToString:@"1"]) return 2;
    if([[dictionary objectForKey:@"spirits"] isEqualToString:@"1"]) return 3;
    if([[dictionary objectForKey:@"stout"] isEqualToString:@"1"]) return 4;
    if([[dictionary objectForKey:@"no_pref"] isEqualToString:@"1"]) return 5;

    return 10;   //default
}

- (NSArray *) getPlansArrayFromDict:(NSDictionary *) dictionary andOptions:(NSArray *) options {
    NSMutableArray *adlArray = [[NSMutableArray alloc] init];
    if([[dictionary objectForKey:@"medisave"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:0]];
    if([[dictionary objectForKey:@"insurance"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:1]];
    if([[dictionary objectForKey:@"cpf_pays"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:2]];
    if([[dictionary objectForKey:@"pgp"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:3]];
    if([[dictionary objectForKey:@"chas"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:4]];
    if([[dictionary objectForKey:@"apply_chas"] isEqualToString:@"1"]) [adlArray addObject:[options objectAtIndex:5]];
    
    return adlArray;
    
}

- (NSArray *) getSupportArrayFromDict:(NSDictionary *) dictionary andOptions:(NSArray *) options {
    NSMutableArray *supportArray = [[NSMutableArray alloc] init];
    if([[dictionary objectForKey:@"care_giving"] isEqualToString:@"1"]) [supportArray addObject:[options objectAtIndex:0]];
    if([[dictionary objectForKey:@"food"] isEqualToString:@"1"]) [supportArray addObject:[options objectAtIndex:1]];
    if([[dictionary objectForKey:@"money"] isEqualToString:@"1"]) [supportArray addObject:[options objectAtIndex:2]];
    if([[dictionary objectForKey:@"others"] isEqualToString:@"1"]) [supportArray addObject:[options objectAtIndex:3]];
    
    return supportArray;
}

- (NSArray *) getCantCopeArrayFromDict:(NSDictionary *) dictionary andOptions:(NSArray *) options {
    NSMutableArray *cantCopeArray = [[NSMutableArray alloc] init];
    if([[dictionary objectForKey:@"cant_cope_med"] isEqualToString:@"1"]) [cantCopeArray addObject:[options objectAtIndex:0]];
    if([[dictionary objectForKey:@"cant_cope_daily"] isEqualToString:@"1"]) [cantCopeArray addObject:[options objectAtIndex:1]];
    if([[dictionary objectForKey:@"cant_cope_arrears"] isEqualToString:@"1"]) [cantCopeArray addObject:[options objectAtIndex:2]];
    if([[dictionary objectForKey:@"cant_cope_others"] isEqualToString:@"1"]) [cantCopeArray addObject:[options objectAtIndex:3]];
    
    return cantCopeArray;
}


- (NSArray *) getOrgArrayFromDict: (NSDictionary *) dictionary andOptions:(NSArray *) options {
    NSMutableArray *orgArray = [[NSMutableArray alloc] init];
    if([[dictionary objectForKey:@"sac"] isEqualToString:@"1"]) [orgArray addObject:[options objectAtIndex:0]];
    if([[dictionary objectForKey:@"fsc"] isEqualToString:@"1"]) [orgArray addObject:[options objectAtIndex:1]];
    if([[dictionary objectForKey:@"cc"] isEqualToString:@"1"]) [orgArray addObject:[options objectAtIndex:2]];
    if([[dictionary objectForKey:@"rc"] isEqualToString:@"1"]) [orgArray addObject:[options objectAtIndex:3]];
    if([[dictionary objectForKey:@"ro"] isEqualToString:@"1"]) [orgArray addObject:[options objectAtIndex:4]];
    if([[dictionary objectForKey:@"so"] isEqualToString:@"1"]) [orgArray addObject:[options objectAtIndex:5]];
    if([[dictionary objectForKey:@"oth"] isEqualToString:@"1"]) [orgArray addObject:[options objectAtIndex:6]];
    if([[dictionary objectForKey:@"na"] isEqualToString:@"1"]) [orgArray addObject:[options objectAtIndex:7]];
    
    return orgArray;
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

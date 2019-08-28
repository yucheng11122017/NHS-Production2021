    //
//  ProfilingFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 9/27/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "ProfilingFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "KAStatusBar.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"
#import "ScreeningDictionary.h"
#import "ResidentProfile.h"

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


typedef enum formName {
    Profiling,
    Diabetes,
    Hyperlipidemia,
    Hypertension,
    Stroke,
    Others,
    Surgery,
    BarriersToHealthcare,
    FamilyHistory,
    RiskStratification,
    Diet,
    Exercise,
    FitTest,
    Mammogram,
    PapSmear,
    Eq5d,
    FallRiskEligible,
    DementiaEligible,
    FinanceHistory,
    FinanceAssmtBasic,
    CHAS_Eligibility,
    SocialHistory,
    SocialAssessment,
    Loneliness,
    DepressionAssmt,
    SuicideRisk
} formName;

@interface ProfilingFormVC () {
    NSString *gender;
    NSString *neighbourhood, *citizenship;
    NSNumber *age;
    BOOL noChas, lowIncome, wantChas;
    BOOL age40, chronicCond, wantFreeBt; //for phleb
    BOOL sporeanPr, age50, relColorectCancer, colon3Yrs, wantColRef, disableFIT;
    BOOL fit12Mths, colonsc10Yrs, wantFitKit;
    BOOL sporean, age5069 ,noMammo2Yrs, hasChas, wantMammo;
    BOOL age2569, noPapSmear3Yrs, hadSex, wantPapSmear;
    BOOL age65, feelFall, scaredFall, fallen12Mths;
    BOOL internetDCed;
    BOOL firstDataFetch;
    BOOL isFormFinalized;
    XLFormRowDescriptor *fallRiskScoreRow, *fallRiskStatusRow, *socialAssmtScoreRow, *phqScoreRow;
}

@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSNumber *residentID;
@property (strong, nonatomic) NSMutableArray *fallRiskQuestionsArray;

@end

@implementation ProfilingFormVC

- (void)viewDidLoad {
    
    /** initialise variables */
    internetDCed = false;
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    citizenship = [[NSUserDefaults standardUserDefaults]
                   stringForKey:kCitizenship];
    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                        stringForKey:kResidentAge];
    gender = [[NSUserDefaults standardUserDefaults]
              stringForKey:kGender];
    neighbourhood = [[NSUserDefaults standardUserDefaults]
                     stringForKey:kNeighbourhood];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    XLFormViewController *form;
    //must init first before [super viewDidLoad]
    int formNumber = [_formID intValue];
    switch (formNumber) {
        case 1:
            form = [self initDiabetesMellitus];
            break;
        case 2:
            form = [self initHyperlipidemia];
            break;
        case 3:
            form = [self initHypertension];
            break;
        case 4:
            form = [self initStroke];
            break;
        case 5:
            form = [self initMedHistOthers];
            break;
        case 6:
            form = [self initSurgery];
            break;
        case 7:
            form = [self initHealthcareBarriers];
            break;
        case 8:
            form = [self initFamilyHistory];
            break;
        case 9:
            form = [self initRiskStratification];
            break;
        case 10:
            form = [self initDietHistory];
            break;
        case 11:
            form = [self initExerciseHistory];
            break;
        case 12:
            form = [self initFitEligible];
            break;
        case 13:
            form = [self initMammogramEligible];
            break;
        case 14:
            form = [self initPapSmearEligible];
            break;
        case 15:
            form = [self initEq5d];
            break;
        case 16:
            form = [self initFallRiskAsmt];
            break;
        case 17:
            form = [self initDementiaAsmt];
            break;
        case 18:
            form = [self initFinanceHist];
            break;
        case 19:
            form = [self initFinanceAssmtBasic];
            break;
        case 20:
            form = [self initChasPrelim];
            break;
        case 21:
            form = [self initSocialHistory];
            break;
        case 22:
            form = [self initSocialAssmt];
            break;
        case 23:
            form = [self initLoneliness];
            break;
        case 24:
            form = [self initDepressionAssmt];
            break;
        case 25:
            form = [self initSuicideRisk];
            break;
            
            
        default:
            break;
    }
    [self.form setAddAsteriskToRequiredRowsTitle:YES];
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    if (isFormFinalized) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        [self.form setDisabled:YES];
        [self.tableView endEditing:YES];    //to really disable the table
        [self.tableView reloadData];
    }
    else {
        [self.form setDisabled:NO];
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finalize" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeBtnPressed:)];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated {
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    [super viewWillDisappear:animated];
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
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckDiabetes];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Diabetes Mellitus"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *hasInformedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has a western-trained doctor ever told you that you have diabetes?"];
    [self setDefaultFontWithRow:hasInformedRow];
    hasInformedRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasInformedRow.selectorOptions = @[@"Yes", @"No"];
    hasInformedRow.required = YES;
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        hasInformedRow.value = [self getYesNoFromOneZero:diabetesDict[kHasInformed]];
    }
    
    [section addFormRow:hasInformedRow];
    
    XLFormRowDescriptor *hasCheckedBloodQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ2
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"When was the last time you checked your blood sugar?"];
    [self setDefaultFontWithRow:hasCheckedBloodQRow];
    hasCheckedBloodQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasCheckedBloodQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", hasInformedRow];
    [section addFormRow:hasCheckedBloodQRow];
    
    XLFormRowDescriptor *hasCheckedBloodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMCheckedBlood rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    hasCheckedBloodRow.required = YES;
    hasCheckedBloodRow.selectorOptions = @[@"Within past 3 years", @"More than 3 years ago"];
    hasCheckedBloodRow.noValueDisplayText = @"Tap Here";
    hasCheckedBloodRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", hasInformedRow];
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kCheckedBlood] != (id)[NSNull null]) {
        hasCheckedBloodRow.value = diabetesDict[kCheckedBlood];
    }
    [section addFormRow:hasCheckedBloodRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How often are you seeing your doctor for your diabetes?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformedRow];
    [section addFormRow:row];
    
    XLFormRowDescriptor *seeDocRegularRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    seeDocRegularRow.selectorOptions = @[@"Regular (Interval of 6 months or less)", @"Occasionally (Interval of more than 6 months)", @"Seldom (last appointment was >1 year ago)", @"Not at all"];
    seeDocRegularRow.required = YES;
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        seeDocRegularRow.value = diabetesDict[kSeeingDocRegularly];
    }
    seeDocRegularRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformedRow];
    [section addFormRow:seeDocRegularRow];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4
//                                                rowType:XLFormRowDescriptorTypeInfo
//                                                  title:@"If yes to (a), are you taking any medication for your diabetes?"];
//    [self setDefaultFontWithRow:row];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformedRow];
//    [section addFormRow:row];
    
    XLFormRowDescriptor *currentPrescrRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you taking any medication for your diabetes?"];
    [self setDefaultFontWithRow:currentPrescrRow];
    currentPrescrRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    currentPrescrRow.required = YES;
    currentPrescrRow.selectorOptions = @[@"Yes", @"No"];
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kCurrentlyPrescribed] != (id)[NSNull null]) {
        currentPrescrRow.value = [self getYesNoFromOneZero:diabetesDict[kCurrentlyPrescribed]];
    }
    
    currentPrescrRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformedRow];
    [section addFormRow:currentPrescrRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ5
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How often do you forget to take your diabetes medication in a week?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformedRow];
    row.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", currentPrescrRow];
    [section addFormRow:row];
    
    // Segmented Control
    XLFormRowDescriptor *takingRegularRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    
    //Initial Setting
    if (currentPrescrRow.value != nil && currentPrescrRow.value != (id)[NSNull null]) {
        if ([currentPrescrRow.value isEqualToString:@"Yes"])
            takingRegularRow.required = YES;
        else
            takingRegularRow.required = NO;
    }
    
    takingRegularRow.selectorOptions = @[@"0", @"1-3", @"4-6", @"≥7"];
    
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kTakingRegularly] != (id)[NSNull null]) {
        takingRegularRow.value = diabetesDict[kTakingRegularly];
    }
    takingRegularRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformedRow];
    takingRegularRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", currentPrescrRow];
    [section addFormRow:takingRegularRow];
    
    //On Change Setting
    currentPrescrRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                takingRegularRow.required = YES;
            } else {
                takingRegularRow.required = NO;
            }
        }
    };
    return [super initWithForm:formDescriptor];
}

- (id) initHyperlipidemia {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *hyperlipidDict = [self.fullScreeningForm objectForKey:SECTION_HYPERLIPIDEMIA];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckHyperlipidemia];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Hyperlipidemia - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Hyperlipidemia"];
    [formDescriptor addFormSection:section];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ6
//                                                rowType:XLFormRowDescriptorTypeInfo
//                                                  title:@"Has a western-trained doctor ever told you that you have high cholesterol?"];
//    [self setDefaultFontWithRow:row];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformed = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has a western-trained doctor ever told you that you have high cholesterol?"];
    [self setDefaultFontWithRow:hasInformed];
    hasInformed.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasInformed.selectorOptions = @[@"Yes", @"No"];
    hasInformed.required = YES;
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        hasInformed.value = [self getYesNoFromOneZero:hyperlipidDict[kHasInformed]];
    }
    
    [section addFormRow:hasInformed];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ7
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"When was the last time you checked your blood cholesterol?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", hasInformed];
    [section addFormRow:row];
    
    XLFormRowDescriptor *lipidCheckBloodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCheckedBlood
                                                                                    rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                                                      title:@""];
    lipidCheckBloodRow.required = YES;
    lipidCheckBloodRow.selectorOptions = @[@"Within past 3 years",
                                           @"More than 3 years ago"];
    
    lipidCheckBloodRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", hasInformed];
    lipidCheckBloodRow.noValueDisplayText = @"Tap Here";
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kCheckedBlood] != (id)[NSNull null]) {
        lipidCheckBloodRow.value = hyperlipidDict[kCheckedBlood];
    }
    
    [section addFormRow:lipidCheckBloodRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ8
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How often are you seeing your doctor for your high cholesterol?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed];
    [section addFormRow:row];
    
    XLFormRowDescriptor *seeDocRegularRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidSeeingDocRegularly
                                                                                  rowType:XLFormRowDescriptorTypeSelectorPush
                                                                                    title:@""];
    seeDocRegularRow.selectorOptions = @[@"Regular (Interval of 6 months or less)",
                                         @"Occasionally (Interval of more than 6 months)",
                                         @"Seldom (last appointment was >1 year ago)",
                                         @"Not at all"];
    seeDocRegularRow.required = YES;
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        seeDocRegularRow.value = hyperlipidDict[kSeeingDocRegularly];
    }
    
    seeDocRegularRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed];
    [section addFormRow:seeDocRegularRow];
    
    XLFormRowDescriptor *prescribedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you taking any medication for your high cholesterol?"];
    [self setDefaultFontWithRow:prescribedRow];
    prescribedRow.required = YES;
    prescribedRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    prescribedRow.selectorOptions = @[@"Yes", @"No"];
    prescribedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kCurrentlyPrescribed] != (id)[NSNull null]) {
        prescribedRow.value = [self getYesNoFromOneZero:hyperlipidDict[kCurrentlyPrescribed]];
    }
    
    [section addFormRow:prescribedRow];
    
    XLFormRowDescriptor *takeRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ10
                                                                                   rowType:XLFormRowDescriptorTypeInfo
                                                                                     title:@"How often do you forget to take your cholesterol medication in a week?"];
    [self setDefaultFontWithRow:takeRegularlyQRow];
    takeRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    takeRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed];
    takeRegularlyQRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", prescribedRow];
    [section addFormRow:takeRegularlyQRow];
    
    // Segmented Control
    XLFormRowDescriptor *takeRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    
    //Initial Setting
    if (prescribedRow.value != nil && prescribedRow.value != (id)[NSNull null]) {
        if ([prescribedRow.value isEqualToString:@"Yes"])
            takeRegularlyRow.required = YES;
        else
            takeRegularlyRow.required = NO;
    }
    
    takeRegularlyRow.selectorOptions = @[@"0", @"1-3", @"4-6", @"≥7"];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kTakingRegularly] != (id)[NSNull null]) {
        takeRegularlyRow.value = hyperlipidDict[kTakingRegularly];
    }
    
    takeRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed];
    takeRegularlyRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", prescribedRow];
    
    [section addFormRow:takeRegularlyRow];

    //On Change Setting
    prescribedRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                takeRegularlyRow.required = YES;
            } else {
                takeRegularlyRow.required = NO;
            }
        }
    };
    return [super initWithForm:formDescriptor];
}


-(id) initHypertension {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    
    NSDictionary *hypertensionDict = [self.fullScreeningForm objectForKey:SECTION_HYPERTENSION];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckHypertension];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    // Hypertension - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Hypertension"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *hasInformed_HT = [XLFormRowDescriptor formRowDescriptorWithTag:kHTHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has a western-trained doctor ever told you that you have high BP?"];
    [self setDefaultFontWithRow:hasInformed_HT];
    hasInformed_HT.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasInformed_HT.selectorOptions = @[@"Yes", @"No"];
    hasInformed_HT.required = YES;
    
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        hasInformed_HT.value = [self getYesNoFromOneZero:hypertensionDict[kHasInformed]];
    }
    
    [section addFormRow:hasInformed_HT];
    
    XLFormRowDescriptor *checkedBPQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ2
                                                                               rowType:XLFormRowDescriptorTypeInfo
                                                                                 title:@"When was the last time you checked your blood pressure?"];
    [self setDefaultFontWithRow:checkedBPQRow];
    checkedBPQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    checkedBPQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", hasInformed_HT];
    [section addFormRow:checkedBPQRow];
    
    XLFormRowDescriptor *checkedBP = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCheckedBp rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:checkedBP];
    checkedBP.required = YES;
    checkedBP.selectorOptions = @[@"Within past 3 years", @"More than 3 years ago"];
    checkedBP.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", hasInformed_HT];
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kCheckedBp] != (id)[NSNull null]) {
        checkedBP.value = hypertensionDict[kCheckedBp];
    }
    [section addFormRow:checkedBP];
    
    
    XLFormRowDescriptor *seeDocRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"How often are you seeing your doctor for your high blood pressure?"];
    [self setDefaultFontWithRow:seeDocRegularlyQRow];
    seeDocRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    seeDocRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_HT];
    [section addFormRow:seeDocRegularlyQRow];
    
    XLFormRowDescriptor *seeDocRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    seeDocRegularlyRow.required = YES;
    seeDocRegularlyRow.selectorOptions = @[@"Regular (Interval of 6 months or less)",
                                           @"Occasionally (Interval of more than 6 months)",
                                           @"Seldom (last appointment was >1 year ago)",
                                           @"Not at all"];
    
    //value
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        seeDocRegularlyRow.value = hypertensionDict[kSeeingDocRegularly];
    }
    
    seeDocRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_HT];
    [section addFormRow:seeDocRegularlyRow];
    
    
//    XLFormRowDescriptor *prescribedQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4
//                                                                                rowType:XLFormRowDescriptorTypeInfo
//                                                                                  title:@""];
//    [self setDefaultFontWithRow:prescribedQRow];
//    prescribedQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    prescribedQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_HT];
//    [section addFormRow:prescribedQRow];
    
    XLFormRowDescriptor *prescribedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you taking any medication for your high blood pressure?"];
    prescribedRow.required = YES;
    [self setDefaultFontWithRow:prescribedRow];
    prescribedRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    prescribedRow.selectorOptions = @[@"Yes", @"No"];
    prescribedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_HT];
    
    //value
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kHTCurrentlyPrescribed] != (id)[NSNull null]) {
        prescribedRow.value = [self getYesNoFromOneZero:hypertensionDict[kCurrentlyPrescribed]];
    }
    
    
    [section addFormRow:prescribedRow];
    
    XLFormRowDescriptor *takeRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ5
                                                                                   rowType:XLFormRowDescriptorTypeInfo
                                                                                     title:@"How often do you forget to take your blood pressure medication in a week?"];
    [self setDefaultFontWithRow:takeRegularlyQRow];
    takeRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    takeRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_HT];
    takeRegularlyQRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", prescribedRow];
    [section addFormRow:takeRegularlyQRow];
    
    // Segmented Control
    XLFormRowDescriptor *takeRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    
    //Initial Setting
    if (prescribedRow.value != nil && prescribedRow.value != (id)[NSNull null]) {
        if ([prescribedRow.value isEqualToString:@"Yes"])
            takeRegularlyRow.required = YES;
        else
            takeRegularlyRow.required = NO;
    }
    
    [self setDefaultFontWithRow:takeRegularlyRow];
    takeRegularlyRow.selectorOptions = @[@"0", @"1-3", @"4-6", @"≥7"];
    
    //value
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kHTTakingRegularly] != (id)[NSNull null]) {
        takeRegularlyRow.value = hypertensionDict[kTakingRegularly];
    }
    
    takeRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_HT];
    takeRegularlyRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", prescribedRow];
    [section addFormRow:takeRegularlyRow];
    
    //On Change Setting
    prescribedRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                takeRegularlyRow.required = YES;
            } else {
                takeRegularlyRow.required = NO;
            }
        }
    };
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initStroke {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    
    NSDictionary *strokeDict = [self.fullScreeningForm objectForKey:SECTION_STROKE];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckStroke];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    // Hypertension - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical History: Stroke TTSH HLQ"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *hasInformed_Stroke = [XLFormRowDescriptor formRowDescriptorWithTag:kStrokeHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has a western-trained doctor ever told you that you have stroke?"];
    [self setDefaultFontWithRow:hasInformed_Stroke];
    hasInformed_Stroke.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasInformed_Stroke.selectorOptions = @[@"Yes", @"No"];
    hasInformed_Stroke.required = YES;
    
    if (strokeDict != (id)[NSNull null] && [strokeDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        hasInformed_Stroke.value = [self getYesNoFromOneZero:strokeDict[kStrokeHasInformed]];
    }
    
    [section addFormRow:hasInformed_Stroke];
    
    XLFormRowDescriptor *seeDocRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"How often are you seeing your doctor for your stroke?"];
    [self setDefaultFontWithRow:seeDocRegularlyQRow];
    seeDocRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    seeDocRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_Stroke];
    [section addFormRow:seeDocRegularlyQRow];
    
    XLFormRowDescriptor *seeDocRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kStrokeSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    seeDocRegularlyRow.required = YES;
    seeDocRegularlyRow.selectorOptions = @[@"Regular (Interval of 6 months or less)",
                                           @"Occasionally (Interval of more than 6 months)",
                                           @"Seldom (last appointment was >1 year ago)",
                                           @"Not at all"];
    
    //value
    if (strokeDict != (id)[NSNull null] && [strokeDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        seeDocRegularlyRow.value = strokeDict[kStrokeSeeingDocRegularly];
    }
    
    seeDocRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_Stroke];
    [section addFormRow:seeDocRegularlyRow];
    
    XLFormRowDescriptor *prescribedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kStrokeCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you taking any medication for your stroke?"];
    prescribedRow.required = YES;
    [self setDefaultFontWithRow:prescribedRow];
    prescribedRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    prescribedRow.selectorOptions = @[@"Yes", @"No"];
    prescribedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", hasInformed_Stroke];
    
    //value
    if (strokeDict != (id)[NSNull null] && [strokeDict objectForKey:kHTCurrentlyPrescribed] != (id)[NSNull null]) {
        prescribedRow.value = [self getYesNoFromOneZero:strokeDict[kStrokeCurrentlyPrescribed]];
    }
    
    [section addFormRow:prescribedRow];
    
    return [super initWithForm:formDescriptor];
}

- (id) initMedHistOthers {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Others"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Please key in NIL if not applicable";
    
    NSDictionary *medHistOthersDict = [self.fullScreeningForm objectForKey:SECTION_MEDICAL_HISTORY];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckMedicalHistory];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    XLFormRowDescriptor *otherMedQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"other_medication_q"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you taking any other medications?"];
    [self setDefaultFontWithRow:otherMedQRow];
    otherMedQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:otherMedQRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTakingMeds
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:@""];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@"Type here" forKey:@"textField.placeholder"];
    //value
    if (medHistOthersDict != (id)[NSNull null] && [medHistOthersDict objectForKey:kTakingMeds] != (id)[NSNull null]) {
        row.value = medHistOthersDict[kTakingMeds];
    }
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Please key in NIL if not applicable";
    
    XLFormRowDescriptor *otherMedCondQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"med_conds_q"
                                                                              rowType:XLFormRowDescriptorTypeInfo
                                                                                title:@"Are there any medical conditions we should take note of?"];
    [self setDefaultFontWithRow:otherMedCondQRow];
    otherMedCondQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:otherMedCondQRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedConds
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:@""];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@"Type here" forKey:@"textField.placeholder"];
    //value
    if (medHistOthersDict != (id)[NSNull null] && [medHistOthersDict objectForKey:kMedConds] != (id)[NSNull null]) {
        row.value = medHistOthersDict[kMedConds];
    }
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initSurgery {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Surgery"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Please key in NIL if not applicable";
    
    NSDictionary *surgeryDict = [self.fullScreeningForm objectForKey:SECTION_SURGERY];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSurgery];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    XLFormRowDescriptor *surgeryQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"surgery_q"
                                                                              rowType:XLFormRowDescriptorTypeInfo
                                                                                title:@"Have you had any surgery?"];
    [self setDefaultFontWithRow:surgeryQRow];
    surgeryQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:surgeryQRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHadSurgery
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:@""];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@"Type here" forKey:@"textField.placeholder"];
    //value
    if (surgeryDict != (id)[NSNull null] && [surgeryDict objectForKey:kHadSurgery] != (id)[NSNull null]) {
        row.value = surgeryDict[kHadSurgery];
    }
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initHealthcareBarriers {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Healthcare Barriers"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *healthcareBarriersDict = [self.fullScreeningForm objectForKey:SECTION_HEALTHCARE_BARRIERS];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[SECTION_HEALTHCARE_BARRIERS];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    NSString *frequency = [self checkFreqGoingDocConsult];      //"going", "not", or <empty string>
    
    XLFormRowDescriptor *doctorSeeQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_doctor_see_q"
                                                                             rowType:XLFormRowDescriptorTypeInfo
                                                                               title:@"Which doctor do you see for your existing conditions?"];
    [self setDefaultFontWithRow:doctorSeeQRow];
    doctorSeeQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:doctorSeeQRow];
    
    
    
    XLFormRowDescriptor *doctorSeeRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_doctor_see" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    doctorSeeRow.required = YES;
    doctorSeeRow.noValueDisplayText = @"Tap for options";
    doctorSeeRow.selectorOptions = @[@"General Practioner / Family Doctor",
                                   @"Family Medicine Clinic",
                                   @"Polyclinic",
                                   @"Specialist Outpatient Clinic (Hospital)"];
    
    doctorSeeRow.value = [self getDoctorSeeArray:healthcareBarriersDict];
    [section addFormRow:doctorSeeRow];
    
    
    doctorSeeRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
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
                        [self postDoctorSeeWithOptionName:[array firstObject] andValue:@"1"];
                    } else {
                        [oldSet minusSet:newSet];
                        NSArray *array = [oldSet allObjects];
                        [self postDoctorSeeWithOptionName:[array firstObject] andValue:@"0"];
                    }
                } else {
                    [self postDoctorSeeWithOptionName:[newValue firstObject] andValue:@"1"];
                }
            } else {
                if (oldValue != nil && oldValue != (id) [NSNull null]) {
                    [self postDoctorSeeWithOptionName:[oldValue firstObject] andValue:@"0"];
                }
            }
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHCBRemarks rowType:XLFormRowDescriptorTypeText title:@"Remarks (Disease/Destination)"];
    row.required = YES;
    row.noValueDisplayText = @"Type here";
    [self setDefaultFontWithRow:row];
    //value
    if (healthcareBarriersDict != (id)[NSNull null] && [healthcareBarriersDict objectForKey:kHCBRemarks] != (id)[NSNull null]) {
        row.value = healthcareBarriersDict[kHCBRemarks];
    }
    [section addFormRow:row];
    
    XLFormRowDescriptor *whyNotFollowUpQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"why_not_follow_up_q"
                                                                                       rowType:XLFormRowDescriptorTypeInfo
                                                                                         title:@"Why do you not follow-up with your doctor for your existing conditions?"];
    [self setDefaultFontWithRow:whyNotFollowUpQRow];
    whyNotFollowUpQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:whyNotFollowUpQRow];
    
    XLFormRowDescriptor *whyNotFollowUpRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"why_not_follow_up" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    whyNotFollowUpRow.selectorOptions = @[@"Do not see the need for the tests",
                            @"Challenging to make time to go for appointments",
                            @"Difficulty getting to clinic (mobility)",
                            @"Financial issues",
                            @"Scared of doctor",
                            @"Prefer traditional medicine",
                            @"Others"];
    whyNotFollowUpRow.noValueDisplayText = @"Tap for options";
    whyNotFollowUpRow.required = YES;
    whyNotFollowUpRow.value = [self getWhyNotFollowUpArray:healthcareBarriersDict];
    [section addFormRow:whyNotFollowUpRow];
    
    whyNotFollowUpRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
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
                        [self postWhyNotFollowUpWithOptionName:[array firstObject] andValue:@"1"];
                    } else {
                        [oldSet minusSet:newSet];
                        NSArray *array = [oldSet allObjects];
                        [self postWhyNotFollowUpWithOptionName:[array firstObject] andValue:@"0"];
                    }
                } else {
                    [self postWhyNotFollowUpWithOptionName:[newValue firstObject] andValue:@"1"];
                }
            } else {
                if (oldValue != nil && oldValue != (id) [NSNull null]) {
                    [self postWhyNotFollowUpWithOptionName:[oldValue firstObject] andValue:@"0"];
                }
            }
        }
    };
    
    if ([frequency isEqualToString:@"going"]) {
        whyNotFollowUpQRow.disabled = @YES;
        whyNotFollowUpRow.disabled = @YES;
        whyNotFollowUpRow.required = NO;
    } else if ([frequency isEqualToString:@"not"]) {
        doctorSeeQRow.disabled = @YES;
        doctorSeeRow.required = NO;
        doctorSeeRow.disabled = @YES;
    } else {
        whyNotFollowUpQRow.disabled = @YES;
        whyNotFollowUpRow.disabled = @YES;
        whyNotFollowUpRow.required = NO;
        doctorSeeQRow.disabled = @YES;
        doctorSeeRow.required = NO;
        doctorSeeRow.disabled = @YES;
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOtherBarrier rowType:XLFormRowDescriptorTypeText title:@"Others (please specify):"];
    row.required = YES;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", whyNotFollowUpRow];
    [self setDefaultFontWithRow:row];
    //value
    if (healthcareBarriersDict != (id)[NSNull null] && [healthcareBarriersDict objectForKey:kOtherBarrier] != (id)[NSNull null]) {
        row.value = healthcareBarriersDict[kOtherBarrier];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAeFreq rowType:XLFormRowDescriptorTypeInteger title:@"How many times have you visited the A&E in the past 6 months?"];
    row.required = YES;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    //value
    if (healthcareBarriersDict != (id)[NSNull null] && [healthcareBarriersDict objectForKey:kAeFreq] != (id)[NSNull null]) {
        row.value = healthcareBarriersDict[kAeFreq];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHospitalizedFreq rowType:XLFormRowDescriptorTypeInteger title:@"How many times have you been hospitalised in the past 1 year?"];
    row.required = YES;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    //value
    if (healthcareBarriersDict != (id)[NSNull null] && [healthcareBarriersDict objectForKey:kHospitalizedFreq] != (id)[NSNull null]) {
        row.value = healthcareBarriersDict[kHospitalizedFreq];
    }
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initFamilyHistory {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Family History"];
    XLFormSectionDescriptor * section;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *famHistDict = [self.fullScreeningForm objectForKey:SECTION_FAM_HIST];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckFamHist];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section.footerTitle = @"MI = myocardial infarction / heart attack \nCAD = coronary artery disease (narrowed blood vessels supplying heart muscle)";
    
    XLFormRowDescriptor *famHistQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1"
                                                                                       rowType:XLFormRowDescriptorTypeInfo
                                                                                         title:@"Have your immediate family members (parents/siblings/children) ever been diagnosed/told by a doctor that they have any of the chronic condition(s) listed below?"];
    [self setDefaultFontWithRow:famHistQRow];
    famHistQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:famHistQRow];
    
    XLFormRowDescriptor *famHistRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_fam_hist" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    famHistRow.required = YES;
    famHistRow.noValueDisplayText = @"Tap for options";
    famHistRow.selectorOptions = @[@"High blood pressure",
                                   @"High blood cholesterol",
                                   @"Heart attack or coronary heart disease (narrowed blood vessels supplying heart muscle)",
                                   @"Stroke",
                                   @"No, they do not have any of the above"];
    
    famHistRow.value = [self getFamHistArray:famHistDict];
    
    
    famHistRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
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
                        [self postFamHistWithOptionName:[array firstObject] andValue:@"1"];
                    } else {
                        [oldSet minusSet:newSet];
                        NSArray *array = [oldSet allObjects];
                        [self postFamHistWithOptionName:[array firstObject] andValue:@"0"];
                    }
                } else {
                    [self postFamHistWithOptionName:[newValue firstObject] andValue:@"1"];
                }
            } else {
                if (oldValue != nil && oldValue != (id) [NSNull null]) {
                    [self postFamHistWithOptionName:[oldValue firstObject] andValue:@"0"];
                }
            }
        }
    };
    
    
    [section addFormRow:famHistRow];
    
    return [super initWithForm:formDescriptor];
}


-(id) initRiskStratification {
    
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Lipids Risk Stratification"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *riskStratDict = [self.fullScreeningForm objectForKey:SECTION_RISK_STRATIFICATION];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckRiskStratification];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabeticFriend
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Do you have any immediate family member (parent/sibling/child) with diabetes mellitus?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"Yes", @"No"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kDiabeticFriend] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kDiabeticFriend]];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDelivered4kgOrGestational
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Have you delivered a baby 4 kg or more; or were previously diagnosed with gestational diabetes mellitus?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"Yes", @"No"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kDelivered4kgOrGestational] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kDelivered4kgOrGestational]];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHeartAttack
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Have you ever suffered from a \"heart attack\" or been told by your doctor that you have coronary heart disease (heart disease caused by narrowed blood vessels supplying the heart muscle)?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"Yes", @"No"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kHeartAttack] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kHeartAttack]];
    }
    [section addFormRow:row];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kStroke
//                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
//                                                  title:@"Have you ever been diagnosed by your doctor to have a stroke?"];
//    [self setDefaultFontWithRow:row];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.selectorOptions = @[@"Yes", @"No"];
//    row.required = YES;
//
//    //value
//    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kStroke] != (id)[NSNull null]) {
//        row.value = [self getYesNoFromOneZero:riskStratDict[kStroke]];
//    }
//
//    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAneurysm
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Has your doctor ever told you that the blood vessels to your limbs are diseased and have become narrower (peripheral artery disease) or that any other major blood vessels in your body have weakened walls that have \"ballooned out\" (aneurysm)?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"Yes", @"No"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kAneurysm] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kAneurysm]];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKidneyDisease
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Have you ever been diagnosed by your doctor to have chronic kidney disease?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"Yes", @"No"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kKidneyDisease] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kKidneyDisease]];
    }
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *doYouSmokeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmoke
                                                                               rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                 title:@"Do you smoke?"];
    [self setDefaultFontWithRow:doYouSmokeRow];
    doYouSmokeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    doYouSmokeRow.selectorOptions = @[@"Yes", @"No"];
    doYouSmokeRow.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kSmoke] != (id)[NSNull null]) {
        doYouSmokeRow.value = [self getYesNoFromOneZero:riskStratDict[kSmoke]];
    }
    [section addFormRow:doYouSmokeRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokeYes
                                                rowType:XLFormRowDescriptorTypeSelectorPush
                                                  title:@"Choose one only"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Less than 1 cigarette (or equivalent) per day on average",
                            @"Between 1 to 10 cigarettes (or equivalent) per day on average",
                            @"More than 10 cigarettes (or equivalent) per day on average"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", doYouSmokeRow];
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
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", doYouSmokeRow];
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kSmokeNo] != (id)[NSNull null]) {
        row.value = riskStratDict[kSmokeNo];
    }
    
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initDietHistory {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Diet History"];
    XLFormSectionDescriptor * section;
    
    NSDictionary *dietHistDict = [self.fullScreeningForm objectForKey:SECTION_DIET];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckDiet];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Note: Standard drink = 1 shot of hard liquor OR 1 can/bottle of beer OR 1 glass of wine";
    
    XLFormRowDescriptor *alcoholQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1"
                                                                             rowType:XLFormRowDescriptorTypeInfo
                                                                               title:@"Do you drink alcohol?"];
    [self setDefaultFontWithRow:alcoholQRow];
    alcoholQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:alcoholQRow];
    
    XLFormRowDescriptor *alcoholRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcohol rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    alcoholRow.required = YES;
    alcoholRow.noValueDisplayText = @"Tap for options";
    alcoholRow.selectorOptions = @[@"More than 2 standard drinks per day on average",
                                   @"Less than 2 standard drinks per day on average",
                                   @"Quit alcoholic drinks",
                                   @"No"];
    
    //value
    if (dietHistDict != (id)[NSNull null] && [dietHistDict objectForKey:kAlcohol] != (id)[NSNull null]) {
        alcoholRow.value = dietHistDict[kAlcohol];
    }
    
    [section addFormRow:alcoholRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *eatHealthyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEatHealthy
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Do you consciously try to eat more fruits, vegetables, whole grain and cereals?"];
    [self setDefaultFontWithRow:eatHealthyRow];
    eatHealthyRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    eatHealthyRow.selectorOptions = @[@"Yes", @"No"];
    eatHealthyRow.required = YES;
    
    //value
    if (dietHistDict != (id)[NSNull null] && [dietHistDict objectForKey:kEatHealthy] != (id)[NSNull null]) {
        eatHealthyRow.value = [self getYesNoFromOneZero:dietHistDict[kEatHealthy]];
    }
    [section addFormRow:eatHealthyRow];
    
    XLFormSectionDescriptor *vegeSection = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:vegeSection];
    vegeSection.footerTitle = @"Note: 1 serving = 1 small apple/orange; 1 wedge papaya/watermelon; 10 grapes/longans; 1 cup 100% fruit juice";
    vegeSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", eatHealthyRow];
    
    XLFormRowDescriptor *vegetablesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kVege rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Vegetables"];
    [self setDefaultFontWithRow:vegetablesRow];
    vegetablesRow.required = YES;
    vegetablesRow.noValueDisplayText = @"Tap for options";
    vegetablesRow.selectorOptions = @[@"1 serving per day",
                                   @"2 or more servings per day"];
    
    //value
    if (dietHistDict != (id)[NSNull null] && [dietHistDict objectForKey:kVege] != (id)[NSNull null]) {
        vegetablesRow.value = dietHistDict[kVege];
    }
    [vegeSection addFormRow:vegetablesRow];
    
    XLFormSectionDescriptor *fruitsSection = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:fruitsSection];
    fruitsSection.footerTitle = @"Note: 1 serving = 3/4 mug cooked vegetables OR 1/4 round plate cooked vegetables";
    fruitsSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", eatHealthyRow];
    
    XLFormRowDescriptor *fruitsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFruits rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Fruits"];
    [self setDefaultFontWithRow:fruitsRow];
    fruitsRow.required = YES;
    fruitsRow.noValueDisplayText = @"Tap for options";
    fruitsRow.selectorOptions = @[@"1 serving per day",
                                      @"2 or more servings per day"];
    
    //value
    if (dietHistDict != (id)[NSNull null] && [dietHistDict objectForKey:kFruits] != (id)[NSNull null]) {
        fruitsRow.value = dietHistDict[kFruits];
    }
    
    [fruitsSection addFormRow:fruitsRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *grainCerealsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kGrainsCereals
                                                                               rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                 title:@"Whole grain and cereals"];
    [self setDefaultFontWithRow:grainCerealsRow];
    grainCerealsRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    grainCerealsRow.selectorOptions = @[@"Yes", @"No"];
    grainCerealsRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", eatHealthyRow];
    grainCerealsRow.required = YES;
    
    //value
    if (dietHistDict != (id)[NSNull null] && [dietHistDict objectForKey:kGrainsCereals] != (id)[NSNull null]) {
        grainCerealsRow.value = [self getYesNoFromOneZero:dietHistDict[kGrainsCereals]];
    }
    [section addFormRow:grainCerealsRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *highFatsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"high_fats_q" rowType:XLFormRowDescriptorTypeInfo title:@"How often do you eat high fat foods e.g. hamburger, butter, fried food?"];
    [self setDefaultFontWithRow:highFatsQRow];
    highFatsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:highFatsQRow];
    
    XLFormRowDescriptor *highFatsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHighFats rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    highFatsRow.required = YES;
    highFatsRow.noValueDisplayText = @"Tap for options";
    highFatsRow.selectorOptions = @[@"Less than 2 times per week",
                                  @"2-5 times per week",
                                    @"Almost daily"];
    
    //value
    if (dietHistDict != (id)[NSNull null] && [dietHistDict objectForKey:kHighFats] != (id)[NSNull null]) {
        highFatsRow.value = dietHistDict[kHighFats];
    }
    
    [section addFormRow:highFatsRow];
    
    XLFormRowDescriptor *processedFoodQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"processed_foods_q" rowType:XLFormRowDescriptorTypeInfo title:@"How often do you eat preserved, tinned or processed foods?"];
    [self setDefaultFontWithRow:processedFoodQRow];
    processedFoodQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:processedFoodQRow];
    
    XLFormRowDescriptor *processedFoodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kProcessedFoods rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    processedFoodRow.required = YES;
    processedFoodRow.noValueDisplayText = @"Tap for options";
    processedFoodRow.selectorOptions = @[@"Less than 2 times per week",
                                    @"2-5 times per week",
                                    @"Almost daily"];
    
    //value
    if (dietHistDict != (id)[NSNull null] && [dietHistDict objectForKey:kProcessedFoods] != (id)[NSNull null]) {
        processedFoodRow.value = dietHistDict[kProcessedFoods];
    }
    [section addFormRow:processedFoodRow];
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initExerciseHistory {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Exercise History"];
    XLFormSectionDescriptor * section;
    
    NSDictionary *exerciseHistDict = [self.fullScreeningForm objectForKey:SECTION_EXERCISE];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckExercise];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Note: Examples of physical activity includes exercising, walking, playing sports, washing your car, lifting/moving moderately heavy luggage and doing housework.";
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:kDoesEngagePhysical rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Do you exercise or participate in any form of moderate physical exercise for at least 150 minutes OR intense physical activity at least 75 minutes throughout the week?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    row.required = YES;
    
    if (exerciseHistDict != (id)[NSNull null] && [exerciseHistDict objectForKey:kDoesEngagePhysical] != (id)[NSNull null])
    row.value = [self getYesNoFromOneZero:exerciseHistDict[kDoesEngagePhysical]];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"0 - Sedentary or inactive \n1 - Usual daily physical activities e.g. housework, walking to home/work \n2 - Low level of exertion (slight rise in breathing/heart rate), regularly (≥5 days per week), with sufficient duration (≥10 min each time) \n3 - Aerobic exercises for 20-60 min per week \n4 - Aerobic exercises for 1-3 h per week \n5 - Aerobic exercises for > 3h per week \n\n NOTE: aerobic exercises include brisk walking, jogging, running, cycling, swimming, vigorous sports or similar activities.";
    
    XLFormRowDescriptor *engagePhyActivityQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"engage_physical_q"
                                                                             rowType:XLFormRowDescriptorTypeInfo
                                                                               title:@"How often do you engage in physical activity?"];
    [self setDefaultFontWithRow:engagePhyActivityQRow];
    engagePhyActivityQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:engagePhyActivityQRow];
    
    XLFormRowDescriptor *engagePhyActivityRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEngagePhysical rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    engagePhyActivityRow.required = YES;
    engagePhyActivityRow.noValueDisplayText = @"Tap for options";
    engagePhyActivityRow.selectorOptions = @[@"0",
                                             @"1",
                                             @"2",
                                             @"3",
                                             @"4",
                                             @"5"];
    
    if (exerciseHistDict != (id)[NSNull null] && [exerciseHistDict objectForKey:kEngagePhysical] != (id)[NSNull null])
        engagePhyActivityRow.value = exerciseHistDict[kEngagePhysical];
    [section addFormRow:engagePhyActivityRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *reasonNotExerciseQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"not_exercise_q" rowType:XLFormRowDescriptorTypeInfo title:@"What are your main reasons for not doing any physical activity?"];
    [self setDefaultFontWithRow:reasonNotExerciseQRow];
    reasonNotExerciseQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    reasonNotExerciseQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains '0'", engagePhyActivityRow];  //previously sedentary
    [section addFormRow:reasonNotExerciseQRow];
    
    XLFormRowDescriptor *reasonNotExerciseRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_not_exercise_reason" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    reasonNotExerciseRow.selectorOptions = @[@"No time (family/work commitments)",
                                             @"Too tired",
                                             @"Too lazy",
                                             @"No interest"];
    reasonNotExerciseRow.noValueDisplayText = @"Tap for options";
    reasonNotExerciseRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains '0'", engagePhyActivityRow];  //previously sedentary
    
    reasonNotExerciseRow.value = [self getWhyNotExerciseArray:exerciseHistDict];
    
    reasonNotExerciseRow.required = YES;
    [section addFormRow:reasonNotExerciseRow];
    
    reasonNotExerciseRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
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
                        [self postWhyNoExercise:[array firstObject] andValue:@"1"];
                    } else {
                        [oldSet minusSet:newSet];
                        NSArray *array = [oldSet allObjects];
                        [self postWhyNoExercise:[array firstObject] andValue:@"0"];
                    }
                } else {
                    [self postWhyNoExercise:[newValue firstObject] andValue:@"1"];
                }
            } else {
                if (oldValue != nil && oldValue != (id) [NSNull null]) {
                    [self postWhyNoExercise:[oldValue firstObject] andValue:@"0"];
                }
            }
        }
    };
    
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initFitEligible {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"FIT Eligibility"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *fitEligibDict = [self.fullScreeningForm objectForKey:SECTION_FIT_ELIGIBLE];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckFitEligible];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    XLFormRowDescriptor *sporeanPrRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Singaporean/PR"];
    [self setDefaultFontWithRow:sporeanPrRow];
    sporeanPrRow.selectorOptions = @[@"Yes", @"No"];
    sporeanPrRow.required = NO;
    sporeanPrRow.disabled = @(1);
    [sporeanPrRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) {
        sporeanPr = YES;
        sporeanPrRow.value = @"Yes";
    }
    else {
        sporeanPr = NO;
        sporeanPrRow.value = @"No";
    }
    [section addFormRow:sporeanPrRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"age_50" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Age 50 and above"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    [row.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    row.required = NO;
    row.disabled = @(1);
    if ([age integerValue] >= 50) {
        row.value = @"Yes";
        age50 = YES;
    }
    else {
        row.value = @"No";
        age50 = NO;
//        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
    }
    [section addFormRow:row];
    
    XLFormRowDescriptor *fitLast12MthsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFitLast12Mths rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has resident done FIT in the last 12 months?"];
    if (fitEligibDict != (id)[NSNull null] && [fitEligibDict objectForKey:kFitLast12Mths] != (id)[NSNull null])
        fitLast12MthsRow.value = [self getYesNoFromOneZero:fitEligibDict[kFitLast12Mths]];
    [self setDefaultFontWithRow:fitLast12MthsRow];
    fitLast12MthsRow.selectorOptions = @[@"Yes", @"No"];
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
    
    XLFormRowDescriptor *colonoscopy10YrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kColonoscopy10Yrs rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has resident done colonoscopy in the past 10 years?"];
    if (fitEligibDict != (id)[NSNull null] && [fitEligibDict objectForKey:kColonoscopy10Yrs] != (id)[NSNull null])
        colonoscopy10YrsRow.value = [self getYesNoFromOneZero:fitEligibDict[kColonoscopy10Yrs]];
    [self setDefaultFontWithRow:colonoscopy10YrsRow];
    colonoscopy10YrsRow.selectorOptions = @[@"Yes", @"No"];
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
    
    XLFormRowDescriptor *wantFitKitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantFitKit rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident want a free FIT kit?"];
    if (fitEligibDict != (id)[NSNull null] && [fitEligibDict objectForKey:kWantFitKit] != (id)[NSNull null]) wantFitKitRow.value =
        wantFitKitRow.value = [self getYesNoFromOneZero:fitEligibDict[kWantFitKit]];
    [self setDefaultFontWithRow:wantFitKitRow];
    wantFitKitRow.selectorOptions = @[@"Yes", @"No"];
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
    
    // for the initial setting
    if (sporeanPr && age50 && relColorectCancer && colon3Yrs && wantColRef) {
        disableFIT = true;
        fitLast12MthsRow.disabled = [NSNumber numberWithBool:disableFIT];
        colonoscopy10YrsRow.disabled = [NSNumber numberWithBool:disableFIT];
        wantFitKitRow.disabled = [NSNumber numberWithBool:disableFIT];
    }
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initMammogramEligible {
    
    age5069 = noMammo2Yrs = hasChas = wantMammo = false;
    
    BOOL isMale;
    if ([gender isEqualToString:@"M"]) {
        isMale=true;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyPapSmear];
    }
    else isMale = false;
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Mammogram Eligibility"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *mammoEligibDict = [self.fullScreeningForm objectForKey:SECTION_MAMMOGRAM_ELIGIBLE];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckMammogramEligible];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Singaporean"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    [row.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    row.required = NO;
    row.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"]) {
        sporeanPr = true;
        row.value = @"Yes";
    }
    else {
        sporeanPr = false;
        row.value = @"No";
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"age_50_69" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Aged 50 to 69?"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    [row.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    row.required = NO;
    row.disabled = @(1);
    if ([age integerValue] >= 50 && [age integerValue] <= 69) {
        row.value = @"Yes";
        age5069 = YES;
    }
    else {
        row.value = @"No";
        age5069 = NO;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"has_valid_chas" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has a valid CHAS card (auto-calculated)"];
    
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.selectorOptions = @[@"Yes", @"No"];
    [row.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    row.disabled = @(1);
    if ([[ResidentProfile sharedManager] hasValidCHAS]) {
        row.value = @"Yes";
    }
    else {
        row.value = @"No";
    }
    [section addFormRow:row];
    
    XLFormRowDescriptor *mammo2YrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMammo2Yrs rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has the resident done a mammogram in the last 2 years?"];
    if (mammoEligibDict != (id)[NSNull null] && [mammoEligibDict objectForKey:kMammo2Yrs] != (id)[NSNull null])
        mammo2YrsRow.value = [self getYesNoFromOneZero:mammoEligibDict[kMammo2Yrs]];
    [self setDefaultFontWithRow:mammo2YrsRow];
    mammo2YrsRow.selectorOptions = @[@"Yes", @"No"];
    mammo2YrsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    mammo2YrsRow.required = NO;
    mammo2YrsRow.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:mammo2YrsRow];
    
    mammo2YrsRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@"Yes"]) {
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
    
    XLFormRowDescriptor *wantMammoRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantMammo rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident want a free mammogram referral?"];
    if (mammoEligibDict != (id)[NSNull null] && [mammoEligibDict objectForKey:kWantMammo] != (id)[NSNull null])
        wantMammoRow.value = [self getYesNoFromOneZero:mammoEligibDict[kWantMammo]];
    wantMammoRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:wantMammoRow];
    wantMammoRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantMammoRow.required = NO;
    wantMammoRow.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:wantMammoRow];
    
    wantMammoRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@"Yes"]) {
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
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initPapSmearEligible {
    
    BOOL isMale;
    if ([gender isEqualToString:@"M"]) {
        isMale=true;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyMammo];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyPapSmear];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else isMale = false;
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Eligibility for Pap Smear"];
    XLFormSectionDescriptor * section;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *papSmearEligibDict = _fullScreeningForm[SECTION_PAP_SMEAR_ELIGIBLE];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckMammogramEligible];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    XLFormRowDescriptor *sporeanPrRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Singaporean/PR"];
    [self setDefaultFontWithRow:sporeanPrRow];
    sporeanPrRow.selectorOptions = @[@"Yes", @"No"];
    sporeanPrRow.required = NO;
    sporeanPrRow.disabled = @(1);
    [sporeanPrRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) {
        sporeanPr = YES;
        sporeanPrRow.value = @"Yes";
    }
    else {
        sporeanPr = NO;
        sporeanPrRow.value = @"No";
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyPapSmear];
    }
    //    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:sporeanPrRow];
    
    XLFormRowDescriptor *ageCheckRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeCheck2 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Aged 25 to 69"];
    [self setDefaultFontWithRow:ageCheckRow];
    ageCheckRow.selectorOptions = @[@"Yes", @"No"];
    ageCheckRow.required = NO;
    ageCheckRow.disabled = @(1);
    [ageCheckRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    if (([age integerValue] >= 25) && ([age integerValue] < 70)) {
        age2569 = YES;
        ageCheckRow.value = @"Yes";
    }
    else {
        age2569 = NO;
        ageCheckRow.value = @"No";
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyPapSmear];
    }
    //    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:ageCheckRow];
    
    XLFormRowDescriptor *pap3Yrs = [XLFormRowDescriptor formRowDescriptorWithTag:kPap3Yrs rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Have you done a pap smear in the last 3 years?"];
    if (papSmearEligibDict != (id)[NSNull null] && [papSmearEligibDict objectForKey:kPap3Yrs] != (id)[NSNull null])
        pap3Yrs.value = [self getYesNoFromOneZero:papSmearEligibDict[kPap3Yrs]];
    [self setDefaultFontWithRow:pap3Yrs];
    pap3Yrs.selectorOptions = @[@"Yes", @"No"];
    pap3Yrs.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    pap3Yrs.required = NO;
    pap3Yrs.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:pap3Yrs];
    
    pap3Yrs.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                noPapSmear3Yrs = TRUE;
            } else {
                noPapSmear3Yrs = FALSE;
            }
            if (sporeanPr && age2569 && noPapSmear3Yrs && hadSex && wantPapSmear) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyPapSmear];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyPapSmear];
            }
            
        }
    };
    
    XLFormRowDescriptor *engageSexRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEngagedSex rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Have you engaged in sexual intercourse before?"];
    if (papSmearEligibDict != (id)[NSNull null] && [papSmearEligibDict objectForKey:kEngagedSex] != (id)[NSNull null])
        engageSexRow.value = [self getYesNoFromOneZero:papSmearEligibDict[kEngagedSex]];
    [self setDefaultFontWithRow:engageSexRow];
    engageSexRow.selectorOptions = @[@"Yes", @"No"];
    engageSexRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    engageSexRow.required = NO;
    engageSexRow.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:engageSexRow];
    
    engageSexRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                hadSex = TRUE;
            } else {
                hadSex = FALSE;
            }
            if (sporeanPr && age2569 && noPapSmear3Yrs && hadSex && wantPapSmear) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyPapSmear];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyPapSmear];
            }
            
        }
    };
    
    XLFormRowDescriptor *wantPapRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantPap rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident want a free pap smear referral?"];
    if (papSmearEligibDict != (id)[NSNull null] && [papSmearEligibDict objectForKey:kWantPap] != (id)[NSNull null])
        wantPapRow.value = [self getYesNoFromOneZero:papSmearEligibDict[kWantPap]];
    [self setDefaultFontWithRow:wantPapRow];
    wantPapRow.selectorOptions = @[@"Yes", @"No"];
    wantPapRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantPapRow.required = NO;
    wantPapRow.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:wantPapRow];
    
    wantPapRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                wantPapSmear = TRUE;
            } else {
                wantPapSmear = FALSE;
            }
            if (sporeanPr && age2569 && noPapSmear3Yrs && hadSex && wantPapSmear) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyPapSmear];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyPapSmear];
            }
            
        }
    };
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initEq5d {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Functional Self Rated Quality of Health"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    NSDictionary *eq5dDict = _fullScreeningForm[SECTION_EQ5D];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckEq5d];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    NSArray *selectorOptionsArray = @[@"0 No problem",
                                      @"1 Slight problem",
                                      @"2 Moderate problem",
                                      @"3 Severe problem",
                                      @"4 Completed unable to do so"];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *walkingQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"walking_qrow"
                                                                               rowType:XLFormRowDescriptorTypeInfo
                                                                                 title:@"Do you have any problems with walking around? If yes, how much?"];
    [self setDefaultFontWithRow:walkingQRow];
    walkingQRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:walkingQRow];
    
    XLFormRowDescriptor *walkingRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWalking
                                                                              rowType:XLFormRowDescriptorTypeSelectorPush
                                                                                title:@""];
    walkingRow.noValueDisplayText = @"Tap here for options";
    walkingRow.required = YES;
    walkingRow.selectorOptions = selectorOptionsArray;
    
    //value
    if (eq5dDict != (id)[NSNull null] && [eq5dDict objectForKey:kWalking] != (id)[NSNull null]) {
        walkingRow.value = [self getEq5dOptionsFromNumber:eq5dDict[kWalking]];
    }
    
    [section addFormRow:walkingRow];
    
    XLFormRowDescriptor *takingCareQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"taking_care_qrow"
                                                                             rowType:XLFormRowDescriptorTypeInfo
                                                                               title:@"Do you have any problems with taking care of yourself? If yes, how much?"];
    [self setDefaultFontWithRow:takingCareQRow];
    takingCareQRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:takingCareQRow];
    
    XLFormRowDescriptor *takingCareRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTakingCare
                                                                            rowType:XLFormRowDescriptorTypeSelectorPush
                                                                              title:@""];
    takingCareRow.noValueDisplayText = @"Tap here for options";
    takingCareRow.required = YES;
    takingCareRow.selectorOptions = selectorOptionsArray;
    
    //value
    if (eq5dDict != (id)[NSNull null] && [eq5dDict objectForKey:kTakingCare] != (id)[NSNull null]) {
        takingCareRow.value = [self getEq5dOptionsFromNumber:eq5dDict[kTakingCare]];
    }
    
    [section addFormRow:takingCareRow];
    
    XLFormRowDescriptor *usualActQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"usual_act_qrow"
                                                                                rowType:XLFormRowDescriptorTypeInfo
                                                                                  title:@"Do you have any problems with doing your usual activities? If yes, how much?"];
    [self setDefaultFontWithRow:usualActQRow];
    usualActQRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:usualActQRow];
    
    XLFormRowDescriptor *usualActRow = [XLFormRowDescriptor formRowDescriptorWithTag:kUsualActivities
                                                                               rowType:XLFormRowDescriptorTypeSelectorPush
                                                                                 title:@""];
    usualActRow.noValueDisplayText = @"Tap here for options";
    usualActRow.required = YES;
    usualActRow.selectorOptions = selectorOptionsArray;
    
    //value
    if (eq5dDict != (id)[NSNull null] && [eq5dDict objectForKey:kUsualActivities] != (id)[NSNull null]) {
        usualActRow.value = [self getEq5dOptionsFromNumber:eq5dDict[kUsualActivities]];
    }
    
    [section addFormRow:usualActRow];
    
    XLFormRowDescriptor *painDiscomfortQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"pain_discomfort_qrow"
                                                                              rowType:XLFormRowDescriptorTypeInfo
                                                                                title:@"Do you have any pain/discomfort? If yes, how much?"];
    [self setDefaultFontWithRow:painDiscomfortQRow];
    painDiscomfortQRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:painDiscomfortQRow];
    
    XLFormRowDescriptor *painDiscomfortRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPainDiscomfort
                                                                             rowType:XLFormRowDescriptorTypeSelectorPush
                                                                               title:@""];
    painDiscomfortRow.noValueDisplayText = @"Tap here for options";
    painDiscomfortRow.required = YES;
    painDiscomfortRow.selectorOptions = selectorOptionsArray;
    
    //value
    if (eq5dDict != (id)[NSNull null] && [eq5dDict objectForKey:kPainDiscomfort] != (id)[NSNull null]) {
        painDiscomfortRow.value = [self getEq5dOptionsFromNumber:eq5dDict[kPainDiscomfort]];
    }
    
    [section addFormRow:painDiscomfortRow];
    
    return [super initWithForm:formDescriptor];
}

- (id) initFallRiskAsmt {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Fall Risk Assessment (Basic)"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    BOOL age60Above = false;
    
    if ([age intValue] >= 60)
        age60Above = true;
    else
        age60Above = false;
    
    
    NSDictionary *fallRiskEligibleDict = _fullScreeningForm[SECTION_FALL_RISK_ELIGIBLE];
    _fallRiskQuestionsArray = [[NSMutableArray alloc] init];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckFallRiskEligible];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUndergoneAssmt
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Undergone assessment?"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    row.selectorOptions = @[@"Yes", @"No"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isComm = [defaults objectForKey:@"isComm"];
    
    if (![isComm boolValue]) row.disabled = @YES;  //if it's not Comms, then disable this.
    
    //value
    if (fallRiskEligibleDict != (id)[NSNull null] && [fallRiskEligibleDict objectForKey:kUndergoneAssmt] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:fallRiskEligibleDict[kUndergoneAssmt]];
    } else {
        if (age60Above) {
            row.value = @"Yes"; // by default
            [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kUndergoneAssmt andNewContent:@"1"];   //only if it's no value previously.
        }
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobility
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@"Current mobility Status"];
    [self setDefaultFontWithRow:row];
    row.noValueDisplayText = @"Tap here for options";
    row.required = YES;
    row.selectorOptions = @[@"Ambulant", @"Assistance required (stick/frame)", @"Wheelchair-bound", @"Bedridden"];
    
    //value
    if (fallRiskEligibleDict != (id)[NSNull null] && [fallRiskEligibleDict objectForKey:kMobility] != (id)[NSNull null]) {
        row.value = fallRiskEligibleDict[kMobility];
    }
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *numFallsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNumFalls
                                                rowType:XLFormRowDescriptorTypeSelectorPush
                                                  title:@"Number of falls in the past 12 months"];
    [self setDefaultFontWithRow:numFallsRow];
    numFallsRow.noValueDisplayText = @"Tap here";
    numFallsRow.required = YES;
    numFallsRow.selectorOptions = @[@"0", @"1", @"2", @"3 or more"];
    
    //value
    if (fallRiskEligibleDict != (id)[NSNull null] && [fallRiskEligibleDict objectForKey:kNumFalls] != (id)[NSNull null]) {
        numFallsRow.value = [self getFallRiskValueWithRow:numFallsRow andValue: [fallRiskEligibleDict objectForKey:kNumFalls]];
    }
    [section addFormRow:numFallsRow];
    
    [_fallRiskQuestionsArray addObject:numFallsRow];
    
    XLFormRowDescriptor *assistLvlQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"assist_lvl_q"
                                                                              rowType:XLFormRowDescriptorTypeInfo
                                                                                title:@"Prior to this fall, how much assistance was the individual requiring for instrumental activities of daily living (eg cooking, housework, laundry). If no fall in last 12 months, rate current function"];
    [self setDefaultFontWithRow:assistLvlQRow];
    assistLvlQRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:assistLvlQRow];
    
    XLFormRowDescriptor *assistLvlRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAssistLevel
                                                                             rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                                                title:@""];
    assistLvlRow.noValueDisplayText = @"Tap here for options";
    assistLvlRow.required = YES;
    assistLvlRow.selectorOptions = @[@"None (completely independent)", @"Supervision", @"Some assistance required", @"Completely dependent"];
    
    //value
    if (fallRiskEligibleDict != (id)[NSNull null] && [fallRiskEligibleDict objectForKey:kAssistLevel] != (id)[NSNull null]) {
        assistLvlRow.value = [self getFallRiskValueWithRow:assistLvlRow andValue: [fallRiskEligibleDict objectForKey:kAssistLevel]];
    }
    [section addFormRow:assistLvlRow];
    
    [_fallRiskQuestionsArray addObject:assistLvlRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Note: Severely unsteady means the resident need constant hands on assistance";
    
    XLFormRowDescriptor *steadinessQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"assist_lvl_q"
                                                                               rowType:XLFormRowDescriptorTypeInfo
                                                                                 title:@"When walking and turning, does the person appear unsteady or at risk of losing their balance? Observe the person standing, walking a few metres, turning and sitting. If the person uses an aid, observe the person with the aid. Do not base on self-report. If level fluctuates, choose the most unsteady rating. If the person is unable to walk due to injury, score as 3."];
    [self setDefaultFontWithRow:steadinessQRow];
    steadinessQRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:steadinessQRow];
    
    XLFormRowDescriptor *steadinessRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSteadiness
                                                                              rowType:XLFormRowDescriptorTypeSelectorPush
                                                                                 title:@""];
    [self setDefaultFontWithRow:steadinessRow];
    steadinessRow.noValueDisplayText = @"Tap here for options";
    steadinessRow.required = YES;
    steadinessRow.selectorOptions = @[@"No unsteadiness observed", @"Yes, minimally unsteady", @"Yes, moderately unsteady (needs supervision)", @"Yes, consistently and severely unsteady"];
    
    //value
    if (fallRiskEligibleDict != (id)[NSNull null] && [fallRiskEligibleDict objectForKey:kSteadiness] != (id)[NSNull null]) {

        steadinessRow.value = [self getFallRiskValueWithRow:steadinessRow andValue: [fallRiskEligibleDict objectForKey:kSteadiness]];
    }
    [section addFormRow:steadinessRow];
    [_fallRiskQuestionsArray addObject:steadinessRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    fallRiskScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFallRiskScore
                                                             rowType:XLFormRowDescriptorTypeInfo
                                                               title:@"Fall Risk Score"];
    [self setDefaultFontWithRow:fallRiskScoreRow];
    fallRiskScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    fallRiskScoreRow.disabled = @1;
    
    //value
    if (fallRiskEligibleDict != (id)[NSNull null] && [fallRiskEligibleDict objectForKey:kFallRiskScore] != (id)[NSNull null]) {
        fallRiskScoreRow.value = [fallRiskEligibleDict objectForKey:kFallRiskScore];
    }
    
    [section addFormRow:fallRiskScoreRow];
    
    fallRiskStatusRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFallRiskStatus
                                                              rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                title:@"Fall Risk Status"];
    [self setDefaultFontWithRow:fallRiskStatusRow];
    fallRiskStatusRow.selectorOptions = @[@"Low Risk", @"High Risk"];
    fallRiskStatusRow.disabled = @YES;
    fallRiskStatusRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (fallRiskEligibleDict != (id)[NSNull null] && [fallRiskEligibleDict objectForKey:kFallRiskStatus] != (id)[NSNull null]) {
        fallRiskStatusRow.value = [fallRiskEligibleDict objectForKey:kFallRiskStatus];
    }

    [section addFormRow:fallRiskStatusRow];
    
    return [super initWithForm:formDescriptor];
}

- (id) initDementiaAsmt {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Dementia Assessment (Basic)"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    BOOL age60Above = false;
    
    if ([age intValue] >= 60)
        age60Above = true;
    else
        age60Above = false;
    
    NSDictionary *dementiaEligibleDict = _fullScreeningForm[SECTION_GERIATRIC_DEMENTIA_ELIGIBLE];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckGeriatricDementiaEligible];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove65
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Age 60 and above?"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    [row.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    row.disabled = @YES;    //auto-calculated
    if (age60Above) row.value = @"Yes";
    else row.value = @"No";
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCognitiveImpair
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Resident thinks he/she has signs of cognitive impairment (e.g. forgetfulness, carelessness, lack of awareness)\nOR\nVolunteer thinks resident shows signs of cognitive impairment"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.selectorOptions = @[@"Yes", @"No"];
    
    [section addFormRow:row];
    
    //value
    if (dementiaEligibleDict != (id)[NSNull null] && [dementiaEligibleDict objectForKey:kCognitiveImpair] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:[dementiaEligibleDict objectForKey:kCognitiveImpair]];
    }
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initFinanceHist {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Financial History"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    NSDictionary *financeHistDict = _fullScreeningForm[SECTION_PROFILING_SOCIOECON];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckProfilingSocioecon];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    XLFormRowDescriptor *employmentRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStat rowType:XLFormRowDescriptorTypeSelectorPush title:@"Employment Status"];
    if (financeHistDict != (id)[NSNull null]) employmentRow.value = financeHistDict[kEmployStat];
    [self setDefaultFontWithRow:employmentRow];
    employmentRow.required = YES;
    employmentRow.selectorOptions = @[@"Retired", @"Housewife/Homemaker",@"Self- employed",@"Part-time employed",@"Full-time employed", @"Unemployed", @"Others"];
    [section addFormRow:employmentRow];
    
//    XLFormRowDescriptor *unemployReasonsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployReasons rowType:XLFormRowDescriptorTypeTextView title:@""];
//    if (financeHistDict != (id)[NSNull null] && financeHistDict[kEmployReasons] != (id)[NSNull null]) unemployReasonsRow.value = financeHistDict[kEmployReasons];
//    [self setDefaultFontWithRow:unemployReasonsRow];
//    unemployReasonsRow.required = NO;
//    unemployReasonsRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Unemployed'", employmentRow];
//    [unemployReasonsRow.cellConfigAtConfigure setObject:@"Reasons for unemployment" forKey:@"textView.placeholder"];
//
//    [section addFormRow:unemployReasonsRow];
    
//    XLFormRowDescriptor *otherEmployRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployOthers rowType:XLFormRowDescriptorTypeText title:@"Other employment"];
//    if (financeHistDict != (id)[NSNull null]) otherEmployRow.value = financeHistDict[kEmployOthers];
//    [self setDefaultFontWithRow:otherEmployRow];
//    otherEmployRow.required = NO;
//    otherEmployRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", employmentRow];
//    [otherEmployRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    [section addFormRow:otherEmployRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOccupation rowType:XLFormRowDescriptorTypeText title:@"Occupation"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfigAtConfigure setObject:@"Enter here" forKey:@"textField.placeholder"];
    if (financeHistDict != (id)[NSNull null]) row.value = financeHistDict[kOccupation];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains ' employed'", employmentRow]; //if there's other employment, don't show this!
    [self setDefaultFontWithRow:row];
    row.required = NO;
    
#warning write a code for showing this field as long as employed.
    [section addFormRow:row];

    
    XLFormRowDescriptor *noDiscloseIncomeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiscloseIncome rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you ok with telling me how much your household earns every month? (Ask about resident's monthly household income)"];
    if (financeHistDict != (id)[NSNull null] && [financeHistDict objectForKey:kDiscloseIncome] != (id)[NSNull null]) noDiscloseIncomeRow.value = [self getYesNoFromOneZero:financeHistDict[kDiscloseIncome]];
    noDiscloseIncomeRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:noDiscloseIncomeRow];
    noDiscloseIncomeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noDiscloseIncomeRow.required = NO;
    [section addFormRow:noDiscloseIncomeRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *mthHouseIncome = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgMthHouseIncome rowType:XLFormRowDescriptorTypeDecimal title:@"Average monthly household income"];
    //value
    if (financeHistDict != (id)[NSNull null] && financeHistDict[kAvgMthHouseIncome] != (id)[NSNull null])
        mthHouseIncome.value = financeHistDict[kAvgMthHouseIncome];
    
    [self setDefaultFontWithRow:mthHouseIncome];
    [mthHouseIncome.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [mthHouseIncome.cellConfigAtConfigure setObject:@"Enter here" forKey:@"textField.placeholder"];
    mthHouseIncome.cellConfig[@"textLabel.numberOfLines"] = @0;
    mthHouseIncome.required = NO;
    [section addFormRow:mthHouseIncome];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *noOfPplInHouse = [XLFormRowDescriptor formRowDescriptorWithTag:kNumPplInHouse rowType:XLFormRowDescriptorTypeInteger title:@"No. of people in the household"];
    
    //value
    if (financeHistDict != (id)[NSNull null] && financeHistDict[kNumPplInHouse] != (id) [NSNull null])
        noOfPplInHouse.value = financeHistDict[kNumPplInHouse];
    
    [self setDefaultFontWithRow:noOfPplInHouse];
    [noOfPplInHouse.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    noOfPplInHouse.cellConfig[@"textLabel.numberOfLines"] = @0;
    [noOfPplInHouse addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be greater than 0" regex:@"^[1-9][0-9]*$"]];
    noOfPplInHouse.required = NO;
    [section addFormRow:noOfPplInHouse];
    
    XLFormRowDescriptor *avgIncomePerHead = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgIncomePerHead rowType:XLFormRowDescriptorTypeDecimal title:@"Resident's household monthly income"];   //auto-calculate
    
    //value
    if (financeHistDict != (id)[NSNull null] && financeHistDict[avgIncomePerHead] != (id) [NSNull null])
        avgIncomePerHead.value = financeHistDict[avgIncomePerHead];
    
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
    
    //Initial value
    if (financeHistDict != (id)[NSNull null] && financeHistDict[kDiscloseIncome] != (id)[NSNull null]) {
        noDiscloseIncomeRow.value = [self getYesNoFromOneZero:financeHistDict[kDiscloseIncome]];
        if ([noDiscloseIncomeRow.value isEqualToString:@"No"]) {
            mthHouseIncome.disabled = @YES;
            noOfPplInHouse.disabled = @YES;
        } else {
            mthHouseIncome.disabled = @NO;
            noOfPplInHouse.disabled = @NO;
        }
        [self updateFormRow:mthHouseIncome];
        [self updateFormRow:noOfPplInHouse];
    }
    
    //On Change value
    noDiscloseIncomeRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"No"]) {
                mthHouseIncome.disabled = @YES;
                noOfPplInHouse.disabled = @YES;
            } else {
                mthHouseIncome.disabled = @NO;
                noOfPplInHouse.disabled = @NO;
            }
            [self updateFormRow:mthHouseIncome];
            [self updateFormRow:noOfPplInHouse];
        }
    };
    
    mthHouseIncome.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if (mthHouseIncome.value == (id)[NSNull null] || noOfPplInHouse.value == (id)[NSNull null])
                return; //don't bother continuing
            if ([mthHouseIncome.value integerValue] != 0 && [noOfPplInHouse.value integerValue] != 0) {
                avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", ([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])];
                [self updateFormRow:avgIncomePerHead];
                [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kAvgIncomePerHead andNewContent:newValue];
            }
        }
    };
    
    noOfPplInHouse.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if (mthHouseIncome.value == (id)[NSNull null] || noOfPplInHouse.value == (id)[NSNull null])
                return; //don't bother continuing
            if ([mthHouseIncome.value integerValue] != 0 && [noOfPplInHouse.value integerValue] != 0) {
                avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", ([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])];
                [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kNumPplInHouse andNewContent:newValue];
                [self updateFormRow:avgIncomePerHead];
            }
        }
    };
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initFinanceAssmtBasic {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Financial Assessment (Basic)"];
    XLFormSectionDescriptor * section;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    NSDictionary *financeAssmtDict = _fullScreeningForm[SECTION_FIN_ASSMT];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckFinAssmt];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    XLFormRowDescriptor *copeFinancialRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCopeFin rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you able to cope financially?"];
    [self setDefaultFontWithRow:copeFinancialRow];
    copeFinancialRow.selectorOptions = @[@"Yes", @"No"];
    
    //value
    if (financeAssmtDict != (id)[NSNull null] && [financeAssmtDict objectForKey:kCopeFin] != (id)[NSNull null]) {
        copeFinancialRow.value = [self getYesNoFromOneZero:financeAssmtDict[kCopeFin]];
    }
    copeFinancialRow.required = YES;
    copeFinancialRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:copeFinancialRow];
    
    XLFormRowDescriptor *receiveFinAssistRow = [XLFormRowDescriptor formRowDescriptorWithTag:kReceiveFinAssist rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you receiving any financial assistance?"];
    [self setDefaultFontWithRow:receiveFinAssistRow];
    receiveFinAssistRow.selectorOptions = @[@"Yes", @"No"];
    receiveFinAssistRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow]; //if there's other employment, don't show this!
    receiveFinAssistRow.required = YES;
    receiveFinAssistRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (financeAssmtDict != (id)[NSNull null] && [financeAssmtDict objectForKey:kReceiveFinAssist] != (id)[NSNull null]) {
        receiveFinAssistRow.value = [self getYesNoFromOneZero:financeAssmtDict[kReceiveFinAssist]];
    }
    
    [section addFormRow:receiveFinAssistRow];
    
    XLFormRowDescriptor *seekFinAssistRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSeekFinAssist rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Do you want to seek financial assistance?"];
    [self setDefaultFontWithRow:seekFinAssistRow];
    seekFinAssistRow.selectorOptions = @[@"Yes", @"No"];
    seekFinAssistRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow]; //if there's other employment, don't show this!
    seekFinAssistRow.required = YES;
    seekFinAssistRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (financeAssmtDict != (id)[NSNull null] && [financeAssmtDict objectForKey:kSeekFinAssist] != (id)[NSNull null]) {
        seekFinAssistRow.value = [self getYesNoFromOneZero:financeAssmtDict[kSeekFinAssist]];
    }
    
#warning If Yes, activate Social Work (Adv) and Social Work Referral!
    
    [section addFormRow:seekFinAssistRow];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initChasPrelim {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"CHAS Preliminary Elibility Assessment"];
    XLFormSectionDescriptor * section;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    NSDictionary *chasPrelimDict = _fullScreeningForm[SECTION_CHAS_PRELIM];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckChasPrelim];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    XLFormRowDescriptor *whatChasQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ1
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"Does the resident own any of these cards?"];
    [self setDefaultFontWithRow:whatChasQRow];
    whatChasQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:whatChasQRow];
    
    XLFormRowDescriptor *whatChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_owns_card" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    whatChasRow.required = YES;
    whatChasRow.selectorOptions = @[@"Blue CHAS card",
                                    @"Orange CHAS card",
                                    @"Pioneer Generation (PG) card",
                                    @"Public Assistance (PA) card",
                                    @"None of the above"];
    
    whatChasRow.noValueDisplayText = @"Tap here";
    
    //value
    if (chasPrelimDict != (id)[NSNull null]) {
        whatChasRow.value = [self getMultiCardsArray:chasPrelimDict];
    }
    
    
    [section addFormRow:whatChasRow];
    
    // Just an indicator
    XLFormRowDescriptor *chasOwnRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDoesOwnChas rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does the resident own CHAS card?"];
//    if (chasPrelimDict != (id)[NSNull null] && [chasPrelimDict objectForKey:kDoesOwnChas] != (id)[NSNull null])
//        chasOwnRow.value = [self getTrueFalseFromOneZero:chasPrelimDict[kDoesOwnChas]];
    [self setDefaultFontWithRow:chasOwnRow];
    chasOwnRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    chasOwnRow.disabled = @YES;
    [chasOwnRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    chasOwnRow.selectorOptions = @[@"Yes", @"No"];
    
    if (whatChasRow.value != nil && whatChasRow.value != (id)[NSNull null]) {
        if ([whatChasRow.value containsObject:@"Blue CHAS card"] || [whatChasRow.value containsObject:@"Orange CHAS card"]) {
            chasOwnRow.value = @"Yes";
        } else {
            chasOwnRow.value = @"No";
        }
    }
    
    whatChasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
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
                        [self postMultiCardsWithOptionName:[array firstObject] andValue:@"1"];
                    } else {
                        [oldSet minusSet:newSet];
                        NSArray *array = [oldSet allObjects];
                        [self postMultiCardsWithOptionName:[array firstObject] andValue:@"0"];
                    }
                } else {
                    [self postMultiCardsWithOptionName:[newValue firstObject] andValue:@"1"];
                }
            } else {
                if (oldValue != nil && oldValue != (id) [NSNull null]) {
                    [self postMultiCardsWithOptionName:[oldValue firstObject] andValue:@"0"];
                }
            }
            
            if (newValue != (id)[NSNull null] && newValue != nil) {
                if ([newValue containsObject:@"Blue CHAS card"] || [newValue containsObject:@"Orange CHAS card"])
                    chasOwnRow.value = @"Yes";
                else
                    chasOwnRow.value = @"No";
            } else chasOwnRow.value = @"No";
            [self reloadFormRow:chasOwnRow];
        }
    };
    
    
    
    [section addFormRow:chasOwnRow];
    
    XLFormRowDescriptor *chasExpiringRow = [XLFormRowDescriptor formRowDescriptorWithTag:kChasExpiringSoon rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is the CHAS card expiring in 3 months?"];
    if (chasPrelimDict != (id)[NSNull null] && [chasPrelimDict objectForKey:kChasExpiringSoon] != (id)[NSNull null])
        chasExpiringRow.value = [self getTrueFalseFromOneZero:chasPrelimDict[kChasExpiringSoon]];
    [self setDefaultFontWithRow:chasExpiringRow];
    chasExpiringRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    chasExpiringRow.required = NO;
    chasExpiringRow.selectorOptions = @[@"True", @"False"];
    [section addFormRow:chasExpiringRow];
    
//    whatChasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//        if (newValue != oldValue) {
//            if ([newValue isEqual:@1]) {
//                noChas = TRUE;
//            } else {
//                noChas = FALSE;
//            }
//            if (sporean && noChas && lowIncome && wantChas) {
//                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyCHAS];
//            } else {
//                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyCHAS];
//            }
//
//        }
//    };
//
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"This is required for CHAS application";
    
    XLFormRowDescriptor *lowHouseIncomeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLowHouseIncome rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"For households with income: \nIs your household monthly income $1800 and below?"];
    if (chasPrelimDict != (id)[NSNull null] && [chasPrelimDict objectForKey:kLowHouseIncome] != (id)[NSNull null])
        lowHouseIncomeRow.value = [self getYesNoFromOneZero:chasPrelimDict[kLowHouseIncome]];
    lowHouseIncomeRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:lowHouseIncomeRow];
    lowHouseIncomeRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    lowHouseIncomeRow.required = NO;
    
    if ([[ResidentProfile sharedManager] hasIncome]) lowHouseIncomeRow.disabled = @NO;
    else lowHouseIncomeRow.disabled = @YES;
    
    [section addFormRow:lowHouseIncomeRow];
    
    lowHouseIncomeRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqual:@1]) {
                lowIncome = TRUE;
            } else {
                lowIncome = FALSE;
            }
            if (sporean && noChas && lowIncome && wantChas) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyCHAS];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyCHAS];
            }
            
        }
    };
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *lowHomeValueRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLowHomeValue rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"For households with no income: \nIs the annual value (estimated annual rent) of your home $21,000 and below?"];
    if (chasPrelimDict != (id)[NSNull null] && [chasPrelimDict objectForKey:kLowHomeValue] != (id)[NSNull null])
        lowHomeValueRow.value = [self getYesNoFromOneZero:chasPrelimDict[kLowHomeValue]];
    lowHomeValueRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:lowHomeValueRow];
    lowHomeValueRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    lowHomeValueRow.required = NO;
    
    if (![[ResidentProfile sharedManager] hasIncome]) lowHomeValueRow.disabled = @NO;
    else lowHomeValueRow.disabled = @YES;
    
    [section addFormRow:lowHomeValueRow];
    
    XLFormRowDescriptor *wantChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantChas rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident want to apply for CHAS?"];
    if (chasPrelimDict != (id)[NSNull null] && [chasPrelimDict objectForKey:kWantChas] != (id)[NSNull null]) wantChasRow.value = [self getYesNoFromOneZero:chasPrelimDict[kWantChas]];
    [self setDefaultFontWithRow:wantChasRow];
    wantChasRow.selectorOptions = @[@"Yes", @"No"];
    wantChasRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantChasRow.required = NO;
    [section addFormRow:wantChasRow];
    
//    wantChasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//        if (newValue != oldValue) {
//            if ([newValue isEqual:@1]) {
//                wantChas = TRUE;
//            } else {
//                wantChas = FALSE;
//            }
//            if (sporean && noChas && lowIncome && wantChas) {
//                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kQualifyCHAS];
//            } else {
//                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kQualifyCHAS];
//            }
//
//        }
//    };
    return [super initWithForm:formDescriptor];
}

- (id) initSocialHistory {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Social History"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor *row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    NSDictionary *socialHistoryDict = _fullScreeningForm[SECTION_SOCIAL_HISTORY];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSocialHistory];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMaritalStatus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Marital Status"];
    [self setDefaultFontWithRow:row];
    if (socialHistoryDict != (id)[NSNull null] && [socialHistoryDict objectForKey:kMaritalStatus] != (id)[NSNull null])
        row.value = socialHistoryDict[kMaritalStatus];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Divorced",
                            @"Married",
                            @"Separated",
                            @"Single",
                            @"Widowed"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNumChildren rowType:XLFormRowDescriptorTypeNumber title:@"Number of children"];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfigAtConfigure setObject:@"Enter here" forKey:@"textField.placeholder"];
    if (socialHistoryDict != (id)[NSNull null] && [socialHistoryDict objectForKey:kNumChildren] != (id)[NSNull null])
        row.value = socialHistoryDict[kNumChildren];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReligion rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Religion"];
    [self setDefaultFontWithRow:row];
    if (socialHistoryDict != (id)[NSNull null] && [socialHistoryDict objectForKey:kReligion] != (id)[NSNull null])
        row.value = socialHistoryDict[kReligion];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Buddhism",
                            @"Taoism",
                            @"Islam",
                            @"Christianity",
                            @"Hinduism",
                            @"No religion",
                            @"Others"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHousingType rowType:XLFormRowDescriptorTypeSelectorPush title:@"Housing Type"];
    [self setDefaultFontWithRow:row];
    if (socialHistoryDict != (id)[NSNull null] && [socialHistoryDict objectForKey:kHousingType] != (id)[NSNull null])
        row.value = socialHistoryDict[kHousingType];
    row.required = YES;
    row.selectorOptions = @[@"Government Rented HDB 1 Room",
                            @"Government Rented HDB 2 Room",
                            @"Private Rental (incl. HDB & Condo)",
                            @"Owned HDB 1 room",
                            @"Owned HDB 2 room",
                            @"Owned HDB 3 room",
                            @"Owned HDB 4 room",
                            @"Owned HDB 5 room (incl. maisonette & executive flat)",
                            @"Owned Private Condo",
                            @"Owned Landed Property"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHighestEduLevel rowType:XLFormRowDescriptorTypeSelectorPush title:@"Highest Education Type"];
    if (socialHistoryDict != (id)[NSNull null] && [socialHistoryDict objectForKey:kHighestEduLevel] != (id)[NSNull null])
        row.value = socialHistoryDict[kHighestEduLevel];
    row.required = NO;
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"No Formal Qualifications",
                            @"Primary",
                            @"Secondary",
                            @"Post-Secondary School (Non-Tertiary)",
                            @"Polytechnic Diploma",
                            @"Professional Qualification (Non-Tertiary)",
                            @"Bachelor's or Equivalent",
                            @"Master's/ Doctorate or equivalent",
                            @"Refuse to answer"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"If months, put in decimals to 1 decimal place eg. 6 months=0.5 years";
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressDuration rowType:XLFormRowDescriptorTypeDecimal title:@"How many years have you stayed at your current block?  ____ years"];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (socialHistoryDict != (id)[NSNull null] && [socialHistoryDict objectForKey:kAddressDuration] != (id)[NSNull null])
        row.value = socialHistoryDict[kAddressDuration];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLivingArrangement rowType:XLFormRowDescriptorTypeSelectorPush title:@"Living Arrangement"];
//    [self setDefaultFontWithRow:row];
//    if (socialHistoryDict != (id)[NSNull null] && [socialHistoryDict objectForKey:kLivingArrangement] != (id)[NSNull null])
//        row.value = socialHistoryDict[kLivingArrangement];
//    row.required = YES;
//    row.selectorOptions = @[@"HDB 1-2 room flat",
//                            @"HDB 3 room flat",
//                            @"HDB 4 room flat",
//                            @"HDB 5 room flat/Executive (including mansionette)",
//                            @"Private Condo/Flat",
//                            @"Landed",
//                            @"Rental"];
//    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Please key in NIL if not applicable";
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverName rowType:XLFormRowDescriptorTypeText title:@"Caregiver's Name (if applicable)"];
    [self setDefaultFontWithRow:row];
    if (socialHistoryDict != (id)[NSNull null] && [socialHistoryDict objectForKey:kCaregiverName] != (id)[NSNull null])
        row.value = socialHistoryDict[kCaregiverName];
    [row.cellConfigAtConfigure setObject:@"Enter here" forKey:@"textField.placeholder"];
    row.required = YES;
    [section addFormRow:row];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverName rowType:XLFormRowDescriptorTypeText title:@""];
//
//
//    row.required = YES;
//    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initSocialAssmt {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Social Assessment (Basic)"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    NSDictionary *socialAssmtDict = _fullScreeningForm[SECTION_SOCIAL_ASSMT];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSocialAssmt];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ1 rowType:XLFormRowDescriptorTypeInfo title:@"Please think about your friends, relatives and family. Please indicate the extent to which you agree or disagree with the following statements. "];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ2 rowType:XLFormRowDescriptorTypeInfo title:@"1. There is someone who understands what I am going through."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUnderstands rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:row];
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kUnderstands] != (id)[NSNull null])
        row.value = [self getAgreeOptionsFromNumber:socialAssmtDict[kUnderstands]];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Strongly Disagree",
                            @"Disagree",
                            @"Agree",
                            @"Strongly Agree"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3 rowType:XLFormRowDescriptorTypeInfo title:@"2. The people close to me let me know they care about me.                             "];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCloseCare rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:row];
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kCloseCare] != (id)[NSNull null])
        row.value = [self getAgreeOptionsFromNumber:socialAssmtDict[kCloseCare]];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Strongly Disagree",
                            @"Disagree",
                            @"Agree",
                            @"Strongly Agree"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4 rowType:XLFormRowDescriptorTypeInfo title:@"3. I have a friend or relative in whose opinion I have confidence."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOpinionConfidence rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:row];
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kOpinionConfidence] != (id)[NSNull null])
        row.value = [self getAgreeOptionsFromNumber:socialAssmtDict[kOpinionConfidence]];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Strongly Disagree",
                            @"Disagree",
                            @"Agree",
                            @"Strongly Agree"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ5 rowType:XLFormRowDescriptorTypeInfo title:@"4. I have someone whom I feel I can trust."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTrust rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:row];
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kTrust] != (id)[NSNull null])
        row.value = [self getAgreeOptionsFromNumber:socialAssmtDict[kTrust]];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Strongly Disagree",
                            @"Disagree",
                            @"Agree",
                            @"Strongly Agree"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ6 rowType:XLFormRowDescriptorTypeInfo title:@"5. I have people around me who help me to keep my spirits up."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpiritsUp rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:row];
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kSpiritsUp] != (id)[NSNull null])
        row.value = [self getAgreeOptionsFromNumber:socialAssmtDict[kSpiritsUp]];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Strongly Disagree",
                            @"Disagree",
                            @"Agree",
                            @"Strongly Agree"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ7 rowType:XLFormRowDescriptorTypeInfo title:@"6. There are people in my life who make me feel good about myself."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelGood rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:row];
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kFeelGood] != (id)[NSNull null])
        row.value = [self getAgreeOptionsFromNumber:socialAssmtDict[kFeelGood]];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Strongly Disagree",
                            @"Disagree",
                            @"Agree",
                            @"Strongly Agree"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ8 rowType:XLFormRowDescriptorTypeInfo title:@"7. I have at least one friend or relative that I can really confide in."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConfide rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:row];
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kConfide] != (id)[NSNull null])
        row.value = [self getAgreeOptionsFromNumber:socialAssmtDict[kConfide]];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Strongly Disagree",
                            @"Disagree",
                            @"Agree",
                            @"Strongly Agree"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ9 rowType:XLFormRowDescriptorTypeInfo title:@"8. I have at least one friend or relative I want to be with when I am feeling down or discouraged."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDownDiscouraged rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:row];
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kDownDiscouraged] != (id)[NSNull null])
        row.value = [self getAgreeOptionsFromNumber:socialAssmtDict[kDownDiscouraged]];
    row.required = NO;
    row.noValueDisplayText = @"Tap Here";
    row.selectorOptions = @[@"Strongly Disagree",
                            @"Disagree",
                            @"Agree",
                            @"Strongly Agree"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"social_score_q" rowType:XLFormRowDescriptorTypeInfo title:@"Total score for L1 generic social questionnaire"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];
    
    socialAssmtScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSocialAssmtScore rowType:XLFormRowDescriptorTypeNumber title:@""];
    [self setDefaultFontWithRow:socialAssmtScoreRow];
    socialAssmtScoreRow.required = NO;
    socialAssmtScoreRow.disabled = @YES;
    
    if (socialAssmtDict != (id)[NSNull null] && [socialAssmtDict objectForKey:kSocialAssmtScore] != (id)[NSNull null])
        socialAssmtScoreRow.value = socialAssmtDict[kSocialAssmtScore];
    
    [section addFormRow:socialAssmtScoreRow];

    return [super initWithForm:formDescriptor];
}

- (id) initLoneliness {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Loneliness"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *lonelinessDict = _fullScreeningForm[SECTION_LONELINESS];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckLoneliness];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    NSArray *phqOptions = @[@"0 Hardly ever", @"1 Sometimes", @"2 Often"];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel that you lack companionship?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *lackCompanionRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLackCompanionship rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    lackCompanionRow.selectorOptions = phqOptions;
    lackCompanionRow.noValueDisplayText = @"Tap here";
    
    if (lonelinessDict != (id)[NSNull null] && [lonelinessDict objectForKey:kLackCompanionship] != (id)[NSNull null]) {
        lackCompanionRow.value = [self getLonelinessOptionsFromNumber:lonelinessDict[kLackCompanionship]];
    }
    
    [section addFormRow:lackCompanionRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q2" rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel left out?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *leftOutRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLeftOut rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    leftOutRow.selectorOptions = phqOptions;
    leftOutRow.noValueDisplayText = @"Tap here";
    
    if (lonelinessDict != (id)[NSNull null] && [lonelinessDict objectForKey:kLeftOut] != (id)[NSNull null]) {
        leftOutRow.value = [self getLonelinessOptionsFromNumber:lonelinessDict[kLeftOut]];
    }
    
    [section addFormRow:leftOutRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q3" rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel isolated from others?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *isolatedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kIsolated rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    isolatedRow.selectorOptions = phqOptions;
    isolatedRow.noValueDisplayText = @"Tap here";
    
    if (lonelinessDict != (id)[NSNull null] && [lonelinessDict objectForKey:kIsolated] != (id)[NSNull null]) {
        isolatedRow.value = [self getLonelinessOptionsFromNumber:lonelinessDict[kIsolated]];
    }
    
    [section addFormRow:isolatedRow];
    
    return [super initWithForm:formDescriptor];
}

- (id) initDepressionAssmt {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Depression Assessment (Basic)"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *depressionDict = _fullScreeningForm[SECTION_DEPRESSION];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckDepression];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    NSArray *phqOptions = @[@"Not at all [0]", @"Several days [1]", @"More than half the days [2]", @"Nearly every day [3]"];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"1. Have you ever felt that life was not worth living? If yes, when? Do you feel that way now?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *phqQ1Row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ1 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    phqQ1Row.selectorOptions = phqOptions;
    phqQ1Row.noValueDisplayText = @"Tap here";
    
    if (depressionDict != (id)[NSNull null] && [depressionDict objectForKey:kPhqQ1] != (id)[NSNull null]) {
        phqQ1Row.value = [self getSelectorOptionFromNumber:depressionDict[kPhqQ1]];
    }
    
    [section addFormRow:phqQ1Row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q2" rowType:XLFormRowDescriptorTypeInfo title:@"2. Feeling down, depressed or hopeless"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *phqQ2Row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ2 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    phqQ2Row.selectorOptions = phqOptions;
    phqQ2Row.noValueDisplayText = @"Tap here";
    
    if (depressionDict != (id)[NSNull null] && [depressionDict objectForKey:kPhqQ2] != (id)[NSNull null]) {
        phqQ2Row.value = [self getSelectorOptionFromNumber:depressionDict[kPhqQ2]];
    }
    
    [section addFormRow:phqQ2Row];
    
    phqScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ2Score rowType:XLFormRowDescriptorTypeText title:@"PHQ-2 Score"];
    [self setDefaultFontWithRow:phqScoreRow];
    phqScoreRow.required = NO;
    phqScoreRow.disabled = @YES;
    [phqScoreRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    if (depressionDict != (id)[NSNull null] && [depressionDict objectForKey:kPhqQ2Score] != (id)[NSNull null])
        phqScoreRow.value = depressionDict[kPhqQ2Score];
    
    [section addFormRow:phqScoreRow];
    
    return [super initWithForm:formDescriptor];
    
}
    
- (id) initSuicideRisk {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Suicide Risk Assessment (Basic)"];
    XLFormSectionDescriptor * section;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    NSDictionary *suicideRiskDict = _fullScreeningForm[SECTION_SUICIDE_RISK];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSuicideRisk];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    XLFormRowDescriptor *problemApproachQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ1
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"When you come across problems that are overwhelming, what do you normally do? E.g. loss of job, sudden death of family member/friend\n\nWho do you approach?"];
    [self setDefaultFontWithRow:problemApproachQRow];
    problemApproachQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:problemApproachQRow];
    
    XLFormRowDescriptor *problemApproachRow = [XLFormRowDescriptor formRowDescriptorWithTag:kProblemApproach rowType:XLFormRowDescriptorTypeText title:@""];
    problemApproachRow.required = NO;
    [problemApproachRow.cellConfigAtConfigure setObject:@"Text" forKey:@"textField.placeholder"];
    
    if (suicideRiskDict != (id)[NSNull null] && [suicideRiskDict objectForKey:kProblemApproach] != (id)[NSNull null]) {
        problemApproachRow.value = suicideRiskDict[kProblemApproach];
    }
    [section addFormRow:problemApproachRow];
    
    XLFormRowDescriptor *livingLifeQrow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ2
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"Have you ever had thoughts of ending your life? If yes, when? Do you still feel that way now? (你有过轻生的念想吗?)"];
    [self setDefaultFontWithRow:livingLifeQrow];
    livingLifeQrow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:livingLifeQrow];
    
    XLFormRowDescriptor *livingLifeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLivingLife rowType:XLFormRowDescriptorTypeText title:@""];
    livingLifeRow.required = NO;
    [livingLifeRow.cellConfigAtConfigure setObject:@"Text" forKey:@"textField.placeholder"];
    
    if (suicideRiskDict != (id)[NSNull null] && [suicideRiskDict objectForKey:kLivingLife] != (id)[NSNull null]) {
        livingLifeRow.value = suicideRiskDict[kLivingLife];
    }
    [section addFormRow:livingLifeRow];
    
    XLFormRowDescriptor *possibleSuicideRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPossibleSuicide rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Volunteer Assessment: Possible Suicide Risk?"];
    possibleSuicideRow.selectorOptions = @[@"Yes", @"No"];
    possibleSuicideRow.required = YES;
    [self setDefaultFontWithRow:possibleSuicideRow];
    possibleSuicideRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    
    if (suicideRiskDict != (id)[NSNull null] && [suicideRiskDict objectForKey:kPossibleSuicide] != (id)[NSNull null]) {
        possibleSuicideRow.value = [self getYesNoFromOneZero:suicideRiskDict[kPossibleSuicide]];
    }
    [section addFormRow:possibleSuicideRow];
    
    return [super initWithForm:formDescriptor];
    
}

#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    NSString* ansFromYesNo;
    
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"YES"] || [newValue isEqualToString:@"Yes"])
            ansFromYesNo = @"1";
        else if ([newValue isEqualToString:@"NO"] || [newValue isEqualToString:@"No"])
            ansFromYesNo = @"0";
    }
    
    NSString* ansFromTrueFalse;
    
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"True"])
            ansFromTrueFalse = @"1";
        else if ([newValue isEqualToString:@"False"])
            ansFromTrueFalse = @"0";
    }
    
    /* Profiling */
    if ([rowDescriptor.tag isEqualToString:kProfilingConsent]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kProfilingConsent andNewContent:ansFromYesNo];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kRelWColorectCancer]) {
        [self postSingleFieldWithSection:SECTION_COLONOSCOPY_ELIGIBLE andFieldName:kRelWColorectCancer andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kColonoscopy3yrs]) {
        [self postSingleFieldWithSection:SECTION_COLONOSCOPY_ELIGIBLE andFieldName:kColonoscopy3yrs andNewContent:newValue];
    }else if ([rowDescriptor.tag isEqualToString:kWantColonoscopyRef]) {
        [self postSingleFieldWithSection:SECTION_COLONOSCOPY_ELIGIBLE andFieldName:kWantColonoscopyRef andNewContent:newValue];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kFallen12Mths]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kFallen12Mths andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kScaredFall]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kScaredFall andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kFeelFall]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kFeelFall andNewContent:newValue];
    }
    
    /* Diabetes Mellitus */
    
    else if ([rowDescriptor.tag isEqualToString:kDMHasInformed]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kHasInformed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kDMCheckedBlood]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kCheckedBlood andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDMSeeingDocRegularly]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kSeeingDocRegularly andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDMCurrentlyPrescribed]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kCurrentlyPrescribed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kDMTakingRegularly]) {
        [self postSingleFieldWithSection:SECTION_DIABETES andFieldName:kTakingRegularly andNewContent:newValue];
    }
    
    /* Hyperlipidemia */
    
    else if ([rowDescriptor.tag isEqualToString:kLipidHasInformed]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kHasInformed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kLipidCheckedBlood]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kCheckedBlood andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kLipidSeeingDocRegularly]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kSeeingDocRegularly andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kLipidCurrentlyPrescribed]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kCurrentlyPrescribed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kLipidTakingRegularly]) {
        [self postSingleFieldWithSection:SECTION_HYPERLIPIDEMIA andFieldName:kTakingRegularly andNewContent:newValue];
    }
    
    /* HyperTension */
    
    else if ([rowDescriptor.tag isEqualToString:kHTHasInformed]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kHasInformed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHTCheckedBp]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kCheckedBp andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kHTSeeingDocRegularly]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kSeeingDocRegularly andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kHTCurrentlyPrescribed]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kCurrentlyPrescribed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHTTakingRegularly]) {
        [self postSingleFieldWithSection:SECTION_HYPERTENSION andFieldName:kTakingRegularly andNewContent:newValue];
    }
    
    /* Stroke */
    
    else if ([rowDescriptor.tag isEqualToString:kStrokeHasInformed]) {
        [self postSingleFieldWithSection:SECTION_STROKE andFieldName:kHasInformed andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kStrokeSeeingDocRegularly]) {
        [self postSingleFieldWithSection:SECTION_STROKE andFieldName:kSeeingDocRegularly andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kStrokeCurrentlyPrescribed]) {
        [self postSingleFieldWithSection:SECTION_STROKE andFieldName:kCurrentlyPrescribed andNewContent:ansFromYesNo];
    }
    
    /* Risk Stratification */
    else if ([rowDescriptor.tag isEqualToString:kDiabeticFriend]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kDiabeticFriend andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kDelivered4kgOrGestational]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kDelivered4kgOrGestational andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHeartAttack]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kHeartAttack andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kStroke]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kStroke andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kAneurysm]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kAneurysm andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kKidneyDisease]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kKidneyDisease andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kSmoke]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kSmoke andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kSmokeYes]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kSmokeYes andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSmokeNo]) {
        [self postSingleFieldWithSection:SECTION_RISK_STRATIFICATION andFieldName:kSmokeNo andNewContent:rowDescriptor.value];
    }
    
    /* Healthcare Barriers */
//    else if ([rowDescriptor.tag isEqualToString:kremarks]) {
//        [self postSingleFieldWithSection:SECTION_HEALTHCARE_BARRIERS andFieldName:kExistingDoc andNewContent:newValue];
//    } else if ([rowDescriptor.tag isEqualToString:kWhyNotFollowUp]) {
//        [self postSingleFieldWithSection:SECTION_HEALTHCARE_BARRIERS andFieldName:kWhyNotFollowUp andNewContent:newValue];
//    }
    
    
    /* Diet History */
    else if ([rowDescriptor.tag isEqualToString:kAlcohol]) {
        [self postSingleFieldWithSection:SECTION_DIET andFieldName:kAlcohol andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kEatHealthy]) {
        [self postSingleFieldWithSection:SECTION_DIET andFieldName:kEatHealthy andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kVege]) {
        [self postSingleFieldWithSection:SECTION_DIET andFieldName:kVege andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kFruits]) {
        [self postSingleFieldWithSection:SECTION_DIET andFieldName:kFruits andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kGrainsCereals]) {
        [self postSingleFieldWithSection:SECTION_DIET andFieldName:kGrainsCereals andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHighFats]) {
        [self postSingleFieldWithSection:SECTION_DIET andFieldName:kHighFats andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kProcessedFoods]) {
        [self postSingleFieldWithSection:SECTION_DIET andFieldName:kProcessedFoods andNewContent:newValue];
    }
    
    /* Exercise History */
    else if ([rowDescriptor.tag isEqualToString:kDoesEngagePhysical]) {
        [self postSingleFieldWithSection:SECTION_EXERCISE andFieldName:kDoesEngagePhysical andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kEngagePhysical]) {
        [self postSingleFieldWithSection:SECTION_EXERCISE andFieldName:kEngagePhysical andNewContent:newValue];
    }
    
    /* FIT Eligibility */
    else if ([rowDescriptor.tag isEqualToString:kFitLast12Mths]) {
        [self postSingleFieldWithSection:SECTION_FIT_ELIGIBLE andFieldName:kFitLast12Mths andNewContent:ansFromYesNo];
    }else if ([rowDescriptor.tag isEqualToString:kColonoscopy10Yrs]) {
        [self postSingleFieldWithSection:SECTION_FIT_ELIGIBLE andFieldName:kColonoscopy10Yrs andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kWantFitKit]) {
        [self postSingleFieldWithSection:SECTION_FIT_ELIGIBLE andFieldName:kWantFitKit andNewContent:ansFromYesNo];
    }
    
    /* Mammogram Eligibility */
    else if ([rowDescriptor.tag isEqualToString:kMammo2Yrs]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_ELIGIBLE andFieldName:kMammo2Yrs andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kWantMammo]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_ELIGIBLE andFieldName:kWantMammo andNewContent:ansFromYesNo];
    }
    
    /* Pap Smear Eligibility */
    else if ([rowDescriptor.tag isEqualToString:kPap3Yrs]) {
        [self postSingleFieldWithSection:SECTION_PAP_SMEAR_ELIGIBLE andFieldName:kPap3Yrs andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kEngagedSex]) {
        [self postSingleFieldWithSection:SECTION_PAP_SMEAR_ELIGIBLE andFieldName:kEngagedSex andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kWantPap]) {
        [self postSingleFieldWithSection:SECTION_PAP_SMEAR_ELIGIBLE andFieldName:kWantPap andNewContent:ansFromYesNo];
    }
    
    /* Geriatric Depression Assessment */
//    else if ([rowDescriptor.tag isEqualToString:kPhqQ1]) {
//        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ1 andNewContent:newValue];
//    } else if ([rowDescriptor.tag isEqualToString:kPhqQ2]) {
//        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ2 andNewContent:newValue];
//    } else if ([rowDescriptor.tag isEqualToString:kPhq9Score]) {
//        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhq9Score andNewContent:newValue];
//    }  else if ([rowDescriptor.tag isEqualToString:kQ10Response]) {
//        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kQ10Response andNewContent:newValue];
//    } else if ([rowDescriptor.tag isEqualToString:kFollowUpReq]) {
//        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kFollowUpReq andNewContent:newValue];
//    }
    
    /* EQ5D */
    else if ([rowDescriptor.tag isEqualToString:kWalking]) {
        [self postSingleFieldWithSection:SECTION_EQ5D andFieldName:kWalking andNewContent:[newValue substringWithRange:NSMakeRange(0, 1)]];
    } else if ([rowDescriptor.tag isEqualToString:kTakingCare]) {
        [self postSingleFieldWithSection:SECTION_EQ5D andFieldName:kTakingCare andNewContent:[newValue substringWithRange:NSMakeRange(0, 1)]];
    } else if ([rowDescriptor.tag isEqualToString:kUsualActivities]) {
        [self postSingleFieldWithSection:SECTION_EQ5D andFieldName:kUsualActivities andNewContent:[newValue substringWithRange:NSMakeRange(0, 1)]];
    } else if ([rowDescriptor.tag isEqualToString:kPainDiscomfort]) {
        [self postSingleFieldWithSection:SECTION_EQ5D andFieldName:kPainDiscomfort andNewContent:[newValue substringWithRange:NSMakeRange(0, 1)]];
    }
    
    
    /* Fall Risk Assessment (Basic) */
    else if ([rowDescriptor.tag isEqualToString:kUndergoneAssmt]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kUndergoneAssmt andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kMobility]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kMobility andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNumFalls]) {
        NSString *ans;
        if ([rowDescriptor.value containsString:@"0"]) ans = @"0";
        else if ([rowDescriptor.value containsString:@"1"]) ans = @"1";
        else if ([rowDescriptor.value containsString:@"2"]) ans = @"2";
        else if ([rowDescriptor.value containsString:@"3"]) ans = @"3";
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kNumFalls andNewContent:ans];
        
        fallRiskScoreRow.value = [NSNumber numberWithInt:[self calculateTotalFallRiskScore]];
        [self reloadFormRow:fallRiskScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kAssistLevel]) {
        NSString *ans;
        if ([rowDescriptor.value containsString:@"None"]) ans = @"0";
        else if ([rowDescriptor.value containsString:@"Supervision"]) ans = @"1";
        else if ([rowDescriptor.value containsString:@"assistance"]) ans = @"2";
        else if ([rowDescriptor.value containsString:@"dependent"]) ans = @"3";
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kAssistLevel andNewContent:ans];
        fallRiskScoreRow.value = [NSNumber numberWithInt:[self calculateTotalFallRiskScore]];
        [self reloadFormRow:fallRiskScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kSteadiness]) {
        NSString *ans;
        if ([rowDescriptor.value containsString:@"unsteadiness"]) ans = @"0";
        else if ([rowDescriptor.value containsString:@"minimally"]) ans = @"1";
        else if ([rowDescriptor.value containsString:@"moderately"]) ans = @"2";
        else if ([rowDescriptor.value containsString:@"severely"]) ans = @"3";
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kSteadiness andNewContent:ans];
        fallRiskScoreRow.value = [NSNumber numberWithInt:[self calculateTotalFallRiskScore]];
        [self reloadFormRow:fallRiskScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kFallRiskScore]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kFallRiskScore andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFallRiskStatus]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kFallRiskStatus andNewContent:rowDescriptor.value];
    }
    
    /* Dementia Assessment (Basic) */
    else if ([rowDescriptor.tag isEqualToString:kCognitiveImpair]) {
        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ELIGIBLE andFieldName:kCognitiveImpair andNewContent:ansFromYesNo];
    }
    
    /* Finance History */
    else if ([rowDescriptor.tag isEqualToString:kEmployStat]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kEmployStat andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDiscloseIncome]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kDiscloseIncome andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kAvgIncomePerHead]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kAvgIncomePerHead andNewContent:newValue];
    }
    
    /* Finance Assessment (Basic) */
    else if ([rowDescriptor.tag isEqualToString:kCopeFin]) {
        [self postSingleFieldWithSection:SECTION_FIN_ASSMT andFieldName:kCopeFin andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kReceiveFinAssist]) {
        [self postSingleFieldWithSection:SECTION_FIN_ASSMT andFieldName:kReceiveFinAssist andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kSeekFinAssist]) {
        [self postSingleFieldWithSection:SECTION_FIN_ASSMT andFieldName:kSeekFinAssist andNewContent:ansFromYesNo];
    }
    
    /* CHAS Preliminary Eligibility Assessment */
    else if ([rowDescriptor.tag isEqualToString:kDoesNotOwnChasPioneer]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kDoesNotOwnChasPioneer andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kDoesOwnChas]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kDoesOwnChas andNewContent:ansFromTrueFalse];
    } else if ([rowDescriptor.tag isEqualToString:kChasExpiringSoon]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kChasExpiringSoon andNewContent:ansFromTrueFalse];
    } else if ([rowDescriptor.tag isEqualToString:kLowHouseIncome]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kLowHouseIncome andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kLowHomeValue]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kLowHomeValue andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kWantChas]) {
        [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:kWantChas andNewContent:ansFromYesNo];
    }
    
    /* Social History */
    else if ([rowDescriptor.tag isEqualToString:kMaritalStatus]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_HISTORY andFieldName:kMaritalStatus andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kReligion]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_HISTORY andFieldName:kReligion andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kHighestEduLevel]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_HISTORY andFieldName:kHighestEduLevel andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kHousingType]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_HISTORY andFieldName:kHousingType andNewContent:newValue];
    }
    
    /* Social Assessment (Basic) */
    else if ([rowDescriptor.tag isEqualToString:kUnderstands]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kUnderstands andNewContent:[self getNumberFromAgreeOptions:newValue]];
        [self calculateSocAssmtScore];
    } else if ([rowDescriptor.tag isEqualToString:kCloseCare]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kCloseCare andNewContent:[self getNumberFromAgreeOptions:newValue]];
        [self calculateSocAssmtScore];
    } else if ([rowDescriptor.tag isEqualToString:kOpinionConfidence]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kOpinionConfidence andNewContent:[self getNumberFromAgreeOptions:newValue]];
        [self calculateSocAssmtScore];
    } else if ([rowDescriptor.tag isEqualToString:kTrust]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kTrust andNewContent:[self getNumberFromAgreeOptions:newValue]];
        [self calculateSocAssmtScore];
    } else if ([rowDescriptor.tag isEqualToString:kSpiritsUp]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kSpiritsUp andNewContent:[self getNumberFromAgreeOptions:newValue]];
        [self calculateSocAssmtScore];
    } else if ([rowDescriptor.tag isEqualToString:kFeelGood]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kFeelGood andNewContent:[self getNumberFromAgreeOptions:newValue]];
        [self calculateSocAssmtScore];
    } else if ([rowDescriptor.tag isEqualToString:kConfide]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kConfide andNewContent:[self getNumberFromAgreeOptions:newValue]];
        [self calculateSocAssmtScore];
    } else if ([rowDescriptor.tag isEqualToString:kDownDiscouraged]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kDownDiscouraged andNewContent:[self getNumberFromAgreeOptions:newValue]];
        [self calculateSocAssmtScore];
    } else if ([rowDescriptor.tag isEqualToString:kSocialAssmtScore]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_ASSMT andFieldName:kSocialAssmtScore andNewContent:newValue];
    }
    
    /* Loneliness */
    else if ([rowDescriptor.tag isEqualToString:kLackCompanionship]) {
        [self postSingleFieldWithSection:SECTION_LONELINESS andFieldName:kLackCompanionship andNewContent:[newValue substringWithRange:NSMakeRange(0, 1)]];
    } else if ([rowDescriptor.tag isEqualToString:kLeftOut]) {
        [self postSingleFieldWithSection:SECTION_LONELINESS andFieldName:kLeftOut andNewContent:[newValue substringWithRange:NSMakeRange(0, 1)]];
    } else if ([rowDescriptor.tag isEqualToString:kIsolated]) {
        [self postSingleFieldWithSection:SECTION_LONELINESS andFieldName:kIsolated andNewContent:[newValue substringWithRange:NSMakeRange(0, 1)]];
    }
    
    /* Depression Assessment (Basic) */
    else if ([rowDescriptor.tag isEqualToString:kPhqQ1]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhqQ1 andNewContent:[self getNumberFromPhqOption:newValue]];
        [self calculatePhqScore];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ2]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhqQ2 andNewContent:[self getNumberFromPhqOption:newValue]];
        [self calculatePhqScore];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ2Score]) {
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhqQ2Score andNewContent:newValue];
        });
    }

    /* Suicide Risk Assessment (Basic) */
    else if ([rowDescriptor.tag isEqualToString:kPossibleSuicide]) {
        [self postSingleFieldWithSection:SECTION_SUICIDE_RISK andFieldName:kPossibleSuicide andNewContent:ansFromYesNo];
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
    
    /* Other Med Conds */
    if ([rowDescriptor.tag isEqualToString:kTakingMeds]) {
        [self postSingleFieldWithSection:SECTION_MEDICAL_HISTORY andFieldName:kTakingMeds andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kMedConds]) {
        [self postSingleFieldWithSection:SECTION_MEDICAL_HISTORY andFieldName:kMedConds andNewContent:rowDescriptor.value];
    }
    
    /* Surgery */
    else if ([rowDescriptor.tag isEqualToString:kHadSurgery]) {
        [self postSingleFieldWithSection:SECTION_SURGERY andFieldName:kHadSurgery andNewContent:rowDescriptor.value];
    }
    
    /* Healthcare Barriers */
    else if ([rowDescriptor.tag isEqualToString:kHCBRemarks]) {
        [self postSingleFieldWithSection:SECTION_HEALTHCARE_BARRIERS andFieldName:kHCBRemarks andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kOtherBarrier]) {
        [self postSingleFieldWithSection:SECTION_HEALTHCARE_BARRIERS andFieldName:kOtherBarrier andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAeFreq]) {
        [self postSingleFieldWithSection:SECTION_HEALTHCARE_BARRIERS andFieldName:kAeFreq andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kHospitalizedFreq]) {
        [self postSingleFieldWithSection:SECTION_HEALTHCARE_BARRIERS andFieldName:kHospitalizedFreq andNewContent:rowDescriptor.value];
    }
    
    /* Finance History */
    else if ([rowDescriptor.tag isEqualToString:kOccupation]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kOccupation andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kEmployReasons]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kEmployReasons andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kEmployOthers]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kEmployOthers andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAvgMthHouseIncome]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kAvgMthHouseIncome andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNumPplInHouse]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kNumPplInHouse andNewContent:rowDescriptor.value];
    }
    
    /* Social History */
    else if ([rowDescriptor.tag isEqualToString:kNumChildren]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_HISTORY andFieldName:kNumChildren andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAddressDuration]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_HISTORY andFieldName:kAddressDuration andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCaregiverName]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_HISTORY andFieldName:kCaregiverName andNewContent:rowDescriptor.value];
    }
    
    /* Suicide Risk Assessment (Basic) */
    else if ([rowDescriptor.tag isEqualToString:kProblemApproach]) {
        [self postSingleFieldWithSection:SECTION_SUICIDE_RISK andFieldName:kProblemApproach andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kLivingLife]) {
        [self postSingleFieldWithSection:SECTION_SUICIDE_RISK andFieldName:kLivingLife andNewContent:rowDescriptor.value];
    }
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
        
    };

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
        
        switch ([self.formID intValue]) {
            case Profiling: fieldName = kCheckProfiling;
                break;
                
                /** 3a. Medical History */
            case Diabetes: fieldName = kCheckDiabetes;
                break;
            case Hyperlipidemia: fieldName = kCheckHyperlipidemia;
                break;
            case Hypertension: fieldName = kCheckHypertension;
                break;
            case Others: fieldName = kCheckMedicalHistory;
                break;
            case Surgery: fieldName = kCheckSurgery;
                break;
            case BarriersToHealthcare: fieldName = kCheckHealthcareBarriers;
                break;
            case FamilyHistory: fieldName = kCheckFamHist;
                break;
            case RiskStratification: fieldName = kCheckRiskStratification;
                break;
                /** 3b. Diet & Exercise History */
            case Diet: fieldName = kCheckDiet;
                break;
            case Exercise: fieldName = kCheckExercise;
                break;
            case FitTest: fieldName = kCheckFitEligible;
                break;
            case Mammogram: fieldName = kCheckMammogramEligible;
                break;
            case PapSmear: fieldName = kCheckPapSmearEligible;
                break;
            case Eq5d: fieldName = kCheckEq5d;
                break;
            case FallRiskEligible: fieldName = kCheckFallRiskEligible;
                break;
            case DementiaEligible: fieldName = kCheckGeriatricDementiaEligible;
                break;
            case FinanceHistory: fieldName = kCheckProfilingSocioecon;
                break;
            case FinanceAssmtBasic: fieldName = kCheckFinAssmt;
                break;
            case CHAS_Eligibility: fieldName = kCheckChasPrelim;
                break;
            case SocialHistory: fieldName = kCheckSocialHistory;
                break;
            case SocialAssessment: fieldName = kCheckSocialAssmt;
                break;
            case Loneliness: fieldName = kCheckLoneliness;
                break;
            case DepressionAssmt: fieldName = kCheckLoneliness;
                break;
            case SuicideRisk: fieldName = kCheckSuicideRisk;
                break;
                
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
        
        switch ([self.formID intValue]) {
            case Profiling: fieldName = kCheckProfiling;
                break;
                
                /** 3a. Medical History */
            case Diabetes: fieldName = kCheckDiabetes;
                break;
            case Hyperlipidemia: fieldName = kCheckHyperlipidemia;
                break;
            case Hypertension: fieldName = kCheckHypertension;
                break;
            case Others: fieldName = kCheckMedicalHistory;
                break;
            case Surgery: fieldName = kCheckSurgery;
                break;
            case BarriersToHealthcare: fieldName = kCheckHealthcareBarriers;
                break;
            case FamilyHistory: fieldName = kCheckFamHist;
                break;
            case RiskStratification: fieldName = kCheckRiskStratification;
                break;
                
                /** 3b. Diet & Exercise History */
            case Diet: fieldName = kCheckDiet;
                break;
            case Exercise: fieldName = kCheckExercise;
                break;
                
            case FitTest: fieldName = kCheckFitEligible;
                break;
            case Mammogram: fieldName = kCheckMammogramEligible;
                break;
            case PapSmear: fieldName = kCheckPapSmearEligible;
                break;
            case Eq5d: fieldName = kCheckEq5d;
                break;
            case FallRiskEligible: fieldName = kCheckFallRiskEligible;
                break;
            case DementiaEligible: fieldName = kCheckGeriatricDementiaEligible;
                break;
            case FinanceHistory: fieldName = kCheckProfilingSocioecon;
                break;
            case FinanceAssmtBasic: fieldName = kCheckFinAssmt;
                break;
            case CHAS_Eligibility: fieldName = kCheckChasPrelim;
                break;
            case SocialHistory: fieldName = kCheckSocialHistory;
                break;
            case SocialAssessment: fieldName = kCheckSocialAssmt;
                break;
            case Loneliness: fieldName = kCheckLoneliness;
                break;
            case DepressionAssmt: fieldName = kCheckDepression;
                break;
            case SuicideRisk: fieldName = kCheckSuicideRisk;
                break;
                
                
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

#pragma mark - Other methods

- (NSString *) getYesNoFromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"])
            return @"Yes";
        else if ([value isEqualToString:@"0"])
            return @"No";
        
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1])
            return @"Yes";
        else if ([value isEqual:@0])
            return @"No";
        
    }
    return @"";
}

- (NSString *) getTrueFalseFromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"])
            return @"True";
        else if ([value isEqualToString:@"0"])
            return @"False";
        
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1])
            return @"True";
        else if ([value isEqual:@0])
            return @"False";
        
    }
    return @"";
}

- (NSString *) checkFreqGoingDocConsult {
    
    NSDictionary *diabetesDict = _fullScreeningForm[SECTION_DIABETES];
    NSDictionary *tensionDict = _fullScreeningForm[SECTION_HYPERTENSION];
    NSDictionary *lipidDict = _fullScreeningForm[SECTION_HYPERLIPIDEMIA];
    
    NSArray *textArray = @[@"Regular", @"Occasionally", @"Seldom", @"Not at all"];
    NSString *freq;
    
    for (int i=0; i<4; i++) {       //check one section after another, from "Regular" all the way till "Not at all"
        
        if (diabetesDict != (id)[NSNull null] && diabetesDict != nil) {
            freq = diabetesDict[kSeeingDocRegularly];
            if ([freq isKindOfClass:[NSString class]]) {
                if ([freq containsString:textArray[i]]) {
                    if (i < 2) return @"going";
                    else if (i < 4) return @"not";
                    else return @"";
                }
            }
        }
        if (tensionDict != (id)[NSNull null] && tensionDict != nil) {
            freq = tensionDict[kSeeingDocRegularly];
            if ([freq isKindOfClass:[NSString class]]) {
                if ([freq containsString:textArray[i]]) {
                    if (i < 2) return @"going";
                    else if (i < 4) return @"not";
                    else return @"";
                }
            }
        }
        
        if (lipidDict != (id)[NSNull null] && lipidDict != nil) {
            freq = lipidDict[kSeeingDocRegularly];
            if ([freq isKindOfClass:[NSString class]]) {
                if ([freq containsString:textArray[i]]) {
                    if (i < 2) return @"going";
                    else if (i < 4) return @"not";
                    else return @"";
                }
            }
        }


    }
    return @"";
}

- (void) postDoctorSeeWithOptionName:(NSString *) option andValue: (NSString *) value {
    NSString *fieldName;
    
    if ([option containsString:@"General"]) fieldName = kGpFamDoc;
    else if ([option containsString:@"Family"]) fieldName = kFamMed;
    else if ([option containsString:@"Polyclinic"]) fieldName = kPolyclinic;
    else if ([option containsString:@"Outpatient"]) fieldName = kSocHospital;
    
    [self postSingleFieldWithSection:SECTION_HEALTHCARE_BARRIERS andFieldName:fieldName andNewContent:value];
}

- (NSArray *) getDoctorSeeArray: (NSDictionary *) dictionary {
    if (dictionary == (id)[NSNull null] || dictionary == nil) {
        return @[]; //return empty array;
    }
    
    NSMutableArray *doctorSeeArray = [[NSMutableArray alloc] init];
    
    if([[dictionary objectForKey:kGpFamDoc] isEqual:@(1)]) [doctorSeeArray addObject:@"General Practioner / Family Doctor"];
    if([[dictionary objectForKey:kFamMed] isEqual:@(1)]) [doctorSeeArray addObject:@"Family Medicine Clinic"];
    if([[dictionary objectForKey:kPolyclinic] isEqual:@(1)]) [doctorSeeArray addObject:@"Polyclinic"];
    if([[dictionary objectForKey:kSocHospital] isEqual:@(1)]) [doctorSeeArray addObject:@"Specialist Outpatient Clinic (Hospital)"];
    
    return doctorSeeArray;
}

- (void) postWhyNotFollowUpWithOptionName:(NSString *) option andValue: (NSString *) value {
    NSString *fieldName;
    
    if ([option containsString:@"tests"]) fieldName = kNotSeeNeed;
    else if ([option containsString:@"Challenging"]) fieldName = kCantMakeTime;
    else if ([option containsString:@"Difficulty"]) fieldName = kHCBMobility;
    else if ([option containsString:@"Financial"]) fieldName = kHCBFinancial;
    else if ([option containsString:@"Scared"]) fieldName = kScaredOfDoc;
    else if ([option containsString:@"Prefer"]) fieldName = kPreferTraditional;
    else if ([option containsString:@"Others"]) fieldName = kHCBOthers;
    
    [self postSingleFieldWithSection:SECTION_HEALTHCARE_BARRIERS andFieldName:fieldName andNewContent:value];
}

- (NSArray *) getWhyNotFollowUpArray: (NSDictionary *) dictionary {
    if (dictionary == (id)[NSNull null] || dictionary == nil) {
        return @[]; //return empty array;
    }
    
    NSMutableArray *whyNotFollowUpArray = [[NSMutableArray alloc] init];
    
    if([[dictionary objectForKey:kNotSeeNeed] isEqual:@(1)]) [whyNotFollowUpArray addObject:@"Do not see the need for the tests"];
    if([[dictionary objectForKey:kCantMakeTime] isEqual:@(1)]) [whyNotFollowUpArray addObject:@"Challenging to make time to go for appointments"];
    if([[dictionary objectForKey:kHCBMobility] isEqual:@(1)]) [whyNotFollowUpArray addObject:@"Difficulty getting to clinic (mobility)"];
    if([[dictionary objectForKey:kHCBFinancial] isEqual:@(1)]) [whyNotFollowUpArray addObject:@"Financial issues"];
    if([[dictionary objectForKey:kScaredOfDoc] isEqual:@(1)]) [whyNotFollowUpArray addObject:@"Scared of doctor"];
    if([[dictionary objectForKey:kPreferTraditional] isEqual:@(1)]) [whyNotFollowUpArray addObject:@"Prefer traditional medicine"];
    if([[dictionary objectForKey:kHCBOthers] isEqual:@(1)]) [whyNotFollowUpArray addObject:@"Others"];
    
    return whyNotFollowUpArray;
}


- (void) postFamHistWithOptionName:(NSString *) option andValue: (NSString *) value {
    NSString *fieldName;

    if ([option containsString:@"pressure"]) fieldName = kFamHighBp;
    else if ([option containsString:@"cholesterol"]) fieldName = kFamHighCholes;
    else if ([option containsString:@"attack"]) fieldName = kFamChd;
    else if ([option containsString:@"Stroke"]) fieldName = kFamStroke;
    else if ([option containsString:@"above"]) fieldName = kFamNone;
    
    [self postSingleFieldWithSection:SECTION_FAM_HIST andFieldName:fieldName andNewContent:value];
}

- (NSArray *) getFamHistArray: (NSDictionary *) dictionary {
    if (dictionary == (id)[NSNull null] || dictionary == nil) {
        return @[]; //return empty array;
    }
    
    NSMutableArray *famHistArray = [[NSMutableArray alloc] init];
    
    if([[dictionary objectForKey:kFamHighBp] isEqual:@(1)]) [famHistArray addObject:@"High blood pressure"];
    if([[dictionary objectForKey:kFamHighCholes] isEqual:@(1)]) [famHistArray addObject:@"High blood cholesterol"];
    if([[dictionary objectForKey:kFamChd] isEqual:@(1)]) [famHistArray addObject:@"Heart attack or coronary heart disease (narrowed blood vessels supplying heart muscle)"];
    if([[dictionary objectForKey:kFamStroke] isEqual:@(1)]) [famHistArray addObject:@"Stroke"];
    if([[dictionary objectForKey:kFamNone] isEqual:@(1)]) [famHistArray addObject:@"No, they do not have any of the above"];
    
    return famHistArray;
}

- (void) postWhyNoExercise:(NSString *) option andValue: (NSString *) value {
    NSString *fieldName;
    
    if ([option containsString:@"time"]) fieldName = kNoTime;
    else if ([option containsString:@"tired"]) fieldName = kTooTired;
    else if ([option containsString:@"lazy"]) fieldName = kTooLazy;
    else if ([option containsString:@"interest"]) fieldName = kNoInterest;
    
    [self postSingleFieldWithSection:SECTION_EXERCISE andFieldName:fieldName andNewContent:value];
}

- (NSArray *) getWhyNotExerciseArray: (NSDictionary *) dictionary {
    if (dictionary == (id)[NSNull null] || dictionary == nil) {
        return @[]; //return empty array;
    }
    
    NSMutableArray *whyNotExerciseArray = [[NSMutableArray alloc] init];
    
    if([[dictionary objectForKey:kNoTime] isEqual:@(1)]) [whyNotExerciseArray addObject:@"No time (family/work/commitments)"];
    if([[dictionary objectForKey:kTooTired] isEqual:@(1)]) [whyNotExerciseArray addObject:@"Too tired"];
    if([[dictionary objectForKey:kTooLazy] isEqual:@(1)]) [whyNotExerciseArray addObject:@"Too lazy"];
    if([[dictionary objectForKey:kNoInterest] isEqual:@(1)]) [whyNotExerciseArray addObject:@"No interest"];
    
    return whyNotExerciseArray;
}

- (int) calculateTotalFallRiskScore {
    
    int totalScore = 0;
    
    for (XLFormRowDescriptor *row in _fallRiskQuestionsArray) {
        if (row.value != nil && row.value !=(id)[NSNull null]) {
            
            if ([row.value isKindOfClass:[NSNumber class]]) {
                row.value = [NSString stringWithFormat:@"%@", row.value];
            }
            if ([row.tag isEqualToString:kNumFalls]) {
                if ([row.value containsString:@"0"]) totalScore = totalScore;
                else if ([row.value containsString:@"1"]) totalScore += 1;
                else if ([row.value containsString:@"2"]) totalScore += 2;
                else if ([row.value containsString:@"3"]) totalScore += 3;
            } else if ([row.tag isEqualToString:kAssistLevel]) {
                if ([row.value containsString:@"None"]) totalScore = totalScore;
                else if ([row.value containsString:@"Supervision"]) totalScore += 1;
                else if ([row.value containsString:@"assistance"]) totalScore += 2;
                else if ([row.value containsString:@"dependent"]) totalScore += 3;
            } else if ([row.tag isEqualToString:kSteadiness]) {
                if ([row.value containsString:@"unsteadiness"]) totalScore = totalScore;
                else if ([row.value containsString:@"minimally"]) totalScore += 1;
                else if ([row.value containsString:@"moderately"]) totalScore += 2;
                else if ([row.value containsString:@"severely"]) totalScore += 3;
            }
        }
    }
    
    /* Return the Score and determine the Risk */
    if (totalScore >= 4) {
        fallRiskStatusRow.value = @"High Risk";
        [self reloadFormRow:fallRiskStatusRow];
        return totalScore;
    } else if (totalScore >= 0 && totalScore <= 3) {
        XLFormRowDescriptor *assistLevelRow = [_fallRiskQuestionsArray objectAtIndex:1];
        XLFormRowDescriptor *steadinessRow = [_fallRiskQuestionsArray objectAtIndex:2];
        if (assistLevelRow.value) {
            if (![assistLevelRow.value containsString:@"None"]) { // Q1 >= 1
                fallRiskStatusRow.value = @"High Risk";
                [self reloadFormRow:fallRiskStatusRow];
                return totalScore;
                
            }
        }
        
        if (steadinessRow.value) {
            if (![steadinessRow.value containsString:@"unsteadiness"]) { // Q2 >= 1
                fallRiskStatusRow.value = @"High Risk";
                [self reloadFormRow:fallRiskStatusRow];
                return totalScore;
            }
            
        }
    
    }
    
    fallRiskStatusRow.value = @"Low Risk";
    [self reloadFormRow:fallRiskStatusRow];
    return totalScore;
}

- (NSString *) getFallRiskValueWithRow: (XLFormRowDescriptor *) row
                              andValue: (NSNumber *) value {
    if ([row.tag isEqualToString:kNumFalls]) {
        if ([value isEqualToNumber:@0]) return @"0";
        else if ([value isEqualToNumber:@1]) return @"1";
        else if ([value isEqualToNumber:@2]) return @"2";
        else if ([value isEqualToNumber:@3]) return @"3";
    } else if ([row.tag isEqualToString:kAssistLevel]) {
        if ([value isEqualToNumber:@0]) return @"None (completely independent)";
        else if ([value isEqualToNumber:@1]) return @"Supervision";
        else if ([value isEqualToNumber:@2]) return  @"Some assistance required";
        else if ([value isEqualToNumber:@3]) return @"Completely dependent";
    } else if ([row.tag isEqualToString:kSteadiness]) {
        if ([value isEqualToNumber:@0]) return @"No unsteadiness observed";
        else if ([value isEqualToNumber:@1]) return @"Yes, minimally unsteady";
        else if ([value isEqualToNumber:@2]) return  @"Yes, moderately unsteady (needs supervision)";
        else if ([value isEqualToNumber:@3]) return @"Yes, consistently and severely unsteady";
    }
    
    return @"";
}


- (void) postMultiCardsWithOptionName:(NSString *) option andValue: (NSString *) value {
    NSString *fieldName;
    
    if ([option containsString:@"Blue"]) fieldName = kBlueChas;
    else if ([option containsString:@"Orange"]) fieldName = kOrangeChas;
    else if ([option containsString:@"Pioneer"]) fieldName = kPgCard;
    else if ([option containsString:@"Public"]) fieldName = kPaCard;
    else if ([option containsString:@"None"]) fieldName = kOwnsNoCard;
    
    [self postSingleFieldWithSection:SECTION_CHAS_PRELIM andFieldName:fieldName andNewContent:value];
}

- (NSArray *) getMultiCardsArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kBlueChas, kOrangeChas, kPgCard, kPaCard, kOwnsNoCard];
    NSArray *textArray = @[@"Blue CHAS card", @"Orange CHAS card", @"Pioneer Generation (PG) card", @"Public Assistance (PA) card", @"None of the above"];
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[keyArray count]; i++) {
        NSString *key = keyArray[i];
        if (dict[key] != (id)[NSNull null]) {
            if ([dict[key] isEqual:@1])
                [returnArray addObject:textArray[i]];
        }
    }
    
    return returnArray;
}



#pragma mark - Methods for Social Assessment
- (NSString *) getNumberFromAgreeOptions: (NSString *) options {
    if ([options isEqualToString:@"Strongly Disagree"]) return @"1";
    else if ([options isEqualToString:@"Disagree"]) return @"2";
    else if ([options isEqualToString:@"Agree"]) return @"3";
    else return @"4";
}

- (NSString *) getAgreeOptionsFromNumber: (NSNumber *) options {
    if ([options isEqualToNumber:@1]) return @"Strongly Disagree";
    else if ([options isEqualToNumber:@2]) return @"Disagree";
    else if ([options isEqualToNumber:@3]) return @"Agree";
    else return @"Strongly Agree";
}

- (NSString *) getEq5dOptionsFromNumber: (NSString *) options {
    if ([options isEqualToString:@"0"]) return @"0 No problem";
    else if ([options isEqualToString:@"1"]) return @"1 Slight problem";
    else if ([options isEqualToString:@"2"]) return @"2 Moderate problem";
    else if ([options isEqualToString:@"3"]) return @"3 Severe problem";
    else if ([options isEqualToString:@"4"]) return @"4 Completed unable to do so";
    else return @"0 No problem";
}

- (NSString *) getLonelinessOptionsFromNumber: (NSNumber *) options {
    if ([options isEqualToNumber:@0]) return @"0 Hardly ever";
    else if ([options isEqualToNumber:@1]) return @"1 Sometimes";
    else if ([options isEqualToNumber:@2]) return @"2 Often";
    else return @"0 Hardly ever";
}

- (void) calculateSocAssmtScore {
    NSDictionary *fields = [self.form formValues];
    NSArray *arrayOfVarName = @[kUnderstands,kCloseCare,kConfide,kOpinionConfidence,kDownDiscouraged,kFeelGood,kSpiritsUp,kTrust];
    int totalScore = 0;
    for (NSString *str in arrayOfVarName) {
        if ([fields objectForKey:str] != nil && [fields objectForKey:str] != (id)[NSNull null]) {
            totalScore += [[self getNumberFromAgreeOptions:[fields objectForKey:str]] intValue];
        }
    }
    
    socialAssmtScoreRow.value = [NSNumber numberWithInt:totalScore];
    [self reloadFormRow:socialAssmtScoreRow];
}

#pragma mark - Methods for Depression Assessment
- (NSString *) getSelectorOptionFromNumber: (NSNumber *) number {
    if ([number isEqualToNumber:@0]) return @"Not at all [0]";
    else if ([number isEqualToNumber:@1]) return @"Several days [1]";
    else if ([number isEqualToNumber:@2]) return @"More than half the days [2]";
    else return @"Nearly every day [3]";
}

- (NSString *) getNumberFromPhqOption: (NSString *) str {
    if ([str containsString:@"0"]) return @"0";
    else if ([str containsString:@"1"]) return @"1";
    else if ([str containsString:@"2"]) return @"2";
    else return @"3";
}

- (void) calculatePhqScore {
    NSDictionary *fields = [self.form formValues];
    NSArray *arrayOfVarName = @[kPhqQ1,kPhqQ2];
    int totalScore = 0;
    for (NSString *str in arrayOfVarName) {
        if ([fields objectForKey:str] != nil && [fields objectForKey:str] != (id)[NSNull null]) {
            totalScore += [[self getNumberFromPhqOption:[fields objectForKey:str]] intValue];
        }
    }
    
    phqScoreRow.value = [NSNumber numberWithInt:totalScore];
    [self reloadFormRow:phqScoreRow];
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


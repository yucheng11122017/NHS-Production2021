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
    RiskStratification
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
}

@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSNumber *residentID;

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
        case 0:
            form = [self initProfiling];
            break;
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
            form = [self initRiskStratification];
            break;
        default:
            break;
    }
    [self.form setAddAsteriskToRequiredRowsTitle:NO];
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
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckProfiling];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kProfilingConsent rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Consent to disclosure of information"];
    if (profilingDict != (id)[NSNull null] && [profilingDict objectForKey:kProfilingConsent] != (id)[NSNull null]) row.value = [self getYesNofromOneZero:profilingDict[kProfilingConsent]];
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
    if (profilingDict != (id)[NSNull null] && profilingDict[kEmployReasons] != (id)[NSNull null]) unemployReasonsRow.value = profilingDict[kEmployReasons];
    [self setDefaultFontWithRow:unemployReasonsRow];
    unemployReasonsRow.required = NO;
    unemployReasonsRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Unemployed'", employmentRow];
    [unemployReasonsRow.cellConfigAtConfigure setObject:@"Reasons for unemployment" forKey:@"textView.placeholder"];
    
    [section addFormRow:unemployReasonsRow];
    
    XLFormRowDescriptor *otherEmployRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployOthers rowType:XLFormRowDescriptorTypeText title:@"Other employment"];
    if (profilingDict != (id)[NSNull null]) otherEmployRow.value = profilingDict[kEmployOthers];
    [self setDefaultFontWithRow:otherEmployRow];
    otherEmployRow.required = NO;
    otherEmployRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", employmentRow];
    [otherEmployRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:otherEmployRow];
    
    XLFormRowDescriptor *noDiscloseIncomeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiscloseIncome rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Resident does not want to disclose income"];
    if (profilingDict != (id)[NSNull null] && [profilingDict objectForKey:kDiscloseIncome] != (id)[NSNull null]) noDiscloseIncomeRow.value = profilingDict[kDiscloseIncome];
    [self setDefaultFontWithRow:noDiscloseIncomeRow];
    //    noDiscloseIncomeRow.selectorOptions = @[@"Yes", @"No"];
    noDiscloseIncomeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noDiscloseIncomeRow.required = NO;
    [section addFormRow:noDiscloseIncomeRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *mthHouseIncome = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgMthHouseIncome rowType:XLFormRowDescriptorTypeDecimal title:@"Average monthly household income"];
    //value
    if (profilingDict != (id)[NSNull null] && profilingDict[kAvgMthHouseIncome] != (id)[NSNull null])
        mthHouseIncome.value = profilingDict[kAvgMthHouseIncome];
    
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
    if (profilingDict != (id)[NSNull null] && profilingDict[kNumPplInHouse] != (id) [NSNull null])
        noOfPplInHouse.value = profilingDict[kNumPplInHouse];
    
    [self setDefaultFontWithRow:noOfPplInHouse];
    [noOfPplInHouse.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    noOfPplInHouse.cellConfig[@"textLabel.numberOfLines"] = @0;
    [noOfPplInHouse addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be greater than 0" regex:@"^[1-9][0-9]*$"]];
    noOfPplInHouse.required = NO;
    [section addFormRow:noOfPplInHouse];
    
    XLFormRowDescriptor *avgIncomePerHead = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgIncomePerHead rowType:XLFormRowDescriptorTypeDecimal title:@"Average income per head"];   //auto-calculate
    
    //value
    if (profilingDict != (id)[NSNull null] && profilingDict[avgIncomePerHead] != (id) [NSNull null])
        avgIncomePerHead.value = profilingDict[avgIncomePerHead];
    
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
            if (mthHouseIncome.value == (id)[NSNull null] || noOfPplInHouse.value == (id)[NSNull null])
                return; //don't bother continuing
            if ([mthHouseIncome.value integerValue] != 0 && [noOfPplInHouse.value integerValue] != 0) {
                avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", ([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])];
                [self updateFormRow:avgIncomePerHead];
            }
        }
    };
    noOfPplInHouse.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if (mthHouseIncome.value == (id)[NSNull null] || noOfPplInHouse.value == (id)[NSNull null])
                return; //don't bother continuing
            if ([mthHouseIncome.value integerValue] != 0 && [noOfPplInHouse.value integerValue] != 0) {
                avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", ([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])];
                [self updateFormRow:avgIncomePerHead];
            }
        }
    };
    
    // CHAS Preliminary Eligibiliy Assessment - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"CHAS Preliminary Eligibility Assessment"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *sporeanRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSporean rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean"];
    [self setDefaultFontWithRow:sporeanRow];
    sporeanRow.required = NO;
    sporeanRow.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"]) {
        sporeanRow.value = @1;
        sporean = YES;
    }
    else {
        sporeanRow.value = @0;
        sporean = NO;
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kQualifyCHAS];
    }
    [section addFormRow:sporeanRow];
    
    
    XLFormRowDescriptor *chasNoChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDoesntOwnChasPioneer rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does not currently own a CHAS card (blue/orange) OR \nCurrently owns a CHAS card which expires in ≤ 3 months"];
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
            if (sporean && noChas && lowIncome && wantChas) {
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
            if (sporean && noChas && lowIncome && wantChas) {
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
            if (sporean && noChas && lowIncome && wantChas) {
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
    if (colonscoEligibDict != (id)[NSNull null] && [colonscoEligibDict objectForKey:kRelWColorectCancer] != (id)[NSNull null]) {
        relColCancerRow.value = colonscoEligibDict[kRelWColorectCancer];
        relColorectCancer = [relColCancerRow.value boolValue];
    }
    
    [self setDefaultFontWithRow:relColCancerRow];
    relColCancerRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    relColCancerRow.required = NO;
    [section addFormRow:relColCancerRow];
    
    
    XLFormRowDescriptor *colon3yrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kColonoscopy3yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done colonoscopy in the past 3 years?"];
    
    //value
    if (colonscoEligibDict != (id)[NSNull null] && [colonscoEligibDict objectForKey:kColonoscopy3yrs] != (id)[NSNull null]) {
        colon3yrsRow.value = colonscoEligibDict[kColonoscopy3yrs];
        colon3Yrs = [colon3yrsRow.value boolValue];
    }
    [self setDefaultFontWithRow:colon3yrsRow];
    colon3yrsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    colon3yrsRow.required = NO;
    [section addFormRow:colon3yrsRow];
    
    XLFormRowDescriptor *wantColonRefRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantColonoscopyRef rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a referral for free colonoscopy?"];
    if (colonscoEligibDict != (id)[NSNull null] && [colonscoEligibDict objectForKey:kWantColonoscopyRef] != (id)[NSNull null]) {
        wantColonRefRow.value = colonscoEligibDict[kWantColonoscopyRef];
        wantColRef = [wantColonRefRow.value boolValue];
    }
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
    
    // for the initial setting
    if (sporeanPr && age50 && relColorectCancer && colon3Yrs && wantColRef) {
        disableFIT = true;
        fitLast12MthsRow.disabled = [NSNumber numberWithBool:disableFIT];
        colonoscopy10YrsRow.disabled = [NSNumber numberWithBool:disableFIT];
        wantFitKitRow.disabled = [NSNumber numberWithBool:disableFIT];
    }
    
    
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
        age2569 = YES;
        row.value = @1;
    }
    else {
        age2569 = NO;
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
            if (sporeanPr && age2569 && noPapSmear3Yrs && hadSex && wantPapSmear) {
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
            if (sporeanPr && age2569 && noPapSmear3Yrs && hadSex && wantPapSmear) {
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
            if (sporeanPr && age2569 && noPapSmear3Yrs && hadSex && wantPapSmear) {
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ1
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Has a western-trained doctor ever told you that you have diabetes? *"];
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
                                                                                       title:@"Have you checked your blood sugar in the past 3 years?"];
    [self setDefaultFontWithRow:hasCheckedBloodQRow];
    hasCheckedBloodQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasCheckedBloodQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformedRow];
    [section addFormRow:hasCheckedBloodQRow];
    
    XLFormRowDescriptor *hasCheckedBloodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMCheckedBlood rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    
    hasCheckedBloodRow.selectorOptions = @[@"No",@"Yes, 2 yrs ago",@"Yes, 3 yrs ago",@"Yes < 1 yr ago"];
    hasCheckedBloodRow.noValueDisplayText = @"Tap Here";
    hasCheckedBloodRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformedRow];
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kCheckedBlood] != (id)[NSNull null]) {
        hasCheckedBloodRow.value = diabetesDict[kCheckedBlood];
    }
    [section addFormRow:hasCheckedBloodRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you seeing your doctor regularly for your diabetes?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    XLFormRowDescriptor *seeDocRegularRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    seeDocRegularRow.selectorOptions = @[@"YES", @"NO"];
    
    ;
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        seeDocRegularRow.value = [self getYesNoFromOneZero:diabetesDict[kSeeingDocRegularly]];
    }
    seeDocRegularRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:seeDocRegularRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you currently prescribed medication for your diabetes?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    XLFormRowDescriptor *currentPrescrRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    currentPrescrRow.selectorOptions = @[@"YES", @"NO"];
    
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kCurrentlyPrescribed] != (id)[NSNull null]) {
        currentPrescrRow.value = [self getYesNoFromOneZero:diabetesDict[kCurrentlyPrescribed]];
    }
    
    currentPrescrRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:currentPrescrRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ5
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you taking your diabetes medication regularly? (≥ 90% of time)"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    // Segmented Control
    XLFormRowDescriptor *takingRegularRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDMTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    takingRegularRow.selectorOptions = @[@"YES", @"NO"];
    
    
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kTakingRegularly] != (id)[NSNull null]) {
        takingRegularRow.value = [self getYesNoFromOneZero:diabetesDict[kTakingRegularly]];
    }
    takingRegularRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:takingRegularRow];
    
    // For initial value
    if (diabetesDict != (id)[NSNull null] && [diabetesDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        if ([diabetesDict[kHasInformed] isEqualToNumber:@1]) {
            seeDocRegularRow.required = YES;
            currentPrescrRow.required = YES;
            takingRegularRow.required = YES;
        } else {
            hasCheckedBloodRow.required = YES;
        }
    }
    
    //For detecting change
    hasInformedRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"YES"]) {
                seeDocRegularRow.required = YES;
                currentPrescrRow.required = YES;
                takingRegularRow.required = YES;
            } else {
                hasCheckedBloodRow.required = YES;
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
    
    XLFormRowDescriptor *lipidCheckBloodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCheckedBlood
                                                                                    rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                                                      title:@""];
    lipidCheckBloodRow.selectorOptions = @[@"No",
                                           @"Yes, 2 yrs ago",
                                           @"Yes, 3 yrs ago",
                                           @"Yes < 1 yr ago"];
    
    lipidCheckBloodRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed];
    lipidCheckBloodRow.noValueDisplayText = @"Tap Here";
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kCheckedBlood] != (id)[NSNull null]) {
        lipidCheckBloodRow.value = hyperlipidDict[kCheckedBlood];
    }
    
    [section addFormRow:lipidCheckBloodRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ8
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you seeing your doctor regularly? (regular = every 6 mths or less, or as per doctor scheduled to follow up)"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    XLFormRowDescriptor *seeDocRegularRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    seeDocRegularRow.selectorOptions = @[@"YES", @"NO"];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        seeDocRegularRow.value = [self getYesNoFromOneZero:hyperlipidDict[kSeeingDocRegularly]];
    }
    
    seeDocRegularRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:seeDocRegularRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQ9
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you currently prescribed medication for your high cholesterol?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    XLFormRowDescriptor *prescribedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    prescribedRow.selectorOptions = @[@"YES", @"NO"];
    prescribedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kCurrentlyPrescribed] != (id)[NSNull null]) {
        prescribedRow.value = [self getYesNoFromOneZero:hyperlipidDict[kCurrentlyPrescribed]];
    }
    
    [section addFormRow:prescribedRow];
    
    XLFormRowDescriptor *takeRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ10
                                                                                   rowType:XLFormRowDescriptorTypeInfo
                                                                                     title:@"Are you taking your cholesterol medication regularly?"];
    [self setDefaultFontWithRow:takeRegularlyQRow];
    takeRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    takeRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribedRow];
    [section addFormRow:takeRegularlyQRow];
    
    // Segmented Control
    XLFormRowDescriptor *takeRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:row];
    takeRegularlyRow.selectorOptions = @[@"YES", @"NO"];
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kTakingRegularly] != (id)[NSNull null]) {
        takeRegularlyRow.value = [self getYesNoFromOneZero:hyperlipidDict[kTakingRegularly]];
    }
    
    takeRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribedRow];
    
    [section addFormRow:takeRegularlyRow];
    
    
    hasInformed.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqualToString:@"NO"]) {
                seeDocRegularRow.required = NO;
                prescribedRow.required = NO;
                lipidCheckBloodRow.required = YES;
                
                takeRegularlyQRow.hidden = @(1);
                takeRegularlyRow.hidden = @(1);
                takeRegularlyRow.required = NO;
            } else {
                seeDocRegularRow.required = YES;
                prescribedRow.required = YES;
                lipidCheckBloodRow.required = NO;
                
                if ([prescribedRow.value isEqualToString:@"YES"]) {
                    takeRegularlyQRow.hidden = @(0);
                    takeRegularlyRow.hidden = @(0);
                    takeRegularlyRow.required = YES;
                }
            }
        }
    };
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        if ([hasInformed.value isEqualToString:@"YES"]) {
            seeDocRegularRow.required = YES;
            prescribedRow.required = YES;
            lipidCheckBloodRow.required = NO;
        } else {
            seeDocRegularRow.required = NO;
            prescribedRow.required = NO;
            lipidCheckBloodRow.required = YES;
        }
    }
    
    prescribedRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqualToString:@"YES"]) {
                takeRegularlyQRow.hidden = @(0);
                takeRegularlyRow.hidden = @(0);
                takeRegularlyRow.required = YES;
            } else {
                takeRegularlyQRow.hidden = @(1);
                takeRegularlyRow.hidden = @(1);
                takeRegularlyRow.required = NO;
            }
        }
    };
    
    if (hyperlipidDict != (id)[NSNull null] && [hyperlipidDict objectForKey:kCurrentlyPrescribed] != (id)[NSNull null]) {
        if ([prescribedRow.value isEqualToString:@"YES"] && [hasInformed.value isEqualToString:@"YES"]) {
            takeRegularlyRow.required = YES;
        }
    }
    return [super initWithForm:formDescriptor];
}


-(id) initHypertension {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
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
    checkedBPQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed_HT];
    [section addFormRow:checkedBPQRow];
    
    XLFormRowDescriptor *checkedBP = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCheckedBp rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:checkedBP];
    checkedBP.selectorOptions = @[@"YES", @"NO"];
    checkedBP.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformed_HT];
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kCheckedBp] != (id)[NSNull null]) {
        checkedBP.value = [self getYesNoFromOneZero:hypertensionDict[kCheckedBp]];
    }
    [section addFormRow:checkedBP];
    
    
    XLFormRowDescriptor *seeDocRegularlyQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ3
                                                                                     rowType:XLFormRowDescriptorTypeInfo
                                                                                       title:@"Are you seeing your doctor regularly for your high BP?"];
    [self setDefaultFontWithRow:seeDocRegularlyQRow];
    seeDocRegularlyQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    seeDocRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed_HT];
    [section addFormRow:seeDocRegularlyQRow];
    XLFormRowDescriptor *seeDocRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    seeDocRegularlyRow.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kSeeingDocRegularly] != (id)[NSNull null]) {
        seeDocRegularlyRow.value = [self getYesNoFromOneZero:hypertensionDict[kSeeingDocRegularly]];
    }
    
    seeDocRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed_HT];
    [section addFormRow:seeDocRegularlyRow];
    
    
    XLFormRowDescriptor *prescribedQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ4
                                                                                rowType:XLFormRowDescriptorTypeInfo
                                                                                  title:@"Are you currently prescribed medication for your high BP?"];
    [self setDefaultFontWithRow:prescribedQRow];
    prescribedQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    prescribedQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed_HT];
    [section addFormRow:prescribedQRow];
    
    XLFormRowDescriptor *prescribedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:prescribedRow];
    prescribedRow.selectorOptions = @[@"YES", @"NO"];
    prescribedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed_HT];
    
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
    takeRegularlyQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed_HT];
    [section addFormRow:takeRegularlyQRow];
    
    // Segmented Control
    XLFormRowDescriptor *takeRegularlyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHTTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    [self setDefaultFontWithRow:takeRegularlyRow];
    takeRegularlyRow.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kHTTakingRegularly] != (id)[NSNull null]) {
        takeRegularlyRow.value = [self getYesNoFromOneZero:hypertensionDict[kTakingRegularly]];
    }
    
    takeRegularlyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed_HT];
    [section addFormRow:takeRegularlyRow];
    
    
    hasInformed_HT.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"YES"]) {
                seeDocRegularlyRow.required = YES;
                prescribedRow.required = YES;
                takeRegularlyRow.required = YES;
                checkedBP.required = NO;
            } else {
                seeDocRegularlyRow.required = NO;
                prescribedRow.required = NO;
                takeRegularlyRow.required = NO;
                checkedBP.required = YES;
            }
        }
    };
    
    if (hypertensionDict != (id)[NSNull null] && [hypertensionDict objectForKey:kHasInformed] != (id)[NSNull null]) {
        if ([hasInformed_HT.value isEqualToString:@"YES"]) {
            seeDocRegularlyRow.required = YES;
            prescribedRow.required = YES;
            takeRegularlyRow.required = YES;
            checkedBP.required = NO;
        } else {
            seeDocRegularlyRow.required = NO;
            prescribedRow.required = NO;
            takeRegularlyRow.required = NO;
            checkedBP.required = YES;
        }
    }
    
    //    checkedBP.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
    //        if (oldValue != newValue) {
    //            if ([newValue isEqualToString:@"NO"]) {
    //                takeRegularlyQRow.hidden = @(1);
    //                takeRegularlyRow.hidden = @(1);
    //            } else {
    ////                if ([prescribedRow.value isEqualToString:@"YES"]) {
    //                    takeRegularlyQRow.hidden = @(0);
    //                    takeRegularlyRow.hidden = @(0);
    ////                }
    //            }
    //        }
    //    };
    
    
    return [super initWithForm:formDescriptor];
}

-(id) initRiskStratification {
    
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@""];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Risk Stratification"];
    [formDescriptor addFormSection:section];
    
    NSDictionary *riskStratDict = [self.fullScreeningForm objectForKey:SECTION_RISK_STRATIFICATION];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckRiskStrat];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
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
    [section addFormRow:row];
    
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
                                                  title:@"Have you ever been diagnosed by your doctor to have chronic kidney disease? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.selectorOptions = @[@"YES", @"NO"];
    row.required = YES;
    
    //value
    if (riskStratDict != (id)[NSNull null] && [riskStratDict objectForKey:kKidneyDisease] != (id)[NSNull null]) {
        row.value = [self getYesNoFromOneZero:riskStratDict[kKidneyDisease]];
    }
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *doYouSmokeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmoke
                                                                               rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                 title:@"Do you smoke? *"];
    [self setDefaultFontWithRow:doYouSmokeRow];
    doYouSmokeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    doYouSmokeRow.selectorOptions = @[@"YES", @"NO"];
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
    row.selectorOptions = @[@"≥ 1 cigarette (or equivalent) per day on average",
                            @"< 1 cigarette (or equivalent) per day on average"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", doYouSmokeRow];
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
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", doYouSmokeRow];
    
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
    
    /* Profiling */
    else if ([rowDescriptor.tag isEqualToString:kProfilingConsent]) {
        [self postSingleFieldWithSection:SECTION_PROFILING_SOCIOECON andFieldName:kProfilingConsent andNewContent:ansFromYesNo];
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
    
    /* Geriatric Depression Assessment */
    else if ([rowDescriptor.tag isEqualToString:kPhqQ1]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhqQ1 andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ2]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhqQ2 andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPhq9Score]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kPhq9Score andNewContent:newValue];
    }  else if ([rowDescriptor.tag isEqualToString:kQ10Response]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kQ10Response andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kFollowUpReq]) {
        [self postSingleFieldWithSection:SECTION_DEPRESSION andFieldName:kFollowUpReq andNewContent:newValue];
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
            case Diabetes: fieldName = kCheckDiabetes;
                break;
            case Hyperlipidemia: fieldName = kCheckHyperlipidemia;
                break;
            case Hypertension: fieldName = kCheckHypertension;
                break;
            case RiskStratification: fieldName = kCheckRiskStrat;
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
            case Diabetes: fieldName = kCheckDiabetes;
                break;
            case Hyperlipidemia: fieldName = kCheckHyperlipidemia;
                break;
            case Hypertension: fieldName = kCheckHypertension;
                break;
            case RiskStratification: fieldName = kCheckRiskStrat;
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


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

//Screening of Risk Factors
NSString *const kExYesNo = @"ex_yes_no";
NSString *const kExNoWhy = @"ex_no_why";
NSString *const kExNoOthers = @"ex_no_others";
NSString *const kSmoking = @"smoking";
NSString *const kSmokingNumYears = @"smoking_num_years";
NSString *const kTypeOfSmoke = @"smoking_type";
NSString *const kSmokeNumSticks = @"smoking_num_sticks";
NSString *const kSmokeAfterWaking = @"smoking_after_waking";
NSString *const kSmokingRefrain = @"smoking_refrain";
NSString *const kSmokingWhichNotGiveUp = @"smoking_which_not_give_up";
NSString *const kSmokingMornFreq = @"smoking_morn_freq";
NSString *const kSmokingSickInBed = @"smoking_sick_in_bed";
NSString *const kSmokingAttemptedQuit = @"smoking_attempted_quit";
NSString *const kSmokingNumQuitAttempts = @"smoking_num_quit_attempts";
NSString *const kSmokingIntentionsToCut = @"smoking_intentions_to_cut";
NSString *const kSmokingHowQuit = @"smoking_how_quit";
NSString *const kSmokingHowQuitOthers = @"smoking_how_quit_others";
NSString *const kSmokingWhyQuit = @"smoking_why_quit";
NSString *const kSmokingWhyQuitOthers = @"smoking_why_quit_others";
NSString *const kAlcoholHowOften = @"alcohol_how_often";
NSString *const kAlcoholNumYears = @"alcohol_num_years";
NSString *const kAlcoholConsumpn = @"alcohol_consumpn";
NSString *const kAlcoholPreference = @"alcohol_preference";
NSString *const kAlcoholIntentToCut = @"alcohol_intent_to_cut";

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


//Primary Care Source
//NSString *const kCareGiverID = @"care_giver_id";
//NSString *const kCareGiverOthers = @"care_giver_others";
//NSString *const kCareProviderID = @"care_provider_id";
//NSString *const kCareProviderOthers = @"care_provider_others";
//NSString *const kAneVisit = @"ane_visit";
//NSString *const kHospitalized = @"hospitalized";

//My Health and My Neighbourhood
NSString *const kMobility = @"mobility";
NSString *const kMobilityAid = @"mobility_aid";
NSString *const kSelfCare = @"self_care";
NSString *const kUsualActivities = @"usual_activities";
NSString *const kHealthToday = @"health_today";
NSString *const kParkTime = @"park_time";
NSString *const kFeelSafe = @"feel_safe";
NSString *const kCrimeLow = @"crime_low";
NSString *const kDrunkenPpl = @"drunken_ppl";
NSString *const kBrokenBottles = @"broken_bottles";
NSString *const kUnclearSigns = @"unclear_signs";
NSString *const kHomelessPpl = @"homeless_ppl";
NSString *const kPublicTrans = @"public_trans";
NSString *const kSeeDoc = @"see_doc";
NSString *const kBuyMedi = @"buy_medi";
NSString *const kGrocery = @"grocery";
NSString *const kCommCentre = @"comm_centre";
NSString *const kSSCentres = @"ss_centres";
NSString *const kBankingPost = @"banking_post";
NSString *const kReligiousPlaces = @"religious_places";
NSString *const kInteract = @"interact";
NSString *const kSafePlaces = @"safe_places";

//Demographics

//Current Physical Issues
NSString *const kMultiADL = @"multi_adl";


//Referral for Doctor Consult
//NSString *const kReferralChecklist = @"referral_checklist";
//NSString *const kDocConsult = @"doc_consult";
//NSString *const kDocRef = @"doc_ref";
//NSString *const kSeri = @"seri";
//NSString *const kSeriRef = @"seri_ref";
//NSString *const kDentalConsult = @"dental";
//NSString *const kDentalRef = @"dental_ref";
//NSString *const kMammoRef = @"mammo_ref";
//NSString *const kFitKit = @"fit_kit";
//NSString *const kPapSmearRef = @"pap_smear_ref";
//NSString *const kPhlebotomy = @"phleb";
//NSString *const kRefNA = @"na";
//NSString *const kDocNotes = @"doc_notes";
//NSString *const kDocName = @"doc_name";


@interface ScreeningFormViewController () {
    NSString *gender;
    NSArray *spoken_lang_value;
    XLFormRowDescriptor *preEdScoreRow, *postEdScoreRow, *showPostEdSectionBtnRow;
    XLFormSectionDescriptor *preEdSection, *postEdSection;
    NSString *neighbourhood, *citizenship;
    NSNumber *age;
    BOOL sporean, age50, relColorectCancer, colon3Yrs, wantColRef, disableFIT;
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
                            stringForKey:@"ResidentCitizenship"];
    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                             stringForKey:@"ResidentAge"];
    gender = [[NSUserDefaults standardUserDefaults]
              stringForKey:@"ResidentGender"];
    neighbourhood = [[NSUserDefaults standardUserDefaults]
              stringForKey:@"Neighbourhood"];
    
    
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
        case 3: form = [self initTriage];
            break;
        case 4: form = [self initSnellenEyeTest];
            break;
        case 5: form = [self initAdditionalSvcs];
            break;
        case 6: form = [self initRefForDoctorConsult];
            break;
////        case 10: form = [self initMyHealthAndMyNeighbourhood];
////            break;
//        case 12: form = [self initCurrentPhysicalIssues];
//            break;
        case 11: form = [self initHealthEducation];
            break;
//        case 14: form = [self initSocialSupportAssessment];
//            break;
//        case 15: form = [self initRefForDoctorConsult];
//            break;
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
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApptDate rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Appointment Date"];
    row.noValueDisplayText = @"Tap here";
    
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
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFastingBloodGlucose rowType:XLFormRowDescriptorTypeDecimal title:@"Fasting blood glucose (mmol/L)"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:15] forKey:@"textLabel.font"];   //the description too long. Default fontsize is 16
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTriglycerides rowType:XLFormRowDescriptorTypeDecimal title:@"Triglycerides (mmol/L)"];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLDL rowType:XLFormRowDescriptorTypeDecimal title:@"LDL Cholestrol (mmol/L)"];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHDL rowType:XLFormRowDescriptorTypeDecimal title:@"HDL Cholestrol (mmol/L)"];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCholesterolHdlRatio rowType:XLFormRowDescriptorTypeDecimal title:@"Cholestrol/HDL ratio"];
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTotCholesterol rowType:XLFormRowDescriptorTypeDecimal title:@"Total Cholestrol (mmol/L)"];
    row.required = NO;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}


-(id) initProfiling {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Profiling"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    XLFormRowDescriptor *rowInfo;
    
    sporean = age50 = relColorectCancer = colon3Yrs = wantColRef = disableFIT = false;
    
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kProfilingConsent rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Consent to disclosure of information"];
    row.required = YES;
    [section addFormRow:row];
    
    // Resident's Socioeconomic status - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Resident's Socioeconomic Status"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *employmentRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStat rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Employment status"];
    employmentRow.required = NO;
    employmentRow.selectorOptions = @[@"Retired", @"Housewife/Homemaker",@"Self-employed",@"Part-time employed",@"Full-time employed", @"Unemployed", @"Others"];
    [section addFormRow:employmentRow];
    
    XLFormRowDescriptor *unemployReasonsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployReasons rowType:XLFormRowDescriptorTypeTextView title:@""];
    unemployReasonsRow.required = NO;
    unemployReasonsRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Unemployed'", employmentRow];
    [unemployReasonsRow.cellConfigAtConfigure setObject:@"Reasons for unemployment" forKey:@"textView.placeholder"];
//    [unemployReasonsRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textView.textAlignment"];
    [section addFormRow:unemployReasonsRow];
    
    XLFormRowDescriptor *otherEmployRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployOthers rowType:XLFormRowDescriptorTypeText title:@"Other employment"];
    otherEmployRow.required = NO;
    otherEmployRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", employmentRow];
    [otherEmployRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:otherEmployRow];
    
    XLFormRowDescriptor *noDiscloseIncomeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiscloseIncome rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Resident does not want to disclose income"];
//    noDiscloseIncomeRow.selectorOptions = @[@"Yes", @"No"];
    noDiscloseIncomeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noDiscloseIncomeRow.required = NO;
    [section addFormRow:noDiscloseIncomeRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *mthHouseIncome = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgMthHouseIncome rowType:XLFormRowDescriptorTypeDecimal title:@"Average monthly household income"];
    [mthHouseIncome.cellConfigAtConfigure setObject:@"Enter here" forKey:@"textField.placeholder"];
    mthHouseIncome.cellConfig[@"textLabel.numberOfLines"] = @0;
    mthHouseIncome.required = NO;
    [section addFormRow:mthHouseIncome];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

    XLFormRowDescriptor *noOfPplInHouse = [XLFormRowDescriptor formRowDescriptorWithTag:kNumPplInHouse rowType:XLFormRowDescriptorTypeNumber title:@"No. of people in the household"];
    [noOfPplInHouse.cellConfig setObject:[UIFont systemFontOfSize:15] forKey:@"textLabel.font"];   //the description too long. Default fontsize is 16
    [noOfPplInHouse.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    noOfPplInHouse.required = NO;
    [section addFormRow:noOfPplInHouse];
    
    XLFormRowDescriptor *avgIncomePerHead = [XLFormRowDescriptor formRowDescriptorWithTag:kAvgIncomePerHead rowType:XLFormRowDescriptorTypeDecimal title:@"Average income per head"];   //auto-calculate
    [avgIncomePerHead.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    avgIncomePerHead.required = NO;
    
    if (!isnan([mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue])) {  //check for not nan first!
        avgIncomePerHead.value = [NSString stringWithFormat:@"$ %.2f", [mthHouseIncome.value doubleValue] / [noOfPplInHouse.value doubleValue]];
    }
    
    avgIncomePerHead.disabled = @(1);
    [section addFormRow:avgIncomePerHead];
        //Initial value only
//        if ([clinicalResultsDict objectForKey:@"bmi"] != [NSNull null]) {
//            if (![[clinicalResultsDict objectForKey:@"bmi"] isEqualToString:@""]) {
//                bmi.value = [clinicalResultsDict objectForKey:@"bmi"];
//            } else {
    
//            }
//        }
    
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
    chasNoChasRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    chasNoChasRow.required = NO;
    [section addFormRow:chasNoChasRow];
    
    XLFormRowDescriptor *lowHouseIncomeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLowHouseIncome rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"For households with income: Household monthly income per person is $1800 and below \nOR\nFor households with no income: Annual Value (AV) of home is $21,000 and below"];
    lowHouseIncomeRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    lowHouseIncomeRow.required = NO;
    [section addFormRow:lowHouseIncomeRow];
    
    XLFormRowDescriptor *wantChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantChas rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want to apply for CHAS?"];
    wantChasRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantChasRow.required = NO;
    [section addFormRow:wantChasRow];
    
    XLFormRowDescriptor *chasColorRow = [XLFormRowDescriptor formRowDescriptorWithTag:kChasColor rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"If resident owns CHAS card, what colour?"];
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
    sporeanPrRow.required = NO;
    sporeanPrRow.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"]) {
        sporeanPrRow.value = @1;
        sporean = YES;
    }
    else {
        sporeanPrRow.value = @0;
        sporean = NO;
    }
    [section addFormRow:sporeanPrRow];
    
    XLFormRowDescriptor *age50Row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove50 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Age 50 and above"];
    age50Row.required = NO;
    age50Row.disabled = @(1);
    if ([age integerValue] >= 50) {
        age50Row.value = @1;
        age50 = YES;
    }
    else {
        age50Row.value = @0;
        age50 = NO;
    }
    [section addFormRow:age50Row];
    
    XLFormRowDescriptor *relColCancerRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelWColorectCancer rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"First degree relative with colorectal cancer?"];
    relColCancerRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    relColCancerRow.required = NO;
    [section addFormRow:relColCancerRow];
    
    
    XLFormRowDescriptor *colon3yrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kColonoscopy3yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done colonoscopy in the past 3 years?"];
    colon3yrsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    colon3yrsRow.required = NO;
    [section addFormRow:colon3yrsRow];
    
    XLFormRowDescriptor *wantColonRefRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantColonoscopyRef rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a referral for free colonoscopy?"];
    wantColonRefRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantColonRefRow.required = NO;
    [section addFormRow:wantColonRefRow];
    
    // Eligibility Assessment for FIT - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility Assessment for FIT"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean/PR"];
    row.required = NO;
    row.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"])
        row.value = @1;
    else
        row.value = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove50 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Age 50 and above"];
    row.required = NO;
    row.disabled = @(1);
    if ([age integerValue] >= 50)
        row.value = @1;
    else
        row.value = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *fitLast12MthsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFitLast12Mths rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done FIT in the last 12 months?"];
    fitLast12MthsRow.required = NO;
    fitLast12MthsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:fitLast12MthsRow];
    
    XLFormRowDescriptor *colonoscopy10YrsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kColonoscopy10Yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done colonoscopy in the past 10 years?"];
    colonoscopy10YrsRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    colonoscopy10YrsRow.required = NO;
    [section addFormRow:colonoscopy10YrsRow];
    
    XLFormRowDescriptor *wantFitKitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantFitKit rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free FIT kit?"];
    wantFitKitRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    wantFitKitRow.required = NO;
    [section addFormRow:wantFitKitRow];
    
    relColCancerRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqual:@(1)])  relColorectCancer = true;
            else relColorectCancer = false;
        }
        
        if (sporean && age50 && relColorectCancer && colon3Yrs && wantColRef) disableFIT = true;
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
        
        if (sporean && age50 && relColorectCancer && colon3Yrs && wantColRef) disableFIT = true;
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
        
        if (sporean && age50 && relColorectCancer && colon3Yrs && wantColRef) disableFIT = true;
        else disableFIT = false;
        fitLast12MthsRow.disabled = [NSNumber numberWithBool:disableFIT];
        colonoscopy10YrsRow.disabled = [NSNumber numberWithBool:disableFIT];
        wantFitKitRow.disabled = [NSNumber numberWithBool:disableFIT];
        [self reloadFormRow:fitLast12MthsRow];
        [self reloadFormRow:colonoscopy10YrsRow];
        [self reloadFormRow:wantFitKitRow];

    };
    
    
    
    
    BOOL isMale;
    if ([gender isEqualToString:@"M"]) isMale=true;
    else isMale = false;
    
    // Eligibility Assessment for Mammogram - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility Assessment for Mammogram"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean"];
    row.required = NO;
    row.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"])
        row.value = @1;
    else
        row.value = @0;
//    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeCheck rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 50 to 69"];
    row.required = NO;
    row.disabled = @(1);
    if (([age integerValue] >= 50) && ([age integerValue] < 70))
        row.value = @1;
    else
        row.value = @0;
//    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMammo2Yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done mammogram in the last 2 years?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHasChas rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has a valid CHAS card (blue/orange)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kWantMammo rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free mammogram referral?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    // Eligibility Assessment for pap smear - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility Assessment for Pap Smear"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Singaporean/PR"];
    row.required = NO;
    row.disabled = @(1);
    if ([citizenship isEqualToString:@"Singaporean"] || [citizenship isEqualToString:@"PR"])
        row.value = @1;
    else
        row.value = @0;
//    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
#warning need to change the age name
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeCheck2 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 25 to 69"];
    row.required = NO;
    row.disabled = @(1);
    if (([age integerValue] >= 25) && ([age integerValue] < 70))
        row.value = @1;
    else
        row.value = @0;
//    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPap3Yrs rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has not done pap smear in the last 3 years?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEngagedSex rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has engaged in sexual intercourse before"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferPapSmear rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free pap smear referral?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    row.disabled = isMale? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [section addFormRow:row];

    
    // Eligibility for Fall Risk Assessment - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility for Fall Risk Assessment"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove50 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 65 and above?"];
    row.required = NO;
    row.disabled = @(1);
    if ([age integerValue] >= 65)
        row.value = @1;
    else
        row.value = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFallen12Mths rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Have you fallen in the past 12 months?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kScaredFall rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Do you avoid going out because you are scared of falling?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelFall rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Do you feel like you are going to fall when getting up or walking?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];
    
    // Eligibility for Geriatric dementia assessment - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Eligibility for Geriatric dementia assessment"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeAbove65 rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Aged 65 and above?"];
    row.required = NO;
    row.disabled = @(1);
    if ([age integerValue] >= 65)
        row.value = @1;
    else
        row.value = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Resident shows signs of cognitive impairment(e.g. forgetfulness, carelessness, lack of awareness)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.required = NO;
    [section addFormRow:row];

    
    
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

-(id)initScreeningOfRiskFactors {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Screening of Risk Factors"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *riskFactorsDict = [self.fullScreeningForm objectForKey:@"risk_factors"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Exercise - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Exercise"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Do you participate in any form of physical activity, for at least 20 min per occasion, 3 or more days a week?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *exerciseYesNoRow = [XLFormRowDescriptor formRowDescriptorWithTag:kExYesNo rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    exerciseYesNoRow.selectorOptions = @[@"YES", @"NO"];
    if (![[riskFactorsDict objectForKey:kExYesNo] isEqualToString:@""]) {
        exerciseYesNoRow.value = [[riskFactorsDict objectForKey:kExYesNo] isEqualToString:@"1"]? @"YES":@"NO";
    }
    [section addFormRow:exerciseYesNoRow];
    
    
    
    
    XLFormRowDescriptor *exerciseNoWhyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kExNoWhy rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"If no, why not?"];
    exerciseNoWhyRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Because of health condition"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"No time"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Too troublesome"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Others"]
                            ];
    if ([exerciseYesNoRow.value isEqualToString:@"NO"]) {
        exerciseNoWhyRow.hidden = @(0);
    } else {
        exerciseNoWhyRow.hidden = @(1);
    }
    NSArray *options = exerciseNoWhyRow.selectorOptions;
    if (![[riskFactorsDict objectForKey:kExNoWhy]isEqualToString:@""]) {
        exerciseNoWhyRow.value = [options objectAtIndex:[[riskFactorsDict objectForKey:kExNoWhy] integerValue]];
    }
    exerciseNoWhyRow.noValueDisplayText = @"Tap here for options";
    [section addFormRow:exerciseNoWhyRow];
    
    XLFormRowDescriptor *exerciseNoOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kExNoOthers
                                                rowType:XLFormRowDescriptorTypeTextView title:@"Others"];
    [exerciseNoOthersRow.cellConfigAtConfigure setObject:@"Type your other reasons here" forKey:@"textView.placeholder"];
    if ([[exerciseNoWhyRow.value formValue] isEqualToNumber:@3]) {
        exerciseNoOthersRow.hidden = @(0);
    } else {
        exerciseNoOthersRow.hidden = @(1);
    }
    exerciseNoOthersRow.value = [riskFactorsDict objectForKey:kExNoOthers];
    [section addFormRow:exerciseNoOthersRow];
    
    exerciseNoWhyRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([[newValue formValue] isEqual:@(3)]) {
                exerciseNoOthersRow.hidden = @(0);
            } else {
                exerciseNoOthersRow.hidden = @(1);
            }
        }
    };
    
    exerciseYesNoRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([newValue isEqualToString:@"NO"]) {
                exerciseNoWhyRow.hidden = @(0);
            } else {
                exerciseNoWhyRow.hidden = @(1);
                exerciseNoOthersRow.hidden = @(1);
            }
        }
    };
    
    // Smoking - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Smoking"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *smokingStatusRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmoking
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@"What is your smoking status? *"];
    smokingStatusRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Smokes at least once a day"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Smokes but not everyday"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Ex-smoker, now quit"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Never smoked"]
                            ];
    options = smokingStatusRow.selectorOptions;
    if (![[riskFactorsDict objectForKey:kSmoking]isEqualToString:@""]) {
        smokingStatusRow.value = [options objectAtIndex:[[riskFactorsDict objectForKey:kSmoking] integerValue]];
    }
    smokingStatusRow.required = YES;
    [section addFormRow:smokingStatusRow];
    
    XLFormRowDescriptor *smokingNumYearsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, how many years have you been smoking for?"];
    smokingNumYearsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingNumYearsQRow];
    
    XLFormRowDescriptor *smokingNumYearsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingNumYears rowType:XLFormRowDescriptorTypeInteger title:@"Year(s)"];
    if (![[riskFactorsDict objectForKey:kSmokingNumYears]isEqualToString:@""]) {
        smokingNumYearsRow.value = [riskFactorsDict objectForKey:kSmokingNumYears];
    }
    [section addFormRow:smokingNumYearsRow];
    XLFormRowDescriptor *smokingTypeOfSmokeQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, what do you smoke? (can tick more than one option)"];
    smokingTypeOfSmokeQRow.cellConfig[@"textLabel.numberOfLines"] = @0;

    [section addFormRow:smokingTypeOfSmokeQRow];
    
    XLFormRowDescriptor *smokingTypeOfSmokeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTypeOfSmoke rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    smokingTypeOfSmokeRow.selectorOptions = @[@"Cigarettes", @"Pipe", @"Self-rolled leaves \"ang hoon\"", @"Shisha", @"Cigars", @"E-cigarettes", @"Others"];

    NSArray *typeOfSmokeArray = [self getTypeOfSmokeFromIndivValues];
    
    smokingTypeOfSmokeRow.value = typeOfSmokeArray;
    
    [section addFormRow:smokingTypeOfSmokeRow];
    
    XLFormRowDescriptor *smokingNumSticksQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, how many sticks do you smoke a day (average)?"];
    smokingNumSticksQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingNumSticksQRow];
    XLFormRowDescriptor *smokingNumSticksRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokeNumSticks rowType:XLFormRowDescriptorTypeInteger title:@"Stick(s)"];
    
    smokingNumSticksRow.value = [riskFactorsDict objectForKey:kSmokeNumSticks];
    
    
    [section addFormRow:smokingNumSticksRow];
    
    XLFormRowDescriptor *smokeAfterWakingQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, how soon after waking do you smoke your first cigarette?"];
    smokeAfterWakingQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokeAfterWakingQRow];
    XLFormRowDescriptor *smokeAfterWakingRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokeAfterWaking
                                                 rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    smokeAfterWakingRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Within 5 mins"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"5-30 mins"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"More than 30 mins"]];
    
    options = smokeAfterWakingRow.selectorOptions;
    if (![[riskFactorsDict objectForKey:kSmokeAfterWaking]isEqualToString:@""]) {
        smokeAfterWakingRow.value = [options objectAtIndex:[[riskFactorsDict objectForKey:kSmokeAfterWaking] integerValue]];
    }
    smokeAfterWakingRow.noValueDisplayText = @"Tap here for options";
    
    [section addFormRow:smokeAfterWakingRow];
    
    XLFormRowDescriptor *smokingRefrainQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, do you find it difficult to refrain from smoking in places where it is forbidden/not allowed?"];
    smokingRefrainQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingRefrainQRow];
    XLFormRowDescriptor *smokingRefrainRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingRefrain rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    smokingRefrainRow.selectorOptions = @[@"YES", @"NO"];
    
    if (![[riskFactorsDict objectForKey:kSmokingRefrain] isEqualToString:@""]) {
        smokingRefrainRow.value = [[riskFactorsDict objectForKey:kSmokingRefrain] isEqualToString:@"1"]? @"YES":@"NO";
    }
    
    [section addFormRow:smokingRefrainRow];
    
    XLFormRowDescriptor *smokingWhichNotGiveUpQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSix
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, which cigarette would you hate to give up?"];
    smokingWhichNotGiveUpQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingWhichNotGiveUpQRow];
    XLFormRowDescriptor *smokingWhichNotGiveUpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingWhichNotGiveUp
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    smokingWhichNotGiveUpRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"The first in the morning"],
                                                 [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Any other"]];
    //value
    options = smokingWhichNotGiveUpRow.selectorOptions;
    if (![[riskFactorsDict objectForKey:kSmokingWhichNotGiveUp]isEqualToString:@""]) {
        smokingWhichNotGiveUpRow.value = [options objectAtIndex:[[riskFactorsDict objectForKey:kSmokingWhichNotGiveUp] integerValue]];
    }
    smokingWhichNotGiveUpRow.noValueDisplayText = @"Tap here for options";
    [section addFormRow:smokingWhichNotGiveUpRow];
    
    XLFormRowDescriptor *smokingMornFreqQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSeven
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, do you smoke more frequently in the morning?"];
    smokingMornFreqQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingMornFreqQRow];
    XLFormRowDescriptor *smokingMornFreqRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingMornFreq rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    smokingMornFreqRow.selectorOptions = @[@"YES", @"NO"];
    //value
    if (![[riskFactorsDict objectForKey:kSmokingMornFreq] isEqualToString:@""]) {
        smokingMornFreqRow.value = [[riskFactorsDict objectForKey:kSmokingMornFreq] isEqualToString:@"1"]? @"YES":@"NO";
    }
    
    [section addFormRow:smokingMornFreqRow];
    
    XLFormRowDescriptor *smokingSickInBedQRow= [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEight
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, do you smoke even if you are sick in bed most of the day?"];
    smokingSickInBedQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingSickInBedQRow];
    XLFormRowDescriptor *smokingSickInBedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingSickInBed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    smokingSickInBedRow.selectorOptions = @[@"YES", @"NO"];
    //value
    if (![[riskFactorsDict objectForKey:kSmokingSickInBed] isEqualToString:@""]) {
        smokingSickInBedRow.value = [[riskFactorsDict objectForKey:kSmokingSickInBed] isEqualToString:@"1"]? @"YES":@"NO";
    }
    
    [section addFormRow:smokingSickInBedRow];
    
    XLFormRowDescriptor *smokingAttemptedQuitQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionNine
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, have you attempted to quit before, in the past year?"];
    smokingAttemptedQuitQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingAttemptedQuitQRow];
    XLFormRowDescriptor *smokingAttemptedQuitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingAttemptedQuit rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    smokingAttemptedQuitRow.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (![[riskFactorsDict objectForKey:kSmokingAttemptedQuit] isEqualToString:@""]) {
        smokingAttemptedQuitRow.value = [[riskFactorsDict objectForKey:kSmokingAttemptedQuit] isEqualToString:@"1"]? @"YES":@"NO";
    }
    [section addFormRow:smokingAttemptedQuitRow];
    
    XLFormRowDescriptor *smokingNumQuitAttemptsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTen
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If you have attempted to quit in the past year, how many quit attempts did you make?"];
    smokingNumQuitAttemptsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingNumQuitAttemptsQRow];
    XLFormRowDescriptor *smokingNumQuitAttemptsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingNumQuitAttempts rowType:XLFormRowDescriptorTypeNumber title:@"Attempt(s)"];
    //value
    smokingNumQuitAttemptsRow.value = [riskFactorsDict objectForKey:kSmokingNumQuitAttempts];
    [section addFormRow:smokingNumQuitAttemptsRow];
    
    XLFormRowDescriptor *smokingIntentionsToCutQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEleven
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, what are your intentions towards quitting/cutting down in the forseeable future?"];
    smokingIntentionsToCutQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingIntentionsToCutQRow];
    XLFormRowDescriptor *smokingIntentionsToCutRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingIntentionsToCut
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    smokingIntentionsToCutRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I plan to quit in the next 12 months"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I plan to quit, but not within the next 12 months"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I do not plan to quit, but I intend to cut down"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I do not plan to quit or cut down"]
                            ];
    //value
    options = smokingIntentionsToCutRow.selectorOptions;
    if (![[riskFactorsDict objectForKey:kSmokingIntentionsToCut]isEqualToString:@""]) {
        smokingIntentionsToCutRow.value = [options objectAtIndex:[[riskFactorsDict objectForKey:kSmokingIntentionsToCut] integerValue]];
    }
    smokingIntentionsToCutRow.noValueDisplayText = @"Tap here for options";
    
    [section addFormRow:smokingIntentionsToCutRow];

    XLFormRowDescriptor *smokingHowQuitQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwelve
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If ex-smoker, how did you quit smoking? (can tick more than one)"];
    smokingHowQuitQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingHowQuitQRow];
    XLFormRowDescriptor *smokingHowQuitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingHowQuit rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    smokingHowQuitRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"By myself"],
                                         [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"By joining a smoking cessation programme"],
                                         [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"By taking medication"],
                                         [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"With encouragement of family/friends"],
                                        [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Others"]];
  
    options = smokingHowQuitRow.selectorOptions;
    //value
    NSMutableArray *howQuitArray = [[NSMutableArray alloc] init];
    if ([[riskFactorsDict objectForKey:@"smoking_how_by_myself"] isEqualToString:@"1"]) [howQuitArray addObject:[options objectAtIndex:0]];
    if ([[riskFactorsDict objectForKey:@"smoking_how_join_cessation"] isEqualToString:@"1"]) [howQuitArray addObject:[options objectAtIndex:1]];
    if ([[riskFactorsDict objectForKey:@"smoking_how_take_med"] isEqualToString:@"1"]) [howQuitArray addObject:[options objectAtIndex:2]];
    if ([[riskFactorsDict objectForKey:@"smoking_how_encourage"] isEqualToString:@"1"]) [howQuitArray addObject:[options objectAtIndex:3]];
    if (![[riskFactorsDict objectForKey:@"smoking_how_quit_others"] isEqualToString:@""]) [howQuitArray addObject:[options objectAtIndex:4]];   //if others is not blank
    smokingHowQuitRow.value = howQuitArray;
    
    [section addFormRow:smokingHowQuitRow];
    
    XLFormRowDescriptor *smokingHowQuitOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingHowQuitOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    //value
    smokingHowQuitOthersRow.value = [riskFactorsDict objectForKey:kSmokingHowQuitOthers];
    smokingHowQuitOthersRow.hidden = @(1);  //default hidden
    [section addFormRow:smokingHowQuitOthersRow];
    
    //Initial state
    if (([smokingHowQuitRow.value isKindOfClass:[NSArray class]]) || ([smokingHowQuitRow.value isKindOfClass:[NSMutableArray class]])) {
        for(int i=0;i<[smokingHowQuitRow.value count];i++) {
            if ([[[smokingHowQuitRow.value objectAtIndex:i]formValue] isEqual:@(5)]) {
                smokingHowQuitOthersRow.hidden = @(0);
                break;
            }
            else {
                smokingHowQuitOthersRow.hidden = @(1);
            }
        }
    }

    smokingHowQuitRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if (newValue != (id)[NSNull null]) {
                if (([newValue isKindOfClass:[NSArray class]]) || ([newValue isKindOfClass:[NSMutableArray class]])) {
                    for(int i=0; i<[newValue count];i++) {
                        if ([[newValue[i] formValue] isEqual:@(4)]) {  //others option
                            smokingHowQuitOthersRow.hidden = @(0);
                            break;
                        } else {
                            smokingHowQuitOthersRow.hidden = @(1);
                        }
                    }
                }
            }
        }
    };
    
    XLFormRowDescriptor *smokingWhyQuitQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThirteen
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If ex-smoker, why did you choose to quit? (can tick more than one)"];
    smokingWhyQuitQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingWhyQuitQRow];
    XLFormRowDescriptor *smokingWhyQuitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingWhyQuit rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    smokingWhyQuitRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Health/medical reasons"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Side effects (eg. Odour)"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Learnt about harm of smoking"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Family/friends' advice"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Too expensive"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Others"]];
    
    options = smokingWhyQuitRow.selectorOptions;
    //value
    NSMutableArray *whyQuitArray = [[NSMutableArray alloc] init];
    if ([[riskFactorsDict objectForKey:@"smoking_why_health"] isEqualToString:@"1"]) [whyQuitArray addObject:[options objectAtIndex:0]];
    if ([[riskFactorsDict objectForKey:@"smoking_why_side"] isEqualToString:@"1"]) [whyQuitArray addObject:[options objectAtIndex:1]];
    if ([[riskFactorsDict objectForKey:@"smoking_why_harm"] isEqualToString:@"1"]) [whyQuitArray addObject:[options objectAtIndex:2]];
    if ([[riskFactorsDict objectForKey:@"smoking_why_advice"] isEqualToString:@"1"]) [whyQuitArray addObject:[options objectAtIndex:3]];
    if ([[riskFactorsDict objectForKey:@"smoking_why_ex"] isEqualToString:@"1"]) [whyQuitArray addObject:[options objectAtIndex:4]];
    if (![[riskFactorsDict objectForKey:@"smoking_why_quit_others"] isEqualToString:@""]) [whyQuitArray addObject:[options objectAtIndex:5]];   //if others is not blank
    smokingWhyQuitRow.value = whyQuitArray;
    
    
    [section addFormRow:smokingWhyQuitRow];
    
    XLFormRowDescriptor *smokingWhyQuitOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingWhyQuitOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    //value
    smokingWhyQuitOthersRow.value = [riskFactorsDict objectForKey:kSmokingWhyQuitOthers];
    smokingWhyQuitOthersRow.hidden = @(1);  //default hidden
    
    [section addFormRow:smokingWhyQuitOthersRow];
    
    if (([smokingWhyQuitRow.value isKindOfClass:[NSArray class]]) || ([smokingWhyQuitRow.value isKindOfClass:[NSMutableArray class]])) {
        for(int i=0;i<[smokingWhyQuitRow.value count];i++) {
            if ([[[smokingWhyQuitRow.value objectAtIndex:i]formValue] isEqual:@(5)]) {
                smokingWhyQuitOthersRow.hidden = @(0);
                break;
            }
            else {
                smokingWhyQuitOthersRow.hidden = @(1);
            }
        }
    }
    
    smokingWhyQuitRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if (newValue != (id)[NSNull null]) {
                if (([newValue isKindOfClass:[NSArray class]]) || ([newValue isKindOfClass:[NSMutableArray class]])) {
                    for(int i=0; i<[newValue count];i++) {
                        if ([[newValue[i] formValue] isEqual:@(5)]) {  //others option
                            smokingWhyQuitOthersRow.hidden = @(0);
                            break;
                        } else {
                            smokingWhyQuitOthersRow.hidden = @(1);
                        }
                    }
                }
            }
        }
    };
    

    if (([[smokingStatusRow.value formValue] isEqual:@(0)])||([[smokingStatusRow.value formValue] isEqual:@(1)])) {
        smokingNumYearsQRow.hidden = @(0);  //show
        smokingNumYearsRow.hidden = @(0);
        smokingTypeOfSmokeQRow.hidden = @(0);
        smokingTypeOfSmokeRow.hidden = @(0);
        smokingNumSticksQRow.hidden = @(0);
        smokingNumSticksRow.hidden = @(0);
        smokeAfterWakingQRow.hidden = @(0);
        smokeAfterWakingRow.hidden = @(0);
        smokingRefrainQRow.hidden = @(0);
        smokingRefrainRow.hidden = @(0);
        smokingWhichNotGiveUpQRow.hidden = @(0);
        smokingWhichNotGiveUpRow.hidden = @(0);
        smokingMornFreqQRow.hidden = @(0);
        smokingMornFreqRow.hidden = @(0);
        smokingSickInBedQRow.hidden = @(0);
        smokingSickInBedRow.hidden = @(0);
        smokingAttemptedQuitQRow.hidden = @(0);
        smokingAttemptedQuitRow.hidden = @(0);
        smokingNumQuitAttemptsQRow.hidden = @(0);
        smokingNumQuitAttemptsRow.hidden = @(0);
        smokingIntentionsToCutQRow.hidden = @(0);
        smokingIntentionsToCutRow.hidden = @(0);
        
//        //hide ex-smoker portion
        smokingHowQuitQRow.hidden = @(1);
        smokingHowQuitRow.hidden = @(1);
        smokingHowQuitOthersRow.hidden = @(1);
        smokingWhyQuitQRow.hidden = @(1);
        smokingWhyQuitRow.hidden = @(1);
        smokingWhyQuitOthersRow.hidden = @(1);
    }
    else if([[smokingStatusRow.value formValue] isEqual:@(2)]) {    //ex-smoker
        
        //hide smoking currently rows
        smokingNumYearsQRow.hidden = @(1);
        smokingNumYearsRow.hidden = @(1);
        smokingTypeOfSmokeQRow.hidden = @(1);
        smokingTypeOfSmokeRow.hidden = @(1);
        smokingNumSticksQRow.hidden = @(1);
        smokingNumSticksRow.hidden = @(1);
        smokeAfterWakingQRow.hidden = @(1);
        smokeAfterWakingRow.hidden = @(1);
        smokingRefrainQRow.hidden = @(1);
        smokingRefrainRow.hidden = @(1);
        smokingWhichNotGiveUpQRow.hidden = @(1);
        smokingWhichNotGiveUpRow.hidden = @(1);
        smokingMornFreqQRow.hidden = @(1);
        smokingMornFreqRow.hidden = @(1);
        smokingSickInBedQRow.hidden = @(1);
        smokingSickInBedRow.hidden = @(1);
        smokingAttemptedQuitQRow.hidden = @(1);
        smokingAttemptedQuitRow.hidden = @(1);
        smokingNumQuitAttemptsQRow.hidden = @(1);
        smokingNumQuitAttemptsRow.hidden = @(1);
        smokingIntentionsToCutQRow.hidden = @(1);
        smokingIntentionsToCutRow.hidden = @(1);
        
        //show ex-smoker rows
        smokingHowQuitQRow.hidden = @(0);
        smokingHowQuitRow.hidden = @(0);
        smokingWhyQuitQRow.hidden = @(0);
        smokingWhyQuitRow.hidden = @(0);
    }
    else {
        smokingNumYearsQRow.hidden = @(1);  //hide
        smokingNumYearsRow.hidden = @(1);
        smokingTypeOfSmokeQRow.hidden = @(1);
        smokingTypeOfSmokeRow.hidden = @(1);
        smokingNumSticksQRow.hidden = @(1);
        smokingNumSticksRow.hidden = @(1);
        smokeAfterWakingQRow.hidden = @(1);
        smokeAfterWakingRow.hidden = @(1);
        smokingRefrainQRow.hidden = @(1);
        smokingRefrainRow.hidden = @(1);
        smokingWhichNotGiveUpQRow.hidden = @(1);
        smokingWhichNotGiveUpRow.hidden = @(1);
        smokingMornFreqQRow.hidden = @(1);
        smokingMornFreqRow.hidden = @(1);
        smokingSickInBedQRow.hidden = @(1);
        smokingSickInBedRow.hidden = @(1);
        smokingAttemptedQuitQRow.hidden = @(1);
        smokingAttemptedQuitRow.hidden = @(1);
        smokingNumQuitAttemptsQRow.hidden = @(1);
        smokingNumQuitAttemptsRow.hidden = @(1);
        smokingIntentionsToCutQRow.hidden = @(1);
        smokingIntentionsToCutRow.hidden = @(1);
        smokingHowQuitQRow.hidden = @(1);
        smokingHowQuitRow.hidden = @(1);
        smokingHowQuitOthersRow.hidden = @(1);
        smokingWhyQuitQRow.hidden = @(1);
        smokingWhyQuitRow.hidden = @(1);
        smokingWhyQuitOthersRow.hidden = @(1);
    }


    smokingStatusRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if (([[newValue formValue] isEqual:@(0)]) | ([[newValue formValue] isEqual:@(1)])) {    //if status is currently smoking
                smokingNumYearsQRow.hidden = @(0);  //show
                smokingNumYearsRow.hidden = @(0);
                smokingTypeOfSmokeQRow.hidden = @(0);
                smokingTypeOfSmokeRow.hidden = @(0);
                smokingNumSticksQRow.hidden = @(0);
                smokingNumSticksRow.hidden = @(0);
                smokeAfterWakingQRow.hidden = @(0);
                smokeAfterWakingRow.hidden = @(0);
                smokingRefrainQRow.hidden = @(0);
                smokingRefrainRow.hidden = @(0);
                smokingWhichNotGiveUpQRow.hidden = @(0);
                smokingWhichNotGiveUpRow.hidden = @(0);
                smokingMornFreqQRow.hidden = @(0);
                smokingMornFreqRow.hidden = @(0);
                smokingSickInBedQRow.hidden = @(0);
                smokingSickInBedRow.hidden = @(0);
                smokingAttemptedQuitQRow.hidden = @(0);
                smokingAttemptedQuitRow.hidden = @(0);
                smokingNumQuitAttemptsQRow.hidden = @(0);
                smokingNumQuitAttemptsRow.hidden = @(0);
                smokingIntentionsToCutQRow.hidden = @(0);
                smokingIntentionsToCutRow.hidden = @(0);
                
                //hide ex-smoker portion
                smokingHowQuitQRow.hidden = @(1);
                smokingHowQuitRow.hidden = @(1);
                smokingWhyQuitQRow.hidden = @(1);
                smokingWhyQuitRow.hidden = @(1);
            }
            else if([[newValue formValue] isEqual:@(2)]) {    //ex-smoker
                
                //hide smoking currently rows
                smokingNumYearsQRow.hidden = @(1);
                smokingNumYearsRow.hidden = @(1);
                smokingTypeOfSmokeQRow.hidden = @(1);
                smokingTypeOfSmokeRow.hidden = @(1);
                smokingNumSticksQRow.hidden = @(1);
                smokingNumSticksRow.hidden = @(1);
                smokeAfterWakingQRow.hidden = @(1);
                smokeAfterWakingRow.hidden = @(1);
                smokingRefrainQRow.hidden = @(1);
                smokingRefrainRow.hidden = @(1);
                smokingWhichNotGiveUpQRow.hidden = @(1);
                smokingWhichNotGiveUpRow.hidden = @(1);
                smokingMornFreqQRow.hidden = @(1);
                smokingMornFreqRow.hidden = @(1);
                smokingSickInBedQRow.hidden = @(1);
                smokingSickInBedRow.hidden = @(1);
                smokingAttemptedQuitQRow.hidden = @(1);
                smokingAttemptedQuitRow.hidden = @(1);
                smokingNumQuitAttemptsQRow.hidden = @(1);
                smokingNumQuitAttemptsRow.hidden = @(1);
                smokingIntentionsToCutQRow.hidden = @(1);
                smokingIntentionsToCutRow.hidden = @(1);
                smokingHowQuitQRow.hidden = @(1);
                smokingHowQuitRow.hidden = @(1);
                smokingHowQuitOthersRow.hidden = @(1);
                smokingWhyQuitQRow.hidden = @(1);
                smokingWhyQuitRow.hidden = @(1);
                smokingWhyQuitOthersRow.hidden = @(1);
                
                //show ex-smoker rows
                smokingHowQuitQRow.hidden = @(0);
                smokingHowQuitRow.hidden = @(0);
                smokingWhyQuitQRow.hidden = @(0);
                smokingWhyQuitRow.hidden = @(0);
            }
            else {  //non-smoker totally
                smokingNumYearsQRow.hidden = @(1);  //hide
                smokingNumYearsRow.hidden = @(1);
                smokingTypeOfSmokeQRow.hidden = @(1);
                smokingTypeOfSmokeRow.hidden = @(1);
                smokingNumSticksQRow.hidden = @(1);
                smokingNumSticksRow.hidden = @(1);
                smokeAfterWakingQRow.hidden = @(1);
                smokeAfterWakingRow.hidden = @(1);
                smokingRefrainQRow.hidden = @(1);
                smokingRefrainRow.hidden = @(1);
                smokingWhichNotGiveUpQRow.hidden = @(1);
                smokingWhichNotGiveUpRow.hidden = @(1);
                smokingMornFreqQRow.hidden = @(1);
                smokingMornFreqRow.hidden = @(1);
                smokingSickInBedQRow.hidden = @(1);
                smokingSickInBedRow.hidden = @(1);
                smokingAttemptedQuitQRow.hidden = @(1);
                smokingAttemptedQuitRow.hidden = @(1);
                smokingNumQuitAttemptsQRow.hidden = @(1);
                smokingNumQuitAttemptsRow.hidden = @(1);
                smokingIntentionsToCutQRow.hidden = @(1);
                smokingIntentionsToCutRow.hidden = @(1);
                smokingHowQuitQRow.hidden = @(1);
                smokingHowQuitRow.hidden = @(1);
                smokingHowQuitOthersRow.hidden = @(1);
                smokingWhyQuitQRow.hidden = @(1);
                smokingWhyQuitRow.hidden = @(1);
                smokingWhyQuitOthersRow.hidden = @(1);
            }
        }
    };
    
    // Alcohol - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Alcohol"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFourteen
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How often do you consume alcohol?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholHowOften
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@">4 days a week"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"1-4 days a week"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"<3 days a month"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Not drinking"]];
    //value
    options = row.selectorOptions;
    if (![[riskFactorsDict objectForKey:kAlcoholHowOften]isEqualToString:@""]) {
        row.value = [options objectAtIndex:[[riskFactorsDict objectForKey:kAlcoholHowOften] integerValue]];
    }
    row.noValueDisplayText = @"Tap here for options";
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If drinking, how many years have you been drinking for?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholNumYears rowType:XLFormRowDescriptorTypeNumber title:@"Year(s)"];
    row.value = [riskFactorsDict objectForKey:kAlcoholNumYears];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you consumed 5 or more drinks (male) or 4 or more drinks (female) in any one drinking session in the past month? (1 alcoholic drink refers to 1 can/small bottle of beer or one glass of wine)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholConsumpn rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (![[riskFactorsDict objectForKey:kAlcoholConsumpn] isEqualToString:@""]) {
        row.value = [[riskFactorsDict objectForKey:kAlcoholConsumpn] isEqualToString:@"1"]? @"YES":@"NO";
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"What is your preferred alcoholic drink? (choose only one)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholPreference
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Beer"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Wine"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Rice Wine"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Spirits"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Stout"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"No preference"]];

    //value
    options = row.selectorOptions;
    if ([self getAlcoholPrefFromIndivValues] < 6) {     //if no value, return 10
        row.value = [options objectAtIndex:[self getAlcoholPrefFromIndivValues]];
    }
    row.noValueDisplayText = @"Tap here for options";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"What are your intentions towards quitting/cutting down in the forseeable future?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholIntentToCut
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I plan to quit in the next 12 months"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I plan to quit, but not within the next 12 months"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I do not plan to quit, but I intend to cut down"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I do not plan to quit or cut down"]];
    
    //value
    options = row.selectorOptions;
    if (![[riskFactorsDict objectForKey:kAlcoholIntentToCut]isEqualToString:@""]) {
        row.value = [options objectAtIndex:[[riskFactorsDict objectForKey:kAlcoholIntentToCut] integerValue]];
    }
    row.noValueDisplayText = @"Tap here for options";
    
    [section addFormRow:row];
    
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

    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Doctor's Notes"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
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

- (id) initHealthEducation {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Health Education"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    preEdSection = [XLFormSectionDescriptor formSectionWithTitle:@"Pre-education Knowledge Quiz"];
    [formDescriptor addFormSection:preEdSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu1 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person always knows when they have heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu2 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If you have a family history of heart disease, you are at risk for developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu3 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"The older a person is, the greater their risk of having heart disease "];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu4 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Smoking is a risk factor for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu5 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person who stops smoking will lower their risk of developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu6 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"High blood pressure is a risk factor for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu7 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Keeping blood pressure under control will reduce a person’s risk for developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu8 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"High cholesterol is a risk factor for developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu9 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Eating fatty foods does not affect blood cholesterol levels"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu10 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If your ‘good’ cholesterol (HDL) is high you are at risk for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu11 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If your ‘bad’ cholesterol (LDL) is high you are at risk for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu12 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Being overweight increases a person’s risk for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu13 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Regular physical activity will lower a person’s chance of getting heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu14 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Only exercising at a gym or in an exercise class will lower a person’s chance of developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu15 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Walking is considered exercise that will help lower a person’s chance of developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu16 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Diabetes is a risk factor for developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu17 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"High blood sugar puts a strain on the heart"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu18 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If your blood sugar is high over several months it can cause your cholesterol level to go up and increase your risk of heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu19 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their blood sugar levels under control"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu20 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"People with diabetes rarely have high cholesterol"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu21 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If a person has diabetes, keeping their cholesterol under control will help to lower their chance of developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu22 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"People with diabetes tend to have low HDL (good) cholesterol"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu23 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their blood pressure under control"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu24 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their weight under control"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [preEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu25 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Men with diabetes have a higher risk of heart disease than women with diabetes "];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu1 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person always knows when they have heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu2 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If you have a family history of heart disease, you are at risk for developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu3 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"The older a person is, the greater their risk of having heart disease "];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu4 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Smoking is a risk factor for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu5 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person who stops smoking will lower their risk of developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu6 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"High blood pressure is a risk factor for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu7 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Keeping blood pressure under control will reduce a person’s risk for developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu8 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"High cholesterol is a risk factor for developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu9 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Eating fatty foods does not affect blood cholesterol levels"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu10 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If your ‘good’ cholesterol (HDL) is high you are at risk for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu11 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If your ‘bad’ cholesterol (LDL) is high you are at risk for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu12 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Being overweight increases a person’s risk for heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu13 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Regular physical activity will lower a person’s chance of getting heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu14 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Only exercising at a gym or in an exercise class will lower a person’s chance of developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu15 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Walking is considered exercise that will help lower a person’s chance of developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu16 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Diabetes is a risk factor for developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu17 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"High blood sugar puts a strain on the heart"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu18 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If your blood sugar is high over several months it can cause your cholesterol level to go up and increase your risk of heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu19 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their blood sugar levels under control"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu20 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"People with diabetes rarely have high cholesterol"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu21 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"If a person has diabetes, keeping their cholesterol under control will help to lower their chance of developing heart disease"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu22 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"People with diabetes tend to have low HDL (good) cholesterol"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu23 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their blood pressure under control"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu24 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"A person who has diabetes can reduce their risk of developing heart disease if they keep their weight under control"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [postEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEdu25 rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Men with diabetes have a higher risk of heart disease than women with diabetes "];
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
        case 3: [self saveScreeningOfRiskFactors];
            break;
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

- (void) saveScreeningOfRiskFactors {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *risk_factors = [[self.fullScreeningForm objectForKey:@"risk_factors"] mutableCopy];
                                         
    //resident_id again
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kExYesNo] forKey:kExYesNo];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kExNoWhy] forKey:kExNoWhy];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kExNoOthers] forKey:kExNoOthers];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSmoking] forKey:kSmoking];

    NSArray *smokingTypes = [fields objectForKey:kTypeOfSmoke];
    if ((smokingTypes != (id)[NSNull null]) && smokingTypes) {
        for(int i=0; i<[smokingTypes count]; i++) {
            if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Cigarettes"]) [risk_factors setObject:@"1" forKey:@"ciggs"];
            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Pipe"]) [risk_factors setObject:@"1" forKey:@"pipe"];
            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Self-rolled leaves \"ang hoon\""]) [risk_factors setObject:@"1" forKey:@"rolled_leaves"];
            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Shisha"]) [risk_factors setObject:@"1" forKey:@"shisha"];
            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Cigars"]) [risk_factors setObject:@"1" forKey:@"cigars"];
            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"E-cigarettes"]) [risk_factors setObject:@"1" forKey:@"e_ciggs"];
            else if ([[smokingTypes objectAtIndex:i] isEqualToString:@"Others"]) [risk_factors setObject:@"1" forKey:@"others"];
        }
    }
    
//    ciggs, pipe, rolled_leaves, shisha, cigars, e_ciggs, others
//    @"Cigarettes", @"Pipe", @"self-rolled leaves \"ang hoon\"", @"Shisha", @"Cigars", @"E-cigarettes", @"Others"
    
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kSmokingNumYears] forKey:kSmokingNumYears];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kSmokeNumSticks] forKey:kSmokeNumSticks];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSmokeAfterWaking] forKey:kSmokeAfterWaking];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSmokingRefrain] forKey:kSmokingRefrain];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSmokingWhichNotGiveUp] forKey:kSmokingWhichNotGiveUp];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSmokingMornFreq] forKey:kSmokingMornFreq];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSmokingSickInBed] forKey:kSmokingSickInBed];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSmokingAttemptedQuit] forKey:kSmokingAttemptedQuit];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kSmokingNumQuitAttempts] forKey:kSmokingNumQuitAttempts];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSmokingIntentionsToCut] forKey:kSmokingIntentionsToCut];
    
    [risk_factors setObject:@"0" forKey:@"smoking_how_by_myself"];
    [risk_factors setObject:@"0" forKey:@"smoking_how_join_cessation"];
    [risk_factors setObject:@"0" forKey:@"smoking_how_take_med"];
    [risk_factors setObject:@"0" forKey:@"smoking_how_encourage"];
    
    if ([[fields objectForKey:kSmokingHowQuit] count]!=0) {
        NSArray *smokingHowQuitArray = [fields objectForKey:kSmokingHowQuit];
        for (int i=0; i<[smokingHowQuitArray count]; i++) {
            if([[[smokingHowQuitArray objectAtIndex:i] formValue] isEqual:@(0)]) [risk_factors setObject:@"1" forKey:@"smoking_how_by_myself"];
            else if([[[smokingHowQuitArray objectAtIndex:i] formValue] isEqual:@(1)]) [risk_factors setObject:@"1" forKey:@"smoking_how_join_cessation"];
            else if([[[smokingHowQuitArray objectAtIndex:i] formValue] isEqual:@(2)]) [risk_factors setObject:@"1" forKey:@"smoking_how_take_med"];
            else if([[[smokingHowQuitArray objectAtIndex:i] formValue] isEqual:@(3)]) [risk_factors setObject:@"1" forKey:@"smoking_how_encourage"];
        }
    }
    
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSmokingHowQuitOthers] forKey:kSmokingHowQuitOthers];
    
    [risk_factors setObject:@"0" forKey:@"smoking_why_health"];
    [risk_factors setObject:@"0" forKey:@"smoking_why_side"];
    [risk_factors setObject:@"0" forKey:@"smoking_why_harm"];
    [risk_factors setObject:@"0" forKey:@"smoking_why_advice"];
    [risk_factors setObject:@"0" forKey:@"smoking_why_ex"];
    
    
    if ([[fields objectForKey:kSmokingWhyQuit] count]!=0) {
        NSArray *smokingWhyQuitArray = [fields objectForKey:kSmokingWhyQuit];
        for (int i=0; i<[smokingWhyQuitArray count]; i++) {
            if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(0)]) [risk_factors setObject:@"1" forKey:@"smoking_why_health"];
            else if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(1)]) [risk_factors setObject:@"1" forKey:@"smoking_why_side"];
            else if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(2)]) [risk_factors setObject:@"1" forKey:@"smoking_why_harm"];
            else if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(3)]) [risk_factors setObject:@"1" forKey:@"smoking_why_advice"];
            else if([[[smokingWhyQuitArray objectAtIndex:i] formValue] isEqual:@(4)]) [risk_factors setObject:@"1" forKey:@"smoking_why_ex"];
        }
    }

    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSmokingWhyQuitOthers] forKey:kSmokingWhyQuitOthers];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kAlcoholHowOften] forKey:kAlcoholHowOften];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kAlcoholNumYears] forKey:kAlcoholNumYears];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kAlcoholConsumpn] forKey:kAlcoholConsumpn];
    
    NSString *alcoholPreference = [self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kAlcoholPreference];
    
    //reset all values first
    [risk_factors setObject:@"0" forKey:@"beer"];
    [risk_factors setObject:@"0" forKey:@"wine"];
    [risk_factors setObject:@"0" forKey:@"rice_wine"];
    [risk_factors setObject:@"0" forKey:@"spirits"];
    [risk_factors setObject:@"0" forKey:@"stout"];
    [risk_factors setObject:@"0" forKey:@"no_pref"];
    
    if ([alcoholPreference isEqualToString:@"0"]) [risk_factors setObject:@"1" forKey:@"beer"];
    else if ([alcoholPreference isEqualToString:@"1"]) [risk_factors setObject:@"1" forKey:@"wine"];
    else if ([alcoholPreference isEqualToString:@"2"]) [risk_factors setObject:@"1" forKey:@"rice_wine"];
    else if ([alcoholPreference isEqualToString:@"3"]) [risk_factors setObject:@"1" forKey:@"spirits"];
    else if ([alcoholPreference isEqualToString:@"4"]) [risk_factors setObject:@"1" forKey:@"stout"];
    else if ([alcoholPreference isEqualToString:@"5"]) [risk_factors setObject:@"1" forKey:@"no_pref"];
    
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kAlcoholIntentToCut] forKey:kAlcoholIntentToCut];
    
    [self.fullScreeningForm setObject:risk_factors forKey:@"risk_factors"];
    
}


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
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"needSERI"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"needSERI"];
    }
}

- (void) calculateScore: (XLFormRowDescriptor *)sender {
    
    NSDictionary *dict = [self.form formValues];
    int score, eachAns, count;
    NSNumber *ans;
    score = count = 0;
    for (NSString *key in dict) {
        if (![key isEqualToString:kPreEdScore] && ![key isEqualToString:kPostEdScore] && ![key isEqualToString:@"preEdScoreButton"] && ![key isEqualToString:@"postEdScoreButton"]) {
            //prevent null cases
            if (dict[key] != [NSNull null])
                ans = dict[key];
            else
                ans = @0;
            
            eachAns = [ans intValue];
            score = score + eachAns;
            count++;
        }
    }
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

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


//NSString *const kBpSystolic = @"bp_systolic";
//NSString *const kBpDiastolic = @"bp_diastolic";
//NSString *const kWeight = @"weight";
//NSString *const kHeight = @"height";
//NSString *const kBMI = @"bmi";
//NSString *const kWaistCircum = @"waist_circum";
//NSString *const kHipCircum = @"hip_circum";
//NSString *const kWaistHipRatio = @"waist_hip_ratio";
//NSString *const kCbg = @"cbg";
//NSString *const kBpSystolic2 = @"bp_systolic2";
//NSString *const kBpDiastolic2 = @"bp_diastolic2";
//NSString *const kBpSystolicAvg = @"bp_systolic_avg";
//NSString *const kBpDiastolicAvg = @"bp_diastolic_avg";
//NSString *const kBpSystolic3 = @"bp_systolic3";
//NSString *const kBpDiastolic3 = @"bp_diastolic3";

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

// Diabetes Mellitus
//NSString *const kDiabetesHasInformed = @"diabetes_has_informed";
//NSString *const kDiabetesCheckedBlood = @"diabetes_checked_blood";
//NSString *const kDiabetesSeeingDocRegularly = @"diabetes_seeing_doc_regularly";
//NSString *const kDiabetesCurrentlyPrescribed = @"diabetes_currently_prescribed";
//NSString *const kDiabetesTakingRegularly = @"diabetes_taking_regularly";

//Hyperlipidemia
//NSString *const kLipidHasInformed = @"lipid_has_informed";
//NSString *const kLipidCheckedBlood = @"lipid_checked_blood";
//NSString *const kLipidSeeingDocRegularly = @"lipid_seeing_doc_regularly";
//NSString *const kLipidCurrentlyPrescribed = @"lipid_currently_prescribed";
//NSString *const kLipidTakingRegularly = @"lipid_taking_regularly";
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


//HyperTension
//NSString *const kHTHasInformed = @"tension_has_informed";
//NSString *const kHTCheckedBP = @"tension_checked_blood";
//NSString *const kHTSeeingDocRegularly = @"tension_seeing_doc_regularly";
//NSString *const kHTCurrentlyPrescribed = @"tension_currently_prescribed";
//NSString *const kHTTakingRegularly = @"tension_taking_regularly";

//Cancer Screening
NSString *const kMultiCancerDiagnosed = @"multi_cancer_diagnosed";
NSString *const kPapSmear = @"pap_smear";
NSString *const kMammogram = @"mammogram";
NSString *const kFobt = @"fobt";

//Other Medical Issues
NSString *const kHeartAttack = @"heart_attack";
NSString *const kHeartFailure = @"heart_failure";
NSString *const kCopd = @"copd";
NSString *const kAsthma = @"asthma";
NSString *const kStroke = @"stroke";
NSString *const kDementia = @"dementia";
NSString *const kHemiplegia = @"hemiplegia";
NSString *const kSolidOrganCancer = @"solid_organ_cancer";
NSString *const kBloodCancer = @"blood_cancer";
NSString *const kMetastaticCancer = @"metastatic_cancer";
NSString *const kDiabetesWODamage = @"diabetes_wo_damage";
NSString *const kDiabetesWDamage = @"diabetes_w_damage";
NSString *const kKidneyFailure = @"kidney_failure";
NSString *const kPepticUlcer = @"peptic_ulcer";
NSString *const kMildLiver = @"mild_liver";
NSString *const kModerateSevereLiver = @"moderate_severe_liver";
NSString *const kVascularDisease = @"vascular_disease";
NSString *const kTissueDisease = @"tissue_disease";
NSString *const kOsteoarthritis = @"osteoarthritis";
NSString *const kAids = @"aids";
NSString *const kOtherMedIssues = @"other_medical_issues";
NSString *const kNA = @"NA";
NSString *const kPain = @"pain";
NSString *const kPainDuration = @"pain_duration";
NSString *const kAnxiety = @"anxiety";


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

//Current Socioeconomic Situation
NSString *const kMultiPlan = @"multi_plan";
NSString *const kCPFAmt = @"cpf_amt";
NSString *const kChasColour = @"chas_colour";
NSString *const kHouseCoping = @"house_coping";
NSString *const kHouseCopingReason = @"house_coping_reason";
NSString *const kHouseCopingReasonOthers = @"house_coping_reason_others";
NSString *const kEmployStatus = @"employ_status";
NSString *const kEmployStatusOthers = @"employ_status_others";
NSString *const kManageExpenses = @"manage_expenses";
NSString *const kHouseholdIncome = @"household_income";
NSString *const kPplInHouse = @"ppl_in_house";
NSString *const kAnyAssist = @"any_assist";
NSString *const kSeekHelp = @"seek_help";
NSString *const kHelpType = @"help_type";
NSString *const kHelpOrg = @"help_org";
NSString *const kHelpDescribe = @"help_describe";
NSString *const kHelpAmt = @"help_amt";
NSString *const kHelpPeriod = @"help_period";
NSString *const kHelpHelpful = @"help_helpful";

//Social Support Assessment
//NSString *const kHasCaregiver = @"has_caregiver";
//NSString *const kCaregiverName = @"caregiver_name";
//NSString *const kCaregiverRs = @"caregiver_rs";
//NSString *const kCaregiverContactNum = @"caregiver_contact_num";
//NSString *const kCaregiverNric = @"caregiver_nric";
//NSString *const kCaregiverAddress = @"caregiver_address";
//NSString *const kEContact = @"e_contact";
//NSString *const kEContactName = @"e_contact_name";
//NSString *const kEContactRs = @"e_contact_rs";
//NSString *const kEContactNum = @"e_contact_num";
//NSString *const kEContactNric = @"e_contact_nric";
//NSString *const kEContactAddress = @"e_contact_address";
//NSString *const kGettingSupport = @"getting_support";
//NSString *const kMultiSupport = @"multi_support";
//NSString *const kSupportOthers = @"support_others";
//NSString *const kRelativesContact = @"relatives_contact";
//NSString *const kRelativesEase = @"relatives_ease";
//NSString *const kRelativesClose = @"relatives_close";
//NSString *const kFriendsContact = @"friends_contact";
//NSString *const kFriendsEase = @"friends_ease";
//NSString *const kFriendsClose = @"friends_close";
//NSString *const kSocialScore = @"social_score";
//NSString *const kLackCompan = @"lack_compan";
//NSString *const kFeelLeftOut = @"feel_left_out";
//NSString *const kFeelIsolated = @"feel_isolated";
//NSString *const kAwareActivities = @"aware_activities";
//NSString *const kParticipateActivities = @"participate_activities";
//NSString *const kMultiHost = @"multi_host";
//NSString *const kHostOthers = @"host_others";

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
    XLFormRowDescriptor *relativesContactRow, *relativesEaseRow, *relativesCloseRow, *friendsContactRow, *friendsEaseRow, *friendsCloseRow, *socialScoreRow;
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
//        case 7: form = [self initCancerScreening];
//            break;
//        case 8: form = [self initOtherMedicalIssues];
//            break;
//        case 9: form = [self initPrimaryCareSource];
//            break;
////        case 10: form = [self initMyHealthAndMyNeighbourhood];
////            break;
//        case 11: form = [self initDemographics];
//            break;
//        case 12: form = [self initCurrentPhysicalIssues];
//            break;
//        case 13: form = [self initCurrentSocioSituation];
//            break;
//        case 14: form = [self initSocialSupportAssessment];
//            break;
//        case 15: form = [self initRefForDoctorConsult];
//            break;
}
    NSLog(@"%@", [form class]);
    
    NSLog(@"Form type: %@", self.formType);
    
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kScreenMode rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Pick one *"];
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

    XLFormRowDescriptor *noOfPplInHouse = [XLFormRowDescriptor formRowDescriptorWithTag:kPplInHouse rowType:XLFormRowDescriptorTypeNumber title:@"No. of people in the household"];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPapSmear rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does resident want a free pap smear referral?"];
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

//
//- (id) initClinicalResults {
//    
//    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Clinical Results"];
//    XLFormSectionDescriptor * section;
//    XLFormRowDescriptor * row;
//    NSDictionary *clinicalResultsDict = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"clinical_results"];
//    NSArray *bpRecordsArray = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"bp_record"];
////    
////    if ([_formType integerValue] == ViewScreenedScreeningForm) {
////        [formDescriptor setDisabled:YES];
////    }
//    
//    
//    formDescriptor.assignFirstResponderOnShow = YES;
//    
//    // Basic Information - Section
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:section];
//    
//    XLFormRowDescriptor *systolic_1;
//    systolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic rowType:XLFormRowDescriptorTypeNumber title:@"BP (1. Systolic number) *"];
//    systolic_1.required = YES;
//    systolic_1.value = [[bpRecordsArray objectAtIndex:1] objectForKey:@"systolic_bp"];
//    [section addFormRow:systolic_1];
//    
//    XLFormRowDescriptor *diastolic_1;
//    diastolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic rowType:XLFormRowDescriptorTypeNumber title:@"BP (2. Diastolic number) *"];
//    diastolic_1.required = YES;
//    diastolic_1.value = [[bpRecordsArray objectAtIndex:1] objectForKey:@"diastolic_bp"];
//    [section addFormRow:diastolic_1];
//    
//    XLFormRowDescriptor *height;
//    height = [XLFormRowDescriptor formRowDescriptorWithTag:kHeight rowType:XLFormRowDescriptorTypeNumber title:@"Height (cm) *"];
//    height.required = YES;
//    height.value = [clinicalResultsDict objectForKey:@"height_cm"];
//    [section addFormRow:height];
//    
//    XLFormRowDescriptor *weight;
//    weight = [XLFormRowDescriptor formRowDescriptorWithTag:kWeight rowType:XLFormRowDescriptorTypeNumber title:@"Weight (kg) *"];
//    weight.required = YES;
//    weight.value = [clinicalResultsDict objectForKey:@"weight_kg"];
//    [section addFormRow:weight];
//    
//    XLFormRowDescriptor *bmi;
//    bmi = [XLFormRowDescriptor formRowDescriptorWithTag:kBMI rowType:XLFormRowDescriptorTypeText title:@"BMI"];
////    bmi.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kHeight, kWeight]];
//    //Initial value only
//    if ([clinicalResultsDict objectForKey:@"bmi"] != [NSNull null]) {
//        if (![[clinicalResultsDict objectForKey:@"bmi"] isEqualToString:@""]) {
//            bmi.value = [clinicalResultsDict objectForKey:@"bmi"];
//        } else {
//            if (!isnan([weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2))) {  //check for not nan first!
//                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
//            }
//        }
//    }
//    bmi.disabled = @(1);
//    [section addFormRow:bmi];
//    
//    weight.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([weight.value integerValue] != 0 && [height.value integerValue] != 0) {
//                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
//                [self updateFormRow:bmi];
//            }
//        }
//    };
//    height.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([weight.value integerValue] != 0 && [height.value integerValue] != 0) {
//                bmi.value = [NSString stringWithFormat:@"%.2f", [weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2)];
//                [self updateFormRow:bmi];
//            }
//        }
//    };
//    
//    XLFormRowDescriptor *waist;
//    waist = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistCircum rowType:XLFormRowDescriptorTypeNumber title:@"Waist Circumference (cm) *"];
//    waist.required = YES;
//    waist.value = [clinicalResultsDict objectForKey:@"waist_circum"];
//    [section addFormRow:waist];
//    
//    XLFormRowDescriptor *hip;
//    hip = [XLFormRowDescriptor formRowDescriptorWithTag:kHipCircum rowType:XLFormRowDescriptorTypeNumber title:@"Hip Circumference (cm) *"];
//    hip.required = YES;
//    hip.value = [clinicalResultsDict objectForKey:@"hip_circum"];
//    [section addFormRow:hip];
//    
//    XLFormRowDescriptor *waistHipRatio;
//    waistHipRatio = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistHipRatio rowType:XLFormRowDescriptorTypeText title:@"Waist : Hip Ratio"];
//    waistHipRatio.required = YES;
////    waistHipRatio.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kWaistCircum, kHipCircum]];
//    //Initial value
//    if(![[clinicalResultsDict objectForKey:@"waist_hip_ratio"] isEqualToString:@""]) {
//        waistHipRatio.value = [clinicalResultsDict objectForKey:@"waist_hip_ratio"];
//    }
//    waistHipRatio.disabled = @(1);
//    [section addFormRow:waistHipRatio];
//    
//    waist.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([waist.value integerValue] != 0 && [hip.value integerValue] != 0) {
//                waistHipRatio.value = [NSString stringWithFormat:@"%.2f", [waist.value doubleValue] / [hip.value doubleValue]];
//                [self updateFormRow:waistHipRatio];
//            }
//        }
//    };
//    hip.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([waist.value integerValue] != 0 && [hip.value integerValue] != 0) {
//                waistHipRatio.value = [NSString stringWithFormat:@"%.2f", [waist.value doubleValue] / [hip.value doubleValue]];
//                [self updateFormRow:waistHipRatio];
//            }
//        }
//    };
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCbg rowType:XLFormRowDescriptorTypeText title:@"CBG *"];
//    row.required = YES;
//    row.value = [clinicalResultsDict objectForKey:@"cbg"];
//    [section addFormRow:row];
//    
//    XLFormRowDescriptor *systolic_2;
//    systolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic2 rowType:XLFormRowDescriptorTypeNumber title:@"BP Taking (2nd Systolic) *"];
//    systolic_2.required = YES;
//    systolic_2.value = [[bpRecordsArray objectAtIndex:2] objectForKey:@"systolic_bp"];
//    [section addFormRow:systolic_2];
//    
//    XLFormRowDescriptor *diastolic_2;
//    diastolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic2 rowType:XLFormRowDescriptorTypeNumber title:@"BP Taking (2nd Diastolic) *"];
//    diastolic_2.required = YES;
//    diastolic_2.value = [[bpRecordsArray objectAtIndex:2] objectForKey:@"diastolic_bp"];
//    [section addFormRow:diastolic_2];
//    
//    XLFormRowDescriptor *systolic_avg;
//    systolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolicAvg rowType:XLFormRowDescriptorTypeText title:@"BP (Avg. of 1st & 2nd systolic)"];
//    systolic_avg.required = YES;
//    if (![[[bpRecordsArray objectAtIndex:0] objectForKey:@"systolic_bp"] isEqualToString:@""]) {
//        systolic_avg.value = [[bpRecordsArray objectAtIndex:0] objectForKey:@"systolic_bp"];
//    }
////    systolic_avg.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kBpSystolic, kBpSystolic2]];
//    systolic_avg.disabled = @(1);   //permanent
//    [section addFormRow:systolic_avg];
//    
//    systolic_1.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if ( oldValue != newValue) {
//            systolic_avg.value = @(([systolic_1.value doubleValue]+ [systolic_2.value doubleValue])/2);
//            [self updateFormRow:systolic_avg];
//        }
//        
//    };
//    
//    systolic_2.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if ( oldValue != newValue) {
//            systolic_avg.value = @(([systolic_1.value doubleValue]+ [systolic_2.value doubleValue])/2);
//            [self updateFormRow:systolic_avg];
//        }
//        
//    };
//    
//    XLFormRowDescriptor *diastolic_avg;
//    diastolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolicAvg rowType:XLFormRowDescriptorTypeText title:@"BP (Avg. of 1st & 2nd diastolic) *"];
//    diastolic_avg.required = YES;
//    if (![[[bpRecordsArray objectAtIndex:0] objectForKey:@"diastolic_bp"] isEqualToString:@""]) {
//        diastolic_avg.value = [[bpRecordsArray objectAtIndex:0] objectForKey:@"diastolic_bp"];
//    }
//    diastolic_avg.disabled = @(1);
//    [section addFormRow:diastolic_avg];
//    
////    diastolic_avg.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kBpDiastolic, kBpDiastolic2]];        //somehow must disable first ... @.@"
//    
//    diastolic_1.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if ( oldValue != newValue) {
//            diastolic_avg.value = @(([diastolic_1.value integerValue]+ [diastolic_2.value integerValue])/2);
//            [self updateFormRow:diastolic_avg];
//        }
//    };
//    
//    diastolic_2.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if ( oldValue != newValue) {
//            diastolic_avg.value = @(([diastolic_1.value integerValue]+ [diastolic_2.value integerValue])/2);
//            [self updateFormRow:diastolic_avg];
//        }
//    };
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic3 rowType:XLFormRowDescriptorTypeNumber title:@"BP Taking (3rd Systolic)"];
//    row.required = NO;
//    [row.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
//    row.value = [[bpRecordsArray objectAtIndex:3] objectForKey:@"systolic_bp"];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic3 rowType:XLFormRowDescriptorTypeNumber title:@"BP Taking (3rd Diastolic)"];
//    [row.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
//    row.required = NO;
//    row.value = [[bpRecordsArray objectAtIndex:3] objectForKey:@"diastolic_bp"];
//    [section addFormRow:row];
//    
//    return [super initWithForm:formDescriptor];
//    
//}

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



-(id) initCancerScreening {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Cancer Screening"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *cancerScreenDict = [self.fullScreeningForm objectForKey:@"cancer"];
    
    formDescriptor.assignFirstResponderOnShow = YES;

    
    // Introduction - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Note:"];
    section.footerTitle = @"Do note the screening criteria below to avoid embarrassment (e.g. asking a male resident about his Pap smear)";
    [formDescriptor addFormSection:section];
    
    // Cancer Screening - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you ever been diagnosed with any of these cancers? (tick all that apply)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiCancerDiagnosed rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    row.selectorOptions = @[@"Cervical (子宫颈癌)", @"Breast (乳腺癌)", @"Colorectal (大肠癌)"];
    //value
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([[cancerScreenDict objectForKey:@"cervical"] isEqualToString:@"1"]) [array addObject:@"Cervical (子宫颈癌)"];
    if ([[cancerScreenDict objectForKey:@"breast"] isEqualToString:@"1"]) [array addObject:@"Breast (乳腺癌)"];
    if ([[cancerScreenDict objectForKey:@"colorectal"] isEqualToString:@"1"]) [array addObject:@"Colorectal (大肠癌)"];
    row.value = array;
    row.noValueDisplayText = @"Tap here for options";
    [section addFormRow:row];
    

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Do you go for a pap smear regularly? (once every 3 years for sexually active ladies ≤ 69 years old)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPapSmear rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO", @"N.A."];
    
    //value
    if (![[cancerScreenDict objectForKey:kPapSmear] isEqualToString:@""]) {
        if ([[cancerScreenDict objectForKey:kPapSmear] isEqualToString:@"1"]) row.value = @"YES";
        else if ([[cancerScreenDict objectForKey:kPapSmear] isEqualToString:@"0"]) row.value = @"NO";
        else if ([[cancerScreenDict objectForKey:kPapSmear] isEqualToString:@"2"]) row.value = @"N.A.";
    }
    
    
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Do you go for regular mammograms? (Once every 2 years for ladies aged 40-49; yearly for ladies ≥ 50)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMammogram rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO", @"N.A."];
    
    //value
    if (![[cancerScreenDict objectForKey:kMammogram] isEqualToString:@""]) {
        if ([[cancerScreenDict objectForKey:kMammogram] isEqualToString:@"1"]) row.value = @"YES";
        else if ([[cancerScreenDict objectForKey:kMammogram] isEqualToString:@"0"]) row.value = @"NO";
        else if ([[cancerScreenDict objectForKey:kMammogram] isEqualToString:@"2"]) row.value = @"N.A.";
    }
    
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Do you go for FOBT regularly? (once a year for ≥ 50)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFobt rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO", @"N.A."];
    
    //value
    if (![[cancerScreenDict objectForKey:kFobt] isEqualToString:@""]) {
        if ([[cancerScreenDict objectForKey:kFobt] isEqualToString:@"1"]) row.value = @"YES";
        else if ([[cancerScreenDict objectForKey:kFobt] isEqualToString:@"0"]) row.value = @"NO";
        else if ([[cancerScreenDict objectForKey:kFobt] isEqualToString:@"2"]) row.value = @"N.A.";
    }
    
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

-(id) initOtherMedicalIssues {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Other Medical Issues"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *otherMedIssuesDict = [self.fullScreeningForm objectForKey:@"others"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Introduction - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Introduction"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Charlson Comorbidity Index. Ask the resident, \"what medical conditions do you have?\". Compare against the list below and tick the condition if present. You can tick more than 1 box."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    // Heart - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Heart"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHeartAttack rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Heart Attack (心脏发作)"];
    [section addFormRow:row];
    //value
    row.value = [otherMedIssuesDict objectForKey:kHeartAttack];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHeartFailure rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Heart Failure (心脏病)"];
    
    //value
    row.value = [otherMedIssuesDict objectForKey:kHeartFailure];
    [section addFormRow:row];
    
    // Lung - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Lung"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCopd rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Chronic Pulmonary Disease (COPD) (慢性肺部疾病)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //value
    row.value = [otherMedIssuesDict objectForKey:kCopd];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAsthma rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Asthma (气喘)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kAsthma];
    [section addFormRow:row];
    
    // Brain - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Brain"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kStroke rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Stroke (脑中风)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kStroke];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDementia rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dementia (老人痴呆症)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kDementia];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHemiplegia rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Hemiplegia (偏痴)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kHemiplegia];
    [section addFormRow:row];
    
    // Cancer - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Cancer"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSolidOrganCancer rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Solid organ cancer (实体器官癌症)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kSolidOrganCancer];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBloodCancer rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Blood cancer (eg. Leukemia/Lymphoma) (血症)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kBloodCancer];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMetastaticCancer rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Metastatic cancer (转移癌)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kMetastaticCancer];
    [section addFormRow:row];
    
    // DM and Renal - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Diabetes and Renal"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesWODamage rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Diabetes, without end-organ damage (eg. retinopathy, kidney problems, heart problems, amputation, strokes) (糖尿病－无器官受损）"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //value
    row.value = [otherMedIssuesDict objectForKey:kDiabetesWODamage];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesWDamage rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Diabetes, with end organ damage (糖尿病－有器官受损)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //value
    row.value = [otherMedIssuesDict objectForKey:kDiabetesWDamage];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKidneyFailure rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Kidney failure (肾功能衰竭)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kKidneyFailure];
    [section addFormRow:row];
    
    // Gut and Liver - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Gut and Liver"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPepticUlcer rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Peptic Ulcer Disease (消化性溃疡病)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kPepticUlcer];
    [section addFormRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMildLiver rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Mild Liver Disease (肝病)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kMildLiver];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kModerateSevereLiver rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Moderate-to-severe liver disease (has jaundice or ascites) (严重肝病)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //value
    row.value = [otherMedIssuesDict objectForKey:@"liver_disease"];
    [section addFormRow:row];
    
    // Misc - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Misc"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVascularDisease rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Peripheral Vascular Disease (血管疾病)"];
    //value
    row.value = [otherMedIssuesDict objectForKey:kVascularDisease];
    [section addFormRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTissueDisease rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Connective Tissue Disease (eg.Rheumatoid Arthritis (风湿关节炎)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //value
    row.value = [otherMedIssuesDict objectForKey:kTissueDisease];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOsteoarthritis rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Osteoarthritis (骨性关节炎)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //value
    row.value = [otherMedIssuesDict objectForKey:kOsteoarthritis];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAids rowType:XLFormRowDescriptorTypeBooleanCheck title:@"AIDS (爱滋病)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //value
    row.value = [otherMedIssuesDict objectForKey:kAids];
    [section addFormRow:row];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive rowType:XLFormRowDescriptorTypeInfo title:@"Other medical conditions:"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    
//    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOtherMedIssues rowType:XLFormRowDescriptorTypeTextView title:@""];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@"Other medical conditions:(specify)" forKey:@"textView.placeholder"];
    //value
    row.value = [otherMedIssuesDict objectForKey:@"others"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNA rowType:XLFormRowDescriptorTypeBooleanCheck title:@"N.A."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //value
    row.value = [otherMedIssuesDict objectForKey:@"NA"];
    [section addFormRow:row];
    
    // Pain and Anxiety - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"If resident selects any of the Extreme options, please refer them for doctor's consult.";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSix rowType:XLFormRowDescriptorTypeInfo title:@"Pain / Discomfort"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *painRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPain
                                                                         rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                                           title:@""];
    painRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no pain or discomfort"],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight pain or discomfort"],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate pain or discomfort"],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I have severe pain or discomfort"],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"I have extreme pain or discomfort"]];
    //value
    NSArray *options = painRow.selectorOptions;
    if (![[otherMedIssuesDict objectForKey:kPain]isEqualToString:@""]) {
        painRow.value = [options objectAtIndex:[[otherMedIssuesDict objectForKey:kPain] integerValue]];
    }
    painRow.noValueDisplayText = @"Tap here for options";
    [section addFormRow:painRow];
    
    
    
    XLFormRowDescriptor *painDurQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"My pain has lasted ≥ 3 months)"];
    painDurQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:painDurQRow];
    
    XLFormRowDescriptor *painDurationRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPainDuration
                                                                                 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                   title:@""];
    painDurationRow.selectorOptions = @[@"YES", @"NO"];
    //value
    if (![[otherMedIssuesDict objectForKey:kPainDuration] isEqualToString:@""]) {
        painDurationRow.value = [[otherMedIssuesDict objectForKey:kPainDuration] isEqualToString:@"1"]? @"YES":@"NO";
    }
    [section addFormRow:painDurationRow];
    
    //Initial hidden state
    if([[otherMedIssuesDict objectForKey:kPain] isEqualToString:@""]) {
        painDurQRow.hidden = @(1);
        painDurationRow.hidden = @(1);
    } else {
        if ([[painRow.value formValue] isEqual:@(0)]) {
            painDurQRow.hidden = @(1);
            painDurationRow.hidden = @(1);
        } else {
            painDurQRow.hidden = @(0);
            painDurationRow.hidden = @(0);
        }
    }
    
    painRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([[newValue formValue] isEqual:@(0)]) {
                painDurQRow.hidden = @(1);  //hide
                painDurationRow.hidden = @(1);  //hide
            } else {
                painDurQRow.hidden = @(0);  //hide
                painDurationRow.hidden = @(0);  //hide
            }
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSix rowType:XLFormRowDescriptorTypeInfo title:@"Anxiety / Depression"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAnxiety
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I am not anxious or depressed"],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I am slightly anxious or depressed"],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I am moderately anxious or depressed"],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I am severely anxious or depressed"],
                                [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"I am extremely anxious or depressed"]];
    //value
    options = row.selectorOptions;
    if (![[otherMedIssuesDict objectForKey:kAnxiety]isEqualToString:@""]) {
        row.value = [options objectAtIndex:[[otherMedIssuesDict objectForKey:kAnxiety] integerValue]];
    }
    row.noValueDisplayText = @"Tap here for options";
    [section addFormRow:row];

    
    
    
    return [super initWithForm:formDescriptor];
}
//
//-(id) initPrimaryCareSource {
//    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Primary Care Source"];
//    XLFormSectionDescriptor * section;
//    XLFormRowDescriptor * row;
//    NSDictionary *primaryCareDict = [self.fullScreeningForm objectForKey:@"primary_care"];
//    
//    formDescriptor.assignFirstResponderOnShow = YES;
//    
//    
//    // Hyperlipidemia - Section
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:section];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
//                                                rowType:XLFormRowDescriptorTypeInfo
//                                                  title:@"If you were sick who would you turn to first for medical treatment/advice? (ie. who is your primary care provider?"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    
//    XLFormRowDescriptor *primaryCareSource;
//    primaryCareSource = [XLFormRowDescriptor formRowDescriptorWithTag:kCareGiverID
//                                                rowType:XLFormRowDescriptorTypeSelectorPush
//                                                  title:@""];
//    primaryCareSource.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"GP"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Polyclinic"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Hospital"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"TCM Practitioner"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Family"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Friends"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"Nobody, I rely on myself"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"Others"]];
//    //value
//    NSArray *options = primaryCareSource.selectorOptions;
//    if (![[primaryCareDict objectForKey:kCareGiverID]isEqualToString:@""]) {
//        primaryCareSource.value = [options objectAtIndex:[[primaryCareDict objectForKey:kCareGiverID] integerValue]];
//    }
//    primaryCareSource.noValueDisplayText = @"Tap here for options";
//    [section addFormRow:primaryCareSource];
//    
//    XLFormRowDescriptor *sourceOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCareGiverOthers rowType:XLFormRowDescriptorTypeText title:@""];
//    [sourceOthersRow.cellConfigAtConfigure setObject:@"If others, please state" forKey:@"textField.placeholder"];
//    sourceOthersRow.value = [primaryCareDict objectForKey:kCareGiverOthers];
//    [section addFormRow:sourceOthersRow];
//    
//    
//    //Initial hidden state
//    if([[primaryCareDict objectForKey:kCareGiverID] isEqualToString:@""]) {
//        sourceOthersRow.hidden = @(1);
//    } else {
//        if ([[primaryCareSource.value formValue] isEqual:@(7)]) {
//            sourceOthersRow.hidden = @(0);
//        } else {
//            sourceOthersRow.hidden = @(1);
//        }
//    }
//    
//    primaryCareSource.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([[newValue formValue] isEqual:@(7)]) {
//                sourceOthersRow.hidden = @(0);  //show
//            } else {
//                sourceOthersRow.hidden = @(1);  //hide
//            }
//        }
//    };
//    
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
//                                                rowType:XLFormRowDescriptorTypeInfo
//                                                  title:@"Which is your main healthcare provider for followup?"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    XLFormRowDescriptor *careProvider;
//    careProvider = [XLFormRowDescriptor formRowDescriptorWithTag:kCareProviderID
//                                                              rowType:XLFormRowDescriptorTypeSelectorPush
//                                                                title:@""];
//    careProvider.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"N.A."],
//                                          [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"GP"],
//                                          [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Polyclinic"],
//                                          [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Hospital"],
//                                          [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Free Clinic"],
//                                          [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Others"]];
//    //value
//    options = careProvider.selectorOptions;
//    if (![[primaryCareDict objectForKey:kCareProviderID]isEqualToString:@""]) {
//        careProvider.value = [options objectAtIndex:[[primaryCareDict objectForKey:kCareProviderID] integerValue]];
//    }
//    careProvider.noValueDisplayText = @"Tap here for options";
//    [section addFormRow:careProvider];
//    
//    XLFormRowDescriptor *providerOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCareProviderOthers rowType:XLFormRowDescriptorTypeText title:@""];
//    [providerOthersRow.cellConfigAtConfigure setObject:@"If others, please state" forKey:@"textField.placeholder"];
//    providerOthersRow.value = [primaryCareDict objectForKey:kCareProviderOthers];
//    [section addFormRow:providerOthersRow];
//    
//    //Initial hidden state
//    if([[primaryCareDict objectForKey:kCareProviderID] isEqualToString:@""]) {
//        providerOthersRow.hidden = @(1);
//    } else {
//        if ([[careProvider.value formValue] isEqual:@(5)]) {
//            providerOthersRow.hidden = @(0);
//        } else {
//            providerOthersRow.hidden = @(1);
//        }
//    }
//    
//    careProvider.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([[newValue formValue] isEqual:@(5)]) {
//                providerOthersRow.hidden = @(0);  //hide
//            } else {
//                providerOthersRow.hidden = @(1);  //hide
//            }
//        }
//    };
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
//                                                rowType:XLFormRowDescriptorTypeInfo
//                                                  title:@"How many times did you visit A&E in past 6 months? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAneVisit rowType:XLFormRowDescriptorTypeInteger title:@"Number of time(s)"];
//    row.required = YES;
//    row.value = [primaryCareDict objectForKey:kAneVisit];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
//                                                rowType:XLFormRowDescriptorTypeInfo
//                                                  title:@"How many times have you been hospitalized in past 1 year? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHospitalized rowType:XLFormRowDescriptorTypeInteger title:@"Number of time(s)"];
//    row.required = YES;
//    row.value = [primaryCareDict objectForKey:kHospitalized];
//    [section addFormRow:row];
//    
//    return [super initWithForm:formDescriptor];
//}

//-(id) initMyHealthAndMyNeighbourhood {
//    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"My Health & My Neighbourhood"];
//    XLFormSectionDescriptor * section;
//    XLFormRowDescriptor * row;
//    NSDictionary *healthNeighbourhoodDict = [self.fullScreeningForm objectForKey:@"self_rated"];
//    
//    formDescriptor.assignFirstResponderOnShow = YES;
//
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:section];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne rowType:XLFormRowDescriptorTypeInfo title:@"Mobility"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    
//    XLFormRowDescriptor *mobilityRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMobility
//                                                         rowType:XLFormRowDescriptorTypeSelectorActionSheet
//                                                           title:@""];
//    mobilityRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no problem in walking about"],
//                                     [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight problems in walking about"],
//                                     [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate problems in walking about"],
//                                     [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I have severe problems in walking about"],
//                                     [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"I am unable to walk about"]];
//    //value
//    NSArray *options = mobilityRow.selectorOptions;
//    if (![[healthNeighbourhoodDict objectForKey:kMobility]isEqualToString:@""]) {
//        mobilityRow.value = [options objectAtIndex:[[healthNeighbourhoodDict objectForKey:kMobility] integerValue]];
//    }
//    mobilityRow.noValueDisplayText = @"Tap here for options";
//    [section addFormRow:mobilityRow];
//    
//    XLFormRowDescriptor *mobilityAidQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"If you have difficulty walking, what mobility aid are you using?"];
//    mobilityAidQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:mobilityAidQRow];
//    XLFormRowDescriptor *mobilityAidRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityAid
//                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
//                                                  title:@""];
//    mobilityRow.noValueDisplayText = @"Tap here for options";
//    mobilityAidRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Walking stick/frame"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Wheelchair-bound"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Bedridden"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Have problems walking but do not use aids"]];
//    
//    //value
//    options = mobilityAidRow.selectorOptions;
//    if (![[healthNeighbourhoodDict objectForKey:kMobilityAid]isEqualToString:@""]) {
//        mobilityAidRow.value = [options objectAtIndex:[[healthNeighbourhoodDict objectForKey:kMobilityAid] integerValue]];
//    }
//    
//    [section addFormRow:mobilityAidRow];
//    
//    mobilityRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([[newValue formValue] isEqual:@(0)]) {
//                mobilityAidQRow.hidden = @(1);  //hide
//                mobilityAidRow.hidden = @(1);  //hide
//            } else {
//                mobilityAidQRow.hidden = @(0);  //hide
//                mobilityAidRow.hidden = @(0);  //hide
//            }
//        }
//    };
//    
//    
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree rowType:XLFormRowDescriptorTypeInfo title:@"Self-care"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSelfCare
//                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
//                                                  title:@""];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no problem washing or dressing myself"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight problems washing or dressing myself"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate problems washing or dressing myself"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"I have severe problems washing or dressing myself"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"I am unable to wash or dress myself"]];
//    row.noValueDisplayText = @"Tap here for options";
//    //value
//    options = row.selectorOptions;
//    if (![[healthNeighbourhoodDict objectForKey:kSelfCare]isEqualToString:@""]) {
//        row.value = [options objectAtIndex:[[healthNeighbourhoodDict objectForKey:kSelfCare] integerValue]];
//    }
//    
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive rowType:XLFormRowDescriptorTypeInfo title:@"Usual Activities (e.g. work, study, housework, family or leisure activities)"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUsualActivities
//                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
//                                                  title:@""];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no problem doing my usual activities"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight problems doing my usual activities"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate problems doing my usual activities"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"I have severe problems doing my usual activities"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"I am unable to do my usual activities"]];
//    //value
//    options = row.selectorOptions;
//    if (![[healthNeighbourhoodDict objectForKey:kUsualActivities]isEqualToString:@""]) {
//        row.value = [options objectAtIndex:[[healthNeighbourhoodDict objectForKey:kUsualActivities] integerValue]];
//    }
//    row.noValueDisplayText = @"Tap here for options";
//    [section addFormRow:row];
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"Your health today"];
//    section.footerTitle = @"100 means the BEST health you can imagine.\n0 means the WORST health you can imagine.";
//    [formDescriptor addFormSection:section];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSeven
//                                                rowType:XLFormRowDescriptorTypeInfo
//                                                  title:@"We would like to know how good or bad your health is TODAY. The scale is numbered from 0 to 100. *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHealthToday rowType:XLFormRowDescriptorTypeNumber title:@""];
//    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between 0 and 100" regex:@"^(0|[0-9][0-9]|100|[0-9])$"]];
//    row.required = YES;
//    row.value = [healthNeighbourhoodDict objectForKey:kHealthToday];
//    [section addFormRow:row];
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:section];
//    
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"Park"];
//    [formDescriptor addFormSection:section];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEight
//                                                rowType:XLFormRowDescriptorTypeInfo
//                                                  title:@"How long does it take (mins) for you to reach to a park or rest areas where you like to walk and enjoy yourself, playing sports or games, from your house? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kParkTime rowType:XLFormRowDescriptorTypeNumber title:@""];
//    row.required = YES;
//    row.value = [healthNeighbourhoodDict objectForKey:kParkTime];
//    [section addFormRow:row];
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"Tick all that applies"];
//    [formDescriptor addFormSection:section];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelSafe rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel safe when I walk around my neighbourhood by myself at night."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kFeelSafe];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCrimeLow rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel that crime rate (i.e. damage or stealing) is low in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kCrimeLow];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDrunkenPpl rowType:XLFormRowDescriptorTypeBooleanCheck title:@"In the morning, or later in the day, I can see drunken people on the street in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kDrunkenPpl];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBrokenBottles rowType:XLFormRowDescriptorTypeBooleanCheck title:@"In my neighbourhood, there are broken bottles or trash lying around."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kBrokenBottles];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUnclearSigns rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I and my visitors have been lost because of no or unclear signs of directions."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kUnclearSigns];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHomelessPpl rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I see destitute or homeless people walking or sitting around in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kHomelessPpl];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPublicTrans rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to take public transportations in my neighbourhood (i.e. bus stops, MRT)"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kPublicTrans];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSeeDoc rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to see a doctor in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kSeeDoc];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBuyMedi rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to buy medication in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kBuyMedi];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGrocery rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to do grocery shopping in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kGrocery];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCommCentre rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to visit community centres in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kCommCentre];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSSCentres rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to visit social service centres (i.e. Senior Activity Centres, Family Service Centres) in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kSSCentres];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBankingPost rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to visit banking and post services (banks, post offices, etc.)"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kBankingPost];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReligiousPlaces rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to visit religious places (i.e., temples, churches, synagogue, etc.)"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kReligiousPlaces];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kInteract rowType:XLFormRowDescriptorTypeBooleanCheck title:@"The people in my neighbourhood actively interact with each other (i.e., playing sports together, having meals together, etc.)."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kInteract];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSafePlaces rowType:XLFormRowDescriptorTypeBooleanCheck title:@"There are plenty of safe places to walk or play outdoors in my neighbourhood."];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.value = [healthNeighbourhoodDict objectForKey:kSafePlaces];
//    [section addFormRow:row];
//    
//    return [super initWithForm:formDescriptor];
//}

-(id) initDemographics {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Demographics"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *demographicsDict = [self.fullScreeningForm objectForKey:@"demographics"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Consent - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Consent to share particulars, personal information, screening results and other necessary information with the following"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"consent_sso_tj" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"SSO @ Taman Jurong"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    if ([demographicsDict objectForKey:@"consent_sso_tj"] != [NSNull null] && ([demographicsDict objectForKey:@"consent_sso_tj"])) {
        if (([[demographicsDict objectForKey:@"consent_sso_tj"] isEqualToString:@"0"]) || ([[demographicsDict objectForKey:@"consent_sso_tj"] isEqualToString:@"1"]))
            row.value = [demographicsDict objectForKey:@"consent_sso_tj"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"consent_ntuc_tj" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"NTUC Health Cluster Support @ Taman Jurong"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    if ([demographicsDict objectForKey:@"consent_ntuc_tj"] != [NSNull null] && ([demographicsDict objectForKey:@"consent_ntuc_tj"])) {
        if (([[demographicsDict objectForKey:@"consent_ntuc_tj"] isEqualToString:@"0"]) || ([[demographicsDict objectForKey:@"consent_ntuc_tj"] isEqualToString:@"1"]))
            row.value = [demographicsDict objectForKey:@"consent_ntuc_tj"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"consent_fysc" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Fei Yue Family Service Centre"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    if ([demographicsDict objectForKey:@"consent_fysc"] != [NSNull null] && ([demographicsDict objectForKey:@"consent_fysc"])) {
        if (([[demographicsDict objectForKey:@"consent_fysc"] isEqualToString:@"0"]) || ([[demographicsDict objectForKey:@"consent_fysc"] isEqualToString:@"1"]))
            row.value = [demographicsDict objectForKey:@"consent_fysc"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"consent_sso_bgs" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"SSO @ Bedok and Geylang Serai"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    if ([demographicsDict objectForKey:@"consent_sso_bgs"] != [NSNull null] && ([demographicsDict objectForKey:@"consent_sso_bgs"])) {
        if (([[demographicsDict objectForKey:@"consent_sso_bgs"] isEqualToString:@"0"]) || ([[demographicsDict objectForKey:@"consent_sso_bgs"] isEqualToString:@"1"]))
            row.value = [demographicsDict objectForKey:@"consent_sso_bgs"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"consent_gl" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Goodlife"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    if ([demographicsDict objectForKey:@"consent_gl"] != [NSNull null] && ([demographicsDict objectForKey:@"consent_gl"])) {
        if (([[demographicsDict objectForKey:@"consent_gl"] isEqualToString:@"0"]) || ([[demographicsDict objectForKey:@"consent_gl"] isEqualToString:@"1"]))
            row.value = [demographicsDict objectForKey:@"consent_gl"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"consent_fsc_mp" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Family Service Centre @ Marine Parade"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    if ([demographicsDict objectForKey:@"consent_fsc_mp"] != [NSNull null] && ([demographicsDict objectForKey:@"consent_fsc_mp"])) {
        if (([[demographicsDict objectForKey:@"consent_fsc_mp"] isEqualToString:@"0"]) || ([[demographicsDict objectForKey:@"consent_fsc_mp"] isEqualToString:@"1"]))
            row.value = [demographicsDict objectForKey:@"consent_fsc_mp"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCitizenship rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Citizenship"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Singaporean"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Foreigner"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Permanent Resident"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Stateless"]
                            ];
    //value
    NSArray *options = row.selectorOptions;
    if (![[demographicsDict objectForKey:kUsualActivities]isEqualToString:@""]) {
        row.value = [options objectAtIndex:[[demographicsDict objectForKey:kCitizenship] integerValue]];
    }
    [section addFormRow:row];
    
    XLFormRowDescriptor *religionRow = [XLFormRowDescriptor formRowDescriptorWithTag:kReligion rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Religion"];
    religionRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Buddhism"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Taoism"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Islam"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Christianity"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Hinduism"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"No religion"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"Others"]
                            ];
    //value
    options = religionRow.selectorOptions;
    if (![[demographicsDict objectForKey:kReligion]isEqualToString:@""]) {
        religionRow.value = [options objectAtIndex:[[demographicsDict objectForKey:kReligion] integerValue]];
    }
    religionRow.noValueDisplayText = @"Tap here for options";
    [section addFormRow:religionRow];
    
    XLFormRowDescriptor *religionOthers = [XLFormRowDescriptor formRowDescriptorWithTag:kReligionOthers rowType:XLFormRowDescriptorTypeText title:@"Other Religion"];
    religionOthers.value = [demographicsDict objectForKey:kReligionOthers];
    religionOthers.noValueDisplayText = @"Specify here";
    [section addFormRow:religionOthers];
    
    if (![[demographicsDict objectForKey:kReligion] isEqualToString:@""]) {
        if ([[religionRow.value formValue] isEqual:@(6)]) {
            religionOthers.hidden = @(0);  //show
        } else {
            religionOthers.hidden = @(1);
        }
    } else {
        religionOthers.hidden = @(1);
    }
    
    religionRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([[newValue formValue] isEqual:@(6)]) {
                religionOthers.hidden = @(0);  //show
            } else {
                religionOthers.hidden = @(1);  //hide
            }
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

//- (id) initRefForDoctorConsult {
//    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Referral for Doctor Consult"];
//    XLFormSectionDescriptor * section;
//    XLFormRowDescriptor * row;
//    NSDictionary *refForDocConsultDict = [self.fullScreeningForm objectForKey:@"consult_record"];
//    
//    formDescriptor.assignFirstResponderOnShow = YES;
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTE"];
//    section.footerTitle = @"If it is appropriate to refer the resident doctor consult:\n- If resident is mobile, accompany him/her to the consultation booths at HQ\n- If resident is not mobile, call Ops to send a doctor to the resident's flat\n- Please refer for consult immediately. Teams that wait till they are done with all other units on their list often find that upon return to a previously-covered unit, the resident has gone out";
//    [formDescriptor addFormSection:section];
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"The resident has gone for/received the following: (Check all that apply)"];
//    [formDescriptor addFormSection:section];
//    
////    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferralChecklist rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Checklist:"];
////    row.required = YES;
////    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Doctor's consultation"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Doctor's referral"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"SERI"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"SERI referral"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Dental"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"Dental referral"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"Mammogram referral"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(8) displayText:@"FIT kit"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(9) displayText:@"Pap smear referral"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"Phlebotomy (Blood test)"],
////                            [XLFormOptionsObject formOptionsObjectWithValue:@(11) displayText:@"N.A."]];
////    row.required = YES;
////    [section addFormRow:row];
////
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocConsult rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Doctor's consultation"];
//    row.value = [refForDocConsultDict objectForKey:kDocConsult];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Doctor's referral"];
//    row.value = [refForDocConsultDict objectForKey:kDocRef];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSeri rowType:XLFormRowDescriptorTypeBooleanCheck title:@"SERI"];
//    row.value = [refForDocConsultDict objectForKey:kSeri];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSeriRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"SERI referral"];
//    row.value = [refForDocConsultDict objectForKey:kSeriRef];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDentalConsult rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dental"];
//    row.value = [refForDocConsultDict objectForKey:kDentalConsult];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDentalRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dental referral"];
//    row.value = [refForDocConsultDict objectForKey:kDentalRef];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMammoRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Mammogram referal"];
//    row.value = [refForDocConsultDict objectForKey:kMammoRef];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFitKit rowType:XLFormRowDescriptorTypeBooleanCheck title:@"FIT kit"];
//    row.value = [refForDocConsultDict objectForKey:kFitKit];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPapSmearRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Pap smear referral"];
//    row.value = [refForDocConsultDict objectForKey:kPapSmearRef];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhlebotomy rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Phlebotomy (Blood test)"];
//    row.value = [refForDocConsultDict objectForKey:kPhlebotomy];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRefNA rowType:XLFormRowDescriptorTypeBooleanCheck title:@"N.A."];
//    row.value = [refForDocConsultDict objectForKey:kRefNA];
//    [section addFormRow:row];
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"Doctor's notes"];
//    [formDescriptor addFormSection:section];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocNotes
//                                                rowType:XLFormRowDescriptorTypeTextView];
//    [row.cellConfigAtConfigure setObject:@"Doctor's notes" forKey:@"textView.placeholder"];
//    row.value = [refForDocConsultDict objectForKey:kDocNotes];
//    [section addFormRow:row];
//
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:section];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocName
//                                                rowType:XLFormRowDescriptorTypeName title:@"Name of Doctor"];
//    row.required = NO;
//    row.value = [refForDocConsultDict objectForKey:kDocName];
//    [section addFormRow:row];
//    
//    return [super initWithForm:formDescriptor];
//}

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
//        case 1: [self saveResidentParticulars];
//            break;
//        case 2: [self saveClinicalResults];
//            break;
        case 3: [self saveScreeningOfRiskFactors];
            break;
//        case 4: [self saveDiabetesMellitus];
//            break;
        case 5: [self saveHyperlipidemia];
            break;
//        case 6: [self saveHypertension];
//            break;
        case 7: [self saveCancerScreening];
            break;
        case 8: [self saveOtherMedicalIssues];
            break;
//        case 9: [self savePrimaryCareSource];
//            break;
        case 10: [self saveMyHealthAndMyNeighbourhood];
            break;
        case 11: [self saveDemographics];
            break;
        case 12: [self saveCurrentPhysicalIssues];
            break;
        case 13: [self saveCurrentSocioSituation];
            break;
//        case 14: [self saveSocialSupportAssessment];
//            break;
//        case 15: [self saveRefForDoctorConsult];
//            break;
    }
}

//- (void) saveNeighbourhood {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *neighbourhood = [[self.fullScreeningForm objectForKey:@"neighbourhood"] mutableCopy];
//    
//    [neighbourhood setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kNeighbourhoodLoc] forKey:kNeighbourhoodLoc];
//    [neighbourhood setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kNeighbourhoodOthers] forKey:kNeighbourhoodOthers];
//
//    [self.fullScreeningForm setObject:neighbourhood forKey:@"neighbourhood"];
//    
//}
////
//- (void) saveResidentParticulars {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *resi_particulars = [[self.fullScreeningForm objectForKey:@"resi_particulars"] mutableCopy];
//    
//    if ([fields objectForKey:kGender] != [NSNull null]) {
//        if ([[fields objectForKey:kGender] isEqualToString:@"Male"]) {
//            [resi_particulars setObject:@"M" forKey:kGender];
//        } else if ([[fields objectForKey:kGender] isEqualToString:@"Female"]) {
//            [resi_particulars setObject:@"F" forKey:kGender];
//        }
//    }
//    
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kName] forKey:@"resident_name"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kNRIC] forKey:kNRIC];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kDOB] forKey:@"birth_year"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kContactNumber] forKey:@"contact_no"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kAddPostCode] forKey:@"address_postcode"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddStreet] forKey:@"address_street"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddBlock] forKey:@"address_block"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddUnit] forKey:@"address_unit"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentNUS] forKey:kConsentNUS];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentHPB] forKey:kConsentHPB];
////    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentGoodlife] forKey:kConsentGoodlife];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddYears] forKey:@"address_num_years"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kContactNumber2] forKey:@"contact_no2"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSpokenLangOthers] forKey:@"lang_others_text"];
//    
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kEthnicity] forKey:kEthnicity];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kMaritalStatus] forKey:kMaritalStatus];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kHighestEduLvl] forKey:@"highest_edu_lvl"];
//
//    //Init them to zero first
//    [resi_particulars setObject:@"0" forKey:@"lang_canto"];
//    [resi_particulars setObject:@"0" forKey:@"lang_english"];
//    [resi_particulars setObject:@"0" forKey:@"lang_hokkien"];
//    [resi_particulars setObject:@"0" forKey:@"lang_hindi"];
//    [resi_particulars setObject:@"0" forKey:@"lang_malay"];
//    [resi_particulars setObject:@"0" forKey:@"lang_mandrin"];
//    [resi_particulars setObject:@"0" forKey:@"lang_tamil"];
//    [resi_particulars setObject:@"0" forKey:@"lang_teochew"];
//    [resi_particulars setObject:@"0" forKey:@"lang_others"];
//    
//    if ([[fields objectForKey:kSpokenLanguage] count]!=0) {
//        NSArray *spokenLangArray = [fields objectForKey:kSpokenLanguage];
//        for (int i=0; i<[spokenLangArray count]; i++) {
//            
//            if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Cantonese"]) [resi_particulars setObject:@"1" forKey:@"lang_canto"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"English"]) [resi_particulars setObject:@"1" forKey:@"lang_english"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hindi"]) [resi_particulars setObject:@"1" forKey:@"lang_hindi"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hokkien"]) [resi_particulars setObject:@"1" forKey:@"lang_hokkien"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Malay"]) [resi_particulars setObject:@"1" forKey:@"lang_malay"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Mandarin"]) [resi_particulars setObject:@"1" forKey:@"lang_mandrin"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Tamil"]) [resi_particulars setObject:@"1" forKey:@"lang_tamil"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Teochew"]) [resi_particulars setObject:@"1" forKey:@"lang_teochew"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Others"]) [resi_particulars setObject:@"1" forKey:@"lang_others"];
//        }
//    }
//    
//    NSString *room;
//    NSUInteger loc;
//    if (([fields objectForKey:kHousingType] != [NSNull null]) && ([fields objectForKey:kHousingType])) {
//        NSString *houseType = [fields objectForKey:kHousingType];
//        if ([houseType rangeOfString:@"Owned"].location != NSNotFound) {
//            [resi_particulars setObject:@"0" forKey:@"housing_owned_rented"];
//        } else if ([houseType rangeOfString:@"Rental"].location != NSNotFound) {
//            [resi_particulars setObject:@"1" forKey:@"housing_owned_rented"];
//        }
//        
//        loc = [houseType rangeOfString:@"-"].location;
//        room = [houseType substringWithRange:NSMakeRange(loc-1, 1)];
//        [resi_particulars setObject:room forKey:@"housing_num_rooms"];
//    }
//    
//    [self.fullScreeningForm setObject:resi_particulars forKey:@"resi_particulars"];
//}
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
//- (void) saveDiabetesMellitus {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *diabetes_dict = [[self.fullScreeningForm objectForKey:@"diabetes"] mutableCopy];
//    
//    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kDiabetesHasInformed] forKey:@"has_informed"];
//    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kDiabetesCheckedBlood] forKey:@"checked_blood"];
//    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kDiabetesSeeingDocRegularly] forKey:@"seeing_doc_regularly"];
//    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kDiabetesCurrentlyPrescribed] forKey:@"currently_prescribed"];
//    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kDiabetesTakingRegularly] forKey:@"taking_regularly"];
//    
//    [self.fullScreeningForm setObject:diabetes_dict forKey:@"diabetes"];
//}

- (void) saveHyperlipidemia {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *hyperlipid_dict = [[self.fullScreeningForm objectForKey:@"hyperlipid"] mutableCopy];
    
    [hyperlipid_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kLipidHasInformed] forKey:@"has_informed"];
    [hyperlipid_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kLipidCheckedBlood] forKey:@"checked_blood"];
    [hyperlipid_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kLipidSeeingDocRegularly] forKey:@"seeing_doc_regularly"];
    [hyperlipid_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kLipidCurrentlyPrescribed] forKey:@"currently_prescribed"];
    [hyperlipid_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kLipidTakingRegularly] forKey:@"taking_regularly"];
    
    [self.fullScreeningForm setObject:hyperlipid_dict forKey:@"hyperlipid"];
}
//
//- (void) saveHypertension {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *hypertension_dict = [[self.fullScreeningForm objectForKey:@"hypertension"] mutableCopy];
//    
//    [hypertension_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kHTHasInformed] forKey:@"has_informed"];
//    [hypertension_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kHTCheckedBP] forKey:@"checked_bp"];
//    [hypertension_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kHTSeeingDocRegularly] forKey:@"seeing_doc_regularly"];
//    [hypertension_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kHTCurrentlyPrescribed] forKey:@"currently_prescribed"];
//    [hypertension_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kHTTakingRegularly] forKey:@"taking_regularly"];
//    
//    [self.fullScreeningForm setObject:hypertension_dict forKey:@"hypertension"];
//}

- (void) saveCancerScreening {
    
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *cancer_dict = [[self.fullScreeningForm objectForKey:@"cancer"] mutableCopy];
    

    //set all to 0 first
    [cancer_dict setObject:@"0" forKey:@"cervical"];
    [cancer_dict setObject:@"0" forKey:@"breast"];
    [cancer_dict setObject:@"0" forKey:@"colorectal"];
    
    if ([[fields objectForKey:kMultiCancerDiagnosed] count]!=0) {
        NSArray *cancerDiagnosedArray = [fields objectForKey:kMultiCancerDiagnosed];
        
        for (int i=0; i<[cancerDiagnosedArray count]; i++) {
            if([[cancerDiagnosedArray objectAtIndex:i] isEqualToString:@"Cervical (子宫颈癌)"]) [cancer_dict setObject:@"1" forKey:@"cervical"];
            else if([[cancerDiagnosedArray objectAtIndex:i] isEqualToString:@"Breast (乳腺癌)"]) [cancer_dict setObject:@"1" forKey:@"breast"];
            else if([[cancerDiagnosedArray objectAtIndex:i] isEqualToString:@"Colorectal (大肠癌)"]) [cancer_dict setObject:@"1" forKey:@"colorectal"];
        }
    }
    
    
    [cancer_dict setObject:[self getStringWithDictionary:fields rowType:YesNoNA formDescriptorWithTag:kPapSmear] forKey:kPapSmear];
    [cancer_dict setObject:[self getStringWithDictionary:fields rowType:YesNoNA formDescriptorWithTag:kMammogram] forKey:kMammogram];
    [cancer_dict setObject:[self getStringWithDictionary:fields rowType:YesNoNA formDescriptorWithTag:kFobt] forKey:kFobt];
    
    [self.fullScreeningForm setObject:cancer_dict forKey:@"cancer"];
    
}

- (void) saveOtherMedicalIssues {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *otherMedIssues_dict = [[self.fullScreeningForm objectForKey:@"others"] mutableCopy];
    
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kHeartAttack] forKey:kHeartAttack];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kHeartFailure] forKey:kHeartFailure];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kCopd] forKey:kCopd];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kAsthma] forKey:kAsthma];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kStroke] forKey:kStroke];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kDementia] forKey:kDementia];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kHemiplegia] forKey:kHemiplegia];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kSolidOrganCancer] forKey:kSolidOrganCancer];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kBloodCancer] forKey:kBloodCancer];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kMetastaticCancer] forKey:kMetastaticCancer];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kDiabetesWODamage] forKey:kDiabetesWODamage];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kDiabetesWDamage] forKey:kDiabetesWDamage];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kKidneyFailure] forKey:kKidneyFailure];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kPepticUlcer] forKey:kPepticUlcer];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kMildLiver] forKey:kMildLiver];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kModerateSevereLiver] forKey:@"liver_disease"];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kVascularDisease] forKey:kVascularDisease];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kTissueDisease] forKey:kTissueDisease];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kOsteoarthritis] forKey:kOsteoarthritis];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kAids] forKey:kAids];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kNA] forKey:@"NA"];
    
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:TextView formDescriptorWithTag:kOtherMedIssues] forKey:@"others"];
    
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kPain] forKey:kPain];
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kAnxiety] forKey:kAnxiety];
    
    [otherMedIssues_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kPainDuration] forKey:kPainDuration];
    
    [self.fullScreeningForm setObject:otherMedIssues_dict forKey:@"others"];
    
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

- (void) saveMyHealthAndMyNeighbourhood {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *healthNeighbourhood_dict = [[self.fullScreeningForm objectForKey:@"self_rated"] mutableCopy];
    
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kMobility] forKey:kMobility];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kMobilityAid] forKey:kMobilityAid];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kSelfCare] forKey:kSelfCare];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kUsualActivities] forKey:kUsualActivities];
    
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kHealthToday] forKey:kHealthToday];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kParkTime] forKey:kParkTime];
    
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kFeelSafe] forKey:kFeelSafe];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kCrimeLow] forKey:kCrimeLow];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kDrunkenPpl] forKey:kDrunkenPpl];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kBrokenBottles] forKey:kBrokenBottles];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kUnclearSigns] forKey:kUnclearSigns];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kHomelessPpl] forKey:kHomelessPpl];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kPublicTrans] forKey:kPublicTrans];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kSeeDoc] forKey:kSeeDoc];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kBuyMedi] forKey:kBuyMedi];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kGrocery] forKey:kGrocery];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kCommCentre] forKey:kCommCentre];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kSSCentres] forKey:kSSCentres];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kBankingPost] forKey:kBankingPost];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kReligiousPlaces] forKey:kReligiousPlaces];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kInteract] forKey:kInteract];
    [healthNeighbourhood_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kSafePlaces] forKey:kSafePlaces];

    
    [self.fullScreeningForm setObject:healthNeighbourhood_dict forKey:@"self_rated"];
}

- (void) saveDemographics {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *demographics_dict = [[self.fullScreeningForm objectForKey:@"demographics"] mutableCopy];
    
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:@"consent_sso_tj"] forKey:@"consent_sso_tj"];
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:@"consent_fsc_mp"] forKey:@"consent_fsc_mp"];
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:@"consent_ntuc_tj"] forKey:@"consent_ntuc_tj"];
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:@"consent_gl"] forKey:@"consent_gl"];
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:@"consent_fysc"] forKey:@"consent_fysc"];
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:@"consent_sso_bgs"] forKey:@"consent_sso_bgs"];
    
    
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kCitizenship] forKey:kCitizenship];
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kReligion] forKey:kReligion];
    [demographics_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kReligionOthers] forKey:kReligionOthers];
    
    [self.fullScreeningForm setObject:demographics_dict forKey:@"demographics"];
    
}

- (void) saveCurrentPhysicalIssues {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *currPhyIssues_dict = [[self.fullScreeningForm objectForKey:@"adls"] mutableCopy];
    
    if ([fields objectForKey:kMultiADL] != (id) [NSNull null]) {    //check for null first, if not crash may happen
        //Clear all first
        [currPhyIssues_dict setObject:@"0" forKey:@"bathe"];
        [currPhyIssues_dict setObject:@"0" forKey:@"dress"];
        [currPhyIssues_dict setObject:@"0" forKey:@"eat"];
        [currPhyIssues_dict setObject:@"0" forKey:@"hygiene"];
        [currPhyIssues_dict setObject:@"0" forKey:@"toileting"];
        [currPhyIssues_dict setObject:@"0" forKey:@"walk"];
        
        if ([[fields objectForKey:kMultiADL] count]!=0) {
            NSArray *adlArray = [fields objectForKey:kMultiADL];
            for (int i=0; i<[adlArray count]; i++) {
                if([[[adlArray objectAtIndex:i] formValue] isEqual:@(0)]) [currPhyIssues_dict setObject:@"1" forKey:@"bathe"];
                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(1)]) [currPhyIssues_dict setObject:@"1" forKey:@"dress"];
                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(2)]) [currPhyIssues_dict setObject:@"1" forKey:@"eat"];
                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(3)]) [currPhyIssues_dict setObject:@"1" forKey:@"hygiene"];
                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(4)]) [currPhyIssues_dict setObject:@"1" forKey:@"toileting"];
                else if([[[adlArray objectAtIndex:i] formValue] isEqual:@(5)]) [currPhyIssues_dict setObject:@"1" forKey:@"walk"];
            }
        }
    }
    
    [self.fullScreeningForm setObject:currPhyIssues_dict forKey:@"adls"];
}

- (void) saveCurrentSocioSituation {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *currSocioSituation_dict = [[self.fullScreeningForm objectForKey:@"socioecon"] mutableCopy];
    
    if ([fields objectForKey:kMultiPlan] != (id) [NSNull null]) {
        NSArray *plansOptionArray = [fields objectForKey:kMultiPlan];
        for(int i=0;i<[plansOptionArray count];i++) {
            if ([[[plansOptionArray objectAtIndex:i] formValue] isEqual:@0]) [currSocioSituation_dict setObject:@"1" forKey:@"medisave"];
            else if ([[[plansOptionArray objectAtIndex:i] formValue] isEqual:@1]) [currSocioSituation_dict setObject:@"1" forKey:@"insurance"];
            else if ([[[plansOptionArray objectAtIndex:i] formValue] isEqual:@2]) [currSocioSituation_dict setObject:@"1" forKey:@"cpf_pays"];
            else if ([[[plansOptionArray objectAtIndex:i] formValue] isEqual:@3]) [currSocioSituation_dict setObject:@"1" forKey:@"pgp"];
            else if ([[[plansOptionArray objectAtIndex:i] formValue] isEqual:@4]) [currSocioSituation_dict setObject:@"1" forKey:@"chas"];
            else if ([[[plansOptionArray objectAtIndex:i] formValue] isEqual:@5]) [currSocioSituation_dict setObject:@"1" forKey:@"apply_chas"];
        }
    }
    
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kCPFAmt] forKey:kCPFAmt];
    
    //CHAS COLOR
    if ([fields objectForKey:kChasColour] != (id)[NSNull null]) {
        if ([[fields objectForKey:kChasColour] isEqualToString:@"Blue"]) [currSocioSituation_dict setObject:@"0" forKey:kChasColour];
        else if ([[fields objectForKey:kChasColour] isEqualToString:@"Orange"]) [currSocioSituation_dict setObject:@"1" forKey:kChasColour];
        else if ([[fields objectForKey:kChasColour] isEqualToString:@"N.A."]) [currSocioSituation_dict setObject:@"2" forKey:kChasColour];
    }
    
    //reset values to 0 first
    [currSocioSituation_dict setObject:@"0" forKey:@"cant_cope_med"];
    [currSocioSituation_dict setObject:@"0" forKey:@"cant_cope_daily"];
    [currSocioSituation_dict setObject:@"0" forKey:@"cant_cope_arrears"];
    [currSocioSituation_dict setObject:@"0" forKey:@"cant_cope_others"];
    
    if ([fields objectForKey:kHouseCopingReason] != (id) [NSNull null]) {
        NSArray *houseCopingArray = [fields objectForKey:kHouseCopingReason];
        for(int i=0;i<[houseCopingArray count];i++) {
            if ([[houseCopingArray objectAtIndex:i] isEqualToString:@"Medical expenses"]) [currSocioSituation_dict setObject:@"1" forKey:@"cant_cope_med"];
            else if ([[houseCopingArray objectAtIndex:i] isEqualToString:@"Daily living expenses"]) [currSocioSituation_dict setObject:@"1" forKey:@"cant_cope_daily"];
            else if ([[houseCopingArray objectAtIndex:i] isEqualToString:@"Arrears / Debts"]) [currSocioSituation_dict setObject:@"1" forKey:@"cant_cope_arrears"];
            else if ([[houseCopingArray objectAtIndex:i] isEqualToString:@"Others"]) [currSocioSituation_dict setObject:@"1" forKey:@"cant_cope_others"];
        }
    }
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kHouseCoping] forKey:kHouseCoping];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kHouseCopingReasonOthers] forKey:kHouseCopingReasonOthers];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kEmployStatus] forKey:kEmployStatus];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kEmployStatusOthers] forKey:kEmployStatusOthers];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:TextView formDescriptorWithTag:kManageExpenses] forKey:kManageExpenses];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kHouseholdIncome] forKey:kHouseholdIncome];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kPplInHouse] forKey:kPplInHouse];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kAnyAssist] forKey:kAnyAssist];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kSeekHelp] forKey:kSeekHelp];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kHelpOrg] forKey:kHelpOrg];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:TextView formDescriptorWithTag:kHelpDescribe] forKey:kHelpDescribe];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kHelpAmt] forKey:kHelpAmt];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kHelpPeriod] forKey:kHelpPeriod];
    [currSocioSituation_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kHelpHelpful] forKey:kHelpHelpful];
    
    [self.fullScreeningForm setObject:currSocioSituation_dict forKey:@"socioecon"];
}
//
//- (void) saveSocialSupportAssessment {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *socialSuppAssessment_dict = [[self.fullScreeningForm objectForKey:@"social_support"] mutableCopy];
//    
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kHasCaregiver] forKey:kHasCaregiver];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCaregiverName] forKey:kCaregiverName];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCaregiverRs] forKey:kCaregiverRs];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kCaregiverContactNum] forKey:kCaregiverContactNum];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCaregiverNric] forKey:kCaregiverNric];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCaregiverAddress] forKey:kCaregiverAddress];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kEContact] forKey:kEContact];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kEContactName] forKey:kEContactName];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kEContactRs] forKey:kEContactRs];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kEContactNum] forKey:kEContactNum];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kEContactNric] forKey:kEContactNric];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kEContactAddress] forKey:kEContactAddress];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kGettingSupport] forKey:kGettingSupport];
//    //Support in terms of..... multi selector
//    
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"care_giving"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"food"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"money"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"others"];
//    
//    if([fields objectForKey:kMultiSupport]!= [NSNull null]) {
//        NSArray *multiSupportArray = [fields objectForKey:kMultiSupport];
//        
//        if ([multiSupportArray count]>0) {
//            for(int i=0;i<[multiSupportArray count];i++) {
//                if ([[multiSupportArray objectAtIndex:i] isEqualToString:@"Care-giving"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"care_giving"];
//                else if ([[multiSupportArray objectAtIndex:i] isEqualToString:@"Food"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"food"];
//                else if ([[multiSupportArray objectAtIndex:i] isEqualToString:@"Money"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"money"];
//                else if ([[multiSupportArray objectAtIndex:i] isEqualToString:@"Others"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"others"];
//                
//            }
//        }
//    }
//    
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSupportOthers] forKey:@"others_text"];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kRelativesContact] forKey:kRelativesContact];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kRelativesEase] forKey:kRelativesEase];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kRelativesClose] forKey:kRelativesClose];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kFriendsContact] forKey:kFriendsContact];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kFriendsEase] forKey:kFriendsEase];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kFriendsClose] forKey:kFriendsClose];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSocialScore] forKey:kSocialScore];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kLackCompan] forKey:kLackCompan];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kFeelLeftOut] forKey:kFeelLeftOut];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kFeelIsolated] forKey:kFeelIsolated];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kAwareActivities] forKey:kAwareActivities];
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kParticipateActivities] forKey:kParticipateActivities];
//    
//    //reset values first
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"sac"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"fsc"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"cc"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"rc"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"ro"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"so"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"oth"];
//    [socialSuppAssessment_dict setObject:@"0" forKey:@"na"];
//    
//    if([fields objectForKey:kMultiHost]!= [NSNull null]) {
//        NSArray *multiHostArray = [fields objectForKey:kMultiHost];
//        
//        if ([multiHostArray count]>0) {
//            for(int i=0;i<[multiHostArray count];i++) {
//                if ([[multiHostArray objectAtIndex:i] isEqualToString:@"Senior Activity Centre (SAC)"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"sac"];
//                else if ([[multiHostArray objectAtIndex:i] isEqualToString:@"Family Services Centre (FSC)"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"fsc"];
//                else if ([[multiHostArray objectAtIndex:i] isEqualToString:@"Community Centre (CC)"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"cc"];
//                else if ([[multiHostArray objectAtIndex:i] isEqualToString:@"Residents' Committee (RC)"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"rc"];
//                else if ([[multiHostArray objectAtIndex:i] isEqualToString:@"Religious Organisations"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"ro"];
//                else if ([[multiHostArray objectAtIndex:i] isEqualToString:@"Self-organised"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"so"];
//                else if ([[multiHostArray objectAtIndex:i] isEqualToString:@"Others"]) [socialSuppAssessment_dict setObject:@"1" forKey:@"oth"];
//                else if ([[multiHostArray objectAtIndex:i] isEqualToString:@"N.A."]) [socialSuppAssessment_dict setObject:@"1" forKey:@"na"];
//                
//            }
//        }
//    }
//    
//    [socialSuppAssessment_dict setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kHostOthers] forKey:kHostOthers];
//
//    [self.fullScreeningForm setObject:socialSuppAssessment_dict forKey:@"social_support"];
//}
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

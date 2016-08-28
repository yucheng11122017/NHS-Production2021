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
#import "MBProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"

//XLForms stuffs
#import "XLForm.h"

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

typedef enum rowTypes {
    Text,
    YesNo,
    MultiSelector,
    Checkbox,
    SelectorPush,
    SelectorActionSheet,
    SegmentedControl,
    Number,
    Switch
} rowTypes;

NSString *const kNeighbourhoodLoc = @"neighbourhood_location";
NSString *const kNeighbourhoodOthers = @"neighbourhood_others";
NSString *const kContactNumber2 = @"contactnumber2";
NSString *const kEthnicity = @"ethnicity_id";
NSString *const kMaritalStatus = @"marital_status";
NSString *const kHousingType = @"housing_type";
NSString *const kHighestEduLvl = @"highest_level_education";
NSString *const kAddYears = @"address_years";
NSString *const kConsentNUS = @"consent_nus";
NSString *const kConsentHPB = @"consent_hpb";
NSString *const kConsentGoodlife = @"consent_goodlife";
NSString *const kBpSystolic = @"bp_systolic";
NSString *const kBpDiastolic = @"bp_diastolic";
NSString *const kWeight = @"weight";
NSString *const kHeight = @"height";
NSString *const kBMI = @"bmi";
NSString *const kWaistCircum = @"waist_circum";
NSString *const kHipCircum = @"hip_circum";
NSString *const kWaistHipRatio = @"waist_hip_ratio";
NSString *const kCbg = @"cbg";
NSString *const kBpSystolic2 = @"bp_systolic2";
NSString *const kBpDiastolic2 = @"bp_diastolic2";
NSString *const kBpSystolicAvg = @"bp_systolic_avg";
NSString *const kBpDiastolicAvg = @"bp_diastolic_avg";
NSString *const kBpSystolic3 = @"bp_systolic3";
NSString *const kBpDiastolic3 = @"bp_diastolic3";

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
NSString *const kDiabetesHasInformed = @"diabetes_has_informed";
NSString *const kDiabetesCheckedBlood = @"diabetes_checked_blood";
NSString *const kDiabetesSeeingDocRegularly = @"diabetes_seeing_doc_regularly";
NSString *const kDiabetesCurrentlyPrescribed = @"diabetes_currently_prescribed";
NSString *const kDiabetesTakingRegularly = @"diabetes_taking_regularly";

//Hyperlipidemia
NSString *const kLipidHasInformed = @"lipid_has_informed";
NSString *const kLipidCheckedBlood = @"lipid_checked_blood";
NSString *const kLipidSeeingDocRegularly = @"lipid_seeing_doc_regularly";
NSString *const kLipidCurrentlyPrescribed = @"lipid_currently_prescribed";
NSString *const kLipidTakingRegularly = @"lipid_taking_regularly";
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
NSString *const kHTHasInformed = @"tension_has_informed";
NSString *const kHTCheckedBP = @"tension_checked_blood";
NSString *const kHTSeeingDocRegularly = @"tension_seeing_doc_regularly";
NSString *const kHTCurrentlyPrescribed = @"tension_currently_prescribed";
NSString *const kHTTakingRegularly = @"tension_taking_regularly";

//Cancer Screening
NSString *const kMultiCancerDiagnosed = @"multi_cancer_diagnosed";
NSString *const kPapSmear = @"pap_smear";
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

//Primary Care Source
NSString *const kCareGiverID = @"care_giver_id";
NSString *const kCareGiverOthers = @"care_giver_others";
NSString *const kCareProviderID = @"care_provider_id";
NSString *const kCareProviderOthers = @"care_provider_others";
NSString *const kAneVisit = @"ane_visit";
NSString *const kHospitalized = @"hospitalized";

//My Health and My Neighbourhood
NSString *const kMobility = @"mobility";
NSString *const kMobilityAid = @"mobility_aid";
NSString *const kSelfCare = @"self_care";
NSString *const kUsualActivities = @"usual_activities";
NSString *const kPain = @"pain";
NSString *const kPainDuration = @"pain_duration";
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
NSString *const kCitizenship = @"citizenship";
NSString *const kReligion = @"religion";
NSString *const kReligionOthers = @"religion_others";

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
NSString *const kHasCaregiver = @"has_caregiver";
NSString *const kCaregiverName = @"caregiver_name";
NSString *const kCaregiverRs = @"caregiver_rs";
NSString *const kCaregiverContactNum = @"caregiver_contact_num";
NSString *const kCaregiverNric = @"caregiver_nric";
NSString *const kCaregiverAddress = @"caregiver_address";
NSString *const kEContact = @"e_contact";
NSString *const kEContactName = @"e_contact_name";
NSString *const kEContactRs = @"e_contact_rs";
NSString *const kEContactNum = @"e_contact_num";
NSString *const kEContactNric = @"e_contact_nric";
NSString *const kEContactAddress = @"e_contact_address";
NSString *const kGettingSupport = @"getting_suppport";
NSString *const kMultiSupport = @"multi_support";
NSString *const kSupportOthers = @"support_others";
NSString *const kRelativesContact = @"relatives_contact";
NSString *const kRelativesEase = @"relatives_ease";
NSString *const kRelativesClose = @"relatives_close";
NSString *const kFriendsContact = @"friends_contact";
NSString *const kFriendsEase = @"friends_ease";
NSString *const kFriendsClose = @"friends_close";
NSString *const kSocialScore = @"social_score";
NSString *const kLackCompan = @"lack_compan";
NSString *const kFeelLeftOut = @"feel_left_out";
NSString *const kFeelIsolated = @"feel_isolated";
NSString *const kAwareActivities = @"aware_activities";
NSString *const kParticipateActivities = @"participate_activities";
NSString *const kMultiHost = @"multi_host";
NSString *const kHostOthers = @"host_others";

//Referral for Doctor Consult
NSString *const kReferralChecklist = @"referral_checklist";
NSString *const kDocConsult = @"doc_consult";
NSString *const kDocRef = @"doc_ref";
NSString *const kSeri = @"seri";
NSString *const kSeriRef = @"seri_ref";
NSString *const kDentalConsult = @"dental";
NSString *const kDentalRef = @"dental_ref";
NSString *const kMammoRef = @"mammo_ref";
NSString *const kFitKit = @"fit_kit";
NSString *const kPapSmearRef = @"pap_smear_ref";
NSString *const kPhlebotomy = @"phleb";
NSString *const kRefNA = @"na";
NSString *const kDocNotes = @"doc_notes";
NSString *const kDocName = @"doc_name";


@interface ScreeningFormViewController () {
    NSString *gender, *nric, *resident_name, *birth_year, *address_block, *address_postcode, *address_street, *address_unit, *contact_no;
    NSArray *spoken_lang_value;
}

@end

@implementation ScreeningFormViewController

- (void)viewDidLoad {
    
    XLFormDescriptor *form;
    [self getDictionaryIntoVariables];
    
    switch([self.sectionID integerValue]) {
        case 0: form = [self initNeighbourhood];       //must init first before [super viewDidLoad]
            break;
        case 1: form = [self initResidentParticulars];
            break;
        case 2: form = [self initClinicalResults];
            break;
        case 3: form = [self initScreeningOfRiskFactors];
            break;
        case 4: form = [self initDiabetesMellitus];
            break;
        case 5: form = [self initHyperlipidemia];
            break;
        case 6: form = [self initHypertension];
            break;
        case 7: form = [self initCancerScreening];
            break;
        case 8: form = [self initOtherMedicalIssues];
            break;
        case 9: form = [self initPrimaryCareSource];
            break;
        case 10: form = [self initMyHealthAndMyNeighbourhood];
            break;
        case 11: form = [self initDemographics];
            break;
        case 12: form = [self initCurrentPhysicalIssues];
            break;
        case 13: form = [self initCurrentSocioSituation];
            break;
        case 14: form = [self initSocialSupportAssessment];
            break;
        case 15: form = [self initRefForDoctorConsult];
            break;
    }
//    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(returnBtnPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Validate" style:UIBarButtonItemStyleDone target:self action:@selector(validateBtnPressed:)];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated {
    [self saveEntriesIntoDictionary];
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

#pragma mark - Buttons
//-(void)returnBtnPressed:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}


-(void)validateBtnPressed:(UIBarButtonItem * __unused)button
{
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
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Set the custom view mode to show any view.
        hud.mode = MBProgressHUDModeCustomView;
        // Set an image view with a checkmark.
        UIImage *image = [[UIImage imageNamed:@"ThumbsUp"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // Looks a bit nicer if we make it square.
        hud.square = YES;
        
        hud.backgroundColor = [UIColor clearColor];
        // Optional label text.
        hud.label.text = NSLocalizedString(@"Good!", @"HUD done title");
        [hud hideAnimated:YES afterDelay:1.f];

    }
//    [self.tableView endEditing:YES];
//    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the label text.
//    hud.label.text = NSLocalizedString(@"Uploading...", @"HUD loading title");
//    [self submitPersonalInfo:[self preparePersonalInfoDict]];

    
}

#pragma mark - Forms methods

-(id)initNeighbourhood
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Neighbourhood"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *neighbourhoodDict = [self.fullScreeningForm objectForKey:@"neighbourhood"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Introduction"];
    section.footerTitle = @"Dear Volunteer: \n\nThank you for being a part of NHS. For your convenience, this form contains the questionnaire. \nAll fields marked with an asterisk are mandatory. \nComplete all sections (tick) to submit. \nForm is auto-saved.";
    [formDescriptor addFormSection:section];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Neighbourhood"];
    [formDescriptor addFormSection:section];
    
    
    // RowNavigationShowAccessoryView
    XLFormRowDescriptor *neighbourhoodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourhoodLoc rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Screening Neighbourhood"];
    neighbourhoodRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Bukit Merah"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Eunos Crescent"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Marine Terrace"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Taman Jurong"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Volunteer Training"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Others"]
                            ];
    neighbourhoodRow.required = YES;
    NSArray *options = neighbourhoodRow.selectorOptions;
    if (![[neighbourhoodDict objectForKey:kNeighbourhoodLoc]isEqualToString:@""]) {
        neighbourhoodRow.value = [options objectAtIndex:[[neighbourhoodDict objectForKey:kNeighbourhoodLoc] integerValue]];
    }
    [section addFormRow:neighbourhoodRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourhoodOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    row.value = [neighbourhoodDict objectForKey:kNeighbourhoodOthers];
    if ([row.value length] <= 0) {
        row.hidden = @(YES);
    }
    [section addFormRow:row];
    
    neighbourhoodRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        //        bmi.value = @([weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2));
        if (oldValue != newValue) {
            if ([[newValue formValue] isEqual:@5]) {
                row.hidden = @(NO);
            } else {
                row.hidden = @(YES);
            }
        }
    };
    
    return [super initWithForm:formDescriptor];
}

-(id)initResidentParticulars
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Resident Particulars"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *resiPartiDict = [self.fullScreeningForm objectForKey:@"resi_particulars"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"Patient Name"];
    row.required = YES;
    row.value = resident_name? resident_name:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    row.value = gender? gender:@"Male";
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    row.value = nric? nric:@"";
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDOB rowType:XLFormRowDescriptorTypeInteger title:@"DOB Year"];
    row.required = YES;
    row.value = birth_year? birth_year:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kContactNumber rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    row.required = YES;
    row.value = contact_no? contact_no:@"";
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kContactNumber2 rowType:XLFormRowDescriptorTypePhone title:@"Contact Number (2)"];
    row.required = NO;
    row.value = [resiPartiDict objectForKey:@"contact_no2"];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number(2) must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEthnicity rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Ethnicity"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Chinese"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Indian"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Malay"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Others"]
                            ];
    row.required = NO;
    if ([[resiPartiDict objectForKey:@"ethnicity_id"] isEqualToString:@""]) {
//        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Chinese"];   //default value
    } else {
        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"ethnicity_id"] integerValue]] ;
    }
    [section addFormRow:row];
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLanguage rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    row.required = YES;
    spokenLangRow.value = spoken_lang_value? spoken_lang_value:@[];
    [section addFormRow:spokenLangRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLangOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", spokenLangRow];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMaritalStatus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Marital Status"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Divorced"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Married"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Separated"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Single"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Widowed"]
                            ];
    if ([[resiPartiDict objectForKey:@"marital_status"] isEqualToString:@""]) {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Single"];   //default value
    } else {
        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"marital_status"] integerValue]] ;
    }
    
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHousingType rowType:XLFormRowDescriptorTypeSelectorPush title:@"Housing Type"];
    row.selectorOptions = @[@"Owned, 1-room", @"Owned, 2-room", @"Owned, 3-room", @"Owned, 4-room", @"Owned, 5-room", @"Rental, 1-room", @"Rental, 2-room", @"Rental, 3-room", @"Rental, 4-room"];
    row.required = YES;
    if (![[resiPartiDict objectForKey:@"housing_owned_rented"] isEqualToString:@""]) { //if got value
        if([[resiPartiDict objectForKey:@"housing_owned_rented"] isEqualToString:@"0"]) {   //owned
            NSArray *options = row.selectorOptions;
            row.value = [options objectAtIndex:([[resiPartiDict objectForKey:@"housing_num_rooms"] integerValue] - 1)]; //do the math =D
        } else {
            NSArray *options = row.selectorOptions;
            row.value = [options objectAtIndex:([[resiPartiDict objectForKey:@"housing_num_rooms"] integerValue] + 4)];
        }
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHighestEduLvl rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Highest education level"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"ITE/Pre-U/JC"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"No formal qualifications"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Primary"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Secondary"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"University"]
                            ];
    if ([[resiPartiDict objectForKey:@"highest_edu_lvl"] isEqualToString:@""]) {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"ITE/Pre-U/JC"];   //default value
    } else {
        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"highest_edu_lvl"] integerValue]] ;
    }
    
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddPostCode rowType:XLFormRowDescriptorTypeInteger title:@"Address (Post Code)"];
    row.required = YES;
    row.value = address_postcode? address_postcode:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddStreet rowType:XLFormRowDescriptorTypeText title:@"Address (Street)"];
    row.required = YES;
    row.value = address_street? address_street:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddBlock rowType:XLFormRowDescriptorTypeText title:@"Address (Block)"];
    row.required = YES;
    row.value = address_block? address_block:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddUnit rowType:XLFormRowDescriptorTypeText title:@"Address (Unit) - {With #}"];
    row.required = YES;
    row.value = address_unit? address_unit:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddYears rowType:XLFormRowDescriptorTypeText title:@"Address (years stayed)"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"address_num_years"]? [resiPartiDict objectForKey:@"address_num_years"]:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // Consent - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Consent to share particulars, personal information, screening results and other necessary information with the following"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentNUS rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"NUS"];
    row.required = NO;
    if ([resiPartiDict objectForKey:@"consent_nus"] != [NSNull null] && ([resiPartiDict objectForKey:@"consent_nus"])) {
        if (([[resiPartiDict objectForKey:@"consent_nus"] isEqualToString:@"0"]) || ([[resiPartiDict objectForKey:@"consent_nus"] isEqualToString:@"1"]))
            row.value = [resiPartiDict objectForKey:@"consent_nus"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentHPB rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"HPB"];
    row.required = NO;
    if ([resiPartiDict objectForKey:@"consent_hpb"] != [NSNull null] && ([resiPartiDict objectForKey:@"consent_hpb"])) {
        if (([[resiPartiDict objectForKey:@"consent_hpb"] isEqualToString:@"0"]) || ([[resiPartiDict objectForKey:@"consent_hpb"] isEqualToString:@"1"]))
            row.value = [resiPartiDict objectForKey:@"consent_hpb"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentGoodlife rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Goodlife"];
    row.required = NO;
    if ([resiPartiDict objectForKey:@"consent_goodlife"] != [NSNull null] && ([resiPartiDict objectForKey:@"consent_goodlife"])) {
        if (([[resiPartiDict objectForKey:@"consent_goodlife"] isEqualToString:@"0"]) || ([[resiPartiDict objectForKey:@"consent_goodlife"] isEqualToString:@"1"]))
            row.value = [resiPartiDict objectForKey:@"consent_goodlife"];
        else
            row.value = @1;
    } else {
        row.value = @1;
    }
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initClinicalResults {
    
    typeof(self) __weak weakself = self;    //for alertController
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Clinical Results"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *systolic_1;
    systolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic rowType:XLFormRowDescriptorTypeInteger title:@"BP (1. Systolic number)"];
    systolic_1.required = YES;
    systolic_1.value = @0;
    [section addFormRow:systolic_1];
    
    XLFormRowDescriptor *diastolic_1;
    diastolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic rowType:XLFormRowDescriptorTypeInteger title:@"BP (2. Diastolic number)"];
    diastolic_1.required = YES;
    diastolic_1.value = @0;
    [section addFormRow:diastolic_1];
    
    XLFormRowDescriptor *height;
    height = [XLFormRowDescriptor formRowDescriptorWithTag:kHeight rowType:XLFormRowDescriptorTypeInteger title:@"Height (cm)"];
    height.required = YES;
    height.value = @0;
    [section addFormRow:height];
    
    XLFormRowDescriptor *weight;
    weight = [XLFormRowDescriptor formRowDescriptorWithTag:kWeight rowType:XLFormRowDescriptorTypeInteger title:@"Weight (kg)"];
    weight.required = YES;
    weight.value = @0;
    [section addFormRow:weight];
    
    XLFormRowDescriptor *bmi;
    bmi = [XLFormRowDescriptor formRowDescriptorWithTag:kBMI rowType:XLFormRowDescriptorTypeText title:@"BMI"];
    bmi.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kHeight, kWeight]];
    bmi.value = @([weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2));
    [section addFormRow:bmi];
    
    weight.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        bmi.value = @([weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2));
    };
    height.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        bmi.value = @([weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2));
    };
    
    bmi.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([bmi.value doubleValue] > 30) {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Please refer for consult if BMI > 30" preferredStyle:UIAlertControllerStyleActionSheet];
//                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
//                [weakself.navigationController presentViewController:alert animated:YES completion:nil];
            }
        }
    };
    
    XLFormRowDescriptor *waist;
    waist = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistCircum rowType:XLFormRowDescriptorTypeInteger title:@"Waist Circumference (cm)"];
    waist.required = YES;
    waist.value = @0;
    [section addFormRow:waist];
    
    XLFormRowDescriptor *hip;
    hip = [XLFormRowDescriptor formRowDescriptorWithTag:kHipCircum rowType:XLFormRowDescriptorTypeInteger title:@"Hip Circumference (cm)"];
    hip.required = YES;
    hip.value = @0;
    [section addFormRow:hip];
    
    XLFormRowDescriptor *waistHipRatio;
    waistHipRatio = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistHipRatio rowType:XLFormRowDescriptorTypeText title:@"Waist : Hip Ratio (cm)"];
    waistHipRatio.required = YES;
    waistHipRatio.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kWaistCircum, kHipCircum]];
    [section addFormRow:waistHipRatio];
    
    waist.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        waistHipRatio.value = @([waist.value doubleValue] / [hip.value doubleValue]);
    };
    hip.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        waistHipRatio.value = @([waist.value doubleValue] / [hip.value doubleValue]);
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCbg rowType:XLFormRowDescriptorTypeText title:@"CBG"];
    row.required = YES;
    [section addFormRow:row];
    
    
    row.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([row.value doubleValue] > 11.1) {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Random CBG > 11.1" preferredStyle:UIAlertControllerStyleActionSheet];
//                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
//                [weakself.navigationController presentViewController:alert animated:YES completion:nil];
            }
        }
    };
    
    XLFormRowDescriptor *systolic_2;
    systolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic2 rowType:XLFormRowDescriptorTypeInteger title:@"Repeat BP Taking (2nd Systolic)"];
    systolic_2.required = YES;
    systolic_2.value = @0;
    [section addFormRow:systolic_2];
    
    XLFormRowDescriptor *diastolic_2;
    diastolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic2 rowType:XLFormRowDescriptorTypeInteger title:@"Repeat BP Taking (2nd Diastolic)"];
    diastolic_2.required = YES;
    diastolic_2.value = @0;
    [section addFormRow:diastolic_2];
    
    XLFormRowDescriptor *systolic_avg;
    systolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolicAvg rowType:XLFormRowDescriptorTypeText title:@"BP (Avg. of 1st & 2nd systolic)"];
    systolic_avg.required = YES;
    systolic_avg.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kBpSystolic, kBpSystolic2]];
    [section addFormRow:systolic_avg];
    
    
    systolic_2.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            if ([systolic_2.value doubleValue] >= 140) {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"BP Systolic ≥ 140" preferredStyle:UIAlertControllerStyleActionSheet];
//                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
//                [weakself.navigationController presentViewController:alert animated:YES completion:nil];
            }
            systolic_avg.value = @(([systolic_1.value doubleValue]+ [systolic_2.value doubleValue])/2);
        }
        
    };
    
    XLFormRowDescriptor *diastolic_avg;
    diastolic_avg = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolicAvg rowType:XLFormRowDescriptorTypeText title:@"BP (Avg. of 1st & 2nd diastolic)"];
    diastolic_avg.required = YES;
    [section addFormRow:diastolic_avg];
    
    diastolic_avg.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"($%@.value == 0) OR ($%@.value == 0)", kBpDiastolic, kBpDiastolic2]];        //somehow must disable first ... @.@"
    
    diastolic_2.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if ( oldValue != newValue) {
            if ([diastolic_2.value doubleValue] >= 90) {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"BP Diastolic ≥ 90" preferredStyle:UIAlertControllerStyleActionSheet];
//                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
//                [weakself.navigationController presentViewController:alert animated:YES completion:nil];
            }
            diastolic_avg.value = @(([diastolic_1.value integerValue]+ [diastolic_2.value integerValue])/2);
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic3 rowType:XLFormRowDescriptorTypeInteger title:@"Repeat BP Taking (3rd Systolic)"];
    row.required = NO;
    [row.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic3 rowType:XLFormRowDescriptorTypeInteger title:@"Repeat BP Taking (3rd Diastolic)"];
    [row.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    row.required = NO;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

-(id)initScreeningOfRiskFactors {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Screening of Risk Factors"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *riskFactrorsDict = [self.fullScreeningForm objectForKey:@"risk_factors"];
    
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
    if (![[riskFactrorsDict objectForKey:kExYesNo] isEqualToString:@""]) {
        exerciseYesNoRow.value = [[riskFactrorsDict objectForKey:kExYesNo] isEqualToString:@"1"]? @"YES":@"NO";
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
    if (![[riskFactrorsDict objectForKey:kExNoWhy]isEqualToString:@""]) {
        exerciseNoWhyRow.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kExNoWhy] integerValue]];
    }
    [section addFormRow:exerciseNoWhyRow];
    
    XLFormRowDescriptor *exerciseNoOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kExNoOthers
                                                rowType:XLFormRowDescriptorTypeTextView title:@"Others"];
    [exerciseNoOthersRow.cellConfigAtConfigure setObject:@"Type your other reasons here" forKey:@"textView.placeholder"];
    if ([[exerciseNoWhyRow.value formValue] isEqualToNumber:@3]) {
        exerciseNoOthersRow.hidden = @(0);
    } else {
        exerciseNoOthersRow.hidden = @(1);
    }
    exerciseNoOthersRow.value = [riskFactrorsDict objectForKey:kExNoOthers];
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
                                                  title:@"What is your smoking status?"];
    smokingStatusRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Smokes at least once a day"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Smokes but not everyday"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Ex-smoker, now quit"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Never smoked"]
                            ];
    options = smokingStatusRow.selectorOptions;
    if (![[riskFactrorsDict objectForKey:kSmoking]isEqualToString:@""]) {
        smokingStatusRow.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kSmoking] integerValue]];
    }
    smokingStatusRow.required = YES;
    [section addFormRow:smokingStatusRow];
    
    XLFormRowDescriptor *smokingNumYearsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, how many years have you been smoking for?"];
    smokingNumYearsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingNumYearsQRow];
    
    XLFormRowDescriptor *smokingNumYearsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingNumYears rowType:XLFormRowDescriptorTypeInteger title:@"Year(s)"];
    if (![[riskFactrorsDict objectForKey:kSmokingNumYears]isEqualToString:@""]) {
        smokingNumYearsRow.value = [riskFactrorsDict objectForKey:kSmokingNumYears];
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
    
    smokingNumSticksRow.value = [riskFactrorsDict objectForKey:kSmokeNumSticks];
    
    
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
    if (![[riskFactrorsDict objectForKey:kSmokeAfterWaking]isEqualToString:@""]) {
        smokeAfterWakingRow.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kSmokeAfterWaking] integerValue]];
    }
    
    [section addFormRow:smokeAfterWakingRow];
    
    XLFormRowDescriptor *smokingRefrainQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, do you find it difficult to refrain from smoking in places where it is forbidden/not allowed?"];
    smokingRefrainQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingRefrainQRow];
    XLFormRowDescriptor *smokingRefrainRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingRefrain rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    smokingRefrainRow.selectorOptions = @[@"YES", @"NO"];
    
    if (![[riskFactrorsDict objectForKey:kSmokingRefrain] isEqualToString:@""]) {
        smokingRefrainRow.value = [[riskFactrorsDict objectForKey:kSmokingRefrain] isEqualToString:@"1"]? @"YES":@"NO";
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
    if (![[riskFactrorsDict objectForKey:kSmokingWhichNotGiveUp]isEqualToString:@""]) {
        smokingWhichNotGiveUpRow.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kSmokingWhichNotGiveUp] integerValue]];
    }
    
    [section addFormRow:smokingWhichNotGiveUpRow];
    
    XLFormRowDescriptor *smokingMornFreqQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSeven
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, do you smoke more frequently in the morning?"];
    smokingMornFreqQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingMornFreqQRow];
    XLFormRowDescriptor *smokingMornFreqRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingMornFreq rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    smokingMornFreqRow.selectorOptions = @[@"YES", @"NO"];
    //value
    if (![[riskFactrorsDict objectForKey:kSmokingMornFreq] isEqualToString:@""]) {
        smokingMornFreqRow.value = [[riskFactrorsDict objectForKey:kSmokingMornFreq] isEqualToString:@"1"]? @"YES":@"NO";
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
    if (![[riskFactrorsDict objectForKey:kSmokingSickInBed] isEqualToString:@""]) {
        smokingSickInBedRow.value = [[riskFactrorsDict objectForKey:kSmokingSickInBed] isEqualToString:@"1"]? @"YES":@"NO";
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
    if (![[riskFactrorsDict objectForKey:kSmokingAttemptedQuit] isEqualToString:@""]) {
        smokingAttemptedQuitRow.value = [[riskFactrorsDict objectForKey:kSmokingAttemptedQuit] isEqualToString:@"1"]? @"YES":@"NO";
    }
    [section addFormRow:smokingAttemptedQuitRow];
    
    XLFormRowDescriptor *smokingNumQuitAttemptsQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTen
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If you have attempted to quit in the past year, how many quit attempts did you make?"];
    smokingNumQuitAttemptsQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingNumQuitAttemptsQRow];
    XLFormRowDescriptor *smokingNumQuitAttemptsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingNumQuitAttempts rowType:XLFormRowDescriptorTypeNumber title:@"Attempt(s)"];
    //value
    smokingNumQuitAttemptsRow.value = [riskFactrorsDict objectForKey:kSmokingNumQuitAttempts];
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
    if (![[riskFactrorsDict objectForKey:kSmokingIntentionsToCut]isEqualToString:@""]) {
        smokingIntentionsToCutRow.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kSmokingIntentionsToCut] integerValue]];
    }
    
    [section addFormRow:smokingIntentionsToCutRow];

    XLFormRowDescriptor *smokingHowQuitQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwelve
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If ex-smoker, how did you quit smoking? (can tick more than one)"];
    smokingHowQuitQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingHowQuitQRow];
    XLFormRowDescriptor *smokingHowQuitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingHowQuit rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    smokingHowQuitRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"By myself"],
                                         [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"By joining a smoking cessation programme"],
                                         [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"By taking medication"],
                                         [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"With encouragement of family/friends"],
                                        [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Others"]];
  
    //value
    options = smokingHowQuitRow.selectorOptions;
    if (![[riskFactrorsDict objectForKey:kSmokingHowQuit]isEqualToString:@""]) {
        smokingHowQuitRow.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kSmokingHowQuit] integerValue]];
    }
    
    [section addFormRow:smokingHowQuitRow];
    
    XLFormRowDescriptor *smokingHowQuitOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingHowQuitOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    //value
    smokingHowQuitOthersRow.value = [riskFactrorsDict objectForKey:kSmokingHowQuitOthers];
    
    [section addFormRow:smokingHowQuitOthersRow];
    
    if ([[smokingHowQuitRow.value formValue] isEqual:@(4)]) {
            smokingHowQuitOthersRow.hidden = @(0);
    }
    else {
        smokingHowQuitOthersRow.hidden = @(1);
    }
    smokingHowQuitRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (newValue != (id)[NSNull null]) {
            if (oldValue != newValue) {
                if ([[newValue formValue] isEqual:@(4)]) {  //others option
                    smokingHowQuitOthersRow.hidden = @(0);
                } else {
                    smokingHowQuitOthersRow.hidden = @(1);
                }
            }
        }
    };
    
    XLFormRowDescriptor *smokingWhyQuitQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThirteen
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If ex-smoker, why did you choose to quit? (can tick more than one)"];
    smokingWhyQuitQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:smokingWhyQuitQRow];
    XLFormRowDescriptor *smokingWhyQuitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingWhyQuit rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    smokingWhyQuitRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"By myself"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Side effects (eg. Odour)"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Learnt about harm of smoking"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Family/friends' advice"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Too expensive"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Others"]];
    
    options = smokingWhyQuitRow.selectorOptions;
    if (![[riskFactrorsDict objectForKey:kSmokingWhyQuit]isEqualToString:@""]) {
        smokingWhyQuitRow.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kSmokingWhyQuit] integerValue]];
    }
    
    [section addFormRow:smokingWhyQuitRow];
    
    XLFormRowDescriptor *smokingWhyQuitOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingWhyQuitOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    //value
    smokingWhyQuitOthersRow.value = [riskFactrorsDict objectForKey:kSmokingWhyQuitOthers];
    
    [section addFormRow:smokingWhyQuitOthersRow];
    
    if ([[smokingWhyQuitRow.value formValue] isEqual:@(5)]) {
        smokingWhyQuitOthersRow.hidden = @(0);
    }
    else {
        smokingWhyQuitOthersRow.hidden = @(1);
    }
    
    smokingWhyQuitRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if (newValue != (id)[NSNull null]) {
                if ([[newValue formValue] isEqual:@(5)]) {  //others option
                    smokingWhyQuitOthersRow.hidden = @(0);
                } else {
                    smokingWhyQuitOthersRow.hidden = @(1);
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
    if (![[riskFactrorsDict objectForKey:kAlcoholHowOften]isEqualToString:@""]) {
        row.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kAlcoholHowOften] integerValue]];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If drinking, how many years have you been drinking for?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholNumYears rowType:XLFormRowDescriptorTypeNumber title:@"Year(s)"];
    row.value = [riskFactrorsDict objectForKey:kAlcoholNumYears];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you consumed 5 or more drinks (male) or 4 or more drinks (female) in any one drinking session in the past month? (1 alcoholic drink refers to 1 can/small bottle of beer or one glass of wine)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholConsumpn rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (![[riskFactrorsDict objectForKey:kAlcoholConsumpn] isEqualToString:@""]) {
        row.value = [[riskFactrorsDict objectForKey:kAlcoholConsumpn] isEqualToString:@"1"]? @"YES":@"NO";
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
    if (![[riskFactrorsDict objectForKey:kAlcoholIntentToCut]isEqualToString:@""]) {
        row.value = [options objectAtIndex:[[riskFactrorsDict objectForKey:kAlcoholIntentToCut] integerValue]];
    }
    
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

-(id)initDiabetesMellitus {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Diabetes Mellitus"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSDictionary *diabetesDict = [self.fullScreeningForm objectForKey:@"diabetes"];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"1) (a) Has a western-trained doctor ever told you that you have diabetes?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasInformedRow.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (![[diabetesDict objectForKey:@"has_informed"] isEqualToString:@""]) {
        hasInformedRow.value = [[diabetesDict objectForKey:@"has_informed"] isEqualToString:@"1"]? @"YES":@"NO";
    }
    
    hasInformedRow.required = YES;
    [section addFormRow:hasInformedRow];
    
    XLFormRowDescriptor *hasCheckedBloodQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If no to (a), have you checked your blood sugar in the past 3 years?"];
    hasCheckedBloodQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    hasCheckedBloodQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformedRow];
    [section addFormRow:hasCheckedBloodQRow];
    
    XLFormRowDescriptor *hasCheckedBloodRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesCheckedBlood rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    hasCheckedBloodRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"No"],
                                       [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Yes, 2 yrs ago"],
                                       [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Yes, 3 yrs ago"],
                                       [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Yes < 1 yr ago"]];
    hasCheckedBloodRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasInformedRow];
    
    //value
    NSArray *options = hasCheckedBloodRow.selectorOptions;
    if (![[diabetesDict objectForKey:@"checked_blood"]isEqualToString:@""]) {
        hasCheckedBloodRow.value = [options objectAtIndex:[[diabetesDict objectForKey:@"checked_blood"] integerValue]];
    }
    [section addFormRow:hasCheckedBloodRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you seeing your doctor regularly for your diabetes?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (![[diabetesDict objectForKey:@"seeing_doc_regularly"] isEqualToString:@""]) {
        row.value = [[diabetesDict objectForKey:@"seeing_doc_regularly"] isEqualToString:@"1"]? @"YES":@"NO";
    }
    
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you currently prescribed medication for your diabetes?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (![[diabetesDict objectForKey:@"currently_prescribed"] isEqualToString:@""]) {
        row.value = [[diabetesDict objectForKey:@"currently_prescribed"] isEqualToString:@"1"]? @"YES":@"NO";
    }
    
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you taking your diabetes meds regularly? (≥ 90% of time)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    // Segmented Control
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (![[diabetesDict objectForKey:@"taking_regularly"] isEqualToString:@""]) {
        row.value = [[diabetesDict objectForKey:@"taking_regularly"] isEqualToString:@"1"]? @"YES":@"NO";
    }
    
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformedRow];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

-(id) initHyperlipidemia {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Hyperlipidemia"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Hyperlipidemia - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Has a western-trained doctor ever told you that you have high cholesterol?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *hasInformed = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasInformed.selectorOptions = @[@"YES", @"NO"];
    hasInformed.required = YES;
    [section addFormRow:hasInformed];
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo
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
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you seeing your doctor regularly? (regular = every 6 mths or less, or as per doctor scheduled to follow up)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you curently prescribed medication for your high cholesterol?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:row];
    
    XLFormRowDescriptor *prescribed = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    prescribed.selectorOptions = @[@"YES", @"NO"];
    prescribed.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasInformed];
    [section addFormRow:prescribed];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you taking your cholesterol medication regularly?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribed];
    [section addFormRow:row];
    
    // Segmented Control
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLipidTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribed];
    [section addFormRow:row];

    
    return [super initWithForm:formDescriptor];
}

-(id) initHypertension {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Hypertension"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Hyperlipidemia - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Has a western-trained doctor ever told you that you have high BP?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *hasInformed = [XLFormRowDescriptor formRowDescriptorWithTag:kHTHasInformed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasInformed.selectorOptions = @[@"YES", @"NO"];
    hasInformed.required = YES;
    [section addFormRow:hasInformed];
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you checked your BP in the last 1 year?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *checkedBP = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCheckedBP rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    checkedBP.selectorOptions = @[@"YES", @"NO"];
    [section addFormRow:checkedBP];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you seeing your doctor regularly for your high BP?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHTSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you curently prescribed medication for your high BP?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:row];
    
    XLFormRowDescriptor *prescribed = [XLFormRowDescriptor formRowDescriptorWithTag:kHTCurrentlyPrescribed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    prescribed.selectorOptions = @[@"YES", @"NO"];
    prescribed.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", checkedBP];
    [section addFormRow:prescribed];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Are you taking your BP medication regularly?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribed];
    [section addFormRow:row];
    
    // Segmented Control
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHTTakingRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", prescribed];
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
}

-(id) initCancerScreening {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Cancer Screening"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Introduction - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Note:"];
    section.footerTitle = @"Do note the screening criteria below to avoid embarrassment (e.g. asking a male resident about his Pap smear)";
    [formDescriptor addFormSection:section];
    
    // Hyperlipidemia - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you ever been diagnosed with any of these cancers? (tick all that apply)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiCancerDiagnosed rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    row.selectorOptions = @[@"Cervical (子宫颈癌)", @"Breast (乳腺癌)", @"Colorectal (大肠癌)"];
    [section addFormRow:row];
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Do you go for a pap smear regularly? (once every 3 years for sexually active ladies ≤ 69 years old)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *checkedBP = [XLFormRowDescriptor formRowDescriptorWithTag:kPapSmear rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    checkedBP.selectorOptions = @[@"YES", @"NO", @"N.A."];
    [section addFormRow:checkedBP];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Do you go for regular mammograms? (Once every 2 yeas for ladies aged 40-49; yearly for ladies ≥ 50)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHTSeeingDocRegularly rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO", @"N.A."];
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Do you go for FOBT regularly? (once a year for ≥ 50)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *prescribed = [XLFormRowDescriptor formRowDescriptorWithTag:kFobt rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    prescribed.selectorOptions = @[@"YES", @"NO", @"N.A."];
    [section addFormRow:prescribed];
    
    return [super initWithForm:formDescriptor];
}

-(id) initOtherMedicalIssues {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Other Medical Issues"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHeartFailure rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Heart Failure (心脏病)"];
    [section addFormRow:row];
    
    // Lung - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Lung"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCopd rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Chronic Pulmonary Disease (COPD) (慢性肺部疾病)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAsthma rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Asthma (气喘)"];
    [section addFormRow:row];
    
    // Brain - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Brain"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kStroke rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Stroke (脑中风)"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDementia rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dementia (老人痴呆症)"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHemiplegia rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Hemiplegia (偏痴)"];
    [section addFormRow:row];
    
    // Cancer - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Cancer"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSolidOrganCancer rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Solid organ cancer (实体器官癌症)"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBloodCancer rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Blood cancer (eg. Leukemia/Lymphoma) (血症)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMetastaticCancer rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Metastatic cancer (转移癌)"];
    [section addFormRow:row];
    
    // DM and Renal - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Diabetes and Renal"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesWODamage rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Diabetes, without end-organ damage (eg. retinopathy, kidney problems, heart problems, amputation, strokes) (糖尿病－无器官受损）"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesWDamage rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Diabetes, with end organ damage (糖尿病－有器官受损)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKidneyFailure rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Kidney failure (肾功能衰竭)"];
    [section addFormRow:row];
    
    // Gut and Liver - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Gut and Liver"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPepticUlcer rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Peptic Ulcer Disease (消化性溃疡病)"];
    [section addFormRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMildLiver rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Mid Liver Disease (肝病)"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kModerateSevereLiver rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Moderate-to-severe liver disease (has jaundice or ascites) (严重肝病)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    // Misc - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Misc"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVascularDisease rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Peripheral Vascular Disease (血管疾病)"];
    [section addFormRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTissueDisease rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Connective Tissue Disease (eg.Rheumatoid Arthritis (风湿关节炎)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOsteoarthritis rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Osteoarthritis (骨性关节炎)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAids rowType:XLFormRowDescriptorTypeBooleanCheck title:@"AIDS (爱滋病)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive rowType:XLFormRowDescriptorTypeInfo title:@"Other medical conditions:"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    
//    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOtherMedIssues rowType:XLFormRowDescriptorTypeTextView title:@""];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@"Other medical conditions:(specify)" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNA rowType:XLFormRowDescriptorTypeBooleanCheck title:@"N.A."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

-(id) initPrimaryCareSource {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Primary Care Source"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Hyperlipidemia - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If you were sick who would you turn to first for medical treatment/advice? (ie. who is your primary care provider?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *primaryCareSource;
    primaryCareSource = [XLFormRowDescriptor formRowDescriptorWithTag:kCareGiverID
                                                rowType:XLFormRowDescriptorTypeSelectorPush
                                                  title:@""];
    primaryCareSource.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"GP"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Polyclinic"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Hospital"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"TCM Practitioner"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Family"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Friends"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"Nobody, I rely on myself"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"Others"]];
    primaryCareSource.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"GP"];   //default value
    [section addFormRow:primaryCareSource];
    
    XLFormRowDescriptor *sourceOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCareGiverOthers rowType:XLFormRowDescriptorTypeText title:@""];
    sourceOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", primaryCareSource];
    [sourceOthersRow.cellConfigAtConfigure setObject:@"If others, please state" forKey:@"textField.placeholder"];
    [section addFormRow:sourceOthersRow];
    
    
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Which is your main healthcare provider for followup?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *careProvider;
    careProvider = [XLFormRowDescriptor formRowDescriptorWithTag:kCareProviderID
                                                              rowType:XLFormRowDescriptorTypeSelectorPush
                                                                title:@""];
    careProvider.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"N.A."],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"GP"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Polyclinic"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Hospital"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Free Clinic"],
                                          [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Others"]];
    careProvider.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"N.A."];   //default value
    [section addFormRow:careProvider];
    XLFormRowDescriptor *providerOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCareProviderOthers rowType:XLFormRowDescriptorTypeText title:@""];
    providerOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", careProvider];
    [providerOthersRow.cellConfigAtConfigure setObject:@"If others, please state" forKey:@"textField.placeholder"];
    [section addFormRow:providerOthersRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How many times did you visit A&E in past 6 months?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAneVisit rowType:XLFormRowDescriptorTypeInteger title:@"Number of time(s)"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How many times have you been hospitalized in past 1 year?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHospitalized rowType:XLFormRowDescriptorTypeInteger title:@"Number of time(s)"];
    row.required = YES;
    [section addFormRow:row];
    
    
    
    return [super initWithForm:formDescriptor];
}

-(id) initMyHealthAndMyNeighbourhood {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"My Health & My Neighbourhood"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne rowType:XLFormRowDescriptorTypeInfo title:@"Mobility"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *mobilityRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMobility
                                                         rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                           title:@""];
    mobilityRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no problem in walking about"],
                                     [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight problems in walking about"],
                                     [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate problems in walking about"],
                                     [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I have severe problems in walking about"],
                                     [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"I am unable to walk about"]];
    mobilityRow.value = [XLFormOptionsObject formOptionsObjectWithValue:NULL displayText:@"Tap for options"];
    [section addFormRow:mobilityRow];
    
    XLFormRowDescriptor *mobilityAidQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"If you have difficulty walking, what mobility aid are you using?"];
    mobilityAidQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:mobilityAidQRow];
    XLFormRowDescriptor *mobilityAidRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityAid
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    mobilityAidRow.value = [XLFormOptionsObject formOptionsObjectWithValue:NULL displayText:@"Tap for options"];
    mobilityAidRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Walking stick/frame"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Wheelchair-bound"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Bedridden"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Have problems walking but do not use aids"]];
    [section addFormRow:mobilityAidRow];
    
    mobilityRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([[newValue formValue] isEqual:@(0)]) {
                mobilityAidQRow.hidden = @(1);  //hide
                mobilityAidRow.hidden = @(1);  //hide
            } else {
                mobilityAidQRow.hidden = @(0);  //hide
                mobilityAidRow.hidden = @(0);  //hide
            }
        }
    };
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree rowType:XLFormRowDescriptorTypeInfo title:@"Self-care"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSelfCare
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:NULL displayText:@"Tap for options"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no problem washing or dressing myself"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight problems washing or dressing myself"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate problems washing or dressing myself"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I have severe problems washing or dressing myself"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I am unable to wash or dress myself"]];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive rowType:XLFormRowDescriptorTypeInfo title:@"Usual Activities (e.g. work, study, housework, family or leisure activities)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUsualActivities
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no problem doing my usual activities"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight problems doing my usual activities"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate problems doing my usual activities"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I have severe problems doing my usual activities"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I am unable to do my usual activities"]];
row.value = [XLFormOptionsObject formOptionsObjectWithValue:NULL displayText:@"Tap for options"];
    [section addFormRow:row];
    
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
    painRow.value = [XLFormOptionsObject formOptionsObjectWithValue:NULL displayText:@"Tap for options"];
    [section addFormRow:painRow];
    
    XLFormRowDescriptor *painDurQRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"Pain / Discomfort (If resident indicates that he/she has pain - My pain has lasted ≥ 3 months)"];
    painDurQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:painDurQRow];
    
    XLFormRowDescriptor *painDurationRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPainDuration
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@""];
    painDurationRow.selectorOptions = @[@"YES", @"NO"];
    [section addFormRow:painDurationRow];
    
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
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Your health today"];
    section.footerTitle = @"100 means the BEST health you can imagine.\n0 means the WORST health you can imagine.";
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSeven
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"We would like to know how good or bad your health is TODAY. The scale is numbered from 0 to 100"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHealthToday rowType:XLFormRowDescriptorTypeNumber title:@""];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between 0 and 100" regex:@"^(0|[0-9][0-9]|100)$"]];
    row.required = YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Park"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEight
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How long does it take (mins) for you to reach to a park or rest areas where you like to walk and enjoy yourself, playing sports or games, from your house?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kParkTime rowType:XLFormRowDescriptorTypeNumber title:@""];
    row.required = YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Tick all that applies"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelSafe rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel safe when I walk around my neighbourhood by myself at night."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCrimeLow rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel that crime rate (i.e. damage or stealing) is low in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDrunkenPpl rowType:XLFormRowDescriptorTypeBooleanCheck title:@"In the morning, or later in the day, I can see drunken people on the street in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBrokenBottles rowType:XLFormRowDescriptorTypeBooleanCheck title:@"In my neighbourhood, there are broken bottles or trash lying around."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUnclearSigns rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I and my visitors have been lost because of no or unclear signs of directions."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHomelessPpl rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I see destitute or homeless people walking or sitting around in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPublicTrans rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to take public transportations in my neighbourhood (i.e. bus stops, MRT)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSeeDoc rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to see a doctor in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBuyMedi rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to buy medication in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGrocery rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to do grocery shopping in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCommCentre rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to visit community centres in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSSCentres rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to visit social service centres (i.e. Senior Activity Centres, Family Service Centres) in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBankingPost rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to visit banking and post services (banks, post offices, etc.)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReligiousPlaces rowType:XLFormRowDescriptorTypeBooleanCheck title:@"I feel convenient to visit religious places (i.e., temples, churches, synagogue, etc.)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kInteract rowType:XLFormRowDescriptorTypeBooleanCheck title:@"The people in my neighbourhood actively interact with each other (i.e., playing sports together, having meals together, etc.)."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSafePlaces rowType:XLFormRowDescriptorTypeBooleanCheck title:@"There are plenty of safe places to walk or play outdoors in my neighbourhood."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

-(id) initDemographics {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Demographics"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCitizenship rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Citizenship"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Singaporean"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Foreigner"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Permanent Resident"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Stateless"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Singaporean"];   //default value
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
    [section addFormRow:religionRow];
    
    XLFormRowDescriptor *religionOthers = [XLFormRowDescriptor formRowDescriptorWithTag:kReligionOthers rowType:XLFormRowDescriptorTypeText title:@"Other Religion"];
    religionOthers.hidden = @(1);
    [section addFormRow:religionOthers];
    
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
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initCurrentSocioSituation {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Socioeconomic Issues"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTE"];
    section.footerTitle = @"Non-medical barriers have to be addressed in order to improve the resident's health. A multi-disciplinary team is required for this section.";
    [formDescriptor addFormSection:section];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"If interesed in CHAS, visit Pub Med booth at Triage";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiPlan rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Do you have the following?"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Medisave"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Insurance Coverage"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"CPF pay outs"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Pioneer Generation Package (PGP)"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Community Health Assist Scheme (CHAS)"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"If no, will you like to apply for CHAS?"]];
    [section addFormRow:row];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne rowType:XLFormRowDescriptorTypeInfo title:@""];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiADL rowType:XLFormRowDescriptorTypeBooleanCheck title:@"];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiADL rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Insurance Coverage"];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiADL rowType:XLFormRowDescriptorTypeBooleanCheck title:@"CPF pay outs"];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiADL rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Pioneer Generation Package (PGP)"];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiADL rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Community Health Assist Scheme (CHAS)"];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiADL rowType:XLFormRowDescriptorTypeBooleanCheck title:@"If no, will you like to apply for CHAS? (If interesed, visit Pub Med booth at Triage)"];
//    [section addFormRow:row];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    // New section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne rowType:XLFormRowDescriptorTypeInfo title:@"If you have CPF pay outs, what is the amount per month?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCPFAmt rowType:XLFormRowDescriptorTypeNumber title:@"Amount"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"If you have the CHAS card, what colour is it?"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kChasColour rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@" "];
    row.selectorOptions = @[@"Blue", @"Orange", @"N.A."];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree rowType:XLFormRowDescriptorTypeInfo title:@"Is your household currently coping in terms of financial expenses?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *financeCopingRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseCoping rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    financeCopingRow.selectorOptions = @[@"YES", @"NO"];
    financeCopingRow.required = YES;
    [section addFormRow:financeCopingRow];
    
    XLFormRowDescriptor *notCopingReasonRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseCopingReason rowType:XLFormRowDescriptorTypeMultipleSelector title:@"If no, why?"];
//    notCopingReasonRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Medical expenses"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Daily living expenses"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Arrears / Debts"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Others"]];
    notCopingReasonRow.selectorOptions = @[@"Medical expenses", @"Daily living expenses", @"Arrears / Debts", @"Others"];
    notCopingReasonRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", financeCopingRow];
    [section addFormRow:notCopingReasonRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseCopingReasonOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [row.cellConfigAtConfigure setObject:@"Other reason" forKey:@"textField.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", notCopingReasonRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour rowType:XLFormRowDescriptorTypeInfo title:@"What is your employment status?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *EmployStatusRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStatus rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    EmployStatusRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Full time employed"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Part time employed"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Unemployed due to disability"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Unemployed but able to work"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Housewife/Homemaker"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Retiree"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"Student"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"Others"]];
    EmployStatusRow.required = YES;
    [section addFormRow:EmployStatusRow];
    
    XLFormRowDescriptor *EmployStatusOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStatusOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [EmployStatusOthersRow.cellConfigAtConfigure setObject:@"Please specify" forKey:@"textField.placeholder"];
    EmployStatusOthersRow.hidden = @(1);
    [section addFormRow:EmployStatusOthersRow];
    
    EmployStatusRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([[newValue formValue] isEqual:@(7)]) {
                EmployStatusOthersRow.hidden = @(0);  //show
            } else {
                EmployStatusOthersRow.hidden = @(1);  //hide
            }
        }
    };
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive rowType:XLFormRowDescriptorTypeInfo title:@"If unemployed, how does resident manage his/her expenses?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kManageExpenses rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"(max 2 lines)" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSix rowType:XLFormRowDescriptorTypeInfo title:@"What is your average monthly household income?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseholdIncome rowType:XLFormRowDescriptorTypeNumber title:@"$"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSeven rowType:XLFormRowDescriptorTypeInfo title:@"How many people are there in your household?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPplInHouse rowType:XLFormRowDescriptorTypeNumber title:@"No. of person(s):"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEight rowType:XLFormRowDescriptorTypeInfo title:@"Is your household receiving or has received any form of social or financial assistance?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *financeAssist = [XLFormRowDescriptor formRowDescriptorWithTag:kAnyAssist rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    financeAssist.selectorOptions = @[@"YES", @"NO"];
    [section addFormRow:financeAssist];
    
    XLFormRowDescriptor *qSeekHelpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionNine rowType:XLFormRowDescriptorTypeInfo title:@"If no, do you know who to approach if you need help? (e.g. financial, social services)"];
    qSeekHelpRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    qSeekHelpRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", financeAssist];
    [section addFormRow:qSeekHelpRow];
    XLFormRowDescriptor *seekHelpSegmentRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSeekHelp rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    seekHelpSegmentRow.selectorOptions = @[@"YES", @"NO"];
    seekHelpSegmentRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", financeAssist];
    [section addFormRow:seekHelpSegmentRow];
    
#warning removed question. INFORM YOGA!
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTen rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Details of financial/social assistance received  - Type )"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpType rowType:XLFormRowDescriptorTypeText title:@""];
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEleven rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Details of financial/social assistance received  - Organisation )"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpOrg rowType:XLFormRowDescriptorTypeText title:@""];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwelve rowType:XLFormRowDescriptorTypeInfo title:@"If yes, help rendered:"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpDescribe rowType:XLFormRowDescriptorTypeTextView title:@""];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [row.cellConfigAtConfigure setObject:@"Describe the help you received..." forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThirteen rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Details of financial/social assistance received - Amount per month (if applicable)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpAmt rowType:XLFormRowDescriptorTypeNumber title:@""];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFourteen rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Details of financial/social assistance received - Period"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpPeriod rowType:XLFormRowDescriptorTypeText title:@""];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [row.cellConfigAtConfigure setObject:@"Specify the period here" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFifteen rowType:XLFormRowDescriptorTypeInfo title:@"If yes, has the assistance rendered been helpful? (elaboration in Annex A)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpHelpful rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (id) initSocialSupportAssessment {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Social Support Assessment"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTE"];
    section.footerTitle = @"Non-medical barriers have to be addressed in order to improve the resident's health. A multi-disciplinary team is required for this section.";
    [formDescriptor addFormSection:section];
    
    XLFormSectionDescriptor *hasPriCaregiversection = [XLFormSectionDescriptor formSectionWithTitle:@"Primary Caregiver"];
    [formDescriptor addFormSection:hasPriCaregiversection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne rowType:XLFormRowDescriptorTypeInfo title:@"Do you have a Primary Caregiver?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [hasPriCaregiversection addFormRow:row];
    
    XLFormRowDescriptor *hasCaregiverRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHasCaregiver rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasCaregiverRow.selectorOptions = @[@"YES", @"NO"];
    [hasPriCaregiversection addFormRow:hasCaregiverRow];
    
    XLFormSectionDescriptor *careGiverSection = [XLFormSectionDescriptor formSectionWithTitle:@"Caregiver Details"];
    careGiverSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasCaregiverRow];
    [formDescriptor addFormSection:careGiverSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverName rowType:XLFormRowDescriptorTypeText title:@"Name"];
    [careGiverSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverRs rowType:XLFormRowDescriptorTypeText title:@"Relationship"];
    [careGiverSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverContactNum rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [careGiverSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverNric rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    [careGiverSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverAddress rowType:XLFormRowDescriptorTypeText title:@"Address"];
    [careGiverSection addFormRow:row];
    
    XLFormSectionDescriptor *askEmerContactSection = [XLFormSectionDescriptor formSectionWithTitle:@""];
    askEmerContactSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasCaregiverRow];
    [formDescriptor addFormSection:askEmerContactSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"Do you have any emergency contact person?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [askEmerContactSection addFormRow:row];
    XLFormRowDescriptor *hasEmerContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEContact rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasEmerContactRow.selectorOptions = @[@"YES", @"NO"];
    [askEmerContactSection addFormRow:hasEmerContactRow];
    
    XLFormSectionDescriptor *EmerContactSection = [XLFormSectionDescriptor formSectionWithTitle:@"Emergency Contact"];
    EmerContactSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasEmerContactRow];
    [formDescriptor addFormSection:EmerContactSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactName rowType:XLFormRowDescriptorTypeText title:@"Name"];
    [EmerContactSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactRs rowType:XLFormRowDescriptorTypeText title:@"Relationship"];
    [EmerContactSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactNum rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [EmerContactSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactNric rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    [EmerContactSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactAddress rowType:XLFormRowDescriptorTypeText title:@"Address"];
    [EmerContactSection addFormRow:row];
    
    
    //SUPPORT
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Support"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree rowType:XLFormRowDescriptorTypeInfo title:@"Are you getting support from your children/relatives/others"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *getSupportRow = [XLFormRowDescriptor formRowDescriptorWithTag:kGettingSupport rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    getSupportRow.selectorOptions = @[@"YES", @"NO"];
    [section addFormRow:getSupportRow];
    
    XLFormRowDescriptor *multiSupportRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiSupport rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Support in term of:"];
    multiSupportRow.hidden =[NSString stringWithFormat:@"NOT $%@.value contains 'YES'", getSupportRow];
    multiSupportRow.selectorOptions = @[@"Care-giving", @"Food", @"Money", @"Others"];
    [section addFormRow:multiSupportRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSupportOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [row.cellConfigAtConfigure setObject:@"Specify here" forKey:@"textField.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiSupportRow];
    [section addFormRow:row];
    
    
    
    //RELATIVES
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Relatives"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you see or hear from at least once a month?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesContact rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you feel at ease with that you can talk about private matters?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesEase rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSix rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you feel close to such that you could call on them for help?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesClose rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    row.required = YES;
    [section addFormRow:row];
    
    
    //FRIENDS
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Friends"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSeven rowType:XLFormRowDescriptorTypeInfo title:@"How many friends do you see or hear from at least once a month?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsContact rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEight rowType:XLFormRowDescriptorTypeInfo title:@"How many friends do you feel at ease with that you can talk about private matters?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsEase rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionNine rowType:XLFormRowDescriptorTypeInfo title:@"How many of your friends do you feel close to such that you could call on them for help?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsClose rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    row.required = YES;
    [section addFormRow:row];
    
    //SOCIAL SCORE
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Social Score"];
    [formDescriptor addFormSection:section];
    XLFormRowDescriptor *socialScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSocialScore rowType:XLFormRowDescriptorTypeText title:@""];
//    socialScoreRow.disabled = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"0"]];
    socialScoreRow.value = @"not calculating...";
    [section addFormRow:socialScoreRow];
    
    //MEASURING LONELINESS
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Measuring Loneliness"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTen rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel lack of companionship?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLackCompan rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Hardly Ever"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Sometimes"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Often"]];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEleven rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel left out?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelLeftOut rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Hardly Ever"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Sometimes"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Often"]];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwelve rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel isolated from others?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelIsolated rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Hardly Ever"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Sometimes"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Often"]];
    row.required = YES;
    [section addFormRow:row];
    
    //Last part
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThirteen rowType:XLFormRowDescriptorTypeInfo title:@"Are you aware of any community activities?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAwareActivities rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFourteen rowType:XLFormRowDescriptorTypeInfo title:@"Do you participate in any community activities?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kParticipateActivities rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFifteen rowType:XLFormRowDescriptorTypeInfo title:@"Which organisation hosts the activities that you participate in?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *multiOrgActivitiesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiHost rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    multiOrgActivitiesRow.selectorOptions = @[@"Senior Activity Centre (SAC)", @"Family Services Centre (FSC)", @"Community Centre (CC)", @"Residents' Committee (RC)", @"Religious Organisations", @"Self-organised", @"Others"];
    [section addFormRow:multiOrgActivitiesRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHostOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiOrgActivitiesRow];
    [section addFormRow:row];
    
    // Just to avoid keyboard covering the row in the ScrollView
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initRefForDoctorConsult {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Referral for Doctor Consult"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTE"];
    section.footerTitle = @"If it is appropriate to refer the resident doctor consult:\n- If resident is mobile, accompany him/her to the consultation booths at HQ\n- If resident is not mobile, call Ops to send a doctor to the resident's flat\n- Please refer for consult immediately. Teams that wait till they are done with all other units on their list often find that upon return to a previously-covered unit, the resident has gone out";
    [formDescriptor addFormSection:section];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"The resident has gone for/received the following: (Check all that apply)"];
    [formDescriptor addFormSection:section];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReferralChecklist rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Checklist:"];
//    row.required = YES;
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Doctor's consultation"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Doctor's referral"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"SERI"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"SERI referral"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Dental"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"Dental referral"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"Mammogram referral"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(8) displayText:@"FIT kit"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(9) displayText:@"Pap smear referral"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"Phlebotomy (Blood test)"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(11) displayText:@"N.A."]];
//    row.required = YES;
//    [section addFormRow:row];
//
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocConsult rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Doctor's consultation"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Doctor's referral"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSeri rowType:XLFormRowDescriptorTypeBooleanCheck title:@"SERI"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSeriRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"SERI referral"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDentalConsult rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dental"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDentalRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dental referral"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMammoRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Mammogram referal"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFitKit rowType:XLFormRowDescriptorTypeBooleanCheck title:@"FIT kit"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPapSmearRef rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Pap smear referral"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhlebotomy rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Phlebotomy (Blood test)"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRefNA rowType:XLFormRowDescriptorTypeBooleanCheck title:@"N.A."];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Doctor's notes"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocNotes
                                                rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Doctor's notes" forKey:@"textView.placeholder"];
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocName
                                                rowType:XLFormRowDescriptorTypeText title:@"Name of Doctor"];
    row.required = NO;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

#pragma mark - Dictionary methods

- (void) saveEntriesIntoDictionary {
    switch([self.sectionID integerValue]) {
        case 0: [self saveNeighbourhood];
            break;
        case 1: [self saveResidentParticulars];
            break;
        case 2: [self saveClinicalResults];
            break;
        case 3: [self saveScreeningOfRiskFactors];
            break;
        case 4: [self saveDiabetesMellitus];
            break;
//        case 5: form = [self saveHyperlipidemia];
//            break;
//        case 6: form = [self saveHypertension];
//            break;
//        case 7: form = [self saveCancerScreening];
//            break;
//        case 8: form = [self saveOtherMedicalIssues];
//            break;
//        case 9: form = [self savePrimaryCareSource];
//            break;
//        case 10: form = [self savetMyHealthAndMyNeighbourhood];
//            break;
//        case 11: form = [self saveDemographics];
//            break;
//        case 12: form = [self saveCurrentPhysicalIssues];
//            break;
//        case 13: form = [self saveCurrentSocioSituation];
//            break;
//        case 14: form = [self saveSocialSupportAssessment];
//            break;
//        case 15: form = [self saveRefForDoctorConsult];
//            break;
    }
}

- (void) saveNeighbourhood {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *neighbourhood = [[self.fullScreeningForm objectForKey:@"neighbourhood"] mutableCopy];
    
    [neighbourhood setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kNeighbourhoodLoc] forKey:kNeighbourhoodLoc];
    [neighbourhood setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kNeighbourhoodOthers] forKey:kNeighbourhoodOthers];

    [self.fullScreeningForm setObject:neighbourhood forKey:@"neighbourhood"];
    
}

- (void) saveResidentParticulars {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *resi_particulars = [[self.fullScreeningForm objectForKey:@"resi_particulars"] mutableCopy];
    
#warning resident_id part is missing...
    
    if ([[fields objectForKey:kGender] isEqualToString:@"Male"]) {
        [resi_particulars setObject:@"M" forKey:kGender];
    } else if ([[fields objectForKey:kGender] isEqualToString:@"Female"]) {
        [resi_particulars setObject:@"F" forKey:kGender];
    }
    
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kName] forKey:@"resident_name"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kNRIC] forKey:kNRIC];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kDOB] forKey:@"birth_year"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kContactNumber] forKey:@"contact_no"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kAddPostCode] forKey:@"address_postcode"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddStreet] forKey:@"address_street"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddBlock] forKey:@"address_block"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddUnit] forKey:@"address_unit"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentNUS] forKey:kConsentNUS];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentHPB] forKey:kConsentHPB];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentGoodlife] forKey:kConsentGoodlife];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddYears] forKey:@"address_num_years"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kContactNumber2] forKey:@"contact_no2"];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSpokenLangOthers] forKey:@"lang_others_text"];
    
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kEthnicity] forKey:kEthnicity];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kMaritalStatus] forKey:kMaritalStatus];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kHighestEduLvl] forKey:@"highest_edu_lvl"];
//
//    if (([fields objectForKey:kAddYears] != [NSNull null]) && ([fields objectForKey:kAddYears])) {
//        [resi_particulars setObject:[fields objectForKey:kAddYears] forKey:];
//    } else {
//        [resi_particulars setObject:@"" forKey:@"address_num_years"];
//    }
    
    
//    if (([fields objectForKey:kContactNumber2] != [NSNull null]) && ([fields objectForKey:kContactNumber2])) {
//        [resi_particulars setObject:[fields objectForKey:kContactNumber2] forKey:];
//    } else {
//        [resi_particulars setObject:@"" forKey:@"contact_no2"];
//    }
    
//    if (([fields objectForKey:kSpokenLangOthers] != [NSNull null]) && ([fields objectForKey:kSpokenLangOthers])) {
//        [resi_particulars setObject:[fields objectForKey:kSpokenLangOthers] forKey:];
//    } else {
//        [resi_particulars setObject:@"" forKey:@"lang_others_text"];
//    }

    
    if ([[fields objectForKey:kSpokenLanguage] count]!=0) {
        NSArray *spokenLangArray = [fields objectForKey:kSpokenLanguage];
        for (int i=0; i<[spokenLangArray count]; i++) {
            
            if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Cantonese"]) [resi_particulars setObject:@"1" forKey:@"lang_canto"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"English"]) [resi_particulars setObject:@"1" forKey:@"lang_english"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hindi"]) [resi_particulars setObject:@"1" forKey:@"lang_hindi"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hokkien"]) [resi_particulars setObject:@"1" forKey:@"lang_hokkien"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Malay"]) [resi_particulars setObject:@"1" forKey:@"lang_malay"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Mandarin"]) [resi_particulars setObject:@"1" forKey:@"lang_mandrin"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Teochew"]) [resi_particulars setObject:@"1" forKey:@"lang_teochew"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Others"]) [resi_particulars setObject:@"1" forKey:@"lang_others"];
        }
    }
    
    NSString *room;
    NSUInteger loc;
    if (([fields objectForKey:kHousingType] != [NSNull null]) && ([fields objectForKey:kHousingType])) {
        NSString *houseType = [fields objectForKey:kHousingType];
        if ([houseType rangeOfString:@"Owned"].location != NSNotFound) {
            [resi_particulars setObject:@"0" forKey:@"housing_owned_rented"];
        } else if ([houseType rangeOfString:@"Rental"].location != NSNotFound) {
            [resi_particulars setObject:@"1" forKey:@"housing_owned_rented"];
        }
        
        loc = [houseType rangeOfString:@"-"].location;
        room = [houseType substringWithRange:NSMakeRange(loc-1, 1)];
        [resi_particulars setObject:room forKey:@"housing_num_rooms"];
    }
    
    [self.fullScreeningForm setObject:resi_particulars forKey:@"resi_particulars"];
}

- (void) saveClinicalResults {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *clinical_results = [[[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"clinical_results"] mutableCopy];
    NSMutableArray *bp_record = [[[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"bp_record"] mutableCopy];
    NSMutableDictionary *individualBpRecord;
    
    //resident_id here
    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kHeight] forKey:@"height_cm"];
    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kWeight] forKey:@"weight_kg"];
    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kBMI] forKey:@"bmi"];
    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kWaistCircum] forKey:kWaistCircum];
    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kHipCircum] forKey:kHipCircum];
    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kWaistHipRatio] forKey:kWaistHipRatio];
    [clinical_results setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCbg] forKey:kCbg];
    //also timestamp is here..
    
    
    individualBpRecord = [[bp_record objectAtIndex:0] mutableCopy];
    //resident_id
    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpSystolicAvg] forKey:@"systolic_bp"];
    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpDiastolicAvg] forKey:@"diastolic_bp"];
    [individualBpRecord setObject:@"0" forKey:@"order_num"];
    [individualBpRecord setObject:@"1" forKey:@"is_avg"];
    //also timestamp is here..
    [bp_record replaceObjectAtIndex:0 withObject:individualBpRecord];
     
    individualBpRecord = [[bp_record objectAtIndex:1] mutableCopy];
    //resident_id
    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpSystolic] forKey:@"systolic_bp"];
    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpDiastolic] forKey:@"diastolic_bp"];
    [individualBpRecord setObject:@"1"forKey:@"order_num"];
    [individualBpRecord setObject:@"0" forKey:@"is_avg"];
    //also timestamp is here..
    [bp_record replaceObjectAtIndex:1 withObject:individualBpRecord];
      
    individualBpRecord = [[bp_record objectAtIndex:2] mutableCopy];
    //resident_id
    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpSystolic2] forKey:@"systolic_bp"];
    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpDiastolic2] forKey:@"diastolic_bp"];
    [individualBpRecord setObject:@"2" forKey:@"order_num"];
    [individualBpRecord setObject:@"0" forKey:@"is_avg"];
    //is_avg is missing
    //also timestamp is here...
    [bp_record replaceObjectAtIndex:2 withObject:individualBpRecord];
       
    individualBpRecord = [[bp_record objectAtIndex:3] mutableCopy];
    //resident_id
    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpSystolic3] forKey:@"systolic_bp"];
    [individualBpRecord setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kBpDiastolic3] forKey:@"diastolic_bp"];
    [individualBpRecord setObject:@"3" forKey:@"order_num"];
    [individualBpRecord setObject:@"0" forKey:@"is_avg"];
    //is_avg is missing
    //also timestamp is here..
    [bp_record replaceObjectAtIndex:3 withObject:individualBpRecord];
    
    NSMutableDictionary *temp = [@{@"clinical_results":clinical_results} mutableCopy];  //just to make it mutable
    
    [self.fullScreeningForm setObject:temp forKey:@"clinical_results"];
    [[self.fullScreeningForm objectForKey:@"clinical_results"] setObject:bp_record forKey:@"bp_record"];
    
}

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
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kSmokingHowQuit] forKey:kSmokingHowQuit];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSmokingHowQuitOthers] forKey:kSmokingHowQuitOthers];
    [risk_factors setObject:[self getStringWithDictionary:fields rowType:SelectorPush formDescriptorWithTag:kSmokingWhyQuit] forKey:kSmokingWhyQuit];
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

- (void) saveDiabetesMellitus {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *diabetes_dict = [[self.fullScreeningForm objectForKey:@"diabetes"] mutableCopy];
    
    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kDiabetesHasInformed] forKey:@"has_informed"];
    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kDiabetesCheckedBlood] forKey:@"checked_blood"];
    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kDiabetesSeeingDocRegularly] forKey:@"seeing_doc_regularly"];
    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kDiabetesCurrentlyPrescribed] forKey:@"currently_prescribed"];
    [diabetes_dict setObject:[self getStringWithDictionary:fields rowType:YesNo formDescriptorWithTag:kDiabetesTakingRegularly] forKey:@"taking_regularly"];
    
    [self.fullScreeningForm setObject:diabetes_dict forKey:@"diabetes"];
}

- (NSString *) getStringWithDictionary:(NSDictionary *)dict
                               rowType:(NSInteger)type
                 formDescriptorWithTag:(NSString *)rowTag {
//                             serverAPI:(NSString *)key {

    
    if (([dict objectForKey:rowTag] == [NSNull null]) || (![dict objectForKey:rowTag])) {    //if  NULL or nil, just return
        return @"";
    }
    NSString *fieldEntry, *returnValue;
    NSArray *multiSelectorArray;
    
    switch (type) {
        case Text: returnValue = [dict objectForKey:rowTag];
            break;
            
        case YesNo: fieldEntry = [dict objectForKey:rowTag];
            if ([fieldEntry isEqualToString:@"YES"]) returnValue = @"1";
            else if([fieldEntry isEqualToString:@"NO"]) returnValue = @"0";
            else returnValue = @"";
            break;
            
        case MultiSelector:
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
            
        default: NSLog(@"default, not found its type");
            break;
    }

    return returnValue;
}

- (void) getDictionaryIntoVariables {
//    NSDictionary *contact_info = [NSDictionary dictionaryWithDictionary:[self.preRegParticularsDict objectForKey:@"contact_info"]];
//    NSDictionary *personal_info = [NSDictionary dictionaryWithDictionary:[self.preRegParticularsDict objectForKey:@"personal_info"]];
//    NSDictionary *spoken_lang = [NSDictionary dictionaryWithDictionary:[self.preRegParticularsDict objectForKey:@"spoken_lang"]];

    NSDictionary *resi_particulars = [self.fullScreeningForm objectForKey:@"resi_particulars"];
    
    address_block = [resi_particulars objectForKey:@"address_block"];
    address_postcode = [resi_particulars objectForKey:@"address_postcode"];
    address_street = [resi_particulars objectForKey:@"address_street"];
    address_unit = [resi_particulars objectForKey:@"address_unit"];
    contact_no = [resi_particulars objectForKey:@"contact_no"];
    
    birth_year = [resi_particulars objectForKey:@"birth_year"];
    gender = [resi_particulars objectForKey:@"gender"];
    if ([gender isEqualToString:@"M"]) {
        gender = @"Male";
    } else if ([gender isEqualToString:@"F"]) {
        gender = @"Female";
    } else {
        gender = @"";
    }
    
    nric = [resi_particulars objectForKey:@"nric"];
    resident_name = [resi_particulars objectForKey:@"resident_name"];
    
    if ([resi_particulars objectForKey:@"lang_canto"] != (id)[NSNull null]) {
        spoken_lang_value = [self getSpokenLangArray:resi_particulars];
    }
    
}

- (NSArray *) getSpokenLangArray: (NSDictionary *) dictionary {
    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
    if([[dictionary objectForKey:@"lang_canto"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
    if([[dictionary objectForKey:@"lang_english"] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
    if([[dictionary objectForKey:@"lang_hindi"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
    if([[dictionary objectForKey:@"lang_hokkien"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
    if([[dictionary objectForKey:@"lang_malay"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
    if([[dictionary objectForKey:@"lang_mandrin"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
    if([[dictionary objectForKey:@"lang_others"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Others"];
    if([[dictionary objectForKey:@"lang_tamil"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
    if([[dictionary objectForKey:@"lang_teochew"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
    
    return spokenLangArray;
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

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

//XLForms stuffs
#import "XLForm.h"

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

NSString *const kNeighbourhoodLoc = @"neighbourhood_location";
NSString *const kNeighbourhoodOthers = @"neighbourhood_location_others";
NSString *const kContactNumber2 = @"contactnumber2";
NSString *const kEthnicity = @"ethnicity";
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
NSString *const kSmokingWhyQuit = @"smoking_why_quit";
NSString *const kAlcoholHowOften = @"alcohol_how_often";
NSString *const kAlcoholNumYears = @"alcohol_num_years";
NSString *const kAlcoholConsumpn = @"alcohol_consumpn";
NSString *const kAlcoholPreference = @"alcohol_preference";
NSString *const kAlcoholIntentToCut = @"alcohol_intent_to_cut";

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(validateBtnPressed:)];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setpreRegParticularsDict :(NSDictionary *)preRegParticularsDict {
    self.preRegParticularsDict = [[NSDictionary alloc] initWithDictionary:preRegParticularsDict];
}

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
        return;
    } else {
        UIAlertController *alertController;
        UIAlertAction *okAction;
        
        alertController = [UIAlertController alertControllerWithTitle:@"Validation success"
                                                              message:@"All required fields are not empty."
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
        okAction = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction *action) {
                                                   // do destructive stuff here
                                               }];

        // note: you can control the order buttons are shown, unlike UIActionSheet
        [alertController addAction:okAction];
        [alertController setModalPresentationStyle:UIModalPresentationPopover];
        [self presentViewController:alertController animated:YES completion:nil];

    }
    //    if (validationErrors.count > 0){
    //        [self showFormValidationError:[validationErrors firstObject]];
    //        return;
    //    }
//    [self.tableView endEditing:YES];
//    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the label text.
//    hud.label.text = NSLocalizedString(@"Uploading...", @"HUD loading title");
//    [self submitPersonalInfo:[self preparePersonalInfoDict]];

    
}

-(id)initNeighbourhood
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Neighbourhood"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
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
    [section addFormRow:neighbourhoodRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourhoodOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    row.hidden = @(YES);
    [section addFormRow:row];
    
    neighbourhoodRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        //        bmi.value = @([weight.value doubleValue] / pow(([height.value doubleValue]/100.0), 2));
        if (oldValue != newValue) {
            if ([[neighbourhoodRow.value formValue] isEqual:@5]) {
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
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"Patient Name"];
    row.required = YES;
        row.value = resident_name? resident_name:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    row.value = gender? gender:@"Male";
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    row.value = nric? nric:@"";
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDOB rowType:XLFormRowDescriptorTypeText title:@"DOB Year"];
    row.required = YES;
    row.value = birth_year? birth_year:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kContactNumber rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    row.required = YES;
    row.value = contact_no? contact_no:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kContactNumber2 rowType:XLFormRowDescriptorTypePhone title:@"Contact Number (2)"];
    row.required = NO;
    //    row.value = [self.retrievedPatientDictionary objectForKey:kContactNumber]? [self.retrievedPatientDictionary objectForKey:kContactNumber]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEthnicity rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Ethnicity"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Chinese"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Indian"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Malay"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Others"]
                            ];
    row.required = NO;
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Chinese"];   //default value
    [section addFormRow:row];
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLanguage rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    row.required = YES;
        spokenLangRow.value = spoken_lang_value? spoken_lang_value:@[] ;
    [section addFormRow:spokenLangRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLangOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", spokenLangRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMaritalStatus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Marital Status"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Divorced"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Married"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Separated"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Single"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Widowed"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Single"];   //default value
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHousingType rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Housing Type"];
    row.selectorOptions = @[@"Owned, 1-room", @"Owned, 2-room", @"Owned, 3-room", @"Owned, 4-room", @"Owned, 5-room", @"Rental, 1-room", @"Rental, 2-room", @"Rental, 3-room", @"Rental, 4-room"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHighestEduLvl rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Highest education level"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"ITE/Pre-U/JC"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"No formal qualifications"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Primary"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Secondary"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"University"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"ITE/Pre-U/JC"];   //default value
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddPostCode rowType:XLFormRowDescriptorTypeNumber title:@"Address (Post Code)"];
    row.required = YES;
    row.value = address_postcode? address_postcode:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddStreet rowType:XLFormRowDescriptorTypeText title:@"Address (Street)"];
    row.required = YES;
    row.value = address_street? address_street:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddBlock rowType:XLFormRowDescriptorTypeText title:@"Address (Block)"];
    row.required = YES;
    row.value = address_block? address_block:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddUnit rowType:XLFormRowDescriptorTypeText title:@"Address (Unit) - {With #}"];
    row.required = YES;
    row.value = address_unit? address_unit:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddYears rowType:XLFormRowDescriptorTypeText title:@"Address (years stayed)"];
    row.required = YES;
    [section addFormRow:row];
    
    // Consent - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Consent to share particulars, personal information, screening results and other necessary information with the following"];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentNUS rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"NUS"];
    row.required = NO;
    row.value = @1;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentHPB rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"HPB"];
    row.required = NO;
    row.value = @1;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentGoodlife rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Goodlife"];
    row.required = NO;
    row.value = @1;
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
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *systolic_1;
    systolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic rowType:XLFormRowDescriptorTypeNumber title:@"BP (1. Systolic number)"];
    systolic_1.required = YES;
    systolic_1.value = @0;
    [section addFormRow:systolic_1];
    
    XLFormRowDescriptor *diastolic_1;
    diastolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic rowType:XLFormRowDescriptorTypeNumber title:@"BP (2. Diastolic number)"];
    diastolic_1.required = YES;
    diastolic_1.value = @0;
    [section addFormRow:diastolic_1];
    
    XLFormRowDescriptor *height;
    height = [XLFormRowDescriptor formRowDescriptorWithTag:kHeight rowType:XLFormRowDescriptorTypeNumber title:@"Height (cm)"];
    height.required = YES;
    height.value = @0;
    [section addFormRow:height];
    
    XLFormRowDescriptor *weight;
    weight = [XLFormRowDescriptor formRowDescriptorWithTag:kWeight rowType:XLFormRowDescriptorTypeNumber title:@"Weight (kg)"];
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Please refer for consult if BMI > 30" preferredStyle:UIAlertControllerStyleActionSheet];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                [weakself.navigationController presentViewController:alert animated:YES completion:nil];
            }
        }
    };
    
    XLFormRowDescriptor *waist;
    waist = [XLFormRowDescriptor formRowDescriptorWithTag:kWaistCircum rowType:XLFormRowDescriptorTypeNumber title:@"Waist Circumference (cm)"];
    waist.required = YES;
    waist.value = @0;
    [section addFormRow:waist];
    
    XLFormRowDescriptor *hip;
    hip = [XLFormRowDescriptor formRowDescriptorWithTag:kHipCircum rowType:XLFormRowDescriptorTypeNumber title:@"Hip Circumference (cm)"];
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Random CBG > 11.1" preferredStyle:UIAlertControllerStyleActionSheet];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                [weakself.navigationController presentViewController:alert animated:YES completion:nil];
            }
        }
    };
    
    XLFormRowDescriptor *systolic_2;
    systolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic2 rowType:XLFormRowDescriptorTypeNumber title:@"Repeat BP Taking (2nd Systolic)"];
    systolic_2.required = YES;
    systolic_2.value = @0;
    [section addFormRow:systolic_2];
    
    XLFormRowDescriptor *diastolic_2;
    diastolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic2 rowType:XLFormRowDescriptorTypeNumber title:@"Repeat BP Taking (2nd Diastolic)"];
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"BP Systolic ≥ 140" preferredStyle:UIAlertControllerStyleActionSheet];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                [weakself.navigationController presentViewController:alert animated:YES completion:nil];
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"BP Diastolic ≥ 90" preferredStyle:UIAlertControllerStyleActionSheet];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                [weakself.navigationController presentViewController:alert animated:YES completion:nil];
            }
            diastolic_avg.value = @(([diastolic_1.value integerValue]+ [diastolic_2.value integerValue])/2);
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBpSystolic3 rowType:XLFormRowDescriptorTypeNumber title:@"Repeat BP Taking (3rd Systolic)"];
    row.required = NO;
    [row.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBpDiastolic3 rowType:XLFormRowDescriptorTypeNumber title:@"Repeat BP Taking (3rd Diastolic)"];
    [row.cellConfigAtConfigure setObject:@"Only if necessary" forKey:@"textField.placeholder"];
    row.required = NO;
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

-(id)initScreeningOfRiskFactors {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Screening of Risk Factors"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Exercise - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Exercise"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Do you participate in any form of physical activity, for at least 20 min per occasion, 3 or more days a week?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kExYesNo rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kExNoWhy rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"If no, why not?"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Because of health condition"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"No time"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Too troublesome"],
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"No time"];   //default value
    [section addFormRow:row];
    
#warning others in previous question!
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If no, why not? - Others"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kExNoOthers
                                                rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Type your other reasons here" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    // Smoking - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Smoking"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmoking
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@"What is your smoking status?"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Smokes at least once a day"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Smokes but not everyday"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Ex-smoker, now quit"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Never smoked"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Never smoked"];   //default value
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, how many years have you been smoking for?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingNumYears rowType:XLFormRowDescriptorTypeNumber title:@"Year(s)"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, what do you smoke? (can tick more than one option)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTypeOfSmoke rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    row.selectorOptions = @[@"Cigarettes", @"Pipe", @"self-rolled leaves \"ang hoon\"", @"Shisha", @"Cigars", @"E-cigarettes", @"Others"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, how many sticks do you smoke a day (average)?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokeNumSticks rowType:XLFormRowDescriptorTypeNumber title:@"Stick(s)"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, how soon after waking do you smoke your first cigarette?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokeAfterWaking
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Within 5 mins"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"5-30 mins"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"More than 30 mins"]];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"More than 30 mins"];   //default value
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, do you find it difficult to refrain from smoking in places where it is forbidden/not allowed?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingRefrain rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, which cigarette would you hate to give up?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingWhichNotGiveUp
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"The first in the morning"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Any other"]];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"The first in the morning"];   //default value
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, do you smoke more frequently in the morning?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingMornFreq rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, do you smoke even if you are sick in bed most of the day?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingSickInBed rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, have you attempted to quit before, in the past year?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingAttemptedQuit rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If you have attempted to quit in the past year, how many quit attempts did you make?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingNumQuitAttempts rowType:XLFormRowDescriptorTypeNumber title:@"Attempt(s)"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If smoking currently, what are your intentions towards quitting/cutting down in the forseeable future?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingIntentionsToCut
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I plan to quit in the next 12 months"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I plan to quit, but not within the next 12 months"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I do not plan to quit, but I intend to cut down"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I do not plan to quit or cut down"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I do not plan to quit or cut down"];   //default value
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If ex-smoker, how did you quit smoking? (can tick more than one)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingHowQuit rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    row.selectorOptions = @[@"By myself", @"By joining a smoking cessation programme", @"By taking medication", @"With encouragement of family/friends", @"Others (specify)____"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If ex-smoker, why did you choose to quit? (can tick more than one)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSmokingWhyQuit rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    row.selectorOptions = @[@"Health/medical reasons", @"Side effects (eg. Odour)", @"Learnt about harm of smoking", @"Family/friends' advice", @"Too expensive", @"Others (Specify)____"];
    [section addFormRow:row];
    
    
    // Alcohol - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Alcohol"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
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
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Not drinking"];   //default value
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If drinking, how many years have you been drinking for?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholNumYears rowType:XLFormRowDescriptorTypeNumber title:@"Year(s)"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Have you consumed 5 or more drinks (male) or 4 or more drinks (female) in any one drinking session in the past month? (1 alcoholic drink refers to 1 can/small bottle of beer or one glass of wine)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAlcoholConsumpn rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
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
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Beer"];   //default value
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
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
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

-(id)initDiabetesMellitus {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Diabetes Mellitus"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"1) (a) Has a western-trained doctor ever told you that you have diabetes?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    row.required = YES;
    [section addFormRow:row];
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If no to (a), have you checked your blood sugar in the past 3 years?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you seeing your doctor regularly for your diabetes?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you currently prescribed medication for your diabetes?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"If yes to (a), are you taking your diabetes meds regularly? (≥ 90% of time)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    // Segmented Control
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAneVisit rowType:XLFormRowDescriptorTypeNumber title:@"Number of time(s)"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How many times have you been hospitalized in past 1 year?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHospitalized rowType:XLFormRowDescriptorTypeNumber title:@"Number of time(s)"];
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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobility
                                                         rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                           title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no problem in walking about"],
                                     [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight problems in walking about"],
                                     [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate problems in walking about"],
                                     [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I have severe problems in walking about"],
                                     [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"I am unable to walk about"]];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:NULL displayText:@"Tap for options"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne rowType:XLFormRowDescriptorTypeInfo title:@"If you have difficulty walking, what mobility aid are you using?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityAid
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:NULL displayText:@"Tap for options"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Walking stick/frame"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Wheelchair-bound"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Bedridden"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Have problems walking but do not use aids"]];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne rowType:XLFormRowDescriptorTypeInfo title:@"Self-care"];
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

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"Usual Activities (e.g. work, study, housework, family or leisure activities)"];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"Pain / Discomfort"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPain
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@""];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"I have no pain or discomfort"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"I have slight pain or discomfort"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"I have moderate pain or discomfort"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I have severe pain or discomfort"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"I have extreme pain or discomfort"]];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:NULL displayText:@"Tap for options"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"Pain / Discomfort (If resident indicates that he/she has pain - My pain has lasted ≥ 3 months)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPainDuration
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    [section addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Your health today"];
    section.footerTitle = @"100 means the BEST health you can imagine.\n0 means the WORST health you can imagine.";
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"We would like to know how good or bad your health is TODAY. The scale is numbered from 0 to 100"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHealthToday rowType:XLFormRowDescriptorTypeNumber title:@""];
#warning  need to do validation criterias. between 0 - 100
    row.required = YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Park"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"How long does it take (mins) for you to reach to a park or rest areas where you like to walk and enjoy yourself, playing sports or games, from your house?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kParkTime rowType:XLFormRowDescriptorTypeNumber title:@""];
#warning  need to do validation criterias. between 0 - 100
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
#warning not sure why cannot hide this...
    religionOthers.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", religionRow];
    [section addFormRow:religionOthers];
    
    
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
    
    XLFormRowDescriptor *notCopingReasonRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseCopingReason rowType:XLFormRowDescriptorTypeSelectorPush title:@"If no, why?"];
    notCopingReasonRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Medical expenses"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Daily living expenses"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Arrears / Debts"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Others"]];
    notCopingReasonRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", financeCopingRow];
    [section addFormRow:notCopingReasonRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseCopingReasonOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [row.cellConfigAtConfigure setObject:@"Other reason" forKey:@"textField.placeholder"];
#warning Cannot hide at the moment
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStatusOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [row.cellConfigAtConfigure setObject:@"Please specify" forKey:@"textField.placeholder"];
#warning Cannot hide at the moment
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", EmployStatusRow];
    [section addFormRow:row];
    
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

- (void) getDictionaryIntoVariables {
    NSDictionary *contact_info = [NSDictionary dictionaryWithDictionary:[self.preRegParticularsDict objectForKey:@"contact_info"]];
    NSDictionary *personal_info = [NSDictionary dictionaryWithDictionary:[self.preRegParticularsDict objectForKey:@"personal_info"]];
    NSDictionary *spoken_lang = [NSDictionary dictionaryWithDictionary:[self.preRegParticularsDict objectForKey:@"spoken_lang"]];
    
    address_block = [contact_info objectForKey:@"address_block"];
    address_postcode = [contact_info objectForKey:@"address_postcode"];
    address_street = [contact_info objectForKey:@"address_street"];
    address_unit = [contact_info objectForKey:@"address_unit"];
    contact_no = [contact_info objectForKey:@"contact_no"];
    
    birth_year = [personal_info objectForKey:@"birth_year"];
    gender = [personal_info objectForKey:@"gender"];
    gender = [gender isEqualToString:@"M"]? @"Male":@"Female";
    
    nric = [personal_info objectForKey:@"nric"];
    resident_name = [personal_info objectForKey:@"resident_name"];
    
    if ([spoken_lang objectForKey:@"lang_canto"] != (id)[NSNull null]) {
        spoken_lang_value = [self getSpokenLangArray:spoken_lang];
    }
    
}

- (NSArray *) getSpokenLangArray: (NSDictionary *) spoken_lang_dictionary {
    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
    if([[spoken_lang_dictionary objectForKey:@"lang_canto"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
    if([[spoken_lang_dictionary objectForKey:@"lang_english"] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
    if([[spoken_lang_dictionary objectForKey:@"lang_hindi"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
    if([[spoken_lang_dictionary objectForKey:@"lang_hokkien"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
    if([[spoken_lang_dictionary objectForKey:@"lang_malay"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
    if([[spoken_lang_dictionary objectForKey:@"lang_mandrin"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
    if([[spoken_lang_dictionary objectForKey:@"lang_others"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Others"];
    if([[spoken_lang_dictionary objectForKey:@"lang_tamil"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
    if([[spoken_lang_dictionary objectForKey:@"lang_teochew"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
    
    return spokenLangArray;
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

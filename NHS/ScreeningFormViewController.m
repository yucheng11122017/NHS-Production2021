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

@interface ScreeningFormViewController ()

@end

@implementation ScreeningFormViewController

- (void)viewDidLoad {
    XLFormDescriptor *form;
    
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
            
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitPressed:)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)submitPressed:(UIBarButtonItem * __unused)button
{
    NSLog(@"%@", [self.form formValues]);
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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourhoodLoc rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Screening Neighbourhood"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Bukit Merah"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Eunos Crescent"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Marine Terrace"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Taman Jurong"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Volunteer Training"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Others"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Bukit Merah"];   //default value
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourhoodOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [section addFormRow:row];
    
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
    //    row.value = [self.retrievedPatientDictionary objectForKey:kName]? [self.retrievedPatientDictionary objectForKey:kName]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    //    row.value = [self.retrievedPatientDictionary objectForKey:kGender]? [self.retrievedPatientDictionary objectForKey:kGender]:@"Male";
    row.value = @"Male";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    //    row.value = [self.retrievedPatientDictionary objectForKey:kNRIC]? [self.retrievedPatientDictionary objectForKey:kNRIC]:@"";
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDOB rowType:XLFormRowDescriptorTypeText title:@"DOB Year"];
    row.required = YES;
    //    row.value = [self.retrievedPatientDictionary objectForKey:kDOB]? [self.retrievedPatientDictionary objectForKey:kDOB]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kContactNumber rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    row.required = YES;
    //    row.value = [self.retrievedPatientDictionary objectForKey:kContactNumber]? [self.retrievedPatientDictionary objectForKey:kContactNumber]:@"";
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
    //    spokenLangRow.value = [self.retrievedPatientDictionary objectForKey:kSpokenLanguage]? [self.retrievedPatientDictionary objectForKey:kSpokenLanguage]:@[] ;
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
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Divorced"];   //default value
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
    //    row.value = [self.retrievedPatientDictionary objectForKey:kAddPostCode]? [self.retrievedPatientDictionary objectForKey:kAddPostCode]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddStreet rowType:XLFormRowDescriptorTypeText title:@"Address (Street)"];
    row.required = YES;
    //    row.value = [self.retrievedPatientDictionary objectForKey:kAddStreet]? [self.retrievedPatientDictionary objectForKey:kAddStreet]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddBlock rowType:XLFormRowDescriptorTypeText title:@"Address (Block)"];
    row.required = YES;
    //    row.value = [self.retrievedPatientDictionary objectForKey:kAddUnit]? [self.retrievedPatientDictionary objectForKey:kAddUnit]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddUnit rowType:XLFormRowDescriptorTypeText title:@"Address (Unit) - {With #}"];
    row.required = YES;
    //    row.value = [self.retrievedPatientDictionary objectForKey:kAddBlock]? [self.retrievedPatientDictionary objectForKey:kAddBlock]:@"";
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
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Resident Particulars"];
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
                                                  title:@"Exercise (Do you participate in any form of physical activity, for at least 20 min per occasion, 3 o more days a week?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kExYesNo rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    row.selectorOptions = @[@"YES", @"NO"];
    row.value = @"NO";
    [section addFormRow:row];
    
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kExNoWhy rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Exercise (If no, why not?)"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Because of health condition"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"No time"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Too troublesome"],
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"No time"];   //default value
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Exercise (If no, why not? - Others)"];
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
                                                  title:@"Have you consumed 5 or more drinks (male) or 4 or more drinks (female) in any one dirnking session in the past month? (1 alcoholic drink refers to 1 can/small bottle of beer or one glass of wine)"];
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
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Cancer"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesWODamage rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Diabetes, without end-organ damage (eg. retinopathy, kidney problems, heart problems, amputation, strokes) (糖尿病－无器官受损）"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesWDamage rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Diabetes, w/ end organ damage (糖尿病－有器官受损)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKidneyFailure rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Kidney failure (肾功能衰竭)"];
    [section addFormRow:row];
    
    // Git and Liver - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Git and Liver"];
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
    XLFormRowDescriptor *providerOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCareProviderOthers rowType:XLFormRowDescriptorTypeText title:@"hello"];
    providerOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", careProvider];
    [providerOthersRow.cellConfigAtConfigure setObject:@"If others, please state" forKey:@"textField.placeholder"];
    [section addFormRow:providerOthersRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Which is your main healthcare provider for followup?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
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

    
    
    
    
    
    
    

    return [super initWithForm:formDescriptor];
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

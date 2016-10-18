//
//  FollowUpFormViewController.m
//  NHS
//
//  Created by Nicholas Wong on 9/18/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "FollowUpFormViewController.h"
#import "ServerComm.h"
#import "SVProgressHUD.h"

//XLForms stuffs
#import "XLForm.h"
#import "AppConstants.h"

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

typedef enum typeOfFollowUp {
    houseVisit,
    phoneCall
} typeOfFollowUp;

NSString *const kDateDay = @"date_dd";
NSString *const kDateMonth = @"date_mm";
NSString *const kDateYear = @"date_yyyy";
NSString *const kFUDocName = @"doc_name";

//From screening form
//NSString *const kName = @"resident_name";
//NSString *const kGender = @"gender";    //dropdown
//NSString *const kNRIC = @"nric";
//NSString *const kDOB = @"birth_year";
//NSString *const kContactNo = @"contact_no";
//NSString *const kAddPostcode = @"address_postcode";
//NSString *const kAddStreet = @"address_street";
//NSString *const kAddBlock = @"address_block";
//NSString *const kAddUnit = @"address_unit";


/****** HOUSE VISIT ******/
//Clinical Results
NSString *const kFUHeight = @"height_cm";
NSString *const kFUWeight = @"weight_kg";
NSString *const kFUBMI = @"bmi";      //auto-generated

//Diabetes Mellitus - CBG reading
NSString *const kFUCBG = @"cbg";

//Hypertension - BP Reading
NSString *const kSysBP_1 = @"systolic_bp_1";
NSString *const kDiaBP_1 = @"diastolic_bp_1";
NSString *const kSysBP_2 = @"systolic_bp_2";
NSString *const kDiaBP_2 = @"diastolic_bp_2";

//Medical/Social Issues
NSString *const kMedIssues = @"med_issues";
NSString *const kSocialIssues = @"soc_issues";

//Post Home Visit Management Plan
NSString *const kAction = @"action";
NSString *const kUrgent = @"urgent";
NSString *const kPhoneCall = @"phone_call";
NSString *const kHomeVisit = @"home_visit";
NSString *const kDischarge = @"discharge";
NSString *const kFUDocNotes = @"doc_notes";
// NSString *const kDocName = @"doc_name";  //same field as the above
NSString *const kDocSignature = @"doc_sign";

/****** PHONE CALL ******/
NSString *const kCallTime = @"call_time";
NSString *const kCallerName = @"caller_name";
NSString *const kNotes = @"notes";

/****** SOCIAL WORK ******/
NSString *const kCaseRanking = @"case_ranking";
NSString *const kDoneBy = @"done_by";
NSString *const kFollowUpDate = @"follow_up_date";
NSString *const kFollowUpType = @"follow_up_type";
NSString *const kFollowUpTypeOrg = @"follow_up_type_org";
NSString *const kIssues = @"issues";
NSString *const kCaseStatusInfo = @"case_status_info";
NSString *const kFollowUpInfo = @"follow_up_info";


@interface FollowUpFormViewController () {
    int success_count;
}

@property (strong, nonatomic) XLFormDescriptor * formDescriptor;

@end

@implementation FollowUpFormViewController

- (void)viewDidLoad {
    
    if ([self.typeOfFollowUp isEqualToNumber:[NSNumber numberWithInt:houseVisit]]) {
        XLFormViewController *form = [self initHouseVisit];       //must init first before [super viewDidLoad]
        NSLog(@"%@", [form class]);
    } else if ([self.typeOfFollowUp isEqualToNumber:[NSNumber numberWithInt:phoneCall]]){
        XLFormViewController *form = [self initPhoneCall];       //must init first before [super viewDidLoad]
        NSLog(@"%@", [form class]);
    } else {
        XLFormViewController *form = [self initSocialWork];       //must init first before [super viewDidLoad]
        NSLog(@"%@", [form class]);
    }
    if ([_viewForm isEqualToNumber:@1]) {
        [self.form setDisabled:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(editPressed:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(submitPressed:)];

    }
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backBtnPressed:)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id)initHouseVisit
{
    self.formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New Form"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *resiPartiDict = self.residentParticulars;
    
    self.formDescriptor.assignFirstResponderOnShow = YES;
    
    NSDictionary *house_volunteer, *house_mgmt_plan, *house_med_soc, *house_clinical, *house_cbg;
    NSArray *house_bp_record;
    house_bp_record = [self.downloadedForm objectForKey:@"house_bp_record"];
    house_cbg = [self.downloadedForm objectForKey:@"house_cbg"];
    house_clinical = [self.downloadedForm objectForKey:@"house_clinical"];
    house_med_soc = [self.downloadedForm objectForKey:@"house_med_soc"];
    house_mgmt_plan = [self.downloadedForm objectForKey:@"house_mgmt_plan"];
    house_volunteer = [self.downloadedForm objectForKey:@"house_volunteer"];
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Details of Home Visit"];
    [self.formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDateDay rowType:XLFormRowDescriptorTypeInteger title:@"Date of Home Visit (dd)"];
    row.required = YES;
    row.value = [house_volunteer objectForKey:kDateDay]? [house_volunteer objectForKey:kDateDay]:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDateMonth rowType:XLFormRowDescriptorTypeInteger title:@"Date of Home Visit (mm)"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
  row.value = [house_volunteer objectForKey:kDateMonth]? [house_volunteer objectForKey:kDateMonth]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDateYear rowType:XLFormRowDescriptorTypeInteger title:@"Date of Home Visit (yyyy)"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.value = [house_volunteer objectForKey:kDateYear]? [house_volunteer objectForKey:kDateYear]:@"";
    [section addFormRow:row];
    
    XLFormRowDescriptor *docNameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFUDocName rowType:XLFormRowDescriptorTypeName title:@"Name of Doctor"];
    docNameRow.required = YES;
    docNameRow.value = [house_volunteer objectForKey:kFUDocName]? [house_volunteer objectForKey:kFUDocName]:@"";
    [docNameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:docNameRow];
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Subject Particulars"];
    [self.formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeName title:@"Name *"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"resident_name"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender *"];
    row.selectorOptions = @[@"Male", @"Female"];
    NSString *genderMF = [resiPartiDict objectForKey:@"gender"];
    if ([genderMF isEqualToString:@"M"]) {
        row.value = @"Male";
    } else if ([genderMF isEqualToString:@"F"]) {
        row.value = @"Female";
    }
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC *"];
    row.value = [resiPartiDict objectForKey:@"nric"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDOB rowType:XLFormRowDescriptorTypeInteger title:@"Year of Birth *"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"birth_year"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kContactNumber rowType:XLFormRowDescriptorTypePhone title:@"Contact No *"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"contact_no"];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddPostCode rowType:XLFormRowDescriptorTypeInteger title:@"Address (Post Code) *"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"address_postcode"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddStreet rowType:XLFormRowDescriptorTypeName title:@"Address (Street) *"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"address_street"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddBlock rowType:XLFormRowDescriptorTypeText title:@"Address (Block) *"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"address_block"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddUnit rowType:XLFormRowDescriptorTypeText title:@"Address (Unit)* - {With #}"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"address_unit"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];


    section = [XLFormSectionDescriptor formSectionWithTitle:@"Clinical Results (general)"];
    [self.formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *height;
    height = [XLFormRowDescriptor formRowDescriptorWithTag:kFUHeight rowType:XLFormRowDescriptorTypeNumber title:@"Height (cm)"];
    height.value = [house_clinical objectForKey:kFUHeight]? [house_clinical objectForKey:kFUHeight]:@"";
    
    [section addFormRow:height];
    
    XLFormRowDescriptor *weight;
    weight = [XLFormRowDescriptor formRowDescriptorWithTag:kFUWeight rowType:XLFormRowDescriptorTypeNumber title:@"Weight (kg)"];
    weight.value = [house_clinical objectForKey:kFUWeight]? [house_clinical objectForKey:kFUWeight]:@"";
    [section addFormRow:weight];
    
    XLFormRowDescriptor *bmi;
    bmi = [XLFormRowDescriptor formRowDescriptorWithTag:kFUBMI rowType:XLFormRowDescriptorTypeText title:@"BMI"];
    bmi.value = [house_clinical objectForKey:kFUBMI]? [house_clinical objectForKey:kFUBMI]:@"";
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
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Diabetes Mellitus - CBG Reading"];
    [self.formDescriptor addFormSection:section];
    
    
    XLFormRowDescriptor *cbg;
    cbg = [XLFormRowDescriptor formRowDescriptorWithTag:kFUCBG rowType:XLFormRowDescriptorTypeNumber title:@"CBG Reading (mmol/L)"];
    cbg.value = [house_cbg objectForKey:kFUCBG]? [house_cbg objectForKey:kFUCBG]:@"";
    [section addFormRow:cbg];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Hypertension - BP Readings"];
    [self.formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *systolic_1;
    systolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kSysBP_1 rowType:XLFormRowDescriptorTypeNumber title:@"1st Systolic Reading(mmHg)"];
    systolic_1.value = [house_bp_record objectAtIndex:0]? [[house_bp_record objectAtIndex:0] objectForKey:@"systolic_bp"]:@"";
    [section addFormRow:systolic_1];
    
    XLFormRowDescriptor *diastolic_1;
    diastolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kDiaBP_1 rowType:XLFormRowDescriptorTypeNumber title:@"1st Diastolic Reading(mmHg)"];
    diastolic_1.value = [house_bp_record objectAtIndex:0]? [[house_bp_record objectAtIndex:0] objectForKey:@"diastolic_bp"]:@"";
    [section addFormRow:diastolic_1];
    
    XLFormRowDescriptor *systolic_2;
    systolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kSysBP_2 rowType:XLFormRowDescriptorTypeNumber title:@"2nd Systolic Reading(mmHg)"];
    systolic_2.value = [house_bp_record objectAtIndex:1]? [[house_bp_record objectAtIndex:1] objectForKey:@"systolic_bp"]:@"";
    [section addFormRow:systolic_2];
    
    XLFormRowDescriptor *diastolic_2;
    diastolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kDiaBP_2 rowType:XLFormRowDescriptorTypeNumber title:@"2nd Diastolic Reading(mmHg)"];
    [section addFormRow:diastolic_2];
    diastolic_2.value = [house_bp_record objectAtIndex:1]? [[house_bp_record objectAtIndex:1] objectForKey:@"diastolic_bp"]:@"";
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical/Social Issues"];
    [self.formDescriptor addFormSection:section];
    
    row =[XLFormRowDescriptor formRowDescriptorWithTag:kMedIssues rowType:XLFormRowDescriptorTypeTextView title:@"Medical Issues"];
    row.value = [house_med_soc objectForKey:kMedIssues]? [house_med_soc objectForKey:kMedIssues]:@"";
    [section addFormRow:row];
    
    row =[XLFormRowDescriptor formRowDescriptorWithTag:kSocialIssues rowType:XLFormRowDescriptorTypeTextView title:@"Social Issues"];
    row.value = [house_med_soc objectForKey:kSocialIssues]? [house_med_soc objectForKey:kSocialIssues]:@"";
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Post Home Visit Management Plan"];
    [self.formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *actionToBeTaken = [XLFormRowDescriptor formRowDescriptorWithTag:kAction rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Action to be taken"];
    actionToBeTaken.selectorOptions = @[@"Urgent", @"Phone Call", @"Home Visit", @"Discharge"];
    actionToBeTaken.value = [self getActionToBeTakenForKey:@"house_mgmt_plan"];
    [section addFormRow:actionToBeTaken];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFUDocNotes
                                                rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Doctor's notes" forKey:@"textView.placeholder"];
    row.value = [house_mgmt_plan objectForKey:kFUDocNotes]? [house_mgmt_plan objectForKey:kFUDocNotes]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFUDocName rowType:XLFormRowDescriptorTypeName title:@"Name of Doctor"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    docNameRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            row.value = newValue;
        }
    };

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocSignature rowType:XLFormRowDescriptorTypeText title:@"Doctor's MCR Number"];
    row.value = [house_mgmt_plan objectForKey:kDocSignature]? [house_mgmt_plan objectForKey:kDocSignature]:@"";
    [section addFormRow:row];
    
    return [super initWithForm:self.formDescriptor];
    
}

- (id) initPhoneCall {
    self.formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New Form"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *resiPartiDict = self.residentParticulars;
    
    self.formDescriptor.assignFirstResponderOnShow = YES;
    
    // Caller's Name - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Call Details"];
    [self.formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCallTime rowType:XLFormRowDescriptorTypeDateTime title:@"Time of Call *"];
    row.required = YES;
    row.value = [NSDate dateWithTimeIntervalSinceNow:0];
    if ([_viewForm isEqualToNumber:@1]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        NSDate *oneDayBehind = [dateFormatter dateFromString:[[self.downloadedForm objectForKey:@"calls_caller"] objectForKey:@"call_time"]];
        NSDate *correctDate = [NSDate dateWithTimeInterval:60*60*8 sinceDate:oneDayBehind];
        if ([self.downloadedForm objectForKey:@"calls_caller"]!= (id)[NSNull null]) {
            row.value = correctDate;
        }
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCallerName rowType:XLFormRowDescriptorTypeName title:@"Name of Caller *"];
    row.required = YES;
    row.value = [self.downloadedForm objectForKey:@"calls_caller"]? [[self.downloadedForm objectForKey:@"calls_caller"] objectForKey:kCallerName] : @"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // Subject Particulars - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Subject Particulars"];
    [self.formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeName title:@"Name *"];
    row.required = YES;
    row.value = [resiPartiDict objectForKey:@"resident_name"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC *"];
    row.value = [resiPartiDict objectForKey:@"nric"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // Subject Particulars - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Post Home Visit Management Plan"];
    [self.formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNotes
                                                rowType:XLFormRowDescriptorTypeTextView];
    if ([self.downloadedForm objectForKey:@"calls_mgmt_plan"] != (id) [NSNull null]) {
        row.value = [self.downloadedForm objectForKey:@"calls_mgmt_plan"]? [[self.downloadedForm objectForKey:@"calls_mgmt_plan"] objectForKey:kNotes] : @"";
    }
    [row.cellConfigAtConfigure setObject:@"Notes" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    XLFormRowDescriptor *actionToBeTaken = [XLFormRowDescriptor formRowDescriptorWithTag:kAction rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Action to be taken"];
    actionToBeTaken.selectorOptions = @[@"Urgent", @"Phone Call", @"Home Visit", @"Discharge"];
    actionToBeTaken.value = [self getActionToBeTakenForKey:@"calls_mgmt_plan"];
    [section addFormRow:actionToBeTaken];
    
    return [super initWithForm:self.formDescriptor];
}

- (id) initSocialWork {
    self.formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New Form"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    self.formDescriptor.assignFirstResponderOnShow = YES;
    
    // Social Work - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Social Work"];
    [self.formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaseRanking rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Case Ranking"];
    row.noValueDisplayText = @"Tap here";
    row.selectorOptions = @[@"Immediate", @"R1", @"R1.5", @"R2", @"R3"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDoneBy rowType:XLFormRowDescriptorTypeName title:@"Done by"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUpDate rowType:XLFormRowDescriptorTypeDate title:@"Follow up date"];
    row.required = YES;
    row.value = [NSDate dateWithTimeIntervalSinceNow:0];
//        if ([_viewForm isEqualToNumber:@1]) {
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    
//            dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
//            NSDate *oneDayBehind = [dateFormatter dateFromString:[[self.downloadedForm objectForKey:@"calls_caller"] objectForKey:@"call_time"]];
//            NSDate *correctDate = [NSDate dateWithTimeInterval:60*60*8 sinceDate:oneDayBehind];
//            if ([self.downloadedForm objectForKey:@"calls_caller"]!= (id)[NSNull null]) {
//                row.value = correctDate;
//            }
//        }
    [section addFormRow:row];
    
    XLFormRowDescriptor *followUpTypeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUpType rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Type of follow up"];
    followUpTypeRow.noValueDisplayText = @"Tap here";
    followUpTypeRow.selectorOptions = @[@"Phone Call", @"Home Visit", @"Organisation"];
    [section addFormRow:followUpTypeRow];
    
    XLFormRowDescriptor *nameOfOrgRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUpTypeOrg rowType:XLFormRowDescriptorTypeName title:@"Name of Organisation"];
    nameOfOrgRow.value = @"";
    [nameOfOrgRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    nameOfOrgRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Organisation'", followUpTypeRow];
    [section addFormRow:nameOfOrgRow];
    
//    followUpTypeRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if (newValue != (id)[NSNull null]) {
//                if ([newValue isEqualToString:@"Organisation"]) {
//                    nameOfOrgRow.hidden = @(0);
//                } else {
//                    nameOfOrgRow.hidden = @(1);
//                }
//            }
//        }
//    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIssues rowType:XLFormRowDescriptorTypeText title:@"Presenting issues"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [self.formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"Q1" rowType:XLFormRowDescriptorTypeInfo title:@"Case status & information discussed"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaseStatusInfo rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Type here" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [self.formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUpInfo rowType:XLFormRowDescriptorTypeText title:@"Follow up to be done"];
    [section addFormRow:row];
    
    return [super initWithForm:self.formDescriptor];
}

- (NSArray *) getActionToBeTakenForKey: (NSString *) firstKey {
    if ([self.downloadedForm objectForKey:firstKey] != (id)[NSNull null] && [self.downloadedForm objectForKey:firstKey] != nil) {
        NSDictionary *calls_mgmt_plan = [self.downloadedForm objectForKey:firstKey];
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        if ([[calls_mgmt_plan objectForKey:@"discharge"] isEqualToString:@"1"]) {
            [mutArray addObject:@"Discharge"];
        }
        if ([[calls_mgmt_plan objectForKey:@"urgent"] isEqualToString:@"1"]) {
            [mutArray addObject:@"Urgent"];
        }
        if ([[calls_mgmt_plan objectForKey:@"phone_call"] isEqualToString:@"1"]) {
            [mutArray addObject:@"Phone Call"];
        }
        if ([[calls_mgmt_plan objectForKey:@"home_visit"] isEqualToString:@"1"]) {
            [mutArray addObject:@"Home Visit"];
        }
        return mutArray;
    } else {
        return @[];
    }
}

#pragma mark - Buttons

-(void)backBtnPressed:(id)sender
{
    if ([_viewForm isEqualToNumber:@1]) {   //for form viewing
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (![self.navigationItem.rightBarButtonItem.title isEqualToString:@"Edit"]) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                                      message:@"Do you want to cancel form entry?"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * deleteDraftAction) {
                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                                style:UIAlertActionStyleCancel
                                                              handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)submitPressed:(UIBarButtonItem * __unused)button
{
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
        
        return; //will return if validation got error
    }
    
    [self.tableView endEditing:YES];
    [SVProgressHUD showWithStatus:@"Uploading..."];
    if ([self.typeOfFollowUp isEqualToNumber:[NSNumber numberWithInt:houseVisit]]) {
        [self submitHouseVisitForm];
    } else if ([self.typeOfFollowUp isEqualToNumber:[NSNumber numberWithInt:phoneCall]]) {
        [self submitPhoneCallForm];
    } else {
        [self submitSocialWorkForm];
    }

}

-(void) editPressed:(UIBarButtonItem * __unused)button {
    [self.form setDisabled:NO];
    [self.tableView reloadData];
    
    //change button to submit
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(submitPressed:)];
}


#pragma mark Submission
- (void) submitHouseVisitForm {
    
    NSDictionary *dict = [self prepareVolunteerInfoDict];
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postVolunteerInfoWithDict:dict
                        progressBlock:[self progressBlock]
                         successBlock:[self volunteerInfoSuccessBlock]
                         andFailBlock:[self errorBlock]];
}

- (void) submitPhoneCallForm {
    NSDictionary *dict = [self prepareCallerInfoDict];
    
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postCallerInfoWithDict:dict
                     progressBlock:[self progressBlock]
                      successBlock:[self callerInfoSuccessBlock]
                      andFailBlock:[self errorBlock]];
}

- (void) submitSocialWorkForm {
    NSDictionary *dict = [self prepareSocialWorkDict];
    
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postSocialWorkFollowUpWithDict:dict
                             progressBlock:[self progressBlock]
                              successBlock:[self callerInfoSuccessBlock]
                              andFailBlock:[self errorBlock]];
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"POST in progress...");
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))callerInfoSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        NSDictionary *dict = [self prepareCallsMgmtPlanDictWithCallID:[responseObject objectForKey:@"call_id"]];
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postCallMgmtPlanWithDict:dict
                           progressBlock:[self progressBlock]
                            successBlock:[self callMgmtPlanSuccessBlock]
                            andFailBlock:[self errorBlock]];
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))callMgmtPlanSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        
        NSLog(@"SUBMISSION SUCCESSFUL!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Uploaded", nil)
                                                                                  message:@"Form uploaded successfully!"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction) {
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFollowUpListTable"
                                                                                                                  object:nil
                                                                                                                userInfo:nil];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFollowUpHistoryTable"
                                                                                                                  object:nil
                                                                                                                userInfo:nil];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject)) volunteerInfoSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        success_count = 0; //reset to 0
        
        NSDictionary *dict = [self prepareClinicalDictWithVisitID:[responseObject objectForKey:@"visit_id"]];
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postClinicalWithDict:dict
                       progressBlock:[self progressBlock]
                        successBlock:[self houseVisitCompleteSuccessBlock]
                        andFailBlock:[self errorBlock]];
        
        dict = [self prepareCbgDictWithVisitID:[responseObject objectForKey:@"visit_id"]];
        [client postCbgWithDict:dict
                  progressBlock:[self progressBlock]
                   successBlock:[self houseVisitCompleteSuccessBlock]
                   andFailBlock:[self errorBlock]];
        
        NSArray *array = [self prepareBpRecordArrayWithVisitID:[responseObject objectForKey:@"visit_id"]];
        [client postBpRecordWithArray:array
                        progressBlock:[self progressBlock]
                         successBlock:[self houseVisitCompleteSuccessBlock]
                         andFailBlock:[self errorBlock]];
        
        dict = [self prepareMedSocIssuesDictWithVisitID:[responseObject objectForKey:@"visit_id"]];
        [client postMedicalSocialIssuesWithDict:dict
                                  progressBlock:[self progressBlock]
                                   successBlock:[self houseVisitCompleteSuccessBlock]
                                   andFailBlock:[self errorBlock]];
        
        dict = [self prepareHouseMgmtPlanDictWithCallID:[responseObject objectForKey:@"visit_id"]];
        [client postMgmtPlanWithDict:dict
                       progressBlock:[self progressBlock]
                        successBlock:[self houseVisitCompleteSuccessBlock]
                        andFailBlock:[self errorBlock]];
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject)) houseVisitCompleteSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        success_count++;
        NSLog(@"%@", responseObject);
        if (success_count==5) {
            NSLog(@"SUBMISSION SUCCESSFUL!!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Uploaded", nil)
                                                                                      message:@"Form uploaded successfully!"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * okAction) {
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFollowUpListTable"
                                                                                                                      object:nil
                                                                                                                    userInfo:nil];
                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                              }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
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

#pragma mark - Dictionary Methods

- (NSDictionary *) prepareCallerInfoDict {
    NSString *callerName = [[self.form formValues] objectForKey:kCallerName];
    NSString *callTime = [[self.form formValues] objectForKey:kCallTime];

    return @{@"resident_id": [self.residentParticulars objectForKey:@"resident_id"],
             kCallTime: [callTime description], //to get the NSString
             kCallerName: callerName,
             @"ts": [self getCurrentTimeWithSecondInterval:0]
             };
}

- (NSDictionary *) prepareCallsMgmtPlanDictWithCallID: (NSString *) call_id {
    NSString *notes = [[self.form formValues] objectForKey:kNotes];
    NSNumber *urgent = @0, *phoneCall = @0, *homeVisit = @0, *discharge = @0;
    
    if ([[[self.form formValues] objectForKey:kAction] count]!=0) {
        NSArray *actions = [[self.form formValues] objectForKey:kAction];
        for (int i=0; i<[actions count]; i++) {
            
            if([[actions objectAtIndex:i] isEqualToString:@"Urgent"]) urgent = @1;
            else if([[actions objectAtIndex:i] isEqualToString:@"Phone Call"]) phoneCall = @1;
            else if([[actions objectAtIndex:i] isEqualToString:@"Home Visit"]) homeVisit = @1;
            else if([[actions objectAtIndex:i] isEqualToString:@"Discharge"]) discharge = @1;
        }
    }

    return @{@"call_id": call_id,
             kNotes: notes,
             kUrgent: urgent,
             kPhoneCall: phoneCall,
             kHomeVisit: homeVisit,
             kDischarge: discharge,
             @"ts": [self getCurrentTimeWithSecondInterval:1.0]
             };
}

- (NSDictionary *) prepareVolunteerInfoDict {
    NSString *date_dd = [[self.form formValues] objectForKey:kDateDay];
    NSString *date_mm = [[self.form formValues] objectForKey:kDateMonth];
    NSString *date_yyyy = [[self.form formValues] objectForKey:kDateYear];
    NSString *doc_name = [[self.form formValues] objectForKey:kFUDocName];
    
    return @{@"resident_id": [self.residentParticulars objectForKey:@"resident_id"],
             kDateDay: date_dd,
             kDateMonth: date_mm,
             kDateYear: date_yyyy,
             kFUDocName: doc_name,
             @"ts": [self getCurrentTimeWithSecondInterval:0]
             };
}

- (NSDictionary *) prepareClinicalDictWithVisitID: (NSString *) visit_id {
    NSString *height = [[self.form formValues] objectForKey:kFUHeight];
    NSString *weight = [[self.form formValues] objectForKey:kFUWeight];
    NSString *bmi = [[self.form formValues] objectForKey:kFUBMI];
    
    return @{@"visit_id": visit_id,
             kFUHeight: height,
             kFUWeight: weight,
             kFUBMI: bmi,
             @"ts": [self getCurrentTimeWithSecondInterval:1]
             };
}

- (NSDictionary *) prepareCbgDictWithVisitID: (NSString *) visit_id {
    NSString *cbg = [[self.form formValues] objectForKey:kFUCBG];
    
    return @{@"visit_id": visit_id,
             kFUCBG: cbg,
             @"ts": [self getCurrentTimeWithSecondInterval:2]
             };
}

- (NSArray *) prepareBpRecordArrayWithVisitID: (NSString *) visit_id {
    NSString *systolic_bp1 = [[self.form formValues] objectForKey:kSysBP_1];
    NSString *diastolic_bp1 = [[self.form formValues] objectForKey:kDiaBP_1];
    NSString *systolic_bp2 = [[self.form formValues] objectForKey:kSysBP_2];
    NSString *diastolic_bp2 = [[self.form formValues] objectForKey:kDiaBP_2];
    
    return @[@{@"visit_id": visit_id,
               @"systolic_bp": systolic_bp1,
               @"diastolic_bp": diastolic_bp1,
               @"order_num": @"1",
               @"ts" : [self getCurrentTimeWithSecondInterval:3]},
             @{@"visit_id": visit_id,
               @"systolic_bp": systolic_bp2,
               @"diastolic_bp": diastolic_bp2,
               @"order_num": @"2",
               @"ts": [self getCurrentTimeWithSecondInterval:4]
               }];
}

- (NSDictionary *) prepareMedSocIssuesDictWithVisitID: (NSString *) visit_id {
    NSString *med_issues = [[self.form formValues] objectForKey:kMedIssues];
    NSString *soc_issues = [[self.form formValues] objectForKey:kSocialIssues];
    
    return @{@"visit_id": visit_id,
             kMedIssues: med_issues,
             kSocialIssues: soc_issues,
             @"ts": [self getCurrentTimeWithSecondInterval:5]
             };
}

- (NSDictionary *) prepareHouseMgmtPlanDictWithCallID: (NSString *) visit_id {
    NSString *doc_notes = [[self.form formValues] objectForKey:kFUDocNotes];
    NSString *doc_name = [[self.form formValues] objectForKey:kFUDocName];
    NSString *doc_sign = [[self.form formValues] objectForKey:kDocSignature];
    NSNumber *urgent = @0, *phoneCall = @0, *homeVisit = @0, *discharge = @0;
    
    if ([[[self.form formValues] objectForKey:kAction] count]!=0) {
        NSArray *actions = [[self.form formValues] objectForKey:kAction];
        for (int i=0; i<[actions count]; i++) {
            
            if([[actions objectAtIndex:i] isEqualToString:@"Urgent"]) urgent = @1;
            else if([[actions objectAtIndex:i] isEqualToString:@"Phone Call"]) phoneCall = @1;
            else if([[actions objectAtIndex:i] isEqualToString:@"Home Visit"]) homeVisit = @1;
            else if([[actions objectAtIndex:i] isEqualToString:@"Discharge"]) discharge = @1;
        }
    }

    return @{@"visit_id": visit_id,
             kFUDocNotes: doc_notes,
             kFUDocName: doc_name,
             kDocSignature: doc_sign,
             kUrgent: urgent,
             kPhoneCall: phoneCall,
             kHomeVisit: homeVisit,
             kDischarge: discharge,
             @"ts": [self getCurrentTimeWithSecondInterval:6]
             };
}

- (NSDictionary *) prepareSocialWorkDict {
    
    // CASE RANKING
    NSString *caseRankingString = [[self.form formValues] objectForKey:kCaseRanking];
    NSString *caseRankingIndex = @"";
    if ([caseRankingString isEqualToString:@"Immedidate"]) caseRankingIndex = @"1";
    else if ([caseRankingString isEqualToString:@"R1"]) caseRankingIndex = @"2";
    else if ([caseRankingString isEqualToString:@"R1.5"]) caseRankingIndex = @"3";
    else if ([caseRankingString isEqualToString:@"R2"]) caseRankingIndex = @"4";
    else if ([caseRankingString isEqualToString:@"R3"]) caseRankingIndex = @"5";
    
    // FOLLOW UP TYPE
    NSString *followUpTypeIndex = @"";
    NSString *followUpTypeString = [[self.form formValues] objectForKey:kFollowUpType];
    
    if ([followUpTypeString isEqualToString:@"Phone Call"]) followUpTypeIndex = @"1";
    else if([followUpTypeString isEqualToString:@"Home Visit"]) followUpTypeIndex = @"2";
    else if([followUpTypeString isEqualToString:@"Organisation"]) followUpTypeIndex = @"3";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *longDate = [[self.form formValues] objectForKey:kFollowUpDate];
    NSString *shortDate = [dateFormat stringFromDate:longDate];
//    NSString *shortDate = [longDate stringByReplacingCharactersInRange:NSMakeRange(11, 14) withString:@""];
    
    //make sure no nil value inserted to dictionary
    NSString *followUpTypeOrg = ([[self.form formValues] objectForKey:kFollowUpTypeOrg])? [[self.form formValues] objectForKey:kFollowUpTypeOrg]:@"";
    
    return @{ @"resident_id":[self.residentParticulars objectForKey:@"resident_id"],
             kCaseRanking:caseRankingIndex,
             kDoneBy:[[self.form formValues]objectForKey:kDoneBy],
             kFollowUpDate:shortDate,
             kFollowUpType:followUpTypeIndex,
             kFollowUpTypeOrg:followUpTypeOrg,
             kIssues:[[self.form formValues] objectForKey:kIssues],
             kCaseStatusInfo:[[self.form formValues] objectForKey:kCaseStatusInfo],
             kFollowUpInfo:[[self.form formValues] objectForKey:kFollowUpInfo],
             @"ts":[self getCurrentTimeWithSecondInterval:0]
          };
}



- (NSString *) getCurrentTimeWithSecondInterval: (int) timeInSec {
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    localDateTime = [NSDate dateWithTimeInterval:timeInSec sinceDate:localDateTime];      //add a second
    
    return [[localDateTime description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];

}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

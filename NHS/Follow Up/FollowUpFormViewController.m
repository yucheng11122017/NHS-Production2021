//
//  FollowUpFormViewController.m
//  NHS
//
//  Created by Nicholas Wong on 9/18/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "FollowUpFormViewController.h"
#import "ServerComm.h"
#import "MBProgressHUD.h"

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
NSString *const kFUHeight = @"height";
NSString *const kFUWeight = @"weight";
NSString *const kFUBMI = @"bmi";      //auto-generated

//Diabetes Mellitus - CBG reading
NSString *const kFUCBG = @"cbg";

//Hypertension - BP Reading
NSString *const kSysBP_1 = @"systolic_bp_1";
NSString *const kDiaBP_1 = @"diastolic_bp_1";
NSString *const kSysBP_2 = @"diastolic_bp_2";
NSString *const kDiaBP_2 = @"diastolic_bp_2";

//Medical/Social Issues
NSString *const kMedIssues = @"med_issues";
NSString *const kSocialIssues = @"social_issues";

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


@interface FollowUpFormViewController () {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) XLFormDescriptor * formDescriptor;

@end

@implementation FollowUpFormViewController

- (void)viewDidLoad {
    if ([self.typeOfFollowUp isEqualToNumber:[NSNumber numberWithInt:houseVisit]]) {
        XLFormViewController *form = [self initHouseVisit];       //must init first before [super viewDidLoad]
        NSLog(@"%@", [form class]);
    } else {
        XLFormViewController *form = [self initPhoneCall];       //must init first before [super viewDidLoad]
        NSLog(@"%@", [form class]);
    }
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(submitPressed:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];

    
    
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
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Details of Home Visit"];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [self.formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDateDay rowType:XLFormRowDescriptorTypeInteger title:@"Date of Home Visit (dd)"];
    row.required = YES;
//    row.value = [self.downloadedBloodTestResult objectForKey:kNRIC]? [self.downloadedBloodTestResult objectForKey:kNRIC]:_residentNRIC;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDateMonth rowType:XLFormRowDescriptorTypeInteger title:@"Date of Home Visit (mm)"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    row.value = [self.downloadedBloodTestResult objectForKey:kGlucose]? [self.downloadedBloodTestResult objectForKey:kGlucose]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDateYear rowType:XLFormRowDescriptorTypeInteger title:@"Date of Home Visit (yyyy)"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    row.value = [self.downloadedBloodTestResult objectForKey:kTrigly]? [self.downloadedBloodTestResult objectForKey:kTrigly]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFUDocName rowType:XLFormRowDescriptorTypeText title:@"Name of Doctor"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    row.value = [self.downloadedBloodTestResult objectForKey:kLdl]? [self.downloadedBloodTestResult objectForKey:kLdl]:@"";
    [section addFormRow:row];
    
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
//    height.value = [clinicalResultsDict objectForKey:@"height_cm"];
    [section addFormRow:height];
    
    XLFormRowDescriptor *weight;
    weight = [XLFormRowDescriptor formRowDescriptorWithTag:kFUWeight rowType:XLFormRowDescriptorTypeNumber title:@"Weight (kg)"];
//    weight.value = [clinicalResultsDict objectForKey:@"weight_kg"];
    [section addFormRow:weight];
    
    XLFormRowDescriptor *bmi;
    bmi = [XLFormRowDescriptor formRowDescriptorWithTag:kFUBMI rowType:XLFormRowDescriptorTypeText title:@"BMI"];
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
    //    height.value = [clinicalResultsDict objectForKey:@"height_cm"];
    [section addFormRow:cbg];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Hypertension - BP Readings"];
    [self.formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *systolic_1;
    systolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kSysBP_1 rowType:XLFormRowDescriptorTypeNumber title:@"1st Systolic Reading(mmHg)"];
    [section addFormRow:systolic_1];
    
    XLFormRowDescriptor *diastolic_1;
    diastolic_1 = [XLFormRowDescriptor formRowDescriptorWithTag:kDiaBP_1 rowType:XLFormRowDescriptorTypeNumber title:@"1st Diastolic Reading(mmHg)"];
    [section addFormRow:diastolic_1];
    
    XLFormRowDescriptor *systolic_2;
    systolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kSysBP_2 rowType:XLFormRowDescriptorTypeNumber title:@"2nd Systolic Reading(mmHg)"];
    [section addFormRow:systolic_2];
    
    XLFormRowDescriptor *diastolic_2;
    diastolic_2 = [XLFormRowDescriptor formRowDescriptorWithTag:kDiaBP_2 rowType:XLFormRowDescriptorTypeNumber title:@"2nd Diastolic Reading(mmHg)"];
    [section addFormRow:diastolic_2];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Medical/Social Issues"];
    [self.formDescriptor addFormSection:section];
    
    row =[XLFormRowDescriptor formRowDescriptorWithTag:kDiaBP_2 rowType:XLFormRowDescriptorTypeTextView title:@"Medical Issues"];
    [section addFormRow:row];
    
    row =[XLFormRowDescriptor formRowDescriptorWithTag:kDiaBP_2 rowType:XLFormRowDescriptorTypeTextView title:@"Social Issues"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Post Home Visit Management Plan"];
    [self.formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *actionToBeTaken = [XLFormRowDescriptor formRowDescriptorWithTag:kAction rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Action to be taken"];
    actionToBeTaken.selectorOptions = @[@"Urgent", @"Phone Call", @"Home Visit", @"Discharge"];
    [section addFormRow:actionToBeTaken];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFUDocNotes
                                                rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Doctor's notes" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFUDocName rowType:XLFormRowDescriptorTypeText title:@"Name of Doctor"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    //    row.value = [self.downloadedBloodTestResult objectForKey:kLdl]? [self.downloadedBloodTestResult objectForKey:kLdl]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDocSignature rowType:XLFormRowDescriptorTypeText title:@"Doctor's MCR Number"];
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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCallTime rowType:XLFormRowDescriptorTypeInteger title:@"Time of Call *"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCallerName rowType:XLFormRowDescriptorTypeInteger title:@"Name of Caller *"];
    row.required = YES;
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
    [row.cellConfigAtConfigure setObject:@"Notes" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    XLFormRowDescriptor *actionToBeTaken = [XLFormRowDescriptor formRowDescriptorWithTag:kAction rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Action to be taken"];
    actionToBeTaken.selectorOptions = @[@"Urgent", @"Phone Call", @"Home Visit", @"Discharge"];
    [section addFormRow:actionToBeTaken];
    
    return [super initWithForm:self.formDescriptor];
}


#pragma mark - Buttons

-(void)backBtnPressed:(id)sender
{
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
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the label text.
    hud.label.text = NSLocalizedString(@"Uploading...", @"HUD loading title");
//    [self submitBloodTestResult:[self prepareBloodTestDict]];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

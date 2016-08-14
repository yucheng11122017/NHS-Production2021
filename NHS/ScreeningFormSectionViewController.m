//
//  ScreeningFormSectionViewController.m
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ScreeningFormSectionViewController.h"
#import "PreRegFormViewController.h"
#import "ServerComm.h"
#import "MBProgressHUD.h"
#import "XLForm.h"
#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

NSString *const kNeighborhood = @"neighbourhood";
NSString *const kResidentParticulars = @"resident_particulars";
NSString *const kClinicalResults = @"clinical_results";
NSString *const kScreenOfRiskFactors = @"screening_of_risk_factors";
NSString *const kDiabetesMellitus = @"diabetes_mellitus";
NSString *const kHyperlipidemia = @"hyperlipidemia";
NSString *const kHypertension = @"hypertension";
NSString *const kCancerScreening = @"cancer_screening";
NSString *const kOtherMedIssues = @"other_medical_issues";
NSString *const kPriCareSource = @"primary_care_source";
NSString *const kMyHealthAndMyNeigh = @"my_health_and_my_neighbourhood";
NSString *const kDemographics = @"demographics";
NSString *const kCurPhysicalIssues = @"current_physical_issues";
NSString *const kCurSocioSituation = @"current_socioeconomics_situation";
NSString *const kSocialSuppAssess = @"social_support_assessment";
NSString *const kRefForDoctorConsult = @"referral_for_doctor_consult";
NSString *const kSubmit = @"submit";

@interface ScreeningFormSectionViewController ()

@end

@implementation ScreeningFormSectionViewController

-(void)viewDidLoad
{
    XLFormDescriptor *form = [self init];       //must init first before [super viewDidLoad]

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id)init
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New Screening Form"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Sections"];
    [formDescriptor addFormSection:section];
    
    // RowNavigationShowAccessoryView
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighborhood rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Neighbourhood"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kResidentParticulars rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Resident Particulars"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kClinicalResults rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Clinical Results"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kScreenOfRiskFactors rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Screening of Risk Factors"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiabetesMellitus rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Diabetes Mellitus"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHyperlipidemia rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Hyperlipidemia"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHypertension rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Hypertension"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCancerScreening rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Cancer Screening"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOtherMedIssues rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Other Medical Issues"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPriCareSource rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Primary Care Source"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMyHealthAndMyNeigh rowType:XLFormRowDescriptorTypeBooleanCheck title:@"My Health and My Neighbourhood"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDemographics rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Demographics"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCurPhysicalIssues rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Current Physical Issues"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCurSocioSituation rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Current Socioeconomics Situation"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSocialSuppAssess rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Social Support Assessment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRefForDoctorConsult rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Referral for Doctor Consultation"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSubmit rowType:XLFormRowDescriptorTypeButton title:@"Submit"];
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

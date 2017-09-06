//
//  SocialWorkFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/9/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "SocialWorkFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "KAStatusBar.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"
#import "ScreeningDictionary.h"


typedef enum formName {
    Unused0,
    CurrentSocioeconomicSituation,
    CurrentPhysicalStatus,
    SocialSupportAssessment,
    PsychologicalWellbeing,
    AdditionalSvcs,
    Summary
} formName;


@interface SocialWorkFormVC () {
    XLFormRowDescriptor *relativesContactRow, *relativesEaseRow, *relativesCloseRow, *friendsContactRow, *friendsEaseRow, *friendsCloseRow, *socialScoreRow;
    BOOL internetDCed;
    BOOL isFormFinalized;
}

@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;

@end

@implementation SocialWorkFormVC

- (void)viewDidLoad {
    
    isFormFinalized = false;    //by default
    XLFormViewController *form;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    //must init first before [super viewDidLoad]
    int formNumber = [_formNo intValue];
    switch (formNumber) {
            //case 0 is for demographics
        case 1:
            form = [self initCurrentSocioSituation];
            break;
        case 2:
            form = [self initCurrentPhysStatus];
            break;
        case 3:
            form = [self initSocialSupportAssessment];
            break;
        case 4:
            form = [self initPsychWellbeing];
            break;
        case 5:
            form = [self initAdditionalSvcs];
            break;
        case 6:
            form = [self initSummary];
            break;
        default:
            break;
    }
    
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

    [KAStatusBar dismiss];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];

    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id) initCurrentSocioSituation {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Socioeconomic Situation"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *currentSocioSitDict = [_fullScreeningForm objectForKey:SECTION_CURRENT_SOCIOECO_SITUATION];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSocioEco];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    XLFormSectionDescriptor *infoSection = [XLFormSectionDescriptor formSectionWithTitle:@"Info:"];
    infoSection.footerTitle = [NSString stringWithFormat:@"Name: %@\nEmployment Status: %@\nAvg Monthly Household Income: $%@\n", [defaults objectForKey:kName], [defaults objectForKey:kEmployStat], [defaults objectForKey:kAvgMthHouseIncome]];
    [formDescriptor addFormSection:infoSection];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *copeFinancialRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCopeFin rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you able to cope financially?"];
    [self setDefaultFontWithRow:copeFinancialRow];
    copeFinancialRow.selectorOptions = @[@"Yes", @"No"];
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kCopeFin] != (id)[NSNull null]) {
        copeFinancialRow.value = [self getYesNofromOneZero:currentSocioSitDict[kCopeFin]];
    }
    
    copeFinancialRow.required = YES;
    
    copeFinancialRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:copeFinancialRow];
    
    XLFormRowDescriptor *whyNotCopeFinanRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWhyNotCopeFin rowType:XLFormRowDescriptorTypeMultipleSelector title:@"If not, why?"];
    [self setDefaultFontWithRow:whyNotCopeFinanRow];
    whyNotCopeFinanRow.selectorOptions = @[@"Medical Expenses", @"Housing Rent", @"Arrears/Debts",@"Daily living expenses (e.g. transport)", @"Others"];
    whyNotCopeFinanRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow];
    
    //value
    if (currentSocioSitDict != (id)[NSNull null]) {
        whyNotCopeFinanRow.value = [self getWhyCantCopeArray:currentSocioSitDict];
    }
    [section addFormRow:whyNotCopeFinanRow];
    
    XLFormRowDescriptor *moreWhyNotCopeFinanRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMoreWhyNotCopeFin rowType:XLFormRowDescriptorTypeTextView title:@""];
    [moreWhyNotCopeFinanRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    moreWhyNotCopeFinanRow.hidden = @YES;
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kMoreWhyNotCopeFin] != (id)[NSNull null]) {
        moreWhyNotCopeFinanRow.value = currentSocioSitDict[kMoreWhyNotCopeFin];
    }
    
    [section addFormRow:moreWhyNotCopeFinanRow];
    
    whyNotCopeFinanRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            moreWhyNotCopeFinanRow.hidden = @NO;    //once changed, show it immediately.
        }
    };
    
    XLFormRowDescriptor *whatYouHaveRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"what_you_have" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Do you have the following?"];
    [self setDefaultFontWithRow:whatYouHaveRow];
    whatYouHaveRow.selectorOptions = @[@"Community Health Assist Scheme", @"Pioneer Generation Package", @"Medisave", @"Insurance Coverage", @"CPF Pay Outs"];
    whatYouHaveRow.required = YES;
    
    //value
    if (currentSocioSitDict != (id)[NSNull null]) {
        whatYouHaveRow.value = [self getDoyouHaveFollowingArray:currentSocioSitDict];
    }
    
    [section addFormRow:whatYouHaveRow];
    
    XLFormRowDescriptor *chasColorRow = [XLFormRowDescriptor formRowDescriptorWithTag:kChasColor rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Color of CHAS Card"];
    [self setDefaultFontWithRow:chasColorRow];
    chasColorRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    chasColorRow.required = NO;
    chasColorRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Community Health Assist Scheme'", whatYouHaveRow];
    chasColorRow.selectorOptions = @[@"Blue", @"Orange"];
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kChasColor] != (id)[NSNull null]) {
        chasColorRow.value = currentSocioSitDict[kChasColor];
    }
    
    [section addFormRow:chasColorRow];
    
    XLFormRowDescriptor *cpfAmtRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCpfAmt
                                                                                   rowType:XLFormRowDescriptorTypeInteger
                                                                                     title:@"CPF Payouts amount: $"];
    [self setDefaultFontWithRow:cpfAmtRow];
    cpfAmtRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    cpfAmtRow.required = NO;
    cpfAmtRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'CPF Pay Outs'", whatYouHaveRow];
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kCpfAmt] != (id)[NSNull null]) {
        cpfAmtRow.value = currentSocioSitDict[kCpfAmt];
    }
    
    [section addFormRow:cpfAmtRow];
    
    XLFormRowDescriptor *receiveFinAssistRow = [XLFormRowDescriptor formRowDescriptorWithTag:kReceivingFinAssist rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you receiving any form of social/financial assistance?"];
    [self setDefaultFontWithRow:receiveFinAssistRow];
    receiveFinAssistRow.selectorOptions = @[@"Yes", @"No"];
    receiveFinAssistRow.required = YES;
    receiveFinAssistRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kReceivingFinAssist] != (id)[NSNull null]) {
        receiveFinAssistRow.value = [self getYesNofromOneZero:currentSocioSitDict[kReceivingFinAssist]];
    }
    
    [section addFormRow:receiveFinAssistRow];
    
    XLFormSectionDescriptor *finanAssistSection = [XLFormSectionDescriptor formSectionWithTitle:@"Financial assistance details"];
    [formDescriptor addFormSection:finanAssistSection];
    finanAssistSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", receiveFinAssistRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistName rowType:XLFormRowDescriptorTypeText title:@"Description"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kFinAssistName] != (id)[NSNull null]) {
        row.value = currentSocioSitDict[kFinAssistName];
    }
    
    [finanAssistSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistOrg rowType:XLFormRowDescriptorTypeText title:@"Organisation"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kFinAssistOrg] != (id)[NSNull null]) {
        row.value = currentSocioSitDict[kFinAssistOrg];
    }
    
    [finanAssistSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistAmt rowType:XLFormRowDescriptorTypeText title:@"Amount"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kFinAssistAmt] != (id)[NSNull null]) {
        row.value = currentSocioSitDict[kFinAssistAmt];
    }
    
    [finanAssistSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistPeriod rowType:XLFormRowDescriptorTypeText title:@"Period"];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kFinAssistPeriod] != (id)[NSNull null]) {
        row.value = currentSocioSitDict[kFinAssistPeriod];
    }
    
    [finanAssistSection addFormRow:row];

    XLFormRowDescriptor *finAssistEnufRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistEnuf rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has the assistance rendered been sufficient?"];
    [self setDefaultFontWithRow:finAssistEnufRow];
    finAssistEnufRow.selectorOptions = @[@"Yes", @"No"];
    finAssistEnufRow.required = NO;
    finAssistEnufRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kFinAssistEnuf] != (id)[NSNull null]) {
        finAssistEnufRow.value = [self getYesNofromOneZero:currentSocioSitDict[kFinAssistEnuf]];
    }
    
    [finanAssistSection addFormRow:finAssistEnufRow];
    
    XLFormRowDescriptor *finAssistEnufWhyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistEnufWhy rowType:XLFormRowDescriptorTypeTextView title:@""];
    finAssistEnufWhyRow.required = NO;
    [finAssistEnufWhyRow.cellConfigAtConfigure setObject:@"Elaboration on sufficiency if assistance" forKey:@"textView.placeholder"];
    finAssistEnufWhyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", finAssistEnufRow];
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kFinAssistEnufWhy] != (id)[NSNull null]) {
        finAssistEnufWhyRow.value = currentSocioSitDict[kFinAssistEnufWhy];
    }
    
    [finanAssistSection addFormRow:finAssistEnufWhyRow];
    
    finAssistEnufRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([rowDescriptor.value isEqualToString:@"No"]) {
                finAssistEnufWhyRow.hidden = @(0);
            } else {
                finAssistEnufWhyRow.hidden = @(1);
            }
            
        }
    };
    
    XLFormRowDescriptor *socSvcAwareRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSocSvcAware rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Are you aware of the social services available in your area?"];
    [self setDefaultFontWithRow:socSvcAwareRow];
    socSvcAwareRow.required = NO;
    socSvcAwareRow.hidden = @YES;
    socSvcAwareRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kSocSvcAware] != (id)[NSNull null]) {
        socSvcAwareRow.value = currentSocioSitDict[kSocSvcAware];
    }
    
    [section addFormRow:socSvcAwareRow];
    
    receiveFinAssistRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            if ([rowDescriptor.value isEqual:@"Yes"]) {
                finanAssistSection.hidden = @(0);
                socSvcAwareRow.hidden = @(1);
            } else {
                finanAssistSection.hidden = @(1);
                socSvcAwareRow.hidden = @(0);
                
            }
            
        }
    };
    
    return [super initWithForm:formDescriptor];

}

- (id) initCurrentPhysStatus {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Physical Situation"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Activities of Daily Living"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Can you perform the following activities without assistance? (Tick those activities that the resident CAN perform on his/her own)."];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"multiple_ADL" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Activities"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Bathe/Shower"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Dress"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Eat"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Personal Hygiene and Grooming"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Toileting"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Transfer/Walk"]];
//    row.value = [self getADLArrayFromDict:adlDict andOptions:row.selectorOptions];
    row.noValueDisplayText = @"Tap here for options";
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mobility Status"];
    [self setDefaultFontWithRow:row];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityStatus
                                               rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                 title:@"Mobility Status"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Ambulant", @"Able to walk with assistance (stick/frame)", @"Wheelchair-bound", @"Bed-ridden"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityEquipment
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Do you require mobility equipment in your household? (e.g. non-slip mat, handle bar, etc)"];
    row.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initSocialSupportAssessment {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Social Support Assessment"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
//    NSDictionary *socialSuppAssessmentDict = [self.fullScreeningForm objectForKey:@"social_support"];

    formDescriptor.assignFirstResponderOnShow = YES;


    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTE"];
    section.footerTitle = @"Non-medical barriers have to be addressed in order to improve the resident's health. A multi-disciplinary team is required for this section.";
    [formDescriptor addFormSection:section];

    XLFormSectionDescriptor *hasPriCaregiversection = [XLFormSectionDescriptor formSectionWithTitle:@"Social Network"];
    [formDescriptor addFormSection:hasPriCaregiversection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Do you have a Primary Caregiver?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [hasPriCaregiversection addFormRow:row];

    XLFormRowDescriptor *hasCaregiverRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHasCaregiver rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasCaregiverRow.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[socialSuppAssessmentDict objectForKey:kHasCaregiver] isEqualToString:@""]) {
//        hasCaregiverRow.value = [[socialSuppAssessmentDict objectForKey:kHasCaregiver] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    [hasPriCaregiversection addFormRow:hasCaregiverRow];

    XLFormSectionDescriptor *careGiverSection = [XLFormSectionDescriptor formSectionWithTitle:@"Caregiver Details"];
    careGiverSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasCaregiverRow];
    [formDescriptor addFormSection:careGiverSection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
//    row.value = [socialSuppAssessmentDict objectForKey:kCaregiverName];
    [careGiverSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverRs rowType:XLFormRowDescriptorTypeText title:@"Relationship"];
    [self setDefaultFontWithRow:row];
//    row.value = [socialSuppAssessmentDict objectForKey:kCaregiverRs];
    [careGiverSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverContactNum rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
//    row.value = [socialSuppAssessmentDict objectForKey:kCaregiverContactNum];
    [careGiverSection addFormRow:row];

    XLFormSectionDescriptor *askEmerContactSection = [XLFormSectionDescriptor formSectionWithTitle:@""];
    askEmerContactSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasCaregiverRow];
    [formDescriptor addFormSection:askEmerContactSection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q2" rowType:XLFormRowDescriptorTypeInfo title:@"Do you have any emergency contact person?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [askEmerContactSection addFormRow:row];
    XLFormRowDescriptor *hasEmerContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEContact rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasEmerContactRow.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[socialSuppAssessmentDict objectForKey:kEContact] isEqualToString:@""]) {
//        hasEmerContactRow.value = [[socialSuppAssessmentDict objectForKey:kEContact] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    [askEmerContactSection addFormRow:hasEmerContactRow];

    XLFormSectionDescriptor *EmerContactSection = [XLFormSectionDescriptor formSectionWithTitle:@"Emergency Contact"];
    EmerContactSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasEmerContactRow];
    [formDescriptor addFormSection:EmerContactSection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
//    row.value = [socialSuppAssessmentDict objectForKey:kEContactName];
    [EmerContactSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactRs rowType:XLFormRowDescriptorTypeText title:@"Relationship"];
    [self setDefaultFontWithRow:row];
//    row.value = [socialSuppAssessmentDict objectForKey:kEContactRs];
    [EmerContactSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactNum rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
//    row.value = [socialSuppAssessmentDict objectForKey:kEContactNum];
    [EmerContactSection addFormRow:row];
    
    //Are you a caregiver?
    XLFormSectionDescriptor *hasCaregivingSection = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:hasCaregivingSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q3" rowType:XLFormRowDescriptorTypeInfo title:@"Are you a caregiver for somebody else?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [hasCaregivingSection addFormRow:row];
    
    XLFormRowDescriptor *hasCaregivingRow = [XLFormRowDescriptor formRowDescriptorWithTag:kUCaregiver rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasCaregivingRow.selectorOptions = @[@"YES", @"NO"];
    hasCaregivingRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    [hasCaregivingSection addFormRow:hasCaregivingRow];
    
    //Details of being a caregiver
    XLFormSectionDescriptor *caregivingSection = [XLFormSectionDescriptor formSectionWithTitle:@"Caregiving Details"];
    caregivingSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasCaregivingRow];
    [formDescriptor addFormSection:caregivingSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUCareStress rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you facing caregiver stress?"];
    row.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //    row.value = [socialSuppAssessmentDict objectForKey:kEContactName];
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q4" rowType:XLFormRowDescriptorTypeInfo title:@"Describe your caregiving responsibilities (e.g. frequency, caregiving tasks)"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingDescribe rowType:XLFormRowDescriptorTypeTextView title:@""];
    [caregivingSection addFormRow:row];
    
    XLFormRowDescriptor *rcvCareAssistRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingAssist rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Would you like to receive caregiving assistance?"];
    rcvCareAssistRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:rcvCareAssistRow];
    rcvCareAssistRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [caregivingSection addFormRow:rcvCareAssistRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q5" rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Type of assistance preferred:"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", rcvCareAssistRow];
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingAssistType rowType:XLFormRowDescriptorTypeTextView title:@""];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", rcvCareAssistRow];
    [caregivingSection addFormRow:row];
    
    
    //SUPPORT
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Social Network - Support"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q6" rowType:XLFormRowDescriptorTypeInfo title:@"Are you getting support from your family/relatives/friends?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *getSupportRow = [XLFormRowDescriptor formRowDescriptorWithTag:kGettingSupport rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    getSupportRow.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[socialSuppAssessmentDict objectForKey:kGettingSupport] isEqualToString:@""]) {
//        getSupportRow.value = [[socialSuppAssessmentDict objectForKey:kGettingSupport] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    [section addFormRow:getSupportRow];

    XLFormRowDescriptor *multiSupportRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_support" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Support in terms of:"];
    [self setDefaultFontWithRow:multiSupportRow];
    multiSupportRow.hidden =[NSString stringWithFormat:@"NOT $%@.value contains 'YES'", getSupportRow];
    multiSupportRow.selectorOptions = @[@"Care-giving", @"Food", @"Money", @"Others"];

    //value
//    multiSupportRow.value = [self getSupportArrayFromDict:socialSuppAssessmentDict andOptions:multiSupportRow.selectorOptions];
    [section addFormRow:multiSupportRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"support_others" rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@"Specify here" forKey:@"textField.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiSupportRow];
//    row.value = [socialSuppAssessmentDict objectForKey:kSupportOthers];
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@"MEASURING RISK OF SOCIAL ISOLATION"];
    [formDescriptor addFormSection:section];

    //RELATIVES
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Relatives"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q7" rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you see or hear from at least once a month? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    
    relativesContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesContact rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    relativesContactRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    relativesContactRow.required = YES;

    //value
    NSArray *options = relativesContactRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kRelativesContact] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kRelativesContact] intValue];
//        relativesContactRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:relativesContactRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q8" rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you feel at ease with that you can talk about private matters? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];

    relativesEaseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesEase rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    relativesEaseRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    relativesEaseRow.required = YES;

    //value
    options = relativesEaseRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kRelativesEase] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kRelativesEase] intValue];
//        relativesEaseRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:relativesEaseRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q9" rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you feel close to such that you could call on them for help? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    relativesCloseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesClose rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    relativesCloseRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    relativesCloseRow.required = YES;

    //value
    options = relativesCloseRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kRelativesClose] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kRelativesClose] intValue];
//        relativesCloseRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:relativesCloseRow];


    //FRIENDS
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Friends"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q10" rowType:XLFormRowDescriptorTypeInfo title:@"How many friends do you see or hear from at least once a month? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsContact rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsContactRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    friendsContactRow.required = YES;

    //value
    options = friendsContactRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kFriendsContact] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kFriendsContact] intValue];
//        friendsContactRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:friendsContactRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q11" rowType:XLFormRowDescriptorTypeInfo title:@"How many friends do you feel at ease with that you can talk about private matters? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsEaseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsEase rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsEaseRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    friendsEaseRow.required = YES;

    //value
    options = friendsEaseRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kFriendsEase] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kFriendsEase] intValue];
//        friendsEaseRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:friendsEaseRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q12" rowType:XLFormRowDescriptorTypeInfo title:@"How many of your friends do you feel close to such that you could call on them for help? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsCloseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsClose rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsCloseRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    friendsCloseRow.required = YES;

    //value
    options = friendsCloseRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kFriendsClose] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kFriendsClose] intValue];
//        friendsCloseRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:friendsCloseRow];

    //SOCIAL SCORE
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Social Score"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"kComputeScoreButton" rowType:XLFormRowDescriptorTypeButton title:@"Compute Score"];
    row.action.formSelector = @selector(computeScoreButton:);
    [section addFormRow:row];

    socialScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSocialScore rowType:XLFormRowDescriptorTypeText title:@"Computed Social Score"];
    [self setDefaultFontWithRow:row];
    socialScoreRow.disabled = @(1);
    socialScoreRow.cellConfig[@"textLabel.textColor"] = [UIColor blackColor];
    socialScoreRow.cellConfig[@"textField.textColor"] = [UIColor blueColor];
    [socialScoreRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
//    if (![[socialSuppAssessmentDict objectForKey:kSocialScore] isEqualToString:@""]) {
//        socialScoreRow.value = [socialSuppAssessmentDict objectForKey:kSocialScore];
//    } else {
//        socialScoreRow.value = @"";
//    }

    [section addFormRow:socialScoreRow];

    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q13" rowType:XLFormRowDescriptorTypeInfo title:@"Do you participate in any community activities?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *gotCommActivitiesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kParticipateActivities rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    gotCommActivitiesRow.selectorOptions = @[@"YES", @"NO"];
    

    //value
//    if (![[socialSuppAssessmentDict objectForKey:kParticipateActivities] isEqualToString:@""]) {
//        row.value = [[socialSuppAssessmentDict objectForKey:kParticipateActivities] isEqualToString:@"1"]? @"YES":@"NO";
//    }
    [section addFormRow:gotCommActivitiesRow];
    

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q14" rowType:XLFormRowDescriptorTypeInfo title:@"If yes, where do you participate in such activities?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", gotCommActivitiesRow];
    [section addFormRow:row];
    
    XLFormRowDescriptor *multiOrgActivitiesRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_host" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    multiOrgActivitiesRow.selectorOptions = @[@"Senior Activity Centre (SAC)", @"Family Services Centre (FSC)", @"Community Centre (CC)", @"Residents' Committee (RC)", @"Religious Organisations", @"Self-organised", @"Others"];
    multiOrgActivitiesRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", gotCommActivitiesRow];

    //value
//    multiOrgActivitiesRow.value = [self getOrgArrayFromDict:socialSuppAssessmentDict andOptions:multiOrgActivitiesRow.selectorOptions];

    [section addFormRow:multiOrgActivitiesRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHostOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiOrgActivitiesRow];
    //    row.value = [socialSuppAssessmentDict objectForKey:@"others_text"];
    [section addFormRow:row];
    
    
    
    XLFormRowDescriptor *multiNoCommActivRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_why_not_comm_activities" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"If no, why not?"];
    [self setDefaultFontWithRow:multiNoCommActivRow];
    multiNoCommActivRow.selectorOptions = @[@"Don't know", @"Don't like", @"Mobility Issues", @"Others"];
    multiNoCommActivRow.hidden = @YES;
    gotCommActivitiesRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"YES"])
                multiNoCommActivRow.hidden = @YES;
            else
                multiNoCommActivRow.hidden = @NO;
        }
    };
    [section addFormRow:multiNoCommActivRow];
    
    XLFormRowDescriptor *NoCommActivOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"why_not_comm_activities_others" rowType:XLFormRowDescriptorTypeTextView title:@"Others:"];
    [self setDefaultFontWithRow:NoCommActivOthersRow];
    [NoCommActivOthersRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    NoCommActivOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiNoCommActivRow];
    
    [section addFormRow:NoCommActivOthersRow];

    
    // Just to avoid keyboard covering the row in the ScrollView
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];


    return [super initWithForm:formDescriptor];
}

- (id) initPsychWellbeing {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Psychological Well-being"];
    XLFormSectionDescriptor * section;
//    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Psychotic Disorder"];
    [formDescriptor addFormSection:section];

    
    XLFormRowDescriptor *symptomPsychRow = [XLFormRowDescriptor formRowDescriptorWithTag:kIsPsychotic rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does the resident exhibit symptoms of psychotic disorders (i.e. bipolar disorder, schizophrenia)?"];
    [self setDefaultFontWithRow:symptomPsychRow];
    symptomPsychRow.required = YES;
    symptomPsychRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:symptomPsychRow];
    
    XLFormRowDescriptor *psychRemarksRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPsychoticRemarks rowType:XLFormRowDescriptorTypeTextView title:@""];
    [psychRemarksRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    psychRemarksRow.hidden = @YES;
    [section addFormRow:psychRemarksRow];
    
    symptomPsychRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            if ([newValue  isEqual: @1]) {
                psychRemarksRow.hidden = @NO;
            } else
                psychRemarksRow.hidden = @YES;
        }
    };
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Suicidal Ideations"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *suicideIdeasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSuicideIdeas rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does the resident have/had suicide ideations?"];
    [self setDefaultFontWithRow:suicideIdeasRow];
    suicideIdeasRow.required = YES;
    suicideIdeasRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:suicideIdeasRow];
    
    XLFormRowDescriptor *suicideIdeasRemarksRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSuicideIdeasRemarks rowType:XLFormRowDescriptorTypeTextView title:@""];
    [suicideIdeasRemarksRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    suicideIdeasRemarksRow.hidden = @YES;
    [section addFormRow:suicideIdeasRemarksRow];
    
    suicideIdeasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            if ([newValue  isEqual: @1]) {
                suicideIdeasRemarksRow.hidden = @NO;
            } else
                suicideIdeasRemarksRow.hidden = @YES;
        }
    };
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initAdditionalSvcs {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Additional Services"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBedbug rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Household is suspected/at risk of bedbug infection"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *bedbugProofRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBedbugOthers rowType:XLFormRowDescriptorTypeMultipleSelector title:@"If yes, select from this checklist:"];
    [self setDefaultFontWithRow:bedbugProofRow];
    bedbugProofRow.selectorOptions = @[@"Dried scars on body",
                                       @"Hoarding behavior",
                                       @"Itchy bites on skin",
                                       @"Poor personal hygiene",
                                       @"Bedbug blood stains on furniture/floor",
                                       @"Others (specify in next field)"
                                       ];
    bedbugProofRow.required = YES;
    [section addFormRow:bedbugProofRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBedbugOthersText rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Specify here" forKey:@"textView.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others (specify in next field)'",bedbugProofRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"bedbug_other_svs" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Services required:"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Bedbug eradication services",
                            @"Decluttering services"
                            ];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initSummary {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Summary"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Problems"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *infoRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Presenting Problems"];
    [self setDefaultFontWithRow:infoRow];
    infoRow.required = NO;
    [section addFormRow:infoRow];
    
    XLFormRowDescriptor *problemsRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"summary_problems" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    problemsRow.selectorOptions = @[@"Financial",
                            @"ElderCare",
                            @"BASIC/Childcare",
                            @"Behavioural/Emotional",
                            @"Family/Marital",
                            @"Employment",
                            @"Legal",
                            @"Other services (Bedbugs, Mobility)",
                            @"Accommodation (Tenant issues, housing matters...)",
                            @"Other Issues"];
    problemsRow.noValueDisplayText = @"Tap here for options";
    problemsRow.required = YES;
    [section addFormRow:problemsRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kProblems rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Elaborate on the presenting problems" forKey:@"textView.placeholder"];
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Other Issues'", problemsRow];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Category"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaseCat rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Follow-up case category"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"R1"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"R2"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"R3"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"R4"],
                                           ];
    [section addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Volunteer Details"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwVolName rowType:XLFormRowDescriptorTypeName title:@"Volunteer Name"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwVolContactNum rowType:XLFormRowDescriptorTypePhone title:@"Volunteer Contact No"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
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
        
        switch ([self.formNo intValue]) {
            case CurrentSocioeconomicSituation: fieldName = kCheckSocioEco;
                break;
            case CurrentPhysicalStatus: fieldName = kCheckCurrentPhyStatus;
                break;
            case SocialSupportAssessment: fieldName = kCheckSocialSupport;
                break;
            case PsychologicalWellbeing: fieldName = kCheckPsychWellbeing;
                break;
            case AdditionalSvcs: fieldName = kCheckSwAddServices;
                break;
            case Summary: fieldName = kCheckSocWorkSummary;
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
        
        switch ([self.formNo intValue]) {
            case CurrentSocioeconomicSituation: fieldName = kCheckSocioEco;
                break;
            case CurrentPhysicalStatus: fieldName = kCheckCurrentPhyStatus;
                break;
            case SocialSupportAssessment: fieldName = kCheckSocialSupport;
                break;
            case PsychologicalWellbeing: fieldName = kCheckPsychWellbeing;
                break;
            case AdditionalSvcs: fieldName = kCheckSwAddServices;
                break;
            case Summary: fieldName = kCheckSocWorkSummary;
                break;
            default:
                break;
                
        }
        
        [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:fieldName andNewContent:@"1"];
        [SVProgressHUD setMaximumDismissTimeInterval:1.0];
        [SVProgressHUD showSuccessWithStatus:@"Completed!"];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        [self.form setDisabled:YES];
        [self.tableView endEditing:YES];    //to really disable the table
        [self.tableView reloadData];
        
        
    }
    
    
}



#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    NSString* ansFromYesNo;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Yes"])
            ansFromYesNo = @"1";
        else if ([newValue isEqualToString:@"No"])
            ansFromYesNo = @"0";
    }
    
    if ([rowDescriptor.tag isEqualToString:kCopeFin]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kCopeFin andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kWhyNotCopeFin]) {
        [self processWhyNotCopeSubmissionWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:@"what_you_have"]) {
        [self processDoYouHaveFollowingWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kChasColor]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kChasColor andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kReceivingFinAssist]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kReceivingFinAssist andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kFinAssistEnuf]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kFinAssistEnuf andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kSocSvcAware]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kSocSvcAware andNewContent:newValue];
    }
}


-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {    //works great for textField and textView
    
    if (rowDescriptor.value == nil) {
        rowDescriptor.value = @"";  //empty string
    }
    
    if ([rowDescriptor.tag isEqualToString:kMoreWhyNotCopeFin]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kMoreWhyNotCopeFin andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCpfAmt]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kCpfAmt andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFinAssistName]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kFinAssistName andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFinAssistOrg]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kFinAssistOrg andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFinAssistAmt]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kFinAssistAmt andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFinAssistPeriod]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kFinAssistPeriod andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFinAssistEnufWhy]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kFinAssistEnufWhy andNewContent:rowDescriptor.value];
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

#pragma mark - Data Process b4 Submission

- (void) processWhyNotCopeSubmissionWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:[self getFieldNameFromWhyCannotCope:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:[self getFieldNameFromWhyCannotCope:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:[self getFieldNameFromWhyCannotCope:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:[self getFieldNameFromWhyCannotCope:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}

- (NSString *) getFieldNameFromWhyCannotCope: (NSString *) expenses {
    if ([expenses containsString:@"Medical"]) return kMediExp ;
    else if ([expenses containsString:@"Housing"]) return kHouseRent;
    else if ([expenses containsString:@"Debts"]) return kDebts;
    else if ([expenses containsString:@"living"]) return kDailyExpenses;
    else if ([expenses containsString:@"Others"]) return kOtherExpenses;
    else return @"";
}


- (void) processDoYouHaveFollowingWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:[self getFieldNameFromFollowing:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:[self getFieldNameFromFollowing:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:[self getFieldNameFromFollowing:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:[self getFieldNameFromFollowing:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}

- (NSString *) getFieldNameFromFollowing: (NSString *) expenses {
    if ([expenses containsString:@"Community"]) return kHasChas  ;
    else if ([expenses containsString:@"Pioneer"]) return kHasPgp;
    else if ([expenses containsString:@"Medisave"]) return kHasMedisave;
    else if ([expenses containsString:@"Insurance"]) return kHasInsure;
    else if ([expenses containsString:@"CPF"]) return kHasCpfPayouts;
    else return @"";
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

- (NSArray *) getWhyCantCopeArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kMediExp, kHouseRent, kDebts, kDailyExpenses, kOtherExpenses];
    NSArray *textArray = @[@"Medical Expenses", @"Housing Rent", @"Arrears/Debts", @"Daily living expenses (e.g. transport)", @"Others",];
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

- (NSArray *) getDoyouHaveFollowingArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kHasChas, kHasPgp, kHasMedisave, kHasInsure, kHasCpfPayouts];
    NSArray *textArray = @[@"Community Health Assist Scheme", @"Pioneer Generation Package", @"Medisave", @"Insurance Coverage", @"CPF Pay Outs",];
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

#pragma mark - Button methods
- (void) computeScoreButton: (XLFormRowDescriptor *)sender {
    NSInteger score = [[relativesContactRow.value formValue] integerValue] + [[relativesEaseRow.value formValue] integerValue] + [[relativesCloseRow.value formValue] integerValue] + [[friendsContactRow.value formValue] integerValue] + [[friendsEaseRow.value formValue] integerValue] + [[friendsCloseRow.value formValue] integerValue];
    
    socialScoreRow.value = [NSString stringWithFormat:@"%ld", (long)score];
    [self updateFormRow:socialScoreRow];
    
    [self deselectFormRow:sender];
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

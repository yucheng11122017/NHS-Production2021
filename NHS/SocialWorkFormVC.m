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
    XLFormRowDescriptor *preEdScoreRow, *postEdScoreRow, *showPostEdSectionBtnRow, *phqTotalScoreRow;
    BOOL internetDCed;
    BOOL isFormFinalized;
    BOOL hasShownProposedBox;
    BOOL hasShownDepressAlertBox;
}

@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSMutableArray *phqQuestionsArray;

@end

@implementation SocialWorkFormVC

- (void)viewDidLoad {
    
    isFormFinalized = false;    //by default
    hasShownProposedBox = false;
    XLFormViewController *form;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    
    //must init first before [super viewDidLoad]
    int formNumber = [_formNo intValue];
    switch (formNumber) {
            //case 0 is for demographics
            
        case 0:
            form = [self initDepressAssessPhq9];
            break;
//        case 1:
//            form = [self initCurrentSocioSituation];
//            break;
//        case 2:
//            form = [self initCurrentPhysStatus];
//            break;
//        case 3:
//            form = [self initSocialSupportAssessment];
//            break;
//        case 4:
//            form = [self initPsychWellbeing];
//            break;
//        case 5:
//            form = [self initAdditionalSvcs];
//            break;
//        case 6:
//            form = [self initSummary];
//            break;
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
    
    XLFormRowDescriptor *describeWorkInfoRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"question" rowType:XLFormRowDescriptorTypeInfo title:@"Describe your current/past employment and work experiences (e.g. type of job, workplace, work duration, work frequency, relationship with superior, relationship with colleagues)"];
    describeWorkInfoRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [self setDefaultFontWithRow:describeWorkInfoRow];
    
    [section addFormRow:describeWorkInfoRow];
    
    XLFormRowDescriptor *describeWorkRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDescribeWork rowType:XLFormRowDescriptorTypeTextView title:@""];
    [describeWorkRow.cellConfigAtConfigure setObject:@"Comment here..." forKey:@"textView.placeholder"];
    describeWorkRow.required = NO;
    
    //value
    if (currentSocioSitDict != (id)[NSNull null] && [currentSocioSitDict objectForKey:kDescribeWork] != (id)[NSNull null]) {
        describeWorkRow.value = currentSocioSitDict[kDescribeWork];
    }
    
    [section addFormRow:describeWorkRow];
    
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
    whatYouHaveRow.selectorOptions = @[@"Community Health Assist Scheme", @"Pioneer Generation Package", @"Medisave", @"Insurance Coverage", @"CPF Pay Outs", @"None of the above"];
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
    [finAssistEnufWhyRow.cellConfigAtConfigure setObject:@"Elaboration on sufficiency of assistance" forKey:@"textView.placeholder"];
//    finAssistEnufWhyRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", finAssistEnufRow];    //always appear instead (1924)
    
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
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Physical Status"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Activities of Daily Living"];
    [formDescriptor addFormSection:section];
    
    NSDictionary *currPhyStatusDict = [_fullScreeningForm objectForKey:SECTION_CURRENT_PHY_STATUS];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckCurrentPhyStatus];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Can you perform the following activities without assistance? (Tick those activities that the resident CAN perform on his/her own)."];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"multiple_ADL" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Activities"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Bathe/Shower", @"Dress",@"Eat",@"Personal Hygiene and Grooming", @"Toileting", @"Transfer/Walk"];

    //value
    if (currPhyStatusDict != (id)[NSNull null]) {
        row.value = [self getActivitiesArray:currPhyStatusDict];
    }
    
    row.noValueDisplayText = @"Tap here for options";
    row.required = YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mobility Status"];
    [self setDefaultFontWithRow:row];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityStatus
                                               rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                 title:@"Mobility Status"];
    [self setDefaultFontWithRow:row];
    row.noValueDisplayText = @"Tap here for options";
    row.required = YES;
    row.selectorOptions = @[@"Ambulant", @"Able to walk with assistance (stick/frame)", @"Wheelchair-bound", @"Bed-ridden"];
    
    //value
    if (currPhyStatusDict != (id)[NSNull null] && [currPhyStatusDict objectForKey:kMobilityStatus] != (id)[NSNull null]) {
        row.value = currPhyStatusDict[kMobilityStatus];
    }
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *mobilEquipRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityEquipment
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Do you require mobility equipment in your household? (e.g. non-slip mat, handle bar, etc)"];
    mobilEquipRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:mobilEquipRow];
    mobilEquipRow.required = YES;
    mobilEquipRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (currPhyStatusDict != (id)[NSNull null] && [currPhyStatusDict objectForKey:kMobilityEquipment] != (id)[NSNull null]) {
        mobilEquipRow.value = [self getYesNofromOneZero:[currPhyStatusDict objectForKey:kMobilityEquipment]];
    }
    [section addFormRow:mobilEquipRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityEquipmentText rowType:XLFormRowDescriptorTypeTextView title:@""];
    row.required = NO;
    [row.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", mobilEquipRow];
    
    //value
    if (currPhyStatusDict != (id)[NSNull null] && [currPhyStatusDict objectForKey:kMobilityEquipmentText] != (id)[NSNull null]) {
        row.value = [currPhyStatusDict objectForKey:kMobilityEquipmentText];
    }
    
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initSocialSupportAssessment {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Social Support Assessment"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    NSDictionary *socialSupportDict = [_fullScreeningForm objectForKey:SECTION_SOCIAL_SUPPORT];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSocialSupport];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    

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
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kHasCaregiver] != (id)[NSNull null]) {
        hasCaregiverRow.value = [self getYESNOfromOneZero:[socialSupportDict objectForKey:kHasCaregiver]];
    }

    [hasPriCaregiversection addFormRow:hasCaregiverRow];

    XLFormSectionDescriptor *careGiverSection = [XLFormSectionDescriptor formSectionWithTitle:@"Caregiver Details"];
    careGiverSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasCaregiverRow];
    [formDescriptor addFormSection:careGiverSection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kCaregiverName] != (id)[NSNull null]) {
        row.value = socialSupportDict[kCaregiverName];
    }
    
    [careGiverSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverRs rowType:XLFormRowDescriptorTypeText title:@"Relationship"];
    [self setDefaultFontWithRow:row];

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kCaregiverRs] != (id)[NSNull null]) {
        row.value = socialSupportDict[kCaregiverRs];
    }
    
    [careGiverSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverContactNum rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Please check that you have input the correct number" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kCaregiverContactNum] != (id)[NSNull null]) {
        row.value = socialSupportDict[kCaregiverContactNum];
    }
    
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
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kEContact] != (id)[NSNull null]) {
        hasEmerContactRow.value = [self getYESNOfromOneZero:[socialSupportDict objectForKey:kEContact]];
    }

    [askEmerContactSection addFormRow:hasEmerContactRow];

    XLFormSectionDescriptor *EmerContactSection = [XLFormSectionDescriptor formSectionWithTitle:@"Emergency Contact"];
    EmerContactSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasEmerContactRow];
    [formDescriptor addFormSection:EmerContactSection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kEContactName] != (id)[NSNull null]) {
        row.value = socialSupportDict[kEContactName];
    }
    
    [EmerContactSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactRs rowType:XLFormRowDescriptorTypeText title:@"Relationship"];
    [self setDefaultFontWithRow:row];

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kEContactRs] != (id)[NSNull null]) {
        row.value = socialSupportDict[kEContactRs];
    }
    
    [EmerContactSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactNum rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Please check that you have input the correct number" regex:@"^(?=.*\\d).{8}$"]];

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kEContactNum] != (id)[NSNull null]) {
        row.value = socialSupportDict[kEContactNum];
    }
    
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
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kUCaregiver] != (id)[NSNull null]) {
        hasCaregivingRow.value = [self getYESNOfromOneZero:[socialSupportDict objectForKey:kUCaregiver]];
    }
    
    [hasCaregivingSection addFormRow:hasCaregivingRow];
    
    //Details of being a caregiver
    XLFormSectionDescriptor *caregivingSection = [XLFormSectionDescriptor formSectionWithTitle:@"Caregiving Details"];
    caregivingSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasCaregivingRow];
    [formDescriptor addFormSection:caregivingSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUCareStress rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you facing caregiver stress?"];
    row.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kUCareStress] != (id)[NSNull null]) {
        row.value = [self getYesNofromOneZero:[socialSupportDict objectForKey:kUCareStress]];
    }
    
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q4" rowType:XLFormRowDescriptorTypeInfo title:@"Describe your caregiving responsibilities (e.g. frequency, caregiving tasks)"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingDescribe rowType:XLFormRowDescriptorTypeTextView title:@""];
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kCaregivingDescribe] != (id)[NSNull null]) {
        row.value = [socialSupportDict objectForKey:kCaregivingDescribe];
    }
    
    [caregivingSection addFormRow:row];
    
    XLFormRowDescriptor *rcvCareAssistRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingAssist rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Would you like to receive caregiving assistance?"];
    rcvCareAssistRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:rcvCareAssistRow];
    rcvCareAssistRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kCaregivingAssist] != (id)[NSNull null]) {
        rcvCareAssistRow.value = [self getYesNofromOneZero:[socialSupportDict objectForKey:kCaregivingAssist]];
    }
    
    [caregivingSection addFormRow:rcvCareAssistRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q5" rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Type of assistance preferred:"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", rcvCareAssistRow];
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingAssistType rowType:XLFormRowDescriptorTypeTextView title:@""];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", rcvCareAssistRow];
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kCaregivingAssistType] != (id)[NSNull null]) {
        row.value = socialSupportDict[kCaregivingAssistType];
    }
    
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
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kGettingSupport] != (id)[NSNull null]) {
        getSupportRow.value = [self getYESNOfromOneZero:[socialSupportDict objectForKey:kGettingSupport]];
    }

    [section addFormRow:getSupportRow];

    XLFormRowDescriptor *multiSupportRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_support" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Support in terms of:"];
    [self setDefaultFontWithRow:multiSupportRow];
    multiSupportRow.hidden =[NSString stringWithFormat:@"NOT $%@.value contains 'YES'", getSupportRow];
    multiSupportRow.selectorOptions = @[@"Care-giving", @"Food", @"Money", @"Others"];

    //value
    if (socialSupportDict != (id)[NSNull null]) {
        multiSupportRow.value = [self getMultiSupportArray:socialSupportDict];
    }
    
    [section addFormRow:multiSupportRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOthersText rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@"Specify here" forKey:@"textField.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiSupportRow];
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kOthersText] != (id)[NSNull null]) {
        row.value = socialSupportDict[kOthersText];
    }
    
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
    relativesContactRow.selectorOptions = @[@"None",@"One", @"Two", @"Three-Four", @"Five-Eight", @"Nine or more"];
    relativesContactRow.required = YES;

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kRelativesContact] != (id)[NSNull null]) {
        relativesContactRow.value = socialSupportDict[kRelativesContact];
    }

    [section addFormRow:relativesContactRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q8" rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you feel at ease with that you can talk about private matters? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];

    relativesEaseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesEase rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    relativesEaseRow.selectorOptions = @[@"None",@"One", @"Two", @"Three-Four", @"Five-Eight", @"Nine or more"];
    relativesEaseRow.required = YES;

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kRelativesEase] != (id)[NSNull null]) {
        relativesEaseRow.value = socialSupportDict[kRelativesEase];
    }

    [section addFormRow:relativesEaseRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q9" rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you feel close to such that you could call on them for help? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    relativesCloseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesClose rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    relativesCloseRow.selectorOptions = @[@"None",@"One", @"Two", @"Three-Four", @"Five-Eight", @"Nine or more"];
    relativesCloseRow.required = YES;

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kRelativesClose] != (id)[NSNull null]) {
        relativesCloseRow.value = socialSupportDict[kRelativesClose];
    }

    [section addFormRow:relativesCloseRow];


    //FRIENDS
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Friends"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q10" rowType:XLFormRowDescriptorTypeInfo title:@"How many friends do you see or hear from at least once a month? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsContact rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsContactRow.selectorOptions = @[@"None",@"One", @"Two", @"Three-Four", @"Five-Eight", @"Nine or more"];
    friendsContactRow.required = YES;

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kFriendsContact] != (id)[NSNull null]) {
        friendsContactRow.value = socialSupportDict[kFriendsContact];
    }

    [section addFormRow:friendsContactRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q11" rowType:XLFormRowDescriptorTypeInfo title:@"How many friends do you feel at ease with that you can talk about private matters? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsEaseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsEase rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsEaseRow.selectorOptions = @[@"None",@"One", @"Two", @"Three-Four", @"Five-Eight", @"Nine or more"];
    friendsEaseRow.required = YES;

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kFriendsEase] != (id)[NSNull null]) {
        friendsEaseRow.value = socialSupportDict[kFriendsEase];
    }

    [section addFormRow:friendsEaseRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q12" rowType:XLFormRowDescriptorTypeInfo title:@"How many of your friends do you feel close to such that you could call on them for help? *"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsCloseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsClose rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsCloseRow.selectorOptions = @[@"None",@"One", @"Two", @"Three-Four", @"Five-Eight", @"Nine or more"];
    friendsCloseRow.required = YES;

    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kFriendsClose] != (id)[NSNull null]) {
        friendsCloseRow.value = socialSupportDict[kFriendsClose];
    }

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
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kSocialScore] != (id)[NSNull null]) {
        socialScoreRow.value = socialSupportDict[kSocialScore];
    }

    [section addFormRow:socialScoreRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   //newly added (1927)
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q12.5" rowType:XLFormRowDescriptorTypeInfo title:@"Elaboration on social network e.g. ‘resident does not have many friends/does not contact friends frequently but receives strong support’"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSocialNetwork rowType:XLFormRowDescriptorTypeTextView title:@""];
    [self setDefaultFontWithRow:row];
//    [row.cellConfigAtConfigure setObject:@"" forKey:@"textView.placeholder"];
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kSocialNetwork] != (id)[NSNull null] && [[socialSupportDict objectForKey:kSocialNetwork] isKindOfClass:[NSString class]]) {
        row.value = socialSupportDict[kSocialNetwork];
    }
    
    [section addFormRow:row];

    

    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q13" rowType:XLFormRowDescriptorTypeInfo title:@"Do you participate in any community activities?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *gotCommActivitiesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kParticipateActivities rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    gotCommActivitiesRow.selectorOptions = @[@"YES", @"NO"];
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kParticipateActivities] != (id)[NSNull null]) {
        gotCommActivitiesRow.value = [self getYESNOfromOneZero:[socialSupportDict objectForKey:kParticipateActivities]];
    }
    
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
    if (socialSupportDict != (id)[NSNull null]) {
        multiOrgActivitiesRow.value = [self getMultiHostArray:socialSupportDict];
    }

    [section addFormRow:multiOrgActivitiesRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHostOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    [self setDefaultFontWithRow:row];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiOrgActivitiesRow];
    
    //value
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kHostOthers] != (id)[NSNull null]) {
        row.value = socialSupportDict[kHostOthers];
    }
    
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
    
    //value
    if (socialSupportDict != (id)[NSNull null]) {
        multiNoCommActivRow.value = [self getWhyNotJoinArray:socialSupportDict];
    }
    
    [section addFormRow:multiNoCommActivRow];
    
    XLFormRowDescriptor *NoCommActivOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWhyNoParticipate rowType:XLFormRowDescriptorTypeTextView title:@"Others:"];
    [self setDefaultFontWithRow:NoCommActivOthersRow];
    [NoCommActivOthersRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    NoCommActivOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiNoCommActivRow];
    
    //valued
    if (socialSupportDict != (id)[NSNull null] && [socialSupportDict objectForKey:kWhyNoParticipate] != (id)[NSNull null] && [[socialSupportDict objectForKey:kWhyNoParticipate] isKindOfClass:[NSString class]]) {
        NoCommActivOthersRow.value = socialSupportDict[kWhyNoParticipate];
    }
    
    [section addFormRow:NoCommActivOthersRow];

    
    // Just to avoid keyboard covering the row in the ScrollView
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];


    return [super initWithForm:formDescriptor];
}

- (id) initPsychWellbeing {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Psychological Well-being"];
    XLFormSectionDescriptor * section;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Psychotic Disorder"];
    [formDescriptor addFormSection:section];
    
    NSDictionary *psychWellbeingDict = [_fullScreeningForm objectForKey:SECTION_PSYCH_WELL_BEING];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckPsychWellbeing];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }

    
    XLFormRowDescriptor *symptomPsychRow = [XLFormRowDescriptor formRowDescriptorWithTag:kIsPsychotic rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does the resident exhibit symptoms of psychotic disorders (i.e. bipolar disorder, schizophrenia)?"];
    symptomPsychRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:symptomPsychRow];
    symptomPsychRow.required = YES;
    symptomPsychRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (psychWellbeingDict != (id)[NSNull null] && [psychWellbeingDict objectForKey:kIsPsychotic] != (id)[NSNull null]) {
        symptomPsychRow.value = [self getYesNofromOneZero:psychWellbeingDict[kIsPsychotic]];
    }
    
    [section addFormRow:symptomPsychRow];
    
    XLFormRowDescriptor *psychRemarksRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPsychoticRemarks rowType:XLFormRowDescriptorTypeTextView title:@""];
    [psychRemarksRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    
    psychRemarksRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'",symptomPsychRow];
    
    //value
    if (psychWellbeingDict != (id)[NSNull null] && [psychWellbeingDict objectForKey:kPsychoticRemarks] != (id)[NSNull null]) {
        psychRemarksRow.value = psychWellbeingDict[kPsychoticRemarks];
    }
    
    [section addFormRow:psychRemarksRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Suicidal Ideations"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *suicideIdeasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSuicideIdeas rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does the resident have/had suicide ideations?"];
    suicideIdeasRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:suicideIdeasRow];
    suicideIdeasRow.required = YES;
    suicideIdeasRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (psychWellbeingDict != (id)[NSNull null] && [psychWellbeingDict objectForKey:kSuicideIdeas] != (id)[NSNull null]) {
        suicideIdeasRow.value = [self getYesNofromOneZero:psychWellbeingDict[kSuicideIdeas]];
    }
    
    [section addFormRow:suicideIdeasRow];
    
    XLFormRowDescriptor *suicideIdeasRemarksRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSuicideIdeasRemarks rowType:XLFormRowDescriptorTypeTextView title:@""];
    [suicideIdeasRemarksRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    
    suicideIdeasRemarksRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'",suicideIdeasRow];
    
    //value
    if (psychWellbeingDict != (id)[NSNull null] && [psychWellbeingDict objectForKey:kSuicideIdeasRemarks] != (id)[NSNull null]) {
        suicideIdeasRemarksRow.value = psychWellbeingDict[kSuicideIdeasRemarks];
    }
    
    [section addFormRow:suicideIdeasRemarksRow];
    

    return [super initWithForm:formDescriptor];
    
}

- (id) initAdditionalSvcs {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Additional Services"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *addSvcDict = [_fullScreeningForm objectForKey:SECTION_SW_ADD_SERVICES];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSwAddServices];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    XLFormRowDescriptor *gotBedbugIssueRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBedbug rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Household is suspected/at risk of bedbug infection"];
    [self setDefaultFontWithRow:gotBedbugIssueRow];
    gotBedbugIssueRow.selectorOptions = @[@"Yes", @"No"];
    gotBedbugIssueRow.required = YES;
    gotBedbugIssueRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    //value
    if (addSvcDict != (id)[NSNull null] && [addSvcDict objectForKey:kBedbug] != (id)[NSNull null]) {
        gotBedbugIssueRow.value = [self getYesNofromOneZero:addSvcDict[kBedbug]];
    }
    
    
    [section addFormRow:gotBedbugIssueRow];
    
    XLFormRowDescriptor *bedbugProofRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_bedbug_symptom" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"If yes, select from this checklist:"];
    [self setDefaultFontWithRow:bedbugProofRow];
    bedbugProofRow.selectorOptions = @[@"Dried scars on body",
                                       @"Hoarding behavior",
                                       @"Itchy bites on skin",
                                       @"Poor personal hygiene",
                                       @"Bedbug blood stains on furniture/floor",
                                       @"Others (specify in next field)"
                                       ];
    bedbugProofRow.required = NO;
    
    //value
    if (addSvcDict != (id)[NSNull null]) {
        bedbugProofRow.value = [self getBedbugSymptomArray:addSvcDict];
    }
    
    [section addFormRow:bedbugProofRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBedbugOthersText rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Specify here" forKey:@"textView.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others (specify in next field)'",bedbugProofRow];
    
    //value
    if (addSvcDict != (id)[NSNull null] && [addSvcDict objectForKey:kBedbugOthersText] != (id)[NSNull null]) {
        row.value = addSvcDict[kBedbugOthersText];
    }
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *bedbugServiceRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_service_required" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Services required:"];
    [self setDefaultFontWithRow:bedbugServiceRow];
    bedbugServiceRow.selectorOptions = @[@"Bedbug eradication services",
                            @"Decluttering services"
                            ];
    bedbugServiceRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    bedbugProofRow.required = NO;
    
    //value
    if (addSvcDict != (id)[NSNull null]) {
        bedbugServiceRow.value = [self getReqSvcsArray:addSvcDict];
    }
    
    [section addFormRow:bedbugServiceRow];
    
    gotBedbugIssueRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                bedbugProofRow.required = YES;
                bedbugServiceRow.required = YES;
            } else {
                bedbugProofRow.required = NO;
                bedbugServiceRow.required = NO;
            }
        }
    };
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initSummary {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Summary"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Problems"];
    [formDescriptor addFormSection:section];
    
    NSDictionary *summaryDict = [_fullScreeningForm objectForKey:SECTION_SOC_WORK_SUMMARY];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSocWorkSummary];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
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
                            @"Other Issues",
                            @"Nil"];
    problemsRow.noValueDisplayText = @"Tap here for options";
    problemsRow.required = YES;
    
    //value
    if (summaryDict != (id)[NSNull null])
        problemsRow.value = [self getPresentingProblemsArray:summaryDict];
    
    [section addFormRow:problemsRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kProblems rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Elaborate on the presenting problems" forKey:@"textView.placeholder"];

    //value
    if (summaryDict != (id)[NSNull null] && [summaryDict objectForKey:kProblems] != (id)[NSNull null]) {
        row.value = summaryDict[kProblems];
    }
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *proposedIntervenInfoRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1.5" rowType:XLFormRowDescriptorTypeInfo title:@"Proposed Interventions"];
    [self setDefaultFontWithRow:proposedIntervenInfoRow];
    proposedIntervenInfoRow.required = NO;
    [section addFormRow:proposedIntervenInfoRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kInterventions rowType:XLFormRowDescriptorTypeTextView title:@""];
//    [row.cellConfigAtConfigure setObject:@"Elaborate on the presenting problems" forKey:@"textView.placeholder"];
    row.required = YES;
    
    //value
    if (summaryDict != (id)[NSNull null] && [summaryDict objectForKey:kInterventions] != (id)[NSNull null]) {
        row.value = summaryDict[kInterventions];
    }
    
    [section addFormRow:row];
    
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Category"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaseCat rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Follow-up case category"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    row.selectorOptions = @[@"R1",@"R2",@"R3",@"R4"];
    row.noValueDisplayText = @"Tap Here";
    
    //value
    if (summaryDict != (id)[NSNull null] && [summaryDict objectForKey:kCaseCat] != (id)[NSNull null]) {
        row.value = summaryDict[kCaseCat];
    }
    
    [section addFormRow:row];
    
    //NEWLY ADDED
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCommReview rowType:XLFormRowDescriptorTypeBooleanCheck title:@"For Committee Review (✓)"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (summaryDict != (id)[NSNull null] && [summaryDict objectForKey:kCommReview] != (id)[NSNull null]) {
        row.value = summaryDict[kCommReview];
    }
    [section addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Volunteer Details"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwVolName rowType:XLFormRowDescriptorTypeName title:@"Volunteer Name"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    
    //value
    if (summaryDict != (id)[NSNull null] && [summaryDict objectForKey:kSwVolName] != (id)[NSNull null]) {
        row.value = summaryDict[kSwVolName];
    }
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwVolContactNum rowType:XLFormRowDescriptorTypePhone title:@"Volunteer Contact No"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Please check that you have input the correct number" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (summaryDict != (id)[NSNull null] && [summaryDict objectForKey:kSwVolContactNum] != (id)[NSNull null]) {
        row.value = summaryDict[kSwVolContactNum];
    }
    
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initDepressAssessPhq9 {

    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"PHQ-9"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    self.phqQuestionsArray = [[NSMutableArray alloc] init];

    NSDictionary *geriaDepreAssmtDict = [self.fullScreeningForm objectForKey:SECTION_SW_DEPRESSION];

    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];

    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSwDepress];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }

    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDidDepressAssess rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Undergone Depression Assessment?"];
//    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kDidDepressAssess] != (id)[NSNull null])
//        row.value = [self getYesNofromOneZero:geriaDepreAssmtDict[kDidDepressAssess]];
//
//    [self setDefaultFontWithRow:row];
//    row.selectorOptions = @[@"Yes", @"No"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

    NSArray *phqOptions = @[@"Not at all [0]", @"Several days [1]", @"More than half the days [2]", @"Nearly Every day [3]"];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"1. Little interest or pleasure in doing things"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];

    XLFormRowDescriptor *phqQ1Row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ1 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    phqQ1Row.selectorOptions = phqOptions;
    phqQ1Row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ1] != (id)[NSNull null]) {
        phqQ1Row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ1]];
    }

    [section addFormRow:phqQ1Row];

    [_phqQuestionsArray addObject:phqQ1Row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q2" rowType:XLFormRowDescriptorTypeInfo title:@"2. Feeling down, depressed or hopeless"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];

    XLFormRowDescriptor *phqQ2Row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ2 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    phqQ2Row.selectorOptions = phqOptions;
    phqQ2Row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ2] != (id)[NSNull null]) {
        phqQ2Row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ2]];
    }

    [section addFormRow:phqQ2Row];

    [_phqQuestionsArray addObject:phqQ2Row];

    XLFormSectionDescriptor *q3_9Section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:q3_9Section];
    q3_9Section.hidden = @YES;

    // Show the rest of the questions if value >= 2
    if (phqQ1Row.value != nil && phqQ1Row.value != (id)[NSNull null]) {
        if ([[self getNumberFromPhqOption:phqQ1Row.value] integerValue] >= 2) q3_9Section.hidden = @NO;
    }
    if (phqQ2Row.value != nil && phqQ2Row.value != (id)[NSNull null]) {
        if ([[self getNumberFromPhqOption:phqQ2Row.value] integerValue] >= 2) q3_9Section.hidden = @NO;
    }


    /** Section for Q3-Q9 */

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q3" rowType:XLFormRowDescriptorTypeInfo title:@"3. Trouble falling asleep, staying asleep, or sleeping too much"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [q3_9Section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ3 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    row.selectorOptions = phqOptions;
    row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ3] != (id)[NSNull null]) {
        row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ3]];
    }

    [q3_9Section addFormRow:row];

    [_phqQuestionsArray addObject:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q4" rowType:XLFormRowDescriptorTypeInfo title:@"4. Feeling tired or having little energy"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [q3_9Section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ4 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    row.selectorOptions = phqOptions;
    row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ4] != (id)[NSNull null]) {
        row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ4]];
    }

    [q3_9Section addFormRow:row];

    [_phqQuestionsArray addObject:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q5" rowType:XLFormRowDescriptorTypeInfo title:@"5. Poor appetite or overeating"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [q3_9Section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ5 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    row.selectorOptions = phqOptions;
    row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ5] != (id)[NSNull null]) {
        row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ5]];
    }

    [q3_9Section addFormRow:row];

    [_phqQuestionsArray addObject:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q6" rowType:XLFormRowDescriptorTypeInfo title:@"6. Feeling bad about yourself - or that you're a failure or have let yourself or your family down"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [q3_9Section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ6 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    row.selectorOptions = phqOptions;
    row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ6] != (id)[NSNull null]) {
        row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ6]];
    }

    [q3_9Section addFormRow:row];

    [_phqQuestionsArray addObject:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q7" rowType:XLFormRowDescriptorTypeInfo title:@"7. Trouble concentrating on things, such as reading the newspaper or watching television"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [q3_9Section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ7 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    row.selectorOptions = phqOptions;
    row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ7] != (id)[NSNull null]) {
        row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ7]];
    }

    [q3_9Section addFormRow:row];

    [_phqQuestionsArray addObject:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q8" rowType:XLFormRowDescriptorTypeInfo title:@"8. Moving or speaking so slowly that other people could have noticed. Or the opposite - being so fidgety or restless that you have been moving around a lot more than usual"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [q3_9Section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ8 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    row.selectorOptions = phqOptions;
    row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ8] != (id)[NSNull null]) {
        row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ8]];
    }

    [q3_9Section addFormRow:row];

    [_phqQuestionsArray addObject:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q9" rowType:XLFormRowDescriptorTypeInfo title:@"9. Thoughts that you would be better off dead or of hurting yourself in some way"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [q3_9Section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ9 rowType:XLFormRowDescriptorTypeSelectorAlertView title:@""];
    row.selectorOptions = phqOptions;
    row.noValueDisplayText = @"Tap here";

    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ9] != (id)[NSNull null]) {
        row.value = [self getSelectorOptionFromNumber:geriaDepreAssmtDict[kPhqQ9]];
    }

    [q3_9Section addFormRow:row];

    [_phqQuestionsArray addObject:row];

    // PHQ Q9
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {

        if (!hasShownDepressAlertBox) {
            int totalScore = [self calculateTotalPhqScore];

            if (totalScore >= 5) {
                hasShownDepressAlertBox = true;
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Take note", nil)
                                                                                          message:@"Please bring resident to the geriatric assessments booth at the multi-purpose hall for referral"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * okAction) {
                                                                      //do nothing for now
                                                                  }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    };

//    XLFormRowDescriptor* phqQ1Row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ1
//                                                                          rowType:XLFormRowDescriptorTypeStepCounter
//                                                                            title:@"PHQ-2 question 1 Score"];
//    [self setDefaultFontWithRow:phqQ1Row];
//    phqQ1Row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [phqQ1Row.cellConfigAtConfigure setObject:@YES forKey:@"stepControl.wraps"];
//    [phqQ1Row.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
//    [phqQ1Row.cellConfigAtConfigure setObject:@0 forKey:@"stepControl.minimumValue"];
//    [phqQ1Row.cellConfigAtConfigure setObject:@3 forKey:@"stepControl.maximumValue"];
//
//    //value
//    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ1] != (id)[NSNull null]) {
//        phqQ1Row.value = geriaDepreAssmtDict[kPhqQ1];
//    }
//
//    [section addFormRow:phqQ1Row];
//
//    XLFormRowDescriptor* phqQ2Row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhqQ2
//                                                                          rowType:XLFormRowDescriptorTypeStepCounter
//                                                                            title:@"PHQ-2 question 2 Score"];
//    [self setDefaultFontWithRow:phqQ2Row];
//    phqQ2Row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [phqQ2Row.cellConfigAtConfigure setObject:@YES forKey:@"stepControl.wraps"];
//    [phqQ2Row.cellConfigAtConfigure setObject:@1 forKey:@"stepControl.stepValue"];
//    [phqQ2Row.cellConfigAtConfigure setObject:@0 forKey:@"stepControl.minimumValue"];
//    [phqQ2Row.cellConfigAtConfigure setObject:@3 forKey:@"stepControl.maximumValue"];
//
//    //value
//    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhqQ2] != (id)[NSNull null]) {
//        phqQ2Row.value = geriaDepreAssmtDict[kPhqQ2];
//    }
//
//    [section addFormRow:phqQ2Row];
//
//
//
//    XLFormRowDescriptor* phq9ScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhq9Score
//                                                                              rowType:XLFormRowDescriptorTypeNumber
//                                                                                title:@"Total score for PHQ-9"];
//    [self setDefaultFontWithRow:phq9ScoreRow];
//    phq9ScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    phq9ScoreRow.disabled = @(1);
//
//    if (phqQ1Row.value != (id) [NSNull null] && phqQ2Row.value != (id)[NSNull null]) {
//        if ([phqQ1Row.value intValue] > 1 || [phqQ2Row.value intValue] >1) {
//            phq9ScoreRow.disabled = @(0);
//        }
//    }
//    //value
//    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhq9Score] != (id)[NSNull null]) {
//        phq9ScoreRow.value = geriaDepreAssmtDict[kPhq9Score];
//    }
//
//    [section addFormRow:phq9ScoreRow];

    XLFormSectionDescriptor *section3 = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section3];

    XLFormRowDescriptor* q10Row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q10"
                                                                                rowType:XLFormRowDescriptorTypeInfo
                                                                                  title:@"10. If you checked off any problems, how difficult have those problems made it for you to Do your work, take care of things at home, or get along with other people?"];
    [self setDefaultFontWithRow:q10Row];
    q10Row.cellConfig[@"textLabel.numberOfLines"] = @0;
    q10Row.disabled = @(1); //default disabled.

    [section3 addFormRow:q10Row];


    XLFormRowDescriptor* q10ResponseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQ10Response
                                                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                                                  title:@""];
    q10ResponseRow.selectorOptions = @[@"Not difficult at all", @"Somewhat difficult", @"Very difficult",@"Extremely difficult"];
    q10ResponseRow.noValueDisplayText = @"Tap here";
    q10ResponseRow.disabled = @(1);
//    if (phqQ1Row.value != (id) [NSNull null] && phqQ2Row.value != (id)[NSNull null]) {
//        if ([phqQ1Row.value intValue] > 1 || [phqQ2Row.value intValue] >1) {
//            q10ResponseRow.disabled = @(0);
//        }
//    }


    //value
    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kQ10Response] != (id)[NSNull null]) {
        q10ResponseRow.value = geriaDepreAssmtDict[kQ10Response];
    }

    [section3 addFormRow:q10ResponseRow];

    phqQ1Row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([self getScoreFromPhqOptions:newValue] > 1)  {
//                phq9ScoreRow.disabled = @(0);
                q3_9Section.hidden = @NO;
            }
            else {
                if (phqQ2Row.value != nil && phqQ2Row.value != (id) [NSNull null]) {
                    if ([self getScoreFromPhqOptions:phqQ2Row.value] < 2) {    //only when both lower than 2, then disable field
                        //                    phq9ScoreRow.disabled = @(1);
                        [q3_9Section setHidden:@YES];
                    }
                } else {
                    [q3_9Section setHidden:@YES];
                }
            }

//            [self reloadFormRow:phq9ScoreRow];
            [self reloadFormRow:q10ResponseRow];
            [self reloadFormRow:q10Row];
            [self.tableView reloadData];
        }
    };

    phqQ2Row.onChangeBlock= ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([self getScoreFromPhqOptions:newValue] > 1) {
//                phq9ScoreRow.disabled = @(0);
                q3_9Section.hidden = @NO;
            }
            else {
                if (phqQ1Row.value != nil  && phqQ1Row.value != (id) [NSNull null]) {
                    if ([self getScoreFromPhqOptions:phqQ1Row.value] < 2) {    //only when both lower than 2, then disable field
                        //                    phq9ScoreRow.disabled = @(1);
                        [q3_9Section setHidden:@YES];
                    }
                } else {
                    [q3_9Section setHidden:@YES];
                }
            }
//            [self reloadFormRow:phq9ScoreRow];
            [self reloadFormRow:q10Row];
            [self reloadFormRow:q10ResponseRow];
            [self.tableView reloadData];
        }
    };

    XLFormSectionDescriptor *scoreSection = [XLFormSectionDescriptor formSectionWithTitle:@"Total Score (auto-calculate)"];
    [formDescriptor addFormSection:scoreSection];

    phqTotalScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhq9Score rowType:XLFormRowDescriptorTypeInfo title:@"Total Score"];

    //value
    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kPhq9Score] != (id)[NSNull null]) {
        phqTotalScoreRow.value = geriaDepreAssmtDict[kPhq9Score];
        if ([phqTotalScoreRow.value integerValue]>= 5) {
            q10Row.disabled = @NO;  //enable this
            q10ResponseRow.disabled = @NO;
        }
    }


    [scoreSection addFormRow:phqTotalScoreRow];

    phqTotalScoreRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([phqTotalScoreRow.value integerValue] >= 5) {
                q10Row.disabled = @NO;  //enable this
                q10ResponseRow.disabled = @NO;
            } else {
                q10Row.disabled = @YES;  //enable this
                q10ResponseRow.disabled = @YES;
            }
            [self reloadFormRow:q10Row];
            [self reloadFormRow:q10ResponseRow];
        }
    };

//    XLFormSectionDescriptor *finalSection = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:finalSection];

//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUpReq
//                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
//                                                  title:@"Does resident require further follow up?"];
//    [self setDefaultFontWithRow:row];
//    row.selectorOptions = @[@"Yes",@"No"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//
//    //value
//    if (geriaDepreAssmtDict != (id)[NSNull null] && [geriaDepreAssmtDict objectForKey:kFollowUpReq] != (id)[NSNull null]) {
//        row.value = [self getYesNofromOneZero:geriaDepreAssmtDict[kFollowUpReq]];
//    }
//    [finalSection addFormRow:row];

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
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
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
    
    NSString* ansFromYESNO;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"YES"])
            ansFromYESNO = @"1";
        else if ([newValue isEqualToString:@"NO"])
            ansFromYESNO = @"0";
    }
    
    /* Geriatric Dementia Assessment */
    if ([rowDescriptor.tag isEqualToString:kPhqQ1]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ1 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ2]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ2 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ3]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ3 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ4]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ4 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ5]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ5 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ6]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ6 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ7]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ7 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kPhqQ8]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ8 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    }  else if ([rowDescriptor.tag isEqualToString:kPhqQ9]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhqQ9 andNewContent:[self getNumberFromPhqOption:newValue]];
        phqTotalScoreRow.value = [NSNumber numberWithInt:[self calculateTotalPhqScore]];
        [self reloadFormRow:phqTotalScoreRow];
    } else if ([rowDescriptor.tag isEqualToString:kPhq9Score]) {
        
        // if don't delay, not 100% success rate in submission
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kPhq9Score andNewContent:newValue];
        });
    }  else if ([rowDescriptor.tag isEqualToString:kQ10Response]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kQ10Response andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kFollowUpReq]) {
        [self postSingleFieldWithSection:SECTION_SW_DEPRESSION andFieldName:kFollowUpReq andNewContent:ansFromYesNo];
    }
    
    
    else if ([rowDescriptor.tag isEqualToString:kCopeFin]) {
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
    
    else if ([rowDescriptor.tag isEqualToString:@"multiple_ADL"]) {
        [self processActivitiesWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kMobilityStatus]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_PHY_STATUS andFieldName:kMobilityStatus andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kMobilityEquipment]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_PHY_STATUS andFieldName:kMobilityEquipment andNewContent:ansFromYesNo];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kHasCaregiver]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kHasCaregiver andNewContent:ansFromYESNO];
    } else if ([rowDescriptor.tag isEqualToString:kEContact]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kEContact andNewContent:ansFromYESNO];
    } else if ([rowDescriptor.tag isEqualToString:kUCaregiver]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kUCaregiver andNewContent:ansFromYESNO];
    } else if ([rowDescriptor.tag isEqualToString:kUCareStress]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kUCareStress andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kCaregivingAssist]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kCaregivingAssist andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kGettingSupport]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kGettingSupport andNewContent:ansFromYESNO];
    } else if ([rowDescriptor.tag isEqualToString:@"multi_support"]) {
        [self processDiffSupportWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kRelativesContact]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kRelativesContact andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kRelativesEase]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kRelativesEase andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kRelativesClose]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kRelativesClose andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFriendsContact]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kFriendsContact andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFriendsEase]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kFriendsEase andNewContent:rowDescriptor.value];
    }else if ([rowDescriptor.tag isEqualToString:kFriendsClose]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kFriendsClose andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSocialScore]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kSocialScore andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kParticipateActivities]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kParticipateActivities andNewContent:ansFromYESNO];
    } else if ([rowDescriptor.tag isEqualToString:@"multi_host"]) {
        [self processWhereActivitiesWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:@"multi_why_not_comm_activities"]) {
        [self processWhyNotJoinWithNewValue:newValue andOldValue:oldValue];
    }
    
    //Psychological Well-being
    else if ([rowDescriptor.tag isEqualToString:kIsPsychotic]) {
        [self postSingleFieldWithSection:SECTION_PSYCH_WELL_BEING andFieldName:kIsPsychotic andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kSuicideIdeas]) {
        [self postSingleFieldWithSection:SECTION_PSYCH_WELL_BEING andFieldName:kSuicideIdeas andNewContent:ansFromYesNo];
    }
    //Psychological Well-being
    else if ([rowDescriptor.tag isEqualToString:kBedbug]) {
        [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:kBedbug andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:@"multi_bedbug_symptom"]) {
        [self processBedbugSymptomWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:@"multi_service_required"]) {
        [self processScvRequiredWithNewValue:newValue andOldValue:oldValue];
    }
    
    // Summary
    else if ([rowDescriptor.tag isEqualToString:@"summary_problems"]) {
        [self processPresentingProblemsWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kCaseCat]) {
        [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:kCaseCat andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCommReview]) {
        [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:kCommReview andNewContent:rowDescriptor.value];
    }

    
}

-(void)beginEditing:(XLFormRowDescriptor *)rowDescriptor {
    if ([rowDescriptor.tag isEqualToString:kInterventions]) {
        if (rowDescriptor.value == nil || [rowDescriptor.value isEqualToString:@""]) {
            if (!hasShownProposedBox) {
                hasShownProposedBox = true;
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notice", nil)
                                                                                          message:@"(i) Recommend and justify possible interventions \n(ii) What is resident's perception on whether they require/want the service?"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * okAction){
                                                                      
                                                                  }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {    //works great for textField and textView
    
    if (rowDescriptor.value == nil) {
        rowDescriptor.value = @"";  //empty string
    }
    
    if ([rowDescriptor.tag isEqualToString:kDescribeWork]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_SOCIOECO_SITUATION andFieldName:kDescribeWork andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kMoreWhyNotCopeFin]) {
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
    
    else if ([rowDescriptor.tag isEqualToString:kMobilityEquipmentText]) {
        [self postSingleFieldWithSection:SECTION_CURRENT_PHY_STATUS andFieldName:kMobilityEquipmentText andNewContent:rowDescriptor.value];
    }
    
    //Social Support Assessment
    else if ([rowDescriptor.tag isEqualToString:kCaregiverName]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kCaregiverName andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCaregiverRs]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kCaregiverRs andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCaregiverContactNum]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kCaregiverContactNum andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kEContactName]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kEContactName andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kEContactRs]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kEContactRs andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kEContactNum]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kEContactNum andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCaregivingDescribe]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kCaregivingDescribe andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCaregivingAssistType]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kCaregivingAssistType andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kEContactNum]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kEContactNum andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kOthersText]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kOthersText andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSocialNetwork]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kSocialNetwork andNewContent:rowDescriptor.value];
    }
    else if ([rowDescriptor.tag isEqualToString:kHostOthers]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kHostOthers andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kWhyNoParticipate]) {
        [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:kWhyNoParticipate andNewContent:rowDescriptor.value];
    }

    
    //Psychological Well-being
    else if ([rowDescriptor.tag isEqualToString:kPsychoticRemarks]) {
        [self postSingleFieldWithSection:SECTION_PSYCH_WELL_BEING andFieldName:kPsychoticRemarks andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSuicideIdeasRemarks]) {
        [self postSingleFieldWithSection:SECTION_PSYCH_WELL_BEING andFieldName:kSuicideIdeasRemarks andNewContent:rowDescriptor.value];
    }
    
    //Additional Services
    else if ([rowDescriptor.tag isEqualToString:kBedbugOthersText]) {
        [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:kBedbugOthersText andNewContent:rowDescriptor.value];
    }
    
    // Summary
    else if ([rowDescriptor.tag isEqualToString:kProblems]) {
        [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:kProblems andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kInterventions]) {
        [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:kInterventions andNewContent:rowDescriptor.value];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kSwVolName]) {
        [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:kSwVolName andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSwVolContactNum]) {
        [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:kSwVolContactNum andNewContent:rowDescriptor.value];
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
    else if ([expenses containsString:@"None"]) return kNoneOfTheAbove;
    else return @"";
}

- (void) processActivitiesWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_CURRENT_PHY_STATUS andFieldName:[self getFieldNameFromActivities:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_CURRENT_PHY_STATUS andFieldName:[self getFieldNameFromActivities:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_CURRENT_PHY_STATUS andFieldName:[self getFieldNameFromActivities:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_CURRENT_PHY_STATUS andFieldName:[self getFieldNameFromActivities:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}


- (NSString *) getFieldNameFromActivities: (NSString *) activities {
    if ([activities containsString:@"Bathe"]) return kBathe  ;
    else if ([activities containsString:@"Dress"]) return kDress;
    else if ([activities containsString:@"Eat"]) return kEat;
    else if ([activities containsString:@"Personal Hygiene"]) return kHygiene;
    else if ([activities containsString:@"Toileting"]) return kToileting;
    else if ([activities containsString:@"Transfer"]) return kWalk;
    else return @"";
}

- (void) processDiffSupportWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromSupports:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromSupports:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromSupports:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromSupports:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}


- (NSString *) getFieldNameFromSupports: (NSString *) activities {
    if ([activities containsString:@"Care-giving"]) return kCareGiving;
    else if ([activities containsString:@"Food"]) return kFood;
    else if ([activities containsString:@"Money"]) return kMoney;
    else if ([activities containsString:@"Others"]) return kOtherSupport;
    else return @"";
}

- (void) processWhereActivitiesWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromWhereActivities:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromWhereActivities:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromWhereActivities:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromWhereActivities:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}


- (NSString *) getFieldNameFromWhereActivities: (NSString *) activities {
    if ([activities containsString:@"SAC"]) return kSac;
    else if ([activities containsString:@"FSC"]) return kFsc;
    else if ([activities containsString:@"CC"]) return kCc;
    else if ([activities containsString:@"RC"]) return kRc;
    else if ([activities containsString:@"Religious"]) return kRo;
    else if ([activities containsString:@"Self-organised"]) return kSo;
    else if ([activities containsString:@"Others"]) return kOth;
    else return @"";
}

- (void) processWhyNotJoinWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromWhyNotJoin:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromWhyNotJoin:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromWhyNotJoin:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_SOCIAL_SUPPORT andFieldName:[self getFieldNameFromWhyNotJoin:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}


- (NSString *) getFieldNameFromWhyNotJoin: (NSString *) activities {
    if ([activities containsString:@"Don't know"]) return kDontKnow;
    else if ([activities containsString:@"Don't like"]) return kDontLike;
    else if ([activities containsString:@"Mobility Issues"]) return kMobilityIssues;
    else if ([activities containsString:@"Others"]) return kWhyNotOthers;
    else return @"";
}

- (void) processBedbugSymptomWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:[self getFieldNameFromBedbugSymptom:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:[self getFieldNameFromBedbugSymptom:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:[self getFieldNameFromBedbugSymptom:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:[self getFieldNameFromBedbugSymptom:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}


- (NSString *) getFieldNameFromBedbugSymptom: (NSString *) symptoms {
    if ([symptoms containsString:@"Dried scars on body"]) return kDriedScars;
    else if ([symptoms containsString:@"Hoarding behavior"]) return kHoardingBeh;
    else if ([symptoms containsString:@"Itchy bites on skin"]) return kItchyBites;
    else if ([symptoms containsString:@"Poor personal hygiene"]) return kPoorHygiene;
    else if ([symptoms containsString:@"Bedbug blood stains on furniture/floor"]) return kBedbugStains;
    else if ([symptoms containsString:@"Others (specify in next field)"]) return kBedbugOthers;
    else return @"";
}

- (void) processScvRequiredWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:[self getFieldNameFromSvcRequired:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:[self getFieldNameFromSvcRequired:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:[self getFieldNameFromSvcRequired:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_SW_ADD_SERVICES andFieldName:[self getFieldNameFromSvcRequired:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}


- (NSString *) getFieldNameFromSvcRequired: (NSString *) svc {
    if ([svc containsString:@"Bedbug eradication services"]) return kRequiresBedbug;
    else if ([svc containsString:@"Decluttering services"]) return kRequiresDecluttering;

    else return @"";
}

- (void) processPresentingProblemsWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:[self getFieldNameFromPresentingProblems:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:[self getFieldNameFromPresentingProblems:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:[self getFieldNameFromPresentingProblems:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_SOC_WORK_SUMMARY andFieldName:[self getFieldNameFromPresentingProblems:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}


- (NSString *) getFieldNameFromPresentingProblems: (NSString *) svc {
    if ([svc containsString:@"Financial"]) return kFinancial;
    else if ([svc containsString:@"ElderCare"]) return kEldercare;
    else if ([svc containsString:@"BASIC"]) return kBasic;
    else if ([svc containsString:@"Behavioural"]) return kBehEmo;
    else if ([svc containsString:@"Family"]) return kFamMarital;
    else if ([svc containsString:@"Employment"]) return kEmployment;
    else if ([svc containsString:@"Legal"]) return kLegal;
    else if ([svc containsString:@"services"]) return kOtherServices;
    else if ([svc containsString:@"Accommodation"]) return kAccom;
    else if ([svc containsString:@"Other Issues"]) return kOtherIssues;
    else if ([svc containsString:@"Nil"]) return kOptionNil;
    
    else return @"";
}

#pragma mark - Initialisation of Value

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
    NSArray *keyArray = @[kHasChas, kHasPgp, kHasMedisave, kHasInsure, kHasCpfPayouts, kNoneOfTheAbove];
    NSArray *textArray = @[@"Community Health Assist Scheme", @"Pioneer Generation Package", @"Medisave", @"Insurance Coverage", @"CPF Pay Outs",@"None of the above"];
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

- (NSArray *) getActivitiesArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kBathe, kDress, kEat, kHygiene, kToileting, kWalk];
    NSArray *textArray = @[@"Bathe/Shower", @"Dress", @"Eat", @"Personal Hygiene and Grooming", @"Toileting",@"Transfer/Walk"];
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

- (NSArray *) getMultiSupportArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kCareGiving, kFood, kMoney, kOtherSupport];
    NSArray *textArray = @[@"Care-giving", @"Food", @"Money", @"Others"];
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

- (NSArray *) getMultiHostArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kSac, kFsc, kCc, kRc, kRo, kSo, kOth];
    NSArray *textArray = @[@"Senior Activity Centre (SAC)", @"Family Services Centre (FSC)", @"Community Centre (CC)", @"Residents' Committee (RC)", @"Religious Organisations", @"Self-organised", @"Others"];
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

- (NSArray *) getWhyNotJoinArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kDontKnow, kDontLike, kMobilityIssues, kWhyNotOthers];
    NSArray *textArray = @[@"Don't know", @"Don't like", @"Mobility Issues", @"Others"];
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

- (NSArray *) getBedbugSymptomArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kDriedScars, kHoardingBeh, kItchyBites, kPoorHygiene, kBedbugStains, kBedbugOthers];
    NSArray *textArray = @[@"Dried scars on body", @"Hoarding behavior", @"Itchy bites on skin", @"Poor personal hygiene", @"Bedbug blood stains on furniture/floor", @"Others (specify in next field)"];
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

- (NSArray *) getReqSvcsArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kRequiresBedbug, kRequiresDecluttering];
    NSArray *textArray = @[@"Bedbug eradication services", @"Decluttering services"];
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

- (NSArray *) getPresentingProblemsArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kFinancial, kEldercare, kBasic, kBehEmo, kFamMarital, kEmployment, kLegal, kOtherServices, kAccom, kOtherIssues, kOptionNil];
    NSArray *textArray = @[@"Financial",
                           @"ElderCare",
                           @"BASIC/Childcare",
                           @"Behavioural/Emotional",
                           @"Family/Marital",
                           @"Employment",
                           @"Legal",
                           @"Other services (Bedbugs, Mobility)",
                           @"Accommodation (Tenant issues, housing matters...)",
                           @"Other Issues",
                           @"Nil"];
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


- (NSString *) getSelectorOptionFromNumber: (NSNumber *) number {
    if ([number isEqualToNumber:@0]) return @"Not at all [0]";
    else if ([number isEqualToNumber:@1]) return @"Several days [1]";
    else if ([number isEqualToNumber:@2]) return @"More than half the days [2]";
    else return @"Nearly every day [3]";
}

- (NSString *) getNumberFromPhqOption: (NSString *) str {
    if ([str containsString:@"0"]) return @"0";
    else if ([str containsString:@"1"]) return @"1";
    else if ([str containsString:@"2"]) return @"2";
    else return @"3";
}

- (int) getScoreFromPhqOptions: (NSString *) option {
    if ([option isEqualToString:@"Not at all [0]"]) return 0;
    else if ([option isEqualToString:@"Several days [1]"]) return 1;
    else if ([option isEqualToString:@"More than half the days [2]"]) return 2;
    else return 3;
}

- (int) calculateTotalPhqScore {
    
    int totalScore = 0;
    
    for (XLFormRowDescriptor *row in _phqQuestionsArray) {
        if (row.value != nil && row.value !=(id)[NSNull null]) {
            if ([row.value containsString:@"0"]) totalScore = totalScore;
            else if ([row.value containsString:@"1"]) totalScore += 1;
            else if ([row.value containsString:@"2"]) totalScore += 2;
            else if ([row.value containsString:@"3"]) totalScore += 3;
        }
    }
    return totalScore;
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

- (NSString *) getYESNOfromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"]) {
            return @"YES";
        } else {
            return @"NO";
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1]) {
            return @"YES";
        } else {
            return @"NO";
        }
    }
    return @"";
}

#pragma mark - Button methods
- (void) computeScoreButton: (XLFormRowDescriptor *)sender {
    NSInteger score = [self getPointsFromStringValue:relativesContactRow.value] + [self getPointsFromStringValue:relativesEaseRow.value] + [self getPointsFromStringValue:relativesCloseRow.value] + [self getPointsFromStringValue:friendsContactRow.value] + [self getPointsFromStringValue:friendsEaseRow.value] + [self getPointsFromStringValue:friendsCloseRow.value];
    
    socialScoreRow.value = [NSString stringWithFormat:@"%ld", (long)score];
    [self updateFormRow:socialScoreRow];
    
    [self deselectFormRow:sender];
}

- (NSUInteger) getPointsFromStringValue: (NSString *) value{
    
    if (value == nil || value == (id) [NSNull null]) return 0;
    
    if ([value containsString:@"None"]) return 0;
    else if ([value containsString:@"One"]) return 1;
    else if ([value containsString:@"Two"]) return 2;
    else if ([value containsString:@"Three"]) return 3;
    else if ([value containsString:@"Five"]) return 4;
    else if ([value containsString:@"Nine"]) return 5;
    else return 0;
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

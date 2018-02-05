//
//  QuestionnaireFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 10/19/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "QuestionnaireFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "KAStatusBar.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "math.h"
#import "ScreeningDictionary.h"


typedef enum formName {
    MedicalIssues = 1,
    SocialIssues
} formName;


@interface QuestionnaireFormVC () {
    BOOL internetDCed;
    BOOL isFormFinalized;
    int currentForm;
    XLFormRowDescriptor *faceSocProbRow;
}

@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;


@end

@implementation QuestionnaireFormVC

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    
    XLFormViewController *form;
    //must init first before [super viewDidLoad]
    int formNumber = [_formNo intValue];
    switch (formNumber) {
            //case 0 is for demographics
        case 1:
            form = [self initMedicalIssues];
            currentForm = MedicalIssues;
            break;
        case 2:
            form = [self initSocialIssues];
            currentForm = SocialIssues;
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
}

- (void) viewWillDisappear:(BOOL)animated {
    //    [self saveEntriesIntoDictionary];
    [KAStatusBar dismiss];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    [super viewWillDisappear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (id) initMedicalIssues {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Medical Issues"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    NSDictionary *medIssuesDict = [_fullScreeningForm objectForKey:SECTION_PSFU_MED_ISSUES];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckPSFUMedIssues];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *faceMedProbRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFaceMedProb rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is this resident currently facing any medical problems?"];
    [self setDefaultFontWithRow:faceMedProbRow];
    faceMedProbRow.selectorOptions = @[@"Yes", @"No"];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kFaceMedProb] != (id)[NSNull null]) {
        faceMedProbRow.value = [self getYesNofromOneZero:medIssuesDict[kFaceMedProb]];
    }
    
    faceMedProbRow.required = YES;
    
    faceMedProbRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:faceMedProbRow];
    
    XLFormRowDescriptor *whoFaceMedProbRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWhoFaceMedProb rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Who is facing the medical problem?"];
    [self setDefaultFontWithRow:whoFaceMedProbRow];
    whoFaceMedProbRow.selectorOptions = @[@"Resident", @"Resident's family", @"Resident's flatmate",@"Resident's neighbour"];
    whoFaceMedProbRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", faceMedProbRow];
    
    //value
    if (medIssuesDict != (id)[NSNull null]) {
        whoFaceMedProbRow.value = [self getMedIssueWhoFaceArray:medIssuesDict];
    }
    
    [section addFormRow:whoFaceMedProbRow];
    
    /** Family */
    
    XLFormSectionDescriptor *familySection = [XLFormSectionDescriptor formSectionWithTitle:@"Family Details"];
    [formDescriptor addFormSection:familySection];
    
    if (whoFaceMedProbRow.value != nil) {
        if ([whoFaceMedProbRow.value containsObject:@"Resident's family"]) {
            familySection.hidden = @NO;
        } else {
            familySection.hidden = @YES;
        }
    } else {
        familySection.hidden = @YES;
    }

    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kFamilyName] != (id)[NSNull null]) {
        row.value = medIssuesDict[kFamilyName];
    }
    
    [familySection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kFamilyAdd] != (id)[NSNull null]) {
        row.value = [medIssuesDict objectForKey:kFamilyAdd];
    }
    
    [familySection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kFamilyHp] != (id)[NSNull null]) {
        row.value = medIssuesDict[kFamilyHp];
    }
    [familySection addFormRow:row];

    /** Flatmate */
    
    XLFormSectionDescriptor *flatmateSection = [XLFormSectionDescriptor formSectionWithTitle:@"Flatmate Details"];
    [formDescriptor addFormSection:flatmateSection];
    
    if (whoFaceMedProbRow.value != nil) {
        if ([whoFaceMedProbRow.value containsObject:@"Resident's flatmate"]) {
            flatmateSection.hidden = @NO;
        } else {
            flatmateSection.hidden = @YES;
        }
    } else {
        flatmateSection.hidden = @YES;
    }

    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFlatmateName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kFlatmateName] != (id)[NSNull null]) {
        row.value = medIssuesDict[kFlatmateName];
    }
    
    [flatmateSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFlatmateAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kFlatmateAdd] != (id)[NSNull null]) {
        row.value = [medIssuesDict objectForKey:kFlatmateAdd];
    }
    
    [flatmateSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFlatmateHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kFlatmateHp] != (id)[NSNull null]) {
        row.value = medIssuesDict[kFlatmateHp];
    }
    [flatmateSection addFormRow:row];
    
    /** Flatmate */
    
    XLFormSectionDescriptor *neighbourSection = [XLFormSectionDescriptor formSectionWithTitle:@"Neighbour Details"];
    [formDescriptor addFormSection:neighbourSection];
    
    if (whoFaceMedProbRow.value != nil) {
        if ([whoFaceMedProbRow.value containsObject:@"Resident's neighbour"]) {
            neighbourSection.hidden = @NO;
        } else {
            neighbourSection.hidden = @YES;
        }
    } else {
        neighbourSection.hidden = @YES;
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kNeighbourName] != (id)[NSNull null]) {
        row.value = medIssuesDict[kNeighbourName];
    }
    
    [neighbourSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kNeighbourAdd] != (id)[NSNull null]) {
        row.value = [medIssuesDict objectForKey:kNeighbourAdd];
    }
    
    [neighbourSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kNeighbourHp] != (id)[NSNull null]) {
        row.value = medIssuesDict[kNeighbourHp];
    }
    [neighbourSection addFormRow:row];
    
    // Detect change of options to show relevant sections
    
    whoFaceMedProbRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue containsObject:@"Resident's family"]) {
                familySection.hidden = @NO;
            } else {
                familySection.hidden = @YES;
            }
            if ([newValue containsObject:@"Resident's flatmate"]) {
                flatmateSection.hidden = @NO;
            } else {
                flatmateSection.hidden = @YES;
            }
            if ([newValue containsObject:@"Resident's neighbour"]) {
                neighbourSection.hidden = @NO;
            } else {
                neighbourSection.hidden = @YES;
            }
        }
    };
    
    
    /** Section II */

    XLFormSectionDescriptor * section2 =  [XLFormSectionDescriptor formSectionWithTitle:@""];;
    [formDescriptor addFormSection:section2];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHaveHighBpChosCbg rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does this resident currently have borderline & above values for BP/cholesterol/CBG"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kHaveHighBpChosCbg] != (id)[NSNull null]) {
        row.value = [self getYesNofromOneZero:medIssuesDict[kHaveHighBpChosCbg]];
    }
    
    row.required = YES;
    [section2 addFormRow:row];
    
    XLFormRowDescriptor *haveOtherMedIssuesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHaveOtherMedIssues rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does the resident have other medical issues?"];
    [self setDefaultFontWithRow:haveOtherMedIssuesRow];
    haveOtherMedIssuesRow.selectorOptions = @[@"Yes", @"No"];
    haveOtherMedIssuesRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kHaveOtherMedIssues] != (id)[NSNull null]) {
        haveOtherMedIssuesRow.value = [self getYesNofromOneZero:medIssuesDict[kHaveOtherMedIssues]];
    }
    
    haveOtherMedIssuesRow.required = YES;
    [section2 addFormRow:haveOtherMedIssuesRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"question" rowType:XLFormRowDescriptorTypeInfo title:@"Please list a short history of the medical issue"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", haveOtherMedIssuesRow];
    [section2 addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHistMedIssues rowType:XLFormRowDescriptorTypeTextView title:@""];
    
    [row.cellConfigAtConfigure setObject:@"Type here..." forKey:@"textView.placeholder"];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kHistMedIssues] != (id)[NSNull null]) {
        row.value = [medIssuesDict objectForKey:kHistMedIssues];
    }
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", haveOtherMedIssuesRow];
    
    [section2 addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPsfuSeeingDoct rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is this resident currently seeing a doctor?"];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kPsfuSeeingDoct] != (id)[NSNull null]) {
        row.value = [self getYesNofromOneZero:medIssuesDict[kPsfuSeeingDoct]];
    }
    
    row.required = YES;
    [section2 addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNhsfuFlag rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Flag this resident to NHSFU (✓) "];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kNhsfuFlag] != (id)[NSNull null]) {
        row.value = medIssuesDict[kNhsfuFlag];
    }
    
    row.required = YES;
    [section2 addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}


- (id) initSocialIssues {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Social Issues"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *socIssuesDict = [_fullScreeningForm objectForKey:SECTION_PSFU_SOCIAL_ISSUES];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckPSFUSocialIssues];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    faceSocProbRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFaceSocialProb rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is this resident currently facing any social problems?"];
    [self setDefaultFontWithRow:faceSocProbRow];
    faceSocProbRow.selectorOptions = @[@"Yes", @"No"];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kFaceSocialProb] != (id)[NSNull null]) {
        faceSocProbRow.value = [self getYesNofromOneZero:socIssuesDict[kFaceSocialProb]];
    }
    
    faceSocProbRow.required = YES;
    
    faceSocProbRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:faceSocProbRow];
    
    XLFormRowDescriptor *whoFaceSocProbRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWhoFaceSocialProb rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Who is facing the social problem?"];
    [self setDefaultFontWithRow:whoFaceSocProbRow];
    whoFaceSocProbRow.selectorOptions = @[@"Resident", @"Resident's family", @"Resident's flatmate",@"Resident's neighbour"];
    whoFaceSocProbRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", faceSocProbRow];
    
    //value
    if (socIssuesDict != (id)[NSNull null]) {
        whoFaceSocProbRow.value = [self getSocialIssueWhoFaceArray:socIssuesDict];
    }
    
    [section addFormRow:whoFaceSocProbRow];
    
    /** Family */
    
    XLFormSectionDescriptor *familySection = [XLFormSectionDescriptor formSectionWithTitle:@"Family Details"];
    [formDescriptor addFormSection:familySection];
    
    if (whoFaceSocProbRow.value != nil) {
        if ([whoFaceSocProbRow.value containsObject:@"Resident's family"]) {
            familySection.hidden = @NO;
        } else {
            familySection.hidden = @YES;
        }
    } else {
        familySection.hidden = @YES;
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kFamilyName] != (id)[NSNull null]) {
        row.value = socIssuesDict[kFamilyName];
    }
    
    [familySection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kFamilyAdd] != (id)[NSNull null]) {
        row.value = [socIssuesDict objectForKey:kFamilyAdd];
    }
    
    [familySection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kFamilyHp] != (id)[NSNull null]) {
        row.value = socIssuesDict[kFamilyHp];
    }
    [familySection addFormRow:row];
    
    /** Flatmate */
    
    XLFormSectionDescriptor *flatmateSection = [XLFormSectionDescriptor formSectionWithTitle:@"Flatmate Details"];
    [formDescriptor addFormSection:flatmateSection];
    
    if (whoFaceSocProbRow.value != nil) {
        if ([whoFaceSocProbRow.value containsObject:@"Resident's flatmate"]) {
            flatmateSection.hidden = @NO;
        } else {
            flatmateSection.hidden = @YES;
        }
    } else {
        flatmateSection.hidden = @YES;
    }
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFlatmateName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kFlatmateName] != (id)[NSNull null]) {
        row.value = socIssuesDict[kFlatmateName];
    }
    
    [flatmateSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFlatmateAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kFlatmateAdd] != (id)[NSNull null]) {
        row.value = [socIssuesDict objectForKey:kFlatmateAdd];
    }
    
    [flatmateSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFlatmateHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kFlatmateHp] != (id)[NSNull null]) {
        row.value = socIssuesDict[kFlatmateHp];
    }
    [flatmateSection addFormRow:row];
    
    /** Flatmate */
    
    XLFormSectionDescriptor *neighbourSection = [XLFormSectionDescriptor formSectionWithTitle:@"Neighbour Details"];
    [formDescriptor addFormSection:neighbourSection];
    
    if (whoFaceSocProbRow.value != nil) {
        if ([whoFaceSocProbRow.value containsObject:@"Resident's neighbour"]) {
            neighbourSection.hidden = @NO;
        } else {
            neighbourSection.hidden = @YES;
        }
    } else {
        neighbourSection.hidden = @YES;
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kNeighbourName] != (id)[NSNull null]) {
        row.value = socIssuesDict[kNeighbourName];
    }
    
    [neighbourSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kNeighbourAdd] != (id)[NSNull null]) {
        row.value = [socIssuesDict objectForKey:kNeighbourAdd];
    }
    
    [neighbourSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kNeighbourHp] != (id)[NSNull null]) {
        row.value = socIssuesDict[kNeighbourHp];
    }
    [neighbourSection addFormRow:row];
    
    // Detect change of options to show relevant sections
    
    whoFaceSocProbRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue containsObject:@"Resident's family"]) {
                familySection.hidden = @NO;
            } else {
                familySection.hidden = @YES;
            }
            if ([newValue containsObject:@"Resident's flatmate"]) {
                flatmateSection.hidden = @NO;
            } else {
                flatmateSection.hidden = @YES;
            }
            if ([newValue containsObject:@"Resident's neighbour"]) {
                neighbourSection.hidden = @NO;
            } else {
                neighbourSection.hidden = @YES;
            }
        }
    };
    
    
    /** Section II */
    
    XLFormSectionDescriptor * section2 =  [XLFormSectionDescriptor formSectionWithTitle:@""];;
    [formDescriptor addFormSection:section2];
    
    XLFormRowDescriptor *notConnSocWkAgencyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNotConnectSocWkAgency rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is this resident currently NOT connected to a social work agency?"];
    [self setDefaultFontWithRow:notConnSocWkAgencyRow];
    notConnSocWkAgencyRow.selectorOptions = @[@"Yes", @"No"];
    notConnSocWkAgencyRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", faceSocProbRow];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kNotConnectSocWkAgency] != (id)[NSNull null]) {
        notConnSocWkAgencyRow.value = [self getYesNofromOneZero:socIssuesDict[kNotConnectSocWkAgency]];
    }
    
    notConnSocWkAgencyRow.required = YES;
    
    notConnSocWkAgencyRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section2 addFormRow:notConnSocWkAgencyRow];
    
    XLFormRowDescriptor *unwillSeekAgencyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kUnwillingSeekAgency rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is this resident unwilling to seek agency help directly on their own?"];
    [self setDefaultFontWithRow:unwillSeekAgencyRow];
    unwillSeekAgencyRow.selectorOptions = @[@"Yes", @"No"];
    unwillSeekAgencyRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", faceSocProbRow];
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kUnwillingSeekAgency] != (id)[NSNull null]) {
        unwillSeekAgencyRow.value = [self getYesNofromOneZero:socIssuesDict[kUnwillingSeekAgency]];
    }
    
    unwillSeekAgencyRow.required = YES;
    
    unwillSeekAgencyRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section2 addFormRow:unwillSeekAgencyRow];
    
    XLFormRowDescriptor *nhsswRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNhsswFlag rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Flag this resident to NHSSW (✓)"];
    [self setDefaultFontWithRow:nhsswRow];
    nhsswRow.disabled = @YES;   //it will be auto-assigned
    
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kNhsswFlag] != (id)[NSNull null]) {
        nhsswRow.value = socIssuesDict[kNhsswFlag];
    }
    [section2 addFormRow:nhsswRow];
    
    notConnSocWkAgencyRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                if (unwillSeekAgencyRow.value != nil && [unwillSeekAgencyRow.value isEqualToString:@"Yes"]) {
                    nhsswRow.value = @1;    // give it a tick
                } else {
                    nhsswRow.value = @0;
                }
            } else {
                nhsswRow.value = @0;
            }
            [self updateFormRow:nhsswRow];
        }
    };
    
    
    unwillSeekAgencyRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                if (notConnSocWkAgencyRow.value != nil && [notConnSocWkAgencyRow.value isEqualToString:@"Yes"]) {
                    nhsswRow.value = @1;    // give it a tick
                } else {
                    nhsswRow.value = @0;
                }
            } else {
                nhsswRow.value = @0;
            }
            [self updateFormRow:nhsswRow];
        }
    };
    
    [section2 addFormRow:nhsswRow];
    
    XLFormSectionDescriptor *section3 = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section3];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q_spectrum" rowType:XLFormRowDescriptorTypeInfo title:@"What is the spectrum of concern(s)?"];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    row.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", faceSocProbRow];
    
    [section3 addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpectrumConcerns rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Type here..." forKey:@"textView.placeholder"];
    row.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", faceSocProbRow];
    //value
    if (socIssuesDict != (id)[NSNull null] && [socIssuesDict objectForKey:kSpectrumConcerns] != (id)[NSNull null]) {
        row.value = [socIssuesDict objectForKey:kSpectrumConcerns];
    }
    
    [section3 addFormRow:row];
    
    XLFormSectionDescriptor *section4 = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section4];
    
    XLFormRowDescriptor *natureOfIssueRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNatureOfIssue rowType:XLFormRowDescriptorTypeMultipleSelector title:@"What is the nature of the issue?"];
    [self setDefaultFontWithRow:natureOfIssueRow];
    natureOfIssueRow.selectorOptions = @[@"Caregiving", @"Financial", @"Others"];
    natureOfIssueRow.disabled = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", faceSocProbRow];
    
    //value
    if (socIssuesDict != (id)[NSNull null]) {
        natureOfIssueRow.value = [self getNatureOfIssueArray:socIssuesDict];
    }
    
    [section4 addFormRow:natureOfIssueRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSocIssueOthersText rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@"Please specify here..." forKey:@"textField.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", natureOfIssueRow];
    //value
    if (socIssuesDict != (id)[NSNull null]) {
        row.value = [socIssuesDict objectForKey:kSocIssueOthersText];
    }
    
    [section4 addFormRow:row];
    
    
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
            case MedicalIssues: fieldName = kCheckPSFUMedIssues;
                break;
            case SocialIssues: fieldName = kCheckPSFUSocialIssues;
                break;
            default:
                break;
        }
        
        [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:fieldName andNewContent:@"0"]; //un-finalize it
    }
    
}

- (void) finalizeBtnPressed: (UIBarButtonItem * __unused) button {
    
    NSLog(@"%@", [self.form formValues]);
    
    if (faceSocProbRow.value != nil && [faceSocProbRow.value isEqualToString:@"No"] && currentForm == SocialIssues ){      //special exception, ignore all required fields
        // do nothing
    } else {
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
            
            return; //will return here if there's error
        }
    }
    
    NSString *fieldName;
    
    switch ([self.formNo intValue]) {
        case MedicalIssues: fieldName = kCheckPSFUMedIssues;
            break;
        case SocialIssues: fieldName = kCheckPSFUSocialIssues;
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
    
    /** Medical Issues */
    if ([rowDescriptor.tag isEqualToString:kFaceMedProb]) {
        [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:kFaceMedProb andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kWhoFaceMedProb]) {   //multiple choice
        [self processMedProblemWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kHaveHighBpChosCbg]) {
        [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:kHaveHighBpChosCbg andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kHaveOtherMedIssues]) {
        [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:kHaveOtherMedIssues andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kPsfuSeeingDoct]) {
        [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:kPsfuSeeingDoct andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kNhsfuFlag]) {
        [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:kNhsfuFlag andNewContent:newValue];
    }
    
    
    /** Social Issues */
    else if ([rowDescriptor.tag isEqualToString:kFaceSocialProb]) {
        [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:kFaceSocialProb andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kWhoFaceSocialProb]) {   //multiple choice
        [self processSocialProblemWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kNotConnectSocWkAgency]) {
        [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:kNotConnectSocWkAgency andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kUnwillingSeekAgency]) {
        [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:kUnwillingSeekAgency andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kNhsswFlag]) {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:kNhsswFlag andNewContent:newValue];    //prevent miss-saving due to concurrent submission
        });
    } else if ([rowDescriptor.tag isEqualToString:kNatureOfIssue]) {
        [self processNatureOfIssueWithNewValue:newValue andOldValue:oldValue];
    }
}

-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {    //works great for textField and textView
    
    if (rowDescriptor.value == nil) {
        rowDescriptor.value = @"";  //empty string
    }
    NSString *section;
    
    if (currentForm == MedicalIssues) section = SECTION_PSFU_MED_ISSUES;
    else if (currentForm == SocialIssues) section = SECTION_PSFU_SOCIAL_ISSUES;
    
    /** Medical Issues */
    if ([rowDescriptor.tag isEqualToString:kFamilyName]) {
        [self postSingleFieldWithSection:section andFieldName:kFamilyName andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFamilyHp]) {
        [self postSingleFieldWithSection:section andFieldName:kFamilyHp andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFamilyAdd]) {
        [self postSingleFieldWithSection:section andFieldName:kFamilyAdd andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFlatmateName]) {
        [self postSingleFieldWithSection:section andFieldName:kFlatmateName andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFlatmateHp]) {
        [self postSingleFieldWithSection:section andFieldName:kFlatmateHp andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kFlatmateAdd]) {
        [self postSingleFieldWithSection:section andFieldName:kFlatmateAdd andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNeighbourName]) {
        [self postSingleFieldWithSection:section andFieldName:kNeighbourName andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNeighbourHp]) {
        [self postSingleFieldWithSection:section andFieldName:kNeighbourHp andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNeighbourAdd]) {
        [self postSingleFieldWithSection:section andFieldName:kNeighbourAdd andNewContent:rowDescriptor.value];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kHistMedIssues]) {
        [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:kHistMedIssues andNewContent:rowDescriptor.value];
    }
    
    /** Social Issues */
    
    else if ([rowDescriptor.tag isEqualToString:kSpectrumConcerns]) {
        [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:kSpectrumConcerns andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSocIssueOthersText]) {
        [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:kSocIssueOthersText andNewContent:rowDescriptor.value];
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

#pragma mark - Dictionary methods

- (NSArray *) getMedIssueWhoFaceArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kMedResident, kMedResFamily, kMedResFlatmate, kMedResNeighbour];
    NSArray *textArray = @[@"Resident",
                           @"Resident's family",
                           @"Resident's flatmate",
                           @"Resident's neighbour"];
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

- (NSArray *) getSocialIssueWhoFaceArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kSocialResident, kSocialResFamily, kSocialResFlatmate, kSocialResNeighbour];
    NSArray *textArray = @[@"Resident",
                           @"Resident's family",
                           @"Resident's flatmate",
                           @"Resident's neighbour"];
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

- (NSArray *) getNatureOfIssueArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kSocIssueCaregiving, kSocIssueFinancial, kSocIssueOthers];
    NSArray *textArray = @[@"Caregiving",
                           @"Financial",
                           @"Others"];
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


- (void) processMedProblemWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:[self getFieldNameFromFaceMedProblems:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:[self getFieldNameFromFaceMedProblems:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:[self getFieldNameFromFaceMedProblems:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_PSFU_MED_ISSUES andFieldName:[self getFieldNameFromFaceMedProblems:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
}

- (NSString *) getFieldNameFromFaceMedProblems: (NSString *) expenses {
    if ([expenses containsString:@"Resident's family"]) return kMedResFamily;
    else if ([expenses containsString:@"Resident's flatmate"]) return kMedResFlatmate;
    else if ([expenses containsString:@"Resident's neighbour"]) return kMedResNeighbour;
    else return kMedResident;
}

- (void) processSocialProblemWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:[self getFieldNameFromFaceSocialProblems:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:[self getFieldNameFromFaceSocialProblems:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:[self getFieldNameFromFaceSocialProblems:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:[self getFieldNameFromFaceSocialProblems:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
}

- (NSString *) getFieldNameFromFaceSocialProblems: (NSString *) expenses {
    
    if ([expenses containsString:@"Resident's family"]) return kSocialResFamily;
    else if ([expenses containsString:@"Resident's flatmate"]) return kSocialResFlatmate;
    else if ([expenses containsString:@"Resident's neighbour"]) return kSocialResNeighbour;
    else return kSocialResident;
}

- (void) processNatureOfIssueWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
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
                    [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:[self getFieldNameFromNatureOfIssue:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:[self getFieldNameFromNatureOfIssue:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:[self getFieldNameFromNatureOfIssue:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_PSFU_SOCIAL_ISSUES andFieldName:[self getFieldNameFromNatureOfIssue:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
}

- (NSString *) getFieldNameFromNatureOfIssue: (NSString *) string {
    if ([string containsString:@"Caregiving"]) return kSocIssueCaregiving;
    else if ([string containsString:@"Financial"]) return kSocIssueFinancial;
    else if ([string containsString:@"Others"]) return kSocIssueOthers;
    else return @"";
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


@end

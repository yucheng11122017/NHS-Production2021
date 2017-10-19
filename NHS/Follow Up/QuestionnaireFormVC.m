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
            break;
        case 2:
            form = [self initSocialIssues];
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
    
    [super viewDidLoad];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (id) initMedicalIssues {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Medical Issues"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *medIssuesDict = [_fullScreeningForm objectForKey:@"NEED TO CHANGE THIS"];
    
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

    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedFamilyName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedFamilyName] != (id)[NSNull null]) {
        row.value = medIssuesDict[kMedFamilyName];
    }
    
    [familySection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedFamilyAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedFamilyAdd] != (id)[NSNull null]) {
        row.value = [medIssuesDict objectForKey:kMedFamilyAdd];
    }
    
    [familySection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedFamilyHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedFamilyHp] != (id)[NSNull null]) {
        row.value = medIssuesDict[kMedFamilyHp];
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

    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedFlatmateName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedFlatmateName] != (id)[NSNull null]) {
        row.value = medIssuesDict[kMedFlatmateName];
    }
    
    [flatmateSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedFlatmateAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedFlatmateAdd] != (id)[NSNull null]) {
        row.value = [medIssuesDict objectForKey:kMedFlatmateAdd];
    }
    
    [flatmateSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedFlatmateHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedFlatmateHp] != (id)[NSNull null]) {
        row.value = medIssuesDict[kMedFlatmateHp];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedNeighbourName rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedNeighbourName] != (id)[NSNull null]) {
        row.value = medIssuesDict[kMedNeighbourName];
    }
    
    [neighbourSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedNeighbourAdd rowType:XLFormRowDescriptorTypeTextView title:@"Address"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedNeighbourAdd] != (id)[NSNull null]) {
        row.value = [medIssuesDict objectForKey:kMedNeighbourAdd];
    }
    
    [neighbourSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedNeighbourHp rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    
    //value
    if (medIssuesDict != (id)[NSNull null] && [medIssuesDict objectForKey:kMedNeighbourHp] != (id)[NSNull null]) {
        row.value = medIssuesDict[kMedNeighbourHp];
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *currentSocioSitDict = [_fullScreeningForm objectForKey:@"NEED TO CHANGE THIS"];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckPSFUSocialIssues];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
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
                           @"Resident's Neighbour"];
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

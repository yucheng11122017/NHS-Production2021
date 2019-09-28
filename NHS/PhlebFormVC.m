//
//  PhlebFormVC.m
//  NHS
//
//  Created by rehabpal on 3/9/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import "PhlebFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "KAStatusBar.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"
#import "ScreeningDictionary.h"


typedef enum formName {
    ResultsCollection,
    PhlebResults,
} formName;


@interface PhlebFormVC () {
    BOOL internetDCed;
    BOOL isFormFinalized;
}

@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSMutableArray *phqQuestionsArray;

@end

@implementation PhlebFormVC

- (void)viewDidLoad {
    
    isFormFinalized = false;    //by default
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
            
        case ResultsCollection:
            form = [self initPhlebResultsCollect];
            break;
        case PhlebResults:
            form = [self initResults];
            break;
        default:
            break;
    }
    [self.form setAddAsteriskToRequiredRowsTitle:YES];
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

- (id) initResults {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Phlebotomy"];
    XLFormSectionDescriptor * section;
    
    NSDictionary *phlebotomyDict = _fullScreeningForm[SECTION_PHLEBOTOMY];
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckPhleb];
        if ([check isKindOfClass:[NSNumber class]]) {
            //            isFormFinalized = [check boolValue];
            isFormFinalized = true;   //to always make it not enabled, as requested by Woon Wei
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    XLFormRowDescriptor *glucoseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFastingBloodGlucose rowType:XLFormRowDescriptorTypeDecimal title:@"Fasting blood glucose (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) glucoseRow.value = phlebotomyDict[kFastingBloodGlucose];
    glucoseRow.disabled = @1;
    [self setDefaultFontWithRow:glucoseRow];
    [section addFormRow:glucoseRow];
    
    XLFormRowDescriptor *triglyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTriglycerides rowType:XLFormRowDescriptorTypeDecimal title:@"Triglycerides (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) triglyRow.value = phlebotomyDict[kTriglycerides];
    triglyRow.disabled = @1;
    [self setDefaultFontWithRow:triglyRow];
    [section addFormRow:triglyRow];
    
    XLFormRowDescriptor *ldlRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLDL rowType:XLFormRowDescriptorTypeDecimal title:@"LDL Cholesterol (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) ldlRow.value = phlebotomyDict[kLDL];
    ldlRow.disabled = @1;
    [self setDefaultFontWithRow:ldlRow];
    [section addFormRow:ldlRow];
    
    XLFormRowDescriptor *hdlRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHDL rowType:XLFormRowDescriptorTypeDecimal title:@"HDL Cholesterol (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) hdlRow.value = phlebotomyDict[kHDL];
    hdlRow.disabled = @1;
    [self setDefaultFontWithRow:hdlRow];
    hdlRow.required = NO;
    [section addFormRow:hdlRow];
    
    XLFormRowDescriptor *totCholesterolRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTotCholesterol rowType:XLFormRowDescriptorTypeDecimal title:@"Total Cholesterol (mmol/L)"];
    if (phlebotomyDict != (id)[NSNull null]) totCholesterolRow.value = phlebotomyDict[kTotCholesterol];
    totCholesterolRow.disabled = @1;
    [self setDefaultFontWithRow:totCholesterolRow];
    [section addFormRow:totCholesterolRow];
    
    XLFormRowDescriptor *cholesHdlRatioRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCholesterolHdlRatio rowType:XLFormRowDescriptorTypeDecimal title:@"Cholesterol/HDL ratio"];
    if (phlebotomyDict != (id)[NSNull null]) cholesHdlRatioRow.value = phlebotomyDict[kCholesterolHdlRatio];
    cholesHdlRatioRow.disabled = @1;
    [self setDefaultFontWithRow:cholesHdlRatioRow];
    [section addFormRow:cholesHdlRatioRow];
    
    return [super initWithForm:formDescriptor];
}



- (id) initPhlebResultsCollect {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"2a. Results Collection"];
    XLFormSectionDescriptor * section;
    
    NSDictionary *resultsCollectionDict = [_fullScreeningForm objectForKey:SECTION_PHLEBOTOMY_RESULTS];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckPhlebResults];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *doingPhlebRow = [XLFormRowDescriptor
                                              formRowDescriptorWithTag:kPhlebDone
                                              rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Doing phlebotomy?"];
    doingPhlebRow.required = YES;
    
    [self setDefaultFontWithRow:doingPhlebRow];
    doingPhlebRow.selectorOptions = @[@"Yes", @"No"];
    doingPhlebRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:doingPhlebRow];
    
    if (resultsCollectionDict != (id)[NSNull null] && [resultsCollectionDict objectForKey:kPhlebDone] != (id)[NSNull null])
        doingPhlebRow.value = [self getYesNofromOneZero:resultsCollectionDict[kPhlebDone]];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mode of Communication"];
    section.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", doingPhlebRow];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *modeOfContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kModeOfContact rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Preferred mode of contact for results collection"];
    modeOfContactRow.required = YES;
    [self setDefaultFontWithRow:modeOfContactRow];
    modeOfContactRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    modeOfContactRow.selectorOptions = @[@"Call", @"SMS"];
    modeOfContactRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", doingPhlebRow];
    
    if (resultsCollectionDict != (id)[NSNull null] && [resultsCollectionDict objectForKey:kModeOfContact] != (id)[NSNull null])
        modeOfContactRow.value = resultsCollectionDict[kModeOfContact];
    
    [section addFormRow:modeOfContactRow];
    
    XLFormRowDescriptor *preferredDayRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPreferredDay rowType:XLFormRowDescriptorTypeSelectorPush title:@"Preferred day for call"];
    preferredDayRow.required = YES;
    [self setDefaultFontWithRow:preferredDayRow];
    preferredDayRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    preferredDayRow.selectorOptions = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    preferredDayRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Call'", modeOfContactRow];
    
    if (resultsCollectionDict != (id)[NSNull null] && [resultsCollectionDict objectForKey:kPreferredDay] != (id)[NSNull null])
        preferredDayRow.value = resultsCollectionDict[kPreferredDay];
    
    [section addFormRow:preferredDayRow];
    
    XLFormRowDescriptor *preferredTimeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPreferredTime rowType:XLFormRowDescriptorTypeText title:@"Preferred time for call (24h format)"];
    preferredTimeRow.required = YES;
    [self setDefaultFontWithRow:preferredTimeRow];
    preferredTimeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [preferredTimeRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    preferredTimeRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Call'", modeOfContactRow];
    
    if (resultsCollectionDict != (id)[NSNull null] && [resultsCollectionDict objectForKey:kPreferredTime] != (id)[NSNull null])
        preferredTimeRow.value = resultsCollectionDict[kPreferredTime];
    
    [section addFormRow:preferredTimeRow];
    
    XLFormRowDescriptor *preferredLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPreferredLanguage rowType:XLFormRowDescriptorTypeSelectorPush title:@"Preferred language"];
    preferredLangRow.required = YES;
    [self setDefaultFontWithRow:preferredLangRow];
    preferredLangRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    preferredLangRow.selectorOptions = @[@"English", @"Chinese", @"Malay", @"Tamil", @"Hokkien", @"Teochew", @"Cantonese"];
    preferredLangRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", doingPhlebRow];
    
    if (resultsCollectionDict != (id)[NSNull null] && [resultsCollectionDict objectForKey:kPreferredLanguage] != (id)[NSNull null])
        preferredLangRow.value = resultsCollectionDict[kPreferredLanguage];
    
    [section addFormRow:preferredLangRow];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Results collection at Mobile Community Health Post"];
    section.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", doingPhlebRow];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *resultsCollectionQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Results collection at Kampong Glam Community Club (select one)"];
    resultsCollectionQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:resultsCollectionQRow];
    [section addFormRow:resultsCollectionQRow];
    
    XLFormRowDescriptor *resultsCollectionRow = [XLFormRowDescriptor formRowDescriptorWithTag:kResultsCollection rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    resultsCollectionRow.required = YES;
    resultsCollectionRow.noValueDisplayText = @"Tap here";
    resultsCollectionRow.selectorOptions = @[@"26/09/2019 Thursday 2.00pm to 4.00pm",
                                             @"27/09/2019 Friday 10.00am to 12.00pm",
                                             @"28/09/2019 Saturday 9.30am to 11.30am"];
    [self setDefaultFontWithRow:resultsCollectionRow];
    
    if (resultsCollectionDict != (id)[NSNull null] && [resultsCollectionDict objectForKey:kResultsCollection] != (id)[NSNull null])
        resultsCollectionRow.value = resultsCollectionDict[kResultsCollection];
    
    [section addFormRow:resultsCollectionRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Results collection and follow up (if required)"];
    section.footerTitle = @"If follow up is required, choose EITHER to \nA. collect results and follow up at one of our participating GP clinics (please select one) \nOR\nB. Collect results at Kampong Glam Community Club and follow up with your own doctor at polyclinic/GP clinic. \nParticipating GPs: \nA1: Textile Centre Clinic \nA2: United Medical Clinic \nNote: Cost of first health screening review consult will be waived off at our participating GP clinics. Additional tests and medications prescribed by GP are payable by the participant.";
    
    section.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", doingPhlebRow];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *followUpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhlebFollowUp rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Follow Up:"];
    followUpRow.required = YES;
    followUpRow.noValueDisplayText = @"Tap here";
    followUpRow.selectorOptions = @[@"A1 - Textile Centre Clinic",
                                    @"A2 - United Medical Clinic",
                                    @"B - Follow up with own doctor"];
    [self setDefaultFontWithRow:followUpRow];
    
    if (resultsCollectionDict != (id)[NSNull null] && [resultsCollectionDict objectForKey:kPhlebFollowUp] != (id)[NSNull null])
        followUpRow.value = resultsCollectionDict[kPhlebFollowUp];
    
    [section addFormRow:followUpRow];
    
    
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
                
            case ResultsCollection: fieldName = kCheckPhlebResults;
                break;
            case PhlebResults: fieldName = kCheckPhleb;
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
            case ResultsCollection: fieldName = kCheckPhlebResults;
                break;
            case PhlebResults: fieldName = kCheckPhleb;
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
    
    /* Results Collection */
    if ([rowDescriptor.tag isEqualToString:kPhlebDone]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_RESULTS andFieldName:kPhlebDone andNewContent:ansFromYesNo];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kModeOfContact]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_RESULTS andFieldName:kModeOfContact andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPreferredDay]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_RESULTS andFieldName:kPreferredDay andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPreferredLanguage]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_RESULTS andFieldName:kPreferredLanguage andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kResultsCollection]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_RESULTS andFieldName:kResultsCollection andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPhlebFollowUp]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_RESULTS andFieldName:kPhlebFollowUp andNewContent:newValue];
    }
    
    
}

//-(void)beginEditing:(XLFormRowDescriptor *)rowDescriptor {
//    if ([rowDescriptor.tag isEqualToString:kInterventions]) {
//        if (rowDescriptor.value == nil || [rowDescriptor.value isEqualToString:@""]) {
//
//        }
//    }
//}

-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {    //works great for textField and textView
    
    if (rowDescriptor.value == nil) {
        rowDescriptor.value = @"";  //empty string
    }
    
    if ([rowDescriptor.tag isEqualToString:kPreferredTime]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_RESULTS andFieldName:kPreferredTime andNewContent:rowDescriptor.value];
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


- (void) showValidationError {
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
            [UIView animateWithDuration:0.3 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }];
        [self showFormValidationError:[validationErrors firstObject]];
        
        return;
    }
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

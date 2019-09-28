//
//  ResidentParticularsVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/4/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "ResidentParticularsVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "KAStatusBar.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"
#import "ScreeningDictionary.h"
#import "ResidentProfile.h"
//XLForms stuffs
#import "XLForm.h"

#define GREEN_COLOR [UIColor colorWithRed:48.0/255.0 green:207.0/255.0 blue:1.0/255.0 alpha:1.0]
#define FADED_GREEN_COLOR [UIColor colorWithRed:141.0/255.0 green:255.0/255.0 blue:113.0/255.0 alpha:1.0]
#define FADED_ORANGE_COLOR [UIColor colorWithRed:255.0/255.0 green:175.0/255.0 blue:113.0/255.0 alpha:1.0]
#define FADED_RED_COLOR [UIColor colorWithRed:255.0/255.0 green:113.0/255.0 blue:113.0/255.0 alpha:1.0]

typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;

typedef enum rowTypes {
    Text,
    YesNo,
    TextView,
    Checkbox,
    SelectorPush,
    SelectorArray,
    SelectorActionSheet,
    SegmentedControl,
    Number,
    Switch,
    YesNoNA,
    Date
} rowTypes;



@interface ResidentParticularsVC () {
    NSString *neighbourhood;
    XLFormRowDescriptor* dobRow, *ageRow, *age40aboveRow, *screeningSignButtonRow, *researchSignButtonRow;
    XLFormSectionDescriptor *mammoSection;
    int successCounter, failCounter;
    NetworkStatus status;
    int fetchDataState;
    NSString *block, *street;
    UIColor *screeningSignColor, *screeningSignDisabledColor, *researchSignColor, *researchSignDisabledColor;
}

//@property (strong, nonatomic) NSMutableDictionary *resiPartiDict;
@property (strong, nonatomic) NSNumber *resident_id;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) NSMutableArray *signaturePresentArray;

@end

@implementation ResidentParticularsVC

- (void)viewDidLoad {
    
    XLFormViewController *form;

    NSLog(@"Resident selected %@", _residentParticularsDict);
    NSLog(@"%@", _phlebEligibDict);
    NSLog(@"%@", _modeOfScreeningDict);
    NSLog(@"%@", _consentDisclosureDict);
    NSLog(@"%@", _consentResearchDict);
    NSLog(@"%@", _mammogramInterestDict);
    
    neighbourhood = [[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    status = [reachability currentReachabilityStatus];
    [self processConnectionStatus];
    
    //must init first before [super viewDidLoad]
    self.signaturePresentArray = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0, nil];
    [self checkIfSignatureExist];
    
    form = [self initResidentParticularsForm];
    [self.form setAddAsteriskToRequiredRowsTitle: YES];
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    NSNumber *preregCompleted = _residentParticularsDict[kPreregCompleted];
    if ([preregCompleted isEqual:@1]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        [self.form setDisabled:YES];
    }
    else {
        [self.form setDisabled:NO];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitBtnPressed:)];
    }
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSignatureButtonColors];
    self.navigationController.navigationBar.topItem.title = @"Resident Particulars";
}

- (void) viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBar.topItem.title = @"Integrated Profile";
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id) initResidentParticularsForm {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Resident Particulars"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    // Name
    XLFormRowDescriptor *nameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeName title:@"Resident Name"];
    nameRow.value = _residentParticularsDict[kName];
    nameRow.required = YES;
    [self setDefaultFontWithRow:nameRow];
    [nameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:nameRow];
    
    
    XLFormRowDescriptor *genderRow = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    genderRow.selectorOptions = @[@"Male", @"Female"];
    [self setDefaultFontWithRow:genderRow];
    if ([_residentParticularsDict count] > 0) {
        if ([_residentParticularsDict[kGender] isEqualToString:@"M"])
            genderRow.value = @"Male";
        else
            genderRow.value = @"Female";
    }
    genderRow.required = YES;
    [section addFormRow:genderRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"Only Singaporeans/PRs (with a valid NRIC/FIN) are eligible for screening.";
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *nricRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeName title:@"NRIC"];
    nricRow.required = YES;
    nricRow.value = _residentParticularsDict[kNRIC];
    [nricRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:nricRow];
    [section addFormRow:nricRow];
    
    nricRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
            rowDescriptor.value = CAPSed;
        }
    };
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    dobRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBirthDate rowType:XLFormRowDescriptorTypeText title:@"DOB (YYYY-MM-DD)"];
    
    if ([_residentParticularsDict count] > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  //otherwise 1st Jan will not be able to be read.
        NSDate *date = [dateFormatter dateFromString:_residentParticularsDict[kBirthDate]];
        // change to new format
        dateFormatter.dateFormat = @"YYYY-MM-dd";
        dobRow.value = [dateFormatter stringFromDate:date];
        
    }
    dobRow.required = YES;
    [dobRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:dobRow];
    [section addFormRow:dobRow];
    
    ageRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAge rowType:XLFormRowDescriptorTypeNumber title:@"Age (auto-calculated)"];
    [ageRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    ageRow.value = @"N/A";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *yearOfBirth = [dobRow.value substringWithRange:NSMakeRange(0, 4)];        //to match YYYY-MM-dd
    NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
    NSLog(@"%li", (long)age);
    ageRow.value = [NSNumber numberWithLong:age];
    
    ageRow.disabled = @1;
    [self setDefaultFontWithRow:ageRow];
    [section addFormRow:ageRow];
    
    XLFormRowDescriptor *citizenshipRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCitizenship rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Citizenship Status"];
    citizenshipRow.required = YES;
    citizenshipRow.value = _residentParticularsDict[kCitizenship];
    [self setDefaultFontWithRow:citizenshipRow];
    citizenshipRow.selectorOptions = @[@"Singaporean", @"PR", @"Foreigner"];
    [section addFormRow:citizenshipRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHpNumber rowType:XLFormRowDescriptorTypePhone title:@"HP Number"];
    row.required = YES;
    row.value = [_residentParticularsDict objectForKey:kHpNumber];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Please check that you have input the correct number" regex:@"^(?=.*\\d).{8}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseNumber rowType:XLFormRowDescriptorTypePhone title:@"House Phone Number"];
    row.required = YES;
    row.value = [_residentParticularsDict objectForKey:kHouseNumber];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number(2) must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNokName rowType:XLFormRowDescriptorTypeName title:@"Name of Next-of-Kin"]; //need to add the part of inserting Nil if no one.
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    
    if ([_residentParticularsDict objectForKey:kNokName] != (id)[NSNull null] && [_residentParticularsDict objectForKey:kNokName]) {
        row.value = [_residentParticularsDict objectForKey:kNokName];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNokRelationship rowType:XLFormRowDescriptorTypeSelectorPush title:@"Relationship to resident"]; //i.e. (resident's ______)
    row.required = YES;
    row.selectorOptions = @[@"Son", @"Daughter", @"Nephew", @"Niece", @"Husband", @"Wife", @"Father", @"Mother", @"Uncle", @"Aunt", @"Other", @"Nil"];
    [self setDefaultFontWithRow:row];
    row.value = [_residentParticularsDict objectForKey:kNokRelationship];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNokContact rowType:XLFormRowDescriptorTypePhone title:@"Contact Number of Next-of-Kin"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^[0,6,8,9]\\d{7}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    
    if ([_residentParticularsDict objectForKey:kNokContact] != (id)[NSNull null] && [_residentParticularsDict objectForKey:kNokContact]) {
        row.value = [_residentParticularsDict objectForKey:kNokContact];
    }
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEthnicity rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Ethnicity"];
    row.selectorOptions = @[@"Chinese",@"Indian",@"Malay",@"Others"];
    row.value = [_residentParticularsDict objectForKey:kEthnicity];
    row.required = YES;
    row.noValueDisplayText = @"Tap here for options";
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
        }
    };
    
    XLFormRowDescriptor * spokenLangRow;
    //    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Languages"];
    //2019
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeSelectorPush title:@"Preferred Spoken Language"];
    spokenLangRow.selectorOptions = @[@"English", @"Mandarin", @"Malay", @"Tamil", @"Hindi", @"Cantonese", @"Hokkien", @"Teochew"];
    [self setDefaultFontWithRow:spokenLangRow];
    spokenLangRow.required = YES;
    spokenLangRow.value = [_residentParticularsDict objectForKey:kSpokenLang];
    [section addFormRow:spokenLangRow];
    
    XLFormRowDescriptor *backupSpokenLangRow;
    backupSpokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBackupSpokenLang rowType:XLFormRowDescriptorTypeSelectorPush title:@"Backup Spoken Language"];
    backupSpokenLangRow.selectorOptions = @[@"English", @"Mandarin", @"Malay", @"Tamil", @"Hindi", @"Cantonese", @"Hokkien", @"Teochew", @"None"];
    [self setDefaultFontWithRow:backupSpokenLangRow];
    backupSpokenLangRow.value = [_residentParticularsDict objectForKey:kBackupSpokenLang];
    backupSpokenLangRow.required = YES;
    [section addFormRow:backupSpokenLangRow];
    
    XLFormRowDescriptor *writtenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWrittenLang rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Written Language"];
    writtenLangRow.required = YES;
    writtenLangRow.selectorOptions = @[@"English", @"Chinese", @"Malay", @"Tamil", @"Nil"];
    [self setDefaultFontWithRow:writtenLangRow];
    
    if ([_residentParticularsDict objectForKey:kWrittenLang] != (id)[NSNull null] && [_residentParticularsDict objectForKey:kWrittenLang]) {
        writtenLangRow.value = [_residentParticularsDict objectForKey:kWrittenLang];
    }

    [section addFormRow:writtenLangRow];
    
    writtenLangRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Tamil"]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Tamil health screening reports not available." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // do nothing
                }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    };
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *addressRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"address_block_street" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Address"];
    addressRow.required = YES;
    if ([neighbourhood isEqualToString:@"Kampong Glam"])
    addressRow.selectorOptions = @[@"Blk 4 Beach Road",
                                   @"Blk 5 Beach Road",
                                   @"Blk 6 Beach Road",
                                   @"Blk 7 North Bridge Road",
                                   @"Blk 8 North Bridge Road",
                                   @"Blk 9 North Bridge Road",
                                   @"Blk 10 North Bridge Road",
                                   @"Blk 18 Jalan Sultan",
                                   @"Blk 19 Jalan Sultan",
                                   @"Others"];
    else
    addressRow.selectorOptions = @[
                                   @"Blk 3 Jln Bukit Merah",
                                   @"55 Lengkok Bahru",
                                   @"56 Lengkok Bahru",
                                   @"57 Lengkok Bahru",
                                   @"58 Lengkok Bahru",
                                   @"59 Lengkok Bahru",
                                   @"61 Lengkok Bahru",
                                   @"Others"];
    [self setDefaultFontWithRow:addressRow];
    addressRow.value = [self getAddressFromStreetAndBlock];
    [section addFormRow:addressRow];
    
    XLFormRowDescriptor *addressOthersBlock = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressOthersBlock rowType:XLFormRowDescriptorTypeText title:@"Address (Others)-Block"];
    addressOthersBlock.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", addressRow];
    [addressOthersBlock.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:addressOthersBlock];
    if ([_residentParticularsDict objectForKey:kAddressOthersBlock] != (id)[NSNull null] && [_residentParticularsDict objectForKey:kAddressOthersBlock]) {
        addressOthersBlock.value = _residentParticularsDict[kAddressOthersBlock];
    }
    [section addFormRow:addressOthersBlock];
    
    XLFormRowDescriptor *addressOthersRoadName = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressOthersRoadName rowType:XLFormRowDescriptorTypeText title:@"Address (Others)-Road Name"];
    addressOthersRoadName.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", addressRow];
    [addressOthersRoadName.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:addressOthersRoadName];
    if ([_residentParticularsDict objectForKey:kAddressOthersRoadName] != (id)[NSNull null] && [_residentParticularsDict objectForKey:kAddressOthersRoadName]) {
        addressOthersRoadName.value = _residentParticularsDict[kAddressOthersRoadName];
    }
    [section addFormRow:addressOthersRoadName];
    
    addressRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            street = [self getStreetFromAddress:newValue];
            block  = [self getBlockFromStreetName:street];
            
            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kAddressStreet andNewContent:street];
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kAddressBlock andNewContent:block];
            });
            
            if ([newValue containsString:@"Others"]) {
                addressOthersBlock.required = YES;
                addressOthersRoadName.required = YES;
            } else {
                addressOthersBlock.required = NO;
                addressOthersRoadName.required = NO;
            }
            [self reloadFormRow:addressOthersBlock];
            [self reloadFormRow:addressOthersRoadName];
        }
    };
    

    XLFormRowDescriptor *unitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressUnitNum rowType:XLFormRowDescriptorTypeText title:@"Unit No"];
    [self setDefaultFontWithRow:unitRow];
    [unitRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    unitRow.required = YES;
    if ([_residentParticularsDict objectForKey:kAddressUnitNum] != (id)[NSNull null] && [_residentParticularsDict objectForKey:kAddressUnitNum]) {
        unitRow.value = _residentParticularsDict[kAddressUnitNum];
    }
    [section addFormRow:unitRow];
    
    unitRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            
            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
            rowDescriptor.value = CAPSed;
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressPostCode rowType:XLFormRowDescriptorTypePhone title:@"Postal Code"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Postal Code must be 6 digits" regex:@"^(?=.*\\d).{6}$"]];
    if ([_residentParticularsDict objectForKey:kAddressPostCode] != (id)[NSNull null] && [_residentParticularsDict objectForKey:kAddressPostCode]) {
        row.value = _residentParticularsDict[kAddressPostCode];
    }

    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Consent"];   /// NEW SECTION
    section.footerTitle = @"Select no during prepubs. Ask ONLY during screening.";
    [formDescriptor addFormSection:section];
    
    //    XLFormRowDescriptor *showScreenConsentFormBtnRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"show_screening_consent" rowType:XLFormRowDescriptorTypeButton title:@"Show Screening Consent Form"];
    //    showScreenConsentFormBtnRow.required = NO;
    //    showScreenConsentFormBtnRow.action.formSelector = @selector(goToShowConsentForm:);
    //    showScreenConsentFormBtnRow.cellConfigAtConfigure[@"backgroundColor"] = [UIColor colorWithRed:35/255.0 green:22/255.0 blue:120/255.0 alpha:1.0];
    //    showScreenConsentFormBtnRow.cellConfig[@"textLabel.textColor"] = [UIColor whiteColor];
    //    [section addFormRow:showScreenConsentFormBtnRow];
    
    XLFormRowDescriptor *consentInfoRow = [XLFormRowDescriptor formRowDescriptorWithTag:kConsent rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Consent to disclosure of information"];
    consentInfoRow.selectorOptions = @[@"Yes", @"No"];
    consentInfoRow.required = YES;
    [self setDefaultFontWithRow:consentInfoRow];
    if ([_residentParticularsDict objectForKey:kConsent] != (id)[NSNull null])
        consentInfoRow.value = [self getYesNoFromOneZero:[_residentParticularsDict objectForKey:kConsent]];
    [section addFormRow:consentInfoRow];
    
    XLFormRowDescriptor *langExplainedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLangExplainedIn rowType:XLFormRowDescriptorTypeSelectorPush title:@"Language explained in"];
    langExplainedRow.selectorOptions = @[@"English", @"Malay", @"Chinese", @"Tamil", @"Others"];
    [self setDefaultFontWithRow:langExplainedRow];
    langExplainedRow.required = YES;
    langExplainedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    if ([_consentDisclosureDict objectForKey:kLangExplainedIn] != (id)[NSNull null] && [_consentDisclosureDict objectForKey:kLangExplainedIn]) {
        langExplainedRow.value = _consentDisclosureDict[kLangExplainedIn];
    }
    [section addFormRow:langExplainedRow];
    
    XLFormRowDescriptor *langExplainedOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLangExplainedInOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    langExplainedOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", langExplainedRow];
    [langExplainedOthersRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:langExplainedOthersRow];
    langExplainedOthersRow.required = YES;
    if ([_consentDisclosureDict objectForKey:kLangExplainedInOthers] != (id)[NSNull null] && [_consentDisclosureDict objectForKey:kLangExplainedInOthers]) {
        langExplainedOthersRow.value = _consentDisclosureDict[kLangExplainedInOthers];
    }
    [section addFormRow:langExplainedOthersRow];
    
    XLFormRowDescriptor *consentTakerNameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentTakerFullName rowType:XLFormRowDescriptorTypeName title:@"Consent Taker Full Name"];
    consentTakerNameRow.required = YES;
    [consentTakerNameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:consentTakerNameRow];
    consentTakerNameRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    if ([_consentDisclosureDict objectForKey:kConsentTakerFullName] != (id)[NSNull null] && [_consentDisclosureDict objectForKey:kConsentTakerFullName]) {
        consentTakerNameRow.value = _consentDisclosureDict[kConsentTakerFullName];
    }
    [section addFormRow:consentTakerNameRow];
    
    XLFormRowDescriptor *matricNoRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMatriculationNumber rowType:XLFormRowDescriptorTypeName title:@"Matriculation Number"];
    matricNoRow.required = YES;
    [matricNoRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:matricNoRow];
    matricNoRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    if ([_consentDisclosureDict objectForKey:kMatriculationNumber] != (id)[NSNull null] && [_consentDisclosureDict objectForKey:kMatriculationNumber]) {
        matricNoRow.value = _consentDisclosureDict[kMatriculationNumber];
    }
    [section addFormRow:matricNoRow];
    
    XLFormRowDescriptor *orgRow = [XLFormRowDescriptor formRowDescriptorWithTag:kOrganisation rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Organisation"];
    orgRow.selectorOptions = @[@"NUS Medicine", @"NUS Nursing", @"NTU Medicine", @"NUS Social Work", @"Others"];
    [self setDefaultFontWithRow:orgRow];
    orgRow.required = YES;
    orgRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    if ([_consentDisclosureDict objectForKey:kOrganisation] != (id)[NSNull null] && [_consentDisclosureDict objectForKey:kOrganisation]) {
        orgRow.value = _consentDisclosureDict[kOrganisation];
    }
    [section addFormRow:orgRow];
    
    XLFormRowDescriptor *orgOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kOrganisationOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    orgOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", orgRow];
    [orgOthersRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:orgOthersRow];
    orgOthersRow.required = YES;
    if ([_consentDisclosureDict objectForKey:kOrganisationOthers] != (id)[NSNull null] && [_consentDisclosureDict objectForKey:kOrganisationOthers]) {
        orgOthersRow.value = _consentDisclosureDict[kOrganisationOthers];
    }

    [section addFormRow:orgOthersRow];
    
    screeningSignButtonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"sign_screening_btn" rowType:XLFormRowDescriptorTypeButton title:@"Sign Screening Consent"];
    screeningSignButtonRow.required = NO;
    screeningSignButtonRow.action.formSelector = @selector(goToViewSignatureVC:);
    screeningSignButtonRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    screeningSignButtonRow.cellConfigAtConfigure[@"backgroundColor"] = screeningSignColor;
    screeningSignButtonRow.cellConfig[@"textLabel.textColor"] = [UIColor whiteColor];
    [section addFormRow:screeningSignButtonRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Consent to Research"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Select no during prepubs. Ask ONLY during screening.";
    
    //    XLFormRowDescriptor *showResearchConsentFormBtnRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"show_research_consent" rowType:XLFormRowDescriptorTypeButton title:@"Show Research Consent Form"];
    //    showResearchConsentFormBtnRow.required = NO;
    //    showResearchConsentFormBtnRow.action.formSelector = @selector(goToShowConsentForm:);
    //    showResearchConsentFormBtnRow.cellConfigAtConfigure[@"backgroundColor"] = [UIColor colorWithRed:35/255.0 green:22/255.0 blue:120/255.0 alpha:1.0];
    //    showResearchConsentFormBtnRow.cellConfig[@"textLabel.textColor"] = [UIColor whiteColor];
    //    [section addFormRow:showResearchConsentFormBtnRow];
    
    XLFormRowDescriptor *consentResearchRow = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentToResearch rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Consent to research"];
    consentResearchRow.selectorOptions = @[@"Yes", @"No"];
    consentResearchRow.required = YES;
    [self setDefaultFontWithRow:consentResearchRow];
    if ([_residentParticularsDict objectForKey:kConsentToResearch] != (id)[NSNull null])
        consentResearchRow.value = [self getYesNoFromOneZero:[_consentResearchDict objectForKey:kConsentToResearch]];
    [section addFormRow:consentResearchRow];
    
    XLFormRowDescriptor *consentRecontactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentRecontact rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Consent to be recontacted for further studies"];
    consentRecontactRow.selectorOptions = @[@"Yes", @"No"];
    consentRecontactRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    consentRecontactRow.required = YES;
    [self setDefaultFontWithRow:consentRecontactRow];
    consentRecontactRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentResearchRow];
    if ([_consentResearchDict objectForKey:kConsentRecontact] != (id)[NSNull null] && [_consentResearchDict objectForKey:kConsentRecontact]) {
        consentRecontactRow.value = [self getYesNoFromOneZero:_consentResearchDict[kConsentRecontact]];
    }
    [section addFormRow:consentRecontactRow];
    
    XLFormRowDescriptor *translationDoneRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTranslationDone rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Translation Done?"];
    translationDoneRow.selectorOptions = @[@"Yes", @"No"];
    translationDoneRow.required = YES;
    translationDoneRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentResearchRow];
    [self setDefaultFontWithRow:translationDoneRow];
    if ([_consentResearchDict objectForKey:kTranslationDone] != (id)[NSNull null] && [_consentResearchDict objectForKey:kTranslationDone]) {
        translationDoneRow.value = [self getYesNoFromOneZero:_consentResearchDict[kTranslationDone]];
    }
    [section addFormRow:translationDoneRow];
    
    XLFormRowDescriptor *witnessTransFullName = [XLFormRowDescriptor formRowDescriptorWithTag:kWitnessTranslatorFullName rowType:XLFormRowDescriptorTypeName title:@"Witness and/or Translator Full Name"];
    witnessTransFullName.required = YES;
    [witnessTransFullName.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:witnessTransFullName];
    witnessTransFullName.cellConfig[@"textLabel.numberOfLines"] = @0;
    witnessTransFullName.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentResearchRow];
    if ([_consentResearchDict objectForKey:kWitnessTranslatorFullName] != (id)[NSNull null] && [_consentResearchDict objectForKey:kWitnessTranslatorFullName]) {
        witnessTransFullName.value = _consentResearchDict[kWitnessTranslatorFullName];
    }
    [section addFormRow:witnessTransFullName];
    
    researchSignButtonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"sign_research_btn" rowType:XLFormRowDescriptorTypeButton title:@"Sign Research Consent"];
    researchSignButtonRow.required = NO;
    researchSignButtonRow.action.formSelector = @selector(goToResearchSignatureVC:);
    researchSignButtonRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentResearchRow];
    researchSignButtonRow.cellConfigAtConfigure[@"backgroundColor"] = researchSignColor;
    researchSignButtonRow.cellConfig[@"textLabel.textColor"] = [UIColor whiteColor];
    [section addFormRow:researchSignButtonRow];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"INDICATORS"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *sporeanRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr
                                                                            rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                              title:@"Singaporean?"];
    [self setDefaultFontWithRow:sporeanRow];
    [sporeanRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    sporeanRow.selectorOptions = @[@"Yes",@"No"];
    sporeanRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    sporeanRow.disabled = @1;
    [section addFormRow:sporeanRow];
    
    XLFormRowDescriptor *prRow = [XLFormRowDescriptor formRowDescriptorWithTag:kIsPr
                                                                       rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                         title:@"PR?"];
    [self setDefaultFontWithRow:prRow];
    [prRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    prRow.selectorOptions = @[@"Yes",@"No"];
    prRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    prRow.disabled = @1;
    [section addFormRow:prRow];
    
    // initial state
    if (citizenshipRow.value != (id)[NSNull null] && citizenshipRow.value) {
        if ([citizenshipRow.value containsString:@"Singaporean"]) {
            sporeanRow.value = @"Yes";
            [self reloadFormRow:sporeanRow];
            prRow.value = @"No";
            [self reloadFormRow:prRow];
        }
        else if ([citizenshipRow.value containsString:@"PR"]) {
            prRow.value = @"Yes";
            [self reloadFormRow:prRow];
            sporeanRow.value = @"No";
            [self reloadFormRow:sporeanRow];
        } else {
            prRow.value = @"No";
            [self reloadFormRow:prRow];
            sporeanRow.value = @"No";
            [self reloadFormRow:sporeanRow];
        }
    }
    
    citizenshipRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([rowDescriptor.value containsString:@"Singaporean"]) {
                sporeanRow.value = @"Yes";
                [self reloadFormRow:sporeanRow];
                prRow.value = @"No";
                [self reloadFormRow:prRow];
            } else if ([rowDescriptor.value containsString:@"PR"]) {
                prRow.value = @"Yes";
                [self reloadFormRow:prRow];
                sporeanRow.value = @"No";
                [self reloadFormRow:sporeanRow];
            } else {
                prRow.value = @"No";
                [self reloadFormRow:prRow];
                sporeanRow.value = @"No";
                [self reloadFormRow:sporeanRow];
            }
        }
    };
    
    age40aboveRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeCheck
                                                          rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                            title:@"Age 40 and above?"];
    [self setDefaultFontWithRow:age40aboveRow];
    [age40aboveRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    age40aboveRow.disabled = @YES;
    age40aboveRow.selectorOptions = @[@"Yes",@"No"];
    
    //    __weak __typeof(self)weakSelf = self;
    //    dobRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
    //        if (newValue != oldValue) {
    //            // Calculate age
    //            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //            [dateFormatter setDateFormat:@"yyyy"];
    //            NSString *yearOfBirth = [dateFormatter stringFromDate:newValue];
    //            NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
    //            NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
    //            NSLog(@"%li", (long)age);
    //            rowDescriptor.value = [NSNumber numberWithLong:age];
    //            [weakSelf reloadFormRow:rowDescriptor];
    //
    //            if (age >= 40) {
    //                age40aboveRow.value = @"Yes";
    //                age40aboveRow.disabled = @YES;
    //                [weakSelf updateFormRow:age40aboveRow];
    //            } else {
    //                age40aboveRow.value = @"No";
    //                age40aboveRow.disabled = @YES;
    //                [weakSelf updateFormRow:age40aboveRow];
    //            }
    //        }
    //    };
    if (age >= 40) {
        age40aboveRow.value = @"Yes";
    } else {
        age40aboveRow.value = @"No";
    }
    
    age40aboveRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:age40aboveRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Phlebotomy Eligibility Assessment"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *wantFreeBtRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantFreeBt rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident want a free blood test?"];
    [self setDefaultFontWithRow:wantFreeBtRow];
    wantFreeBtRow.value = [self getYesNoFromOneZero:[_phlebEligibDict objectForKey:kWantFreeBt]];
    wantFreeBtRow.selectorOptions = @[@"Yes", @"No"];
    wantFreeBtRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:wantFreeBtRow];
    
    XLFormRowDescriptor *chronicCondRow;
    
    chronicCondRow = [XLFormRowDescriptor formRowDescriptorWithTag:kChronicCond rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does the resident have a previously diagnosed chronic condition?"];
    chronicCondRow.required = YES;
    chronicCondRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:chronicCondRow];
    chronicCondRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    chronicCondRow.value = [self getYesNoFromOneZero:[_phlebEligibDict objectForKey:kChronicCond]];
    [section addFormRow:chronicCondRow];
    
    XLFormRowDescriptor *noFollowUpPcpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRegFollowup rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is resident under regular follow-up with primary care physician?"];
    noFollowUpPcpRow.required = YES;
    noFollowUpPcpRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:noFollowUpPcpRow];
    noFollowUpPcpRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noFollowUpPcpRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", chronicCondRow];
    noFollowUpPcpRow.value = [self getYesNoFromOneZero:[_phlebEligibDict objectForKey:kRegFollowup]];
    [section addFormRow:noFollowUpPcpRow];
    
    XLFormRowDescriptor *noBloodTestRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNoBloodTest
                                                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                  title:@"Has the resident taken a blood test in the past 3 years?"];
    [self setDefaultFontWithRow:noBloodTestRow];
    noBloodTestRow.selectorOptions = @[@"Yes",@"No"];
    noBloodTestRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noBloodTestRow.value = [self getYesNoFromOneZero:[_phlebEligibDict objectForKey:kNoBloodTest]];
    [section addFormRow:noBloodTestRow];
    
    XLFormRowDescriptor *eligibleBTRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEligibleBloodTest
                                                                               rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                 title:@"Is resident eligible for a blood test? (auto-calculated)"];
    [self setDefaultFontWithRow:eligibleBTRow];
    [eligibleBTRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    eligibleBTRow.disabled = @YES;
    eligibleBTRow.selectorOptions = @[@"Yes",@"No"];
    eligibleBTRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    if ([[ResidentProfile sharedManager] isEligiblePhleb])
    eligibleBTRow.value = @"Yes";
    else
    eligibleBTRow.value = @"No";
    
    [section addFormRow:eligibleBTRow];
    
    wantFreeBtRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                NSDictionary *dict =  [self.form formValues];
                if (([dict objectForKey:kChronicCond] == (id)[NSNull null] || [dict objectForKey:kRegFollowup] == (id)[NSNull null])|| [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                if (([[dict objectForKey:kChronicCond] isEqualToString:@"No"] ||
                     ([[dict objectForKey:kChronicCond] isEqualToString:@"Yes"] && [[dict objectForKey:kRegFollowup] isEqualToString:@"No"]))
                    && ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"] ||
                        [[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) &&
                    [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] &&
                    [[dict objectForKey:kNoBloodTest] isEqualToString:@"No"]) {
                    eligibleBTRow.value = @"Yes";
                } else {
                    eligibleBTRow.value = @"No";
                }
                [self reloadFormRow:eligibleBTRow];
            } else {
                eligibleBTRow.value = @"No";
                [self reloadFormRow:eligibleBTRow];
            }
            
        }
    };
    
    
    chronicCondRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"No"]) {
                NSDictionary *dict =  [self.form formValues];
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                if ([[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"] &&
                    ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"] || [[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) &&
                    [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] &&
                    [[dict objectForKey:kNoBloodTest] isEqualToString:@"No"]) {
                    eligibleBTRow.value = @"Yes";
                } else {
                    eligibleBTRow.value = @"No";
                }
                [self reloadFormRow:eligibleBTRow];
            } else {
                NSDictionary *dict =  [self.form formValues];
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null] || [dict objectForKey:kRegFollowup] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                
                if ([[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"] &&
                    [[dict objectForKey:kRegFollowup] isEqualToString:@"No"] &&
                    ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"] || [[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) &&
                    [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] &&
                    [[dict objectForKey:kNoBloodTest] isEqualToString:@"No"]) {
                    
                    eligibleBTRow.value = @"Yes";
                    
                } else {
                    eligibleBTRow.value = @"No";
                }
                [self reloadFormRow:eligibleBTRow];
            }
            
        }
    };
    
    noFollowUpPcpRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"No"]) {
                NSDictionary *dict =  [self.form formValues];
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                if ([[dict objectForKey:kChronicCond] isEqualToString:@"Yes"] &&
                    [[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"] &&
                    ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"]||[[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) &&
                    [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] &&
                    [[dict objectForKey:kNoBloodTest] isEqualToString:@"No"]) {
                    eligibleBTRow.value = @"Yes";
                } else {
                    eligibleBTRow.value = @"No";
                }
                [self reloadFormRow:eligibleBTRow];
            } else {
                eligibleBTRow.value = @"No";
                [self reloadFormRow:eligibleBTRow];
            }
            
        }
    };
    
    noBloodTestRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"No"]) {
                NSDictionary *dict =  [self.form formValues];
                
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kChronicCond] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                
                if (([[dict objectForKey:kChronicCond] isEqualToString:@"No"] ||
                     ([[dict objectForKey:kChronicCond] isEqualToString:@"Yes"] && [[dict objectForKey:kRegFollowup] isEqualToString:@"No"]))
                    && ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"] || [[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) &&
                    [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] &&
                    [[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"]) {
                    eligibleBTRow.value = @"Yes";
                } else {
                    eligibleBTRow.value = @"No";
                }
                [self reloadFormRow:eligibleBTRow];
            } else {    //if has already taken blood test in past 3 years
                eligibleBTRow.value = @"No";
                [self reloadFormRow:eligibleBTRow];
            }
        }
    };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isComm = [defaults objectForKey:@"isComm"];
    
    XLFormRowDescriptor *didPhlebQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"qPhleb" rowType:XLFormRowDescriptorTypeInfo title:@"Has the resident undergone phlebotomy?"];
    if (![isComm boolValue]) didPhlebQRow.hidden = @YES;  //if it's not Comms, then hide this.
    [self setDefaultFontWithRow:didPhlebQRow];
    [section addFormRow:didPhlebQRow];
    
    XLFormRowDescriptor *didPhlebRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDidPhleb rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:didPhlebRow];
    if (![isComm boolValue]) didPhlebRow.hidden = @YES;  //if it's not Comms, then hide this.
    didPhlebRow.selectorOptions = @[@"No, not at all", @"Yes, Saturday", @"Yes, Sunday", @"No, referred to next Saturday", @"Yes, additional session"];
    didPhlebRow.value = [_phlebEligibDict objectForKey:kDidPhleb];
    didPhlebRow.value = @"No, not at all";
    didPhlebRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:didPhlebRow];
    
    if (![neighbourhood containsString:@"Kampong"]) {
        
        
        mammoSection = [XLFormSectionDescriptor formSectionWithTitle:@"Mammogram"];
        [formDescriptor addFormSection:mammoSection];
        
        XLFormRowDescriptor *mammogramInterestRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMammogramInterest
                                                                     rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                       title:@"Are you interested in taking a mammogram on Saturday 10am-1pm?"];
        [self setDefaultFontWithRow:mammogramInterestRow];
        mammogramInterestRow.required = YES;
        mammogramInterestRow.selectorOptions = @[@"Yes",@"No"];
        mammogramInterestRow.cellConfig[@"textLabel.numberOfLines"] = @0;
        mammogramInterestRow.value = [self getYesNoFromOneZero:[_mammogramInterestDict objectForKey:kMammogramInterest]];
        [mammoSection addFormRow:mammogramInterestRow];
        
        XLFormRowDescriptor *hasChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHasChas
                                                           rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                             title:@"Does the resident have a Blue/Orange CHAS card?"];
        [self setDefaultFontWithRow:hasChasRow];
        hasChasRow.required = YES;
        hasChasRow.selectorOptions = @[@"Yes",@"No"];
        hasChasRow.cellConfig[@"textLabel.numberOfLines"] = @0;
        hasChasRow.value = [self getYesNoFromOneZero:[_mammogramInterestDict objectForKey:kHasChas]];
        hasChasRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", mammogramInterestRow];
        [mammoSection addFormRow:hasChasRow];
        
        XLFormRowDescriptor *doneB4Row = [XLFormRowDescriptor formRowDescriptorWithTag:kDoneBefore
                                                          rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                            title:@"Has the resident done a mammogram before?"];
        [self setDefaultFontWithRow:doneB4Row];
        doneB4Row.required = YES;
        doneB4Row.selectorOptions = @[@"Yes",@"No"];
        doneB4Row.cellConfig[@"textLabel.numberOfLines"] = @0;
        doneB4Row.value = [self getYesNoFromOneZero:[_mammogramInterestDict objectForKey:kDoneBefore]];
        doneB4Row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", mammogramInterestRow];
        [mammoSection addFormRow:doneB4Row];
        
        XLFormRowDescriptor *willingPayRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWillingPay
                                                              rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                title:@"Is resident willing to pay $10 for mammogram? (To explain that resident has to pay subsidised fee of $10 if this is a repeat mammogram.)"];
        [self setDefaultFontWithRow:willingPayRow];
        willingPayRow.required = YES;
        willingPayRow.selectorOptions = @[@"Yes",@"No"];
        willingPayRow.cellConfig[@"textLabel.numberOfLines"] = @0;
        willingPayRow.value = [self getYesNoFromOneZero:[_mammogramInterestDict objectForKey:kWillingPay]];
        if ([willingPayRow.value isEqualToString:@""]) { //no value
            willingPayRow.hidden = @YES;
        }
        [mammoSection addFormRow:willingPayRow];
        
        if ([genderRow.value containsString:@"F"] && [age40aboveRow.value isEqualToString:@"Yes"]) {
            mammoSection.hidden = @NO;
        } else {
            mammoSection.hidden = @YES;
        }
        
        mammogramInterestRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
            if (newValue != oldValue) {
                if ([newValue isEqualToString:@"Yes"]) {
                    hasChasRow.hidden = @NO;
                    doneB4Row.hidden = @NO;
                } else {
                    hasChasRow.hidden = @YES;
                    doneB4Row.hidden = @YES;
                }
                
                [self reloadFormRow:hasChasRow];
                [self reloadFormRow:doneB4Row];
            }
        };
        
        
        hasChasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
            if (newValue != oldValue) {
                if ([newValue isEqualToString:@"No"]) {
                    if (doneB4Row.value != (id)[NSNull null] && [doneB4Row.value isEqualToString:@"Yes"]) {
                        willingPayRow.hidden = @NO;
                    } else {
                        willingPayRow.hidden = @YES;
                    }
                } else {
                    willingPayRow.hidden = @YES;
                }
                
                [self reloadFormRow:willingPayRow];
            }
        };
        
        doneB4Row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
            if (newValue != oldValue) {
                if ([newValue isEqualToString:@"Yes"]) {
                    if (hasChasRow.value != (id)[NSNull null] && [hasChasRow.value isEqualToString:@"No"]) {
                        willingPayRow.hidden = @NO;
                    } else {
                        willingPayRow.hidden = @YES;
                    }
                } else {
                    willingPayRow.hidden = @YES;
                }
                
                [self reloadFormRow:willingPayRow];
            }
        };
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mode of Screening"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *screenModeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kScreenMode rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Pick one"];
    screenModeRow.selectorOptions = @[@"Centralised", @"Door-to-door"];
    screenModeRow.required = YES;
    [self setDefaultFontWithRow:screenModeRow];
    if (_modeOfScreeningDict != (id)[NSNull null] && [_modeOfScreeningDict objectForKey:kScreenMode] != (id)[NSNull null]) {
        screenModeRow.value = [_modeOfScreeningDict objectForKey:kScreenMode];
    }
    [section addFormRow:screenModeRow];
    
    XLFormRowDescriptor *centralDateQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"central_date_q" rowType:XLFormRowDescriptorTypeInfo title:@"Which date did the resident attend screening?"];
    centralDateQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    centralDateQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Centralised'", screenModeRow];
    [self setDefaultFontWithRow:centralDateQRow];
    [section addFormRow:centralDateQRow];
    
    XLFormRowDescriptor* centralDateRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCentralDate rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    centralDateRow.noValueDisplayText = @"Tap here";
    centralDateRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:centralDateRow];
    
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        centralDateRow.selectorOptions = @[@"7 Sept", @"8 Sept"];
    } else {
        centralDateRow.selectorOptions = @[@"5 Oct (Lengkok Bahru)", @"6 Oct (3 Jalan Bukit Merah)"];
    }
    centralDateRow.required = YES;
    centralDateRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Centralised'", screenModeRow];
    if (_modeOfScreeningDict != (id)[NSNull null] && [_modeOfScreeningDict objectForKey:kCentralDate] != (id)[NSNull null]) {
        centralDateRow.value = [_modeOfScreeningDict objectForKey:kCentralDate];
    }
    [section addFormRow:centralDateRow];
    
    XLFormRowDescriptor *apptDateQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"appt_date_q" rowType:XLFormRowDescriptorTypeInfo title:@"Non-Phleb door-to-door Date (only available from 1-3pm)"];
    apptDateQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    apptDateQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
    [self setDefaultFontWithRow:apptDateQRow];
    [section addFormRow:apptDateQRow];
    
    XLFormRowDescriptor *apptDateRow = [XLFormRowDescriptor formRowDescriptorWithTag:kApptDate rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        apptDateRow.selectorOptions = @[@"7 Sept", @"8 Sept"];
    } else {
        apptDateRow.selectorOptions = @[@"5 Oct (Lengkok Bahru)", @"6 Oct (3 Jalan Bukit Merah)"];
    }
    apptDateRow.noValueDisplayText = @"Tap here";
    apptDateRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
    if (!apptDateRow.isHidden) {    //which means that screen mode is D2D
        if (eligibleBTRow.value != nil && eligibleBTRow.value != (id)[NSNull null]) {
            if ([eligibleBTRow.value isEqualToString:@"Yes"]) {
                apptDateQRow.hidden = @YES;
                apptDateRow.hidden = @YES;
            }
        }
    }
    
    apptDateRow.required = YES;
    [self setDefaultFontWithRow:apptDateRow];
    if (_modeOfScreeningDict != (id)[NSNull null] && [_modeOfScreeningDict objectForKey:kApptDate] != (id)[NSNull null]) {
        apptDateRow.value = [_modeOfScreeningDict objectForKey:kApptDate];
    }
    [section addFormRow:apptDateRow];
    
    XLFormRowDescriptor *phlebApptQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"phleb_appt_q" rowType:XLFormRowDescriptorTypeInfo title:@"Phleb door-to-door Date (only available from 9-11am)"];
    phlebApptQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    phlebApptQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
    [self setDefaultFontWithRow:phlebApptQRow];
    [section addFormRow:phlebApptQRow];
    
    XLFormRowDescriptor *phlebApptRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhlebAppt rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        phlebApptRow.selectorOptions = @[@"7 Sept", @"8 Sept"];
    } else {
        phlebApptRow.selectorOptions = @[@"5 Oct (Lengkok Bahru)", @"6 Oct (3 Jalan Bukit Merah)"];
    }
    phlebApptRow.noValueDisplayText = @"Tap here";
    phlebApptRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
    
    if (!phlebApptRow.isHidden) {    //which means that screen mode is D2D
        if (eligibleBTRow.value != nil && eligibleBTRow.value != (id)[NSNull null]) {
            if ([eligibleBTRow.value isEqualToString:@"No"]) {
                phlebApptQRow.hidden = @YES;
                phlebApptRow.hidden = @YES;
            }
        }
    }
    
    phlebApptRow.required = YES;
    [self setDefaultFontWithRow:phlebApptRow];
    if (_modeOfScreeningDict != (id)[NSNull null] && [_modeOfScreeningDict objectForKey:kPhlebAppt] != (id)[NSNull null]) {
        phlebApptRow.value = [_modeOfScreeningDict objectForKey:kPhlebAppt];
    }
    [section addFormRow:phlebApptRow];
    
    eligibleBTRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"No"]) {
                if ([screenModeRow.value isEqualToString:@"Door-to-door"]) {
                    apptDateRow.hidden = @NO;
                    apptDateQRow.hidden = @NO;
                    phlebApptQRow.hidden = @YES;
                    phlebApptRow.hidden = @YES;
                    
                } else {
                    apptDateRow.hidden = @YES;
                    apptDateQRow.hidden = @YES;
                    phlebApptQRow.hidden = @YES;
                    phlebApptRow.hidden = @YES;
                }
            } else {
                if ([screenModeRow.value isEqualToString:@"Door-to-door"]) {
                    apptDateRow.hidden = @YES;
                    apptDateQRow.hidden = @YES;
                    phlebApptQRow.hidden = @NO;
                    phlebApptRow.hidden = @NO;
                    
                } else {
                    apptDateRow.hidden = @YES;
                    apptDateQRow.hidden = @YES;
                    phlebApptQRow.hidden = @YES;
                    phlebApptRow.hidden = @YES;
                }
            }
        }
    };
    
    screenModeRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Door-to-door"]) {
                if ([eligibleBTRow.value isEqualToString:@"No"] || eligibleBTRow.value == nil) {
                    apptDateRow.hidden = @NO;
                    apptDateQRow.hidden = @NO;
                    phlebApptQRow.hidden = @YES;
                    phlebApptRow.hidden = @YES;
                } else {
                    apptDateRow.hidden = @YES;
                    apptDateQRow.hidden = @YES;
                    phlebApptQRow.hidden = @NO;
                    phlebApptRow.hidden = @NO;
                }
            } else {
                apptDateRow.hidden = @YES;
                apptDateQRow.hidden = @YES;
                phlebApptQRow.hidden = @YES;
                phlebApptRow.hidden = @YES;
            }
        }
    };
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Notes"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *commentsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNotes rowType:XLFormRowDescriptorTypeTextView title:@""];
    [commentsRow.cellConfigAtConfigure setObject:@"Notes..." forKey:@"textView.placeholder"];
    commentsRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:commentsRow];
    if (_modeOfScreeningDict != (id)[NSNull null] && [_modeOfScreeningDict objectForKey:kNotes] != (id)[NSNull null]) {
        commentsRow.value = [_modeOfScreeningDict objectForKey:kNotes];
    }
    
    [section addFormRow:commentsRow];
    
    
    return [super initWithForm:formDescriptor];
}

#pragma mark - XLFormButton Segue
- (void) goToViewSignatureVC: (XLFormRowDescriptor *) sender {
    [self performSegueWithIdentifier:@"ResiPartiToViewSignatureSegue" sender:self];
}

- (void) goToResearchSignatureVC: (XLFormRowDescriptor *) sender {
    [self performSegueWithIdentifier:@"ResiPartiToResearchSignatureSegue" sender:self];
}

#pragma mark - XLFormViewControllerDelegate 
// Currently only works for textFields
-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {
    
//    if ([rowDescriptor.tag isEqualToString:kBirthDate] || [rowDescriptor.tag isEqualToString:kNRIC]) {    //even NRIC and BirthDate can be edited after registration
//        return;
//    }
    if ([rowDescriptor.tag isEqualToString:kName]) {
        NSString *CAPSed = [rowDescriptor.value uppercaseString];
        rowDescriptor.value = CAPSed;
        [self reloadFormRow:rowDescriptor];
        
    }
    
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0) {
        
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            
            if ([validationStatus.rowDescriptor isEqual:rowDescriptor]) {
                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
                cell.backgroundColor = [UIColor orangeColor];
                [UIView animateWithDuration:0.3 animations:^{
                    cell.backgroundColor = [UIColor whiteColor];
                }];
                [self showFormValidationError:[validationErrors objectAtIndex:idx]];    //only show error if it's this specific row
                return;
            }
        }];
    }
    
    if (rowDescriptor.value != (id)[NSNull null] && rowDescriptor.value != nil) {
        if (rowDescriptor.tag == kBirthDate) {
            
            if (rowDescriptor.value == nil || rowDescriptor.value == (id)[NSNull null]) {
                ageRow.value = @"N/A";
                [self reloadFormRow:ageRow];
                return; //do nothing
            }
            
            if (![self isDobValid:rowDescriptor.value]) {
                [rowDescriptor.cellConfig setObject:[UIColor colorWithRed:240/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] forKey:@"backgroundColor"]; //PINK
                [self reloadFormRow:rowDescriptor];
                ageRow.value = @"N/A";
                [self reloadFormRow:ageRow];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid DOB" message:@"Please check if you have keyed in correctly." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //do nothing;
                }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                return;      //check if DOB Is Valid first
            } else {
                [rowDescriptor.cellConfig setObject:[UIColor whiteColor] forKey:@"backgroundColor"]; //CLEAR
                [self reloadFormRow:rowDescriptor];
                
                NSString *dobString = [NSString stringWithFormat:@"%@", rowDescriptor.value];
//                NSString *birthDate = [self reorderDateString:dobString];
                [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:dobString];

                
                NSString *yearOfBirth = [NSString stringWithFormat:@"%@", [dobString substringWithRange:NSMakeRange(0, 4)]];  //format: YYYY-MM-dd
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy"];
                NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
                NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
                [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:@"yyyy" andNewContent:yearOfBirth];
                [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kAge andNewContent:[NSString stringWithFormat:@"%li", age]];
                
                NSLog(@"%li", (long)age);
                ageRow.value = [NSNumber numberWithLong:age];
                [self reloadFormRow:ageRow];
                
                if (age >= 40) {
                    age40aboveRow.value = @"Yes";
                    age40aboveRow.disabled = @YES;
                    [self updateFormRow:age40aboveRow];
                } else {
                    age40aboveRow.value = @"No";
                    age40aboveRow.disabled = @YES;
                    [self updateFormRow:age40aboveRow];
                }
                return; //do not need to proceed from here.
            }
            
        } else if (rowDescriptor.tag == kNotes) {
            [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
            return;
        } else if ([rowDescriptor.tag isEqualToString:kAddressOthersBlock])  {
            NSString *blkNumber = rowDescriptor.value;
            if ([rowDescriptor.value containsString:@"Blk "]) {
                blkNumber  = [[rowDescriptor.value mutableCopy] stringByReplacingOccurrencesOfString:@"Blk " withString:@""];
            } else if ([rowDescriptor.value containsString:@"BLK "]) {
                blkNumber = [[rowDescriptor.value mutableCopy] stringByReplacingOccurrencesOfString:@"BLK " withString:@""];
            } else if ([rowDescriptor.value containsString:@"Block "]) {
                blkNumber = [[rowDescriptor.value mutableCopy] stringByReplacingOccurrencesOfString:@"Block " withString:@""];
            } else if ([rowDescriptor.value containsString:@"BLOCK "]) {
                blkNumber = [[rowDescriptor.value mutableCopy] stringByReplacingOccurrencesOfString:@"BLOCK " withString:@""];
            }
            rowDescriptor.value = [blkNumber uppercaseString];
            [self updateFormRow:rowDescriptor];
        } else if ([rowDescriptor.tag isEqualToString:kAddressOthersRoadName]) {
            NSString *roadName = [rowDescriptor.value uppercaseString];
            if (roadName) {
                rowDescriptor.value = [self replaceShortForms:roadName];
                [self reloadFormRow:rowDescriptor];
            }
        }
        
        else if ([rowDescriptor.tag isEqualToString:kAddressPostCode]) {
            [self checkIfPostCodeIsValid:rowDescriptor];
            return;
        }
        else if ([rowDescriptor.tag isEqualToString:kLangExplainedInOthers] ||
                 [rowDescriptor.tag isEqualToString:kConsentTakerFullName] ||
                 [rowDescriptor.tag isEqualToString:kMatriculationNumber] ||
                 [rowDescriptor.tag isEqualToString:kOrganisationOthers]) {
            [self postSingleFieldWithSection:SECTION_CONSENT_DISCLOSURE andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
            return;
        }
        else if ([rowDescriptor.tag isEqualToString:kWitnessTranslatorFullName]) {
            [self postSingleFieldWithSection:SECTION_CONSENT_RESEARCH andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
            return;
        }
        
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
    }
}

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    NSString* ansFromGender, *ansFromYesNo;
    
    
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Male"])
            ansFromGender = @"M";
        else if ([newValue isEqualToString:@"Female"])
            ansFromGender = @"F";
    }
    
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Yes"])
            ansFromYesNo = @"1";
        else if ([newValue isEqualToString:@"No"])
            ansFromYesNo = @"0";
    }
    
    if ([rowDescriptor.tag isEqualToString:kGender]) {
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kGender andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kSpokenLang]) {
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kSpokenLang andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kBackupSpokenLang]) {
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kBackupSpokenLang andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kWrittenLang]) {
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kWrittenLang andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kConsent]) {
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kConsent andNewContent:[self getOneZerofromYesNo:newValue]];
    }
    else if ([rowDescriptor.tag isEqualToString:kLangExplainedIn]) {
        [self postSingleFieldWithSection:SECTION_CONSENT_DISCLOSURE andFieldName:kLangExplainedIn andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kOrganisation]) {
        [self postSingleFieldWithSection:SECTION_CONSENT_DISCLOSURE andFieldName:kOrganisation andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kConsentToResearch]) {
        [self postSingleFieldWithSection:SECTION_CONSENT_RESEARCH andFieldName:kConsentToResearch andNewContent:[self getOneZerofromYesNo:newValue]];
    }
    else if ([rowDescriptor.tag isEqualToString:kConsentRecontact]) {
        [self postSingleFieldWithSection:SECTION_CONSENT_RESEARCH andFieldName:kConsentRecontact andNewContent:[self getOneZerofromYesNo:newValue]];
    }
    else if ([rowDescriptor.tag isEqualToString:kTranslationDone]) {
        [self postSingleFieldWithSection:SECTION_CONSENT_RESEARCH andFieldName:kTranslationDone andNewContent:[self getOneZerofromYesNo:newValue]];
    }
    else if ([rowDescriptor.tag isEqualToString:kWantFreeBt]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kWantFreeBt andNewContent:[self getOneZerofromYesNo:newValue]];
    }
    else if ([rowDescriptor.tag isEqualToString:kChronicCond]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kChronicCond andNewContent:[self getOneZerofromYesNo:newValue]];
    }
    else if ([rowDescriptor.tag isEqualToString:kRegFollowup]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kRegFollowup andNewContent:[self getOneZerofromYesNo:newValue]];
    }
    else if ([rowDescriptor.tag isEqualToString:kNoBloodTest]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kNoBloodTest andNewContent:[self getOneZerofromYesNo:newValue]];
    }
    else if ([rowDescriptor.tag isEqualToString:kEligibleBloodTest]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kEligibleBloodTest andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kDidPhleb]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kDidPhleb andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kMammogramInterest]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_INTEREST andFieldName:kMammogramInterest andNewContent:ansFromYesNo];
    }
    else if ([rowDescriptor.tag isEqualToString:kHasChas]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_INTEREST andFieldName:kHasChas andNewContent:ansFromYesNo];
    }
    else if ([rowDescriptor.tag isEqualToString:kDoneBefore]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_INTEREST andFieldName:kDoneBefore andNewContent:ansFromYesNo];
    }
    else if ([rowDescriptor.tag isEqualToString:kWillingPay]) {
        [self postSingleFieldWithSection:SECTION_MAMMOGRAM_INTEREST andFieldName:kWillingPay andNewContent:ansFromYesNo];
    }
    else if ([rowDescriptor.tag isEqualToString:kScreenMode]) {
        [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kScreenMode andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kCentralDate]) {
        [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kCentralDate andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kApptDate]) {
        [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kApptDate andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kPhlebAppt]) {
        [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:kPhlebAppt andNewContent:newValue];
    }
}
    
    
    

#pragma mark -



- (void) calculateAge: (XLFormRowDescriptor *)sender {
    NSDate *dobDate = dobRow.value;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    
    NSString *yearOfBirth = [dateFormatter stringFromDate:dobDate];
    NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];

    NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
    
    
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"You are %ld years old", (long)age]];
    
    [self deselectFormRow:sender];
}


#pragma mark - Organize Dictionary Methods

- (NSString *) getStringWithDictionary:(NSDictionary *)dict
                               rowType:(NSInteger)type
                 formDescriptorWithTag:(NSString *)rowTag {
    //                             serverAPI:(NSString *)key {
    
    
    if (([dict objectForKey:rowTag] == [NSNull null]) || (![dict objectForKey:rowTag])) {    //if  NULL or nil, just return
        return @"";
    }
    NSString *fieldEntry, *returnValue;
    NSDate *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    switch (type) {
        case Text: returnValue = [dict objectForKey:rowTag];
            break;
            
        case YesNo: fieldEntry = [dict objectForKey:rowTag];
            if ([fieldEntry isEqualToString:@"YES"]) returnValue = @"1";
            else if([fieldEntry isEqualToString:@"NO"]) returnValue = @"0";
            else returnValue = @"";
            break;
            
        case TextView: returnValue = [dict objectForKey:rowTag];
            break;
            
        case Checkbox:
            break;
            
        case SelectorPush: returnValue = [NSString stringWithFormat:@"%@",[[dict objectForKey:rowTag] formValue]];
            break;
            
        case SelectorArray: returnValue = [NSString stringWithFormat:@"%@",[dict objectForKey:rowTag]];
            break;
            
        case SelectorActionSheet: returnValue = [NSString stringWithFormat:@"%@",[[dict objectForKey:rowTag] formValue]];
            break;
            
        case SegmentedControl:
            break;
            
        case Number: returnValue = [NSString stringWithFormat:@"%@",[dict objectForKey:rowTag]];
            break;
            
        case Switch: returnValue = [NSString stringWithFormat:@"%@",[dict objectForKey:rowTag]];
            break;
            
        case YesNoNA: fieldEntry = [dict objectForKey:rowTag];
            if ([fieldEntry isEqualToString:@"YES"]) returnValue = @"1";
            else if([fieldEntry isEqualToString:@"NO"]) returnValue = @"0";
            else if([fieldEntry isEqualToString:@"N.A."]) returnValue = @"2";
            else returnValue = @"";
            break;
        case Date: date = [dict objectForKey:rowTag];
            returnValue = [dateFormatter stringFromDate:date];
            break;
            
        default: NSLog(@"default, not found its type");
            break;
    }
    
    return returnValue;
}

- (BOOL) isDobValid: (NSString *) dobString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  //otherwise 1st Jan will not be able to be read.
    NSDate *date = [dateFormatter dateFromString:dobString];
    
    if (date != nil)  {
        return YES;
    }
    
    return NO;
    
    
}

- (NSString *) getDateStringFromFormValue: (NSDictionary *) formValues andRowTag: (NSString *) rowTag {
    NSDate *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    date = [formValues objectForKey:rowTag];
    return [dateFormatter stringFromDate:date];
}

- (NSString *) reorderDateString: (NSString *) originalDateString {

    NSString *newDate = [NSString stringWithFormat:@"%@-%@-%@",
                         [originalDateString substringFromIndex:4],
                         [originalDateString substringWithRange:NSMakeRange(2, 2)],
                         [originalDateString substringWithRange:NSMakeRange(0, 2)]];
    
    
    return newDate;
}

- (NSString *) getEthnicityString: (NSString *) number {
    NSArray *array = @[@"Chinese", @"Indian", @"Malay", @"Others"];
    return [array objectAtIndex:[number integerValue]];
}

- (NSString *) getBlockFromStreetName: (NSString *) street {
    
    NSMutableString *subString;
    NSString* result;
    
    if ([street containsString:@"Others"]) {
        return @"0";
    }
    
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        NSString *addressOption = [[self.form formValues] objectForKey:@"address_block_street"];
        subString = [[addressOption substringWithRange:NSMakeRange(0, 6)] mutableCopy];
        result = [subString stringByReplacingOccurrencesOfString:@"Blk " withString:@""];
    } else {        //Lengkok Bahru / Queenstown
        NSString *addressOption = [[self.form formValues] objectForKey:@"address_block_street"];
        if ([addressOption containsString:@"63A"]) return @"63A";
        else if ([addressOption containsString:@"63B"]) return @"63B";
        
        result = [addressOption stringByReplacingOccurrencesOfString:street withString:@""];
    }
    
    int blkNo = [result intValue];   //to remove whitespace
    return [NSString stringWithFormat:@"%d", blkNo];
}

- (NSString *) getStreetFromAddress: (NSString *) string {
    
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        if ([string containsString:@"Beach"]) return @"Beach Rd";
        else if ([string containsString:@"North"]) return @"North Bridge Rd";
        else if ([string containsString:@"Sultan"]) return @"Jln Sultan";
        else return @"Others";
    } else {
        if ([string containsString:@"Lengkok"]) return @"Lengkok Bahru";
        else if ([string containsString:@"Jln Bt"]) return @"Jln Bt Merah";
        else if ([string containsString:@"Jln Rumah"]) return @"Jln Rumah Tinggi";
        else if ([string containsString:@"Hoy Fatt"]) return @"Hoy Fatt Rd";
        else if ([string containsString:@"Merah Lane"]) return @"Bt Merah Lane 1";
        else return @"Others";
    }
}


- (NSString *) getAddressFromStreetAndBlock {
    if (_residentParticularsDict[kAddressStreet] != (id) [NSNull null]) {
        NSString *block = _residentParticularsDict[kAddressBlock];
        NSString *street = _residentParticularsDict[kAddressStreet];
        
        if ([street isEqualToString:@"Others"]) {
            return @"Others";
        }
        
        if ([neighbourhood isEqualToString:@"Kampong Glam"])
            return [NSString stringWithFormat:@"Blk %@ %@", block, street];
        else
            return [NSString stringWithFormat:@"%@ %@", block, street];
        
    }
    return @"";
}

- (NSString *) getTimeNowInString {
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    return [localDateTime description];
}

- (NSString *) replaceShortForms: (NSString *) originalString {
    NSString *pattern_rd = @"\\bRD\\b";
    NSString *pattern_ave = @"\\bAVE\\b";
    NSString *pattern_st = @"\\bST\\b";
    NSRange range_rd = [originalString rangeOfString:pattern_rd options:NSRegularExpressionSearch|NSCaseInsensitiveSearch];
    NSString *newString = [originalString mutableCopy];
    
    if (range_rd.location != NSNotFound) {
        newString = [newString stringByReplacingCharactersInRange:range_rd withString:@"ROAD"];
    }
    NSRange range_ave = [originalString rangeOfString:pattern_ave options:NSRegularExpressionSearch|NSCaseInsensitiveSearch];
    if (range_ave.location != NSNotFound) {
        newString = [newString stringByReplacingCharactersInRange:range_ave withString:@"AVENUE"];
    }
    NSRange range_st = [originalString rangeOfString:pattern_st options:NSRegularExpressionSearch|NSCaseInsensitiveSearch];
    if (range_st.location != NSNotFound) {
        newString = [newString stringByReplacingCharactersInRange:range_st withString:@"STREET"];
    }
    return newString;
}


- (NSString *) getYesNoFromOneZero: (id) value {
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

- (NSString *) getOneZerofromYesNo: (id) answer {
    if ([answer isKindOfClass:[NSString class]]) {
        if ([answer isEqualToString:@"Yes"] || [answer isEqualToString:@"True"]) {
            return @"1";
        } else {
            return @"0";
        }
    } else if ([answer isKindOfClass:[NSNumber class]]) {
        if ([answer isEqual:@1]) {
            return @"1";
        } else {
            return @"0";
        }
    }
    return @"0";
}


- (void) checkIfPostCodeIsValid: (XLFormRowDescriptor *) rowDescriptor {
    if (rowDescriptor.value) {
        NSString *url = @"https://nhs-som.nus.edu.sg/addressFromPostalCode";
        NSDictionary *dict = @{@"postalcode": rowDescriptor.value};
        NSDictionary *dataDict = @{ @"data" : dict };
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [SVProgressHUD show];
        
        [manager POST:url
           parameters:dataDict
             progress:nil
              success:^(NSURLSessionDataTask *_Nonnull task,
                        id _Nullable responseObject) {
                  
                  [SVProgressHUD dismiss];
                  
                  NSString *postalCode = [responseObject objectForKey:@"postalcode"];
                  NSString *address = [responseObject objectForKey:@"address"];
                  
                  if ([postalCode isEqual:address]) { // if not valid
                      
                      [rowDescriptor.cellConfig setObject:[UIColor colorWithRed:240/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] forKey:@"backgroundColor"]; //PINK
                      [self reloadFormRow:rowDescriptor];
                      
                      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Postcode" message:@"The postal code entered is not valid." preferredStyle:UIAlertControllerStyleAlert];
                      UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                          //do nothing;
                      }];
                      [alertController addAction:okAction];
                      [self presentViewController:alertController animated:YES completion:nil];
                  } else {
                      NSLog(@"%@", [responseObject objectForKey:@"address"]);
                      [rowDescriptor.cellConfig setObject:[UIColor whiteColor] forKey:@"backgroundColor"]; //CLEAR
                      [self reloadFormRow:rowDescriptor];
                      // VALID
                      [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
                  }
              }
              failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                  [SVProgressHUD dismiss];
                  NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
                  NSString *errorString =
                  [[NSString alloc] initWithData:errorData
                                        encoding:NSUTF8StringEncoding];
                  NSLog(@"error: %@", errorString);
              }];
    }
    
}

#pragma mark - UIBarButtonItem methods
- (void) editBtnPressed: (UIBarButtonItem * __unused)button {
    [self.form setDisabled:NO];
    [self.tableView endEditing:YES];
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitBtnPressed:)];
}

-(void)submitBtnPressed:(UIBarButtonItem * __unused)button {
    
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
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kPreregCompleted andNewContent:@"1"];
    }
}



#pragma mark - Download Server API
- (void) processConnectionStatus {
    if(status == NotReachable)
    {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Internet!", nil)
                                                                                  message:@"You're not connected to Internet."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction){
//                                                              [self.refreshControl endRefreshing];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (status == ReachableViaWiFi || status == ReachableViaWWAN) {
        
    }

}


#pragma mark - Post data to server methods

- (void) postSingleFieldWithSection:(NSString *) section andFieldName: (NSString *) fieldName andNewContent: (NSString *) content {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    NSDictionary *dict = @{kResidentId:resident_id,
                           kSectionName:section,
                           kFieldName:fieldName,
                           kNewContent:content
                           };
    
    NSLog(@"Uploading %@ for $%@$ field", content, fieldName);
    [KAStatusBar showWithStatus:@"Syncing..." andBarColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:0 alpha:1.0]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    ServerComm *client = [ServerComm sharedServerCommInstance];
    
    if ([fieldName isEqualToString:kPreregCompleted]) {
        [client postDataGivenSectionAndFieldName:dict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self preRegSuccessBlock]
                                    andFailBlock:[self errorBlock]];
    } else {
        [_pushPopTaskArray addObject:dict];
        [client postDataGivenSectionAndFieldName:dict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
    }
    
}

- (void) postAllOtherFields: (NSDictionary *) completeDict {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    
    NSString *section = @"resi_particulars";
    NSString *resident_id = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId];
    NSDictionary *singleSubmission;
    
    
    for (NSString *key in completeDict) {
        singleSubmission = @{kResidentId:resident_id,
                             kSectionName:section,
                             kFieldName:key,
                             kNewContent:completeDict[key]
                             };
        
        [client postDataGivenSectionAndFieldName:singleSubmission
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
    }
    
    
    
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"POST in progress...");
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        
        [_pushPopTaskArray removeObjectAtIndex:0];
        
        if ([[responseObject objectForKey:@"success"] isKindOfClass:[NSString class]]) {
            if ([[responseObject objectForKey:@"success"]isEqualToString:@"1"]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
                            }
        } else if ([[responseObject objectForKey:@"success"] isKindOfClass:[NSNumber class]]) {
            if ([[responseObject objectForKey:@"success"]isEqual:@1]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
            }
        }

    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))preRegSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        if ([[responseObject objectForKey:@"success"] isKindOfClass:[NSString class]]) {
            if ([[responseObject objectForKey:@"success"]isEqualToString:@"1"]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sucessful", nil)
                                                                                          message:@"Pre-registration completed!"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * okAction) {
                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"enableProfileEntry"
                                                                                                                          object:nil
                                                                                                                        userInfo:nil];
                                                                      [self.navigationController popViewControllerAnimated:YES];
                                                                  }]];
                [self presentViewController:alertController animated:YES completion:nil];

            }
        } else if ([[responseObject objectForKey:@"success"] isKindOfClass:[NSNumber class]]) {
            if ([[responseObject objectForKey:@"success"]isEqual:@1]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
                
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sucessful", nil)
                                                                                          message:@"Pre-registration completed!"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * okAction) {
                                                                      //                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                                      //                                                                                                                  object:nil
                                                                      //                                                                                                                userInfo:nil];
                                                                      [self.navigationController popViewControllerAnimated:YES];
                                                                  }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
        
        
        
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


#pragma mark - Others
- (void) checkIfSignatureExist {
    if (_signImagesArray != (id)[NSNull null]) {
        if ([_signImagesArray count] > 0) {
            for (NSDictionary *dict in _signImagesArray){
                if ([[dict objectForKey:@"file_type"] isEqualToString:@"resident_sign"]) {
                    [_signaturePresentArray replaceObjectAtIndex:0 withObject:@1];
                } else if ([[dict objectForKey:@"file_type"] isEqualToString:@"consent_disclosure"]) {
                    [_signaturePresentArray replaceObjectAtIndex:1 withObject:@1];
                } else if ([[dict objectForKey:@"file_type"] isEqualToString:@"agree_6_points"]) {
                    [_signaturePresentArray replaceObjectAtIndex:2 withObject:@1];
                } else if ([[dict objectForKey:@"file_type"] isEqualToString:@"witness_translator"]) {
                    [_signaturePresentArray replaceObjectAtIndex:3 withObject:@1];
                }
            }
        }
    }

}
- (void) updateSignatureButtonColors {

    NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:SCREENING_PARTICIPANT_SIGNATURE];
    NSString *str2 = [[NSUserDefaults standardUserDefaults] objectForKey:SCREENING_CONSENT_TAKER_SIGNATURE];
    NSString *str3 = [[NSUserDefaults standardUserDefaults] objectForKey:RESEARCH_PARTICIPANT_6_PTS_SIGNATURE];
    NSString *str4 = [[NSUserDefaults standardUserDefaults] objectForKey:RESEARCH_WITNESS_SIGNATURE];
    
    if (str1 != nil || [[_signaturePresentArray objectAtIndex:0] isEqualToNumber:@1]) {
        if (str2 != nil || [[_signaturePresentArray objectAtIndex:1] isEqualToNumber:@1]) {
            screeningSignColor = GREEN_COLOR;
            screeningSignDisabledColor = FADED_GREEN_COLOR;
        } else {
            screeningSignColor = [UIColor orangeColor];
            screeningSignDisabledColor = FADED_ORANGE_COLOR;
        }
    } else {
        if (str2 != nil || [[_signaturePresentArray objectAtIndex:1] isEqualToNumber:@1]) {
            screeningSignColor = [UIColor orangeColor];
            screeningSignDisabledColor = FADED_ORANGE_COLOR;
        } else {
            screeningSignColor = [UIColor redColor];
            screeningSignDisabledColor = FADED_RED_COLOR;
        }
    }
    
    if (str3 != nil || [[_signaturePresentArray objectAtIndex:2] isEqualToNumber:@1]) {
        if (str4 != nil || [[_signaturePresentArray objectAtIndex:3] isEqualToNumber:@1]) {
            researchSignColor = GREEN_COLOR;
            researchSignDisabledColor = FADED_GREEN_COLOR;
        } else {
            researchSignColor = [UIColor orangeColor];
            researchSignDisabledColor = FADED_ORANGE_COLOR;
        }
    } else {
        if (str4 != nil || [[_signaturePresentArray objectAtIndex:3] isEqualToNumber:@1]) {
            researchSignColor = [UIColor orangeColor];
            researchSignDisabledColor = FADED_ORANGE_COLOR;
        } else {
            researchSignColor = [UIColor redColor];
            researchSignDisabledColor = FADED_RED_COLOR;
        }
    }
    screeningSignButtonRow.cellConfig[@"backgroundColor"] = screeningSignColor;
    screeningSignButtonRow.cellConfigIfDisabled[@"backgroundColor"] = screeningSignDisabledColor;
    researchSignButtonRow.cellConfig[@"backgroundColor"] = researchSignColor;
    researchSignButtonRow.cellConfigIfDisabled[@"backgroundColor"] = researchSignDisabledColor;
    
    [self reloadFormRow:screeningSignButtonRow];
    [self reloadFormRow:researchSignButtonRow];
    
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

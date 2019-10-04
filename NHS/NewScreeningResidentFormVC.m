//
//  NewScreeningResidentFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/28/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "NewScreeningResidentFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSelectProfileTableVC.h"
#import "math.h"
#import "AFNetworking.h"
@import WebKit;

//XLForms stuffs.0 blue:141.0/255.0 alpha:1.0]
#define RESI_PART_SECTION @"resi_particulars"

#import "XLForm.h"

#define GREEN_COLOR [UIColor colorWithRed:48.0/255.0 green:207.0/255.0 blue:1.0/255.0 alpha:1.0]

@interface NewScreeningResidentFormVC () {
    NSString *neighbourhood;
    NetworkStatus status;
    XLFormRowDescriptor *dobRow, *ageRow, *age40aboveRow, *screeningSignButtonRow, *researchSignButtonRow, *genderRow;
    XLFormSectionDescriptor *mammoSection;
    XLFormRowDescriptor *mammogramInterestRow, *doneB4Row, *hasChasRow, *willingPayRow;
    NSString *block, *street, *yearOfBirth;
    BOOL gotOldRecord;
    UIColor *screeningSignColor, *researchSignColor;
}

@property (strong, nonatomic) NSNumber *resident_id;
@property (strong, nonatomic) NSString *nric;
@property (strong, nonatomic) NSDictionary *oldRecordDictionary;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;

@end

@implementation NewScreeningResidentFormVC

- (void)viewDidLoad {
    gotOldRecord = FALSE;
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kOldRecord]);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kOldRecord] != (id)[NSNull null] && [[NSUserDefaults standardUserDefaults] objectForKey:kOldRecord] != nil) {
        _oldRecordDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kOldRecord];
        gotOldRecord = TRUE;
    }
    neighbourhood = [[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood];
    
    XLFormViewController *form;
    
    neighbourhood = [[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    status = [reachability currentReachabilityStatus];
    [self processConnectionStatus];
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    
    //must init first before [super viewDidLoad]
    form = [self initNewResidentForm];
    
    [self.form setAddAsteriskToRequiredRowsTitle: YES];
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitBtnPressed:)];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self updateSignatureButtonColors];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id) initNewResidentForm {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New Resident"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    // Name
    XLFormRowDescriptor *nameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeName title:@"Resident Name"];
    if (gotOldRecord) nameRow.value = [_oldRecordDictionary objectForKey:kName];
    nameRow.required = YES;
    [self setDefaultFontWithRow:nameRow];
    [nameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:nameRow];
    
    
    genderRow = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    genderRow.selectorOptions = @[@"Male", @"Female"];
    [self setDefaultFontWithRow:genderRow];
    genderRow.required = YES;
    if (gotOldRecord) {
        if ([_oldRecordDictionary[kGender] isEqualToString:@"M"])
            genderRow.value = @"Male";
        else
            genderRow.value = @"Female";
    }
    [section addFormRow:genderRow];
    
    
    __weak __typeof(self)weakSelf = self;
    genderRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [weakSelf showHideMammogramSection];
        }
    };
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"Only Singaporeans/PRs (with a valid NRIC/FIN) are eligible for screening.";
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *nricRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeName title:@"NRIC"];
    nricRow.required = YES;
    [nricRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:nricRow];
    if (gotOldRecord) nricRow.value = [_oldRecordDictionary objectForKey:kNRIC];
    else
        nricRow.value = [[NSUserDefaults standardUserDefaults] objectForKey:kNRIC];
    [section addFormRow:nricRow];
    
    nricRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
            rowDescriptor.value = CAPSed;
        }
    };
    
    XLFormRowDescriptor *nric2Row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC2 rowType:XLFormRowDescriptorTypeName title:@"Re-enter NRIC"];
    nric2Row.required = YES;
    [nric2Row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (gotOldRecord) nric2Row.value = [_oldRecordDictionary objectForKey:kNRIC];
    [self setDefaultFontWithRow:nric2Row];
    [section addFormRow:nric2Row];
    
    nric2Row.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
            rowDescriptor.value = CAPSed;
        }
    };
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
  
    dobRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBirthDate rowType:XLFormRowDescriptorTypeText title:@"DOB (YYYY-MM-DD)"];
    if (gotOldRecord) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  //otherwise 1st Jan will not be able to be read.
        NSDate *date = [dateFormatter dateFromString:_oldRecordDictionary[kBirthDate]];
        
        //2019
        dobRow.value = [dateFormatter stringFromDate:date];
        // need to change it back to DDMMYYYY
//        dateFormatter.dateFormat = @"ddMMYYYY";
//        dobRow.value = [dateFormatter stringFromDate:date];
//        dobRow.value = date;
    }
    dobRow.required = YES;
    [dobRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:dobRow];
    [section addFormRow:dobRow];
    
    ageRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAge rowType:XLFormRowDescriptorTypeNumber title:@"Age (auto-calculated)"];
    [ageRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    ageRow.value = @"N/A";
    
    if (gotOldRecord) {
        // Calculate age
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
        NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
        
        if (dobRow.value != nil && dobRow.value != (id)[NSNull null]) {
            yearOfBirth = [dobRow.value substringWithRange:NSMakeRange(0, 4)];        //to match YYYY-MM-dd
//            NSString *yearOfBirth = [dobRow.value substringFromIndex:4];
            NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
            NSLog(@"%li", (long)age);
            ageRow.value = [NSNumber numberWithLong:age];
        }
    }
    ageRow.disabled = @1;
    [self setDefaultFontWithRow:ageRow];
    [section addFormRow:ageRow];
    
    XLFormRowDescriptor *citizenshipRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCitizenship rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Citizenship status"];
    citizenshipRow.required = YES;
    citizenshipRow.selectorOptions = @[@"Singaporean", @"PR", @"Foreigner"];
    if (gotOldRecord) citizenshipRow.value = [_oldRecordDictionary objectForKey:kCitizenship];
    [self setDefaultFontWithRow:citizenshipRow];
    [section addFormRow:citizenshipRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Please input 00000000 if the resident has no number available.";
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHpNumber rowType:XLFormRowDescriptorTypePhone title:@"HP Number"];
    if (gotOldRecord) row.value = [_oldRecordDictionary objectForKey:kHpNumber];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Please check that you have input the correct number" regex:@"^[0,6,8,9]\\d{7}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Please input 00000000 if the resident has no number available.";
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseNumber rowType:XLFormRowDescriptorTypePhone title:@"House Phone Number"];
    row.required = YES;
    if (gotOldRecord) row.value = [_oldRecordDictionary objectForKey:kHouseNumber];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Please check that you have input the correct number" regex:@"^[0,6,8,9]\\d{7}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    section.footerTitle = @"Please key in NIL if resident has no Next-of-kin.";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNokName rowType:XLFormRowDescriptorTypeName title:@"Name of Next-of-Kin"]; //need to add the part of inserting Nil if no one.
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNokRelationship rowType:XLFormRowDescriptorTypeSelectorPush title:@"Relationship to resident"]; //i.e. (resident's ______)
    row.required = YES;
    row.selectorOptions = @[@"Son", @"Daughter", @"Nephew", @"Niece", @"Husband", @"Wife", @"Father", @"Mother", @"Uncle", @"Aunt", @"Other", @"Nil"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNokContact rowType:XLFormRowDescriptorTypePhone title:@"Contact Number of Next-of-Kin"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^[0,6,8,9]\\d{7}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEthnicity rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Ethnicity"];
    row.selectorOptions = @[@"Chinese",@"Malay",@"Indian",@"Others"];
    row.required = YES;
    row.noValueDisplayText = @"Tap here for options";
    [self setDefaultFontWithRow:row];
    if (gotOldRecord) row.value = [_oldRecordDictionary objectForKey:kEthnicity];
    [section addFormRow:row];
    
    XLFormRowDescriptor * spokenLangRow;
//    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Languages"];
    //2019
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeSelectorPush title:@"Preferred Spoken Language"];
    spokenLangRow.selectorOptions = @[@"English", @"Mandarin", @"Malay", @"Tamil", @"Hindi", @"Cantonese", @"Hokkien", @"Teochew"];
    [self setDefaultFontWithRow:spokenLangRow];
    spokenLangRow.required = YES;
    [section addFormRow:spokenLangRow];
    
    XLFormRowDescriptor *backupSpokenLangRow;
    backupSpokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBackupSpokenLang rowType:XLFormRowDescriptorTypeSelectorPush title:@"Backup Spoken Language"];
    backupSpokenLangRow.selectorOptions = @[@"English", @"Mandarin", @"Malay", @"Tamil", @"Hindi", @"Cantonese", @"Hokkien", @"Teochew", @"None"];
    [self setDefaultFontWithRow:backupSpokenLangRow];
    backupSpokenLangRow.required = YES;
    [section addFormRow:backupSpokenLangRow];
    
    XLFormRowDescriptor *writtenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWrittenLang rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Written Language"];
    writtenLangRow.required = YES;
    writtenLangRow.selectorOptions = @[@"English", @"Chinese", @"Malay", @"Tamil", @"Nil"];
    [self setDefaultFontWithRow:writtenLangRow];
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
    [section addFormRow:addressRow];
    
    XLFormRowDescriptor *addressOthersBlock = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressOthersBlock rowType:XLFormRowDescriptorTypeText title:@"Address (Others)-Block"];
    addressOthersBlock.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", addressRow];
    [addressOthersBlock.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:addressOthersBlock];
    if (gotOldRecord) addressOthersBlock.value = [_oldRecordDictionary objectForKey:kAddressOthersBlock];
    [section addFormRow:addressOthersBlock];
    
    XLFormRowDescriptor *addressOthersRoadName = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressOthersRoadName rowType:XLFormRowDescriptorTypeText title:@"Address (Others)-Road Name"];
    addressOthersRoadName.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", addressRow];
    [addressOthersRoadName.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:addressOthersRoadName];
    [section addFormRow:addressOthersRoadName];
    
    addressRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            street = [self getStreetFromAddress:newValue];
            block  = [self getBlockFromStreetName:street];
            
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
    if (gotOldRecord) unitRow.value = [_oldRecordDictionary objectForKey:kAddressUnitNum];
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
    [section addFormRow:consentInfoRow];

    XLFormRowDescriptor *langExplainedRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLangExplainedIn rowType:XLFormRowDescriptorTypeSelectorPush title:@"Language explained in"];
    langExplainedRow.selectorOptions = @[@"English", @"Malay", @"Chinese", @"Tamil", @"Others"];
    [self setDefaultFontWithRow:langExplainedRow];
    langExplainedRow.required = YES;
    langExplainedRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    [section addFormRow:langExplainedRow];
    
    XLFormRowDescriptor *langExplainedOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kLangExplainedInOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    langExplainedOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", langExplainedRow];
    [langExplainedOthersRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    langExplainedOthersRow.required = YES;
    [self setDefaultFontWithRow:langExplainedOthersRow];
    [section addFormRow:langExplainedOthersRow];
    
    XLFormRowDescriptor *consentTakerNameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentTakerFullName rowType:XLFormRowDescriptorTypeName title:@"Consent Taker Full Name"];
    consentTakerNameRow.required = YES;
    [consentTakerNameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:consentTakerNameRow];
    consentTakerNameRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    [section addFormRow:consentTakerNameRow];
    
    XLFormRowDescriptor *matricNoRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMatriculationNumber rowType:XLFormRowDescriptorTypeName title:@"Matriculation Number"];
    matricNoRow.required = YES;
    [matricNoRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:matricNoRow];
    matricNoRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    [section addFormRow:matricNoRow];
    
    XLFormRowDescriptor *orgRow = [XLFormRowDescriptor formRowDescriptorWithTag:kOrganisation rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Organisation"];
    orgRow.selectorOptions = @[@"NUS Medicine", @"NUS Nursing", @"NTU Medicine", @"NUS Social Work", @"Others"];
    [self setDefaultFontWithRow:orgRow];
    orgRow.required = YES;
    orgRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentInfoRow];
    [section addFormRow:orgRow];
    
    XLFormRowDescriptor *orgOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kOrganisationOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
    orgOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", orgRow];
    [orgOthersRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    orgOthersRow.required = YES;
    [self setDefaultFontWithRow:orgOthersRow];
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
    [section addFormRow:consentResearchRow];
    
    XLFormRowDescriptor *consentRecontactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentRecontact rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Consent to be recontacted for further studies"];
    consentRecontactRow.selectorOptions = @[@"Yes", @"No"];
    consentRecontactRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    consentRecontactRow.required = YES;
    [self setDefaultFontWithRow:consentRecontactRow];
    consentRecontactRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentResearchRow];
    [section addFormRow:consentRecontactRow];
    
    XLFormRowDescriptor *translationDoneRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTranslationDone rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Translation Done?"];
    translationDoneRow.selectorOptions = @[@"Yes", @"No"];
    translationDoneRow.required = YES;
    translationDoneRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentResearchRow];
    [self setDefaultFontWithRow:translationDoneRow];
    [section addFormRow:translationDoneRow];
    
    XLFormRowDescriptor *witnessTransFullName = [XLFormRowDescriptor formRowDescriptorWithTag:kWitnessTranslatorFullName rowType:XLFormRowDescriptorTypeName title:@"Witness and/or Translator Full Name"];
    witnessTransFullName.required = YES;
    [witnessTransFullName.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:witnessTransFullName];
    witnessTransFullName.cellConfig[@"textLabel.numberOfLines"] = @0;
    witnessTransFullName.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", consentResearchRow];
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
    
    age40aboveRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:age40aboveRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Phlebotomy Eligibility Assessment"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *wantFreeBtRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantFreeBt rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident want a free blood test?"];
    [self setDefaultFontWithRow:wantFreeBtRow];
    wantFreeBtRow.selectorOptions = @[@"Yes", @"No"];
    wantFreeBtRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:wantFreeBtRow];
    
    XLFormRowDescriptor *chronicCondRow;
    
    chronicCondRow = [XLFormRowDescriptor formRowDescriptorWithTag:kChronicCond rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does the resident have a previously diagnosed chronic condition?"];
    chronicCondRow.required = YES;
    chronicCondRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:chronicCondRow];
    chronicCondRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:chronicCondRow];
    
    XLFormRowDescriptor *noFollowUpPcpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRegFollowup rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Is resident under regular follow-up with primary care physician?"];
    noFollowUpPcpRow.required = YES;
    noFollowUpPcpRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:noFollowUpPcpRow];
    noFollowUpPcpRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noFollowUpPcpRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", chronicCondRow];
    [section addFormRow:noFollowUpPcpRow];
    
    XLFormRowDescriptor *noBloodTestRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNoBloodTest
                                                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                  title:@"Has the resident taken a blood test in the past 3 years?"];
    [self setDefaultFontWithRow:noBloodTestRow];
    noBloodTestRow.selectorOptions = @[@"Yes",@"No"];
    noBloodTestRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:noBloodTestRow];
    
    XLFormRowDescriptor *eligibleBTRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEligibleBloodTest
                                                                               rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                 title:@"Is resident eligible for a blood test? (auto-calculated)"];
    [self setDefaultFontWithRow:eligibleBTRow];
    [eligibleBTRow.cellConfigAtConfigure setObject:[UIColor purpleColor] forKey:@"tintColor"];
    eligibleBTRow.disabled = @YES;
    eligibleBTRow.selectorOptions = @[@"Yes",@"No"];
    eligibleBTRow.cellConfig[@"textLabel.numberOfLines"] = @0;
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
                
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kChronicCond] == (id)[NSNull null] || [dict objectForKey:kRegFollowup] == (id)[NSNull null]) {
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
    didPhlebRow.value = @"No, not at all";
    didPhlebRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:didPhlebRow];
    
//    if (![neighbourhood containsString:@"Kampong"]) {
//
//
//        mammoSection = [XLFormSectionDescriptor formSectionWithTitle:@"Mammogram"];
//        [formDescriptor addFormSection:mammoSection];
//
//        mammogramInterestRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMammogramInterest
//                                                                     rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
//                                                                       title:@"Are you interested in taking a mammogram on Saturday 10am-1pm?"];
//        [self setDefaultFontWithRow:mammogramInterestRow];
//        mammogramInterestRow.required = YES;
//        mammogramInterestRow.selectorOptions = @[@"Yes",@"No"];
//        mammogramInterestRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//        [mammoSection addFormRow:mammogramInterestRow];
//
//        hasChasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHasChas
//                                                                                    rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
//                                                                                      title:@"Does the resident have a Blue/Orange CHAS card?"];
//        [self setDefaultFontWithRow:hasChasRow];
//        hasChasRow.required = YES;
//        hasChasRow.selectorOptions = @[@"Yes",@"No"];
//        hasChasRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//        hasChasRow.hidden = @YES;       //default hidden
//        [mammoSection addFormRow:hasChasRow];
//
//        doneB4Row = [XLFormRowDescriptor formRowDescriptorWithTag:kDoneBefore
//                                                                               rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
//                                                                                 title:@"Has the resident done a mammogram before?"];
//        [self setDefaultFontWithRow:doneB4Row];
//        doneB4Row.required = YES;
//        doneB4Row.selectorOptions = @[@"Yes",@"No"];
//        doneB4Row.cellConfig[@"textLabel.numberOfLines"] = @0;
//        doneB4Row.hidden = @YES;       //default hidden
//        [mammoSection addFormRow:doneB4Row];
//
//        willingPayRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWillingPay
//                                                                                   rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
//                                                                                     title:@"Is resident willing to pay $10 for mammogram? (To explain that resident has to pay subsidised fee of $10 if this is a repeat mammogram.)"];
//        [self setDefaultFontWithRow:willingPayRow];
//        willingPayRow.required = YES;
//        willingPayRow.selectorOptions = @[@"Yes",@"No"];
//        willingPayRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//        willingPayRow.hidden = @YES;        //by default always hidden
//        [mammoSection addFormRow:willingPayRow];
//
//        mammoSection.hidden = @YES;
//
//        mammogramInterestRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//            if (newValue != oldValue) {
//                if ([newValue isEqualToString:@"Yes"]) {
//                    hasChasRow.hidden = @NO;
//                    doneB4Row.hidden = @NO;
//                } else {
//                    hasChasRow.hidden = @YES;
//                    doneB4Row.hidden = @YES;
//                }
//
//                [self reloadFormRow:hasChasRow];
//                [self reloadFormRow:doneB4Row];
//            }
//        };
//
//
//        hasChasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//            if (newValue != oldValue) {
//                if ([newValue isEqualToString:@"No"]) {
//                    if (doneB4Row.value != (id)[NSNull null] && [doneB4Row.value isEqualToString:@"Yes"]) {
//                        willingPayRow.hidden = @NO;
//                    } else {
//                        willingPayRow.hidden = @YES;
//                    }
//                } else {
//                    willingPayRow.hidden = @YES;
//                }
//
//                [self reloadFormRow:willingPayRow];
//            }
//        };
//
//        doneB4Row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//            if (newValue != oldValue) {
//                if ([newValue isEqualToString:@"Yes"]) {
//                    if (hasChasRow.value != (id)[NSNull null] && [hasChasRow.value isEqualToString:@"No"]) {
//                        willingPayRow.hidden = @NO;
//                    } else {
//                        willingPayRow.hidden = @YES;
//                    }
//                } else {
//                    willingPayRow.hidden = @YES;
//                }
//
//                [self reloadFormRow:willingPayRow];
//            }
//        };
//    }
    
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mode of Screening"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *screenModeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kScreenMode rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Pick one"];
    screenModeRow.selectorOptions = @[@"Centralised", @"Door-to-door"];
    screenModeRow.required = YES;
    [self setDefaultFontWithRow:screenModeRow];
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
    apptDateRow.required = YES;
    [self setDefaultFontWithRow:apptDateRow];
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
    phlebApptRow.required = YES;
    [self setDefaultFontWithRow:phlebApptRow];
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
    
    [section addFormRow:commentsRow];
    
    
    return [super initWithForm:formDescriptor];
}

#pragma mark - XLFormButton Segue
- (void) goToViewSignatureVC: (XLFormRowDescriptor *) sender {
    [self performSegueWithIdentifier:@"RegistrationFormToViewSignatureSegue" sender:self];
}

- (void) goToResearchSignatureVC: (XLFormRowDescriptor *) sender {
    [self performSegueWithIdentifier:@"RegistrationFormToResearchSignatureSegue" sender:self];
}

//- (void) goToShowConsentForm: (XLFormRowDescriptor *) sender {
//    NSString *formName;
//    if ([sender.tag containsString:@"research"]) {
//        formName = @"ResearchConsent";
//    } else {
//        formName = @"ScreeningConsent";
//    }
//    UIViewController *webVC = [[UIViewController alloc] init];
//
//    NSURL *targetURL = [[NSBundle mainBundle] URLForResource:formName withExtension:@"pdf"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
//    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
//    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, webVC.view.frame.size.width, webVC.view.frame.size.height) configuration:theConfiguration];
//    [wkWebView loadRequest:request];
//
//    [webVC.view addSubview:wkWebView];
//
//
//    [self.navigationController pushViewController:webVC animated:YES];
//}


#pragma mark - XLFormViewControllerDelegate
-(void)endEditing:(XLFormRowDescriptor *) rowDescriptor{

    
    if ([rowDescriptor.tag isEqualToString:kBirthDate] ) {
        // Calculate age
        
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
            yearOfBirth = [NSString stringWithFormat:@"%@", [dobString substringWithRange:NSMakeRange(0, 4)]];  //format: YYYY-MM-dd
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy"];
            NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
            NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
            NSLog(@"%li", (long)age);
            ageRow.value = [NSNumber numberWithLong:age];
            [self reloadFormRow:ageRow];
            
            if (age >= 40) {
                age40aboveRow.value = @"Yes";
                age40aboveRow.disabled = @YES;
                [self updateFormRow:age40aboveRow];
                [self showHideMammogramSection];
            } else {
                age40aboveRow.value = @"No";
                age40aboveRow.disabled = @YES;
                [self updateFormRow:age40aboveRow];
                [self showHideMammogramSection];
            }
        }
    }
    else if ([rowDescriptor.tag isEqualToString:kName]) {
        NSString *CAPSed = [rowDescriptor.value uppercaseString];
        rowDescriptor.value = CAPSed;
        [self reloadFormRow:rowDescriptor];
        
        return;
    } else if ([rowDescriptor.tag isEqualToString:kNRIC]) {
        NSString *CAPSed = [rowDescriptor.value uppercaseString];
        if (CAPSed != nil) {
            rowDescriptor.value = CAPSed;
            [self reloadFormRow:rowDescriptor];
        } else {
            rowDescriptor.value = @"";
        }
        
        
        NSString *url = @"https://pd.homerehab.com.sg/isNricValid";
        NSDictionary *dict = @{@"nric": rowDescriptor.value};
        NSDictionary *dataDict = @{ @"data" : dict };
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager POST:url
           parameters:dataDict
             progress:nil
              success:^(NSURLSessionDataTask *_Nonnull task,
                        id _Nullable responseObject) {
                  
                  NSNumber *valid = [responseObject objectForKey:@"isNricValid"];
                  
                  if (![valid boolValue]) { // if not valid
                      
                      [rowDescriptor.cellConfig setObject:[UIColor colorWithRed:240/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] forKey:@"backgroundColor"]; //PINK
                      [self reloadFormRow:rowDescriptor];
                      
                      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid NRIC" message:@"Please check if you have keyed in correctly." preferredStyle:UIAlertControllerStyleAlert];
                      UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                          //do nothing;
                      }];
                      [alertController addAction:okAction];
                      [self presentViewController:alertController animated:YES completion:nil];
                  } else {
                      [rowDescriptor.cellConfig setObject:[UIColor whiteColor] forKey:@"backgroundColor"]; //CLEAR
                      [self reloadFormRow:rowDescriptor];
                      // VALID
                  }
              }
              failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                  NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
                  NSString *errorString =
                  [[NSString alloc] initWithData:errorData
                                        encoding:NSUTF8StringEncoding];
                  NSLog(@"error: %@", errorString);
                  
                  
              }];
        return;
    } else if ([rowDescriptor.tag isEqualToString:kNRIC2]) {
        if (rowDescriptor.value) {  //if it's not blank
            if ([rowDescriptor.value isEqualToString:[[self.form formValues] objectForKey:kNRIC]]) {
                [rowDescriptor.cellConfig setObject:[UIColor whiteColor] forKey:@"backgroundColor"]; //CLEAR
                [self reloadFormRow:rowDescriptor];
            } else {
                [rowDescriptor.cellConfig setObject:[UIColor colorWithRed:240/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] forKey:@"backgroundColor"]; //PINK
                [self reloadFormRow:rowDescriptor];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"NRIC not match" message:@"Both NRIC entries must match." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //do nothing;
                }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
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
    }
}

#pragma mark - Connectivity Check
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

#pragma mark - Submit
- (void) uploadImageBtnPressed: (UIBarButtonItem * __unused)button {
    [self uploadSignatureIfAny];
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
        BOOL signatureComplete = [self checkAllSignature];
        
        if (!signatureComplete) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incomplete signature" message:@"Signature(s) seem to be incomplete. Are you sure you want to continue to submit?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self prepareAndSubmitForm];
            }];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController addAction:yesAction];
            [alertController addAction:noAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else {    // if signature all complete, skip the alert prompt
            [self prepareAndSubmitForm];
        }
    }
        
}

- (void) prepareAndSubmitForm {
    NSDictionary *fields = [self.form formValues];
    NSString *name, *nric, *gender, *birthDate;
    
    if ([fields objectForKey:kGender] != [NSNull null]) {
        if ([[fields objectForKey:kGender] isEqualToString:@"Male"]) {
            gender = @"M";
        } else if ([[fields objectForKey:kGender] isEqualToString:@"Female"]) {
            gender = @"F";
        }
    }
    NSString *CAPSed = [fields[kName] uppercaseString];
    name = CAPSed;
    
    //        name = fields[kName];
    nric = fields[kNRIC];
    self.nric = fields[kNRIC];
    
    /** Replaced after 2.0.3093 */
    birthDate = fields[kBirthDate];
    
    // 2019 (don't need anymore)
    //        birthDate = [self reorderDateString:fields andRowTag:kBirthDate];
    
    NSString *timeNow = [self getTimeNowInString];
    
    NSString *unitNo = [fields objectForKey:kAddressUnitNum];
    unitNo = [unitNo stringByReplacingOccurrencesOfString:@"#" withString:@""]; //remove the '#' from the String
    
    NSLog(@"Registering new resident...");
    
    // **** RESI PARTICULARS **** //
    
    NSDictionary *dict = @{kName:name,
                           kNRIC:nric,
                           kGender:gender,
                           kBirthDate:birthDate,
                           @"yyyy":yearOfBirth,
                           @"age": ageRow.value,
                           kCitizenship:[fields objectForKey:kCitizenship],
                           kHpNumber: [fields objectForKey:kHpNumber],
                           kHouseNumber: [fields objectForKey:kHouseNumber],
                           kNokName: [fields objectForKey:kNokName],
                           kNokRelationship: [fields objectForKey:kNokRelationship],
                           kNokContact: [fields objectForKey:kNokContact],
                           kEthnicity: [fields objectForKey:kEthnicity],
                           kSpokenLang: [fields objectForKey:kSpokenLang],
                           kBackupSpokenLang: [fields objectForKey:kBackupSpokenLang],
                           kWrittenLang: [fields objectForKey:kWrittenLang],
                           kAddressBlock: block,
                           kAddressStreet: street,
                           kAddressUnitNum: unitNo,
                           kAddressPostCode: [fields objectForKey:kAddressPostCode],
                           kConsent: [self getOneZerofromYesNo:[fields objectForKey:kConsent]],
                           kTimestamp:timeNow,
                           kScreenLocation:neighbourhood,
                           @"prereg_completed":@"1"
                           };
    
    //        dict = [self addLangFieldsIfAny:dict];
    dict = [self addAddressOthersIfAny:dict];
    
    // **** CONSENT DISCLOSURE **** //
    NSArray *array = @[kLangExplainedIn, kLangExplainedInOthers, kConsentTakerFullName, kMatriculationNumber, kOrganisation, kOrganisationOthers];
    NSMutableDictionary *mutDict4 = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in array) {
        if ([fields objectForKey:key] != nil && [fields objectForKey:key] != (id)[NSNull null]) {
            [mutDict4 setObject:[fields objectForKey:key] forKey:key];
        }
    }
    NSDictionary *dict4 = mutDict4;
    
    
    // **** CONSENT RESEARCH **** //
    NSDictionary *dict5;
    if ([[fields objectForKey:kConsentToResearch] isEqualToString:@"No"]) {
        dict5 = @{kConsentToResearch:[self getOneZerofromYesNo:[fields objectForKey:kConsentToResearch]]};
    } else {
        dict5 = @{kConsentToResearch:[self getOneZerofromYesNo:[fields objectForKey:kConsentToResearch]],
                  kConsentRecontact:[self getOneZerofromYesNo:[fields objectForKey:kConsentRecontact]],
                  kTranslationDone:[self getOneZerofromYesNo:[fields objectForKey:kTranslationDone]],
                  kWitnessTranslatorFullName:[fields objectForKey:kWitnessTranslatorFullName]};
    }

    // **** PHLEB PART **** //
    
    NSString *didPhlebEntry = [fields objectForKey:kDidPhleb];
    if (didPhlebEntry == nil) didPhlebEntry = @"";
    
    NSDictionary *dict2 = @{kWantFreeBt:[self getOneZerofromYesNo:[fields objectForKey:kWantFreeBt]],
                            kSporeanPr:[self getOneZerofromYesNo:[fields objectForKey:kSporeanPr]],
                            kIsPr:[self getOneZerofromYesNo:[fields objectForKey:kIsPr]],
                            kAgeCheck:[self getOneZerofromYesNo:[fields objectForKey:kAgeCheck]],
                            kChronicCond:[self getOneZerofromYesNo:[fields objectForKey:kChronicCond]],
                            kNoBloodTest:[self getOneZerofromYesNo:[fields objectForKey:kNoBloodTest]],
                            kEligibleBloodTest:[fields objectForKey:kEligibleBloodTest],
                            kDidPhleb:didPhlebEntry
                            };
    
    if ([fields objectForKey:kRegFollowup] != nil && [fields objectForKey:kRegFollowup] != (id)[NSNull null]) {
        NSMutableDictionary *mutDict2 = [dict2 mutableCopy];
        [mutDict2 setObject:[self getOneZerofromYesNo:[fields objectForKey:kRegFollowup]] forKey:kRegFollowup];
        dict2 = mutDict2;
    }
    
    
    // **** MODE OF SCREENING **** //
    array = @[kScreenMode, kNotes, kCentralDate, kPhlebAppt, kApptDate];
    NSMutableDictionary *mutDict3 = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in array) {
        if ([fields objectForKey:key] != nil && [fields objectForKey:key] != (id)[NSNull null]) {
            [mutDict3 setObject:[fields objectForKey:key] forKey:key];
        }
    }
    NSDictionary *dict3 = mutDict3;
    
    NSDictionary *finalDict;
    
//    if (![neighbourhood containsString:@"Kampong"] && ![mammoSection.hidden boolValue]) {   //only applicable to lengkok bahru ppl, and must be ladies' age >=40
//        // **** MAMMOGRAM INTEREST **** //
//        NSDictionary *dict6 = @{kMammogramInterest:[self getOneZerofromYesNo:[fields objectForKey:kMammogramInterest]]
//                                };
//
//        NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:dict6];
//
//        if (![hasChasRow.hidden boolValue]) {
//
//            [mutDict setObject:[self getOneZerofromYesNo:[fields objectForKey:kHasChas]] forKey:kHasChas];
//            dict6 = mutDict;
//        }
//
//        if (![doneB4Row.hidden boolValue]) {
//            [mutDict setObject:[self getOneZerofromYesNo:[fields objectForKey:kDoneBefore]] forKey:kDoneBefore];
//            dict6 = mutDict;
//        }
//
//        if (![willingPayRow.hidden boolValue]) {
//            [mutDict setObject:[self getOneZerofromYesNo:[fields objectForKey:kWillingPay]] forKey:kWillingPay];
//            dict6 = mutDict;
//        }
//
//        finalDict = @{@"resi_particulars": dict,
//                      @"phlebotomy_eligibility_assmt": dict2,
//                      @"mode_of_screening":dict3,
//                      @"consent_disclosure": dict4,
//                      @"consent_research": dict5,
//                      @"mammogram_interest": dict6
//                      };
//    } else {
    
    // NO NEED MAMMOGRAM INTEREST FOR 5 OCT 2019
            finalDict = @{@"resi_particulars": dict,
                          @"phlebotomy_eligibility_assmt": dict2,
                          @"mode_of_screening":dict3,
                          @"consent_disclosure": dict4,
                          @"consent_research": dict5
                          };
//    }
    
    
    
    [self submitNewResidentEntry:finalDict];
}

- (BOOL) checkAllSignature {
    NSArray *signatureKeys = @[SCREENING_PARTICIPANT_SIGNATURE, SCREENING_CONSENT_TAKER_SIGNATURE, RESEARCH_PARTICIPANT_6_PTS_SIGNATURE, RESEARCH_WITNESS_SIGNATURE];
    
    int count=0;
    for (NSString *key in signatureKeys) {
        NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (imagePath) count++;
    }   //clear all the signatures before leaving this page.
    
    if (count == 4) return YES;
    else return NO;
}

-(void)cancelPressed:(UIBarButtonItem * __unused)button
{
    NSArray *signatureKeys = @[SCREENING_PARTICIPANT_SIGNATURE, SCREENING_CONSENT_TAKER_SIGNATURE, RESEARCH_PARTICIPANT_6_PTS_SIGNATURE, RESEARCH_WITNESS_SIGNATURE];
    
    for (NSString *key in signatureKeys) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }   //clear all the signatures before leaving this page.
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) isDobValid: (NSString *) dobString {
    
    if ([dobString length] != 10)
        return NO;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  //otherwise 1st Jan will not be able to be read.
    NSDate *date = [dateFormatter dateFromString:dobString];
    
    if (date != nil) return YES;
    
    return NO;
    
    
}

- (NSString *) getDateStringFromFormValue: (NSDictionary *) formValues andRowTag: (NSString *) rowTag {
    NSDate *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    date = [formValues objectForKey:rowTag];
    return [dateFormatter stringFromDate:date];
}

- (NSString *) reorderDateString: (NSDictionary *) formValues andRowTag: (NSString *) rowTag {

    NSString *originalDateString = [formValues objectForKey:rowTag];    //which is in DDMMYYYY
    NSString *newDate = [NSString stringWithFormat:@"%@-%@-%@",
                         [originalDateString substringFromIndex:4],
                         [originalDateString substringWithRange:NSMakeRange(2, 2)],
                         [originalDateString substringWithRange:NSMakeRange(0, 2)]];
    
    
    return newDate;
}

- (NSString *) getTimeNowInString {
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    return [localDateTime description];
}

#pragma mark - Post data to server methods
- (void) submitNewResidentEntry:(NSDictionary *) dict {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postNewResidentWithDict:dict
                      progressBlock:[self progressBlock]
                       successBlock:[self personalInfoSuccessBlock]
                       andFailBlock:[self errorBlock]];
}

- (void) uploadSignatureIfAny {
    NSArray *signatureKeys = @[SCREENING_PARTICIPANT_SIGNATURE, SCREENING_CONSENT_TAKER_SIGNATURE, RESEARCH_PARTICIPANT_6_PTS_SIGNATURE, RESEARCH_WITNESS_SIGNATURE];
    if (![self hasSignature]) {
        
        for (NSString *key in signatureKeys) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }   //clear all the signatures before leaving this page.
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshScreeningResidentTable"
                                                                object:self
                                                              userInfo:@{kResidentId:self.resident_id}];
        }];
    } else {
        NSLog(@"Got signature!");
        for (NSString *key in signatureKeys) {
            NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            UIImage *image;
            
            NSString *fileType;
            if ([key isEqualToString:SCREENING_PARTICIPANT_SIGNATURE]) fileType = @"resident_sign";
            else if ([key isEqualToString:SCREENING_CONSENT_TAKER_SIGNATURE]) fileType = @"consent_disclosure";
            else if ([key isEqualToString:RESEARCH_PARTICIPANT_6_PTS_SIGNATURE]) fileType = @"agree_6_points";
            else if ([key isEqualToString:RESEARCH_WITNESS_SIGNATURE]) fileType = @"witness_translator";
            
            // upload image if exist
            if (imagePath) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                [SVProgressHUD showWithStatus:@"Uploading signature"];
                [_pushPopTaskArray addObject:@{@"image":image, @"file_type":fileType}];
                
                NSLog(@"%@", _pushPopTaskArray);
                
               
            }
            

        }
        NSDictionary *firstImageDict = [_pushPopTaskArray firstObject];
        UIImage *image = [firstImageDict objectForKey:@"image"];
        NSString *fileType = [firstImageDict objectForKey:@"file_type"];
        
        // only uploads the first image, the rest will be uploaded in the successBlock itself.
        [[ServerComm sharedServerCommInstance] uploadImage:image
                                               forResident:self.resident_id
                                                  withNric:self.nric
                                           andWithFileType:fileType
                                         withProgressBlock:[self progressBlock]
                                         completionHandler:[self successBlock]];
        
        
        
    }
}

- (void (^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)) successBlock {
    return ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error){
        NSLog(@"%@", responseObject);
        
        if (responseObject != (id)[NSNull null] && [responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSLog(@"Submitted this IMAGEBLOCK: %@", _pushPopTaskArray[0]);
            
            [_pushPopTaskArray removeObjectAtIndex:0];
            
            if ([_pushPopTaskArray count] == 0) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [SVProgressHUD dismiss];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshScreeningResidentTable"
                                                                        object:self
                                                                      userInfo:@{kResidentId:self.resident_id}];
                }];
            } else {
                NSDictionary *retryDict = [_pushPopTaskArray firstObject];

                [[ServerComm sharedServerCommInstance] uploadImage:retryDict[@"image"]
                                                       forResident:self.resident_id
                                                          withNric:self.nric
                                                   andWithFileType:retryDict[@"file_type"]
                                                 withProgressBlock:[self progressBlock]
                                                 completionHandler:[self successBlock]];
                
            }
        }
    };
}

- (BOOL) hasSignature {
    NSArray *signatureKeys = @[SCREENING_PARTICIPANT_SIGNATURE, SCREENING_CONSENT_TAKER_SIGNATURE, RESEARCH_PARTICIPANT_6_PTS_SIGNATURE, RESEARCH_WITNESS_SIGNATURE];
    
    for (NSString *key in signatureKeys) {
        NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (imagePath != nil && ![imagePath isEqualToString:@""]) {
            NSLog(@"Image path: %@", imagePath);
            return true;
        }
    }
    return false;
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"POST in progress...");
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))personalInfoSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        
        if ([responseObject objectForKey:@"reason"]) {  //if it's not nil (which means there's duplicates)
            [SVProgressHUD setMinimumDismissTimeInterval:1.0];
            [SVProgressHUD showErrorWithStatus:@"This NRIC is already registered!"];
            return;
        }
        NSLog(@"Personal info submission success");
        
        self.resident_id = [responseObject objectForKey:kResidentId];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.resident_id forKey:kResidentId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"I'm resident %@", self.resident_id);
        
        [self uploadSignatureIfAny];
        
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

- (void) updateSignatureButtonColors {
//    NSArray *signatureKeys = @[SCREENING_PARTICIPANT_SIGNATURE, SCREENING_CONSENT_TAKER_SIGNATURE, RESEARCH_PARTICIPANT_6_PTS_SIGNATURE, RESEARCH_WITNESS_SIGNATURE];
    NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:SCREENING_PARTICIPANT_SIGNATURE];
    NSString *str2 = [[NSUserDefaults standardUserDefaults] objectForKey:SCREENING_CONSENT_TAKER_SIGNATURE];
    NSString *str3 = [[NSUserDefaults standardUserDefaults] objectForKey:RESEARCH_PARTICIPANT_6_PTS_SIGNATURE];
    NSString *str4 = [[NSUserDefaults standardUserDefaults] objectForKey:RESEARCH_WITNESS_SIGNATURE];
    
    if (str1 != nil) {
        if (str2 != nil) {
            screeningSignColor = GREEN_COLOR;
        } else {
            screeningSignColor = [UIColor orangeColor];
        }
    } else {
        if (str2 != nil) {
            screeningSignColor = [UIColor orangeColor];
        } else {
            screeningSignColor = [UIColor redColor];
        }
    }
    
    if (str3 != nil) {
        if (str4 != nil) {
            researchSignColor = GREEN_COLOR;
        } else {
            researchSignColor = [UIColor orangeColor];
        }
    } else {
        if (str4 != nil) {
            researchSignColor = [UIColor orangeColor];
        } else {
            researchSignColor = [UIColor redColor];
        }
    }
    screeningSignButtonRow.cellConfig[@"backgroundColor"] = screeningSignColor;
    researchSignButtonRow.cellConfig[@"backgroundColor"] = researchSignColor;
    [self reloadFormRow:screeningSignButtonRow];
    [self reloadFormRow:researchSignButtonRow];
    
}

#pragma mark - Organize Methods

-(BOOL)isContactNumberValid: (NSString *) contactNumber {
    NSError  *error  = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @"^[0,6,8,9]\\d{7}$"
                                                                           options:0
                                                                             error:
                                  &error];
    NSUInteger numOfMatches   = [regex numberOfMatchesInString:contactNumber
                                                       options:0
                                                         range:
                                 NSMakeRange(0, [contactNumber length])];
    
    return numOfMatches == 1;
}

- (NSString *) getStreetFromAddress: (NSString *) string {
    
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        if ([string containsString:@"Beach"]) return @"Beach Rd";
        else if ([string containsString:@"North"]) return @"North Bridge Rd";
        else if ([string containsString:@"Sultan"]) return @"Jln Sultan";
        else return @"Others";
    } else {
        if ([string containsString:@"Lengkok"]) return @"Lengkok Bahru";
        else if ([string containsString:@"Jln Bukit"]) return @"Jln Bt Merah";
        else if ([string containsString:@"Jln Rumah"]) return @"Jln Rumah Tinggi";
        else if ([string containsString:@"Hoy Fatt"]) return @"Hoy Fatt";
        else if ([string containsString:@"Merah Lane"]) return @"Bt Merah Lane 1";
        else return @"Others";
    }
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
        else if ([addressOption containsString:@"Merah"]) return @"3";
        
        result = [addressOption stringByReplacingOccurrencesOfString:street withString:@""];
    }
    
    int blkNo = [result intValue];   //to remove whitespace
    return [NSString stringWithFormat:@"%d", blkNo];
}


- (NSDictionary *) addAddressOthersIfAny: (NSDictionary *) dict {
    
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] init];
    mutDict = [dict mutableCopy];
    
    NSString *addressField = [[self.form formValues] objectForKey:@"address_block_street"];
    if ([addressField containsString:@"Others"]) {
        NSString *othersBlock = [[self.form formValues] objectForKey:kAddressOthersBlock];
        NSString *othersRoadName = [[self.form formValues] objectForKey:kAddressOthersRoadName];
        
        [mutDict setObject:othersBlock forKey:kAddressOthersBlock];
        [mutDict setObject:othersRoadName forKey:kAddressOthersRoadName];
        [mutDict removeObjectForKey:kAddressBlock]; //not valid anymore
    }
    
    return mutDict;
}

- (void) checkIfPostCodeIsValid: (XLFormRowDescriptor *) rowDescriptor {
    if (rowDescriptor.value) {
        NSString *url = @"https://pd.homerehab.com.sg/addressFromPostalCode";
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
    return @"";
}


- (void) showHideMammogramSection {
    if (genderRow.value != (id)[NSNull null] && age40aboveRow.value != (id)[NSNull null]) {
        if ([genderRow.value containsString:@"F"] && [age40aboveRow.value isEqualToString:@"Yes"]) {
            mammoSection.hidden = @NO;
//            mammogramInterestRow.hidden = @NO;
//            hasChasRow.hidden = @NO;
//            doneB4Row.hidden = @NO;
        } else {
//            mammogramInterestRow.hidden = @YES;
//            hasChasRow.hidden = @YES;
//            doneB4Row.hidden = @YES;
            mammoSection.hidden = @YES;
        }
    }
//
//    [self reloadFormRow:mammogramInterestRow];
//    [self reloadFormRow:hasChasRow];
//    [self reloadFormRow:doneB4Row];
    

}
@end

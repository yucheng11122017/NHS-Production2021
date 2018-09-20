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
    XLFormRowDescriptor* dobRow;
    int successCounter, failCounter;
    NetworkStatus status;
    int fetchDataState;
    NSString *block, *street;
}

//@property (strong, nonatomic) NSMutableDictionary *resiPartiDict;
@property (strong, nonatomic) NSNumber *resident_id;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;

@end

@implementation ResidentParticularsVC

- (void)viewDidLoad {
    
    XLFormViewController *form;

    NSLog(@"Resident selected %@", _residentParticularsDict);
    NSLog(@"%@", _phlebEligibDict);
    NSLog(@"%@", _modeOfScreeningDict);
    
    neighbourhood = [[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    status = [reachability currentReachabilityStatus];
    [self processConnectionStatus];
    
    //must init first before [super viewDidLoad]
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
    nameRow.required = YES;
    nameRow.value = _residentParticularsDict[kName];
    [self setDefaultFontWithRow:nameRow];
    [nameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:nameRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    [self setDefaultFontWithRow:row];
    if ([_residentParticularsDict count] > 0) {
        if ([_residentParticularsDict[kGender] isEqualToString:@"M"])
            row.value = @"Male";
        else
            row.value = @"Female";
    }
    row.required = YES;
    [section addFormRow:row];
    
    
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
    
    dobRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBirthDate rowType:XLFormRowDescriptorTypeDateInline title:@"DOB"];
    dobRow.required = YES;

    if ([_residentParticularsDict count] > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  //otherwise 1st Jan will not be able to be read.
        NSDate *date = [dateFormatter dateFromString:_residentParticularsDict[kBirthDate]];
        dobRow.value = date;
    }
    [dobRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:dobRow];
    
    XLFormRowDescriptor *ageRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAge rowType:XLFormRowDescriptorTypeNumber title:@"Age (auto-calculated)"];
    [ageRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    ageRow.value = @"N/A";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *yearOfBirth = [dateFormatter stringFromDate:dobRow.value];
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
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
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
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Languages"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    [self setDefaultFontWithRow:spokenLangRow];
    spokenLangRow.required = YES;

    spokenLangRow.value = [self getSpokenLangArray:_residentParticularsDict];
    [section addFormRow:spokenLangRow];
    
    spokenLangRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
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
                        [self postSpokenLangWithLangName:[array firstObject] andValue:@"1"];
                    } else {
                        [oldSet minusSet:newSet];
                        NSArray *array = [oldSet allObjects];
                        [self postSpokenLangWithLangName:[array firstObject] andValue:@"0"];
                    }
                } else {
                    [self postSpokenLangWithLangName:[newValue firstObject] andValue:@"1"];
                }
            } else {
                if (oldValue != nil && oldValue != (id) [NSNull null]) {
                    [self postSpokenLangWithLangName:[oldValue firstObject] andValue:@"0"];
                }
            }
        }
    };
    
    XLFormRowDescriptor *writtenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWrittenLang rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Written Language"];
    writtenLangRow.required = YES;
    writtenLangRow.selectorOptions = @[@"English", @"Chinese", @"Malay", @"Tamil"];
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
        addressRow.selectorOptions = @[@"Blk 4 Beach Road", @"Blk 5 Beach Road", @"Blk 6 Beach Road", @"Blk 7 North Bridge Road", @"Blk 8 North Bridge Road", @"Blk 9 North Bridge Road", @"Blk 10 North Bridge Road", @"Blk 18 Jalan Sultan", @"Blk 19 Jalan Sultan", @"Others"];
    else
        addressRow.selectorOptions = @[@"Blk 55 Lengkok Bahru", @"Blk 56 Lengkok Bahru", @"Blk 57 Lengkok Bahru", @"Blk 58 Lengkok Bahru", @"Blk 59 Lengkok Bahru", @"Blk 61 Lengkok Bahru", @"Blk 3 Jalan Bukit Merah", @"Others"];
    [self setDefaultFontWithRow:addressRow];
    
    addressRow.value = [self getAddressFromStreetAndBlock];
    
    [section addFormRow:addressRow];
    
    addressRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            street = [self getStreetFromAddress:newValue];
            block  = [self getBlockFromAddress:newValue];
            
            if ([newValue containsString:@"Others"]) {
                //                addrOthersRow.required = YES;  //force to fill in address if selected 'Others'
            } else {
                //                addrOthersRow.required = NO;
            }
        }
    };
    
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
    
    
//    XLFormRowDescriptor *addressRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress rowType:XLFormRowDescriptorTypeSelectorPush title:@"Address"];
//    if ([neighbourhood isEqualToString:@"Kampong Glam"])
//        addressRow.selectorOptions = @[@"Blk 4 Beach Rd",@"Blk 5 Beach Rd",@"Blk 6 Beach Rd", @"Blk 7 North Bridge Rd", @"Blk 8 North Bridge Rd", @"Blk 9 North Bridge Rd", @"Blk 10 North Bridge Rd", @"Blk 18 Jln Sultan", @"Blk 19 Jln Sultan", @"Others"];
//    else
//        addressRow.selectorOptions = @[@"1 Eunos Crescent", @"2 Eunos Crescent", @"12 Eunos Crescent", @"2 Upper Aljunied Lane", @"3 Upper Aljunied Lane", @"4 Upper Aljunied Lane", @"5 Upper Aljunied Lane", @"Others"];
//    addressRow.value = [self getAddressFromStreetAndBlock];
//    addressRow.required = YES;
//    [self setDefaultFontWithRow:addressRow];
//    [section addFormRow:addressRow];
//    
//    addressRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//        if (newValue != oldValue) {
//            NSString *street = [self getStreetFromAddress:newValue];
//            NSString *block  = [self getBlockFromAddress:newValue];
//            
//            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kAddressStreet andNewContent:street];
//            double delayInSeconds = 1.0;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                //code to be executed on the main queue after delay
//                [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kAddressBlock andNewContent:block];
//            });
//            
//            if ([newValue containsString:@"Others"]) {
////                addrOthersRow.required = YES;  //force to fill in address if selected 'Others'
//            } else {
////                addrOthersRow.required = NO;
//            }
//        }
//    };
//    
//    XLFormRowDescriptor *unitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressUnitNum rowType:XLFormRowDescriptorTypeText title:@"Unit No"];
//    unitRow.value = _residentParticularsDict[kAddressUnitNum];
//    [self setDefaultFontWithRow:unitRow];
//    [unitRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    unitRow.required = YES;
//    [section addFormRow:unitRow];
//    
//    unitRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        
//        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
//            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
//            rowDescriptor.value = CAPSed;
//        }
//    };
//    
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressPostCode rowType:XLFormRowDescriptorTypePhone title:@"Postal Code"];
//    row.value = _residentParticularsDict[kAddressPostCode];
//    row.required = YES;
//    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    [self setDefaultFontWithRow:row];
//    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Postal Code must be 6 digits" regex:@"^(?=.*\\d).{6}$"]];
//    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Consent"];   /// NEW SECTION
    section.footerTitle = @"I consent to NHS directly disclosing the Information and my past screening and follow-up information (participant’s past screening and follow-up information under NHS’ Screening and Follow-Up Programme) to NHS’ collaborators (refer to organisations/institutions that work in partnership with NHS for the provision of screening and follow-up related services, such as but not limited to: MOH, HPB, Regional Health Systems, Senior Cluster Network Operators, etc. where necessary) for the purposes of checking if I require re-screening, further tests, follow-up action and/or referral to community programmes/activities.";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsent rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Consent to disclosure of information"];
    row.required = YES;
    if ([_residentParticularsDict objectForKey:kConsent] != (id)[NSNull null])
        row.value = [_residentParticularsDict objectForKey:kConsent];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Consent to Research"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentToResearch rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Consent to research"];
    row.required = YES;
    if ([_residentParticularsDict objectForKey:kConsentToResearch] != (id)[NSNull null])
        row.value = [_residentParticularsDict objectForKey:kConsentToResearch];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Phlebotomy Eligibility Assessment"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *wantFreeBtRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantFreeBt rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident want a free blood test?"];
    [self setDefaultFontWithRow:wantFreeBtRow];
    wantFreeBtRow.value = [self getYesNoFromOneZero:[_phlebEligibDict objectForKey:kWantFreeBt]];
    wantFreeBtRow.selectorOptions = @[@"Yes", @"No"];
    wantFreeBtRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:wantFreeBtRow];
    
    XLFormRowDescriptor *sporeanRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSporeanPr
                                                                            rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                              title:@"Singaporean?"];
    [self setDefaultFontWithRow:sporeanRow];
    sporeanRow.selectorOptions = @[@"Yes",@"No"];
    sporeanRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    sporeanRow.disabled = @1;
    
    [section addFormRow:sporeanRow];
    
    XLFormRowDescriptor *prRow = [XLFormRowDescriptor formRowDescriptorWithTag:kIsPr
                                                                       rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                         title:@"PR?"];
    [self setDefaultFontWithRow:prRow];
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
    
    XLFormRowDescriptor *age40aboveRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAgeCheck
                                                                               rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                 title:@"Age 40 and above?"];
    [self setDefaultFontWithRow:age40aboveRow];
    age40aboveRow.disabled = @YES;
    age40aboveRow.selectorOptions = @[@"Yes",@"No"];
    
    if (age >= 40) {
        age40aboveRow.value = @"Yes";
    } else {
        age40aboveRow.value = @"No";
    }
    
    __weak __typeof(self)weakSelf = self;
    dobRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            // Calculate age
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy"];
            NSString *yearOfBirth = [dateFormatter stringFromDate:newValue];
            NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
            NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
            NSLog(@"%li", (long)age);
            ageRow.value = [NSNumber numberWithLong:age];
            [weakSelf reloadFormRow:ageRow];
            
            if (age >= 40) {
                age40aboveRow.value = @"Yes";
                age40aboveRow.disabled = @YES;
                [weakSelf updateFormRow:age40aboveRow];
            } else {
                age40aboveRow.value = @"No";
                age40aboveRow.disabled = @YES;
                [weakSelf updateFormRow:age40aboveRow];
            }
        }
    };
    
    age40aboveRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:age40aboveRow];
    
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
    
    XLFormRowDescriptor *eligibleBTRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"eligible_BT"
                                                                               rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                                                 title:@"Is resident eligible for a blood test? (auto-calculated)"];
    [self setDefaultFontWithRow:eligibleBTRow];
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
                if (([dict objectForKey:kChronicCond] == (id)[NSNull null] && [dict objectForKey:kRegFollowup] == (id)[NSNull null])|| [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                if (([[dict objectForKey:kChronicCond] isEqualToString:@"No"] || [[dict objectForKey:kRegFollowup] isEqualToString:@"No"])&& ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"]||[[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) && [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] && [[dict objectForKey:kNoBloodTest] isEqualToString:@"No"]) {
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
                if ([[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"] && ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"]||[[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) && [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] && [[dict objectForKey:kNoBloodTest] isEqualToString:@"No"]) {
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
    
    noFollowUpPcpRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"No"]) {
                NSDictionary *dict =  [self.form formValues];
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                if ([[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"] && ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"]||[[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) && [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] && [[dict objectForKey:kNoBloodTest] isEqualToString:@"No"]) {
                    eligibleBTRow.value = @"Yes";
                } else {
                    eligibleBTRow.value = @"No";
                }
                [self reloadFormRow:eligibleBTRow];
            } else {
                if ([chronicCondRow.value isEqualToString:@"Yes"]) {  //if both are false
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                }
            }
            
        }
    };
    
    noBloodTestRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                NSDictionary *dict =  [self.form formValues];
                
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kChronicCond] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                
                if ([[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"] && ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"]||[[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) && [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] && [[dict objectForKey:kChronicCond] isEqualToString:@"True"]) {
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
    didPhlebRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:didPhlebRow];
    
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
    
    XLFormRowDescriptor *centralDateQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"central_date_q" rowType:XLFormRowDescriptorTypeInfo title:@"Which date will the resident be coming down (centralised)?"];
    centralDateQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    centralDateQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Centralised'", screenModeRow];
    [self setDefaultFontWithRow:centralDateQRow];
    [section addFormRow:centralDateQRow];
    
    XLFormRowDescriptor* centralDateRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCentralDate rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    centralDateRow.noValueDisplayText = @"Tap here";
    centralDateRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:centralDateRow];
    
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        centralDateRow.selectorOptions = @[@"8 Sept", @"9 Sept"];
    } else {
        centralDateRow.selectorOptions = @[@"6 Oct (Lengkok Bahru)", @"7 Oct (3 Jalan Bukit Merah)"];
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
        apptDateRow.selectorOptions = @[@"8 Sept", @"9 Sept"];
    } else {
        apptDateRow.selectorOptions = @[@"6 Oct (Lengkok Bahru)", @"7 Oct (3 Jalan Bukit Merah)"];
    }
    apptDateRow.noValueDisplayText = @"Tap here";
    apptDateRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
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
        phlebApptRow.selectorOptions = @[@"8 Sept", @"9 Sept"];
    } else {
        phlebApptRow.selectorOptions = @[@"6 Oct (Lengkok Bahru)", @"7 Oct (3 Jalan Bukit Merah)"];
    }
    phlebApptRow.noValueDisplayText = @"Tap here";
    phlebApptRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
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
                if ([eligibleBTRow.value isEqualToString:@"No"]) {
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
//    else if ([rowDescriptor.tag isEqualToString:kAddressOthers]) {
//        NSString *CAPSed = [rowDescriptor.value uppercaseString];
//        rowDescriptor.value = CAPSed;
//        [self reloadFormRow:rowDescriptor];
//        //no return here...
//    }
    
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
            NSString *birthDate = [self getDateStringFromFormValue:rowDescriptor.value];
            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:birthDate];
            return;
        } else if (rowDescriptor.tag == kNotes) {
            [self postSingleFieldWithSection:SECTION_MODE_OF_SCREENING andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
            return;
        }
        
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
    }
}

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    NSString* ansFromGender;
    
    
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Male"])
            ansFromGender = @"M";
        else if ([newValue isEqualToString:@"Female"])
            ansFromGender = @"F";
    }
    
    if ([rowDescriptor.tag isEqualToString:kGender]) {
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kGender andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kConsent]) {
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kConsent andNewContent:newValue];
    }
    else if ([rowDescriptor.tag isEqualToString:kConsentToResearch]) {
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kConsentToResearch andNewContent:newValue];
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
    else if ([rowDescriptor.tag isEqualToString:kDidPhleb]) {
        [self postSingleFieldWithSection:SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT andFieldName:kDidPhleb andNewContent:newValue];
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

- (NSString *) getDateStringFromFormValue: (NSDate *) date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

- (NSString *) getEthnicityString: (NSString *) number {
    NSArray *array = @[@"Chinese", @"Indian", @"Malay", @"Others"];
    return [array objectAtIndex:[number integerValue]];
}

- (NSString *) getMaritalStatusString: (NSString *) number {
    NSArray *array = @[@"Divorced", @"Married", @"Separated", @"Single", @"Widowed"];
    return [array objectAtIndex:[number integerValue]];
}

- (NSString *) getHighestEduLvlString: (NSString *) number {
    NSArray *array = @[@"ITE/Pre-U/JC", @"No formal qualifications", @"Primary", @"Secondary", @"University"];
    return [array objectAtIndex:[number integerValue]];
}

- (NSString *) getBlockFromAddress: (NSString *) string {
    
    NSMutableString *subString;
    NSString* result;
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        subString = [[string substringWithRange:NSMakeRange(0, 6)] mutableCopy];
        result = [subString stringByReplacingOccurrencesOfString:@"Blk " withString:@""];
    } else
        result = [string substringWithRange:NSMakeRange(0, 2)];
    
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
        if ([string containsString:@"Eunos"]) return @"Eunos Crescent";
        else if ([string containsString:@"Aljunied"]) return @"Upper Aljunied Lane";
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
        
        return [NSString stringWithFormat:@"Blk %@ %@", block, street];
        
    }
    return @"";
}

- (NSArray *) getSpokenLangArray: (NSDictionary *) dictionary {
    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];

    if([[dictionary objectForKey:kLangCanto] isEqual:@(1)]) [spokenLangArray addObject:@"Cantonese"];
    if([[dictionary objectForKey:kLangEng] isEqual:@(1)]) [spokenLangArray addObject:@"English"];
    if([[dictionary objectForKey:kLangHindi] isEqual:@(1)]) [spokenLangArray addObject:@"Hindi"];
    if([[dictionary objectForKey:kLangHokkien] isEqual:@(1)]) [spokenLangArray addObject:@"Hokkien"];
    if([[dictionary objectForKey:kLangMalay] isEqual:@(1)]) [spokenLangArray addObject:@"Malay"];
    if([[dictionary objectForKey:kLangMandarin] isEqual:@(1)]) [spokenLangArray addObject:@"Mandarin"];
    if([[dictionary objectForKey:kLangOthers] isEqual:@(1)]) [spokenLangArray addObject:@"Others"];
    if([[dictionary objectForKey:kLangTamil] isEqual:@(1)]) [spokenLangArray addObject:@"Tamil"];
    if([[dictionary objectForKey:kLangTeoChew] isEqual:@(1)]) [spokenLangArray addObject:@"Teochew"];
    return spokenLangArray;
}

- (NSString *) getTimeNowInString {
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    return [localDateTime description];
}

//- (NSString *) getHousingOwnedRentedFromTwoValues {
//
//    if (_residentParticularsDict[kHousingNumRooms] != (id) [NSNull null]) { //got some value
//        NSString *numRooms = _residentParticularsDict[kHousingNumRooms];
//        NSString *housingType = _residentParticularsDict[kHousingType];
//
//        if (housingType == (id)[NSNull null] || housingType == nil)     //don't continue
//            return @"";
//
//        if (![housingType isEqualToString:@"Private"])
//            return [NSString stringWithFormat:@"%@, %@-room", housingType, numRooms];
//        else
//            return @"Private";
//    }
//    return @"";
//}

- (void) postSpokenLangWithLangName:(NSString *) language andValue: (NSString *) value {
    NSString *fieldName;
    if ([language isEqualToString:@"Cantonese"]) fieldName = kLangCanto;
    else if ([language isEqualToString:@"English"]) fieldName = kLangEng;
    else if ([language isEqualToString:@"Hindi"]) fieldName = kLangHindi;
    else if ([language isEqualToString:@"Hokkien"]) fieldName = kLangHokkien;
    else if ([language isEqualToString:@"Malay"]) fieldName = kLangMalay;
    else if ([language isEqualToString:@"Mandarin"]) fieldName = kLangMandarin;
    else if ([language isEqualToString:@"Tamil"]) fieldName = kLangTamil;
    else if ([language isEqualToString:@"Teochew"]) fieldName = kLangTeoChew;
    else if ([language isEqualToString:@"Others"]) fieldName = kLangOthers;
    
    [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:fieldName andNewContent:value];
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

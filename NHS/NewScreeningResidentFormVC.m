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

//XLForms stuffs
#import "XLForm.h"


#define RESI_PART_SECTION @"resi_particulars"


@interface NewScreeningResidentFormVC () {
    NSString *neighbourhood;
    NetworkStatus status;
    XLFormRowDescriptor *dobRow;
    NSString *block, *street;
}

@property (strong, nonatomic) NSNumber *resident_id;

@end

@implementation NewScreeningResidentFormVC

- (void)viewDidLoad {
    
    XLFormViewController *form;
    
    
    neighbourhood = [[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    status = [reachability currentReachabilityStatus];
    [self processConnectionStatus];
    
    //must init first before [super viewDidLoad]
    form = [self initNewResidentForm];
    
    [self.form setAddAsteriskToRequiredRowsTitle: YES];
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitBtnPressed:)];
    
    [super viewDidLoad];

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
    nameRow.required = YES;
    [self setDefaultFontWithRow:nameRow];
    [nameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:nameRow];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"Only Singaporeans/PRs (with a valid NRIC/FIN) are eligible for screening.";
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *nricRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeName title:@"NRIC"];
    nricRow.required = YES;
    [nricRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:nricRow];
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
    
    dobRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBirthDate rowType:XLFormRowDescriptorTypeDate title:@"DOB"];
    dobRow.required = YES;
    [self setDefaultFontWithRow:dobRow];
    [section addFormRow:dobRow];
    
    XLFormRowDescriptor *ageRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAge rowType:XLFormRowDescriptorTypeNumber title:@"Age (auto-calculated)"];
    [ageRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    ageRow.value = @"N/A";
    ageRow.disabled = @1;
    [self setDefaultFontWithRow:ageRow];
    [section addFormRow:ageRow];
    
    XLFormRowDescriptor *citizenshipRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCitizenship rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Citizenship status"];
    citizenshipRow.required = YES;
    citizenshipRow.selectorOptions = @[@"Singaporean", @"PR", @"Foreigner"];
    [self setDefaultFontWithRow:citizenshipRow];
    [section addFormRow:citizenshipRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    section.footerTitle = @"Please input 00000000 if the resident has no number available.";
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHpNumber rowType:XLFormRowDescriptorTypePhone title:@"HP Number"];
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
    row.selectorOptions = @[@"Son", @"Daughter", @"Nephew", @"Niece", @"Father", @"Mother", @"Uncle", @"Aunt", @"Other", @"Nil"];
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
    [section addFormRow:row];
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Languages"];
    spokenLangRow.selectorOptions = @[@"English", @"Mandarin", @"Malay", @"Tamil", @"Hindi", @"Cantonese", @"Hokkien", @"Teochew"];
    [self setDefaultFontWithRow:spokenLangRow];
    spokenLangRow.required = YES;
    [section addFormRow:spokenLangRow];
    
    XLFormRowDescriptor *writtenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWrittenLang rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Written Language"];
    writtenLangRow.required = YES;
    writtenLangRow.selectorOptions = @[@"English", @"Chinese", @"Malay", @"Tamil"];
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
        addressRow.selectorOptions = @[@"Blk 4 Beach Road", @"Blk 5 Beach Road", @"Blk 6 Beach Road", @"Blk 7 North Bridge Road", @"Blk 8 North Bridge Road", @"Blk 9 North Bridge Road", @"Blk 10 North Bridge Road", @"Blk 18 Jalan Sultan", @"Blk 19 Jalan Sultan", @"Others"];
    else
        addressRow.selectorOptions = @[@"Blk 55 Lengkok Bahru", @"Blk 56 Lengkok Bahru", @"Blk 57 Lengkok Bahru", @"Blk 58 Lengkok Bahru", @"Blk 59 Lengkok Bahru", @"Blk 61 Lengkok Bahru", @"Blk 3 Jalan Bukit Merah", @"Others"];
    [self setDefaultFontWithRow:addressRow];
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
    [section addFormRow:addressOthersBlock];
    
    XLFormRowDescriptor *addressOthersRoadName = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressOthersRoadName rowType:XLFormRowDescriptorTypeText title:@"Address (Others)-Road Name"];
    addressOthersRoadName.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", addressRow];
    [addressOthersRoadName.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:addressOthersRoadName];
    [section addFormRow:addressOthersRoadName];
    
    
    XLFormRowDescriptor *unitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressUnitNum rowType:XLFormRowDescriptorTypeText title:@"Unit No"];
    [self setDefaultFontWithRow:unitRow];
    [unitRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    unitRow.required = YES;
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
    section.footerTitle = @"I consent to NHS directly disclosing the Information and my past screening and follow-up information (participant’s past screening and follow-up information under NHS’ Screening and Follow-Up Programme) to NHS’ collaborators (refer to organisations/institutions that work in partnership with NHS for the provision of screening and follow-up related services, such as but not limited to: MOH, HPB, Regional Health Systems, Senior Cluster Network Operators, etc. where necessary) for the purposes of checking if I require re-screening, further tests, follow-up action and/or referral to community programmes/activities.";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsent rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Consent to disclosure of information"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Consent to Research"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kConsentToResearch rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Consent to research"];
    row.required = NO;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Phlebotomy Eligibility Assessment"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *wantFreeBtRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWantFreeBt rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident want a free blood test?"];
    [self setDefaultFontWithRow:wantFreeBtRow];
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
    
    chronicCondRow = [XLFormRowDescriptor formRowDescriptorWithTag:kChronicCond rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Resident has no previously diagnosed chronic condition"];
    chronicCondRow.required = YES;
    chronicCondRow.selectorOptions = @[@"True", @"False"];
    [self setDefaultFontWithRow:chronicCondRow];
    chronicCondRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:chronicCondRow];
    
    XLFormRowDescriptor *noFollowUpPcpRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"no_follow_up_pcp" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"But resident is not under regular follow-up with primary care physician"];
    noFollowUpPcpRow.required = YES;
    noFollowUpPcpRow.selectorOptions = @[@"True", @"False"];
    [self setDefaultFontWithRow:noFollowUpPcpRow];
    noFollowUpPcpRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    noFollowUpPcpRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'False'", chronicCondRow];
    [section addFormRow:noFollowUpPcpRow];
    
    XLFormRowDescriptor *noBloodTestRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNoBloodTest
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Have not taken a blood test in the past 3 years?"];
    [self setDefaultFontWithRow:noBloodTestRow];
    noBloodTestRow.selectorOptions = @[@"Yes",@"No"];
    noBloodTestRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:noBloodTestRow];
    
    XLFormRowDescriptor *eligibleBTRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"eligible_BT"
                                                rowType:XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title:@"Is resident eligible for a blood test? (auto-calculated)"];
    [self setDefaultFontWithRow:eligibleBTRow];
    eligibleBTRow.disabled = @YES;
    eligibleBTRow.selectorOptions = @[@"Yes",@"No"];
    eligibleBTRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:eligibleBTRow];
    
    wantFreeBtRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"Yes"]) {
                NSDictionary *dict =  [self.form formValues];
                if (([dict objectForKey:kChronicCond] == (id)[NSNull null] && [dict objectForKey:@"no_follow_up_pcp"] == (id)[NSNull null])|| [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                if (([[dict objectForKey:kChronicCond] isEqualToString:@"True"] || [[dict objectForKey:@"no_follow_up_pcp"] isEqualToString:@"True"])&& ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"]||[[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) && [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] && [[dict objectForKey:kNoBloodTest] isEqualToString:@"Yes"]) {
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
            if ([newValue isEqualToString:@"True"]) {
                NSDictionary *dict =  [self.form formValues];
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                if ([[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"] && ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"]||[[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) && [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] && [[dict objectForKey:kNoBloodTest] isEqualToString:@"Yes"]) {
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
            if ([newValue isEqualToString:@"True"]) {
                NSDictionary *dict =  [self.form formValues];
                if ([dict objectForKey:kWantFreeBt] == (id)[NSNull null] || [dict objectForKey:kSporeanPr] == (id)[NSNull null] || [dict objectForKey:kIsPr] == (id)[NSNull null] || [dict objectForKey:kAgeCheck] == (id)[NSNull null] || [dict objectForKey:kNoBloodTest] == (id)[NSNull null]) {
                    eligibleBTRow.value = @"No";
                    [self reloadFormRow:eligibleBTRow];
                    return;
                }
                if ([[dict objectForKey:kWantFreeBt] isEqualToString:@"Yes"] && ([[dict objectForKey:kSporeanPr] isEqualToString:@"Yes"]||[[dict objectForKey:kIsPr] isEqualToString:@"Yes"]) && [[dict objectForKey:kAgeCheck] isEqualToString:@"Yes"] && [[dict objectForKey:kNoBloodTest] isEqualToString:@"Yes"]) {
                    eligibleBTRow.value = @"Yes";
                } else {
                    eligibleBTRow.value = @"No";
                }
                [self reloadFormRow:eligibleBTRow];
            } else {
                if ([chronicCondRow.value isEqualToString:@"False"]) {  //if both are false
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
    if (![isComm boolValue]) didPhlebQRow.disabled = @YES;  //if it's not Comms, then disable this.
    [self setDefaultFontWithRow:didPhlebQRow];
    [section addFormRow:didPhlebQRow];
    
    XLFormRowDescriptor *didPhlebRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDidPhleb rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    [self setDefaultFontWithRow:didPhlebRow];
    if (![isComm boolValue]) didPhlebRow.disabled = @YES;  //if it's not Comms, then disable this.
    didPhlebRow.selectorOptions = @[@"No, not at all", @"Yes, Saturday", @"Yes, Sunday", @"No, referred to next Saturday", @"Yes, additional session"];
    didPhlebRow.value = @"No, not at all";
    didPhlebRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:didPhlebRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mode of Screening"];   /// NEW SECTION
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *screenModeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kScreenMode rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Pick one"];
    screenModeRow.selectorOptions = @[@"Centralised", @"Door-to-door"];
    screenModeRow.required = YES;
    [self setDefaultFontWithRow:screenModeRow];
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
    [section addFormRow:apptDateRow];
    
    XLFormRowDescriptor *phlebApptQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"phleb_appt_q" rowType:XLFormRowDescriptorTypeInfo title:@"Phleb door-to-door Date (only available from 9-11am)"];
    phlebApptQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    phlebApptQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Door-to-door'", screenModeRow];
    [self setDefaultFontWithRow:phlebApptQRow];
    [section addFormRow:phlebApptQRow];
    
    XLFormRowDescriptor *phlebApptRow = [XLFormRowDescriptor formRowDescriptorWithTag:kApptDate rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@""];
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        phlebApptRow.selectorOptions = @[@"8 Sept", @"9 Sept"];
    } else {
        phlebApptRow.selectorOptions = @[@"6 Oct (Lengkok Bahru)", @"7 Oct (3 Jalan Bukit Merah)"];
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
    
//    XLFormRowDescriptor *phlebApptRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhlebAppt rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Phlebotomy Appointment"];
//    phlebApptRow.required = NO;
//
//    if ([screenModeRow.value isEqualToString:@"Door-to-door"] && qualifyPhleb)
//        phlebApptRow.disabled = @0;
//    else
//        phlebApptRow.disabled = @1;
//
//
//    if ([neighbourhood isEqualToString:@"Eunos Crescent"]) {
//        phlebApptRow.selectorOptions = @[@"9 Sept, 8-11am", @"10 Sept, 8-11am"];
//    } else {
//        phlebApptRow.selectorOptions = @[@"7 Oct, 8-11am", @"8 Oct, 8-11am"];
//    }
//    phlebApptRow.noValueDisplayText = @"Tap here";
//    [self setDefaultFontWithRow:phlebApptRow];
//    [section addFormRow:phlebApptRow];
//
//    if (screenModeRow.value != (id)[NSNull null] && screeningDateRow.value != (id)[NSNull null]) {
//        if ([screenModeRow.value isEqualToString:@"Centralised"] && [screeningDateRow.value isEqualToString:@"7 Oct"]) {       // 2 initial conditions to fulfill
//            //            ticketNumRow.hidden = @NO;
//            //            ticketNumRow.required = YES;
//
//            phlebApptRow.selectorOptions = @[@"7 Oct, 7-7.45am", @"7 Oct, 7.45-8.15am", @"8 Oct, 8-11am"];
//
//            if (qualifyPhleb) {
//                phlebApptRow.disabled = @NO;
//                phlebApptRow.required = YES;
//            }
//        }
//    }
//
//    screenModeRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//        if (newValue != oldValue) {
//
//            if ([newValue isEqualToString:@"Door-to-door"] && qualifyPhleb) {    //need to be door-to-door and qualify for phleb too!
//
//                if ([neighbourhood containsString:@"Kampong"]) {
//                    phlebApptRow.selectorOptions = @[@"7 Oct, 8-11am", @"8 Oct, 8-11am"];
//                }
//                phlebApptRow.disabled = @0;
//                phlebApptRow.required = YES;
//            } else if ([newValue isEqualToString:@"Door-to-door"]) {
//                d2dTimeRow.required = YES;
//            }
//            else {
//                phlebApptRow.disabled = @1;
//                phlebApptRow.required = NO;
//            }
//
//            if ([newValue isEqualToString:@"Centralised"] && (screeningDateRow.value != (id) [NSNull null]) && [screeningDateRow.value isEqualToString:@"7 Oct"]) {
//                //                ticketNumRow.hidden = @NO;
//                //                ticketNumRow.required = YES;
//
//                if ([neighbourhood containsString:@"Kampong"]) {
//                    phlebApptRow.selectorOptions = @[@"7 Oct, 7-7.45am", @"7 Oct, 7.45-8.15am", @"8 Oct, 8-11am"];
//                }
//
//                if (qualifyPhleb) {  //3rd condition need to be met too!
//                    phlebApptRow.disabled = @NO;
//                    phlebApptRow.required = YES;
//                } else {
//                    phlebApptRow.disabled = @YES;
//                    phlebApptRow.required = NO;
//                }
//            } else if ([newValue isEqualToString:@"Centralised"]) {
//                d2dTimeRow.required = NO;
//            }
//            else {    // if the above 2 conditions are not met
//                //                ticketNumRow.hidden = @YES;
//                //                ticketNumRow.required = NO;
//            }
//            [self reloadFormRow:phlebApptRow];
//            //            [self reloadFormRow:ticketNumRow];
//        }
//    };
//
//    screeningDateRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//        if (newValue != oldValue) {
//            if (newValue != nil && newValue != (id) [NSNull null]) {
//                if ([newValue isEqualToString:@"7 Oct"]) {
//
//                    d2dTimeRow.selectorOptions = @[@"10am-12pm", @"12pm-2pm", @"2pm-4pm"];
//
//                    if ([screenModeRow.value isEqualToString:@"Centralised"]) {
//
//                        if ([neighbourhood containsString:@"Kampong"]) {
//                            phlebApptRow.selectorOptions = @[@"7 Oct, 7-7.45am", @"7 Oct, 7.45-8.15am", @"8 Oct, 8-11am"];
//                            //                            ticketNumRow.hidden = @NO;
//                            //                            ticketNumRow.required = YES;
//                        }
//
//                        if (qualifyPhleb) {
//                            phlebApptRow.disabled = @NO;
//                            phlebApptRow.required = YES;
//                        } else {
//                            phlebApptRow.disabled = @YES;
//                            phlebApptRow.required = NO;
//                        }
//                    } else {    // Door-to-door (7th October)
//                        //                        ticketNumRow.hidden = @YES;
//                        //                        ticketNumRow.required = NO;
//                    }
//
//                } else if ([newValue isEqualToString:@"8 Oct"]) {
//
//                    if ([neighbourhood containsString:@"Kampong"]) {
//                        phlebApptRow.selectorOptions = @[@"7 Oct, 8-11am", @"8 Oct, 8-11am"];
//                        d2dTimeRow.selectorOptions = @[@"8am-10am", @"10am-12pm", @"12pm-2pm", @"2pm-4pm"];
//                        //                        ticketNumRow.hidden = @YES;
//                        //                        ticketNumRow.required = NO;
//
//                        if ([screenModeRow.value isEqualToString:@"Centralised"]) {
//                            phlebApptRow.disabled = @YES;
//                            phlebApptRow.required = NO;
//                        }
//                    }
//                }
//                //                [self updateFormRow:ticketNumRow];
//                [self updateFormRow:d2dTimeRow];
//                [self updateFormRow:phlebApptRow];
//            }
//        }
//    };
    
    

    return [super initWithForm:formDescriptor];
}

#pragma mark - XLFormViewControllerDelegate
-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {
    
    if ([rowDescriptor.tag isEqualToString:kBirthDate] ) {
        return;
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
        
        
        NSString *url = @"https://nhs-som.nus.edu.sg/isNricValid";
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
        NSDictionary *fields = [self.form formValues];
        NSString *name, *nric, *gender, *birthDate;
        
        if ([fields objectForKey:kGender] != [NSNull null]) {
            if ([[fields objectForKey:kGender] isEqualToString:@"Male"]) {
                //            [resi_particulars setObject:@"M" forKey:kGender];
                gender = @"M";
            } else if ([[fields objectForKey:kGender] isEqualToString:@"Female"]) {
                gender = @"F";
                //            [resi_particulars setObject:@"F" forKey:kGender];
            }
        }
        NSString *CAPSed = [fields[kName] uppercaseString];
        name = CAPSed;
        
//        name = fields[kName];
        nric = fields[kNRIC];
        
        birthDate = [self getDateStringFromFormValue:fields andRowTag:kBirthDate];
        
        NSString *timeNow = [self getTimeNowInString];
        
        NSString *unitNo = [fields objectForKey:kAddressUnitNum];
        unitNo = [unitNo stringByReplacingOccurrencesOfString:@"#" withString:@""]; //remove the '#' from the String
        
        NSLog(@"Registering new resident...");
        NSDictionary *dict = @{kName:name,
                               kNRIC:nric,
                               kGender:gender,
                               kBirthDate:birthDate,
                               kCitizenship:[fields objectForKey:kCitizenship],
                               kHpNumber: [fields objectForKey:kHpNumber],
                               kHouseNumber: [fields objectForKey:kHouseNumber],
                               kNokName: [fields objectForKey:kNokName],
                               kNokRelationship: [fields objectForKey:kNokRelationship],
                               kNokContact: [fields objectForKey:kNokContact],
                               kEthnicity: [fields objectForKey:kEthnicity],
                               //skip language for now
                               kWrittenLang: [fields objectForKey:kWrittenLang],
                               kAddressBlock: block,
                               kAddressStreet: street,
                               kAddressUnitNum: unitNo,
                               kAddressPostCode: [fields objectForKey:kAddressPostCode],
                               kConsent: [fields objectForKey:kConsent],
                               kConsentToResearch: [fields objectForKey:kConsentToResearch],
                               kTimestamp:timeNow,
                               kScreenLocation:neighbourhood};
        
        dict = [self addLangFieldsIfAny:dict];
        
        NSDictionary *dict2 = @{kWantFreeBt:[self getOneZerofromYesNo:[fields objectForKey:kWantFreeBt]],
                                kSporeanPr:[self getOneZerofromYesNo:[fields objectForKey:kSporeanPr]],
                                kIsPr:[self getOneZerofromYesNo:[fields objectForKey:kIsPr]],
                                kAgeCheck:[self getOneZerofromYesNo:[fields objectForKey:kAgeCheck]],
                                kChronicCond:[self getOneZerofromYesNo:[fields objectForKey:kChronicCond]],
                                kNoBloodTest:[self getOneZerofromYesNo:[fields objectForKey:kNoBloodTest]],
                                kDidPhleb:[fields objectForKey:kDidPhleb]
                                };
        NSDictionary *finalDict = @{@"resi_particulars": dict,
                                    @"phlebotomy_eligibility_assmt": dict2};
        
        [self submitNewResidentEntry:finalDict];

    }
}

-(void)cancelPressed:(UIBarButtonItem * __unused)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *) getDateStringFromFormValue: (NSDictionary *) formValues andRowTag: (NSString *) rowTag {
    NSDate *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    date = [formValues objectForKey:rowTag];
    return [dateFormatter stringFromDate:date];
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


#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"POST in progress...");
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))personalInfoSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"Personal info submission success");
        
        if ([responseObject objectForKey:@"reason"]) {  //if it's not nil (which means there's duplicates)
            [SVProgressHUD setMinimumDismissTimeInterval:1.0];
            [SVProgressHUD showErrorWithStatus:@"This NRIC is already registered!"];
            return;
        }
        
        self.resident_id = [responseObject objectForKey:kResidentId];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.resident_id forKey:kResidentId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"I'm resident %@", self.resident_id);
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshScreeningResidentTable"
                                                                object:self
                                                              userInfo:@{kResidentId:self.resident_id}];
        }];
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
        else if ([string containsString:@"Bukit"]) return @"Jalan Bukit Merah";
        else return @"Others";
    }
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
    
//    [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:fieldName andNewContent:value];
}

- (NSDictionary *) addLangFieldsIfAny: (NSDictionary *) dict {
    
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] init];
    mutDict = [dict mutableCopy];
    
    NSArray *languageArr = [[self.form formValues] objectForKey:kSpokenLang];
    
    if (languageArr != nil && [languageArr count] > 0) {
        if ([languageArr containsObject:@"Cantonese"]) [mutDict setObject:@"1" forKey:kLangCanto];
        if ([languageArr containsObject:@"English"]) [mutDict setObject:@"1" forKey:kLangEng];
        if ([languageArr containsObject:@"Hindi"]) [mutDict setObject:@"1" forKey:kLangHindi];
        if ([languageArr containsObject:@"Hokkien"]) [mutDict setObject:@"1" forKey:kLangHokkien];
        if ([languageArr containsObject:@"Malay"]) [mutDict setObject:@"1" forKey:kLangMalay];
        if ([languageArr containsObject:@"Mandarin"]) [mutDict setObject:@"1" forKey:kLangMandarin];
        if ([languageArr containsObject:@"Tamil"]) [mutDict setObject:@"1" forKey:kLangTamil];
        if ([languageArr containsObject:@"Teochew"]) [mutDict setObject:@"1" forKey:kLangTeoChew];
    }
    
    return mutDict;
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
    return @"0";
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

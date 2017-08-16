//
//  ResidentParticularsVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/4/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "ResidentParticularsVC.h"
#import "ServerComm.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"

//XLForms stuffs
#import "XLForm.h"

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"


//[row.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.7] forKey:XLFormTextFieldLengthPercentage];      //for changing the answer's fontSize


@interface ResidentParticularsVC () {
    NSString *neighbourhood;
    XLFormRowDescriptor* dobRow;
}

@end

@implementation ResidentParticularsVC

- (void)viewDidLoad {
    
    XLFormViewController *form;
    
    neighbourhood = @"KGL"; //fixed for now
    NSLog(@"Resident selected %@", _residentParticularsDict);
    //    form = [self initModeOfScreening];
    
    //must init first before [super viewDidLoad]
    form = [self initResidentParticularsForm];
    [self.form setAddAsteriskToRequiredRowsTitle: YES];
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated {
//    [self saveEntriesIntoDictionary];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFullScreeningForm"
//                                                        object:nil
//                                                      userInfo:self.fullScreeningForm];
//    NSMutableDictionary *completionCheckUserInfo = [[NSMutableDictionary alloc] init];
//    [completionCheckUserInfo setObject:self.sectionID forKey:@"section"];
//    //Do a quick validation!
//    NSArray * validationErrors = [self formValidationErrors];
//    if (validationErrors.count > 0){
//        [completionCheckUserInfo setObject:@0 forKey:@"value"];
//    } else {
//        [completionCheckUserInfo setObject:@1 forKey:@"value"];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCompletionCheck"
//                                                        object:nil
//                                                      userInfo:completionCheckUserInfo];
    
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
    XLFormRowDescriptor *nameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeName title:@"Patient Name"];
    nameRow.required = YES;
    nameRow.value = _residentParticularsDict[kName];
    [nameRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [nameRow.cellConfig setObject:[UIFont fontWithName:@"Helvetica" size:14] forKey:@"textField.font"];
    [nameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    [nameRow.cellConfigAtConfigure setObject:[NSNumber numberWithFloat:0.7] forKey:XLFormTextFieldLengthPercentage];      //for changing the length of the left side TextLabel
    [section addFormRow:nameRow];
    
    nameRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
            rowDescriptor.value = CAPSed;
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    if ([_residentParticularsDict[kGender] isEqualToString:@"M"])
        row.value = @"Male";
    else
        row.value = @"Female";
        
    
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
//    NSString *genderMF = [resiPartiDict objectForKey:@"gender"];
//    if ([genderMF isEqualToString:@"M"]) {
//        row.value = @"Male";
//    } else if ([genderMF isEqualToString:@"F"]) {
//        row.value = @"Female";
//    }
    row.required = YES;
    [section addFormRow:row];
    
    XLFormRowDescriptor *nricRow = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeName title:@"NRIC"];
    nricRow.required = YES;
    nricRow.value = _residentParticularsDict[kNRIC];
    [nricRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [nricRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:nricRow];
    
    nricRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
            rowDescriptor.value = CAPSed;
        }
    };
    
    dobRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBirthDate rowType:XLFormRowDescriptorTypeDateInline title:@"DOB"];
    dobRow.required = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    NSDate *date = [dateFormatter dateFromString:_residentParticularsDict[kBirthDate]];
    dobRow.value = date;
    [dobRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:dobRow];
    
    dobRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSLog(@"%@", newValue);
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"button" rowType:XLFormRowDescriptorTypeButton title:@"Calculate Age!"];
    row.action.formSelector = @selector(calculateAge:);
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCitizenship rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Citizenship Status"];
    row.required = YES;
    row.value = _residentParticularsDict[kCitizenship];
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    row.selectorOptions = @[@"Singaporean", @"PR", @"Foreigner", @"Stateless"];
    [section addFormRow:row];
    
    XLFormRowDescriptor *religionRow;
    religionRow = [XLFormRowDescriptor formRowDescriptorWithTag:kReligion rowType:XLFormRowDescriptorTypeSelectorPush title:@"Religion"];
    religionRow.selectorOptions = @[@"Buddhism", @"Taoism", @"Islam", @"Christianity", @"Hinduism", @"No Religion", @"Others"];
    [religionRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    religionRow.required = YES;
    [section addFormRow:religionRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"religion_others" rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", religionRow];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHpNumber rowType:XLFormRowDescriptorTypePhone title:@"HP Number"];
    row.required = YES;
//    row.value = [resiPartiDict objectForKey:@"contact_no"];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseNumber rowType:XLFormRowDescriptorTypePhone title:@"House Phone Number"];
    row.required = YES;
//    row.value = [resiPartiDict objectForKey:@"contact_no2"];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number(2) must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEthnicity rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Ethnicity"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Chinese"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Indian"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Malay"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Others"]
                            ];
    row.required = NO;
    row.noValueDisplayText = @"Tap here for options";
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
//    if ([[resiPartiDict objectForKey:@"ethnicity_id"] isEqualToString:@""]) {
//        
//    } else {
//        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"ethnicity_id"] integerValue]] ;
//    }
    [section addFormRow:row];
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    [spokenLangRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    row.required = YES;

//    spokenLangRow.value = [self getSpokenLangArray:resiPartiDict];
//        spokenLangRow.value = spoken_lang_value? spoken_lang_value:@[];
    [section addFormRow:spokenLangRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLangOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", spokenLangRow];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
//    row.value = [resiPartiDict objectForKey:@"lang_others_text"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMaritalStatus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Marital Status"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Divorced"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Married"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Separated"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Single"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Widowed"]
                            ];
//    if ([[resiPartiDict objectForKey:@"marital_status"] isEqualToString:@""]) {
//        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Single"];   //default value
//    } else {
//        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"marital_status"] integerValue]] ;
//    }
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    row.noValueDisplayText = @"Tap here";
    row.required = NO;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHousingOwnedRented rowType:XLFormRowDescriptorTypeSelectorPush title:@"Housing Type"];
    row.selectorOptions = @[@"Owned, 1-room", @"Owned, 2-room", @"Owned, 3-room", @"Owned, 4-room", @"Owned, 5-room", @"Rental, 1-room", @"Rental, 2-room", @"Rental, 3-room", @"Rental, 4-room"];
    row.required = YES;
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
//    if (![[resiPartiDict objectForKey:@"housing_owned_rented"] isEqualToString:@""]) { //if got value
//        if([[resiPartiDict objectForKey:@"housing_owned_rented"] isEqualToString:@"0"]) {   //owned
//            NSArray *options = row.selectorOptions;
//            row.value = [options objectAtIndex:([[resiPartiDict objectForKey:@"housing_num_rooms"] integerValue] - 1)]; //do the math =D
//        } else {
//            NSArray *options = row.selectorOptions;
//            row.value = [options objectAtIndex:([[resiPartiDict objectForKey:@"housing_num_rooms"] integerValue] + 4)];
//        }
//    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHighestEduLevel rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Highest Education Level"];
    row.noValueDisplayText = @"Tap here";
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"ITE/Pre-U/JC"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"No formal qualifications"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Primary"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Secondary"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"University"]
                            ];
//    if ([[resiPartiDict objectForKey:@"highest_edu_lvl"] isEqualToString:@""]) {
//        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"ITE/Pre-U/JC"];   //default value
//    } else {
//        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"highest_edu_lvl"] integerValue]] ;
//    }
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    row.required = NO;
    [section addFormRow:row];
    
    XLFormRowDescriptor *addressRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"address" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Address"];
    if ([neighbourhood isEqualToString:@"KGL"])
        addressRow.selectorOptions = @[@"Blk 4 Beach Rd",@"Blk 5 Beach Rd",@"Blk 6 Beach Rd", @"Blk 7 North Bridge Rd", @"Blk 8 North Bridge Rd", @"Blk 9 North Bridge Rd", @"Blk 10 North Bridge Rd", @"Blk 18 Jln Sultan", @"Blk 19 Jln Sultan", @"Others"];
    else
        addressRow.selectorOptions = @[@"1 Eunos Crescent", @"2 Eunos Crescent", @"12 Eunos Crescent", @"2 Upper Aljunied Lane", @"3 Upper Aljunied Lane", @"4 Upper Aljunied Lane", @"5 Upper Aljunied Lane"];
    addressRow.required = YES;
    [addressRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:addressRow];
    
    XLFormRowDescriptor *addrOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    addrOthersRow.required = NO;
    addrOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", addressRow];
    [addrOthersRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [addrOthersRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:addrOthersRow];
    
    addrOthersRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor) {
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
            rowDescriptor.value = CAPSed;
        }
    };
    
    XLFormRowDescriptor *unitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressUnitNum rowType:XLFormRowDescriptorTypeText title:@"Unit No"];
    [unitRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    unitRow.required = YES;
    [section addFormRow:unitRow];
    
    unitRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
            rowDescriptor.value = CAPSed;
        }
    };
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressPostCode rowType:XLFormRowDescriptorTypeDecimal title:@"PostCode"];
    row.required = NO;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressDuration rowType:XLFormRowDescriptorTypeDecimal title:@"How many years have you stayed at your current block? \n____ years (If months, put in decimals to 1 decimal place eg. 6 months = 0.5 years)"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (NSArray *) getSpokenLangArray: (NSDictionary *) dictionary {
    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
    if ([[dictionary objectForKey:@"lang_canto"] isKindOfClass:[NSString class]]) {
        
        if([[dictionary objectForKey:@"lang_canto"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
        if([[dictionary objectForKey:@"lang_english"] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
        if([[dictionary objectForKey:@"lang_hindi"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
        if([[dictionary objectForKey:@"lang_hokkien"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
        if([[dictionary objectForKey:@"lang_malay"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
        if([[dictionary objectForKey:@"lang_mandrin"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
        if([[dictionary objectForKey:@"lang_others"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Others"];
        if([[dictionary objectForKey:@"lang_tamil"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
        if([[dictionary objectForKey:@"lang_teochew"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
    }
    else if ([[dictionary objectForKey:@"lang_english"] isKindOfClass:[NSNumber class]]) {
        if([[dictionary objectForKey:@"lang_canto"] isEqual:@(1)]) [spokenLangArray addObject:@"Cantonese"];
        if([[dictionary objectForKey:@"lang_english"] isEqual:@(1)]) [spokenLangArray addObject:@"English"];
        if([[dictionary objectForKey:@"lang_hindi"] isEqual:@(1)]) [spokenLangArray addObject:@"Hindi"];
        if([[dictionary objectForKey:@"lang_hokkien"] isEqual:@(1)]) [spokenLangArray addObject:@"Hokkien"];
        if([[dictionary objectForKey:@"lang_malay"] isEqual:@(1)]) [spokenLangArray addObject:@"Malay"];
        if([[dictionary objectForKey:@"lang_mandrin"] isEqual:@(1)]) [spokenLangArray addObject:@"Mandarin"];
        if([[dictionary objectForKey:@"lang_others"] isEqual:@(1)]) [spokenLangArray addObject:@"Others"];
        if([[dictionary objectForKey:@"lang_tamil"] isEqual:@(1)]) [spokenLangArray addObject:@"Tamil"];
        if([[dictionary objectForKey:@"lang_teochew"] isEqual:@(1)]) [spokenLangArray addObject:@"Teochew"];
    }
    return spokenLangArray;
}

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


//- (void) saveResidentParticulars {
//    NSDictionary *fields = [self.form formValues];
//    NSMutableDictionary *resi_particulars = [[self.fullScreeningForm objectForKey:@"resi_particulars"] mutableCopy];
//
//    if ([fields objectForKey:kGender] != [NSNull null]) {
//        if ([[fields objectForKey:kGender] isEqualToString:@"Male"]) {
//            [resi_particulars setObject:@"M" forKey:kGender];
//        } else if ([[fields objectForKey:kGender] isEqualToString:@"Female"]) {
//            [resi_particulars setObject:@"F" forKey:kGender];
//        }
//    }
//
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kName] forKey:@"resident_name"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kNRIC] forKey:kNRIC];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kDOB] forKey:@"birth_year"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kContactNumber] forKey:@"contact_no"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kAddPostCode] forKey:@"address_postcode"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddStreet] forKey:@"address_street"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddBlock] forKey:@"address_block"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddUnit] forKey:@"address_unit"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentNUS] forKey:kConsentNUS];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentHPB] forKey:kConsentHPB];
////    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Switch formDescriptorWithTag:kConsentGoodlife] forKey:kConsentGoodlife];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddYears] forKey:@"address_num_years"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kContactNumber2] forKey:@"contact_no2"];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kSpokenLangOthers] forKey:@"lang_others_text"];
//
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kEthnicity] forKey:kEthnicity];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kMaritalStatus] forKey:kMaritalStatus];
//    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kHighestEduLvl] forKey:@"highest_edu_lvl"];
//
//    //Init them to zero first
//    [resi_particulars setObject:@"0" forKey:@"lang_canto"];
//    [resi_particulars setObject:@"0" forKey:@"lang_english"];
//    [resi_particulars setObject:@"0" forKey:@"lang_hokkien"];
//    [resi_particulars setObject:@"0" forKey:@"lang_hindi"];
//    [resi_particulars setObject:@"0" forKey:@"lang_malay"];
//    [resi_particulars setObject:@"0" forKey:@"lang_mandrin"];
//    [resi_particulars setObject:@"0" forKey:@"lang_tamil"];
//    [resi_particulars setObject:@"0" forKey:@"lang_teochew"];
//    [resi_particulars setObject:@"0" forKey:@"lang_others"];
//
//    if ([[fields objectForKey:kSpokenLanguage] count]!=0) {
//        NSArray *spokenLangArray = [fields objectForKey:kSpokenLanguage];
//        for (int i=0; i<[spokenLangArray count]; i++) {
//
//            if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Cantonese"]) [resi_particulars setObject:@"1" forKey:@"lang_canto"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"English"]) [resi_particulars setObject:@"1" forKey:@"lang_english"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hindi"]) [resi_particulars setObject:@"1" forKey:@"lang_hindi"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hokkien"]) [resi_particulars setObject:@"1" forKey:@"lang_hokkien"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Malay"]) [resi_particulars setObject:@"1" forKey:@"lang_malay"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Mandarin"]) [resi_particulars setObject:@"1" forKey:@"lang_mandrin"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Tamil"]) [resi_particulars setObject:@"1" forKey:@"lang_tamil"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Teochew"]) [resi_particulars setObject:@"1" forKey:@"lang_teochew"];
//            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Others"]) [resi_particulars setObject:@"1" forKey:@"lang_others"];
//        }
//    }
//
//    NSString *room;
//    NSUInteger loc;
//    if (([fields objectForKey:kHousingType] != [NSNull null]) && ([fields objectForKey:kHousingType])) {
//        NSString *houseType = [fields objectForKey:kHousingType];
//        if ([houseType rangeOfString:@"Owned"].location != NSNotFound) {
//            [resi_particulars setObject:@"0" forKey:@"housing_owned_rented"];
//        } else if ([houseType rangeOfString:@"Rental"].location != NSNotFound) {
//            [resi_particulars setObject:@"1" forKey:@"housing_owned_rented"];
//        }
//
//        loc = [houseType rangeOfString:@"-"].location;
//        room = [houseType substringWithRange:NSMakeRange(loc-1, 1)];
//        [resi_particulars setObject:room forKey:@"housing_num_rooms"];
//    }
//
//    [self.fullScreeningForm setObject:resi_particulars forKey:@"resi_particulars"];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

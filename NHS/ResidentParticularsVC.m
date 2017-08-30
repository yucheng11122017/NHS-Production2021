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
}

//@property (strong, nonatomic) NSMutableDictionary *resiPartiDict;
@property (strong, nonatomic) NSNumber *resident_id;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;

@end

@implementation ResidentParticularsVC

- (void)viewDidLoad {
    
    XLFormViewController *form;

    NSLog(@"Resident selected %@", _residentParticularsDict);
    
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
    
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void) viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBar.topItem.title = @"Integrated Profile";

    
    
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    if ([_residentParticularsDict count] > 0) {
        NSDate *date = [dateFormatter dateFromString:_residentParticularsDict[kBirthDate]];
        dobRow.value = date;
    }
    [dobRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:dobRow];
    
    dobRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        
        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
            NSLog(@"%@", newValue);
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCitizenship rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Citizenship Status"];
    row.required = YES;
    row.value = _residentParticularsDict[kCitizenship];
    [self setDefaultFontWithRow:row];
    row.selectorOptions = @[@"Singaporean", @"PR", @"Foreigner", @"Stateless"];
    [section addFormRow:row];
    
    XLFormRowDescriptor *religionRow;
    religionRow = [XLFormRowDescriptor formRowDescriptorWithTag:kReligion rowType:XLFormRowDescriptorTypeSelectorPush title:@"Religion"];
    religionRow.value = _residentParticularsDict[kReligion];
    religionRow.selectorOptions = @[@"Buddhism", @"Taoism", @"Islam", @"Christianity", @"Hinduism", @"No Religion", @"Others"];
    [self setDefaultFontWithRow:religionRow];
    religionRow.required = YES;
    [section addFormRow:religionRow];
    
    religionRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"religion_others" rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", religionRow];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHpNumber rowType:XLFormRowDescriptorTypePhone title:@"HP Number"];
    row.required = YES;
    row.value = [_residentParticularsDict objectForKey:kHpNumber];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
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
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    [self setDefaultFontWithRow:spokenLangRow];
    spokenLangRow.required = YES;

    spokenLangRow.value = [self getSpokenLangArray:_residentParticularsDict];
//        spokenLangRow.value = spoken_lang_value? spoken_lang_value:@[];
    [section addFormRow:spokenLangRow];
    
    spokenLangRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
//            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
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
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLangOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", spokenLangRow];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    row.value = [_residentParticularsDict objectForKey:kLangOthers];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMaritalStatus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Marital Status"];
    row.selectorOptions = @[@"Divorced", @"Married", @"Separated", @"Single", @"Widowed"];
    row.value = _residentParticularsDict[kMaritalStatus];
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kMaritalStatus andNewContent:newValue];
        }
    };
    
//    if ([[resiPartiDict objectForKey:@"marital_status"] isEqualToString:@""]) {
//        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Single"];   //default value
//    } else {
//        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"marital_status"] integerValue]] ;
//    }
    [self setDefaultFontWithRow:row];
    row.noValueDisplayText = @"Tap here";
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHousingType rowType:XLFormRowDescriptorTypeSelectorPush title:@"Housing Type"];
    row.selectorOptions = @[@"Owned, 1-room", @"Owned, 2-room", @"Owned, 3-room", @"Owned, 4-room", @"Owned, 5-room", @"Rental, 1-room", @"Rental, 2-room", @"Rental, 3-room", @"Rental, 4-room", @"Private"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    
    row.value = [self getHousingOwnedRentedFromTwoValues];
    
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            
            NSString *housingType;
            
            if ([newValue rangeOfString:@"Owned"].location != NSNotFound) {
                housingType = @"Owned";
            } else if ([newValue rangeOfString:@"Rental"].location != NSNotFound) {
                housingType = @"Rented";
            } else {
                housingType = @"Private";
            }
            
            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kHousingType andNewContent:housingType];
            if ([housingType isEqualToString:@"Private"]) return;   //no need to post HousingNumRooms
            
            
            NSUInteger loc = [newValue rangeOfString:@"-"].location;
            NSString *room = [newValue substringWithRange:NSMakeRange(loc-1, 1)];
            
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kHousingNumRooms andNewContent:room];
            });
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHighestEduLevel rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Highest Education Level"];
    row.value = _residentParticularsDict[kHighestEduLevel];
    row.noValueDisplayText = @"Tap here";
    row.selectorOptions = @[@"ITE/Pre-U/JC", @"No formal qualifications", @"Primary",@"Secondary",@"University"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kHighestEduLevel andNewContent:newValue];
        }
    };
    
    XLFormRowDescriptor *addressRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress rowType:XLFormRowDescriptorTypeSelectorPush title:@"Address"];
    if ([neighbourhood isEqualToString:@"Kampong Glam"])
        addressRow.selectorOptions = @[@"Blk 4 Beach Rd",@"Blk 5 Beach Rd",@"Blk 6 Beach Rd", @"Blk 7 North Bridge Rd", @"Blk 8 North Bridge Rd", @"Blk 9 North Bridge Rd", @"Blk 10 North Bridge Rd", @"Blk 18 Jln Sultan", @"Blk 19 Jln Sultan", @"Others"];
    else
        addressRow.selectorOptions = @[@"1 Eunos Crescent", @"2 Eunos Crescent", @"12 Eunos Crescent", @"2 Upper Aljunied Lane", @"3 Upper Aljunied Lane", @"4 Upper Aljunied Lane", @"5 Upper Aljunied Lane", @"Others"];
    addressRow.value = [self getAddressFromStreetAndBlock];
    addressRow.required = YES;
    [self setDefaultFontWithRow:addressRow];
    [section addFormRow:addressRow];
    
    XLFormRowDescriptor *addrOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    addrOthersRow.value = _residentParticularsDict[kAddressOthers];
    addrOthersRow.required = NO;
    addrOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", addressRow];
    [addrOthersRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:addrOthersRow];
    [section addFormRow:addrOthersRow];
    
    addressRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            NSString *street = [self getStreetFromAddress:newValue];
            NSString *block  = [self getBlockFromAddress:newValue];
            
            [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kAddressStreet andNewContent:street];
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:kAddressBlock andNewContent:block];
            });
            
            if ([newValue containsString:@"Others"]) {
                addrOthersRow.required = YES;  //force to fill in address if selected 'Others'
            } else {
                addrOthersRow.required = NO;
            }
        }
    };
    
    
//    addrOthersRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor) {
//        
//        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
//            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
//            rowDescriptor.value = CAPSed;
//        }
//    };
    
    XLFormRowDescriptor *unitRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressUnitNum rowType:XLFormRowDescriptorTypeText title:@"Unit No"];
    unitRow.value = _residentParticularsDict[kAddressUnitNum];
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
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressPostCode rowType:XLFormRowDescriptorTypeInteger title:@"Postal Code"];
    row.value = _residentParticularsDict[kAddressPostCode];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Postal Code must be 6 digits" regex:@"^(?=.*\\d).{6}$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressDuration rowType:XLFormRowDescriptorTypeDecimal title:@"No. of years resided in current block"];
    row.value = _residentParticularsDict[kAddressDuration];
    row.required = YES;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

#pragma mark - XLFormViewControllerDelegate 
// Currently only works for textFields
-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {
    
    if ([rowDescriptor.tag isEqualToString:kBirthDate] || [rowDescriptor.tag isEqualToString:kNRIC]) {
        return;
    }
    else if ([rowDescriptor.tag isEqualToString:kName]) {
        NSString *CAPSed = [rowDescriptor.value uppercaseString];
        rowDescriptor.value = CAPSed;
        [self reloadFormRow:rowDescriptor];
        return;
    } else if ([rowDescriptor.tag isEqualToString:kAddressOthers]) {
        NSString *CAPSed = [rowDescriptor.value uppercaseString];
        rowDescriptor.value = CAPSed;
        [self reloadFormRow:rowDescriptor];
        //no return here...
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
        [self postSingleFieldWithSection:SECTION_RESI_PART andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
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




- (void) saveResidentParticulars {
    NSDictionary *fields = [self.form formValues];
    NSMutableDictionary *resi_particulars = [[NSMutableDictionary alloc]init];
    NSString *name, *nric, *gender, *birthDate;

    if ([fields objectForKey:kGender] != [NSNull null]) {
        if ([[fields objectForKey:kGender] isEqualToString:@"Male"]) {
            [resi_particulars setObject:@"M" forKey:kGender];
        } else if ([[fields objectForKey:kGender] isEqualToString:@"Female"]) {
            [resi_particulars setObject:@"F" forKey:kGender];
        }
        gender = resi_particulars[kGender];
    }
    name = [self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kName];
    [resi_particulars setObject:name forKey:kName];
    nric = [self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kNRIC];
    [resi_particulars setObject:nric forKey:kNRIC];
    birthDate = [self getStringWithDictionary:fields rowType:Date formDescriptorWithTag:kBirthDate];
    [resi_particulars setObject:birthDate forKey:kBirthDate];
    
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kCitizenship] forKey:kCitizenship];
    
    if ([[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kReligion] isEqualToString:@"Others"]) {
        [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kReligionOthers] forKey:kReligion];
    } else
        [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kReligion] forKey:kReligion];
    
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kHpNumber] forKey:kHpNumber];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kHouseNumber] forKey:kHouseNumber];
    
    [resi_particulars setObject:[self getEthnicityString:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kEthnicity]] forKey:kEthnicity];
    [resi_particulars setObject:[self getMaritalStatusString:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kMaritalStatus]]forKey:kMaritalStatus];
    [resi_particulars setObject:[self getHighestEduLvlString:[self getStringWithDictionary:fields rowType:SelectorActionSheet formDescriptorWithTag:kHighestEduLevel]] forKey:kHighestEduLevel];
    
    
    NSString *address = [self getStringWithDictionary:fields rowType:SelectorArray formDescriptorWithTag:kAddress];

    [resi_particulars setObject:[self getBlockFromAddress:address] forKey:kAddressBlock];
    [resi_particulars setObject:[self getStreetFromAddress:address] forKey:kAddressStreet];

    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddressUnitNum] forKey:kAddressUnitNum];
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Number formDescriptorWithTag:kAddressPostCode] forKey:kAddressPostCode];
    
    [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kAddressDuration] forKey:kAddressDuration];

    //Init them to zero first
    [resi_particulars setObject:@"0" forKey:kLangCanto];
    [resi_particulars setObject:@"0" forKey:kLangEng];
    [resi_particulars setObject:@"0" forKey:kLangHokkien];
    [resi_particulars setObject:@"0" forKey:kLangHindi];
    [resi_particulars setObject:@"0" forKey:kLangMalay];
    [resi_particulars setObject:@"0" forKey:kLangMandarin];
    [resi_particulars setObject:@"0" forKey:kLangTamil];
    [resi_particulars setObject:@"0" forKey:kLangTeoChew];
    [resi_particulars setObject:@"0" forKey:kLangOthers];

    if ([[fields objectForKey:kSpokenLang] count]!=0) {
        NSArray *spokenLangArray = [fields objectForKey:kSpokenLang];
        for (int i=0; i<[spokenLangArray count]; i++) {

            if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Cantonese"]) [resi_particulars setObject:@"1" forKey:kLangCanto];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"English"]) [resi_particulars setObject:@"1" forKey:kLangEng];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hindi"]) [resi_particulars setObject:@"1" forKey:kLangHindi];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hokkien"]) [resi_particulars setObject:@"1" forKey:kLangHokkien];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Malay"]) [resi_particulars setObject:@"1" forKey:kLangMalay];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Mandarin"]) [resi_particulars setObject:@"1" forKey:kLangMandarin];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Tamil"]) [resi_particulars setObject:@"1" forKey:kLangMandarin];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Teochew"]) [resi_particulars setObject:@"1" forKey:kLangTeoChew];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Others"]) [resi_particulars setObject:@"1" forKey:kLangOthers];
        }
    }
    
    if ([[resi_particulars objectForKey:kLangOthers] isEqualToString:@"1"])
        [resi_particulars setObject:[self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kLangOthersText] forKey:kLangOthersText];

    NSString *room;
    NSUInteger loc;
    if (([fields objectForKey:kHousingType] != [NSNull null]) && ([fields objectForKey:kHousingType])) {
        NSString *houseType = [fields objectForKey:kHousingType];
        if ([houseType rangeOfString:@"Owned"].location != NSNotFound) {
            [resi_particulars setObject:@"Owned" forKey:kHousingType];
        } else if ([houseType rangeOfString:@"Rental"].location != NSNotFound) {
            [resi_particulars setObject:@"Rented" forKey:kHousingType];
        } else {
            [resi_particulars setObject:@"Private" forKey:kHousingType];
        }

        loc = [houseType rangeOfString:@"-"].location;
        room = [houseType substringWithRange:NSMakeRange(loc-1, 1)];
        [resi_particulars setObject:room forKey:@"housing_num_rooms"];
    }
    
    NSString *timeNow = [self getTimeNowInString];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kResidentId] isKindOfClass:[NSNumber class]]) {   //only if no resident ID registered, then submit
        NSLog(@"Registering new resident...");
        NSDictionary *dict = @{kName:name,
                               kNRIC:nric,
                               kGender:gender,
                               kBirthDate:birthDate,
                               kTimestamp:timeNow};
//        [self submitNewResidentEntry:dict];
    }
    NSLog(@"%@", resi_particulars);
    [self postAllOtherFields:resi_particulars];
    
    
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
    if ([neighbourhood isEqualToString:@"Kampong Glam"]) {
        subString = [[string substringWithRange:NSMakeRange(0, 6)] mutableCopy];
        [subString stringByReplacingOccurrencesOfString:@"Blk" withString:@""];
    } else
        subString = [[string substringWithRange:NSMakeRange(0, 2)] mutableCopy];
    
    int blkNo = [subString intValue];   //to remove whitespace
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
        else return @"Upper Aljunied Lane";
    }
}

- (NSString *) getAddressFromStreetAndBlock {
    if (_residentParticularsDict[kAddressStreet] != (id) [NSNull null]) {
        NSString *block = _residentParticularsDict[kAddressBlock];
        NSString *street = _residentParticularsDict[kAddressStreet];
        
        if ([neighbourhood isEqualToString:@"Kampong Glam"])
            return [NSString stringWithFormat:@"Blk %@ %@", block, street];
        else
            return [NSString stringWithFormat:@"%@ %@", block, street];
    }
    return @"";
}

- (NSArray *) getSpokenLangArray: (NSDictionary *) dictionary {
    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
    //    if ([[dictionary objectForKey:kLangCanto] isKindOfClass:[NSString class]]) {
    //
    //        if([[dictionary objectForKey:kLangCanto] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
    //        if([[dictionary objectForKey:kLangEng] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
    //        if([[dictionary objectForKey:kLangHindi] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
    //        if([[dictionary objectForKey:kLangHokkien] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
    //        if([[dictionary objectForKey:kLangMalay] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
    //        if([[dictionary objectForKey:kLangMandarin] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
    //        if([[dictionary objectForKey:kLangOthers] isEqualToString:@"1"]) [spokenLangArray addObject:@"Others"];
    //        if([[dictionary objectForKey:kLangTamil] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
    //        if([[dictionary objectForKey:kLangTeoChew] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
    //    }
    //    else if ([[dictionary objectForKey:kLangCanto] isKindOfClass:[NSNumber class]]) {
    if([[dictionary objectForKey:kLangCanto] isEqual:@(1)]) [spokenLangArray addObject:@"Cantonese"];
    if([[dictionary objectForKey:kLangEng] isEqual:@(1)]) [spokenLangArray addObject:@"English"];
    if([[dictionary objectForKey:kLangHindi] isEqual:@(1)]) [spokenLangArray addObject:@"Hindi"];
    if([[dictionary objectForKey:kLangHokkien] isEqual:@(1)]) [spokenLangArray addObject:@"Hokkien"];
    if([[dictionary objectForKey:kLangMalay] isEqual:@(1)]) [spokenLangArray addObject:@"Malay"];
    if([[dictionary objectForKey:kLangMandarin] isEqual:@(1)]) [spokenLangArray addObject:@"Mandarin"];
    if([[dictionary objectForKey:kLangOthers] isEqual:@(1)]) [spokenLangArray addObject:@"Others"];
    if([[dictionary objectForKey:kLangTamil] isEqual:@(1)]) [spokenLangArray addObject:@"Tamil"];
    if([[dictionary objectForKey:kLangTeoChew] isEqual:@(1)]) [spokenLangArray addObject:@"Teochew"];
    //    }
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

- (NSString *) getHousingOwnedRentedFromTwoValues {
    
    if (_residentParticularsDict[kHousingNumRooms] != (id) [NSNull null]) { //got some value
        NSString *numRooms = _residentParticularsDict[kHousingNumRooms];
        NSString *housingType = _residentParticularsDict[kHousingType];
        
        if (housingType == (id)[NSNull null] || housingType == nil)     //don't continue
            return @"";
        
        if (![housingType isEqualToString:@"Private"])
            return [NSString stringWithFormat:@"%@, %@-room", housingType, numRooms];
        else
            return @"Private";
    }
    return @"";
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
                                                                      //                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                                      //                                                                                                                  object:nil
                                                                      //                                                                                                                userInfo:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

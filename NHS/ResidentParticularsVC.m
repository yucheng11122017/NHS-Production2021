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
#define RESI_PART_SECTION @"resi_particulars"

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
}

@property (strong, nonatomic) NSMutableDictionary *resiPartiDict;
@property (strong, nonatomic) NSNumber *resident_id;

@end

@implementation ResidentParticularsVC

- (void)viewDidLoad {
    
    XLFormViewController *form;

    NSLog(@"Resident selected %@", _residentParticularsDict);
    
    neighbourhood = [[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood];
    _resiPartiDict = [[NSMutableDictionary alloc] init];
    
    //must init first before [super viewDidLoad]
    form = [self initResidentParticularsForm];
    [self.form setAddAsteriskToRequiredRowsTitle: YES];
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitBtnPressed:)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void) viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBar.topItem.title = @"Screening History";
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

    
    //Hide this for now
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"button" rowType:XLFormRowDescriptorTypeButton title:@"Calculate Age!"];
//    row.action.formSelector = @selector(calculateAge:);
//    row.required = NO;
////    [section addFormRow:row];
    
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
    
    religionRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
        }
    };
    
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
    row.selectorOptions = @[@"Chinese",@"Indian",@"Malay",@"Others"];
    row.required = NO;
    row.noValueDisplayText = @"Tap here for options";
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
//    if ([[resiPartiDict objectForKey:@"ethnicity_id"] isEqualToString:@""]) {
//        
//    } else {
//        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"ethnicity_id"] integerValue]] ;
//    }
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
        }
    };
    
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLang rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    [spokenLangRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    row.required = YES;

//    spokenLangRow.value = [self getSpokenLangArray:resiPartiDict];
//        spokenLangRow.value = spoken_lang_value? spoken_lang_value:@[];
    [section addFormRow:spokenLangRow];
    
    spokenLangRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
//            [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
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
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
//    row.value = [resiPartiDict objectForKey:@"lang_others_text"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMaritalStatus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Marital Status"];
    row.selectorOptions = @[@"Divorced", @"Married", @"Separated", @"Single", @"Widowed"];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:kMaritalStatus andNewContent:newValue];
        }
    };
    
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
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            
            NSString *ownedRented;
            
            if ([newValue rangeOfString:@"Owned"].location != NSNotFound) {
                ownedRented = @"Owned";
            } else if ([newValue rangeOfString:@"Rental"].location != NSNotFound) {
                ownedRented = @"Rented";
            }
            
            NSUInteger loc = [newValue rangeOfString:@"-"].location;
            NSString *room = [newValue substringWithRange:NSMakeRange(loc-1, 1)];
            
            [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:kHousingOwnedRented andNewContent:ownedRented];
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:kHousingNumRooms andNewContent:room];
            });
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHighestEduLevel rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Highest Education Level"];
    row.noValueDisplayText = @"Tap here";
    row.selectorOptions = @[@"ITE/Pre-U/JC", @"No formal qualifications", @"Primary",@"Secondary",@"University"];
//    if ([[resiPartiDict objectForKey:@"highest_edu_lvl"] isEqualToString:@""]) {
//        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"ITE/Pre-U/JC"];   //default value
//    } else {
//        row.value = [row.selectorOptions objectAtIndex:[[resiPartiDict objectForKey:@"highest_edu_lvl"] integerValue]] ;
//    }
    [row.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    row.required = NO;
    [section addFormRow:row];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:kHighestEduLevel andNewContent:newValue];
        }
    };
    
    XLFormRowDescriptor *addressRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress rowType:XLFormRowDescriptorTypeSelectorPush title:@"Address"];
    if ([neighbourhood isEqualToString:@"KGL"])
        addressRow.selectorOptions = @[@"Blk 4 Beach Rd",@"Blk 5 Beach Rd",@"Blk 6 Beach Rd", @"Blk 7 North Bridge Rd", @"Blk 8 North Bridge Rd", @"Blk 9 North Bridge Rd", @"Blk 10 North Bridge Rd", @"Blk 18 Jln Sultan", @"Blk 19 Jln Sultan", @"Others"];
    else
        addressRow.selectorOptions = @[@"1 Eunos Crescent", @"2 Eunos Crescent", @"12 Eunos Crescent", @"2 Upper Aljunied Lane", @"3 Upper Aljunied Lane", @"4 Upper Aljunied Lane", @"5 Upper Aljunied Lane", @"Others"];
    addressRow.required = YES;
    [addressRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:addressRow];
    
    addressRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            NSString *street = [self getStreetFromAddress:newValue];
            NSString *block  = [self getBlockFromAddress:newValue];
            
            [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:kAddressStreet andNewContent:street];
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:kAddressBlock andNewContent:block];
            });
        }
    };
    
    XLFormRowDescriptor *addrOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    addrOthersRow.required = NO;
    addrOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", addressRow];
    [addrOthersRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [addrOthersRow.cellConfig setObject:[UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE] forKey:@"textLabel.font"];
    [section addFormRow:addrOthersRow];
    
//    addrOthersRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor) {
//        
//        if (![oldValue isEqual:newValue]) { //otherwise this segment will crash
//            NSString *CAPSed = [rowDescriptor.editTextValue uppercaseString];
//            rowDescriptor.value = CAPSed;
//        }
//    };
    
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
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddressPostCode rowType:XLFormRowDescriptorTypeNumber title:@"PostCode"];
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
    
    if (rowDescriptor.value != (id)[NSNull null] && rowDescriptor.value != nil) {
        
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
        
        [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:rowDescriptor.tag andNewContent:rowDescriptor.value];
    }
}

#pragma mark -

//- (NSArray *) getSpokenLangArray: (NSDictionary *) dictionary {
//    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
//    if ([[dictionary objectForKey:@"lang_canto"] isKindOfClass:[NSString class]]) {
//        
//        if([[dictionary objectForKey:@"lang_canto"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
//        if([[dictionary objectForKey:@"lang_english"] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
//        if([[dictionary objectForKey:@"lang_hindi"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
//        if([[dictionary objectForKey:@"lang_hokkien"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
//        if([[dictionary objectForKey:@"lang_malay"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
//        if([[dictionary objectForKey:@"lang_mandarin"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
//        if([[dictionary objectForKey:@"lang_others"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Others"];
//        if([[dictionary objectForKey:@"lang_tamil"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
//        if([[dictionary objectForKey:@"lang_teochew"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
//    }
//    else if ([[dictionary objectForKey:@"lang_english"] isKindOfClass:[NSNumber class]]) {
//        if([[dictionary objectForKey:@"lang_canto"] isEqual:@(1)]) [spokenLangArray addObject:@"Cantonese"];
//        if([[dictionary objectForKey:@"lang_english"] isEqual:@(1)]) [spokenLangArray addObject:@"English"];
//        if([[dictionary objectForKey:@"lang_hindi"] isEqual:@(1)]) [spokenLangArray addObject:@"Hindi"];
//        if([[dictionary objectForKey:@"lang_hokkien"] isEqual:@(1)]) [spokenLangArray addObject:@"Hokkien"];
//        if([[dictionary objectForKey:@"lang_malay"] isEqual:@(1)]) [spokenLangArray addObject:@"Malay"];
//        if([[dictionary objectForKey:@"lang_mandarin"] isEqual:@(1)]) [spokenLangArray addObject:@"Mandarin"];
//        if([[dictionary objectForKey:@"lang_others"] isEqual:@(1)]) [spokenLangArray addObject:@"Others"];
//        if([[dictionary objectForKey:@"lang_tamil"] isEqual:@(1)]) [spokenLangArray addObject:@"Tamil"];
//        if([[dictionary objectForKey:@"lang_teochew"] isEqual:@(1)]) [spokenLangArray addObject:@"Teochew"];
//    }
//    return spokenLangArray;
//}

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
    if (([fields objectForKey:kHousingOwnedRented] != [NSNull null]) && ([fields objectForKey:kHousingOwnedRented])) {
        NSString *houseType = [fields objectForKey:kHousingOwnedRented];
        if ([houseType rangeOfString:@"Owned"].location != NSNotFound) {
            [resi_particulars setObject:@"Owned" forKey:@"housing_owned_rented"];
        } else if ([houseType rangeOfString:@"Rental"].location != NSNotFound) {
            [resi_particulars setObject:@"Rented" forKey:@"housing_owned_rented"];
        }

        loc = [houseType rangeOfString:@"-"].location;
        room = [houseType substringWithRange:NSMakeRange(loc-1, 1)];
        [resi_particulars setObject:room forKey:@"housing_num_rooms"];
    }

    [self.resiPartiDict setObject:resi_particulars forKey:@"resi_particulars"];
    
    NSString *timeNow = [self getTimeNowInString];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kResidentId] isKindOfClass:[NSNumber class]]) {   //only if no resident ID registered, then submit
        NSLog(@"Registering new resident...");
        NSDictionary *dict = @{kName:name,
                               kNRIC:nric,
                               kGender:gender,
                               kBirthDate:birthDate,
                               kTimestamp:timeNow};
        [self submitNewResidentEntry:dict];
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
    if ([neighbourhood isEqualToString:@"KGL"]) {
        subString = [[string substringWithRange:NSMakeRange(0, 6)] mutableCopy];
        [subString stringByReplacingOccurrencesOfString:@"Blk" withString:@""];
    } else
        subString = [[string substringWithRange:NSMakeRange(0, 2)] mutableCopy];
    
    int blkNo = [subString intValue];   //to remove whitespace
    return [NSString stringWithFormat:@"%d", blkNo];
}

- (NSString *) getStreetFromAddress: (NSString *) string {
    
    if ([neighbourhood isEqualToString:@"KGL"]) {
        if ([string containsString:@"Beach"]) return @"Beach Rd";
        else if ([string containsString:@"North"]) return @"North Bridge Rd";
        else if ([string containsString:@"Sultan"]) return @"Jln Sultan";
        else return @"Others";
    } else {
        if ([string containsString:@"Eunos"]) return @"Eunos Crescent";
        else return @"Upper Aljunied Lane";
    }
}

- (NSString *) getTimeNowInString {
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    return [localDateTime description];
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
    
    [self postSingleFieldWithSection:RESI_PART_SECTION andFieldName:fieldName andNewContent:value];
}


#pragma mark - Submit
-(void)submitBtnPressed:(UIBarButtonItem * __unused)button {
    
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
    name = [self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kName];
//    [resi_particulars setObject:name forKey:kName];
    nric = [self getStringWithDictionary:fields rowType:Text formDescriptorWithTag:kNRIC];
//    [resi_particulars setObject:nric forKey:kNRIC];
    birthDate = [self getStringWithDictionary:fields rowType:Date formDescriptorWithTag:kBirthDate];
//    [resi_particulars setObject:birthDate forKey:kBirthDate];
    
    NSString *timeNow = [self getTimeNowInString];
    
    NSNumber *residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId];
    
    if ((residentID == nil) || residentID == (id)[NSNull null]) {   //only if no resident ID registered, then submit
        NSLog(@"Registering new resident...");
        NSDictionary *dict = @{kName:name,
                               kNRIC:nric,
                               kGender:gender,
                               kBirthDate:birthDate,
                               kTimestamp:timeNow};
        [self submitNewResidentEntry:dict];
    } else {
        NSLog(@"Resident already exist!");
    }
    
    //    NSArray * validationErrors = [self formValidationErrors];
    //    if (validationErrors.count > 0){
    //        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
    //            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
    //            cell.backgroundColor = [UIColor orangeColor];
    //            [UIView animateWithDuration:0.3 animations:^{
    //                cell.backgroundColor = [UIColor whiteColor];
    //            }];
    //        }];
    //        [self showFormValidationError:[validationErrors firstObject]];
    //
    //        return;
    //    } else {
    //
    //        [SVProgressHUD setMinimumDismissTimeInterval:1.0f];
    //        [SVProgressHUD showImage:[[UIImage imageNamed:@"ThumbsUp"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] status:@"Good!"];
    //        
    //        [self saveResidentParticulars];
    //    }
}

    
    


#pragma mark - Post data to server methods
- (void) submitNewResidentEntry:(NSDictionary *) dict {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postNewResidentWithDict:@{@"resi_particulars":dict}
                       progressBlock:[self progressBlock]
                        successBlock:[self personalInfoSuccessBlock]
                        andFailBlock:[self errorBlock]];
}

- (void) postSingleFieldWithSection:(NSString *) section andFieldName: (NSString *) fieldName andNewContent: (NSString *) content {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    NSDictionary *dict = @{kResidentId:resident_id,
                           kSectionName:section,
                           kFieldName:fieldName,
                           kNewContent:content
                           };
    
    NSLog(@"Uploading %@ for $%@$ field", content, fieldName);
    
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postDataGivenSectionAndFieldName:dict
                               progressBlock:[self progressBlock]
                                successBlock:[self successBlock]
                                andFailBlock:[self errorBlock]];
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
        
        successCounter++;
        NSLog(@"%d", successCounter);
//        if(successCounter == 4) {
//            NSLog(@"SUBMISSION SUCCESSFUL!!");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//            if (self.loadDataFlag == [NSNumber numberWithBool:YES]) {       //if this draft is loaded and submitted,now delete!
////                [self removeDraftAfterSubmission];
//            }
//            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Uploaded", nil)
//                                                                                      message:@"Registration successful!"
//                                                                               preferredStyle:UIAlertControllerStyleAlert];
//            
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
//                                                                style:UIAlertActionStyleDefault
//                                                              handler:^(UIAlertAction * okAction) {
//                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
//                                                                                                                      object:nil
//                                                                                                                    userInfo:nil];
//                                                                  [self.navigationController popViewControllerAnimated:YES];
//                                                              }]];
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//        
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))personalInfoSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"Personal info submission success");
        self.resident_id = [responseObject objectForKey:kResidentId];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.resident_id forKey:kResidentId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"I'm resident %@", self.resident_id);
        
        successCounter = failCounter = 0; //preparing for the rest of the submission
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"submittingOtherSections" object:nil];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"******UNSUCCESSFUL SUBMISSION******!!");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSLog(@"error: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
        failCounter++;
        if (failCounter==1) {
            //            [hud hideAnimated:YES];     //stop showing the progressindicator
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
            
        }
        
    };
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

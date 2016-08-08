//
//  PreRegDisplayFormViewController.m
//  NHS
//
//  Created by Mac Pro on 8/7/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "PreRegDisplayFormViewController.h"
#import "ServerComm.h"
#import "XLForm.h"
#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

NSString *const qName = @"name";
NSString *const qNRIC = @"nric";
NSString *const qGender = @"gender";
NSString *const qDOB = @"dob";
NSString *const qSpokenLanguage = @"spokenlanguage";
NSString *const qSpokenLangOthers = @"spokenlangothers";
NSString *const qContactNumber = @"contactnumber";
NSString *const qAddStreet = @"addressstreet";
NSString *const qAddBlock = @"addressblock";
NSString *const qAddUnit = @"addressunit";
NSString *const qAddPostCode = @"addresspostcode";
NSString *const qReqServOthers = @"reqservothers";
NSString *const qPhleb = @"phleb";
NSString *const qFOBT = @"fobt";
NSString *const qDental = @"dental";
NSString *const qEye = @"eye";
NSString *const qPrefDate = @"preferreddate";
NSString *const qPrefTime = @"preferredtime";
NSString *const qNeighbourhood = @"neighbourhood";
NSString *const qRemarks = @"remarks";


typedef enum preRegSection {
    personalInfo,
    spokenLang,
    contactInfo,
    reqServ,
    others
} preRegSection;

//#pragma mark - NSValueTransformer
//
//@interface NSArrayValueTrasformer : NSValueTransformer
//@end
//
//@implementation NSArrayValueTrasformer
//
//+ (Class)transformedValueClass
//{
//    return [NSString class];
//}
//
//+ (BOOL)allowsReverseTransformation
//{
//    return NO;
//}
//
//- (id)transformedValue:(id)value
//{
//    if (!value) return nil;
//    if ([value isKindOfClass:[NSArray class]]){
//        NSArray * array = (NSArray *)value;
//        return [NSString stringWithFormat:@"%@ Item%@", @(array.count), array.count > 1 ? @"s" : @""];
//    }
//    if ([value isKindOfClass:[NSString class]])
//    {
//        return [NSString stringWithFormat:@"%@", value];        //removed the word transformed
//    }
//    return nil;
//}
//
//@end
//
//
//@interface ISOLanguageCodesValueTranformer : NSValueTransformer
//@end
//
//@implementation ISOLanguageCodesValueTranformer
//
//+ (Class)transformedValueClass
//{
//    return [NSString class];
//}
//
//+ (BOOL)allowsReverseTransformation
//{
//    return NO;
//}
//
//- (id)transformedValue:(id)value
//{
//    if (!value) return nil;
//    if ([value isKindOfClass:[NSString class]]){
//        return [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:value];
//    }
//    return nil;
//}
//
//@end


@interface PreRegDisplayFormViewController () {
    bool flag;
}

@property (strong, nonatomic) NSNumber *resident_id;
@property (nonatomic) preRegSection *preRegSection;
@property (strong, nonatomic) NSMutableArray *completePreRegForm;
@property (strong, nonatomic) NSDictionary *retrievedPatientDictionary;


@end

@implementation PreRegDisplayFormViewController


-(id)init
{
    NSDictionary *personal_info = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"personal_info"]];
    NSDictionary *contact_info = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"contact_info"]];
//    NSDictionary *others_prereg = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"others_prereg"]];
    NSDictionary *required_services = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"required_services"]];
    NSDictionary *spoken_lang = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"spoken_lang"]];
    
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Pre-reg Form"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    [formDescriptor setDisabled:YES];
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Personal Info"];
    [formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qName rowType:XLFormRowDescriptorTypeText title:@"Patient Name"];
    row.required = YES;
    row.value = [personal_info objectForKey:@"resident_name"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    row.required = YES;
    row.value = [personal_info objectForKey:@"nric"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qGender rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    if ([[personal_info objectForKey:@"gender"] isEqualToString:@"M"]) {
        row.value = @"Male";
    } else {
        row.value = @"Female";
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qDOB rowType:XLFormRowDescriptorTypeText title:@"DOB Year"];
    row.required = YES;
    row.value = [personal_info objectForKey:@"birth_year"];
    [section addFormRow:row];
    
    
    // Spoken Language - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Spoken Language *"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:qSpokenLanguage rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    row.required = YES;
    [section addFormRow:spokenLangRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qSpokenLangOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", spokenLangRow];
    [section addFormRow:row];
    
    // Contact Info - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Contact Info"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qContactNumber rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"contact_no"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qAddStreet rowType:XLFormRowDescriptorTypeText title:@"Address Street"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"address_street"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qAddUnit rowType:XLFormRowDescriptorTypeText title:@"Address Block"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"address_block"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qAddBlock rowType:XLFormRowDescriptorTypeText title:@"Address Unit"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"address_unit"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qAddPostCode rowType:XLFormRowDescriptorTypeNumber title:@"Address Post Code"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"address_postcode"];
    [section addFormRow:row];
    
    // Required Services - Section
    //    section = [XLFormSectionDescriptor formSectionWithTitle:@"Required Services"];
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Required Services"
                                             sectionOptions:XLFormSectionOptionCanInsert
                                          sectionInsertMode:XLFormSectionInsertModeButton];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qPhleb rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Phleb"];
    row.value = @(NO);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qFOBT rowType:XLFormRowDescriptorTypeBooleanCheck title:@"FOBT"];
    row.value = @(NO);
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qDental rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dental"];
    row.value = @(NO);
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qEye rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Eye"];
    row.value = @(NO);
    [section addFormRow:row];
    
    //    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReqServOthers rowType:XLFormRowDescriptorTypeTextView title:@"Others: -"];
    //    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qReqServOthers rowType:XLFormRowDescriptorTypeText];
    [[row cellConfig] setObject:@"Add other services" forKey:@"textField.placeholder"];
    section.multivaluedRowTemplate = row;
    
    // Others - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Others"];
    [formDescriptor addFormSection:section];
    
    
    // Date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qPrefDate rowType:XLFormRowDescriptorTypeDateInline title:@"Preferred Date"];
    row.value = [NSDate new];
    row.required = YES;
    [section addFormRow:row];
    
    //    // Preferred Time
    XLFormRowDescriptor *preferredTimeRow;
    preferredTimeRow = [XLFormRowDescriptor formRowDescriptorWithTag:qPrefTime rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Preferred Time"];
    preferredTimeRow.selectorOptions = @[@"9-11", @"11-1", @"1-3"];
    preferredTimeRow.required = YES;
    [section addFormRow:preferredTimeRow];
    
    //    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPrefTime rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Preferred Time"];
    //    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"9-11"],
    //                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"11-1"],
    //                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"1-3"]
    //                            ];
    //    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"9-11"];
    //    row.required = YES;
    //    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qNeighbourhood rowType:XLFormRowDescriptorTypeText title:@"Neighbourhood"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qRemarks rowType:XLFormRowDescriptorTypeTextView title:@"Remarks:-"];
    row.required = NO;
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
    
}

-(void)viewDidLoad
{
    flag = false;
    self.retrievedPatientDictionary = [[NSDictionary alloc] init];
    [self getPatientData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];
    self.completePreRegForm = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(submitOtherSections:)
                                                 name:@"submitOtherSections"
                                               object:nil];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        XLFormDescriptor *form = [self init];       //must init first before [super viewDidLoad]
        [super viewDidLoad];
    });
    
}

-(void)backBtnPressed:(id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                              message:@"Are you sure?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)editPressed:(UIBarButtonItem * __unused)button
{
#warning currently do nothing
//    NSArray * validationErrors = [self formValidationErrors];
//    if (validationErrors.count > 0){
//        [self showFormValidationError:[validationErrors firstObject]];
//        return;
//    }
//    [self.tableView endEditing:YES];
//    [self submitPersonalInfo:[self preparePersonalInfoDict]];
    
    //#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    //    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Valid Form", nil)
    //                                                      message:@"No errors found"
    //                                                     delegate:nil
    //                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
    //                                            otherButtonTitles:nil];
    //    [message show];
    //#else
    //    if ([UIAlertController class]){
    //        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Valid Form", nil)
    //                                                                                  message:@"No errors found"
    //                                                                           preferredStyle:UIAlertControllerStyleAlert];
    //        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
    //                                                            style:UIAlertActionStyleDefault
    //                                                          handler:nil]];
    //        [self presentViewController:alertController animated:YES completion:nil];
    //
    //    }
    //    else{
    //        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Valid Form", nil)
    //                                                          message:@"No errors found"
    //                                                         delegate:nil
    //                                                cancelButtonTitle:NSLocalizedString(@"OK", nil)
    //                                                otherButtonTitles:nil];
    //        [message show];
    //    }
    //#endif
    
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Uploading

- (void) submitPersonalInfo:(NSDictionary *) dict {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postPersonalInfoWithDict:dict
                       progressBlock:[self progressBlock]
                        successBlock:[self personalInfoSuccessBlock]
                        andFailBlock:[self errorBlock]];
}

- (void)submitOtherSections:(NSNotification *) notification{
    
    self.completePreRegForm = [self prepareDictionaryFile];
    ServerComm *client = [ServerComm sharedServerCommInstance];
    
    [client postSpokenLangWithDict:[self.completePreRegForm objectAtIndex:spokenLang]
                     progressBlock:[self progressBlock]
                      successBlock:[self successBlock]
                      andFailBlock:[self errorBlock]];
    
    [client postContactInfoWithDict:[self.completePreRegForm objectAtIndex:contactInfo]
                      progressBlock:[self progressBlock]
                       successBlock:[self successBlock]
                       andFailBlock:[self errorBlock]];
    
    [client postReqServWithDict:[self.completePreRegForm objectAtIndex:reqServ]
                  progressBlock:[self progressBlock]
                   successBlock:[self successBlock]
                   andFailBlock:[self errorBlock]];
    
    [client postOthersWithDict:[self.completePreRegForm objectAtIndex:others]
                 progressBlock:[self progressBlock]
                  successBlock:[self successBlock]
                  andFailBlock:[self errorBlock]];
}

- (void) submitContactInfo: (NSTimer *) time{
    
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                            object:nil
                                                          userInfo:nil];
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))personalInfoSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"Personal info submission success");
        self.resident_id = [responseObject objectForKey:@"resident_id"];
        NSLog(@"I'm resident %@", self.resident_id);
        
        //after success submitting personal info, get resident_id and submit the rest
        [[NSNotificationCenter defaultCenter] postNotificationName:@"submitOtherSections"
                                                            object:nil
                                                          userInfo:nil];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"unsuccessful");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSLog(@"error: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
    };
}


#pragma mark -
- (NSDictionary *) preparePersonalInfoDict {
    
    NSDictionary *personalInfoDict = [[NSDictionary alloc] init];
    NSDictionary *dict = [[NSDictionary alloc] init];
    NSString *gender = [[NSString alloc] init];
    
    if ([[[self.form formValues] objectForKey:@"gender"] isEqualToString:@"Male"]) {
        gender = @"M";
    } else {
        gender = @"F";
    }
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    dict = @{@"resident_name":[[self.form formValues] objectForKey:@"name"],
             @"nric":[[self.form formValues] objectForKey:@"nric"],
             @"gender":gender,
             @"birth_year":[[self.form formValues] objectForKey:@"dob"],
             @"ts":[localDateTime description]      //changed to NSString
             };
    
    personalInfoDict = @{@"personal_info":dict};
    [self.completePreRegForm removeAllObjects];
    [self.completePreRegForm addObject:personalInfoDict];
    
    return personalInfoDict;
}

- (NSMutableArray *) prepareDictionaryFile {
    int i;
    NSDictionary *spokenLangDict = [[NSDictionary alloc] init];
    NSDictionary *contactInfoDict = [[NSDictionary alloc] init];
    NSDictionary *reqServDict = [[NSDictionary alloc] init];
    NSDictionary *othersDict = [[NSDictionary alloc] init];
    NSDictionary *dict = [[NSDictionary alloc] init];
    NSMutableDictionary *mutaDict = [[NSMutableDictionary alloc] init];
    
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    
    //Spoken Language
    localDateTime = [NSDate dateWithTimeInterval:1.0 sinceDate:localDateTime];      //add a second
    if ([[self.form formValues] objectForKey:@"spokenlanguage"] != (id)[NSNull null]) {
        //Spoken Languages
        dict = @{@"resident_id":self.resident_id,
                 @"lang_canto":@"0",
                 @"lang_english":@"0",
                 @"lang_hindi":@"0",
                 @"lang_hokkien":@"0",
                 @"lang_malay":@"0",
                 @"lang_mandrin":@"0",
                 @"lang_tamil":@"0",
                 @"lang_teochew":@"0",
                 @"lang_others":@"0",
                 @"lang_others_text":@"",
                 @"ts":[localDateTime description]};
        mutaDict = [dict mutableCopy];
        
        NSArray *spokenLangArray = [[NSArray alloc] initWithArray:[[self.form formValues] objectForKey:@"spokenlanguage"]]; //this will get array
        for (i=0; i<[spokenLangArray count]; i++) {
            
            if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Cantonese"]) [mutaDict setValue:@"1" forKey:@"lang_canto"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"English"]) [mutaDict setValue:@"1" forKey:@"lang_english"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hindi"]) [mutaDict setValue:@"1" forKey:@"lang_hindi"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Hokkien"]) [mutaDict setValue:@"1" forKey:@"lang_hokkien"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Malay"]) [mutaDict setValue:@"1" forKey:@"lang_malay"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Mandarin"]) [mutaDict setValue:@"1" forKey:@"lang_mandrin"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Teochew"]) [mutaDict setValue:@"1" forKey:@"lang_teochew"];
            else if([[spokenLangArray objectAtIndex:i] isEqualToString:@"Others"]) [mutaDict setValue:@"1" forKey:@"lang_others"];
        }
        if ([[self.form formValues] objectForKey:@"spokenlangothers"] != (id)[NSNull null]) {
            [mutaDict setValue:[[self.form formValues] objectForKey:@"spokenlangothers"] forKey:@"lang_others_text"];   //copy the other languages
        }
        dict = [NSDictionary dictionaryWithDictionary:mutaDict];
        spokenLangDict = @{@"spoken_lang":dict};
    }
    
    //Contact Info
    localDateTime = [NSDate dateWithTimeInterval:1.0 sinceDate:localDateTime];      //add a second
    dict = @{@"resident_id":self.resident_id,
             @"contact_no":[[self.form formValues] objectForKey:@"contactnumber"],
             @"address_street":[[self.form formValues] objectForKey:@"addressstreet"],
             @"address_block":[[self.form formValues] objectForKey:@"addressblock"],
             @"address_unit":[[self.form formValues] objectForKey:@"addressunit"],
             @"address_postcode":[[self.form formValues] objectForKey:@"addresspostcode"],
             @"ts":[localDateTime description]      //changed to NSString
             };
    
    contactInfoDict = @{@"contact_info":dict};
    
    //Required Services
    localDateTime = [NSDate dateWithTimeInterval:1.0 sinceDate:localDateTime];      //add a second
    dict = @{@"resident_id":self.resident_id,
             @"pleb":[[self.form formValues] objectForKey:@"phleb"],
             @"fobt":[[self.form formValues] objectForKey:@"fobt"],
             @"dental":[[self.form formValues] objectForKey:@"dental"],
             @"eye":[[self.form formValues] objectForKey:@"eye"],
             @"other_services":@"",
             @"ts":[localDateTime description]
             };
    
    if ([[self.form formValues] objectForKey:@"reqservothers"] != nil) {        //check if it's added first..
        [dict setValue:[[self.form formValues] objectForKey:@"reqservothers"] forKey:@"other_services"];
    }
    
    reqServDict = @{@"required_services":dict};
    
    //Others
    localDateTime = [NSDate dateWithTimeInterval:1.0 sinceDate:localDateTime];      //add a second
    dict = @{@"resident_id":self.resident_id,
             @"pref_date":[[[self.form formValues] objectForKey:@"preferreddate"] description],
             //             @"pref_time":[NSString stringWithFormat:@"%@", [[[self.form formValues] objectForKey:@"preferredtime"] formValue]],
#warning need to update this once op-code 57 updated...
             @"pref_time":[NSString stringWithFormat:@"9-11"],      //FOR NOW!
             @"neighbourhood":[[self.form formValues] objectForKey:@"neighbourhood"],
             @"remarks":@"",
             @"ts":[localDateTime description]
             };
    if ([[self.form formValues] objectForKey:@"remarks"] != (id)[NSNull null]) {
        mutaDict = [dict mutableCopy];
        [mutaDict setValue:[[self.form formValues] objectForKey:@"remarks"] forKey:@"remarks"];
        dict = mutaDict;
    }
    
    othersDict = @{@"others_prereg":dict};
    
    [self.completePreRegForm addObject:spokenLangDict];
    [self.completePreRegForm addObject:contactInfoDict];
    [self.completePreRegForm addObject:reqServDict];
    [self.completePreRegForm addObject:othersDict];
    
    return self.completePreRegForm;
}


#pragma mark - Downloading Patient Details
- (void)getPatientData {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getPatientDataWithPatientID:self.patientID
                          progressBlock:[self progressBlock]
                           successBlock:[self downloadSuccessBlock]
                           andFailBlock:[self errorBlock]];
}


#pragma mark - Downloading Blocks


- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSArray *data = responseObject;      //somehow double brackets... (())
        self.retrievedPatientDictionary = data[0];
        NSLog(@"%@", self.retrievedPatientDictionary);
        flag = true;
        
    };
}







@end

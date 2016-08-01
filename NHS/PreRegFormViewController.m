//
//  PreRegFormViewController.m
//  NHS
//
//  Created by Nicholas on 7/30/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "PreRegFormViewController.h"
#import "ServerComm.h"

//XLForms stuffs
#import "XLForm.h"
//#import "XLForm/InputsFormViewController.h"
//#import "SelectorsFormViewController.h"
//#import "OthersFormViewController.h"
//#import "DatesFormViewController.h"
//#import "MultiValuedFormViewController.h"
//#import "ExamplesFormViewController.h"
//#import "NativeEventFormViewController.h"
///#import "UICustomizationFormViewController.h"
//#import "CustomRowsViewController.h"
//#import "AccessoryViewFormViewController.h"
//#import "PredicateFormViewController.h"
//#import "FormattersViewController.h"
#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

NSString *const kName = @"name";
NSString *const kNRIC = @"nric";
NSString *const kGender = @"gender";
NSString *const kDOB = @"dob";
NSString *const kSpokenLanguage = @"spokenlanguage";
NSString *const kSpokenLangOthers = @"spokenlangothers";
NSString *const kContactNumber = @"contactnumber";
NSString *const kAddStreet = @"addressstreet";
NSString *const kAddBlock = @"addressblock";
NSString *const kAddUnit = @"addressunit";
NSString *const kAddPostCode = @"addresspostcode";
NSString *const kReqServOthers = @"reqservothers";
NSString *const kPhleb = @"phleb";
NSString *const kFOBT = @"fobt";
NSString *const kDental = @"dental";
NSString *const kEye = @"eye";
NSString *const kPrefDate = @"preferreddate";
NSString *const kPrefTime = @"preferredtime";
NSString *const kNeighbourhood = @"neighbourhood";
NSString *const kRemarks = @"remarks";


typedef enum preRegSection {
    personalInfo,
    spokenLang,
    contactInfo,
    reqServ,
    others
} preRegSection;

#pragma mark - NSValueTransformer

@interface NSArrayValueTrasformer : NSValueTransformer
@end

@implementation NSArrayValueTrasformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (!value) return nil;
    if ([value isKindOfClass:[NSArray class]]){
        NSArray * array = (NSArray *)value;
        return [NSString stringWithFormat:@"%@ Item%@", @(array.count), array.count > 1 ? @"s" : @""];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"%@", value];        //removed the word transformed
    }
    return nil;
}

@end


@interface ISOLanguageCodesValueTranformer : NSValueTransformer
@end

@implementation ISOLanguageCodesValueTranformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (!value) return nil;
    if ([value isKindOfClass:[NSString class]]){
        return [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:value];
    }
    return nil;
}

@end


@interface PreRegFormViewController ()

@property (strong, nonatomic) NSNumber *resident_id;
@property (nonatomic) preRegSection *preRegSection;
@property (strong, nonatomic) NSMutableArray *completePreRegForm;

@end

@implementation PreRegFormViewController 

-(id)init
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Pre-Registration"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Personal Info"];
//    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"Patient Name"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    row.value = @"Male";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDOB rowType:XLFormRowDescriptorTypeText title:@"DOB Year"];
    row.required = YES;
    [section addFormRow:row];
    
    
    // Spoken Language - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Spoken Language *"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLanguage rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    row.required = YES;
    [section addFormRow:spokenLangRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLangOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", spokenLangRow];
    [section addFormRow:row];
    
    // Contact Info - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Contact Info"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kContactNumber rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddStreet rowType:XLFormRowDescriptorTypeText title:@"Address Street"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddUnit rowType:XLFormRowDescriptorTypeText title:@"Address Block"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddBlock rowType:XLFormRowDescriptorTypeText title:@"Address Unit"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddPostCode rowType:XLFormRowDescriptorTypeNumber title:@"Address Post Code"];
    row.required = YES;
    [section addFormRow:row];
    
    // Required Services - Section
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"Required Services"];
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Required Services"
                                             sectionOptions:XLFormSectionOptionCanInsert
                                          sectionInsertMode:XLFormSectionInsertModeButton];
    [formDescriptor addFormSection:section];

    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhleb rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Phleb"];
    row.value = @(NO);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFOBT rowType:XLFormRowDescriptorTypeBooleanCheck title:@"FOBT"];
    row.value = @(NO);
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDental rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dental"];
    row.value = @(NO);
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEye rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Eye"];
    row.value = @(NO);
    [section addFormRow:row];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReqServOthers rowType:XLFormRowDescriptorTypeTextView title:@"Others: -"];
//    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReqServOthers rowType:XLFormRowDescriptorTypeText];
    [[row cellConfig] setObject:@"Add other services" forKey:@"textField.placeholder"];
    section.multivaluedRowTemplate = row;
    
    // Others - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Others"];
    [formDescriptor addFormSection:section];
    
    
    // Date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPrefDate rowType:XLFormRowDescriptorTypeDateInline title:@"Preferred Date"];
    row.value = [NSDate new];
    row.required = YES;
    [section addFormRow:row];
    
//    // Preferred Time
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPrefTime rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Preferred Time"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"9-11"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"11-1"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"1-3"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"9-11"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourhood rowType:XLFormRowDescriptorTypeText title:@"Neighbourhood"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRemarks rowType:XLFormRowDescriptorTypeTextView title:@"Remarks:-"];
    row.required = NO;
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
    
}

-(void)viewDidLoad
{
    XLFormDescriptor *form = [self init];       //must init first before [super viewDidLoad]
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitPressed:)];
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];
    self.completePreRegForm = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(submitOtherSections:)
                                                 name:@"submitOtherSections"
                                               object:nil];
    [super viewDidLoad];
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


-(void)submitPressed:(UIBarButtonItem * __unused)button
{
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
        return;
    }
    [self.tableView endEditing:YES];
    [self submitPersonalInfo:[self preparePersonalInfoDict]];
    
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

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
             @"pref_time":[NSString stringWithFormat:@"%@", [[[self.form formValues] objectForKey:@"preferredtime"] formValue]],
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




@end

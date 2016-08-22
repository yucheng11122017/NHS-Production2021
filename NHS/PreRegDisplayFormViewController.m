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
#import "MBProgressHUD.h"


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
NSString *const qInsertedOtherReqServ = @"insertedotherreqserv";
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


@interface PreRegDisplayFormViewController () {
    bool flag;
    MBProgressHUD *hud;
    int successCounter;
}

@property (strong, nonatomic) NSNumber *resident_id;
@property (nonatomic) preRegSection *preRegSection;
@property (strong, nonatomic) NSMutableArray *completePreRegForm;
@property (strong, nonatomic) NSDictionary *retrievedPatientDictionary;
@property (strong, nonatomic) XLFormDescriptor * formDescriptor;


@end

@implementation PreRegDisplayFormViewController

-(void)viewDidLoad
{
    flag = false;
    self.retrievedPatientDictionary = [[NSDictionary alloc] init];
    [self getPatientData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(editPressed:)];
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnPressed:)];
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

-(id)init
{
    NSDictionary *personal_info = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"personal_info"]];
    NSDictionary *spoken_lang, *required_services, *contact_info, *others_prereg;
    
    contact_info = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"contact_info"]];
    
    if([self.retrievedPatientDictionary objectForKey:@"others_prereg"] != (id)[NSNull null]) {
        others_prereg = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"others_prereg"]];
    }
    spoken_lang = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"spoken_lang"]];
    
    if([self.retrievedPatientDictionary objectForKey:@"required_services"] != (id)[NSNull null]) {
        required_services = [[NSDictionary alloc] initWithDictionary:[self.retrievedPatientDictionary objectForKey:@"required_services"]];
    }
    
    
    self.formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Pre-reg Form"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    [self.formDescriptor setDisabled:YES];
    
    self.formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Personal Info"];
    [self.formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qName rowType:XLFormRowDescriptorTypeText title:@"Patient Name"];
    row.required = YES;
    row.value = [personal_info objectForKey:@"resident_name"]? [personal_info objectForKey:@"resident_name"]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    row.required = YES;
    row.value = [personal_info objectForKey:@"nric"]? [personal_info objectForKey:@"nric"]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qGender rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    if ([personal_info objectForKey:@"nric"]!= (id)[NSNull null]) {
        if ([[personal_info objectForKey:@"gender"] isEqualToString:@"M"]) {
            row.value = @"Male";
        } else {
            row.value = @"Female";
        }
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qDOB rowType:XLFormRowDescriptorTypeText title:@"DOB Year"];
    row.required = YES;
    row.value = [personal_info objectForKey:@"birth_year"]? [personal_info objectForKey:@"birth_year"]:@"";
    [section addFormRow:row];
    
    // Spoken Language - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Spoken Language *"];
    [self.formDescriptor addFormSection:section];
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:qSpokenLanguage rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    spokenLangRow.required = YES;
    if ([spoken_lang objectForKey:@"lang_canto"] != (id)[NSNull null]) {
        spokenLangRow.value = [self getSpokenLangArray:spoken_lang];
    }
    [section addFormRow:spokenLangRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qSpokenLangOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", spokenLangRow];
    if ([spoken_lang objectForKey:@"lang_others_text"] != (id)[NSNull null]) {  //if not null
        row.value = [spoken_lang objectForKey:@"lang_others_text"];
    }
    [section addFormRow:row];
    
    // Contact Info - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Contact Info"];
    [self.formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qContactNumber rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"contact_no"]? [contact_info objectForKey:@"contact_no"]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qAddStreet rowType:XLFormRowDescriptorTypeText title:@"Address Street"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"address_street"]? [contact_info objectForKey:@"address_street"]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qAddBlock rowType:XLFormRowDescriptorTypeText title:@"Address Block"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"address_block"]? [contact_info objectForKey:@"address_block"]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qAddUnit rowType:XLFormRowDescriptorTypeText title:@"Address Unit"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"address_unit"]? [contact_info objectForKey:@"address_unit"]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qAddPostCode rowType:XLFormRowDescriptorTypeNumber title:@"Address Post Code"];
    row.required = YES;
    row.value = [contact_info objectForKey:@"address_postcode"]? [contact_info objectForKey:@"address_postcode"]:@"";
    [section addFormRow:row];
    
    // Required Services - Section
    //    section = [XLFormSectionDescriptor formSectionWithTitle:@"Required Services"];
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Required Services"
                                             sectionOptions:XLFormSectionOptionCanInsert
                                          sectionInsertMode:XLFormSectionInsertModeButton];
    [self.formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qPhleb rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Phleb"];
    if (required_services != (id)[NSNull null]) {
        row.value = [required_services objectForKey:@"pleb"];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qFOBT rowType:XLFormRowDescriptorTypeBooleanCheck title:@"FOBT"];
    if (required_services != (id)[NSNull null]) {
        row.value = [required_services objectForKey:@"fobt"];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qDental rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dental"];
    if (required_services != (id)[NSNull null]) {
        row.value = [required_services objectForKey:@"dental"];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qEye rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Eye"];
    if (required_services != (id)[NSNull null]) {
        row.value = [required_services objectForKey:@"eye"];
    }
    [section addFormRow:row];
    
    if (required_services != (id)[NSNull null]) {
        if ([required_services objectForKey:@"other_services"] != (id)[NSNull null]) {
            if ([[required_services objectForKey:@"other_services"] isEqualToString:@"1"]) {    //only if database indicate that the other_services was indeed inserted...
                row = [XLFormRowDescriptor formRowDescriptorWithTag:qInsertedOtherReqServ rowType:XLFormRowDescriptorTypeText];
                row.value = @"Extra";
                [section addFormRow:row];
            }
        }
    }
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qReqServOthers rowType:XLFormRowDescriptorTypeText];
    [[row cellConfig] setObject:@"Add other services" forKey:@"textField.placeholder"];
    section.multivaluedRowTemplate = row;
    
    // Others - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Others"];
    [self.formDescriptor addFormSection:section];
    
    
    // Date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qPrefDate rowType:XLFormRowDescriptorTypeDateInline title:@"Preferred Date"];
    row.required = YES;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    if ([others_prereg objectForKey:@"pref_date"] != (id)[NSNull null]) {
        row.value = [dateFormatter dateFromString:[others_prereg objectForKey:@"pref_date"]];

    }
    [section addFormRow:row];
    
    //    // Preferred Time
    XLFormRowDescriptor *preferredTimeRow;
    preferredTimeRow = [XLFormRowDescriptor formRowDescriptorWithTag:qPrefTime rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Preferred Time"];
    preferredTimeRow.selectorOptions = @[@"9-11", @"11-1", @"1-3"];
    preferredTimeRow.required = YES;
    if(others_prereg != (id)[NSNull null]) {
        if ([others_prereg objectForKey:@"time_slot_9_11"] != (id)[NSNull null]) {
            preferredTimeRow.value = [self getPreferredTimeArray:others_prereg];
        }
    }
    [section addFormRow:preferredTimeRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qNeighbourhood rowType:XLFormRowDescriptorTypeText title:@"Neighbourhood"];
    row.required = YES;
    if(others_prereg != (id)[NSNull null]) {
        row.value = [others_prereg objectForKey:@"neighbourhood"]? [others_prereg objectForKey:@"neighbourhood"]:@"";
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:qRemarks rowType:XLFormRowDescriptorTypeTextView title:@"Remarks:-"];
    row.required = NO;
    NSString *remarks;
    if(others_prereg != (id)[NSNull null]) {
        remarks = [others_prereg objectForKey:@"remarks"];
    }
    
    if (remarks == (id)[NSNull null] || remarks.length == 0 ) {
        row.value = @"";
        NSLog(@"remarks is NULL");
    } else {
        row.value = [others_prereg objectForKey:@"remarks"];
    }
    [section addFormRow:row];
    
    
    return [super initWithForm:self.formDescriptor];
    
}

-(void)backBtnPressed:(id)sender
{
//    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancel", nil)
//                                                                              message:@"Are you sure?"
//                                                                       preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
//                                                        style:UIAlertActionStyleDefault
//                                                      handler:^(UIAlertAction * action) {
//                                                          
//                                                      }]];
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
//                                                        style:UIAlertActionStyleCancel
//                                                      handler:nil]];
//    [self presentViewController:alertController animated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)editPressed:(UIBarButtonItem * __unused)button
{
    if(self.form.isDisabled) {
        [button setTitle:@"Save"];
    } else {
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
            return;
        }
        //    if (validationErrors.count > 0){
        //        [self showFormValidationError:[validationErrors firstObject]];
        //        return;
        //    }
        [self.tableView endEditing:YES];
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Set the label text.
        hud.label.text = NSLocalizedString(@"Uploading...", @"HUD loading title");
        [self submitPersonalInfo:[self preparePersonalInfoDict]];
        
        [button setTitle:@"Edit"];
    }
    
    self.form.disabled = !self.form.disabled;
    [self.tableView endEditing:YES];
    [self.tableView reloadData];
    
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
        successCounter++;
        if(successCounter == 4) {
            NSLog(@"SUBMISSION SUCCESSFUL!!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Uploaded", nil)
                                                                                      message:@"Pre-registration successful!"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * okAction) {
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                                                                                      object:nil
                                                                                                                    userInfo:nil];
//                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                              }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"******UNSUCCESSFUL SUBMISSION******!!");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSString *errorString =[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSLog(@"error: %@", errorString);
        [hud hideAnimated:YES];     //stop showing the progressindicator
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Upload Fail", nil)
                                                                                  message:@"Update form failed!"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction) {
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                                                                                  object:nil
                                                                                                                userInfo:nil];
                                                              //                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    };
}

#pragma mark Downloading Blocks


- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        self.retrievedPatientDictionary = [responseObject objectForKey:@"0"];
        NSLog(@"%@", self.retrievedPatientDictionary);
        flag = true;
        
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

#pragma mark -
- (NSArray *) getSpokenLangArray: (NSDictionary *) spoken_lang {
    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
    if([[spoken_lang objectForKey:@"lang_canto"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
    if([[spoken_lang objectForKey:@"lang_english"] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
    if([[spoken_lang objectForKey:@"lang_hindi"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
    if([[spoken_lang objectForKey:@"lang_hokkien"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
    if([[spoken_lang objectForKey:@"lang_malay"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
    if([[spoken_lang objectForKey:@"lang_mandrin"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
    if([[spoken_lang objectForKey:@"lang_others"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Others"];
    if([[spoken_lang objectForKey:@"lang_tamil"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
    if([[spoken_lang objectForKey:@"lang_teochew"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
    
    return spokenLangArray;
}

- (NSArray *) getPreferredTimeArray: (NSDictionary *) others_prereg {
    NSMutableArray *preferredTimeArray = [[NSMutableArray alloc] init];
    if([[others_prereg objectForKey:@"time_slot_9_11"] isEqualToString:@"1"]) [preferredTimeArray addObject:@"9-11"];
    if([[others_prereg objectForKey:@"time_slot_11_1"] isEqualToString:@"1"]) [preferredTimeArray addObject:@"11-1"];
    if([[others_prereg objectForKey:@"time_slot_1_3"] isEqualToString:@"1"]) [preferredTimeArray addObject:@"1-3"];
    
    return preferredTimeArray;
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
    
    NSMutableArray *otherServicesArray = [[NSMutableArray alloc] initWithArray:[[self.form formValues]objectForKey:@"otherservices"]];
    [otherServicesArray removeObjectsInArray:@[@0,@0,@0,@0]];
#warning though the code is ready, yet API no where to insert other required services.
    NSString *otherServices = @"0";
    if([otherServicesArray count] > 1) {
        otherServices = @"1";
    }
    //Required Services
    localDateTime = [NSDate dateWithTimeInterval:1.0 sinceDate:localDateTime];      //add a second
    dict = @{@"resident_id":self.resident_id,
             @"pleb":[[self.form formValues] objectForKey:@"phleb"],
             @"fobt":[[self.form formValues] objectForKey:@"fobt"],
             @"dental":[[self.form formValues] objectForKey:@"dental"],
             @"eye":[[self.form formValues] objectForKey:@"eye"],
             @"other_services":otherServices,
             @"ts":[localDateTime description]
             };
    
    if ([[self.form formValues] objectForKey:@"reqservothers"] != nil) {        //check if it's added first..
        [dict setValue:[[self.form formValues] objectForKey:@"reqservothers"] forKey:@"other_services"];
    }
    
    reqServDict = @{@"required_services":dict};
    
    //Others
    NSNumber *nineToEleven = @0, *elevenToOne = @0, *OneToThree = @0;
    NSArray *timeSlotChoice = [[self.form formValues] objectForKey:@"preferredtime"];
    for (i=0; i<[timeSlotChoice count]; i++) {
        if ([[timeSlotChoice objectAtIndex:i] isEqualToString:@"9-11"]) nineToEleven = @1;
        else if ([[timeSlotChoice objectAtIndex:i] isEqualToString:@"11-1"]) elevenToOne = @1;
        else if ([[timeSlotChoice objectAtIndex:i] isEqualToString:@"1-3"]) OneToThree = @1;
        
    }
    localDateTime = [NSDate dateWithTimeInterval:1.0 sinceDate:localDateTime];      //add a second
    dict = @{@"resident_id":self.resident_id,
             @"pref_date":[[[self.form formValues] objectForKey:@"preferreddate"] description],
             @"time_slot_9_11":nineToEleven,
             @"time_slot_11_1":elevenToOne,
             @"time_slot_1_3":OneToThree,
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


@end

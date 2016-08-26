//
//  PreRegFormViewController.m
//  NHS
//
//  Created by Nicholas on 7/30/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "PreRegFormViewController.h"
#import "ServerComm.h"
#import "MBProgressHUD.h"

//XLForms stuffs
#import "XLForm.h"
#import "AppConstants.h"

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

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


@interface PreRegFormViewController () {
    int successCounter, failCounter;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSNumber *resident_id;
@property (nonatomic) preRegSection *preRegSection;
@property (strong, nonatomic) NSMutableArray *completePreRegForm;
@property (strong, nonatomic) NSDictionary *retrievedPatientDictionary;
@property (strong, nonatomic) NSString *loadedFilepath;

@end

@implementation PreRegFormViewController 

-(void)viewDidLoad
{
    [self loadDraftIfAny];
    XLFormDescriptor *form = [self init];       //must init first before [super viewDidLoad]
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitPressed:)];
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];
    self.completePreRegForm = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(submitOtherSections:)
                                                 name:@"submittingOtherSections"
                                               object:nil];
    [super viewDidLoad];
}

-(id)init
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New Pre-reg Form"];
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
    row.value = [self.retrievedPatientDictionary objectForKey:kName]? [self.retrievedPatientDictionary objectForKey:kName]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    row.value = [self.retrievedPatientDictionary objectForKey:kNRIC]? [self.retrievedPatientDictionary objectForKey:kNRIC]:@"";
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    row.value = [self.retrievedPatientDictionary objectForKey:kGender]? [self.retrievedPatientDictionary objectForKey:kGender]:@"Male";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDOB rowType:XLFormRowDescriptorTypeInteger title:@"DOB Year"];
    row.required = YES;
    row.value = [self.retrievedPatientDictionary objectForKey:kDOB]? [self.retrievedPatientDictionary objectForKey:kDOB]:@"";
    [section addFormRow:row];
    
    
    // Spoken Language - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Spoken Language *"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor * spokenLangRow;
    spokenLangRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLanguage rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Spoken Language"];
    spokenLangRow.selectorOptions = @[@"Cantonese", @"English", @"Hindi", @"Hokkien", @"Malay", @"Mandarin", @"Tamil", @"Teochew", @"Others"];
    row.required = YES;
    spokenLangRow.value = [self.retrievedPatientDictionary objectForKey:kSpokenLanguage]? [self.retrievedPatientDictionary objectForKey:kSpokenLanguage]:@[] ;
    [section addFormRow:spokenLangRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpokenLangOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.value = [self.retrievedPatientDictionary objectForKey:kSpokenLangOthers]? [self.retrievedPatientDictionary objectForKey:kSpokenLangOthers]:@"" ;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", spokenLangRow];
    [section addFormRow:row];
    
    // Contact Info - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Contact Info"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kContactNumber rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
    row.required = YES;
    row.value = [self.retrievedPatientDictionary objectForKey:kContactNumber]? [self.retrievedPatientDictionary objectForKey:kContactNumber]:@"";
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Contact number must be 8 digits" regex:@"^(?=.*\\d).{8}$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddStreet rowType:XLFormRowDescriptorTypeText title:@"Address Street"];
    row.required = YES;
    row.value = [self.retrievedPatientDictionary objectForKey:kAddStreet]? [self.retrievedPatientDictionary objectForKey:kAddStreet]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddBlock rowType:XLFormRowDescriptorTypeText title:@"Address Block"];
    row.required = YES;
    row.value = [self.retrievedPatientDictionary objectForKey:kAddUnit]? [self.retrievedPatientDictionary objectForKey:kAddUnit]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddUnit rowType:XLFormRowDescriptorTypeText title:@"Address Unit"];
    row.required = YES;
    row.value = [self.retrievedPatientDictionary objectForKey:kAddBlock]? [self.retrievedPatientDictionary objectForKey:kAddBlock]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddPostCode rowType:XLFormRowDescriptorTypeInteger title:@"Address Post Code"];
    row.required = YES;
    row.value = [self.retrievedPatientDictionary objectForKey:kAddPostCode]? [self.retrievedPatientDictionary objectForKey:kAddPostCode]:@"";
    [section addFormRow:row];
    
    // Required Services - Section
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"Required Services"];
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Required Services"
                                             sectionOptions:XLFormSectionOptionCanInsert
                                          sectionInsertMode:XLFormSectionInsertModeButton];
    [formDescriptor addFormSection:section];

    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhleb rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Phleb"];
    row.value = [self.retrievedPatientDictionary objectForKey:@"otherservices"]? [[self.retrievedPatientDictionary objectForKey:@"otherservices"] objectAtIndex:0]:@(NO);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFOBT rowType:XLFormRowDescriptorTypeBooleanCheck title:@"FOBT"];
    row.value = [self.retrievedPatientDictionary objectForKey:@"otherservices"]? [[self.retrievedPatientDictionary objectForKey:@"otherservices"] objectAtIndex:1]:@(NO);
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDental rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Dental"];
    row.value = [self.retrievedPatientDictionary objectForKey:@"otherservices"]? [[self.retrievedPatientDictionary objectForKey:@"otherservices"] objectAtIndex:2]:@(NO);
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEye rowType:XLFormRowDescriptorTypeBooleanCheck title:@"Eye"];
    row.value = [self.retrievedPatientDictionary objectForKey:@"otherservices"]? [[self.retrievedPatientDictionary objectForKey:@"otherservices"] objectAtIndex:3]:@(NO);
    [section addFormRow:row];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReqServOthers rowType:XLFormRowDescriptorTypeTextView title:@"Others: -"];
//    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReqServOthers rowType:XLFormRowDescriptorTypeText];
    [[row cellConfig] setObject:@"Add other services" forKey:@"textField.placeholder"];
    section.multivaluedTag = @"otherservices";
    section.multivaluedRowTemplate = row;
    
    // Others - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Others"];
    [formDescriptor addFormSection:section];
    
    
    // Date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPrefDate rowType:XLFormRowDescriptorTypeDateInline title:@"Preferred Date"];
    [row.cellConfigAtConfigure setObject:[NSDate new] forKey:@"minimumDate"];
    row.required = YES;
    NSDate *date = [self.retrievedPatientDictionary objectForKey:kPrefDate]? [self.retrievedPatientDictionary objectForKey:kPrefDate]: [NSDate new];
    row.value = date;
    [section addFormRow:row];
    
//    // Preferred Time
    XLFormRowDescriptor *preferredTimeRow;
    preferredTimeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPrefTime rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Preferred Time"];
    preferredTimeRow.selectorOptions = @[@"9-11", @"11-1", @"1-3"];
    preferredTimeRow.required = YES;
    preferredTimeRow.value = [self.retrievedPatientDictionary objectForKey:kPrefTime]? [self.retrievedPatientDictionary objectForKey:kPrefTime]:@[];
    [section addFormRow:preferredTimeRow];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPrefTime rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Preferred Time"];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"9-11"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"11-1"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"1-3"]
//                            ];
//    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"9-11"];
//    row.required = YES;
//    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNeighbourhood rowType:XLFormRowDescriptorTypeText title:@"Neighbourhood"];
    row.required = YES;
    row.value = [self.retrievedPatientDictionary objectForKey:kNeighbourhood]? [self.retrievedPatientDictionary objectForKey:kNeighbourhood]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRemarks rowType:XLFormRowDescriptorTypeTextView title:@"Remarks:-"];
    row.required = NO;
    row.value = [self.retrievedPatientDictionary objectForKey:kRemarks]? [self.retrievedPatientDictionary objectForKey:kRemarks]:@"";
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
    
}

- (void) loadDraftIfAny {
    if (self.loadDataFlag == [NSNumber numberWithBool:YES]) {
        if (self.patientDataLocalOrServer == [NSNumber numberWithInt:local]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Pre-registration"];
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            NSArray *localFiles = [fileManager contentsOfDirectoryAtPath:folderPath
                                                                   error:nil];
            NSString *filename = [localFiles objectAtIndex:[self.patientLocalFileIndex intValue]];
            self.loadedFilepath = [[NSString alloc] initWithString:[folderPath stringByAppendingPathComponent:filename]];
            self.retrievedPatientDictionary = [NSDictionary dictionaryWithContentsOfFile:self.loadedFilepath];
            NSLog(@"Retrieved Dictionary from Local File:\n%@", self.retrievedPatientDictionary);
        }
    } else {
        //do nothing
    }
}

# pragma mark - Buttons

-(void)backBtnPressed:(id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                            message:@""
                                            preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Draft", nil)
        style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction * deleteDraftAction) {
            [self deleteDraft];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                                object:nil
                                                              userInfo:nil];
            [self.navigationController popViewControllerAnimated:YES];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save Draft", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * saveDraftAction) {
                                                          if ([[self.form formValues] objectForKey:kNRIC] == (id)[NSNull null] || [[[self.form formValues] objectForKey:kNRIC] isEqualToString:@""]) {
                                                              UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid Save", nil)
                                                                                                                                        message:@"NRIC cannot be empty for saving."
                                                                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                                              
                                                              [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                                                                  style:UIAlertActionStyleDefault
                                                                                                                handler:^(UIAlertAction * okAction) {
                                                                                                                }]];
                                                              [self presentViewController:alertController animated:YES completion:nil];
                                                          } else {
                                                              [self saveDraft];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                                                                                  object:nil
                                                                                                                userInfo:nil];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)submitPressed:(UIBarButtonItem * __unused)button
{
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
}

#pragma mark UIAlertAction methods

- (void) saveDraft {
    
    NSMutableDictionary *formValuesDict = [[self.form formValues] mutableCopy];
    if ([formValuesDict objectForKey:kName] == [NSNull null])        //if NULL, cannot store in local directory
        [formValuesDict removeObjectForKey:kName];
    if ([formValuesDict objectForKey:kSpokenLanguage] == [NSNull null]) {
        [formValuesDict removeObjectForKey:kSpokenLanguage];
    }
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    NSString *ts = [[localDateTime description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    NSString *nric = [[[self.form formValues] objectForKey:@"nric"] stringByAppendingString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [nric stringByAppendingString:ts]; //Eg. S12313K_datetime
    NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Pre-registration"];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
    //Save the form locally on the iPhone
    [formValuesDict writeToFile:filePath atomically:YES];
}

- (void) deleteDraft {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *nric = [[self.form formValues] objectForKey:kNRIC];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Pre-registration"];
    NSArray *localSavedFilenames = [fileManager contentsOfDirectoryAtPath:folderPath
                                                               error:nil];
    NSString *filename;
    for (NSString* item in localSavedFilenames)
    {
        if ([item rangeOfString:nric].location != NSNotFound)
            filename = item;
        else
            return;     //nothing to delete
    }
    NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"Draft deleted!");
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

- (void) removeDraftAfterSubmission {
    NSError *error;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL success = [fileManager removeItemAtPath:self.loadedFilepath error:&error];
    if (success) {
        NSLog(@"Draft deleted!");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }}

#pragma mark - Post data to server methods
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
            if (self.loadDataFlag == [NSNumber numberWithBool:YES]) {       //if this draft is loaded and submitted,now delete!
                [self removeDraftAfterSubmission];
            }
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Uploaded", nil)
                message:@"Pre-registration successful!"
                 preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * okAction) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                        object:nil
                        userInfo:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }


    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))personalInfoSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"Personal info submission success");
        self.resident_id = [responseObject objectForKey:@"resident_id"];
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
            [hud hideAnimated:YES];     //stop showing the progressindicator
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

#pragma mark - Dictionary methods
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
    [otherServicesArray removeObjectsInRange:NSMakeRange(0, 4)];    //remove the first four row values
    
    NSString *otherServices = @"";
    if([otherServicesArray count] == 1) {
        otherServices = [otherServicesArray objectAtIndex:0];
    } else if ([otherServicesArray count] > 1) {
        otherServices = [[otherServicesArray valueForKey:@"description"] componentsJoinedByString:@","];
    }
    
    //Required Services
    localDateTime = [NSDate dateWithTimeInterval:1.0 sinceDate:localDateTime];      //add a second
    dict = @{@"resident_id":self.resident_id,
             @"pleb":[[[self.form formValues] objectForKey:@"otherservices"] objectAtIndex:0],
             @"fobt":[[[self.form formValues] objectForKey:@"otherservices"] objectAtIndex:1],
             @"dental":[[[self.form formValues] objectForKey:@"otherservices"] objectAtIndex:2],
             @"eye":[[[self.form formValues] objectForKey:@"otherservices"] objectAtIndex:3],
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
@end

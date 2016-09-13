//
//  BTFormViewController.m
//  NHS
//
//  Created by Nicholas Wong on 9/13/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "BTFormViewController.h"
#import "ServerComm.h"
#import "MBProgressHUD.h"

//XLForms stuffs
#import "XLForm.h"
#import "AppConstants.h"

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

NSString *const kGlucose = @"glucose";
NSString *const kTrigly = @"trigly";
NSString *const kLdl = @"ldl";
NSString *const kFit = @"fit";


@interface BTFormViewController () {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSMutableArray *bloodTestForm;

@end

@implementation BTFormViewController

- (void)viewDidLoad {
    
    XLFormViewController *form = [self init];       //must init first before [super viewDidLoad]
    NSLog(@"%@", [form class]);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitPressed:)];
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];
    self.bloodTestForm = [[NSMutableArray alloc] init];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(id)init
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"New Form"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Blood Test"];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNRIC rowType:XLFormRowDescriptorTypeText title:@"NRIC"];
    row.required = YES;
//    row.value = [self.retrievedPatientDictionary objectForKey:kName]? [self.retrievedPatientDictionary objectForKey:kName]:@"";
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.value = _residentNRIC;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGlucose rowType:XLFormRowDescriptorTypeNumber title:@"Glucose (Fasting)"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    row.value = [self.retrievedPatientDictionary objectForKey:kContactNumber]? [self.retrievedPatientDictionary objectForKey:kContactNumber]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTrigly rowType:XLFormRowDescriptorTypeNumber title:@"Triglycerides"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    //    row.value = [self.retrievedPatientDictionary objectForKey:kContactNumber]? [self.retrievedPatientDictionary objectForKey:kContactNumber]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLdl rowType:XLFormRowDescriptorTypeNumber title:@"LDL Cholesterol"];
    row.required = YES;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    //    row.value = [self.retrievedPatientDictionary objectForKey:kContactNumber]? [self.retrievedPatientDictionary objectForKey:kContactNumber]:@"";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFit rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"FIT Positive?"];
    row.required = YES;
    //    row.value = [self.retrievedPatientDictionary objectForKey:kContactNumber]? [self.retrievedPatientDictionary objectForKey:kContactNumber]:@"";
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

# pragma mark - Buttons

-(void)backBtnPressed:(id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                              message:@"Do you want to cancel form entry?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * deleteDraftAction) {
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
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor orangeColor];
            [UIView animateWithDuration:0.3 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }];
        [self showFormValidationError:[validationErrors firstObject]];
        
        return; //will return if validation got error
    }

    [self.tableView endEditing:YES];
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the label text.
    hud.label.text = NSLocalizedString(@"Uploading...", @"HUD loading title");
    [self submitBloodTestResult:[self prepareBloodTestDict]];
}



#pragma mark -

#pragma mark Submission
- (void) submitBloodTestResult:(NSDictionary *) dict {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postBloodTestResultWithDict:dict
                       progressBlock:[self progressBlock]
                        successBlock:[self successBlock]
                        andFailBlock:[self errorBlock]];
}

#pragma mark Prepare Dictionary
- (NSDictionary *) prepareBloodTestDict {
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    NSDictionary *dict;
    
    dict = @{@"resident_id":_residentID,
             kGlucose:[[self.form formValues] objectForKey:kGlucose],
             kTrigly:[[self.form formValues] objectForKey:kTrigly],
             kLdl:[[self.form formValues] objectForKey:kLdl],
             kFit:[[self.form formValues] objectForKey:kFit],
             @"ts":[localDateTime description]};
    
    return dict;
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
        
        NSLog(@"SUBMISSION SUCCESSFUL!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Uploaded", nil)
                                                                                  message:@"Blood test result uploaded successfully!"
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
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"******UNSUCCESSFUL SUBMISSION******!!");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSLog(@"error: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);

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
    
    };
}



@end

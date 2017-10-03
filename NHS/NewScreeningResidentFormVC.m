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

//XLForms stuffs
#import "XLForm.h"


#define RESI_PART_SECTION @"resi_particulars"


@interface NewScreeningResidentFormVC () {
    NSString *neighbourhood;
    NetworkStatus status;
    XLFormRowDescriptor *dobRow;
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
    
    dobRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBirthDate rowType:XLFormRowDescriptorTypeDate title:@"DOB"];
    dobRow.required = YES;
    [self setDefaultFontWithRow:dobRow];
    [section addFormRow:dobRow];
    
    return [super initWithForm:formDescriptor];
}

#pragma mark - XLFormViewControllerDelegate
-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {
    
    if ([rowDescriptor.tag isEqualToString:kBirthDate] ) {
        return;
    }
    else if ([rowDescriptor.tag isEqualToString:kName] || [rowDescriptor.tag isEqualToString:kNRIC]) {
        NSString *CAPSed = [rowDescriptor.value uppercaseString];
        rowDescriptor.value = CAPSed;
        [self reloadFormRow:rowDescriptor];
        
        return;
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
        
        NSLog(@"Registering new resident...");
        NSDictionary *dict = @{kName:name,
                               kNRIC:nric,
                               kGender:gender,
                               kBirthDate:birthDate,
                               kTimestamp:timeNow,
                               kScreenLocation:neighbourhood};
        [self submitNewResidentEntry:dict];

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
    [client postNewResidentWithDict:@{@"resi_particulars":dict}
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

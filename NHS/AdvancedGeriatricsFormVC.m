//
//  AdvancedGeriatricsFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 9/7/18.
//  Copyright © 2018 NUS. All rights reserved.
//

#import "AdvancedGeriatricsFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "KAStatusBar.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"
#import "ScreeningDictionary.h"


typedef enum formName {
    DementiaAssmt,
    Referrals,
} formName;


@interface AdvancedGeriatricsFormVC () {
    BOOL internetDCed;
    BOOL isFormFinalized;
    XLFormRowDescriptor *dementiaStatusRow;
}

@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSMutableArray *phqQuestionsArray;

@end

@implementation AdvancedGeriatricsFormVC

- (void)viewDidLoad {
    
    isFormFinalized = false;    //by default
    XLFormViewController *form;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    
    //must init first before [super viewDidLoad]
    int formNumber = [_formNo intValue];
    
    switch (formNumber) {
        case DementiaAssmt:
            form = [self initDementiaAssmt];
            break;
        case Referrals:
            form = [self initReferrals];
            break;
        default:
            break;
    }
    [self.form setAddAsteriskToRequiredRowsTitle:YES];
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    if (isFormFinalized) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        [self.form setDisabled:YES];
        [self.tableView endEditing:YES];    //to really disable the table
        [self.tableView reloadData];
    }
    else {
        [self.form setDisabled:NO];
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finalize" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeBtnPressed:)];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [KAStatusBar dismiss];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (id) initAdvFallRiskAssmt {
//    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Adv Fall Risk Assessment"];
//    XLFormSectionDescriptor * section;
//    XLFormRowDescriptor * row;
//
//    NSDictionary *advFallRiskAssmtDict = [_fullScreeningForm objectForKey:SECTION_ADV_FALL_RISK_ASSMT];
//
//    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
//
//    if (checkDict != nil && checkDict != (id)[NSNull null]) {
//        NSNumber *check = checkDict[kCheckAdvFallRiskAssmt];
//        if ([check isKindOfClass:[NSNumber class]]) {
//            isFormFinalized = [check boolValue];
//        }
//    }
//
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:section];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGivenReferral rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Resident given referral?"];
//    row.noValueDisplayText = @"Tap here";
//    row.required = YES;
//    [self setDefaultFontWithRow:row];
//    row.selectorOptions = @[@"NIL", @"Cluster Operator", @"Hospital"];
//    row.required = YES;
//
//    //value
//    if (advFallRiskAssmtDict != (id)[NSNull null] && [advFallRiskAssmtDict objectForKey:kGivenReferral] != (id)[NSNull null]) {
//        row.value = [advFallRiskAssmtDict objectForKey:kGivenReferral];
//    }
//
//    [section addFormRow:row];
//
//    return [super initWithForm:formDescriptor];
//}


- (id) initDementiaAssmt {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Dementia Assessment (Advanced-AMT)"];
    XLFormSectionDescriptor * section;
    
    NSDictionary *dementiaAssmtDict = [_fullScreeningForm objectForKey:SECTION_GERIATRIC_DEMENTIA_ASSMT];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckGeriatricDementiaAssmt];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *undergoneDementia = [XLFormRowDescriptor
                                              formRowDescriptorWithTag:kUndergoneDementia
                                              rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Undergone Geriatric Dementia Assessment?"];
    undergoneDementia.required = YES;
    
    [self setDefaultFontWithRow:undergoneDementia];
    undergoneDementia.selectorOptions = @[@"Yes", @"No"];
    undergoneDementia.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:undergoneDementia];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    section.footerTitle = @"Range: 0-10";
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *amtScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAmtScore rowType:XLFormRowDescriptorTypeInteger title:@"Total score for AMT"];
    amtScoreRow.required = YES;
    [self setDefaultFontWithRow:amtScoreRow];
    amtScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [amtScoreRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [amtScoreRow addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Score between 0 to 10" regex:@"^([0-9]|10)$"]];
    
    amtScoreRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if (newValue != [NSNull null]) {
                if ([newValue intValue] < 0 || [newValue intValue] > 10) {
                    [self showValidationError];
                }
            }
        }
    };
    
    if (dementiaAssmtDict != (id)[NSNull null] && [dementiaAssmtDict objectForKey:kAmtScore] != (id)[NSNull null])
        amtScoreRow.value = dementiaAssmtDict[kAmtScore];
    
    [section addFormRow:amtScoreRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *eduStatusRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEduStatus rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Resident's education status"];
    eduStatusRow.required = YES;
    eduStatusRow.noValueDisplayText = @"Tap here";
    eduStatusRow.selectorOptions = @[@"0 to 6 years", @"More than 6 years"];
    [self setDefaultFontWithRow:eduStatusRow];
    
    if (dementiaAssmtDict != (id)[NSNull null] && [dementiaAssmtDict objectForKey:kEduStatus] != (id)[NSNull null])
        eduStatusRow.value = dementiaAssmtDict[kEduStatus];
    
    [section addFormRow:eduStatusRow];
    
    dementiaStatusRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDementiaStatus rowType:XLFormRowDescriptorTypeInfo title:@"Dementia Status (auto-calculate)"];
    [self setDefaultFontWithRow:dementiaStatusRow];
    dementiaStatusRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [self setDefaultFontWithRow:dementiaStatus];
    
    if (dementiaAssmtDict != (id)[NSNull null] && [dementiaAssmtDict objectForKey:kDementiaStatus] != (id)[NSNull null])
        dementiaStatusRow.value = dementiaAssmtDict[kDementiaStatus];

    [section addFormRow:dementiaStatusRow];
    
    if (dementiaAssmtDict != (id)[NSNull null] && [dementiaAssmtDict objectForKey:kUndergoneDementia] != (id)[NSNull null]) {
        undergoneDementia.value = [self getYesNofromOneZero:dementiaAssmtDict[kUndergoneDementia]];
        
        if ([undergoneDementia.value isEqualToString:@"No"]) {
            amtScoreRow.required = NO;
            eduStatusRow.required = NO;
        } else {
            amtScoreRow.required = YES;
            eduStatusRow.required = YES;
        }
        [self reloadFormRow:amtScoreRow];
        [self reloadFormRow:eduStatusRow];
    }
    
    undergoneDementia.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"No"]) {
                amtScoreRow.required = NO;
                eduStatusRow.required = NO;
            } else {
                amtScoreRow.required = YES;
                eduStatusRow.required = YES;
            }
            [self reloadFormRow:amtScoreRow];
            [self reloadFormRow:eduStatusRow];
        }
    };
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initReferrals {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Referrals"];
    XLFormSectionDescriptor * section;
    
    NSDictionary *dementiaAssmtDict = [_fullScreeningForm objectForKey:SECTION_GERIATRIC_DEMENTIA_ASSMT];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckReferrals];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *reqFollowUpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kReqFollowupAdvGer rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Resident given referral?"];
    reqFollowUpRow.required = YES;
    reqFollowUpRow.noValueDisplayText = @"Tap here";
    reqFollowUpRow.selectorOptions = @[@"NIL", @"Cluster Operator"];
    reqFollowUpRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:reqFollowUpRow];
    
    if (dementiaAssmtDict != (id)[NSNull null] && [dementiaAssmtDict objectForKey:kReqFollowupAdvGer] != (id)[NSNull null])
        reqFollowUpRow.value = dementiaAssmtDict[kReqFollowupAdvGer];
    
    [section addFormRow:reqFollowUpRow];

    return [super initWithForm:formDescriptor];

}

#pragma mark - Buttons

-(void)editBtnPressed:(UIBarButtonItem * __unused)button
{
    if ([self.form isDisabled]) {
        [self.form setDisabled:NO];     //enable the form
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finalize" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeBtnPressed:)];
        
        NSString *fieldName;
        switch ([self.formNo intValue]) {
            case DementiaAssmt: fieldName = kCheckGeriatricDementiaAssmt;
                break;
            case Referrals: fieldName = kCheckReferrals;
                break;

            default:
                break;

        }
        
        [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:fieldName andNewContent:@"0"]; //un-finalize it
        
        
        
    }
    
}

- (void) finalizeBtnPressed: (UIBarButtonItem * __unused) button {
    
    NSLog(@"%@", [self.form formValues]);
    
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
        NSString *fieldName;

        switch ([self.formNo intValue]) {
            case DementiaAssmt: fieldName = kCheckGeriatricDementiaAssmt;
                break;
            case Referrals: fieldName = kCheckReferrals;
                break;
            default:
                break;

        }
        [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:fieldName andNewContent:@"1"];
        [SVProgressHUD setMaximumDismissTimeInterval:1.0];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showSuccessWithStatus:@"Completed!"];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        [self.form setDisabled:YES];
        [self.tableView endEditing:YES];    //to really disable the table
        [self.tableView reloadData];
        
        
    }
    
    
}

#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    NSString* ansFromYesNo;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Yes"])
            ansFromYesNo = @"1";
        else if ([newValue isEqualToString:@"No"])
            ansFromYesNo = @"0";
    }
    
    NSString* ansFromYESNO;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"YES"])
            ansFromYESNO = @"1";
        else if ([newValue isEqualToString:@"NO"])
            ansFromYESNO = @"0";
    }
    
    /* Geriatric Dementia Assessment */
    if ([rowDescriptor.tag isEqualToString:kUndergoneDementia]) {
        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kUndergoneDementia andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kEduStatus]) {
        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kEduStatus andNewContent:newValue];
        [self tabulateDementiaStatus];
    } else if ([rowDescriptor.tag isEqualToString:kDementiaStatus]) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kDementiaStatus andNewContent:newValue];
        });
    } else if ([rowDescriptor.tag isEqualToString:kReqFollowupAdvGer]) {
        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kReqFollowupAdvGer andNewContent:newValue];
    }
    
    
}

//-(void)beginEditing:(XLFormRowDescriptor *)rowDescriptor {
//    if ([rowDescriptor.tag isEqualToString:kInterventions]) {
//        if (rowDescriptor.value == nil || [rowDescriptor.value isEqualToString:@""]) {
//
//        }
//    }
//}

-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {    //works great for textField and textView
    
    if (rowDescriptor.value == nil) {
        rowDescriptor.value = @"";  //empty string
    }
    
    if ([rowDescriptor.tag isEqualToString:kAmtScore]) {
        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ASSMT andFieldName:kAmtScore andNewContent:rowDescriptor.value];
        [self tabulateDementiaStatus];
    }
}

#pragma mark - Reachability
/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        switch (netStatus) {
            case NotReachable: {
                internetDCed = true;
                NSLog(@"Can't connect to server!");
                [self.form setDisabled:YES];
                [self.tableView reloadData];
                [self.tableView endEditing:YES];
                [SVProgressHUD setMaximumDismissTimeInterval:2.0];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showErrorWithStatus:@"No Internet!"];
                
                
                break;
            }
            case ReachableViaWiFi:
            case ReachableViaWWAN:
                NSLog(@"Connected to server!");
                
                if (!isFormFinalized) {
                    [self.form setDisabled:NO];
                    [self.tableView reloadData];
                }
                
                
                if (internetDCed) { //previously disconnected
                    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                    [SVProgressHUD showSuccessWithStatus:@"Back Online!"];
                    internetDCed = false;
                }
                break;
                
            default:
                break;
        }
    }
    
}



#pragma mark - Post data to server methods

- (void) postSingleFieldWithSection:(NSString *) section andFieldName: (NSString *) fieldName andNewContent: (NSString *) content {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    if ((content != (id)[NSNull null]) && (content != nil)) {   //make sure don't insert nil or null value to a dictionary
        
        NSDictionary *dict = @{kResidentId:resident_id,
                               kSectionName:section,
                               kFieldName:fieldName,
                               kNewContent:content
                               };
        
        NSLog(@"Uploading %@ for $%@$ field", content, fieldName);
        [KAStatusBar showWithStatus:@"Syncing..." andBarColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:0 alpha:1.0]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [_pushPopTaskArray addObject:dict];
        
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postDataGivenSectionAndFieldName:dict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
    }
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        
        [_pushPopTaskArray removeObjectAtIndex:0];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
        
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


- (NSString *) getYesNofromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"]) {
            return @"Yes";
        } else {
            return @"No";
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1]) {
            return @"Yes";
        } else {
            return @"No";
        }
    }
    return @"";
}


- (void) showValidationError {
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
            [UIView animateWithDuration:0.3 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }];
        [self showFormValidationError:[validationErrors firstObject]];
        
        return;
    }
}

- (void) tabulateDementiaStatus {
    NSNumber *age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                                  stringForKey:kResidentAge];
    
    NSDictionary *fields = [self.form formValues];
    if ([age integerValue] < 75) {
        if ([fields objectForKey:kEduStatus] != (id)[NSNull null]) {
            if ([[fields objectForKey:kEduStatus] containsString:@"0 to 6"]) {
                if ([fields objectForKey:kAmtScore] != (id)[NSNull null]) {
                    if ([[fields objectForKey:kAmtScore] intValue] <= 7) {
                        dementiaStatusRow.value = @"Likely";
                    } else {
                        dementiaStatusRow.value = @"Unlikely";
                    }
                }
            } else { // edu_status > 6
                if ([fields objectForKey:kAmtScore] != (id)[NSNull null]) {
                    if ([[fields objectForKey:kAmtScore] intValue] <= 8) {
                        dementiaStatusRow.value = @"Likely";
                    }
                } else {
                    dementiaStatusRow.value = @"Unlikely";
                }
            }
        }
    } else {    // age >= 75
        if ([fields objectForKey:kEduStatus] != (id)[NSNull null]) {
            if ([[fields objectForKey:kEduStatus] containsString:@"0 to 6"]) {
                if ([fields objectForKey:kAmtScore] != (id)[NSNull null]) {
                    if ([[fields objectForKey:kAmtScore] intValue] <= 5) {
                        dementiaStatusRow.value = @"Likely";
                    } else {
                        dementiaStatusRow.value = @"Unlikely";
                    }
                }
            } else { // edu_status > 6
                if ([fields objectForKey:kAmtScore] != (id)[NSNull null]) {
                    if ([[fields objectForKey:kAmtScore] intValue] <= 8) {
                        dementiaStatusRow.value = @"Likely";
                    }
                } else {
                    dementiaStatusRow.value = @"Unlikely";
                }
            }
        }
    }
    [self reloadFormRow:dementiaStatusRow];
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

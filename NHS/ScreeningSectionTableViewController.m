//
//  ScreeningSectionTableViewController.m
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ScreeningSectionTableViewController.h"
#import "ScreeningFormViewController.h"
#import "ServerComm.h"
#import "AppConstants.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "ScreeningDictionary.h"
#import "KAStatusBar.h"

#define DISABLE_SERVER_DATA_FETCH


typedef enum typeOfForm {
    NewScreeningForm,
    PreRegisteredScreeningForm,
    LoadedDraftScreeningForm,
    ViewScreenedScreeningForm
} typeOfForm;

typedef enum sectionRowNumber {
    Phlebotomy,
    ModeOfScreening,
    Profiling,
    HealthAssessment_RiskStratification,
    SocialWork,
    Triage,
    SnellenEyeTest,
    AdditionalServices,
    DoctorsConsultation,
    BasicDentalCheckup,
    SeriAdvancedEyeScreening,
    FallRiskAssessment,
    GeriatricDementiaAssess,
    HealthEducation
} sectionRowNumber;



@interface ScreeningSectionTableViewController () {
    NetworkStatus status;
}

@property (strong, nonatomic) NSArray *rowTitles;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSString *loadedFilepath;
@property (strong, nonatomic) UIBarButtonItem *specialBtn;

@end

@implementation ScreeningSectionTableViewController {
    NSNumber *selectedRow;
    BOOL readyToSubmit, alreadySubmitted;
    NSInteger formType;
}

- (void)viewDidLoad {   //will only happen when it comes from New Resident / Use Existing Resident
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    alreadySubmitted = false;
    
    if ([_fullScreeningForm[SECTION_RESI_PART][kIsFinal] isEqual:@1])
        alreadySubmitted = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnPressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
    
    if (alreadySubmitted) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
    } else {
        BOOL isComm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isComm"] boolValue];
        
        if (isComm) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
            [button addTarget:self action:@selector(forceEnableSubmit:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[UIImage imageNamed:@"spannar-icon"] forState:UIControlStateNormal];
            [button setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
            _specialBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
            _specialBtn.tintColor = self.view.tintColor;
            [self.navigationItem setRightBarButtonItem:_specialBtn];
        }
    }
    
    
    
    formType = NewScreeningForm;    //default value
    
    readyToSubmit = false;
    
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data

    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
    
    @synchronized (self) {
        [self updateCellAccessory];
        [self checkReadyToSubmit];
        [self.tableView reloadData];    //put in the ticks
    }
    
//    Reachability *reachability = [Reachability reachabilityForInternetConnection];
//    [reachability startNotifier];
//    
//    status = [reachability currentReachabilityStatus];
//    [self processConnectionStatus];
    
    //positive number -> Pre-reg Resident/Uploaded Screening Form
    // (-1) New Screening Form
    // (-2) Draft
    
#ifndef DISABLE_SERVER_DATA_FETCH
    if ([self.residentID intValue]>= 0) {
        if (self.retrievedData) {
            [self insertRequestDataToScreeningForm];
            formType = ViewScreenedScreeningForm;
        } else {
            [self getPreRegistrationData];
            formType = PreRegisteredScreeningForm;
        }
    } else if ([self.residentID intValue] == -2) {
        formType = LoadedDraftScreeningForm;
        [self loadDraftIfAny];
    }
#endif
    
    self.rowTitles = @[@"Phlebotomy", @"Mode of Screening",@"Profiling", @"Health Assessment & Risk Stratification", @"Social Work", @"Triage", @"Snellen Eye Test", @"Additional Services", @"Doctor's Consultation", @"Basic Dental Check-up", @"SERI Advanced Eye Screening", @"Fall Risk Assessment", @"Geriatric Dementia Asssesment", @"Health Education"];
    
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Screening Form";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFormType:)
                                                 name:@"formEditedNotification"
                                               object:nil];
    
    
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;   //Submit is in another section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return [self.rowTitles count];
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    static NSString *buttonTableIdentifier = @"SimpleTableButton";
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {   //for the questionaires
         cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
        }
    
        cell.textLabel.text = [self.rowTitles objectAtIndex:indexPath.row];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
        // Put in the ticks if necessary
        if (indexPath.row < [self.completionCheck count]) {
            if ([[self.completionCheck objectAtIndex:indexPath.row] isEqualToNumber:@1]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        if (alreadySubmitted) {
            cell.userInteractionEnabled = NO;
            [cell.textLabel setTextColor:[UIColor grayColor]];
        } else {
            cell.userInteractionEnabled = YES;
            [cell.textLabel setTextColor:[UIColor blackColor]];
        }
    
        if ((indexPath.row >= SeriAdvancedEyeScreening) && (indexPath.row <= GeriatricDementiaAssess)) {   //between 10 to 12
            if (indexPath.row == SeriAdvancedEyeScreening) {  //SERI
                //Enable SERI
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifySeri] isEqual:@"1"]) {
                    if (!alreadySubmitted) {
                        cell.userInteractionEnabled = YES;
                        [cell.textLabel setTextColor:[UIColor blackColor]];
                    }
                    return cell;    //don't disable.
                }
            } else if (indexPath.row == FallRiskAssessment) {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifyFallAssess] isEqual:@"1"]) {
                    if (!alreadySubmitted) {
                        cell.userInteractionEnabled = YES;
                        [cell.textLabel setTextColor:[UIColor blackColor]];
                    }
                    return cell;    //don't disable.
                }
            } else if (indexPath.row == GeriatricDementiaAssess) {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifyDementia] isEqual:@"1"]) {
                    if (!alreadySubmitted) {
                        cell.userInteractionEnabled = YES;
                        [cell.textLabel setTextColor:[UIColor blackColor]];
                    }
                    return cell;    //don't disable.
                }
            }
            
            cell.userInteractionEnabled = NO;
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
    }
    
    //submit button
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:buttonTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonTableIdentifier];
        }
        
        cell.textLabel.text = @"Submit";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        
        if (readyToSubmit && !alreadySubmitted) {    //if enabled
            cell.backgroundColor = [UIColor colorWithRed:0 green:51/255.0 blue:102/255.0 alpha:1];  //dark blue
            cell.userInteractionEnabled = YES;
        }
        else {  //if disabled
            cell.userInteractionEnabled = NO;
            cell.backgroundColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1];  //grayed out
        }
        
        if (alreadySubmitted) {
            cell.userInteractionEnabled = NO;
            cell.backgroundColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1];  //grayed out
        }
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // rows in section 0 should not be selectable
    if ( indexPath.section == 1 ) {
        if (readyToSubmit) {
            return indexPath;
        } else {
            return nil;
        }
    }
    
    // By default, allow row to be selected
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        selectedRow = [NSNumber numberWithInteger:indexPath.row];
        
        if (indexPath.row == HealthAssessment_RiskStratification) {
            [self performSegueWithIdentifier:@"sectionToHARSSegue" sender:self];
            return;
        } else if (indexPath.row == SocialWork) {
            [self performSegueWithIdentifier:@"screenSectionToSocialWorkSegue" sender:self];
            return;
        } else if (indexPath.row == Triage) {
            selectedRow = [NSNumber numberWithInteger:Triage];
        } else if (indexPath.row == SnellenEyeTest) {
            selectedRow = [NSNumber numberWithInteger:SnellenEyeTest];
        } else if (indexPath.row == AdditionalServices) {
            selectedRow = [NSNumber numberWithInteger:AdditionalServices];
        } else if (indexPath.row == DoctorsConsultation) {
            selectedRow = [NSNumber numberWithInteger:DoctorsConsultation];
        } else if (indexPath.row == BasicDentalCheckup) {
            selectedRow = [NSNumber numberWithInteger:BasicDentalCheckup];
          } else if (indexPath.row == SeriAdvancedEyeScreening) {
              [self performSegueWithIdentifier:@"screeningSectionToSeriSubsectionSegue" sender:self];
              return;
          } else if (indexPath.row == FallRiskAssessment) {
              selectedRow = [NSNumber numberWithInteger:FallRiskAssessment];
          } else if (indexPath.row == GeriatricDementiaAssess) {
              selectedRow = [NSNumber numberWithInteger:GeriatricDementiaAssess];
          } else if (indexPath.row == HealthEducation) {
            selectedRow = [NSNumber numberWithInteger:HealthEducation];
        }

        
        [self performSegueWithIdentifier:@"screeningSectionToFormSegue" sender:self];
        NSLog(@"Form segue performed!");
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {   //Submit button
        [self setIsFinalInServer];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


# pragma mark - Buttons

-(void)backBtnPressed:(id)sender
{
    if (formType != ViewScreenedScreeningForm) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                                                                  message:@""
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * deleteDraftAction) {
                                                              //                                                          [self deleteDraft];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)editBtnPressed:(UIBarButtonItem * __unused)button
{
    [self clearIsFinalInServer];
    self.navigationItem.rightBarButtonItem.enabled = NO;   //disable the Edit button
}

- (void)forceEnableSubmit:(UIBarButtonItem * __unused)button
{
    NSLog(@"Enabling Submit button");
    readyToSubmit = true;
    [self.tableView reloadData];
    button.enabled = NO;
    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showSuccessWithStatus:@"Submit enabled!"];
}


#pragma mark - NSNotification Methods

- (void) reloadTable: (NSNotification *) notification {
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    @synchronized (self) {
        [self updateCellAccessory];
        [self checkReadyToSubmit];
        [self.tableView reloadData];    //put in the ticks
    }
}

- (void) updateFormType: (NSNotification *) notification {
    formType = LoadedDraftScreeningForm;        //changed status
}
#pragma mark - Server API
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
        if (_residentID != nil && _residentID != (id) [NSNull null])
            [[ScreeningDictionary sharedInstance] fetchFromServer];
    }
    
}


#pragma mark - Post data to server methods

- (void) setIsFinalInServer {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    
        
    NSDictionary *dict = @{kResidentId:resident_id,
                           kSectionName:SECTION_RESI_PART,
                           kFieldName:kIsFinal,
                           kNewContent:@"1"
                           };
    
    NSLog(@"Uploading $1 for kIsFinal field");
    
    
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postDataGivenSectionAndFieldName:dict
                               progressBlock:[self progressBlock]
                                successBlock:[self successBlock]
                                andFailBlock:[self errorBlock]];
}

- (void) clearIsFinalInServer {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    
    
    NSDictionary *dict = @{kResidentId:resident_id,
                           kSectionName:SECTION_RESI_PART,
                           kFieldName:kIsFinal,
                           kNewContent:@"0"
                           };
    
    NSLog(@"Uploading $0 for kIsFinal field");
    
    
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client postDataGivenSectionAndFieldName:dict
                               progressBlock:[self progressBlock]
                                successBlock:^(NSURLSessionDataTask *task, id responseObject){
                                    
                                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                    [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
                                    alreadySubmitted = false;
                                    
                                    [self.tableView reloadData];
                                }
                                andFailBlock:[self errorBlock]];
}


#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"Success: %@", responseObject);
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *keys = [responseObject allKeys];
            if ([keys containsObject:@"success"]) {
                if ([[responseObject objectForKey:@"success"] isEqualToString:@"1"]) {
                    [[ServerComm sharedServerCommInstance] generateSerialIdForResidentID:_residentID progressBlock:[self progressBlock] successBlock:[self generateIdSuccessBlock] andFailBlock:[self errorBlock]];
                }
            }
        }
        
        
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:@"Submit failed. Try Again."];
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))generateIdSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"Generated ID: %@", responseObject);
        
        NSString *generated_id = [responseObject objectForKey:@"nhs_serial_id"];
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Submission successful!", nil)
                                                                                  message:[NSString stringWithFormat:@"Generated ID: %@", generated_id]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction){

                                                             [self.navigationController popViewControllerAnimated:YES];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    };
}



#pragma mark - Completion Check Methods

- (void) updateCellAccessory {
    
    if ([_completionCheck count] < 1) {
        _completionCheck = [[NSMutableArray alloc] init];
    } else {
        [_completionCheck removeAllObjects];
    }
    NSDictionary *checksDict = [_fullScreeningForm objectForKey:SECTION_CHECKS];
    //    NSDictionary *checksDict = [_fullScreeningForm objectForKey:SECTION_CHECKS];
    NSArray *lookupTable = @[kCheckPhleb, kCheckScreenMode, kCheckProfiling,@"health_assmt_risk_strat",@"check_social_work", kCheckTriage, kCheckSnellen, kCheckAdd, kCheckDocConsult, kCheckDental, @"check_overall_seri", kCheckFall,kCheckDementia, kCheckEd];
    
    if (checksDict != nil && checksDict != (id)[NSNull null]) {
        for (int i=0; i<[lookupTable count]; i++) {
            
            if (i == HealthAssessment_RiskStratification) {
                [_completionCheck addObject:[self checkAllHealthAssmtRiskStratSections:checksDict]];
            } else if (i == SocialWork) {
                [_completionCheck addObject:[self checkAllSocialWorkSections:checksDict]];
            } else if (i== SeriAdvancedEyeScreening) {
                [_completionCheck addObject:[self checkAllSeriSections:checksDict]];
            } else {
                NSString *key = lookupTable[i];
                
                NSNumber *doneNum = [checksDict objectForKey:key];
                [_completionCheck addObject:doneNum];
            }
            
        }
    }
    
}

- (void) checkReadyToSubmit {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *arr = [_completionCheck mutableCopy];   //don't modify the original array!
    
    if ([_fullScreeningForm objectForKey:SECTION_CHECKS] != (id) [NSNull null]) {
        if (![[defaults objectForKey:kQualifyDementia] isEqual:@"1"]) { //don't consider Dementia
            [arr removeObjectAtIndex:12];
        }
        
        if (![[defaults objectForKey:kQualifyFallAssess] isEqual:@"1"]) { //don't consider Fall Assess
            [arr removeObjectAtIndex:11];
        }
        
        if (![[defaults objectForKey:kQualifySeri] isEqual:@"1"]) { //don't consider SERI
            [arr removeObjectAtIndex:10];
        }
        
        int count =0;
        
        for (int i=0; i< [arr count]; i++) {
            NSNumber *value = [arr objectAtIndex:i];
            if ([value isEqual:@1]) count++;
        }
        
        if (count == [arr count])  readyToSubmit = true;
        else readyToSubmit = false;
    } else {
        readyToSubmit = false;
    }
}

- (NSNumber *) checkAllHealthAssmtRiskStratSections:(NSDictionary *) checksDict {
    int count=0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger residentAge = [[defaults objectForKey:kResidentAge] integerValue];
    
    
    for (NSString *key in [checksDict allKeys]) {   //check through all 5 sub-sections
        if ([key isEqualToString:kCheckDiabetes] || [key isEqualToString:kCheckHypertension] || [key isEqualToString:kCheckHyperlipidemia] || [key isEqualToString:kCheckDepression] || [key isEqualToString:kCheckRiskStrat]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
        }
    }
    if (count == 5) return @1;
    else if (count == 4 && residentAge < 65) return @1;    //age less than 65 not qualified for Depression
    else return @0;
}


- (NSNumber *) checkAllSeriSections:(NSDictionary *) checksDict {
    int count=0;
    for (NSString *key in [checksDict allKeys]) {
        if ([key containsString:@"seri"]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
            else
                return @0;  //as long as there's one SERI subsection not done, return @0
        }
    }
    if (count == 7) return @1;
    else return @0;
}

- (NSNumber *) checkAllSocialWorkSections:(NSDictionary *) checksDict {
    int count=0;
    for (NSString *key in [checksDict allKeys]) {   //check through all 7 sub-sections
        if ([key isEqualToString:kCheckSocioEco] || [key isEqualToString:kCheckCurrentPhyStatus] || [key isEqualToString:kCheckSocialSupport] || [key isEqualToString:kCheckPsychWellbeing] || [key isEqualToString:kCheckSwAddServices] || [key isEqualToString:kCheckSocWorkSummary]) {    //removed genogram for the overall checklist
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
            else
                return @0;
        } 
    }
    if (count == 6) return @1;  //changed to 6. Removed genogram
    else return @0;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController respondsToSelector:@selector(setSectionID:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setSectionID:)
                                              withObject:selectedRow];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setFormType:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setFormType:)
                                              withObject:[NSNumber numberWithInteger:formType]];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setFullScreeningForm:)]) {
        [segue.destinationViewController performSelector:@selector(setFullScreeningForm:)
                                              withObject:self.fullScreeningForm];
    }
}


@end

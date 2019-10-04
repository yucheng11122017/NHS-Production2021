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
#import "ResidentProfile.h"

#define DISABLE_SERVER_DATA_FETCH


typedef enum typeOfForm {
    NewScreeningForm,
    PreRegisteredScreeningForm,
    LoadedDraftScreeningForm,
    ViewScreenedScreeningForm
} typeOfForm;

typedef enum sectionRowNumber {
    Triage,
    Phlebotomy,
    Profiling,
    BasicVision,
    AdvancedGeriatric,
    FallRiskAssessment,
    Dental,
    Hearing,
    AdvancedVision,
    EmergencyServices,
    AdditionalServices,
    SocialWork,
    Summary_HealthEducation
} sectionRowNumber;



@interface ScreeningSectionTableViewController () {
    NetworkStatus status;
    NSNumber *age;
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
    
    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                        stringForKey:kResidentAge];
    
    if ([_fullScreeningForm[SECTION_RESI_PART][kIsFinal] isEqual:@1])
        alreadySubmitted = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Exit Profile" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnPressed:)];
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
    //2019
    self.rowTitles = @[@"1. Triage", @"2. Phlebotomy", @"3. Profiling", @"4. Basic Vision", @"5. Advanced Geriatric",@"6. Fall Risk Assessment", @"7. Dental", @"8. Hearing", @"9. Advanced Vision", @"10. Emergency Services", @"11. Financial and Cancer Services", @"12. Social Work", @"Summary & Health Education"];
    
    //2018
//    self.rowTitles = @[@"1. Triage", @"2. Phlebotomy (no need to fill)", @"3. Profiling", @"4. Basic Vision", @"5. Advanced Geriatric", @"6. Dental", @"7. Hearing", @"8. Advanced Vision", @"9. Doctor's Consultation", @"10. Additional Services", @"11. Social Work", @"Summary & Health Education"];
    
    //2017
//    self.rowTitles = @[@"Phlebotomy", @"Mode of Screening",@"Profiling", @"Geriatric Depression Assessment", @"Social Work", @"Triage", @"4. Basic Vision", @"Additional Services", @"Doctor's Consultation", @"6. Dental", @"8. Advanced Vision", @"5. Advanced Geriatric", @"Geriatric Dementia Asssesment", @"Health Education"];
    
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
    
    NSDictionary *modeOfScreeningDict = [_fullScreeningForm objectForKey:SECTION_MODE_OF_SCREENING];
    
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
            return cell;    //disable all sections regardless
        } else {
            cell.userInteractionEnabled = YES;
            [cell.textLabel setTextColor:[UIColor blackColor]];
        }
        
        
        if (indexPath.row == Hearing) {
            if (modeOfScreeningDict != (id)[NSNull null]) {
                NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
                if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
                    cell.userInteractionEnabled = NO;
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                }
            }
            
            if (![[ResidentProfile sharedManager] isEligibleHearing]) {
                cell.userInteractionEnabled = NO;
                [cell.textLabel setTextColor:[UIColor grayColor]];
                return cell;
            }
        } else if (indexPath.row == Dental) {
            if (modeOfScreeningDict != (id)[NSNull null]) {
                NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
                if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
                    cell.userInteractionEnabled = NO;
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                }
            }
            
        }
        else if (indexPath.row == Phlebotomy) {
            if (modeOfScreeningDict != (id)[NSNull null]) {
                NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
                if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
                    cell.userInteractionEnabled = NO;
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                    return cell;
                }
            }
        } else if (indexPath.row == AdvancedGeriatric) {
            if (![[ResidentProfile sharedManager] isEligibleGeriatricDementiaAssmt]) {  //not eligible
                cell.userInteractionEnabled = NO;
                [cell.textLabel setTextColor:[UIColor grayColor]];
                return cell;
            }
        }
        
        else if (indexPath.row == FallRiskAssessment) {
            if (![[ResidentProfile sharedManager] isEligibleFallRiskAssessment]) {
                cell.userInteractionEnabled = NO;
                [cell.textLabel setTextColor:[UIColor grayColor]];
                return cell;
            }
        }
        
        else if (indexPath.row == AdvancedVision) {
            if (modeOfScreeningDict != (id)[NSNull null]) {
                NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
                if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
                    cell.userInteractionEnabled = NO;
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                    return cell;
                }
            }
            
            if (![[ResidentProfile sharedManager] isEligibleAdvancedVision]) {
                cell.userInteractionEnabled = NO;
                [cell.textLabel setTextColor:[UIColor grayColor]];
                return cell;
            }
        } else if(indexPath.row == EmergencyServices) {
            if (![[ResidentProfile sharedManager] isEligibleEmerSvcs]) {
                cell.userInteractionEnabled = NO;
                [cell.textLabel setTextColor:[UIColor grayColor]];
                return cell;
            }
        } else if(indexPath.row == SocialWork) {
            if (![[ResidentProfile sharedManager] isEligibleSocialWork]) {
                cell.userInteractionEnabled = NO;
                [cell.textLabel setTextColor:[UIColor grayColor]];
                return cell;
            }
        }
        else if (indexPath.row == AdditionalServices) {
            if (![[ResidentProfile sharedManager] isEligibleCHAS] &&
                ![[ResidentProfile sharedManager] isEligibleReceiveFIT] &&
                ![[ResidentProfile sharedManager] isEligibleReferMammo] &&
                ![[ResidentProfile sharedManager] isEligibleReferPapSmear]) {
                cell.userInteractionEnabled = NO;
                [cell.textLabel setTextColor:[UIColor grayColor]];
            }
            
        }
        
//        if (indexPath.row == GeriatricDepressionAssess) {   //Geriatric Depression Assessment (Age < 65)
//            if ([age intValue] <65) {
//                [cell.textLabel setTextColor:[UIColor grayColor]];
//                cell.userInteractionEnabled = NO;
//            }
//
//            NSDictionary *geriaDepreAssmtDict = [self.fullScreeningForm objectForKey:SECTION_DEPRESSION];
//            if (geriaDepreAssmtDict != nil && geriaDepreAssmtDict != (id)[NSNull null]) {
//                if ([geriaDepreAssmtDict objectForKey:kPhq9Score] != nil && [geriaDepreAssmtDict objectForKey:kPhq9Score] != (id)[NSNull null]) {
//                    if ([[geriaDepreAssmtDict objectForKey:kPhq9Score] integerValue] >= 5) {
//                        [cell.textLabel setTextColor:[UIColor redColor]];
//                    }
//                }
//            }
//
//        }
////
//        if ((indexPath.row >= SeriAdvancedEyeScreening) && (indexPath.row <= GeriatricDementiaAssess)) {   //between 10 to 12
//            if (indexPath.row == SeriAdvancedEyeScreening) {  //SERI
//                //Enable SERI
//                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifySeri] isEqual:@"1"]) {
//                    if (!alreadySubmitted) {
//                        cell.userInteractionEnabled = YES;
//                        [cell.textLabel setTextColor:[UIColor blackColor]];
//                    }
//                    return cell;    //don't disable.
//                }
//            } else if (indexPath.row == FallRiskAssessment) {
//                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifyFallAssess] isEqual:@"1"]) {
//                    if (!alreadySubmitted) {
//                        cell.userInteractionEnabled = YES;
//                        [cell.textLabel setTextColor:[UIColor blackColor]];
//                    }
//                    return cell;    //don't disable.
//                }
//            } else if (indexPath.row == GeriatricDementiaAssess) {
//                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifyDementia] isEqual:@"1"]) {
//                    if (!alreadySubmitted) {
//                        cell.userInteractionEnabled = YES;
//                        [cell.textLabel setTextColor:[UIColor blackColor]];
//                    }
//                    return cell;    //don't disable.
//                }
//            }
//
//            cell.userInteractionEnabled = NO;
//            [cell.textLabel setTextColor:[UIColor grayColor]];
//        }
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
        
        if (indexPath.row == Profiling) {
            [self performSegueWithIdentifier:@"sectionToProfilingSegue" sender:self];
            return;
        } else if (indexPath.row == Phlebotomy) {
            [self performSegueWithIdentifier:@"screeningSectionToPhlebSubsectionSegue" sender:self];
            return;
        }
        else if (indexPath.row == SocialWork) {
            [self performSegueWithIdentifier:@"screenSectionToSocialWorkSegue" sender:self];
            return;
        } else if (indexPath.row == Triage) {
            selectedRow = [NSNumber numberWithInteger:Triage];
        } else if (indexPath.row == AdditionalServices) {
            selectedRow = [NSNumber numberWithInteger:AdditionalServices];
        } else if (indexPath.row == Hearing) {
            [self performSegueWithIdentifier:@"screeningSectionToHearingSubsectionSegue" sender:self];
            return;
        } else if (indexPath.row == AdvancedVision) {
            [self performSegueWithIdentifier:@"screeningSectionToSeriSubsectionSegue" sender:self];
            return;
        } else if (indexPath.row == AdvancedGeriatric) {
            [self performSegueWithIdentifier:@"screeningSectionToAdvGeriatricsSectionSegue" sender:self];
            return;
        } else if (indexPath.row == FallRiskAssessment) {
            selectedRow = [NSNumber numberWithInteger:FallRiskAssessment];
        }
        else if (indexPath.row == EmergencyServices) {
            selectedRow = [NSNumber numberWithInteger:EmergencyServices];
        }  else if (indexPath.row == Summary_HealthEducation) {
            selectedRow = [NSNumber numberWithInteger:Summary_HealthEducation];
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
        _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
    } else {
        [_completionCheck removeAllObjects];
    }
    NSDictionary *checksDict = [_fullScreeningForm objectForKey:SECTION_CHECKS];
    NSDictionary *modeOfScreeningDict = [_fullScreeningForm objectForKey:SECTION_MODE_OF_SCREENING];
    
    NSArray *lookupTable = @[kCheckClinicalResults, kCheckPhlebResults, @"check_overall_profiling", kCheckSnellenTest, @"check_overall_adv_ger", kCheckPhysiotherapy, kCheckBasicDental, @"check_overall_hearing", @"check_overall_adv_vision", kCheckEmergencyServices ,kCheckAddServices,@"check_overall_sw", kCheckEd];
    // 2019
    // removed kCheckAdvFallRiskAssmt, kCheckDocConsult
    
    if (checksDict != nil && checksDict != (id)[NSNull null]) {
        
        for (int i=0; i<[lookupTable count]; i++) {
            
            if (i == Profiling) {
                [_completionCheck addObject:[self checkAllProfilingSections:checksDict]];
            } else if (i == Phlebotomy) {
                
                NSString *neighbourhood = [[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood];
                if ([neighbourhood containsString:@"Kampong"]) {
                    NSString *key = lookupTable[i];
                    NSNumber *doneNum = [checksDict objectForKey:key];
                    [_completionCheck addObject:doneNum];
                } else {
                    [_completionCheck addObject:@1];    //since 2a is disabled for Leng Kee
                }
                
                
                
            }
            else if (i == AdvancedGeriatric) {
                if (![[ResidentProfile sharedManager] isEligibleGeriatricDementiaAssmt]) {  //not eligible
                    [_completionCheck addObject:@1];
                }
                else {
                    [_completionCheck addObject:[self checkAllAdvGeriatricSections:checksDict]];
                }
            }
            else if (i == FallRiskAssessment) {
                if (![[ResidentProfile sharedManager] isEligibleFallRiskAssessment]) {
                    [_completionCheck addObject:@1];
                } else {
                    NSString *key = lookupTable[i];
                    
                    NSNumber *doneNum = [checksDict objectForKey:key];
                    [_completionCheck addObject:doneNum];
                }
            }
            
            else if (i == Dental) {
                if (modeOfScreeningDict != (id)[NSNull null]) {
                    NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
                    if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
                        [_completionCheck addObject:@1];    // considered as completed
                        continue;
                    }
                }
                NSString *key = lookupTable[i];
                
                NSNumber *doneNum = [checksDict objectForKey:key];
                [_completionCheck addObject:doneNum];
            }
            else if (i == Hearing) {
                if (modeOfScreeningDict != (id)[NSNull null]) {
                    NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
                    if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
                        [_completionCheck addObject:@1];    // considered as completed
                        continue;
                    }
                }
                
                if (![[ResidentProfile sharedManager] isEligibleHearing]) {
                    [_completionCheck addObject:@1];
                } else {
                    [_completionCheck addObject:[self checkAllHearingSections:checksDict]];
                }
            }
            else if (i == AdvancedVision) {
                if (modeOfScreeningDict != (id)[NSNull null]) {
                    NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
                    if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
                        [_completionCheck addObject:@1];    // considered as completed
                        continue;
                    }
                }
                
                if (![[ResidentProfile sharedManager] isEligibleAdvancedVision]) {  //not eligible
                    [_completionCheck addObject:@1];
                } else {
                    //check all advanced vision
                    [_completionCheck addObject:[self checkAllSeriSections:checksDict]];
                }
            }
            else if (i == EmergencyServices) {
                if (![[ResidentProfile sharedManager] isEligibleEmerSvcs]) {  //not eligible
                    [_completionCheck addObject:@1];
                } else {
                    NSString *key = lookupTable[i];
                    
                    NSNumber *doneNum = [checksDict objectForKey:key];
                    [_completionCheck addObject:doneNum];
                }
            }
            else if (i == SocialWork) {
                if (![[ResidentProfile sharedManager] isEligibleSocialWork]) {  //not eligible
                    [_completionCheck addObject:@1];
                } else {
                    [_completionCheck addObject:[self checkAllSocialWorkSections:checksDict]];
                }
            }
            else if (i == AdditionalServices) {
                if (![[ResidentProfile sharedManager] isEligibleCHAS] &&    //if all also not eligible, considered as finished already!
                    ![[ResidentProfile sharedManager] isEligibleReceiveFIT] &&
                    ![[ResidentProfile sharedManager] isEligibleReferMammo] &&
                    ![[ResidentProfile sharedManager] isEligibleReferPapSmear]) {
                    [_completionCheck addObject:@1];
                } else {
                    NSString *key = lookupTable[i];
                    
                    NSNumber *doneNum = [checksDict objectForKey:key];
                    [_completionCheck addObject:doneNum];
                }
            }
            
            
            else if (i == Summary_HealthEducation) {
                [_completionCheck addObject:@0];    //Summary don't need checklist
            }
            else {
                NSString *key = lookupTable[i];
                
                NSNumber *doneNum = [checksDict objectForKey:key];
                [_completionCheck addObject:doneNum];
            }
            
        }
    } else {
        
    }
    
}

- (void) checkReadyToSubmit {
    
    NSMutableArray *arr = [_completionCheck mutableCopy];   //don't modify the original array!
    
    if ([arr count] == 0) { //still no checks at all
        readyToSubmit = false;
        return;
    }
//    NSDictionary *modeOfScreeningDict = [_fullScreeningForm objectForKey:SECTION_MODE_OF_SCREENING];
//    if (modeOfScreeningDict != (id)[NSNull null]) {
//        NSString *screenMode = [modeOfScreeningDict objectForKey:kScreenMode];
//        if (screenMode != (id)[NSNull null] && [screenMode containsString:@"Door"]) {
//            // These are all optional for Door-to-Door
//            [arr removeObjectAtIndex:Hearing];
//            [arr removeObjectAtIndex:Dental];
//            [arr removeObjectAtIndex:AdvancedGeriatric];
//        }
//    }
    
    if ([_fullScreeningForm objectForKey:SECTION_CHECKS] != (id) [NSNull null]) {
        
        int count =0;
        
        for (int i=0; i< [arr count]; i++) {
            NSNumber *value = [arr objectAtIndex:i];
            if ([value isEqual:@1]) count++;
        }
        
        if (count == ([arr count]-1))  readyToSubmit = true;    //because summary & health edu can never be complete
        else readyToSubmit = false;
    } else {
        readyToSubmit = false;
    }
}

- (NSNumber *) checkAllProfilingSections:(NSDictionary *) checksDict {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSInteger residentAge = [[defaults objectForKey:kResidentAge] integerValue];
    
    if ([[ResidentProfile sharedManager] profilingDone]) return @1;
    else return @0;
//    for (NSString *key in [checksDict allKeys]) {   //check through all 5 sub-sections
//        if ([key isEqualToString:kCheckDiabetes] || [key isEqualToString:kCheckHypertension] || [key isEqualToString:kCheckHyperlipidemia] || [key isEqualToString:kCheckProfiling] || [key isEqualToString:kCheckRiskStratification]) {
//            if ([[checksDict objectForKey:key] isEqual:@1])
//                count++;
//        }
//    }
//    if (count == 5) return @1;
//    else if (count == 4 && residentAge < 65) return @1;    //age less than 65 not qualified for Depression
//    else return @0;
}

- (NSNumber *) checkAllHearingSections:(NSDictionary *) checksDict {
    int count=0;
    
    for (NSString *key in [checksDict allKeys]) {   //check through all 5 sub-sections
        if ([key isEqualToString:kCheckHearing] || [key isEqualToString:kCheckFollowUp]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
        }
    }
    if (count == 2) return @1;
    else return @0;
}

- (NSNumber *) checkAllAdvGeriatricSections:(NSDictionary *) checksDict {
    int count=0;
    
    for (NSString *key in [checksDict allKeys]) {   //check through all 5 sub-sections
        if ([key isEqualToString:kCheckReferrals] || [key isEqualToString:kCheckGeriatricDementiaAssmt]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
        }
    }
    if (count == 2) return @1;
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
        if ([key isEqualToString:kCheckSwAdvAssmt] || [key isEqualToString:kCheckSwDepression] || [key isEqualToString:kCheckSwReferrals]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
        }
    }
    if (count == 3) {
        return @1;
    }
    else if (count == 2) {  //all other two are finalized, except Depression
        if (![[ResidentProfile sharedManager] isEligiblePHQ9]) {
            return @1;
        }
    }
    return @0;
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

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
@property (strong, nonatomic) NSMutableDictionary *fullScreeningForm;
@property (strong, nonatomic) NSString *loadedFilepath;

@end

@implementation ScreeningSectionTableViewController {
    NSNumber *selectedRow;
    BOOL readyToSubmit;
    NSInteger formType;
}

- (void)viewDidLoad {   //will only happen when it comes from New Resident / Use Existing Resident
    
    _fullScreeningForm = [[[ScreeningDictionary sharedInstance] dictionary] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];
    
    formType = NewScreeningForm;    //default value
    
    readyToSubmit = false;
    
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data

    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
    
    @synchronized (self) {
        [self updateCellAccessory];
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
    
    self.rowTitles = @[@"📶 Phlebotomy", @"📶 Mode of Screening",@"📶 Profiling", @"📶 Health Assessment & Risk Stratification", @"Social Work", @"📶 Triage", @"📶 Snellen Eye Test", @"📶 Additional Services", @"📶 Doctor's Consultation", @"📶 Basic Dental Check-up", @"SERI Advanced Eye Screening", @"📶 Fall Risk Assessment", @"📶 Geriatric Dementia Asssesment", @"📶 Health Education"];
    
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
    
        if ((indexPath.row >= SeriAdvancedEyeScreening) && (indexPath.row <= GeriatricDementiaAssess)) {   //between 10 to 12
            if (indexPath.row == SeriAdvancedEyeScreening) {  //SERI
                //Enable SERI
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifySeri] isEqual:@"1"]) {
                    cell.userInteractionEnabled = YES;
                    [cell.textLabel setTextColor:[UIColor blackColor]];
                    return cell;    //don't disable.
                }
            } else if (indexPath.row == FallRiskAssessment) {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifyFallAssess] isEqual:@"1"]) {
                    cell.userInteractionEnabled = YES;
                    [cell.textLabel setTextColor:[UIColor blackColor]];
                    return cell;    //don't disable.
                }
            } else if (indexPath.row == GeriatricDementiaAssess) {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kQualifyDementia] isEqual:@"1"]) {
                    cell.userInteractionEnabled = YES;
                    [cell.textLabel setTextColor:[UIColor blackColor]];
                    return cell;    //don't disable.
                }
            }
            
            cell.userInteractionEnabled = NO;
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:buttonTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonTableIdentifier];
        }
        
        cell.textLabel.text = @"Submit";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        
        if (readyToSubmit) {    //if enabled
            cell.backgroundColor = [UIColor colorWithRed:0 green:51/255.0 blue:102/255.0 alpha:1];  //dark blue
            cell.userInteractionEnabled = YES;
        }
        else {  //if disabled
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
    else {    //submit button
        [self performSegueWithIdentifier:@"ScreeningSectionToSummaryPageSegue" sender:self];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

//- (void) setRetrievedData:(NSDictionary *)dictionary {
//    self.retrievedData = dictionary;
//}

# pragma mark - Buttons

-(void)backBtnPressed:(id)sender
{
    if (formType != ViewScreenedScreeningForm) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                                                                  message:@""
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                            style:UIAlertActionStyleDestructive
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

#pragma mark - NSNotification Methods

- (void) reloadTable: (NSNotification *) notification {
    _fullScreeningForm =[[ScreeningDictionary sharedInstance] dictionary];
    @synchronized (self) {
        [self updateCellAccessory];
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
//            [self getAllDataForOneResident];
            [[ScreeningDictionary sharedInstance] fetchFromServer];
    }
    
}

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

- (NSNumber *) checkAllHealthAssmtRiskStratSections:(NSDictionary *) checksDict {
    int count=0;
    for (NSString *key in [checksDict allKeys]) {   //check through all 5 sub-sections
#warning Dementia Assessment might not be applicable to all persons!
        if ([key isEqualToString:kCheckDiabetes] || [key isEqualToString:kCheckHypertension] || [key isEqualToString:kCheckHyperlipidemia] || [key isEqualToString:kCheckDementia] || [key isEqualToString:kCheckRiskStrat]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
            else
                return @0;
        }
    }
    if (count == 5) return @1;
    else return @0;
}


- (NSNumber *) checkAllSeriSections:(NSDictionary *) checksDict {
    int count=0;
    for (NSString *key in [checksDict allKeys]) {
#warning SERI might not be applicable to all persons!
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
        if ([key isEqualToString:kCheckGeno] || [key isEqualToString:kCheckSocioEco] || [key isEqualToString:kCheckCurrentPhyStatus] || [key isEqualToString:kCheckSocialSupport] || [key isEqualToString:kCheckPsychWellbeing] || [key isEqualToString:kCheckSwAddServices] || [key isEqualToString:kCheckSwAddServices]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
            else
                return @0;
        } 
    }
    if (count == 7) return @1;
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

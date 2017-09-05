//
//  ScreeningSectionTableViewController.m
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ScreeningSectionTableViewController.h"
#import "ScreeningFormViewController.h"
#import "SummaryPageViewController.h"
#import "ServerComm.h"
#import "AppConstants.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

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
    
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];
    
    formType = NewScreeningForm;    //default value
    
    readyToSubmit = false;
    
    self.fullScreeningForm = [[NSMutableDictionary alloc] init];
    
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    status = [reachability currentReachabilityStatus];
    [self processConnectionStatus];
    
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
    
    self.rowTitles = @[@"📶 Phlebotomy", @"📶 Mode of Screening",@"📶 Profiling", @"📶 Health Assessment & Risk Stratification", @"Social Work", @"📶 Triage", @"📶 Snellen Eye Test", @"Additional Services", @"📶 Doctor's Consultation", @"📶 Basic Dental Check-up", @"SERI Advanced Eye Screening", @"Fall Risk Assessment", @"Geriatric Dementia Asssesment", @"📶 Health Education"];
    
     self.clearsSelectionOnViewWillAppear = YES;
    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Screening Form";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFullScreeningForm:)
                                                 name:@"updateFullScreeningForm"
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateCompletionCheck:)
//                                                 name:@"updateCompletionCheck"
//                                               object:nil];
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
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kNeedSERI] isEqual:@"1"]) {
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
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Draft", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * deleteDraftAction) {
                                                              //                                                          [self deleteDraft];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save Draft", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * saveDraftAction) {
                                                              [self saveDraft];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshScreeningResidentTable"
                                                                                                                  object:nil
                                                                                                                userInfo:nil];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - NSNotification Methods
- (void) updateFullScreeningForm: (NSNotification *) notification {

    [self getAllDataForOneResident];
}

- (void) updateFormType: (NSNotification *) notification {
    formType = LoadedDraftScreeningForm;        //changed status
}

#pragma mark Save,Load & Delete Methods

- (void) autoSave {
    

    NSString *nric = [[[self.fullScreeningForm objectForKey:@"resi_particulars"] objectForKey:kNRIC] stringByAppendingString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [nric stringByAppendingString:@"autosave"]; //Eg. S12313K_autosave
    NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Screening"];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
    
//    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:NULL];
//    for (count = 0; count < (int)[directoryContent count]; count++)
//    {
//        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
//    }
    
    
    
    //Save the form locally on the iPhone
    [self.fullScreeningForm writeToFile:filePath atomically:YES];

}

- (void) saveDraft {
    
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    NSString *ts = [[localDateTime description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    NSString *nric = [[[self.fullScreeningForm objectForKey:@"resi_particulars"] objectForKey:kNRIC] stringByAppendingString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [nric stringByAppendingString:ts]; //Eg. S12313K_datetime
    NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Screening"];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
    //Save the form locally on the iPhone
    [self.fullScreeningForm writeToFile:filePath atomically:YES];
}

- (void) deleteDraft {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *nric = [self.fullScreeningForm objectForKey:kNRIC];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Pre-registration"];
    NSArray *localSavedFilenames = [fileManager contentsOfDirectoryAtPath:folderPath
                                                                    error:nil];
    NSString *filename = @"";
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
    }
}

- (void) loadDraftIfAny {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Screening"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *localFiles = [fileManager contentsOfDirectoryAtPath:folderPath
                                                           error:nil];
    NSString *filename = [localFiles objectAtIndex:[self.residentLocalFileIndex intValue]];
    self.loadedFilepath = [[NSString alloc] initWithString:[folderPath stringByAppendingPathComponent:filename]];
    self.fullScreeningForm = [[NSDictionary dictionaryWithContentsOfFile:self.loadedFilepath] mutableCopy];
    NSLog(@"Retrieved Dictionary from Local File:\n%@", self.fullScreeningForm);
}


- (void) insertRequestDataToScreeningForm {
    NSArray* keys = [self.retrievedData allKeys];
    NSString *key;
    NSDictionary *retrievedSectionsDict;
    NSMutableDictionary *currentSectionDict;
    
    
    for (key in keys) {
        if ([self.retrievedData objectForKey:key] != [NSNull null]) {
            if ([[self.retrievedData objectForKey:key] isKindOfClass:[NSDictionary class]]) {      //double check surely have something
                retrievedSectionsDict = [self.retrievedData objectForKey:key];
                currentSectionDict = [[self.fullScreeningForm objectForKey:key] mutableCopy];
                NSArray *keys2 = [retrievedSectionsDict allKeys];
                NSString *key2;
                
                for (key2 in keys2) {
                    if ([retrievedSectionsDict objectForKey:key2] != [NSNull null]) {
                        if ([[retrievedSectionsDict objectForKey:key2] isKindOfClass:[NSArray class]]) {    //looking for bp_records
                            if ([[retrievedSectionsDict objectForKey:key2] count] > 0) {
                                [currentSectionDict setObject:[retrievedSectionsDict objectForKey:key2] forKey:key2];
                            }
                        } else {
                            [currentSectionDict setObject:[retrievedSectionsDict objectForKey:key2] forKey:key2];
                        }
                        
                    }
                }
                [self.fullScreeningForm setObject:currentSectionDict forKey:key];   //copy the mutableCopy to the original
            }
        }
    }
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
            [self getAllDataForOneResident];
    }
    
}

- (void)getAllDataForOneResident {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [SVProgressHUD showWithStatus:@"Downloading data..."];
    
    [client getSingleScreeningResidentDataWithResidentID:_residentID
                                           progressBlock:[self progressBlock]
                                            successBlock:[self downloadSingleResidentDataSuccessBlock]
                                            andFailBlock:[self downloadErrorBlock]];
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        //        NSLog(@"Patients GET Request Started. In Progress.");
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSingleResidentDataSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        self.fullScreeningForm = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        NSLog(@"%@", self.fullScreeningForm); //replace the existing one
        
        [self saveCoreData];
        [self prepareAdditionalSvcs];
        // save all the qualify stuffs for additional services
        
        @synchronized (self) {
            [self updateCellAccessory];
            [self.tableView reloadData];    //put in the ticks
        }
        
        [SVProgressHUD dismiss];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))downloadErrorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"******UNSUCCESSFUL DOWNLOAD******!!");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSString *errorString =[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSLog(@"error: %@", errorString);
        [SVProgressHUD dismiss];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Download Fail", nil)
                                                                                  message:@"Download form failed!"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction) {
                                                              [self.tableView reloadData];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    };
}



- (void) saveCoreData {
    
    NSDictionary *particularsDict =[_fullScreeningForm objectForKey:SECTION_RESI_PART];
    NSDictionary *profilingDict =[_fullScreeningForm objectForKey:SECTION_PROFILING_SOCIOECON];
    
    // Calculate age
    NSMutableString *str = [particularsDict[kBirthDate] mutableCopy];
    NSString *yearOfBirth = [str substringWithRange:NSMakeRange(0, 4)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
    
    
    //    [[NSUserDefaults standardUserDefaults] setObject:_sampleResidentDict[kGender] forKey:kGender];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:age] forKey:kResidentAge];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kResidentId] forKey:kResidentId];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kScreenLocation] forKey:kNeighbourhood];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kName] forKey:kName];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kNRIC] forKey:kNRIC];
    
    // For Current Socioecon Situation
    if (profilingDict != (id)[NSNull null] && profilingDict[kEmployStat] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:profilingDict[kEmployStat] forKey:kEmployStat];
    if (profilingDict != (id)[NSNull null] && profilingDict[kAvgMthHouseIncome] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:profilingDict[kAvgMthHouseIncome] forKey:kAvgMthHouseIncome];
    
    // For demographics
    if (particularsDict[kCitizenship] != (id) [NSNull null])        //check for null first
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kCitizenship] forKey:kCitizenship];
    if (particularsDict[kReligion] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kReligion] forKey:kReligion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) prepareAdditionalSvcs {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    /* CHAS */
    NSDictionary *chasDict = [_fullScreeningForm objectForKey:SECTION_CHAS_PRELIM];
    BOOL noChas=false, lowIncome=false, wantChas=false;
    
    if (chasDict != (id)[NSNull null]) {
        
        if (chasDict[kDoesntOwnChasPioneer] != (id)[NSNull null])
            noChas = [chasDict[kDoesntOwnChasPioneer] boolValue];
        if (chasDict[kLowHouseIncome] != (id)[NSNull null])
            lowIncome = [chasDict[kLowHouseIncome] boolValue];
        if (chasDict[kWantChas] != (id)[NSNull null])
            wantChas = [chasDict[kWantChas] boolValue];
        if (noChas && lowIncome && wantChas) {
            [defaults setObject:@"1" forKey:kQualifyCHAS];
        }
    }
    
    
    /* Colonoscopy */
    NSDictionary *colonDict = [_fullScreeningForm objectForKey:SECTION_COLONOSCOPY_ELIGIBLE];
    BOOL sporeanPr = false, age50 = false, relColorectCancer=false, colon3Yrs=false, wantColRef=false;
    
    if (colonDict != (id)[NSNull null]) {
        if ([[defaults objectForKey:kCitizenship] isEqualToString:@"Singaporean"] || [[defaults objectForKey:kCitizenship] isEqualToString:@"PR"]) {
            sporeanPr = true;
        } else {
            sporeanPr = false;
        }
        
        if ([[defaults objectForKey:kResidentAge] intValue] > 49)
            age50 = true;
        else
            age50 = false;
        
        if (colonDict[kRelWColorectCancer] != (id)[NSNull null])
            relColorectCancer = [colonDict[kRelWColorectCancer] boolValue];
        if (colonDict[kColonoscopy3yrs] != (id)[NSNull null])
            colon3Yrs = [colonDict[kColonoscopy3yrs] boolValue];
        if (colonDict[kWantColonoscopyRef] != (id)[NSNull null])
            wantColRef = [colonDict[kWantColonoscopyRef] boolValue];
        
        if (sporeanPr && age50 && relColorectCancer && colon3Yrs && wantColRef)
            [defaults setObject:@"1" forKey:kQualifyColonsc];
    }
    
    /* FIT Kit */
    //SporeanPr and age50 from above.
    NSDictionary *fitDict = [_fullScreeningForm objectForKey:SECTION_FIT_ELIGIBLE];
    BOOL fit12Mths=false, colon10Yrs=false, wantFitKit=false;
    if (fitDict != (id)[NSNull null]) {
        
        if (fitDict[kFitLast12Mths] != (id)[NSNull null])
            fit12Mths = [fitDict[kFitLast12Mths] boolValue];
        if (fitDict[kColonoscopy10Yrs] != (id)[NSNull null])
            colon10Yrs = [fitDict[kColonoscopy10Yrs] boolValue];
        if (fitDict[kWantFitKit] != (id)[NSNull null])
            wantFitKit = [fitDict[kWantFitKit] boolValue];
        
        if (sporeanPr && age50 && fit12Mths && colon10Yrs && wantFitKit)
            [defaults setObject:@"1" forKey:kQualifyFIT];
    }
    
    /* Mammogram */
    NSDictionary *mammoDict = [_fullScreeningForm objectForKey:SECTION_MAMMOGRAM_ELIGIBLE];
    BOOL sporean = false, age5069, noMammo2Yrs = false, hasChas = false, wantMammo;
    
    if (mammoDict != (id)[NSNull null]) {
        if ([[defaults objectForKey:kCitizenship] isEqualToString:@"Singaporean"]) {
            sporean = true;
        } else {
            sporean = false;
        }
        
        if ([[defaults objectForKey:kResidentAge] intValue] >= 50 && [[defaults objectForKey:kResidentAge] intValue] <= 69)
            age5069 = true;
        else
            age5069 = false;
        
        if (mammoDict[kMammo2Yrs] != (id)[NSNull null])
            noMammo2Yrs = [mammoDict[kMammo2Yrs] boolValue];
        if (mammoDict[kHasChas] != (id)[NSNull null])
            hasChas = [mammoDict[kHasChas] boolValue];
        if (mammoDict[kWantMammo] != (id)[NSNull null])
            wantMammo = [mammoDict[kWantMammo] boolValue];
        
        if (sporean && age5069 && noMammo2Yrs && hasChas && kWantMammo)
            [defaults setObject:@"1" forKey:kQualifyMammo];
    
    }
    
    
    
    /* Pap Smear */
    NSDictionary *papSmearDict = [_fullScreeningForm objectForKey:SECTION_PAP_SMEAR_ELIGIBLE];
    BOOL age2569, noPapSmear3Yrs = false, hadSex = false, wantPapSmear = false;
    
    if (papSmearDict != (id)[NSNull null]) {
        if ([[defaults objectForKey:kResidentAge] intValue] >= 25 && [[defaults objectForKey:kResidentAge] intValue] <= 69)
            age2569 = true;
        else
            age2569 = false;
        
        if (papSmearDict[kPap3Yrs] != (id)[NSNull null])
            noPapSmear3Yrs = [papSmearDict[kPap3Yrs] boolValue];
        
        if (papSmearDict[kEngagedSex] != (id)[NSNull null])
            hadSex = [papSmearDict[kEngagedSex] boolValue];
                      
        if (papSmearDict[kWantPap] != (id)[NSNull null])
            wantPapSmear = [papSmearDict[kWantPap] boolValue];
        
        if (sporean && age2569 && noPapSmear3Yrs && hadSex && wantPapSmear)
            [defaults setObject:@"1" forKey:kQualifyPapSmear];

    }
    
/*
    
    else if ([rowDescriptor.tag isEqualToString:kFallen12Mths]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kFallen12Mths andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kScaredFall]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kScaredFall andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kFeelFall]) {
        [self postSingleFieldWithSection:SECTION_FALL_RISK_ELIGIBLE andFieldName:kFeelFall andNewContent:newValue];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kCognitiveImpair]) {
        [self postSingleFieldWithSection:SECTION_GERIATRIC_DEMENTIA_ELIGIBLE andFieldName:kCognitiveImpair andNewContent:newValue];
    }*/

}

- (void) updateCellAccessory {
    
    if ([_completionCheck count] < 1) {
        _completionCheck = [[NSMutableArray alloc] init];
    } else {
        [_completionCheck removeAllObjects];
    }
    
    NSDictionary *checksDict = [_fullScreeningForm objectForKey:SECTION_CHECKS];
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

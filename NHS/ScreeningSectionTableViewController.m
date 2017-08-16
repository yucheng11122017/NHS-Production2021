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

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"
#define DISABLE_SERVER_DATA_FETCH


typedef enum typeOfForm {
    NewScreeningForm,
    PreRegisteredScreeningForm,
    LoadedDraftScreeningForm,
    ViewScreenedScreeningForm
} typeOfForm;


@interface ScreeningSectionTableViewController ()

@property (strong, nonatomic) NSArray *rowTitles;
@property (strong, nonatomic) NSMutableDictionary *preRegDictionary;
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
    [self createEmptyFormWithAllFields];
    readyToSubmit = false;
    
    self.preRegDictionary = [[NSMutableDictionary alloc] init];
    
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
    
//    self.rowTitles = @[@"Resident Particulars", @"Clinical Results",@"Screening of Risk Factors", @"Diabetes Mellitus", @"Hyperlipidemia", @"Hypertension", @"Cancer Screening", @"Other Medical Issues", @"Primary Care Source", @"My Health and My Neighbourhood", @"Demographics", @"Current Physical Issues", @"Current Socioeconomics Situation", @"Social Support Assessment", @"Referral for Doctor Consultation"];
    
    self.rowTitles = @[@"Mode of Screening", @"Phlebotomy",@"Profiling", @"Health Assessment & Risk Stratification", @"Social Work", @"Triage", @"Snellen Eye Test", @"Additional Services", @"Doctor's Consultation", @"Basic Dental Check-up", @"SERI Advanced Eye Screening", @"Fall Risk Assessment", @"Geriatric Dementia Asssesment", @"Health Education", @"Not more..."];
    
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Screening Form";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFullScreeningForm:)
                                                 name:@"updateFullScreeningForm"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCompletionCheck:)
                                                 name:@"updateCompletionCheck"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFormType:)
                                                 name:@"formEditedNotification"
                                               object:nil];
    
    
    NSArray *keys = [self.fullScreeningForm allKeys];
    NSString *key;
    for (key in keys) {
        if ([key isEqualToString:@"completion_check"]) {
            self.completionCheck = [[NSMutableArray alloc] initWithArray:[self.fullScreeningForm objectForKey:@"completion_check"]];
            break;
        }
    }
    //if initialised previously, won't do it again
    if (!self.completionCheck) {
        self.completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,nil];
    }
    int count = 0;
    for (int i=0;i<[self.completionCheck count];i++) {
        count = count + [[self.completionCheck objectAtIndex:i] intValue];
    }
    if (count == [self.completionCheck count]) {
        readyToSubmit = true;
    }
    
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
        //     [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        if ([[self.completionCheck objectAtIndex:indexPath.row] isEqualToNumber:@1]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if ((indexPath.row > 8) && (indexPath.row != 13)) {
            
            if (indexPath.row == 10) {
                //Enable SERI
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"needSERI"] isEqual:@1]) {
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
        
        if (indexPath.row == 3) {
            [self performSegueWithIdentifier:@"sectionToHARSSegue" sender:self];
            return;
        } else if (indexPath.row == 4) {
            [self performSegueWithIdentifier:@"screenSectionToSocialWorkSegue" sender:self];
            return;
        } else if (indexPath.row == 5) {    //clinical results
            selectedRow = [NSNumber numberWithInteger:3];
        } else if (indexPath.row == 6) {    //snellen eye test
            selectedRow = [NSNumber numberWithInteger:4];
        } else if (indexPath.row == 7) {    //Additional Services
            selectedRow = [NSNumber numberWithInteger:5];
        } else if (indexPath.row == 8) {    //Basic Dental Check-up
            selectedRow = [NSNumber numberWithInteger:6];
        } else if (indexPath.row == 13) {   //Health Education
            selectedRow = [NSNumber numberWithInteger:11];
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
    self.fullScreeningForm = [notification.userInfo mutableCopy];
    NSLog(@"%@", self.fullScreeningForm);
    
    if ([self.fullScreeningForm objectForKey:@"resi_particulars"] != [NSNull null]) {   //not null
        if (![[[self.fullScreeningForm objectForKey:@"resi_particulars"] objectForKey:@"nric"] isEqualToString:@""]) {  //not empty
            if (formType != ViewScreenedScreeningForm) {
                [self autoSave];
            }
        }
    }
}

- (void) updateCompletionCheck: (NSNotification *) notification {
    NSLog(@"%@", notification.userInfo);
    int section = [[notification.userInfo objectForKey:@"section"] intValue];
    NSNumber *value = [notification.userInfo objectForKey:@"value"];
    [self.completionCheck replaceObjectAtIndex:section withObject:value];
    int count=0;
    for (int i=0;i<[self.completionCheck count];i++) {
        count = count + [[self.completionCheck objectAtIndex:i] intValue];
    }
    if (count == [self.completionCheck count]) {
        readyToSubmit = true;
    }
    [self.tableView reloadData];
}

- (void) updateFormType: (NSNotification *) notification {
    formType = LoadedDraftScreeningForm;        //changed status
}

#pragma mark Save,Load & Delete Methods

- (void) autoSave {
    //save completionCheck into fullScreeningForm
    [self.fullScreeningForm setObject:self.completionCheck forKey:@"completion_check"];
//    int count;

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
    //save completionCheck into fullScreeningForm
    [self.fullScreeningForm setObject:self.completionCheck forKey:@"completion_check"];
    
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


#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"POST in progress...");
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"&******UNSUCCESSFUL SUBMISSION******!!");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSLog(@"error: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                            object:nil
                                                          userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    };
}

#pragma mark Downloading Blocks
- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        self.preRegDictionary = [[responseObject objectForKey:@"0"] mutableCopy];
        NSLog(@"%@", self.preRegDictionary);
        
        [self insertResiPartiIntoFullScreeningForm];
    };
}

#pragma mark - Downloading Pre-registration data
- (void) getPreRegistrationData {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getPatientDataWithPatientID:self.residentID
                          progressBlock:[self progressBlock]
                           successBlock:[self downloadSuccessBlock]
                           andFailBlock:[self errorBlock]];
}


- (void) createEmptyFormWithAllFields {
    
    //ONLY IF FILE IS IN iOS APP
//    NSString *fileName = @"blankScreeningForm.json";
//    NSURL *documentsFolderURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//    NSString *filePath = [documentsFolderURL.path stringByAppendingString:fileName];
//    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
//    NSError *jsonError;
//    NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
    
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"blankScreeningForm"   //load a blank screening form
                                                         ofType:@"json"];
    //check file exists
    if (fileName) {
        //retrieve file content
        NSData *data = [[NSData alloc] initWithContentsOfFile:fileName];
        //convert JSON NSData to a usable NSDictionary
        NSError *error;
        self.fullScreeningForm = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                              options:0
                                                                error:&error]];
        if (error) {
            NSLog(@"Something went wrong! %@", error.localizedDescription);
        }
        else {
            NSLog(@"%@", self.fullScreeningForm);
        }
    }
    else {
        NSLog(@"Couldn't find file!");
    }
}

- (void) insertResiPartiIntoFullScreeningForm {
    NSDictionary *contact_info = [self.preRegDictionary objectForKey:@"contact_info"];
    NSDictionary *personal_info = [self.preRegDictionary objectForKey:@"personal_info"];
    NSDictionary *spoken_lang = [self.preRegDictionary objectForKey:@"spoken_lang"];
    NSMutableDictionary *resi_particulars = [[self.fullScreeningForm objectForKey:@"resi_particulars"] mutableCopy];
    
    [resi_particulars setObject:[personal_info objectForKey:@"resident_name"] forKey:@"resident_name"];
    [resi_particulars setObject:[personal_info objectForKey:@"gender"] forKey:@"gender"];
    [resi_particulars setObject:[personal_info objectForKey:@"nric"] forKey:@"nric"];
    [resi_particulars setObject:[personal_info objectForKey:@"resident_id"] forKey:@"resident_id"];
    [resi_particulars setObject:[personal_info objectForKey:@"birth_year"] forKey:@"birth_year"];
    
    [resi_particulars setObject:[contact_info objectForKey:@"address_block"] forKey:@"address_block"];
    [resi_particulars setObject:[contact_info objectForKey:@"address_postcode"] forKey:@"address_postcode"];
    [resi_particulars setObject:[contact_info objectForKey:@"address_street"] forKey:@"address_street"];
    [resi_particulars setObject:[contact_info objectForKey:@"address_unit"] forKey:@"address_unit"];
    [resi_particulars setObject:[contact_info objectForKey:@"contact_no"] forKey:@"contact_no"];
    
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_canto"] forKey:@"lang_canto"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_english"] forKey:@"lang_english"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_hindi"] forKey:@"lang_hindi"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_hokkien"] forKey:@"lang_hokkien"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_malay"] forKey:@"lang_malay"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_mandrin"] forKey:@"lang_mandrin"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_others"] forKey:@"lang_others"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_others_text"] forKey:@"lang_others_text"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_tamil"] forKey:@"lang_tamil"];
    [resi_particulars setObject:[spoken_lang objectForKey:@"lang_teochew"] forKey:@"lang_teochew"];
    
    [self.fullScreeningForm setObject:resi_particulars forKey:@"resi_particulars"];     //replace the original form
    [self.preRegDictionary removeAllObjects];   //clear the array
    NSLog(@"********** UPDATED SCREENING FORM! ***********\n%@", self.fullScreeningForm);
    
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
//[self.fullScreeningForm setObject:[self.retrievedData objectForKey:key] forKey:key];
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

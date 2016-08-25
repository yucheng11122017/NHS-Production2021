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

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"


@interface ScreeningSectionTableViewController ()


@property (strong, nonatomic) NSArray *rowTitles;
@property (strong, nonatomic) NSMutableDictionary *preRegDictionary;
@property (strong, nonatomic) NSMutableDictionary *fullScreeningForm;

@end

@implementation ScreeningSectionTableViewController {
    NSNumber *selectedRow;
}

- (void)viewDidLoad {   //will only happen when it comes from New Resident / Use Existing Resident
    
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];
    
    self.preRegDictionary = [[NSMutableDictionary alloc] init];
    if ([self.residentID intValue]>= 0) {
        [self getPatientData];
    }
    
    self.rowTitles = @[@"Neighbourhood",@"Resident Particulars", @"Clinical Results",@"Screening of Risk Factors", @"Diabetes Mellitus", @"Hyperlipidemia", @"Hypertension", @"Cancer Screening", @"Other Medical Issues", @"Primary Care Source", @"My Health and My Neighbourhood", @"Demographics", @"Current Physical Issues", @"Current Socioeconomics Situation", @"Social Support Assessment", @"Referral for Doctor Consultation", @"Submit"];
    
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Screening Form";
    [self createEmptyFormWithAllFields];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFullScreeningForm:)
                                                 name:@"updateFullScreeningForm"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCompletionCheck:)
                                                 name:@"updateCompletionCheck"
                                               object:nil];
    
    self.completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,nil];
    [super viewDidLoad];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 17;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
//    } else {
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//    }

    
    selectedRow = [NSNumber numberWithInteger:indexPath.row];
    
    [self performSegueWithIdentifier:@"screeningSectionToFormSegue" sender:self];
    NSLog(@"Form segue performed!");

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

# pragma mark - Buttons

-(void)backBtnPressed:(id)sender
{
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
//                                                          [self saveDraft];
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreRegPatientTable"
                                                                                                              object:nil
                                                                                                            userInfo:nil];
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - NSNotification Methods
- (void) updateFullScreeningForm: (NSNotification *) notification {
    self.fullScreeningForm = [notification.userInfo mutableCopy];
    NSLog(@"%@", self.fullScreeningForm);
}

- (void) updateCompletionCheck: (NSNotification *) notification {
    NSLog(@"%@", notification.userInfo);
    int section = [[notification.userInfo objectForKey:@"section"] intValue];
    NSNumber *value = [notification.userInfo objectForKey:@"value"];
    [self.completionCheck replaceObjectAtIndex:section withObject:value];
    [self.tableView reloadData];
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

#pragma mark - Downloading Patient Details
- (void)getPatientData {
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController respondsToSelector:@selector(setSectionID:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setSectionID:)
                                              withObject:selectedRow];
        
//        if ([selectedRow isEqualToNumber:[NSNumber numberWithInt:1]]) {    //Resident Particulars
            if ([segue.destinationViewController respondsToSelector:@selector(setFullScreeningForm:)]) {
                [segue.destinationViewController performSelector:@selector(setFullScreeningForm:)
                                                      withObject:self.fullScreeningForm];
            }
//        }
//        [segue.destinationViewController performSelector:@selector(setResidentPersonalData:)
//                                              withObject:selectedRow];
    }
}


@end

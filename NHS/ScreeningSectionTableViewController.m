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
@property (strong, nonatomic) NSDictionary *preRegDictionary;
@end

@implementation ScreeningSectionTableViewController {
    NSNumber *selectedRow;
}

- (void)viewDidLoad {
    
    self.preRegDictionary = [[NSDictionary alloc] init];
    if ((self.patientID != (id) [NSNull null])&&(self.patientID!=nil)) {
        [self getPatientData];
    }
    
    self.rowTitles = @[@"Neighbourhood",@"Resident Particulars", @"Clinical Results",@"Screening of Risk Factors", @"Diabetes Mellitus", @"Hyperlipidemia", @"Hypertension", @"Cancer Screening", @"Other Medical Issues", @"Primary Care Source", @"My Health and My Neighbourhood", @"Demographics", @"Current Physical Issues", @"Current Socioeconomics Situation", @"Social Support Assessment", @"Referral for Doctor Consultation", @"Submit"];
    
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Screening Form";
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    cell.textLabel.text = [self.rowTitles objectAtIndex:indexPath.row];
     [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
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

#pragma mark Downloading Blocks


- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        self.preRegDictionary = [responseObject objectForKey:@"0"];
        NSLog(@"%@", self.preRegDictionary);
    };
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

//#pragma mark -
//- (NSArray *) getSpokenLangArray: (NSDictionary *) spoken_lang {
//    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
//    if([[spoken_lang objectForKey:@"lang_canto"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
//    if([[spoken_lang objectForKey:@"lang_english"] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
//    if([[spoken_lang objectForKey:@"lang_hindi"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
//    if([[spoken_lang objectForKey:@"lang_hokkien"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
//    if([[spoken_lang objectForKey:@"lang_malay"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
//    if([[spoken_lang objectForKey:@"lang_mandrin"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
//    if([[spoken_lang objectForKey:@"lang_others"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Others"];
//    if([[spoken_lang objectForKey:@"lang_tamil"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
//    if([[spoken_lang objectForKey:@"lang_teochew"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
//    
//    return spokenLangArray;
//}
//
//- (NSArray *) getPreferredTimeArray: (NSDictionary *) others_prereg {
//    NSMutableArray *preferredTimeArray = [[NSMutableArray alloc] init];
//    if([[others_prereg objectForKey:@"time_slot_9_11"] isEqualToString:@"1"]) [preferredTimeArray addObject:@"9-11"];
//    if([[others_prereg objectForKey:@"time_slot_11_1"] isEqualToString:@"1"]) [preferredTimeArray addObject:@"11-1"];
//    if([[others_prereg objectForKey:@"time_slot_1_3"] isEqualToString:@"1"]) [preferredTimeArray addObject:@"1-3"];
//    
//    return preferredTimeArray;
//}
//
//- (NSDictionary *) preparePersonalInfoDict {
//    
//    NSDictionary *personalInfoDict = [[NSDictionary alloc] init];
//    NSDictionary *dict = [[NSDictionary alloc] init];
//    NSString *gender = [[NSString alloc] init];
//    
//    if ([[[self.form formValues] objectForKey:@"gender"] isEqualToString:@"Male"]) {
//        gender = @"M";
//    } else {
//        gender = @"F";
//    }
//    // get current date/time
//    NSDate *today = [NSDate date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
//    
//    dict = @{@"resident_name":[[self.form formValues] objectForKey:@"name"],
//             @"nric":[[self.form formValues] objectForKey:@"nric"],
//             @"gender":gender,
//             @"birth_year":[[self.form formValues] objectForKey:@"dob"],
//             @"ts":[localDateTime description]      //changed to NSString
//             };
//    
//    personalInfoDict = @{@"personal_info":dict};
//    [self.completePreRegForm removeAllObjects];
//    [self.completePreRegForm addObject:personalInfoDict];
//    
//    return personalInfoDict;
//}

#pragma mark - Downloading Patient Details
- (void)getPatientData {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getPatientDataWithPatientID:self.patientID
                          progressBlock:[self progressBlock]
                           successBlock:[self downloadSuccessBlock]
                           andFailBlock:[self errorBlock]];
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
}


@end

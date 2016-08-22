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
    
    self.navigationItem.hidesBackButton = YES;      //using back bar button is complicated...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backBtnPressed:)];
    
    self.preRegDictionary = [[NSDictionary alloc] init];
    if ([self.residentID intValue]>= 0) {
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
        self.preRegDictionary = [responseObject objectForKey:@"0"];
        NSLog(@"%@", self.preRegDictionary);
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController respondsToSelector:@selector(setSectionID:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setSectionID:)
                                              withObject:selectedRow];
        
        if ([selectedRow isEqualToNumber:[NSNumber numberWithInt:1]]) {    //Resident Particulars
            if ([self.preRegDictionary allKeys]) {
                [segue.destinationViewController performSelector:@selector(setpreRegParticularsDict:)
                                                  withObject:self.preRegDictionary];
            }
        }
//        [segue.destinationViewController performSelector:@selector(setResidentPersonalData:)
//                                              withObject:selectedRow];
    }
}


@end

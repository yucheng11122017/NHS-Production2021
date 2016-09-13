//
//  ResidentFollowUpHistoryTableViewController.m
//  NHS
//
//  Created by Nicholas Wong on 9/13/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ResidentFollowUpHistoryTableViewController.h"
#import "SummaryReportViewController.h"
#import "MBProgressHUD.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "AppConstants.h"

typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;


@interface ResidentFollowUpHistoryTableViewController () {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSDictionary* retrievedScreeningData;
@end

@implementation ResidentFollowUpHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Retrieved Blood Test Data: %@", self.retrievedData);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Pertinent Info";
    } else {
        return @"Follow-up Records";
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    else return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";

    UITableViewCell *cell;
    
    if (indexPath.section == 0) {   //for the questionaires
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
        }
        
        cell.textLabel.text = @"Report Summary";

    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"House Visit %ld", (indexPath.row+1)];
    }
//    else {
//        cell = [tableView dequeueReusableCellWithIdentifier:buttonTableIdentifier];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonTableIdentifier];
//        }
//        
//        cell.textLabel.text = @"Submit";
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
//        cell.textLabel.textColor = [UIColor whiteColor];
//        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
//        
//        if (readyToSubmit) {    //if enabled
//            cell.backgroundColor = [UIColor colorWithRed:0 green:51/255.0 blue:102/255.0 alpha:1];  //dark blue
//            cell.userInteractionEnabled = YES;
//        }
//        else {  //if disabled
//            cell.userInteractionEnabled = NO;
//            cell.backgroundColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1];  //grayed out
//        }
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the label text.
    hud.label.text = NSLocalizedString(@"Loading...", @"HUD loading title");
    
    if (indexPath.section == 0) {   //Report Summary
        [self getAllScreeningData];
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    
}

- (void)getAllScreeningData {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getSingleScreeningResidentDataWithResidentID:_residentID
                                           progressBlock:[self progressBlock]
                                            successBlock:[self downloadSingleResidentDataSuccessBlock]
                                            andFailBlock:[self errorBlock]];
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        //        NSLog(@"Patients GET Request Started. In Progress.");
    };
}



- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSingleResidentDataSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        self.retrievedScreeningData = [[NSDictionary alloc] initWithDictionary:responseObject];
        NSLog(@"%@", self.retrievedScreeningData);
        [self performSegueWithIdentifier:@"LoadReportSummarySegue" sender:self];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Patients data fetch was unsuccessful!");
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                  message:@"Can't fetch data from server!"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction) {
                                                              [self.tableView reloadData];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    };
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

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [hud hideAnimated:YES];
//    if ([segue.destinationViewController respondsToSelector:@selector(setResidentID:)]) {    //view submitted form
//        [segue.destinationViewController performSelector:@selector(setResidentID:)
//                                              withObject:selectedResidentID];
//    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setFullScreeningForm:)]) {
        [segue.destinationViewController performSelector:@selector(setFullScreeningForm:)
                                              withObject:self.retrievedScreeningData];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setBloodTestResult:)]) {
        [segue.destinationViewController performSelector:@selector(setBloodTestResult:)
                                              withObject:self.retrievedData];
    }
    
}

@end

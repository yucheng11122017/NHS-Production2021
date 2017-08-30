//
//  MedicalHistoryTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/8/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "MedicalHistoryTableVC.h"
#import "AppConstants.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ServerComm.h"
#import "HealthAssessAndRiskFormVC.h"


@interface MedicalHistoryTableVC () {
    NSNumber *selectedRow;
    BOOL internetDCed;
    
}

@property (strong, nonatomic) NSArray *rowLabelsText;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSNumber *residentID;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;

@end

@implementation MedicalHistoryTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    
    self.navigationItem.title = @"Medical History";
    _rowLabelsText= [[NSArray alloc] initWithObjects:@"📶 Diabetes Mellitus",@"📶 Hyperlipidemia",@"📶 Hypertension", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    
        // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateInterfaceWithReachability:self.hostReachability];
    
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
    return [_rowLabelsText count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DEFAULT_ROW_HEIGHT_FOR_SECTIONS;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    NSString *text = [_rowLabelsText objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:text];
    // Configure the cell...
    

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = [NSNumber numberWithInteger:indexPath.row];
    
    [self performSegueWithIdentifier:@"medHistToFormSegue" sender:self];
    
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
                
                [SVProgressHUD setMaximumDismissTimeInterval:2.0];
                [SVProgressHUD showErrorWithStatus:@"No Internet!"];
                
                
                break;
            }
            case ReachableViaWiFi:
            case ReachableViaWWAN:
                NSLog(@"Connected to server!");
                
                [self getAllDataForOneResident];
                
                if (internetDCed) { //previously disconnected
                    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
                    [SVProgressHUD showSuccessWithStatus:@"Back Online!"];
                    internetDCed = false;
                }
                break;
                
            default:
                break;
        }
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

- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSingleResidentDataSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        self.fullScreeningForm = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        NSLog(@"%@", self.fullScreeningForm);
        
        [SVProgressHUD dismiss];
    };
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.destinationViewController respondsToSelector:@selector(setFormID:)]) {    //view submitted form
         [segue.destinationViewController performSelector:@selector(setFormID:)
                                               withObject:selectedRow];
     }
     
     // Go straight to HealthRisk FormVC
     if ([segue.destinationViewController respondsToSelector:@selector(setFullScreeningForm:)]) {    //view submitted form
         [segue.destinationViewController performSelector:@selector(setFullScreeningForm:)
                                               withObject:_fullScreeningForm];
     }
 
 }



@end

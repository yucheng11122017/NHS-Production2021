//
//  SelectProfileTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/3/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "ScreeningSelectProfileTableVC.h"
#import "ResidentParticularsVC.h"
#import "AppConstants.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "SVProgressHUD.h"


#define ERROR_INFO @"com.alamofire.serialization.response.error.data"


typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;

@interface ScreeningSelectProfileTableVC () {
    NetworkStatus status;
    int fetchDataState;
}


@property (strong, nonatomic) NSArray *yearlyProfile;
@property (strong, nonatomic) NSDictionary *residentParticulars;
@property (strong, nonatomic) NSNumber *residentID;

@end

@implementation ScreeningSelectProfileTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Integrated Profile";
    _yearlyProfile = [[NSArray alloc] initWithObjects:@"2017",@"2018",@"2019", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    
    _residentParticulars = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"resi_particulars"]];;
    _residentID = _residentParticulars[kResidentId];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    status = [reachability currentReachabilityStatus];
    [self processConnectionStatus];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section ==0) {
        return @"Personal Information";
    } else if (section == 1) {
        return @"Screening Profiles";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section==0) {
        return 1;
    }
    else {
        return [_yearlyProfile count];
    }
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
    
    if (indexPath.section == 0) {
        [cell.textLabel setText:@"Resident Particulars"];
    } else {
        NSString *text = [_yearlyProfile objectAtIndex:indexPath.row];
        
        NSString *str = [[_residentDetails objectForKey:kResiParticulars] objectForKey:kResidentId];
        
        BOOL newEntry = str? NO:YES;
        
        if([text containsString:@"2017"] && newEntry) {
            [cell setUserInteractionEnabled:NO];
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
        else if ([text containsString:@"2018"] || [text containsString:@"2019"]) {
            [cell setUserInteractionEnabled:NO];
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
        [cell.textLabel setText:text];
        
        
    }
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {   //resident particulars
//        NSInteger selectedRow = [NSNumber numberWithInteger:indexPath.row];
        
        [self performSegueWithIdentifier:@"showResiPartiSegue" sender:self];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (indexPath.section == 1){   //past profiles
        
        if (indexPath.row > 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            //do nothing
        } else {    //only for 2017 profile
            [self performSegueWithIdentifier:@"LoadScreeningFormSegue" sender:self];
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
        
        self.residentDetails = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        NSLog(@"%@", self.residentDetails); //replace the existing one
        _residentParticulars = self.residentDetails[kResiParticulars];  //update the residentParticulars
        
        [self saveCoreData];
        [SVProgressHUD dismiss];
//        [SVProgressHUD setMaximumDismissTimeInterval:1.0];
//        [SVProgressHUD showSuccessWithStatus:@"Done!"];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Patients data fetch was unsuccessful!");
        fetchDataState = failed;
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

#pragma mark - Save Core Data

- (void) saveCoreData {
    
    NSDictionary *particularsDict =[_residentDetails objectForKey:kResiParticulars];
    
    // Calculate age
    NSMutableString *str = [particularsDict[kBirthDate] mutableCopy];
    NSString *yearOfBirth = [str substringWithRange:NSMakeRange(0, 4)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kGender] forKey:kGender];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:age] forKey:kResidentAge];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kResidentId] forKey:kResidentId];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kName] forKey:kName];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kNRIC] forKey:kNRIC];
    
    
    // For demographics
    if (particularsDict[kCitizenship] != (id) [NSNull null])        //check for null first
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kCitizenship] forKey:kCitizenship];
    if (particularsDict[kReligion] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kReligion] forKey:kReligion];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setResidentParticularsDict:)]) {
        [segue.destinationViewController performSelector:@selector(setResidentParticularsDict:)
                                              withObject:_residentParticulars];
    }
}


@end

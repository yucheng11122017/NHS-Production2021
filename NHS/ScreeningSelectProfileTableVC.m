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
#import "ScreeningDictionary.h"



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
        NSNumber *preRegDone =[_residentDetails[kResiParticulars] objectForKey:kPreregCompleted];
        [cell.textLabel setText:@"📶 Resident Particulars"];

        if ([preRegDone isEqual:@0]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        NSString *text = [_yearlyProfile objectAtIndex:indexPath.row];
        [cell.textLabel setText:text];
        NSNumber *preRegDone =[_residentDetails[kResiParticulars] objectForKey:kPreregCompleted];
        
        if ([text containsString:@"2017"]) {
            if ([preRegDone isEqual:@0]) {
                [cell setUserInteractionEnabled:NO];
                [cell.textLabel setTextColor:[UIColor grayColor]];
            } else {
                [cell setUserInteractionEnabled:YES];
                cell.textLabel.textColor = [UIColor blackColor];
            }
        }
        
        else if ([text containsString:@"2018"] || [text containsString:@"2019"]) {
            [cell setUserInteractionEnabled:NO];
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
        
        
    }
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
        if (_residentID != nil && _residentID != (id) [NSNull null]) {
            //don't do anything
            //            [[ScreeningDictionary sharedInstance] fetchFromServer];
        }

    }
    
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

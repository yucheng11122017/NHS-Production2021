//
//  FollowUpTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 9/27/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "FollowUpTableVC.h"
#import "AppConstants.h"
#import "SVProgressHUD.h"
#import "ServerComm.h"
#import "ReportViewController.h"
#import "Reachability.h"
#import "ScreeningDictionary.h"

#define PDFREPORT_LOADED_NOTIF @"Pdf report downloaded"


@interface FollowUpTableVC () {
    BOOL internetDCed;
}

@property (strong, nonatomic) NSString *reportFilePath;
@property (strong, nonatomic) NSMutableArray *completionCheck;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSNumber *residentID;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;

@end

@implementation FollowUpTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0, @0, @0, nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //remove the extra lines after the last used tableviewcell
    
    self.navigationItem.title = @"Follow Up";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportExist:) name:PDFREPORT_LOADED_NOTIF object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary]; //update dictionary if come from other sections
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
    
    [self updateInterfaceWithReachability:self.hostReachability];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    NSString *text;
    
    if (indexPath.row == 0) {
        text = @"NHS Health Report";
    } else if (indexPath.row == 1) {
        text = @"Health Education";
    } else {
        text = @"Questionnaire";       // recently added
    }
    
    [cell.textLabel setText:text];
    
    if (indexPath.row < [self.completionCheck count]) {
        if ([[self.completionCheck objectAtIndex:indexPath.row] isEqualToNumber:@1]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {   // Get report
        [self downloadReport];
    } else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"FollowUpToHealthEdSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"FollowUpToQuestionnaireSegue" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Report Btn API
- (void) downloadReport {
    _reportFilePath = nil;  //don't keep the previously saved PDF file.
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    [[ServerComm sharedServerCommInstance] retrievePdfReportForResident:[defaults objectForKey:kResidentId]];
}

- (void) reportExist: (NSNotification *) notification {
    NSArray *keys = [notification.userInfo allKeys];
    if ([keys containsObject:@"status"]) {
        [SVProgressHUD setMinimumDismissTimeInterval:1.0];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:@"Report could not be downloaded!"];
        return;
    }
    
    _reportFilePath = [[ServerComm sharedServerCommInstance] getretrievedReportFilepath];
    [self performSegueWithIdentifier:@"FollowUpToReportSegue" sender:self];
}


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
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showErrorWithStatus:@"No Internet!"];
                
                
                break;
            }
            case ReachableViaWiFi:
            case ReachableViaWWAN:
                NSLog(@"Connected to server!");
                
                
                if (internetDCed) { //previously disconnected
                    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                    [SVProgressHUD showSuccessWithStatus:@"Back Online!"];
                    internetDCed = false;
                }
                break;
                
            default:
                break;
        }
    }
    
}

#pragma mark - NSNotification Methods

- (void) reloadTable: (NSNotification *) notification {
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
}


#pragma mark - Cell Accessory Update

- (void) updateCellAccessory {
    if ([_completionCheck count] < 1) {
        _completionCheck = [[NSMutableArray alloc] init];
    } else {
        [_completionCheck removeAllObjects];
    }
    
    NSDictionary *checksDict = [_fullScreeningForm objectForKey:SECTION_CHECKS];
    NSArray *lookupTable = @[@"random stuff",@"health_ed", @"questionnaire"];
    
    if (checksDict != nil && checksDict != (id)[NSNull null]) {
        for (int i=0; i<[lookupTable count]; i++) {
            
            NSString *key = lookupTable[i];
            
            if ([key containsString:@"questionnaire"]) {
                [self.completionCheck addObject:[self checkAllQuestionnaireSections:checksDict]];
            } else {
                [self.completionCheck addObject:@0];    //skip the rest
            }
            
        }
    }
}

- (NSNumber *) checkAllQuestionnaireSections:(NSDictionary *) checksDict {
    int count=0;
    for (NSString *key in [checksDict allKeys]) {   //check through all 3 sub-sections
        if ([key isEqualToString:kCheckPSFUMedIssues] || [key isEqualToString:kCheckPSFUSocialIssues]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
            else
                return @0;
        }
    }
    if (count == 2) return @1;
    else return @0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setReportFilepath:)]) {
        [segue.destinationViewController performSelector:@selector(setReportFilepath:)
                                              withObject:_reportFilePath];
    }
}


@end

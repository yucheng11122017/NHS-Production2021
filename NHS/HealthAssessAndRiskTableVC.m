//
//  HealthAssessAndRiskTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/8/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "HealthAssessAndRiskTableVC.h"
#import "AppConstants.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ServerComm.h"
#import "MedicalHistoryTableVC.h"
#import "HealthAssessAndRiskFormVC.h"
#import "ScreeningDictionary.h"

@interface HealthAssessAndRiskTableVC () {
    NSNumber *destinationFormID;
    NSNumber *age;
    BOOL internetDCed;
}

@property (strong, nonatomic) NSArray *rowLabelsText;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSNumber *residentID;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSMutableArray *completionCheck;

@end

@implementation HealthAssessAndRiskTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    internetDCed = false;
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0, nil];
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];

    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                        stringForKey:kResidentAge];
    
    self.navigationItem.title = @"Health Assessment and Risk Stratisfaction";
    _rowLabelsText= [[NSArray alloc] initWithObjects:@"Medical History",@"Geriatric Depression Assessment",@"Risk Stratification", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary]; //update dictionary if come from other sections
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
    
    [self updateInterfaceWithReachability:self.hostReachability];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    [super viewWillDisappear:animated];
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
    
    if (indexPath.row == 1) {   //Geriatric Depression Assessment
        if ([age intValue] <65) {
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
    }
    
    // Put in the ticks if necessary
    if (indexPath.row < [self.completionCheck count]) {
        if ([[self.completionCheck objectAtIndex:indexPath.row] isEqualToNumber:@1]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        [self performSegueWithIdentifier:@"HARSToMedHistSegue" sender:self];
    else {
        if (indexPath.row == 1) {   //Geriatric Depression Assessment
            if ([age intValue] <65) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return; //do nothing
            }
        }
        
        NSInteger targetRow = indexPath.row + 2;
        destinationFormID = [NSNumber numberWithInteger:targetRow];
        [self performSegueWithIdentifier:@"HARSToFormSegue" sender:self];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
                [SVProgressHUD showErrorWithStatus:@"No Internet!"];
                
                
                break;
            }
            case ReachableViaWiFi:
            case ReachableViaWWAN:
                NSLog(@"Connected to server!");
                
                
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


- (void) updateCellAccessory {
    if ([_completionCheck count] < 1) {
        _completionCheck = [[NSMutableArray alloc] init];
    } else {
        [_completionCheck removeAllObjects];
    }
    
    NSDictionary *checksDict = [_fullScreeningForm objectForKey:SECTION_CHECKS];
    NSArray *lookupTable = @[@"kCheckMedHistory", kCheckDepression, kCheckRiskStrat];
    
    if (checksDict != nil && checksDict != (id)[NSNull null]) {
        for (int i=0; i<[lookupTable count]; i++) {
            
            NSString *key = lookupTable[i];
            
            if ([key containsString:@"MedHistory"]) {
                [self.completionCheck addObject:[self checkAllMedHistorySections:checksDict]];
            } else {
                NSNumber *doneNum = [checksDict objectForKey:key];
                [_completionCheck addObject:doneNum];
            }

        }
    }
}

- (NSNumber *) checkAllMedHistorySections:(NSDictionary *) checksDict {
    int count=0;
    for (NSString *key in [checksDict allKeys]) {   //check through all 3 sub-sections
        if ([key isEqualToString:kCheckDiabetes] || [key isEqualToString:kCheckHyperlipidemia] || [key isEqualToString:kCheckHypertension]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
            else
                return @0;
        }
    }
    if (count == 3) return @1;
    else return @0;
}

#pragma mark - NSNotification Methods

- (void) reloadTable: (NSNotification *) notification {
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    
    // Go straight to HealthRisk FormVC
    if ([segue.destinationViewController respondsToSelector:@selector(setFormID:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setFormID:)
                                              withObject:destinationFormID];
    }
}


@end

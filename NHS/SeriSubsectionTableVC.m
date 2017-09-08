//
//  SeriSubsectionTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/21/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "SeriSubsectionTableVC.h"
#import "SeriFormVC.h"
#import "AppConstants.h"
#import  "Reachability.h"
#import "SVProgressHUD.h"
#import "ScreeningDictionary.h"

@interface SeriSubsectionTableVC () {
    NSNumber *selectedRow;
    NSArray *rowTitleArray;
    BOOL internetDCed;
}
@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *completionCheck;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@end

@implementation SeriSubsectionTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    rowTitleArray = [[NSArray alloc] initWithObjects:@"Medical History", @"Visual Acuity", @"Autorefractor", @"Intra-Ocular Pressure", @"Anterior Health Examination", @"Posterior Health Examination", @"Diagnosis and Follow-up", nil];
    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0,@0,@0,@0, nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DEFAULT_ROW_HEIGHT_FOR_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [rowTitleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    NSString *text = [rowTitleArray objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:text];
    
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
    selectedRow = [NSNumber numberWithInteger:indexPath.row];
    
    [self performSegueWithIdentifier:@"seriSectionToFormSegue" sender:self];
    
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
                
                //                [self getAllDataForOneResident];
                
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
    NSArray *lookupTable = @[kCheckSeriMedHist, kCheckSeriVa, kCheckSeriAutorefractor, kCheckSeriIop, kCheckSeriAhe, kCheckSeriPhe, kCheckSeriDiag];
    
    if (checksDict != nil && checksDict != (id)[NSNull null]) {
        for (int i=0; i<[lookupTable count]; i++) {
            
            NSString *key = lookupTable[i];
            
            NSNumber *doneNum = [checksDict objectForKey:key];
            [_completionCheck addObject:doneNum];
            
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
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setFormNo:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setFormNo:)
                                              withObject:selectedRow];
    }
    
}


@end

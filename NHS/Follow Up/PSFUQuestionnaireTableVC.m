//
//  PSFUQuestionnaireTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 10/19/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "PSFUQuestionnaireTableVC.h"
#import "AppConstants.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ServerComm.h"
#import "ScreeningDictionary.h"
#import "QuestionnaireFormVC.h"


@interface PSFUQuestionnaireTableVC () {
    NSNumber *selectedRow;
    BOOL internetDCed;
}

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSNumber *residentID;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSMutableArray *completionCheck;


@end

@implementation PSFUQuestionnaireTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0, nil];
    
    self.navigationItem.title = @"Questionnaire";
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
    
    [self.tableView reloadData];
    
    
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
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    // Put in the ticks if necessary
    if (indexPath.row < [self.completionCheck count]) {
        if ([[self.completionCheck objectAtIndex:indexPath.row] isEqualToNumber:@1]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    NSString *text;
    
    if (indexPath.row == 0) {
        text = @"Medical Issues";
    } else {
        text = @"Social Issues";
    }
    
    [cell.textLabel setText:text];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DEFAULT_ROW_HEIGHT_FOR_SECTIONS;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedRow = [NSNumber numberWithInteger:indexPath.row+1]; //because @0 will become <nil>
    
    [self performSegueWithIdentifier:@"QuestionnaireToFormVC" sender:self];
    
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


- (void) updateCellAccessory {
    if ([_completionCheck count] < 1) {
        _completionCheck = [[NSMutableArray alloc] init];
    } else {
        [_completionCheck removeAllObjects];
    }
    
    NSDictionary *checksDict = [_fullScreeningForm objectForKey:SECTION_CHECKS];
    NSArray *lookupTable = @[kCheckPSFUMedIssues, kCheckPSFUSocialIssues];
    
    if (checksDict != nil && checksDict != (id)[NSNull null]) {
        for (int i=0; i<[lookupTable count]; i++) {
            
            NSString *key = lookupTable[i];
            
            NSNumber *doneNum = [checksDict objectForKey:key];
            if ([doneNum isKindOfClass:[NSNumber class]]) {
                [_completionCheck addObject:doneNum];   //just in case it's NULL for no reason
            } else {
                [_completionCheck addObject:@0];
            }
            
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

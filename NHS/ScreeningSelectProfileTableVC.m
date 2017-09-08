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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"enableProfileEntry" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
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
        [cell.textLabel setText:@"👤 Resident Particulars"];

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

#pragma mark - NSNotification
- (void) refreshTable: (NSNotification *) notification {
    [SVProgressHUD show];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
}

- (void) reloadTable: (NSNotification *) notification {
    _residentDetails = [[ScreeningDictionary sharedInstance] dictionary];
    _residentParticulars = [_residentDetails objectForKey:@"resi_particulars"];
    [self.tableView reloadData];    //put in the ticks
    [SVProgressHUD dismiss];
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setResidentParticularsDict:)]) {
        [segue.destinationViewController performSelector:@selector(setResidentParticularsDict:)
                                              withObject:_residentParticulars];
    }
}


@end

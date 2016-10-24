//
//  ResidentFollowUpHistoryTableViewController.m
//  NHS
//
//  Created by Nicholas Wong on 9/13/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ResidentFollowUpHistoryTableViewController.h"
#import "SummaryReportViewController.h"
#import "FollowUpFormViewController.h"
#import "SVProgressHUD.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "AppConstants.h"
#import "FollowUpCell.h"

typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;

typedef enum typeOfFollowUp {
    houseVisit,
    phoneCall,
    socialWork
} typeOfFollowUp;

@interface ResidentFollowUpHistoryTableViewController () {
    NSNumber *viewForm;
    NSNumber *newForm;
    NSArray *followUpArray;
    NSMutableDictionary *formToView;
}

@property (strong, nonatomic) NSMutableDictionary* retrievedScreeningData;
@property (strong, nonatomic) NSMutableDictionary* bloodTestResult;
@property (strong, nonatomic) NSArray* arrayOfCallHistory;
@property (strong, nonatomic) NSArray* arrayOfHouseVisitHistory;
@property (strong, nonatomic) NSArray* arrayOfSocialWorkHistory;
@property (nonatomic, strong) NSMutableArray *followUpEntitySections; // 2d array
@property (nonatomic, copy) NSArray *prototypeEntities;

@end

@implementation ResidentFollowUpHistoryTableViewController {
    NSNumber *followUpType;
    NSDictionary *residentParticulars;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    newForm = @0;
//    NSLog(@"Retrieved Blood Test Data: %@", self.bloodTestResult);
    NSLog(@"Retrieved Full Follow Up History: %@", self.completeFollowUpHistory);
    
    [self buildFollowUpDataThen:^{
        self.followUpEntitySections = @[].mutableCopy;
        [self.followUpEntitySections addObject:self.prototypeEntities.mutableCopy];
        [self.tableView reloadData];
    }];
    
     self.clearsSelectionOnViewWillAppear = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshFollowUpHistoryTable:)
                                                 name:@"refreshFollowUpHistoryTable"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createNewFollowUpForm:)
                                                 name:@"selectedScreenedResidentToNewForm"
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.bloodTestResult removeAllObjects];
    self.bloodTestResult = nil;
    [self.retrievedScreeningData removeAllObjects];
    self.retrievedScreeningData = nil;
    self.navigationItem.title = _residentName;
}

- (void) addSummaryReportToSection {
    [self.followUpEntitySections addObject:
     [[FollowUpEntity alloc] initWithDictionary:@{
                                                  @"content": @"",
                                                  @"imageName": @"Report",
                                                  @"date": @"",   //best if can show the timestamp from blood test
                                                  @"title":@"Report Summary",
                                                  @"username": @"Computer generated"
                                                  }]];
}

- (void) buildFollowUpDataThen:(void (^)(void))then {
    // Simulate an async request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.arrayOfCallHistory = [[NSArray alloc] initWithArray:[self.completeFollowUpHistory objectForKey:@"Calls"]];
        self.arrayOfHouseVisitHistory = [[NSArray alloc] initWithArray:[self.completeFollowUpHistory objectForKey:@"houseVisits"]];
        self.arrayOfSocialWorkHistory = [[NSArray alloc] initWithArray:[self.completeFollowUpHistory objectForKey:@"socialWorkFollowUp"]];
        
        followUpArray = [[[self.arrayOfCallHistory arrayByAddingObjectsFromArray:self.arrayOfHouseVisitHistory] arrayByAddingObjectsFromArray:self.arrayOfSocialWorkHistory] mutableCopy];  //merge all the arrays together
        NSArray *historyArray = [self prepareArrayForHistoryTable:followUpArray];
        NSMutableArray *entities = @[].mutableCopy;
        
        for (int i=0; i < [historyArray count]; i++) {
            [entities addObject:[[FollowUpEntity alloc] initWithDictionary:historyArray[i]]];
        }
        self.prototypeEntities = entities;
        
        // Callback
        dispatch_async(dispatch_get_main_queue(), ^{
            !then ?: then();
        });
    });
}

- (NSArray *) prepareArrayForHistoryTable: (NSArray *) combinedArray {
    NSMutableArray *tempArray = @[].mutableCopy;
    for (int i=0; i<[combinedArray count]; i++) {
        if ([combinedArray[i] objectForKey:@"calls_caller"]) {  //phone call
            
            NSString *call_notes = @"";
            if ([combinedArray[i] objectForKey:@"calls_mgmt_plan"]!= (id) [NSNull null]) {
                call_notes = [combinedArray[i] objectForKey:@"calls_mgmt_plan"]? [[combinedArray[i] objectForKey:@"calls_mgmt_plan"] objectForKey:@"notes"]: @"";
            }
            [tempArray addObject:@{
                                   @"content": call_notes,
                                   @"imageName": @"Phone",
                                   @"date": [[combinedArray[i] objectForKey:@"calls_caller"] objectForKey:@"ts"],
                                   @"title":@"Phone Call",
                                   @"username": [[combinedArray[i] objectForKey:@"calls_caller"] objectForKey:@"caller_name"],
                                   @"id":[[combinedArray[i] objectForKey:@"calls_caller"] objectForKey:@"call_id"],
                                   @"index":[NSString stringWithFormat:@"%d", i]
                                   }
            ];
        } else if ([combinedArray[i] objectForKey:@"house_volunteer"]) {    //house visit
            
            NSString *doc_notes = [self getValueFromDictionary:combinedArray[i] withFirstKey:@"house_mgmt_plan" andSecondKey:@"doc_notes"];

            [tempArray addObject:@{
                                   @"content": doc_notes,
                                   @"imageName": @"House",
                                   @"date": [[combinedArray[i] objectForKey:@"house_volunteer"] objectForKey:@"ts"],
                                   @"title":@"House Visit",
                                   @"username": [[combinedArray[i] objectForKey:@"house_volunteer"] objectForKey:@"doc_name"],
                                   @"id":[[combinedArray[i] objectForKey:@"house_volunteer"] objectForKey:@"visit_id"],
                                   @"index":[NSString stringWithFormat:@"%d", i]
                                   }
             ];
        } else if ([combinedArray[i] objectForKey:@"social_wk_followup"]) {    //social work
            NSString *case_status = @"";
            if ([combinedArray[i] objectForKey:@"social_wk_followup"]!= (id) [NSNull null]) {
                case_status = [[combinedArray[i] objectForKey:@"social_wk_followup"] objectForKey:@"case_status_info"];
            }
            [tempArray addObject:@{
                                   @"content": case_status,
                                   @"imageName": @"Social Work",
                                   @"date": [[combinedArray[i] objectForKey:@"social_wk_followup"] objectForKey:@"ts"],
                                   @"title":@"Social Work",
                                   @"username": [[combinedArray[i] objectForKey:@"social_wk_followup"] objectForKey:@"done_by"],
                                   @"id":[[combinedArray[i] objectForKey:@"social_wk_followup"] objectForKey:@"social_wk_followup_id"],
                                   @"index":[NSString stringWithFormat:@"%d", i]
                                   }
             ];
        }
    }
    
    tempArray = [self sortLatestFirst: tempArray];
    return tempArray;
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
    else return ([self.arrayOfHouseVisitHistory count] + [self.arrayOfCallHistory count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FollowUpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowUpCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(FollowUpCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
       cell.entity = [[FollowUpEntity alloc] initWithDictionary:@{
                                                     @"content": @"Computer-generated Report",
                                                     @"imageName": @"Report",
                                                     @"date": @"",   //best if can show the timestamp from blood test
                                                     @"title":@"Report Summary",
                                                     @"username": @"---"
                                                     }];
    } else {
        cell.entity = self.followUpEntitySections[indexPath.section-1][indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    if (indexPath.section == 0) {   //Report Summary
        viewForm = @0;
        newForm = @0;
        [self getAllScreeningData];
        [self getBloodTestResultForOneResident];
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;

    } else {
        viewForm = @1;
        [self getAllScreeningData];
        FollowUpEntity *entity = self.followUpEntitySections[indexPath.section-1][indexPath.row];
        NSLog(@"%@", [followUpArray objectAtIndex:[entity.index intValue]]);
        formToView = [[NSMutableDictionary alloc] initWithDictionary:[followUpArray objectAtIndex:[entity.index intValue]]];
        if ([entity.title isEqualToString:@"Phone Call"]) {
            followUpType = [NSNumber numberWithInt:phoneCall];
        } else if ([entity.title isEqualToString:@"House Visit"]) {
            followUpType = [NSNumber numberWithInt:houseVisit];
        } else {
            followUpType = [NSNumber numberWithInt:socialWork];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}

#pragma mark - Server API

- (void)getAllScreeningData {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getSingleScreeningResidentDataWithResidentID:_residentID
                                           progressBlock:[self progressBlock]
                                            successBlock:[self downloadSingleResidentDataSuccessBlock]
                                            andFailBlock:[self errorBlock]];
}

- (void)getBloodTestResultForOneResident {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getBloodTestWithResidentID:_residentID
                         progressBlock:[self progressBlock]
                          successBlock:[self downloadBloodTestResultSuccessBlock]
                          andFailBlock:[self errorBlock]];
}

- (void)getAllFollowUpDataForOneResident {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getFollowUpDetailsWithResidentID:_residentID
                               progressBlock:[self progressBlock]
                                successBlock:[self downloadFollowUpDataSuccessBlock]
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
        
        self.retrievedScreeningData = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        if ([viewForm isEqualToNumber:@1]) {
            residentParticulars = [self.retrievedScreeningData objectForKey:@"resi_particulars"];
            [self performSegueWithIdentifier:@"ViewFollowUpFormSegue" sender:self];
        } else if ([newForm isEqualToNumber:@1]) {
            residentParticulars = [self.retrievedScreeningData objectForKey:@"resi_particulars"];
            [self performSegueWithIdentifier:@"NewFollowUpFormSegue" sender:self];
        }
        else {    //for view summary
            if ([self.bloodTestResult allKeys] != 0) {  //depending on which one successfully retrieve data from server first
                [self performSegueWithIdentifier:@"LoadReportSummarySegue" sender:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"waitForScreeningSummary"
                                                                    object:nil
                                                                  userInfo:nil];
            }
        }
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadBloodTestResultSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        if (self.bloodTestResult) { //only if bloodtestresult is not nil
            self.bloodTestResult = [[NSMutableDictionary alloc] initWithDictionary:[responseObject objectAtIndex:0]];
            if ([self.retrievedScreeningData allKeys] != 0) {   //depending on which one successfully retrieve data from server first
                [self performSegueWithIdentifier:@"LoadReportSummarySegue" sender:self];
            }
        } else {
            if ([self.retrievedScreeningData allKeys] != 0) {   //depending on which one successfully retrieve data from server first
                [self performSegueWithIdentifier:@"LoadReportSummarySegue" sender:self];
            } else {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(loadReportSummary:)
                                                             name:@"waitForScreeningSummary"
                                                           object:nil];
            }
        }
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject)) downloadFollowUpDataSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        [SVProgressHUD dismiss];
        self.completeFollowUpHistory = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        [self buildFollowUpDataThen:^{
            self.followUpEntitySections = @[].mutableCopy;
            [self.followUpEntitySections addObject:self.prototypeEntities.mutableCopy];
            [self.tableView reloadData];
        }];
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

- (NSMutableArray *) sortLatestFirst: (NSArray *) array {
    
    NSMutableArray *mutArray = [array mutableCopy];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:FALSE];
    [mutArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return mutArray;
}

#pragma mark - NSNotification Methods
- (void)refreshFollowUpHistoryTable:(NSNotification *) notification{
    NSLog(@"refresh follow up history table");

    [self getAllFollowUpDataForOneResident];
}

- (void) createNewFollowUpForm: (NSNotification *) notification {
    viewForm = @0;  //not viewing, but creating new one
    residentParticulars = [notification userInfo];
    [self performSegueWithIdentifier:@"NewFollowUpFormSegue" sender:self];
}

- (void) loadReportSummary: (NSNotification *) notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"waitForScreeningSummary" object:nil];
    [self performSegueWithIdentifier:@"LoadReportSummarySegue" sender:self];
}

#pragma mark - Button methods

- (IBAction)addBtnPressed:(UIBarButtonItem *)sender {
    viewForm = @0;
    newForm = @1;
    if (formToView) {
        [formToView removeAllObjects];
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New follow-up form", nil)
                                                                              message:@"Choose one of the options"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Phone Call", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          followUpType = [NSNumber numberWithInt:phoneCall];
                                                          [self getAllScreeningData];
                                                          
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"House Visit", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          followUpType = [NSNumber numberWithInt:houseVisit];
                                                          [self getAllScreeningData];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Social Work", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          followUpType = [NSNumber numberWithInt:socialWork];
                                                          [self getAllScreeningData];
//                                                          [self performSegueWithIdentifier:@"NewFollowUpFormSegue" sender:self];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        alertController.view.superview.userInteractionEnabled = YES;
        [alertController.view.superview addGestureRecognizer:singleTap];    //tap elsewhere to close the alertView
    }];
    
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods
- (NSString *) getValueFromDictionary: (NSDictionary *) dict withFirstKey: (NSString *) firstKey andSecondKey: (NSString *) secondKey {
    
    if ([dict objectForKey:firstKey] != (id) [NSNull null]) {
        if ([[dict objectForKey:firstKey] objectForKey:secondKey] != (id) [NSNull null]) {
            return [[dict objectForKey:firstKey] objectForKey:secondKey];
            
        }
    }
    return @"";
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
    [SVProgressHUD dismiss];
    
    if ([segue.destinationViewController respondsToSelector:@selector(setResidentParticulars:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setResidentParticulars:)
                                              withObject:residentParticulars];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setTypeOfFollowUp:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setTypeOfFollowUp:)
                                              withObject:followUpType];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setFullScreeningForm:)]) {
        [segue.destinationViewController performSelector:@selector(setFullScreeningForm:)
                                              withObject:self.retrievedScreeningData];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setBloodTestResult:)]) {
        [segue.destinationViewController performSelector:@selector(setBloodTestResult:)
                                              withObject:self.bloodTestResult];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setViewForm:)]) {
        [segue.destinationViewController performSelector:@selector(setViewForm:)
                                              withObject:viewForm];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setDownloadedForm:)]) {
        [segue.destinationViewController performSelector:@selector(setDownloadedForm:)
                                              withObject:formToView];
    }
    
}

@end

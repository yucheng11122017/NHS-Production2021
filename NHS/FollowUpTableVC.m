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

#define PDFREPORT_LOADED_NOTIF @"Pdf report downloaded"


@interface FollowUpTableVC ()

@property (strong, nonatomic) NSString *reportFilePath;

@end

@implementation FollowUpTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //remove the extra lines after the last used tableviewcell
    
    self.navigationItem.title = @"Follow Up";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportExist:) name:PDFREPORT_LOADED_NOTIF object:nil];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setReportFilepath:)]) {
        [segue.destinationViewController performSelector:@selector(setReportFilepath:)
                                              withObject:_reportFilePath];
    }
}


@end

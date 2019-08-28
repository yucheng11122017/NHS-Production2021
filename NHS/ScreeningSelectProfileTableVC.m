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
#import "ResidentProfile.h"

#define PDFREPORT_LOADED_NOTIF @"Pdf report downloaded"
#define CELL_RIGHT_MARGIN_OFFSET 64

typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;

@interface ScreeningSelectProfileTableVC () {
    NetworkStatus status;
    int fetchDataState;
    BOOL enableReportButton;
}


@property (strong, nonatomic) NSArray *yearlyProfile;
@property (strong, nonatomic) NSDictionary *residentParticulars;
@property (strong, nonatomic) NSDictionary *phlebEligibDict;
@property (strong, nonatomic) NSDictionary *modeOfScreeningDict;
@property (strong, nonatomic) NSDictionary *consentScreeningDict;
@property (strong, nonatomic) NSDictionary *consentResearchDict;
@property (strong, nonatomic) NSDictionary *mammogramInterestDict;
@property (strong, nonatomic) NSNumber *residentID;
//@property (strong, nonatomic) NSString *reportFilePath;
//@property (strong, nonatomic) UIButton *reportButton;

@end

@implementation ScreeningSelectProfileTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    enableReportButton = false;
    self.navigationItem.title = @"Integrated Profile";
    _yearlyProfile = [[NSArray alloc] initWithObjects:@"2018",@"2019",@"2020", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    
    _residentParticulars = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"resi_particulars"]];
    
    [self checkConsentFormsSubmission];
    
    if ([_residentDetails objectForKey:@"phlebotomy_eligibility_assmt"] == (id)[NSNull null]) { //present crashes
        _phlebEligibDict = @{};
    } else
        _phlebEligibDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"phlebotomy_eligibility_assmt"]];
    
    if ([_residentDetails objectForKey:@"mode_of_screening"] == (id)[NSNull null]) {    //present crashes
        _modeOfScreeningDict = @{};
    } else
        _modeOfScreeningDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"mode_of_screening"]];
    
    if ([_residentDetails objectForKey:@"consent_disclosure"] == (id)[NSNull null]) {    //present crashes
        _consentScreeningDict = @{};
    } else
        _consentScreeningDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"consent_disclosure"]];
    
    if ([_residentDetails objectForKey:@"consent_research"] == (id)[NSNull null]) {    //present crashes
        _consentResearchDict = @{};
    } else
        _consentResearchDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"consent_research"]];
    
    if ([_residentDetails objectForKey:@"mammogram_interest"] == (id)[NSNull null]) {    //present crashes
        _mammogramInterestDict = @{};
    } else
    _mammogramInterestDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"mammogram_interest"]];
    
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
//        NSNumber *preRegDone =[_residentDetails[kResiParticulars] objectForKey:kPreregCompleted];
        NSNumber *preRegDone = @1;
        NSNumber *serialNum = [[NSUserDefaults standardUserDefaults] objectForKey:kNhsSerialNum];
        
        if ([text containsString:@"2019"]) {
            if ([preRegDone isEqual:@0]) {
                [cell setUserInteractionEnabled:NO];
                [cell.textLabel setTextColor:[UIColor grayColor]];
            } else {
                [cell setUserInteractionEnabled:YES];
                cell.textLabel.textColor = [UIColor blackColor];
            }
            
            if (serialNum != (id) [NSNull null]) {
                if ([serialNum isKindOfClass:[NSNumber class]]) {  //as long as have value

//                    enableReportButton = true;
                    // NO EXTRA BUTTON FOR NOW
//                    if (!_reportButton) {
//                        CGRect cellSize = cell.layer.frame;
//                        float cellWidth = cellSize.size.width;
//
//                        CGRect buttonRect = CGRectMake(cellWidth-CELL_RIGHT_MARGIN_OFFSET, 25, 65, 25);        //to fit for all type of deves
//                        _reportButton = [[UIButton alloc] init];
//                        _reportButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//                        _reportButton.frame = buttonRect;
//                        // set the button title here if it will always be the same
//                        [_reportButton setTitle:@"Report" forState:UIControlStateNormal];
//                        _reportButton.tag = 1;
//                        [_reportButton addTarget:self action:@selector(downloadReport:) forControlEvents:UIControlEventTouchUpInside];
//                        [cell.contentView addSubview:_reportButton];
//                    }
                }
            }
            
        }
        
        else if ([text containsString:@"2018"] || [text containsString:@"2020"]) {
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
        
        if (indexPath.row != 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            //do nothing
        } else {    //only for 2018 profile
            [self showPopUpBox];
        }
    }
}

- (void) checkConsentFormsSubmission {
    NSDictionary *consentDictionary = [_residentDetails objectForKey:@"consents"];
    NSDictionary *researchConsentDictionary = [_residentDetails objectForKey:@"consent_research"];
    if (consentDictionary != (id)[NSNull null] && consentDictionary) {
        [[ResidentProfile sharedManager] setConsentImgExists:YES];
    } else {
        [[ResidentProfile sharedManager] setConsentImgExists:NO];
    }
    
    if (researchConsentDictionary != (id)[NSNull null] && researchConsentDictionary) {
        [[ResidentProfile sharedManager] setResearchConsentImgExists:YES];
    } else {
        [[ResidentProfile sharedManager] setResearchConsentImgExists:NO];
    }
}

- (void) showPopUpBox {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"2019 Screening Profile", nil)
                                                                              message:@""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *consentFormAction, *researchConsentFormAction;
     UIAlertAction *formAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Screening Form", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self performSegueWithIdentifier:@"LoadScreeningFormSegue" sender:self];
                                                      }];
    
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NHS Health Report", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
//                                                       [self downloadReport:nil];
                                                       [self performSegueWithIdentifier:@"ProfileToFollowUpSegue" sender:self];
                                                   }];
    
//    if ([[ResidentProfile sharedManager] hasConsentImage]) {
//        consentFormAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Show Consent Form", nil)
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction * action) {
//                                                       [self performSegueWithIdentifier:@"ProfileToConsentFormSegue" sender:self];
//                                                   }];
//    } else {
//        consentFormAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Submit Consent Form", nil)
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction * action) {
//                                                       [self performSegueWithIdentifier:@"ProfileToConsentFormSegue" sender:self];
//                                                   }];
    
//#warning Just to make testing faster, remove for official App release!
//        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood] containsString:@"Lengkok"]) {
//            formAction.enabled = NO;
//            reportAction.enabled = NO;
//        }
//    }
    
//    if ([[ResidentProfile sharedManager] consentForResearch]) {
//        if ([[ResidentProfile sharedManager] hasResearchConsentImage]) {
//            researchConsentFormAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Show Research Consent Form", nil)
//                                                         style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction * action) {
//                                                           [self performSegueWithIdentifier:@"ProfileToResearchConsentFormSegue" sender:self];
//                                                       }];
//        } else {
//            researchConsentFormAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Submit Research Consent Form", nil)
//                                                         style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction * action) {
//                                                           [self performSegueWithIdentifier:@"ProfileToResearchConsentFormSegue" sender:self];
//                                                       }];
//
//            //In this case, disable only if they consented for research, yet haven't submit the form
//            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood] containsString:@"Lengkok"]) {
//                formAction.enabled = NO;
//                reportAction.enabled = NO;
//            }
//        }
//
//    } else {    //didn't give approval for research
//        researchConsentFormAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Submit Research Consent Form", nil)
//                                                             style:UIAlertActionStyleDefault
//                                                           handler:^(UIAlertAction * action) {
//                                                               [self performSegueWithIdentifier:@"ProfileToResearchConsentFormSegue" sender:self];
//                                                           }];
//        researchConsentFormAction.enabled = NO; //don't need to submit
//    }
    
//    reportAction.enabled = enableReportButton;
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kNeighbourhood] containsString:@"Lengkok"]) {  //for kampong glam, don't need to show the other two buttons
//        [alertController addAction:consentFormAction];
//        [alertController addAction:researchConsentFormAction];
//    }
    [alertController addAction:formAction];
    [alertController addAction:reportAction];
    
    
    
    [self presentViewController:alertController animated:YES completion:^{
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        alertController.view.superview.userInteractionEnabled = YES;
        [alertController.view.superview addGestureRecognizer:singleTap];    //tap elsewhere to close the alertView
    }];
}

                                
-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
//
//#pragma mark - Report Btn API
//- (void) downloadReport: (UIButton *) sender {
//    _reportFilePath = nil;  //don't keep the previously saved PDF file.
//    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    [SVProgressHUD show];
//    [[ServerComm sharedServerCommInstance] retrievePdfReportForResident:[defaults objectForKey:kResidentId]];
//}
//
//- (void) reportExist: (NSNotification *) notification {
//    NSArray *keys = [notification.userInfo allKeys];
//    if ([keys containsObject:@"status"]) {
//        [SVProgressHUD setMinimumDismissTimeInterval:1.0];
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//        [SVProgressHUD showErrorWithStatus:@"Report could not be downloaded!"];
//        return;
//    }
//
//    _reportFilePath = [[ServerComm sharedServerCommInstance] getretrievedReportFilepath];
//    [self performSegueWithIdentifier:@"ProfileToWebViewSegue" sender:self];
//}



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
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
}

- (void) reloadTable: (NSNotification *) notification {

    _residentDetails = [[ScreeningDictionary sharedInstance] dictionary];
    
    if ([_residentDetails objectForKey:@"phlebotomy_eligibility_assmt"] == (id)[NSNull null]) { //present crashes
        _phlebEligibDict = @{};
    } else
    _phlebEligibDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"phlebotomy_eligibility_assmt"]];
    
    if ([_residentDetails objectForKey:@"mode_of_screening"] == (id)[NSNull null]) {    //present crashes
        _modeOfScreeningDict = @{};
    } else
    _modeOfScreeningDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"mode_of_screening"]];
    
    if ([_residentDetails objectForKey:@"consent_disclosure"] == (id)[NSNull null]) {    //present crashes
        _consentScreeningDict = @{};
    } else
    _consentScreeningDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"consent_disclosure"]];
    
    if ([_residentDetails objectForKey:@"consent_research"] == (id)[NSNull null]) {    //present crashes
        _consentResearchDict = @{};
    } else
    _consentResearchDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"consent_research"]];
    
    if ([_residentDetails objectForKey:@"mammogram_interest"] == (id)[NSNull null]) {    //present crashes
        _mammogramInterestDict = @{};
    } else
    _mammogramInterestDict = [[NSDictionary alloc] initWithDictionary:[_residentDetails objectForKey:@"mammogram_interest"]];
    
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
    if ([segue.destinationViewController respondsToSelector:@selector(setPhlebEligibDict:)]) {
        [segue.destinationViewController performSelector:@selector(setPhlebEligibDict:)
                                              withObject:_phlebEligibDict];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setModeOfScreeningDict:)]) {
        [segue.destinationViewController performSelector:@selector(setModeOfScreeningDict:)
                                              withObject:_modeOfScreeningDict];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setConsentDisclosureDict:)]) {
        [segue.destinationViewController performSelector:@selector(setConsentDisclosureDict:)
                                              withObject:_consentScreeningDict];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setConsentResearchDict:)]) {
        [segue.destinationViewController performSelector:@selector(setConsentResearchDict:)
                                              withObject:_consentResearchDict];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setMammogramInterestDict:)]) {
        [segue.destinationViewController performSelector:@selector(setMammogramInterestDict:)
                                              withObject:_mammogramInterestDict];
    }
//    if ([segue.destinationViewController respondsToSelector:@selector(setReportFilepath:)]) {
//        [segue.destinationViewController performSelector:@selector(setReportFilepath:)
//                                              withObject:_reportFilePath];
//    }

    
}


@end

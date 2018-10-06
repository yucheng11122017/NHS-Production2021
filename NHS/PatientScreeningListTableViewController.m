//
//  PatientScreeningListTableViewController.m
//  NHS
//
//  Created by Nicholas on 23/7/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "PatientScreeningListTableViewController.h"
#import "ServerComm.h"
#import "SearchResultsTableController.h"
#import "Reachability.h"
#import "AppConstants.h"
#import "SVProgressHUD.h"
#import "ScreeningSectionTableViewController.h"
#import "GenericTableViewCell.h"
#import "ScreeningSelectProfileTableVC.h"
#import "ScreeningDictionary.h"
#import "ResidentProfile.h"


//disable this if fetch data from server
//#define DISABLE_SERVER_DATA_FETCH         //to use generated fake patient data

typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;

typedef enum Category {
    fullList,
    flaggedList
} residentDataSource;

@interface PatientScreeningListTableViewController ()  <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) SearchResultsTableController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (strong, nonatomic) NSMutableArray *residentNames;
@property (strong, nonatomic) NSMutableArray *residentScreenTimestamp;
@property (strong, nonatomic) NSMutableDictionary *residentsGroupedInSections;
@property (strong, nonatomic) NSMutableDictionary *residentsGroupedInFlag;
@property (strong, nonatomic) NSMutableDictionary *retrievedResidentData;

@property (strong, nonatomic) NSDictionary *sampleResidentDict;
@property (strong, nonatomic) NSString *nricNewEntry;
@property (nonatomic) Reachability *hostReachability;

@property BOOL consentImgExist;

@end



@implementation PatientScreeningListTableViewController {
    NSNumber *selectedResidentID;
    NSNumber *draftID;
    NSArray *residentSectionTitles;
    NSArray *flaggedSectionTitles;
    NSNumber *residentDataLocalOrServer;
    BOOL loadDataFlag;
    NetworkStatus status;
    int fetchDataState;
    BOOL appTesting;
    BOOL internetDCed;
    enum Category currentCategory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    internetDCed = false;
    
    //For hiding credentials from Apple Testers
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    appTesting = [defaults boolForKey:@"AppleTesting"];
    
    [defaults setObject:_neighbourhood forKey:kNeighbourhood];
    
    self.residentNames = [[NSMutableArray alloc] init];
    self.residentScreenTimestamp = [[NSMutableArray alloc] init];
    self.residentsGroupedInSections = [[NSMutableDictionary alloc] init];
    self.residentsGroupedInFlag = [[NSMutableDictionary alloc] init];
    fetchDataState = inactive;
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0 green:146/255.0 blue:255/255.0 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshConnectionAndTable)
                  forControlEvents:UIControlEventValueChanged];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshScreeningResidentTable:)
                                                 name:@"refreshScreeningResidentTable"
                                               object:nil];
    
    _resultsTableController = [[SearchResultsTableController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    self.definesPresentationContext = TRUE;     //SUPER IMPORTANT, if not the searchBar won't go away when didSelectRow
    
    
    #ifdef DISABLE_SERVER_DATA_FETCH
    [self generateFakePatient];
    #endif
    
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Full List of Residents";
    [super viewWillAppear:animated];
    
    [self refreshConnectionAndTable];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshConnectionAndTable {
    status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    [self processConnectionStatus];
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
                
                [self getAllScreeningResidents];
                
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



- (void) processConnectionStatus {
    if(status == NotReachable)
    {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Internet!", nil)
                                                                                  message:@"You're not connected to Internet."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * okAction){
                                                              [self.refreshControl endRefreshing];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (status == ReachableViaWiFi)
    {
        NSLog(@"Wifi");
        #ifndef DISABLE_SERVER_DATA_FETCH
        [self getAllScreeningResidents];
        #endif
    }
    else if (status == ReachableViaWWAN)
    {
        NSLog(@"3G");
        #ifndef DISABLE_SERVER_DATA_FETCH
        [self getAllScreeningResidents];
        #endif
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (fetchDataState == failed) {
            return 0;
    } else {
        if (currentCategory == fullList)
            return [residentSectionTitles count];    //alphabets + locally saved files
        else
            return [flaggedSectionTitles count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (currentCategory == fullList) {
        return [residentSectionTitles objectAtIndex:section];
    } else {
        return [flaggedSectionTitles objectAtIndex:section];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *sectionResident;
    
    if (currentCategory == fullList) {
        NSString *sectionTitle = [residentSectionTitles objectAtIndex:section];
        sectionResident = [self.residentsGroupedInSections objectForKey:sectionTitle];
        return [sectionResident count];
    } else {
        
        
        NSString *sectionTitle = [flaggedSectionTitles objectAtIndex:section];
        sectionResident = [self.residentsGroupedInFlag objectForKey:sectionTitle];
        return [sectionResident count];
    }
}

//Indexing purpose!
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (currentCategory == fullList)
        return residentSectionTitles;
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GenericTableViewCell *cell = (GenericTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GenericTableCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GenericTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSArray *residentsInSection;
    
    if (currentCategory == fullList) {
        NSString *sectionTitle;
        
        sectionTitle = [residentSectionTitles objectAtIndex:indexPath.section];
        residentsInSection = [self.residentsGroupedInSections objectForKey:sectionTitle];
    } else {
        NSString *sectionTitle;
        
        sectionTitle = [flaggedSectionTitles objectAtIndex:indexPath.section];
        residentsInSection = [self.residentsGroupedInFlag objectForKey:sectionTitle];
    }
    
    
    
    NSString *residentName = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:kName];
    NSString *residentNric = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:kNRIC];
//    NSString *lastUpdatedTS = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:kLastUpdateTs];
    NSNumber *preRegCompleted = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:kPreregCompleted];
    NSString *serialId = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:kNhsSerialId];
    
    cell.nameLabel.text = residentName;
    cell.NRICLabel.text = residentNric;
//    cell.dateLabel.text = lastUpdatedTS;
    cell.dateLabel.text = serialId;
    
    
    if ([preRegCompleted isEqual:@1])
        cell.regLabel.hidden = NO;
    else
        cell.regLabel.hidden = YES;
    
    //default hidden
    cell.verticalLine.hidden = YES;
    cell.yearLabel.hidden = YES;
    
    
    if (serialId != (id) [NSNull null]) {
        if ([serialId isKindOfClass:[NSString class]]  && ![serialId isEqualToString:@""]) {  //as long as have value
            cell.verticalLine.hidden = NO;
            cell.yearLabel.hidden = NO;
        }
    }
    
    
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *selectedResident = Nil;
    _consentImgExist = false;

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self resetAllUserDefaults];
    
    if (tableView == self.tableView) {      //not in the searchResult view
        
        selectedResident = [[NSDictionary alloc] initWithDictionary:[self findResidentInfoFromSectionRow:indexPath]];
        selectedResidentID = [selectedResident objectForKey:kResidentId];
        
    } else {
        selectedResident = [[NSDictionary alloc] initWithDictionary:self.resultsTableController.filteredProducts[indexPath.row]];  //drafts not included in search!
        selectedResidentID = [selectedResident objectForKey:kResidentId];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
#ifndef DISABLE_SERVER_DATA_FETCH
    [self getAllDataForOneResident];
#endif
    
#ifdef DISABLE_SERVER_DATA_FETCH
//    [self performSegueWithIdentifier:@"LoadScreeningFormSegue" sender:self];
    [self performSegueWithIdentifier:@"showSelectProfileTableVC" sender:self];

#endif
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    BOOL isComm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isComm"] boolValue];
    
    if (isComm) {
        return YES;
    }
    else
        return NO;  // no deleting for volunteers!
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                                                                  message:@""
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * deleteDraftAction) {
                                                              NSDictionary *residentInfo = [self findResidentInfoFromSectionRow:indexPath];
                                                              [self deleteResident:[residentInfo objectForKey:kResidentId]];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    //  else if (editingStyle == UITableViewCellEditingStyleInsert) {
    //        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //    }
}

- (void)deleteResident: (NSNumber *) residentID {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client deleteResidentWithResidentID: residentID
                           progressBlock:[self progressBlock]
                            successBlock:[self deleteSuccessBlock]
                            andFailBlock:[self errorBlock]];
}

#pragma mark - Patient-sorting Related methods

- (NSDictionary *) findResidentInfoFromSectionRow: (NSIndexPath *)indexPath{
    
    NSInteger section;

    section = indexPath.section;
    
    NSInteger row = indexPath.row;
    if (currentCategory == fullList) {
        NSString *sectionAlphabet = [[NSString alloc] initWithString:[residentSectionTitles objectAtIndex:section]];
        NSArray *residentsWithAlphabet = [self.residentsGroupedInSections objectForKey:sectionAlphabet];
        
        return [residentsWithAlphabet objectAtIndex:row];
    } else {
        NSString *sectionFlag = [[NSString alloc] initWithString:[flaggedSectionTitles objectAtIndex:section]];
        NSArray *residentsUnderFlag = [self.residentsGroupedInFlag objectForKey:sectionFlag];
        
        return [residentsUnderFlag objectAtIndex:row];
    }
    
}

#pragma mark - Navigation Button

- (IBAction)addBtnPressed:(UIBarButtonItem *)sender {
    [self.retrievedResidentData removeAllObjects];  //clear the dictionary

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Registration", nil)
                                                                              message:@""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Key in NRIC of resident";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add new resident", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          NSLog(@"NRIC: %@", [[alertController textFields][0] text]);
                                                          _nricNewEntry = [[alertController textFields][0] text];
                                                          [[ServerComm sharedServerCommInstance] getResidentGivenNRIC:_nricNewEntry withProgressBlock:[self progressBlock] successBlock:[self nricSuccessBlock] andFailBlock:[self errorBlock]];
                                                          
//                                                          selectedResidentID = @(-1);
//                                                          _sampleResidentDict = @{};
//                                                          [self resetAllUserDefaults];
//                                                          [[NSUserDefaults standardUserDefaults] setObject:_neighbourhood forKey:kNeighbourhood];   //only keep neighbourhood
//                                                          [[NSUserDefaults standardUserDefaults] synchronize];
//                                                          [self performSegueWithIdentifier:@"addNewResidentSegue" sender:self];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        alertController.view.superview.userInteractionEnabled = YES;
        [alertController.view.superview addGestureRecognizer:singleTap];    //tap elsewhere to close the alertView
    }];

}
- (IBAction)sortBtnPressed:(id)sender {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Category", nil)
                                                                              message:@""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Full list of residents", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          currentCategory = fullList;
                                                          self.navigationItem.title = @"Full List of Residents";
                                                          [self.tableView reloadData];
                                                          [self.refreshControl endRefreshing];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Flagged residents", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          currentCategory = flaggedList;
                                                          [self flagSorting];
                                                          self.navigationItem.title = @"Flagged Residents";
                                                          [self.tableView reloadData];
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

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.screeningResidents mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "iphone"
        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
        //
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // Below we use NSExpression represent expressions in our predicates.
        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:kName];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:kNRIC];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
//        lhs = [NSExpression expressionForKeyPath:kResidentId];
//        rhs = [NSExpression expressionForConstantValue:searchString];
//        finalPredicate = [NSComparisonPredicate
//                          predicateWithLeftExpression:lhs
//                          rightExpression:rhs
//                          modifier:NSDirectPredicateModifier
//                          type:NSContainsPredicateOperatorType
//                          options:NSCaseInsensitivePredicateOption];
//        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    NSLog(@"%@", searchResults);
    // hand over the filtered results to our search results table
    SearchResultsTableController *tableController = (SearchResultsTableController *)self.searchController.searchResultsController;
    tableController.filteredProducts = searchResults;
    [tableController.tableView reloadData];
}

#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

//NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
//NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
//NSString *const SearchBarTextKey = @"SearchBarTextKey";
//NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];

    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}

#pragma mark - Screening Resident API


- (void)getAllScreeningResidents {
    if (!appTesting) {
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client getAllScreeningResidents:[self progressBlock]       //op_code 1700
                            successBlock:[self successBlock]
                            andFailBlock:[self errorBlock]];
    } else {
        [self.refreshControl endRefreshing];
    }
}
//
//- (void)deleteResident: (NSNumber *) residentID {
//    ServerComm *client = [ServerComm sharedServerCommInstance];
//    [client deleteResidentWithResidentID: residentID
//                           progressBlock:[self progressBlock]
//                            successBlock:[self deleteSuccessBlock]
//                            andFailBlock:[self errorBlock]];
//}

- (void)getAllDataForOneResident {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getSingleScreeningResidentDataWithResidentID:selectedResidentID     //op_code 1702
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

- (void (^)(NSURLSessionDataTask *task, id responseObject))deleteSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        [self getAllScreeningResidents];

        [SVProgressHUD setMaximumDismissTimeInterval:1.0];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showSuccessWithStatus:@"Entry Deleted!"];
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        [self.residentNames removeAllObjects];   //reset this array first
        [self.residentScreenTimestamp removeAllObjects];   //reset this array first
        NSArray *patients = [responseObject objectForKey:@"0"];      //somehow double brackets... (())
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[patients count];i++) {
            if ([[patients[i] objectForKey:kScreenLocation] isEqualToString:_neighbourhood])
                [mutArray addObject:patients[i]];
        }
        
        
        
        self.screeningResidents = [[NSMutableArray alloc] initWithArray:mutArray];  // of a specific neighbourhood, eg. Kampong Glam
        
        [self fullNamelistSort];
        [self putNamesIntoSections];    //for full list of residents (A-Z sections)
        currentCategory = fullList;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject)) nricSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        NSDictionary *retrievedDictionary = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        
        NSLog(@"%@", retrievedDictionary);
        
        NSString *year2017 = [[retrievedDictionary objectForKey:@"2017"] objectForKey:@"year_2017"];
        NSString *year2018 = [[retrievedDictionary objectForKey:@"2018"] objectForKey:@"year_2018"];
        
        if ([year2017 isEqualToString:@"not found"] && [year2018 isEqualToString:@"not found"]) {
            // NEW RESIDENT
            selectedResidentID = @(-1);
            _sampleResidentDict = @{};
            [self resetAllUserDefaults];
            [[NSUserDefaults standardUserDefaults] setObject:_neighbourhood forKey:kNeighbourhood];   //only keep neighbourhood
            [[NSUserDefaults standardUserDefaults] setObject:_nricNewEntry forKey:kNRIC];   //only keep neighbourhood
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSegueWithIdentifier:@"addNewResidentSegue" sender:self];
        } else if ([year2018 isEqualToString:@"found"]) {    // already registered
            NSNumber *resident_id = [[retrievedDictionary objectForKey:@"2018"] objectForKey:kResidentId];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Duplicate record" message:@"Resident has already been registered!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                selectedResidentID = resident_id;
                [self getAllDataForOneResident];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else if ([year2017 isEqualToString:@"found"] && [year2018 isEqualToString:@"not found"]) {
            // RESIDENT REGISTERED in 2017
            selectedResidentID = @(-1);
            _sampleResidentDict = @{};
            [self resetAllUserDefaults];
            [[NSUserDefaults standardUserDefaults] setObject:_neighbourhood forKey:kNeighbourhood];   //only keep neighbourhood
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSMutableDictionary *mutDict = [[retrievedDictionary objectForKey:@"2017"] mutableCopy];
            
            for (NSString *key in [[retrievedDictionary objectForKey:@"2017"] allKeys]) {
                if ([mutDict objectForKey:key] == (id)[NSNull null]) {
                    [mutDict removeObjectForKey:key];
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:mutDict forKey:kOldRecord];   //only keep neighbourhood
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSegueWithIdentifier:@"addNewResidentSegue" sender:self];
        }
        
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSingleResidentDataSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        self.retrievedResidentData = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        [[ScreeningDictionary sharedInstance] setDictionary:self.retrievedResidentData];
        [[ResidentProfile sharedManager] updateProfile:self.retrievedResidentData];
        
        [self saveCoreData];
        [[ScreeningDictionary sharedInstance] prepareAdditionalSvcs];   //prepare all the qualifySections
        
        [self performSegueWithIdentifier:@"showSelectProfileTableVC" sender:self];
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

#pragma mark - Sorting Methods

- (void) putNamesIntoSections {
    NSArray *letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    BOOL found = FALSE;
    
    for(int i=0;i<26;i++) {
        for (int j=0; j<[self.residentNames count]; j++) {
            if([[[self.residentNames objectAtIndex:j] uppercaseString] hasPrefix:[[letters objectAtIndex:i] uppercaseString]]) {
                [temp addObject:[self.screeningResidents objectAtIndex:j]];     // using the same index of the residentNames, add the dictionary to temp
                found = TRUE;
            }
            if(j==([self.residentNames count]-1)) {  //reached the end
                if (found) {
                    [self.residentsGroupedInSections setObject:temp forKey:[letters objectAtIndex:i]];  //add the residents' details into respective alphabets
                    temp = [temp mutableCopy];
                    [temp removeAllObjects];
                }
            }
        }
        found = FALSE;
    }

    residentSectionTitles = [[self.residentsGroupedInSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];     //get the keys in alphabetical order
}

- (void) fullNamelistSort {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kName ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.screeningResidents = [[self.screeningResidents sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];      //sorted patients array
    
    for (int i=0; i<[self.screeningResidents count]; i++) {
        [self.residentNames addObject:[[self.screeningResidents objectAtIndex:i] objectForKey:kName]];
        [self.residentScreenTimestamp addObject:[[self.screeningResidents objectAtIndex:i] objectForKey:kLastUpdateTs]];
    }
    
    //sort alphabetically
    self.residentNames = [[self.residentNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

- (void) flagSorting {
    int i;
    BOOL nhsfuFlag = false, nhsswFlag = false;
    
    [_residentsGroupedInFlag removeAllObjects];
    
    NSMutableArray *nhsfuArray, *nhsswArray, *bothArray;
    nhsfuArray = [[NSMutableArray alloc] init];
    nhsswArray = [[NSMutableArray alloc] init];
    bothArray = [[NSMutableArray alloc] init];
    
    for (i=0; i < self.screeningResidents.count ; i++) {
        NSDictionary *dict = _screeningResidents[i];
        
        if ([dict objectForKey:kNhsfuFlag] && [dict objectForKey:kNhsfuFlag] != (id)[NSNull null]) {
            nhsfuFlag = [[dict objectForKey:kNhsfuFlag] boolValue];
        }
        if ([dict objectForKey:kNhsswFlag] && [dict objectForKey:kNhsswFlag] != (id)[NSNull null]) {
            nhsswFlag = [[dict objectForKey:kNhsswFlag] boolValue];
        }
        
        if (nhsfuFlag && nhsswFlag) {
//            NSLog(@"Both: %@", [[_screeningResidents objectAtIndex:i] objectForKey:@"resident_name"]);
            [bothArray addObject:dict];
            nhsfuFlag = nhsswFlag = 0;      //reset before continuing
            continue;
        }
        
        if (nhsfuFlag) {
//            NSLog(@"NHSFU: %@", [[_screeningResidents objectAtIndex:i] objectForKey:@"resident_name"]);
            [nhsfuArray addObject:dict];
        } else if (nhsswFlag) {
//            NSLog(@"NHSSW: %@", [[_screeningResidents objectAtIndex:i] objectForKey:@"resident_name"]);
            [nhsswArray addObject:dict];
        }
        
        nhsfuFlag = nhsswFlag = 0;      //reset before continuing
    }
    
    if ([nhsfuArray count] > 0 ) {
        [self.residentsGroupedInFlag setObject:nhsfuArray forKey:@"Flagged to NHSFU"];
    }
    if ([nhsswArray count] > 0 ) {
        [self.residentsGroupedInFlag setObject:nhsswArray forKey:@"Flagged to NHSSW"];
    }
    if ([bothArray count] > 0) {
        [self.residentsGroupedInFlag setObject:bothArray forKey:@"Flagged to BOTH"];
    }
    
    flaggedSectionTitles = [self.residentsGroupedInFlag allKeys];
    
    // Make sure that BOTH is the last index
    if ([flaggedSectionTitles containsObject:@"Flagged to BOTH"]) {
        NSUInteger index = [flaggedSectionTitles indexOfObject:@"Flagged to BOTH"];
        if (index != [flaggedSectionTitles count] -1) {
            NSMutableArray *temp = [flaggedSectionTitles mutableCopy];
            [temp exchangeObjectAtIndex:index withObjectAtIndex:([flaggedSectionTitles count] -1)];
            flaggedSectionTitles = temp;
        }
    }
}

#pragma mark - NSNotification Methods

- (void)refreshScreeningResidentTable:(NSNotification *) notification{
    NSLog(@"refresh screening table");
    
    if ([notification.userInfo objectForKey:kResidentId] != nil) {
        selectedResidentID = [notification.userInfo objectForKey:kResidentId];
        [self getAllDataForOneResident];
    }
    else {
#ifndef DISABLE_SERVER_DATA_FETCH
        [self getAllScreeningResidents];
#endif
    }
    
}


#pragma mark - For Dev Testing
- (void) generateFakePatient {
    int i;
    [self.residentNames removeAllObjects];   //reset this array first
    [self.residentScreenTimestamp removeAllObjects];   //reset this array first
    NSArray *patients;
  
    if ([_neighbourhood isEqualToString:@"EC"]) {   //Eunos Crescent
        patients =@[@{kResidentId:@1,
                      @"resident_name":@"NICHOLAS WONG",
                      kNeighbourhood:@"EC",
                      kGender:@"M",
                      kBirthDate:@"1990-06-12",
                      kCitizenship:@"PR",
                      @"ts":@"2017-07-01 14:24:24",
                      @"nric":@"S1231234A"
                      },
                    @{kResidentId:@2,
                      @"resident_name":@"YOGA KUMAR",
                      kNeighbourhood:@"EC",
                      kBirthDate:@"1962-05-05",
                      kGender:@"M",
                      kCitizenship:@"Singaporean",
                      @"ts":@"2017-07-02 12:42:42",
                      @"nric":@"S3214321B"
                      },
                    @{kResidentId:@4,
                      @"resident_name":@"MICHELLE BUCHANAN",
                      kNeighbourhood:@"EC",
                      kGender:@"F",
                      kBirthDate:@"1947-01-01",
                      kCitizenship:@"Foreigner",
                      @"ts":@"2017-07-03 08:41:44",
                      @"nric":@"G1342231K"
                      }];
    } else {
        patients =@[@{kResidentId:@1,
                      @"resident_name":@"MOHAMMAD YUSOF",
                      kNeighbourhood:@"KGL",
                      kGender:@"M",
                      kBirthDate:@"1989-07-13",
                      kCitizenship:@"PR",
                      @"ts":@"2017-07-01 14:24:24",
                      @"nric":@"S1231234A"
                      },
                    @{kResidentId:@2,
                      @"resident_name":@"JOSEPH TAN KOK LEONG",
                      kNeighbourhood:@"KGL",
                      kBirthDate:@"1960-05-05",
                      kGender:@"M",
                      kCitizenship:@"Singaporean",
                      @"ts":@"2017-07-02 12:42:42",
                      @"nric":@"S3214321B"
                      },
                    @{kResidentId:@3,
                      @"resident_name":@"MICHELLE HALLABAMA",
                      kNeighbourhood:@"KGL",
                      kGender:@"F",
                      kBirthDate:@"1940-01-01",
                      kCitizenship:@"Foreigner",
                      @"ts":@"2017-07-03 08:41:44",
                      @"nric":@"G1342231K"
                      },
                    @{kResidentId:@4,
                      @"resident_name":@"WONG AH MEI",
                      kNeighbourhood:@"KGL",
                      kGender:@"F",
                      kBirthDate:@"1955-02-02",
                      kCitizenship:@"Singaporean",
                      @"ts":@"2017-07-03 10:41:44",
                      @"nric":@"S1231234T"
                      }];
    }
    
;
    self.screeningResidents = [[NSMutableArray alloc] initWithArray:patients];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kName ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.screeningResidents = [[self.screeningResidents sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];      //sorted patients array
    
    for (i=0; i<[self.screeningResidents count]; i++) {
        [self.residentNames addObject:[[self.screeningResidents objectAtIndex:i] objectForKey:kName]];
        [self.residentScreenTimestamp addObject:[[self.screeningResidents objectAtIndex:i] objectForKey:kLastUpdateTs]];
    }
    
    //sort alphabetically
    self.residentNames = [[self.residentNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    [self putNamesIntoSections];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - UserDefaults methods

- (void) resetAllUserDefaults {
    BOOL isComm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isComm"] boolValue];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    //don't erase this value
    [[NSUserDefaults standardUserDefaults] setBool:isComm forKey:@"isComm"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

- (void) saveCoreData {

    NSDictionary *particularsDict =[_retrievedResidentData objectForKey:kResiParticulars];
    NSDictionary *profilingDict =[_retrievedResidentData objectForKey:SECTION_PROFILING_SOCIOECON];
        // Calculate age
    NSMutableString *str = [particularsDict[kBirthDate] mutableCopy];
    NSString *yearOfBirth = [str substringWithRange:NSMakeRange(0, 4)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];
    
    
//    [[NSUserDefaults standardUserDefaults] setObject:_sampleResidentDict[kGender] forKey:kGender];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:age] forKey:kResidentAge];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kResidentId] forKey:kResidentId];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kScreenLocation] forKey:kNeighbourhood];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kName] forKey:kName];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kNRIC] forKey:kNRIC];
    [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kGender] forKey:kGender];
    
    if (profilingDict != (id)[NSNull null] && profilingDict[kEmployStat] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:profilingDict[kEmployStat] forKey:kEmployStat];
    if (profilingDict != (id)[NSNull null] && profilingDict[kAvgMthHouseIncome] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:profilingDict[kAvgMthHouseIncome] forKey:kAvgMthHouseIncome];
    
    // For demographics
    if (particularsDict[kCitizenship] != (id) [NSNull null])        //check for null first
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kCitizenship] forKey:kCitizenship];
    if (particularsDict[kReligion] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kReligion] forKey:kReligion];
    
    // For Report Availability
    if (particularsDict[kNhsSerialNum] != (id) [NSNull null])
        [[NSUserDefaults standardUserDefaults] setObject:particularsDict[kNhsSerialNum] forKey:kNhsSerialNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [SVProgressHUD dismiss];
//    if ([segue.destinationViewController respondsToSelector:@selector(setResidentID:)]) {    //view submitted form
//        [segue.destinationViewController performSelector:@selector(setResidentID:)
//                                              withObject:selectedResidentID];
//    }
    
    if ([self.retrievedResidentData count]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setResidentDetails:)]) {
            [segue.destinationViewController performSelector:@selector(setResidentDetails:)
                                                  withObject:self.retrievedResidentData];
        }
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setResidentLocalFileIndex:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setResidentLocalFileIndex:)
                                              withObject:draftID];
    }
#ifdef DISABLE_SERVER_DATA_FETCH
    if ([segue.destinationViewController respondsToSelector:@selector(setResidentDetails:)]) {
        [segue.destinationViewController performSelector:@selector(setResidentDetails:)
                                              withObject:_sampleResidentDict];
    }
#endif
}


@end

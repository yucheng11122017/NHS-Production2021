//
//  FollowUpSelectScreeningResidentViewController.m
//  NHS
//
//  Created by Nicholas Wong on 9/18/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "FollowUpSelectScreeningResidentTableViewController.h"
#import "ServerComm.h"
#import "SearchResultsTableController.h"
#import "Reachability.h"
#import "AppConstants.h"

typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;


@interface FollowUpSelectScreeningResidentTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) SearchResultsTableController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (strong, nonatomic) NSMutableArray *residentNames;
@property (strong, nonatomic) NSMutableArray *residentScreenTimestamp;
@property (strong, nonatomic) NSMutableDictionary *patientsGroupedInSections;
@property (strong, nonatomic) NSArray *localSavedFilename;
@property NSMutableArray *screeningResidents;

@end

@implementation FollowUpSelectScreeningResidentTableViewController {
    NSNumber *selectedResidentID;
    NSString *selectedResidentNRIC;
    NSArray *patientSectionTitles;
    NSNumber *patientDataLocalOrServer;
    BOOL loadDataFlag;
    NetworkStatus status;
    int fetchDataState;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fetchDataState = inactive;
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0 green:146/255.0 blue:255/255.0 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshConnectionAndTable)
                  forControlEvents:UIControlEventValueChanged];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    status = [reachability currentReachabilityStatus];
    [self processConnectionStatus];
    
    self.residentNames = [[NSMutableArray alloc] init];
    self.residentScreenTimestamp = [[NSMutableArray alloc] init];
    self.patientsGroupedInSections = [[NSMutableDictionary alloc] init];
    self.localSavedFilename = [[NSArray alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable:)
                                                 name:@"refreshScreenedResidentTable"
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exitViewController:)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Screened Resident List";
    
    [super viewWillAppear:animated];
    //    [self getAllPatients];
    fetchDataState = started;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //REMINDER: navigationController.navigationBar.backItem only is initiated after viewDidAppear!
    //    self.navigationController.navigationBar.backItem.title = @"Home";
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    self.navigationItem.title = @"Back";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) exitViewController:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) refreshConnectionAndTable {
    status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    [self processConnectionStatus];
    
    
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
        [self getAllPatients];
    }
    else if (status == ReachableViaWWAN)
    {
        NSLog(@"3G");
        [self getAllPatients];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (fetchDataState == failed) {
        return 0;
    } else {
        return [patientSectionTitles count];    //alphabets
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [patientSectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle;
    NSArray *sectionPatient;
    
    sectionTitle = [patientSectionTitles objectAtIndex:section];
    sectionPatient = [self.patientsGroupedInSections objectForKey:sectionTitle];
    return [sectionPatient count];
    
}

//Indexing purpose!
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return patientSectionTitles;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    // Configure the cell...
    NSString *sectionTitle;
    
    
    sectionTitle = [patientSectionTitles objectAtIndex:indexPath.section];
    
    NSArray *patientsInSection = [self.patientsGroupedInSections objectForKey:sectionTitle];
    NSString *patientName = [[patientsInSection objectAtIndex:indexPath.row] objectForKey:@"resident_name"];
    NSString *lastUpdatedTS = [[patientsInSection objectAtIndex:indexPath.row] objectForKey:@"last_updated_ts"];
    cell.textLabel.text = patientName;
    cell.detailTextLabel.text = lastUpdatedTS;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    NSString *selectedPatientName;
    NSDictionary *selectedResident;
    
    if (tableView == self.tableView) {      //not in the searchResult view
        selectedResident = [self findPatientNameFromSectionRow:indexPath];
        selectedResidentID = [selectedResident objectForKey:@"resident_id"];
        selectedResidentNRIC = [selectedResident objectForKey:@"nric"];
        
    } else {
        selectedResident = self.resultsTableController.filteredProducts[indexPath.row];  //drafts not included in search!
        selectedResidentID = [selectedResident objectForKey:@"resident_id"];
        selectedResidentNRIC = [selectedResident objectForKey:@"nric"];
    }
    //    NSDictionary *userInfo = @{@"resident_id":selectedPatientID};
//    NSDictionary *userInfo = @{@"resident_id":selectedResidentID,
//                               @"nric":selectedResidentNRIC};
    NSDictionary *userInfo = selectedResident;  //selectedResident is the ResiPart of the Screening Form
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedScreenedResidentToNewForm"
                                                        object:self
                                                      userInfo:userInfo];
    [self dismissViewControllerAnimated:YES completion:^(void) {    //dismiss searchBar
        [self dismissViewControllerAnimated:NO completion:nil];    //dismiss Modal VC
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {  //part of the search
        return 60;
    }
    return 44;
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

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        //        NSLog(@"Patients GET Request Started. In Progress.");
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        int i;
        [self.residentNames removeAllObjects];   //reset this array first
        [self.residentScreenTimestamp removeAllObjects];   //reset this array first
        NSArray *patients = [responseObject objectForKey:@"0"];      //somehow double brackets... (())
        self.screeningResidents = [[NSMutableArray alloc] initWithArray:patients];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"resident_name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.screeningResidents = [[self.screeningResidents sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];      //sorted patients array
        
        for (i=0; i<[self.screeningResidents count]; i++) {
            [self.residentNames addObject:[[self.screeningResidents objectAtIndex:i] objectForKey:@"resident_name"]];
            [self.residentScreenTimestamp addObject:[[self.screeningResidents objectAtIndex:i] objectForKey:@"ts"]];
        }
        
        //sort alphabetically
        self.residentNames = [[self.residentNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        
        [self putNamesIntoSections];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Patients data fetch was unsuccessful!");
        fetchDataState = failed;
        [self.tableView reloadData];
    };
}


#pragma mark - Patient API

- (void)getAllPatients {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getAllScreeningResidents:[self progressBlock]
                        successBlock:[self successBlock]
                        andFailBlock:[self errorBlock]];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
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
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"resident_name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"nric"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    // hand over the filtered results to our search results table
    SearchResultsTableController *tableController = (SearchResultsTableController *)self.searchController.searchResultsController;
    tableController.filteredProducts = searchResults;
    [tableController.tableView reloadData];
}

#pragma  mark - Patient sorting-related methods

- (void)refreshTable:(NSNotification *) notification{
    NSLog(@"refresh");
    [self getAllPatients];
}

- (void) putNamesIntoSections {
    NSArray *letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    BOOL found = FALSE;
    
    for(int i=0;i<26;i++) {
        for (int j=0; j<[self.residentNames count]; j++) {
            if([[[self.residentNames objectAtIndex:j] uppercaseString] hasPrefix:[[letters objectAtIndex:i] uppercaseString]]) {
                [temp addObject:[self.screeningResidents objectAtIndex:j]];
                found = TRUE;
            }
            if(j==([self.screeningResidents count]-1)) {  //reached the end
                if (found) {
                    [self.patientsGroupedInSections setObject:temp forKey:[letters objectAtIndex:i]];
                    temp = [temp mutableCopy];
                    [temp removeAllObjects];
                }
            }
        }
        found = FALSE;
    }
    //    NSLog(@"%@", self.patientsGroupedInSections);
    patientSectionTitles = [[self.patientsGroupedInSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];     //get the keys in alphabetical order
}

- (NSDictionary *) findPatientNameFromSectionRow: (NSIndexPath *)indexPath{
    
    NSInteger section;
    
    section = indexPath.section;
    
    NSInteger row = indexPath.row;
    
    NSString *sectionAlphabet = [[NSString alloc] initWithString:[patientSectionTitles objectAtIndex:section]];
    NSArray *patientsWithAlphabet = [self.patientsGroupedInSections objectForKey:sectionAlphabet];
    
    return [patientsWithAlphabet objectAtIndex:row];
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end

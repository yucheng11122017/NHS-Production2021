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

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

//disable this if fetch data from server
#define DISABLE_SERVER_DATA_FETCH

typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;

typedef enum residentDataSource {
    server,
    local
} residentDataSource;

@interface PatientScreeningListTableViewController ()  <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong,nonatomic) UIBarButtonItem *addButton;

@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) SearchResultsTableController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (strong, nonatomic) NSMutableArray *residentNames;
@property (strong, nonatomic) NSMutableArray *residentScreenTimestamp;
@property (strong, nonatomic) NSMutableDictionary *residentsGroupedInSections;
@property (strong, nonatomic) NSMutableDictionary *retrievedResidentData;
@property (strong, nonatomic) NSArray *localSavedFilename;

@property (strong, nonatomic) NSDictionary *sampleResidentDict;


@end



@implementation PatientScreeningListTableViewController {
    NSNumber *selectedResidentID;
    NSNumber *draftID;
    NSArray *residentSectionTitles;
    NSNumber *residentDataLocalOrServer;
    BOOL loadDataFlag;
    NetworkStatus status;
    int fetchDataState;
    BOOL appTesting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //For hiding credentials from Apple Testers
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    appTesting = [defaults boolForKey:@"AppleTesting"];
    
    self.residentNames = [[NSMutableArray alloc] init];
    self.residentScreenTimestamp = [[NSMutableArray alloc] init];
    self.residentsGroupedInSections = [[NSMutableDictionary alloc] init];
    self.localSavedFilename = [[NSArray alloc] init];
    fetchDataState = inactive;
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0 green:146/255.0 blue:255/255.0 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshConnectionAndTable)
                  forControlEvents:UIControlEventValueChanged];
    
    [self getLocalSavedData];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    status = [reachability currentReachabilityStatus];
    [self processConnectionStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshScreeningResidentTable:)
                                                 name:@"refreshScreeningResidentTable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedPreRegResidentToNewScreenForm:)
                                                 name:@"selectedPreRegResidentToNewScreenForm"
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
    
    
//    self.navigationItem.rightBarButtonItem = self.addButton;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"List of Screened Residents";
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if ([self.localSavedFilename count] > 0) {
            return 1;
        }
        else {
            return 0;
        }
    } else {
        if ([self.localSavedFilename count] > 0) {
            return ([residentSectionTitles count]+1);
        } else {
            return [residentSectionTitles count];    //alphabets + locally saved files
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.localSavedFilename count] > 0) {
        if (section == 0) {
            return @"Drafts";
        } else {
            NSInteger newSection = section-1;

            return [residentSectionTitles objectAtIndex:(newSection)];    //because first section is for drafts.
        }
        
    } else {
        return [residentSectionTitles objectAtIndex:section];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle;
    NSArray *sectionResident;
    
    if ([self.localSavedFilename count] > 0) {
        if(section == 0) {
            return [self.localSavedFilename count];
        } else {
            // Return the number of rows in the section.
            sectionTitle = [residentSectionTitles objectAtIndex:(section-1)];    //first section reserved for drafts.
            sectionResident = [self.residentsGroupedInSections objectForKey:sectionTitle];
            return [sectionResident count];
        }
    } else {    //no draft files
        sectionTitle = [residentSectionTitles objectAtIndex:section];
        sectionResident = [self.residentsGroupedInSections objectForKey:sectionTitle];
        return [sectionResident count];
    }
}

//Indexing purpose!
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return residentSectionTitles;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GenericTableViewCell *cell = (GenericTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GenericTableCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GenericTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    NSString *sectionTitle;
    
    if ([self.localSavedFilename count] > 0) { //if there are local saved data...
        if (indexPath.section == 0) {   //section for Drafts
            NSRange range = [[self.localSavedFilename objectAtIndex:indexPath.row] rangeOfString:@"_"];
            NSString *displayText = [[self.localSavedFilename objectAtIndex:indexPath.row] substringToIndex:(range.location)];
            cell.nameLabel.text = @"Draft";
            cell.NRICLabel.text = displayText;
            cell.dateLabel.text = [[self.localSavedFilename objectAtIndex:indexPath.row]substringFromIndex:(range.location+1)];
//            cell.detailTextLabel.text = [[self.localSavedFilename objectAtIndex:indexPath.row]substringFromIndex:(range.location+1)];
            return cell;
        } else {
            sectionTitle = [residentSectionTitles objectAtIndex:(indexPath.section-1)];  //update sectionlist
        }
    } else {
        sectionTitle = [residentSectionTitles objectAtIndex:indexPath.section];
    }
    NSArray *residentsInSection = [self.residentsGroupedInSections objectForKey:sectionTitle];
    NSString *residentName = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:@"resident_name"];
    NSString *residentNric = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:@"nric"];
    NSString *lastUpdatedTS = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:@"ts"];
    
    cell.nameLabel.text = residentName;
    cell.NRICLabel.text = residentNric;
    cell.dateLabel.text = lastUpdatedTS;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *selectedResident = Nil;

    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
    
    if (tableView == self.tableView) {      //not in the searchResult view
        //check if user clicked on drafts first
        if ([self.localSavedFilename count] > 0) {
            if (indexPath.section == 0) {   //part of the drafts...
                selectedResidentID = [NSNumber numberWithInteger:indexPath.row];
                //            residentDataLocalOrServer = [NSNumber numberWithInt:local];
                //            loadDataFlag = YES;
                draftID = [NSNumber numberWithInteger:indexPath.row];
                selectedResidentID = @(-2); //indicate load from file
                [self performSegueWithIdentifier:@"LoadScreeningFormSegue" sender:self];
                
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                return;
            }
        }
        
        
        
        //not part of draft
        _sampleResidentDict = [[NSDictionary alloc] initWithDictionary:[self findResidentInfoFromSectionRow:indexPath]];
        selectedResidentID = [selectedResident objectForKey:@"resident_id"];
        
        [self saveAgeGenderAndCitizenship];
        
    } else {
        selectedResident = [[NSDictionary alloc] initWithDictionary:self.resultsTableController.filteredProducts[indexPath.row]];  //drafts not included in search!
        selectedResidentID = [selectedResident objectForKey:@"resident_id"];
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
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableVmacproiew commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.localSavedFilename count] > 0) {
            if (indexPath.section == 0) {   //meaning, drafts
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Screening"];
                
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self.localSavedFilename objectAtIndex:indexPath.row]]];
                [fileManager removeItemAtPath:filePath error:NULL];
                UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Delete" message:@"Local Draft deleted!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [removeSuccessFulAlert show];
                [self getLocalSavedData];   //no need to reload online content
                [self.tableView reloadData];
                return;
            }
        }
        
        // Delete the row from the data source
        NSDictionary *residentInfo = [self findResidentInfoFromSectionRow:indexPath];
        [self deleteResident:[residentInfo objectForKey:@"resident_id"]];
        //        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade]; //no need this for now...
        
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
    if ([self.localSavedFilename count] > 0) {
        section = indexPath.section - 1;
    } else {
        section = indexPath.section;
    }
    NSInteger row = indexPath.row;
    
    NSString *sectionAlphabet = [[NSString alloc] initWithString:[residentSectionTitles objectAtIndex:section]];
    NSArray *residentsWithAlphabet = [self.residentsGroupedInSections objectForKey:sectionAlphabet];
    
    return [residentsWithAlphabet objectAtIndex:row];
    
}



- (IBAction)addBtnPressed:(UIBarButtonItem *)sender {
    [self.retrievedResidentData removeAllObjects];  //clear the dictionary
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New screening form", nil)
                                                                              message:@"Choose one of the options"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"New resident", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          selectedResidentID = @(-1);
                                                          [self performSegueWithIdentifier:@"NewScreeningFormSegue" sender:self];
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

- (void)getLocalSavedData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Screening"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    self.localSavedFilename = [fileManager contentsOfDirectoryAtPath:folderPath
                                                               error:nil];
}

- (void)getAllScreeningResidents {
    if (!appTesting) {
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client getAllScreeningResidents:[self progressBlock]
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
    [client getSingleScreeningResidentDataWithResidentID:selectedResidentID
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

        [SVProgressHUD showSuccessWithStatus:@"Entry Deleted!"];
        
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

- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSingleResidentDataSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        
        self.retrievedResidentData = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        NSLog(@"%@", self.retrievedResidentData);
        [self performSegueWithIdentifier:@"LoadScreeningFormSegue" sender:self];
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
            if(j==([self.residentNames count]-1)) {  //reached the end
                if (found) {
                    [self.residentsGroupedInSections setObject:temp forKey:[letters objectAtIndex:i]];
                    temp = [temp mutableCopy];
                    [temp removeAllObjects];
                }
            }
        }
        found = FALSE;
    }
    //    NSLog(@"%@", self.patientsGroupedInSections);
    residentSectionTitles = [[self.residentsGroupedInSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];     //get the keys in alphabetical order
}


#pragma mark - NSNotification Methods

- (void)refreshScreeningResidentTable:(NSNotification *) notification{
    NSLog(@"refresh screening table");
    
    [self getLocalSavedData];
#ifndef DISABLE_SERVER_DATA_FETCH
    [self getAllScreeningResidents];
#endif
}

- (void) selectedPreRegResidentToNewScreenForm: (NSNotification *) notification {
    selectedResidentID = [notification.userInfo objectForKey:@"resident_id"];
    [self performSegueWithIdentifier:@"NewScreeningFormSegue" sender:self];
}


#pragma mark - For Dev Testing
- (void) generateFakePatient {
    int i;
    [self.residentNames removeAllObjects];   //reset this array first
    [self.residentScreenTimestamp removeAllObjects];   //reset this array first
    NSArray *patients = @[@{@"resident_id":@1,
                            @"resident_name":@"NICHOLAS WONG",
                            kGender:@"M",
                            kBirthDate:@"1990-06-12",
                            kCitizenship:@"PR",
                            @"ts":@"2017-07-01 14:24:24",
                            @"nric":@"S1231234A"
                            },
                          @{@"resident_id":@2,
                            @"resident_name":@"YOGA KUMAR",
                            kBirthDate:@"1962-05-05",
                            kGender:@"M",
                            kCitizenship:@"Singaporean",
                            @"ts":@"2017-07-02 12:42:42",
                            @"nric":@"S3214321B"
                            },
                          @{@"resident_id":@3,
                            @"resident_name":@"FOREIGNER MICHELLE",
                            kGender:@"F",
                            kBirthDate:@"1947-01-01",
                            kCitizenship:@"Foreigner",
                            @"ts":@"2017-07-03 08:41:44",
                            @"nric":@"G1342231K"
                            }];
;
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
}

- (void) saveAgeGenderAndCitizenship {
    NSMutableString *str = [_sampleResidentDict[kBirthDate] mutableCopy];
    NSString *yearOfBirth = [str substringWithRange:NSMakeRange(0, 4)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    
    NSString *thisYear = [dateFormatter stringFromDate:[NSDate date]];
    
    NSInteger age = [thisYear integerValue] - [yearOfBirth integerValue];

    [[NSUserDefaults standardUserDefaults] setObject:_sampleResidentDict[kCitizenship] forKey:@"ResidentCitizenship"];
    [[NSUserDefaults standardUserDefaults] setObject:_sampleResidentDict[kGender] forKey:@"ResidentGender"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:age] forKey:@"ResidentAge"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [SVProgressHUD dismiss];
    if ([segue.destinationViewController respondsToSelector:@selector(setResidentID:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setResidentID:)
                                              withObject:selectedResidentID];
    }
    
    if ([self.retrievedResidentData count]) {
        [segue.destinationViewController performSelector:@selector(setRetrievedData:)
                                              withObject:self.retrievedResidentData];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setResidentLocalFileIndex:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setResidentLocalFileIndex:)
                                              withObject:draftID];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setResidentDetails:)]) {
        [segue.destinationViewController performSelector:@selector(setResidentDetails:)
                                              withObject:_sampleResidentDict];
    }
}


@end

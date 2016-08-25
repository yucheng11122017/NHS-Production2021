//
//  PatientPreRegTableViewController.m
//  NHS
//
//  Created by Nicholas on 7/25/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "PatientPreRegTableViewController.h"
#import "PreRegPatientDetailsViewController.h"
#import "ServerComm.h"
#import "PreRegFormViewController.h"
#import "SearchResultsTableController.h"
#import "Reachability.h"
#import "AppConstants.h"
#import "MBProgressHUD.h"


#define ERROR_INFO @"com.alamofire.serialization.response.error.data"


typedef enum getDataState {
    inactive,
    started,
    failed,
    successful
} getDataState;



@interface PatientPreRegTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) SearchResultsTableController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (strong, nonatomic) NSMutableArray *residentNames;
@property (strong, nonatomic) NSMutableArray *residentRegTimestamp;
@property (strong, nonatomic) NSMutableDictionary *residentsGroupedInSections;
@property (strong, nonatomic) NSArray *localSavedFilename;
@property (strong, nonatomic) NSDictionary *retrievedResidentDictionary;

@end

@implementation PatientPreRegTableViewController {
    NSNumber *selectedResidentID;
    NSArray *residentSectionTitles;
    NSNumber *residentDataLocalOrServer;
    BOOL loadDataFlag;
    NetworkStatus status;
    MBProgressHUD *hud;
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
    self.residentRegTimestamp = [[NSMutableArray alloc] init];
    self.residentsGroupedInSections = [[NSMutableDictionary alloc] init];
    self.localSavedFilename = [[NSArray alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable:)
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Pre-Registration";
    
    [super viewWillAppear:animated];
//    [self getAllPatients];
    fetchDataState = started;
    [self getLocalSavedData];
    
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
    self.navigationItem.title = @"Back";
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
        [self getAllResidents];
    }
    else if (status == ReachableViaWWAN)
    {
        NSLog(@"3G");
        [self getAllResidents];
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
            if (newSection == 16) {
                NSLog(@"16");
            }
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
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    // Configure the cell...
    NSString *sectionTitle;
    
    if ([self.localSavedFilename count] > 0) { //if there are local saved data...
        if (indexPath.section == 0) {   //section for Drafts
            NSRange range = [[self.localSavedFilename objectAtIndex:indexPath.row] rangeOfString:@"_"];
            NSString *displayText = [[self.localSavedFilename objectAtIndex:indexPath.row] substringToIndex:(range.location)];
            cell.textLabel.text = displayText;
            cell.detailTextLabel.text = [[self.localSavedFilename objectAtIndex:indexPath.row]substringFromIndex:(range.location+1)];
            return cell;
        } else {
            sectionTitle = [residentSectionTitles objectAtIndex:(indexPath.section-1)];  //update sectionlist
        }
    } else {
        sectionTitle = [residentSectionTitles objectAtIndex:indexPath.section];
    }
    NSArray *residentsInSection = [self.residentsGroupedInSections objectForKey:sectionTitle];
    NSString *residentName = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:@"resident_name"];
    NSString *lastUpdatedTS = [[residentsInSection objectAtIndex:indexPath.row] objectForKey:@"last_updated_ts"];
    cell.textLabel.text = residentName;
    cell.detailTextLabel.text = lastUpdatedTS;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectedResidentName;
    NSDictionary *selectedResident = [[NSDictionary alloc] init];
    if ([self.localSavedFilename count] > 0) {
        if (indexPath.section == 0) {   //part of the drafts...
            selectedResidentID = [NSNumber numberWithInteger:indexPath.row];
            residentDataLocalOrServer = [NSNumber numberWithInt:local];
            loadDataFlag = YES;
            
            [self performSegueWithIdentifier:@"preRegPatientListToPatientFormSegue" sender:self];
            NSLog(@"Continue Form segue performed!");
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
        }
    }
    else {  //no saved draft
        if (tableView == self.tableView) {      //not in the searchResult view
            selectedResident = [self findResidentInfoFromSectionRow:indexPath];
            selectedResidentName = [selectedResident objectForKey:@"resident_name"];
            selectedResidentID = [selectedResident objectForKey:@"resident_id"];
            
        } else {
            selectedResident = self.resultsTableController.filteredProducts[indexPath.row];  //drafts not included in search!
            selectedResidentID = [selectedResident objectForKey:@"resident_id"];
        }
        //Show Progress Indicator
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];
        
        
        [self getAllDataForOneResident];
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    

}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSDictionary *residentInfo = [self findResidentInfoFromSectionRow:indexPath];
        [self deleteResident:[residentInfo objectForKey:@"resident_id"]];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade]; //no need this for now...

    }
//  else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}


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
#pragma mark - Buttons

- (IBAction)addBtnPressed:(id)sender {
    [self.refreshControl endRefreshing];    //stop refreshing
    loadDataFlag = NO;
    [self performSegueWithIdentifier:@"preRegPatientListToPatientFormSegue" sender:self];
    NSLog(@"Form segue performed!");
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"progress started...");
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))deleteSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        [self getAllResidents];
        
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Set the custom view mode to show any view.
        hud.mode = MBProgressHUDModeCustomView;
        // Set an image view with a checkmark.
        UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // Looks a bit nicer if we make it square.
        hud.square = YES;
        // Optional label text.
        hud.label.text = NSLocalizedString(@"Done", @"HUD done title");
        
        
        [hud hideAnimated:YES afterDelay:1.f];
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        int i;
        [self.residentNames removeAllObjects];   //reset this array first
        [self.residentRegTimestamp removeAllObjects];   //reset this array first
        NSArray *patients = [responseObject objectForKey:@"0"];      //somehow double brackets... (())
        self.residents = [[NSMutableArray alloc] initWithArray:patients];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"resident_name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.residents = [[self.residents sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];      //sorted patients array
        
        for (i=0; i<[self.residents count]; i++) {
            NSLog(@"%d", i);
            [self.residentNames addObject:[[self.residents objectAtIndex:i] objectForKey:@"resident_name"]];
            [self.residentRegTimestamp addObject:[[self.residents objectAtIndex:i] objectForKey:@"last_updated_ts"]];
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

#pragma mark Downloading Blocks


- (void (^)(NSURLSessionDataTask *task, id responseObject))downloadSuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        self.retrievedResidentDictionary = [responseObject objectForKey:@"0"];
        NSLog(@"%@", self.retrievedResidentDictionary);
        [self performSegueWithIdentifier:@"preRegPatientListToPatientDataSegue" sender:self];
    };
}


- (void (^)(NSURLSessionDataTask *task, NSError *error))downloadErrorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"******UNSUCCESSFUL DOWNLOAD******!!");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSString *errorString =[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSLog(@"error: %@", errorString);
        [hud hideAnimated:YES];     //stop showing the progressindicator
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



#pragma mark - Patient API

- (void)getLocalSavedData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    self.localSavedFilename = [fileManager contentsOfDirectoryAtPath:documentsDirectory
                                                      error:nil];
}

- (void)getAllResidents {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getPatient:[self progressBlock]
          successBlock:[self successBlock]
          andFailBlock:[self errorBlock]];
}

#pragma mark - Downloading Patient Details
- (void)getAllDataForOneResident {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getPatientDataWithPatientID:selectedResidentID
                          progressBlock:[self progressBlock]
                           successBlock:[self downloadSuccessBlock]
                           andFailBlock:[self downloadErrorBlock]];
}

- (void)deleteResident: (NSNumber *) residentID {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client deleteResidentWithResidentID: residentID
          progressBlock:[self progressBlock]
          successBlock:[self deleteSuccessBlock]
          andFailBlock:[self errorBlock]];
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
    NSMutableArray *searchResults = [self.residents mutableCopy];
    
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

//#pragma mark - Util methods

//- (NSMutableArray *)createPatients:(NSArray *)patients {
//    NSMutableArray *patObjs = [[NSMutableArray alloc] init];
//    for (id patient in patients) {
//        [patObjs addObject:[self createPatient:patient]];
//    }
//    return patObjs;
//}

//- (NSArray *) createPatient: (NSDictionary *) patient {
//    NSNumber *birth_year = [patient objectForKey:@"birth_year"];
//    NSString *gender = [patient objectForKey:@"gender"];
//    NSString *nric = [patient objectForKey:@"nric"];
//    NSNumber *resident_id = [patient objectForKey:@"resident_id"];
//    NSString *resident_name = [patient objectForKey:@"resident_name"];
//
//    return @""; //keep it this way first..
//}
//
//- (Patient *)createPatient:(NSDictionary *)patient {
//    NSString *name = [patient objectForKey:@"name"];
//    NSInteger ID = [[patient objectForKey:@"id"] integerValue];
//    NSString *homeType = [patient objectForKey:@"home"];
//    NSInteger age = [[patient objectForKey:@"age"] integerValue];
//    NSInteger height = [[patient objectForKey:@"height"] integerValue];
//    NSInteger level = [[patient objectForKey:@"level"] integerValue];
//    BOOL hasCaretaker;
//    if ([patient objectForKey:@"available"] != [NSNull null]) {
//        hasCaretaker = [[patient objectForKey:@"available"] boolValue];
//    } else {
//        hasCaretaker = NO;
//    }
//    
//    return [[Patient alloc] initWithName:name
//                                     age:(int)age
//                                      ID:ID
//                                  height:(int)height
//                                   level:(int)level
//                                homeType:hfomeType
//                            hasCaretaker:hasCaretaker];
//}

#pragma  mark - Patient sorting-related methods

- (void)refreshTable:(NSNotification *) notification{
    NSLog(@"refresh");
    [self getAllResidents];
}

- (void) putNamesIntoSections {
    NSArray *letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    BOOL found = FALSE;
    
    for(int i=0;i<26;i++) {
        for (int j=0; j<[self.residentNames count]; j++) {
            if([[[self.residentNames objectAtIndex:j] uppercaseString] hasPrefix:[[letters objectAtIndex:i] uppercaseString]]) {
                [temp addObject:[self.residents objectAtIndex:j]];
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
    
    [hud hideAnimated:YES];
    if ([segue.identifier isEqualToString:@"preRegPatientListToPatientDataSegue"]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setResidentDictionary:)
                                              withObject:self.retrievedResidentDictionary];
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setPatientDataLocalOrServer:)]) { //continue form
        [segue.destinationViewController performSelector:@selector(setPatientDataLocalOrServer:)
                                              withObject:residentDataLocalOrServer];
        [segue.destinationViewController performSelector:@selector(setLoadDataFlag:) withObject:[NSNumber numberWithBool:loadDataFlag]];
    }
    
}

@end

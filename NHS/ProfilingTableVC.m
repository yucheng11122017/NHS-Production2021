//
//  ProfilingTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 9/27/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "ProfilingTableVC.h"
#import "AppConstants.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ServerComm.h"
#import "MedicalHistoryTableVC.h"
#import "ProfilingFormVC.h"
#import "ScreeningDictionary.h"
#import "KAStatusBar.h"

#define COMMENTS_TEXTVIEW_HEIGHT 100

@interface ProfilingTableVC () {
    NSNumber *destinationFormID;
    NSNumber *age;
    BOOL internetDCed;
}

@property (strong, nonatomic) NSArray *rowLabelsText;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSNumber *residentID;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSMutableArray *completionCheck;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) UITextView *commentTextView;

@end

@implementation ProfilingTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    internetDCed = false;
    _pushPopTaskArray = [[NSMutableArray alloc]  init];
    _residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId]; //need this for fetching data
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0, nil];
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                        stringForKey:kResidentAge];
    
    self.navigationItem.title = @"Profiling";
    _rowLabelsText= [[NSArray alloc] initWithObjects:@"Eligibility Assessments",@"Medical History",@"Risk Stratification", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setCancelsTouchesInView:NO]; //IMPT! Otherwise TableView didSelectRow will be overwritten
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary]; //update dictionary if come from other sections
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
    
    [self updateInterfaceWithReachability:self.hostReachability];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard {
    [_commentTextView resignFirstResponder];    //hide keyboard
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    // fixed font style. use custom view (UILabel) if you want something different
    if (section == 0) {
        return @"Sub-sections";
    }
    else {
        return @"Comments";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [_rowLabelsText count];    //one more for commments
    else return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return DEFAULT_ROW_HEIGHT_FOR_SECTIONS;
    else return COMMENTS_TEXTVIEW_HEIGHT;    //for textView
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    if (indexPath.section == 0) {
        
        NSString *text = [_rowLabelsText objectAtIndex:indexPath.row];
        
        [cell.textLabel setText:text];
        
        // Put in the ticks if necessary
        if (indexPath.row < [self.completionCheck count]) {
            if ([[self.completionCheck objectAtIndex:indexPath.row] isEqualToNumber:@1]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else {
        _commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, COMMENTS_TEXTVIEW_HEIGHT)];
        _commentTextView.editable = YES;
        _commentTextView.font = [self getDefaultFont];
        _commentTextView.userInteractionEnabled = YES;
        cell.userInteractionEnabled = YES;
        _commentTextView.delegate = self;
        
        NSDictionary *profilingComments = _fullScreeningForm[SECTION_PROFILING_COMMENTS];
        
        //value
        if (profilingComments != (id)[NSNull null] && [profilingComments objectForKey:kProfilingComments] != (id)[NSNull null]) {
            _commentTextView.text = profilingComments[kProfilingComments];
        }
        
        [cell.contentView addSubview:_commentTextView];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {   //Eligibility Assessments
            [self performSegueWithIdentifier:@"ProfilingToFormSegue" sender:self];
            destinationFormID = [NSNumber numberWithInteger:0];
        }
        else if (indexPath.row == 1)
            [self performSegueWithIdentifier:@"ProfilingToMedHistSegue" sender:self];
        else if (indexPath.row == 2) {
            NSInteger targetRow = indexPath.row + 2;
            destinationFormID = [NSNumber numberWithInteger:targetRow];
            [self performSegueWithIdentifier:@"ProfilingToFormSegue" sender:self];
        }
    } else {
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TextViewDelegates
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // this method is called every time you touch in the textView, provided it's editable;
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:textView.superview.superview];
    // i know that looks a bit obscure, but calling superview the first time finds the contentView of your cell;
    //  calling it the second time returns the cell it's held in, which we can retrieve an index path from;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];   //in our case it's fixed
    // this is the edited part;
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    // this programmatically selects the cell you've called behind the textView;
    
    
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    // this selects the cell under the textView;
    return YES;  // specifies you don't want to edit the textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self postSingleFieldWithSection:SECTION_PROFILING_COMMENTS andFieldName:kProfilingComments andNewContent:textView.text];
}

#pragma mark - UIFont methods
- (UIFont *) getDefaultFont {
    return [UIFont systemFontOfSize:16];
}

#pragma mark - Post data to server methods

- (void) postSingleFieldWithSection:(NSString *) section andFieldName: (NSString *) fieldName andNewContent: (NSString *) content {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    if ((content != (id)[NSNull null]) && (content != nil)) {   //make sure don't insert nil or null value to a dictionary
        
        NSDictionary *dict = @{kResidentId:resident_id,
                               kSectionName:section,
                               kFieldName:fieldName,
                               kNewContent:content
                               };
        
        NSLog(@"Uploading %@ for $%@$ field", content, fieldName);
        [KAStatusBar showWithStatus:@"Syncing..." andBarColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:0 alpha:1.0]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [_pushPopTaskArray addObject:dict];
        
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postDataGivenSectionAndFieldName:dict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
    }
}


#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        
        [_pushPopTaskArray removeObjectAtIndex:0];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
        
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"<<< SUBMISSION FAILED >>>");
        
        NSDictionary *retryDict = [_pushPopTaskArray firstObject];
        
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSLog(@"error: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
        
        
        NSLog(@"\n\nRETRYING...");
        
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postDataGivenSectionAndFieldName:retryDict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
        
        
    };
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

#pragma mark - NSNotification Methods

- (void) reloadTable: (NSNotification *) notification {
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
}


#pragma mark - Cell Accessory Update
- (void) updateCellAccessory {
    if ([_completionCheck count] < 1) {
        _completionCheck = [[NSMutableArray alloc] init];
    } else {
        [_completionCheck removeAllObjects];
    }
    
    NSDictionary *checksDict = [_fullScreeningForm objectForKey:SECTION_CHECKS];
    NSArray *lookupTable = @[kCheckProfiling,@"kCheckMedHistory", kCheckRiskStrat];
    
    if (checksDict != nil && checksDict != (id)[NSNull null]) {
        for (int i=0; i<[lookupTable count]; i++) {
            
            NSString *key = lookupTable[i];
            
            if ([key containsString:@"MedHistory"]) {
                [self.completionCheck addObject:[self checkAllMedHistorySections:checksDict]];
            } else {
                NSNumber *doneNum = [checksDict objectForKey:key];
                [_completionCheck addObject:doneNum];
            }
            
        }
    }
}

- (NSNumber *) checkAllMedHistorySections:(NSDictionary *) checksDict {
    int count=0;
    for (NSString *key in [checksDict allKeys]) {   //check through all 3 sub-sections
        if ([key isEqualToString:kCheckDiabetes] || [key isEqualToString:kCheckHyperlipidemia] || [key isEqualToString:kCheckHypertension]) {
            if ([[checksDict objectForKey:key] isEqual:@1])
                count++;
            else
                return @0;
        }
    }
    if (count == 3) return @1;
    else return @0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Go straight to HealthRisk FormVC
    if ([segue.destinationViewController respondsToSelector:@selector(setFormID:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setFormID:)
                                              withObject:destinationFormID];
    }
}


@end


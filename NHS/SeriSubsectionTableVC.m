//
//  SeriSubsectionTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/21/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "SeriSubsectionTableVC.h"
#import "SeriFormVC.h"
#import "AppConstants.h"
#import  "Reachability.h"
#import "SVProgressHUD.h"
#import "ScreeningDictionary.h"
#import "SegmentedCell.h"
#import "KAStatusBar.h"
#import "ServerComm.h"

@interface SeriSubsectionTableVC () {
    NSNumber *selectedRow;
    NSArray *rowTitleArray;
    BOOL internetDCed;
}
@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *completionCheck;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSString *undergoneSeri;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@end

@implementation SeriSubsectionTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    rowTitleArray = [[NSArray alloc] initWithObjects:@"Medical History", @"Visual Acuity", @"Autorefractor", @"Intra-Ocular Pressure", @"Anterior Health Examination", @"Posterior Health Examination", @"Diagnosis and Follow-up", nil];
    _completionCheck = [[NSMutableArray alloc] initWithObjects:@0,@0,@0,@0,@0,@0,@0, nil];
    
    self.navigationItem.title = @"SERI Advanced Eye Screening";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:NOTIFICATION_RELOAD_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    //must add here, otherwise App will crash
    [self addObserver:self forKeyPath:@"undergoneSeri" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self removeObserver:self forKeyPath:@"undergoneSeri"];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    // fixed font style. use custom view (UILabel) if you want something different
//    if (section == 0) {
//        return @"Optional check";
//    }
//    else {
        return @"Sub-sections";
//    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0)
//        return 44;
//    else if (indexPath.section==1)
        return DEFAULT_ROW_HEIGHT_FOR_SECTIONS;
//    else
//        return DEFAULT_ROW_HEIGHT_FOR_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 1;
//    } else {
        return [rowTitleArray count];
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.section == 0) {
//        SegmentedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentedCell"];
//        if (cell == nil) {
//            // Load the top-level objects from the custom cell XIB.
//            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SegmentedCell" owner:self options:nil];
//            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
//            cell = (SegmentedCell *) [topLevelObjects objectAtIndex:0];
//        }
//
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;    //not selectable, but still responding to touches.
//
//        NSDictionary *medHistoryDict = [self.fullScreeningForm objectForKey:SECTION_SERI_MED_HIST];
//        //value
//        if (medHistoryDict != (id)[NSNull null] && [medHistoryDict objectForKey:kUndergoneAdvSeri] != (id)[NSNull null]) {
////            NSLog(@"Value from server: %@", medHistoryDict[kUndergoneAdvSeri]);
//            if ([medHistoryDict[kUndergoneAdvSeri] isEqual:@1]) cell.segmentCtrl.selectedSegmentIndex = 0;  //reversed position
//            else cell.segmentCtrl.selectedSegmentIndex = 1;
//
//        }
//
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yesNoSegmentCtrlChanged:) name:@"SegmentedCtrlChange" object:nil];
//
//        return cell;
//
//    } else {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    NSString *text = [rowTitleArray objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:text];
    
    
    // Put in the ticks if necessary
    if (indexPath.row < [self.completionCheck count]) {
        if ([[self.completionCheck objectAtIndex:indexPath.row] isEqualToNumber:@1]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
//    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0) {
//
//    } else {    //sub-sections
    selectedRow = [NSNumber numberWithInteger:indexPath.row];
    [self performSegueWithIdentifier:@"seriSectionToFormSegue" sender:self];
//    }
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
                
                //                [self getAllDataForOneResident];
                
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
    NSArray *lookupTable = @[kCheckSeriMedHist, kCheckSeriVa, kCheckSeriAutorefractor, kCheckSeriIop, kCheckSeriAhe, kCheckSeriPhe, kCheckSeriDiag];
    
    if (checksDict != nil && checksDict != (id)[NSNull null]) {
        for (int i=0; i<[lookupTable count]; i++) {
            
            NSString *key = lookupTable[i];
            
            NSNumber *doneNum = [checksDict objectForKey:key];
            [_completionCheck addObject:doneNum];
            
        }
    }
}

#pragma mark - UIFont methods
- (UIFont *) getDefaultFont {
    UIFont *font = [UIFont fontWithName:DEFAULT_FONT_NAME size:DEFAULT_FONT_SIZE];
    UIFont *boldedFont = [self boldFontWithFont:font];
    return boldedFont;
}

- (UIFont *)boldFontWithFont:(UIFont *)font
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}


#pragma mark - NSNotification Methods

- (void) reloadTable: (NSNotification *) notification {
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    @synchronized (self) {
        [self updateCellAccessory];
        [self.tableView reloadData];    //put in the ticks
    }
}

- (void) yesNoSegmentCtrlChanged: (NSNotification *) notification {
    BOOL value = [[notification.userInfo objectForKey:@"value"] boolValue];
    
    self.undergoneSeri = [NSString stringWithFormat:@"%d", value];   //remember must use the setter! otherwise it will not trigger the KVO
    NSLog(@"%@", _undergoneSeri);
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"undergoneSeri"]) {
        [self postSingleFieldWithSection:SECTION_SERI_MED_HIST andFieldName:kUndergoneAdvSeri andNewContent:[change objectForKey:@"new"]];
    }
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setFormNo:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setFormNo:)
                                              withObject:selectedRow];
    }
    
}


@end

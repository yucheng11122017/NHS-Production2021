//
//  HearingFormVC.m
//  NHS
//
//  Created by rehabpal on 6/9/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import "HearingFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "KAStatusBar.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"
#import "ScreeningDictionary.h"


#define GREEN_COLOR [UIColor colorWithRed:48.0/255.0 green:207.0/255.0 blue:1.0/255.0 alpha:1.0]

typedef enum formName {
    Hearing,
    FollowUp,
} formName;


@interface HearingFormVC () {
    BOOL internetDCed;
    BOOL isFormFinalized;
    XLFormRowDescriptor *referrerSignButtonRow, *recommendationRow;
    UIColor *signColor;
}

@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;
@property (strong, nonatomic) NSMutableArray *phqQuestionsArray;


@end

@implementation HearingFormVC

- (void)viewDidLoad {
    
    isFormFinalized = false;    //by default
    XLFormViewController *form;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    
    //must init first before [super viewDidLoad]
    int formNumber = [_formNo intValue];
    
    
    switch (formNumber) {
            //case 0 is for demographics
            
        case Hearing:
            form = [self initHearing];
            break;
        case FollowUp:
            form = [self initFollowUp];
            break;
        default:
            break;
    }
    [self.form setAddAsteriskToRequiredRowsTitle:YES];
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    if (isFormFinalized) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        [self.form setDisabled:YES];
        [self.tableView endEditing:YES];    //to really disable the table
        [self.tableView reloadData];
    }
    else {
        [self.form setDisabled:NO];
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finalize" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeBtnPressed:)];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSignatureButtonColors];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [KAStatusBar dismiss];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id) initHearing {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"7. Hearing"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *hearingDict = [_fullScreeningForm objectForKey:SECTION_HEARING];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckHearing];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Hearing Aid"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUsesAidRight rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does the resident use hearing aid for right ear?"];
    row.required = YES;
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kUsesAidRight] != (id)[NSNull null])
        row.value = [self getYesNofromOneZero:hearingDict[kUsesAidRight]];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUsesAidLeft rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does the resident use hearing aid for left ear?"];
    row.required = YES;
    row.selectorOptions = @[@"Yes", @"No"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kUsesAidLeft] != (id)[NSNull null])
        row.value = [self getYesNofromOneZero:hearingDict[kUsesAidLeft]];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"HHIE"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *attendedHhieRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAttendedHhie rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Attended HHIE?"];
    attendedHhieRow.required = YES;
    attendedHhieRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:attendedHhieRow];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAttendedHhie] != (id)[NSNull null])
        attendedHhieRow.value = [self getYesNofromOneZero:hearingDict[kAttendedHhie]];
    
    [section addFormRow:attendedHhieRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHhieResult rowType:XLFormRowDescriptorTypeInteger title:@"HHIE Result:"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedHhieRow];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kHhieResult] != (id)[NSNull null])
        row.value = hearingDict[kHhieResult];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Tinnitus"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *attendedTinnitusRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAttendedTinnitus rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Has Tinnitus? (continuous ringing, hissing or other sounds in ears or head)"];
    attendedTinnitusRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    attendedTinnitusRow.required = YES;
    attendedTinnitusRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:attendedTinnitusRow];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAttendedTinnitus] != (id)[NSNull null])
        attendedTinnitusRow.value = [self getYesNofromOneZero:hearingDict[kAttendedTinnitus]];
    
    [section addFormRow:attendedTinnitusRow];
    
    XLFormRowDescriptor *tinnitusResultQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"tinnitus_q"
                                                                                    rowType:XLFormRowDescriptorTypeInfo
                                                                                      title:@"How much of a problem is the tinnitus?"];
    tinnitusResultQRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    tinnitusResultQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedTinnitusRow];
    [self setDefaultFontWithRow:tinnitusResultQRow];
    [section addFormRow:tinnitusResultQRow];
    
    
    XLFormRowDescriptor *tinnitusResultRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTinnitusResult
                                                                                   rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                                                     title:@""];
    tinnitusResultRow.noValueDisplayText = @"Tap here";
    tinnitusResultRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedTinnitusRow];
    tinnitusResultRow.required = YES;
    tinnitusResultRow.selectorOptions = @[@"No problem", @"Small problem", @"Big problem", @"Very big problem"];
    
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kTinnitusResult] != (id)[NSNull null])
        tinnitusResultRow.value = hearingDict[kTinnitusResult];
    
    [section addFormRow:tinnitusResultRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Otoscopy"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOtoscopyLeft
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@"Otoscopy Examination (Left ear)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.required = YES;
    row.noValueDisplayText = @"Tap here";
    row.selectorOptions = @[@"NA", @"Pass", @"Needs referral"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kOtoscopyLeft] != (id)[NSNull null])
        row.value = hearingDict[kOtoscopyLeft];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOtoscopyRight
                                                rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                  title:@"Otoscopy Examination (Right ear)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.required = YES;
    row.noValueDisplayText = @"Tap here";
    row.selectorOptions = @[@"NA", @"Pass", @"Needs referral"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kOtoscopyRight] != (id)[NSNull null])
        row.value = hearingDict[kOtoscopyRight];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Audioscope"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *attendedAudioscopeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kAttendedAudioscope rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Attended Audioscope?"];
    attendedAudioscopeRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    attendedAudioscopeRow.required = YES;
    attendedAudioscopeRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:attendedAudioscopeRow];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAttendedAudioscope] != (id)[NSNull null])
        attendedAudioscopeRow.value = [self getYesNofromOneZero:hearingDict[kAttendedAudioscope]];
    
    [section addFormRow:attendedAudioscopeRow];
    
    
    XLFormRowDescriptor *row500hz60 = [XLFormRowDescriptor formRowDescriptorWithTag:kPractice500Hz60 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Practice Tone (500Hz at 60dB in “better ear”)"];
    row500hz60.cellConfig[@"textLabel.numberOfLines"] = @0;
    row500hz60.required = YES;
    row500hz60.selectorOptions = @[@"Pass", @"Fail"];
    row500hz60.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row500hz60];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kPractice500Hz60] != (id)[NSNull null])
        row500hz60.value = [self getPassFailfromOneZero:hearingDict[kPractice500Hz60]];
    
    [section addFormRow:row500hz60];
    
    XLFormRowDescriptor *row500hz25L = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioL500Hz25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (L) 500Hz at 25 dBHL Results"];
    row500hz25L.cellConfig[@"textLabel.numberOfLines"] = @0;
    row500hz25L.required = YES;
    row500hz25L.selectorOptions = @[@"Pass", @"Fail"];
    row500hz25L.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row500hz25L];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioL500Hz25] != (id)[NSNull null])
        row500hz25L.value = [self getPassFailfromOneZero:hearingDict[kAudioL500Hz25]];
    
    [section addFormRow:row500hz25L];
    
    XLFormRowDescriptor *row500hz25R = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioR500Hz25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (R) 500Hz at 25 dBHL Results"];
    row500hz25R.cellConfig[@"textLabel.numberOfLines"] = @0;
    row500hz25R.required = YES;
    row500hz25R.selectorOptions = @[@"Pass", @"Fail"];
    row500hz25R.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row500hz25R];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioR500Hz25] != (id)[NSNull null])
        row500hz25R.value = [self getPassFailfromOneZero:hearingDict[kAudioR500Hz25]];
    
    [section addFormRow:row500hz25R];
    
    XLFormRowDescriptor *row1000hz25L = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioL1000Hz25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (L) 1000Hz at 25 dBHL Results"];
    row1000hz25L.cellConfig[@"textLabel.numberOfLines"] = @0;
    row1000hz25L.required = YES;
    row1000hz25L.selectorOptions = @[@"Pass", @"Fail"];
    row1000hz25L.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row1000hz25L];
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioL1000Hz25] != (id)[NSNull null])
        row1000hz25L.value = [self getPassFailfromOneZero:hearingDict[kAudioL1000Hz25]];
    [section addFormRow:row1000hz25L];
    
    XLFormRowDescriptor *row1000hz25R = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioR1000Hz25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (R) 1000Hz at 25 dBHL Results"];
    row1000hz25R.cellConfig[@"textLabel.numberOfLines"] = @0;
    row1000hz25R.required = YES;
    row1000hz25R.selectorOptions = @[@"Pass", @"Fail"];
    row1000hz25R.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row1000hz25R];
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioR1000Hz25] != (id)[NSNull null])
        row1000hz25R.value = [self getPassFailfromOneZero:hearingDict[kAudioR1000Hz25]];
    
    [section addFormRow:row1000hz25R];
    
    XLFormRowDescriptor *row2000hz25L = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioL2000Hz25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (L) 2000Hz at 25 dBHL Results"];
    row2000hz25L.cellConfig[@"textLabel.numberOfLines"] = @0;
    row2000hz25L.required = YES;
    row2000hz25L.selectorOptions = @[@"Pass", @"Fail"];
    row2000hz25L.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row2000hz25L];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioL2000Hz25] != (id)[NSNull null])
        row2000hz25L.value = [self getPassFailfromOneZero:hearingDict[kAudioL2000Hz25]];
    [section addFormRow:row2000hz25L];
    
    XLFormRowDescriptor *row2000hz25R = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioR2000Hz25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (R) 2000Hz at 25 dBHL Results"];
    row2000hz25R.cellConfig[@"textLabel.numberOfLines"] = @0;
    row2000hz25R.required = YES;
    row2000hz25R.selectorOptions = @[@"Pass", @"Fail"];
    row2000hz25R.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row2000hz25R];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioR2000Hz25] != (id)[NSNull null])
        row2000hz25R.value = [self getPassFailfromOneZero:hearingDict[kAudioR2000Hz25]];
    
    [section addFormRow:row2000hz25R];
    
    XLFormRowDescriptor *row4000hz25L = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioL4000Hz25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (L) 4000Hz at 25 dBHL Results"];
    row4000hz25L.cellConfig[@"textLabel.numberOfLines"] = @0;
    row4000hz25L.required = YES;
    row4000hz25L.selectorOptions = @[@"Pass", @"Fail"];
    row4000hz25L.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row4000hz25L];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioL4000Hz25] != (id)[NSNull null])
        row4000hz25L.value = [self getPassFailfromOneZero:hearingDict[kAudioL4000Hz25]];
    [section addFormRow:row4000hz25L];
    
    XLFormRowDescriptor *row4000hz25R = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioR4000Hz25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (R) 4000Hz at 25 dBHL Results"];
    row4000hz25R.cellConfig[@"textLabel.numberOfLines"] = @0;
    row4000hz25R.required = YES;
    row4000hz25R.selectorOptions = @[@"Pass", @"Fail"];
    row4000hz25R.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row4000hz25R];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioR4000Hz25] != (id)[NSNull null])
        row4000hz25R.value = [self getPassFailfromOneZero:hearingDict[kAudioR4000Hz25]];
    
    [section addFormRow:row4000hz25R];
    
    XLFormRowDescriptor *row500hz40L = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioL500Hz40 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (L) 500Hz at 40 dBHL Results"];
    row500hz40L.cellConfig[@"textLabel.numberOfLines"] = @0;
    row500hz40L.required = YES;
    row500hz40L.selectorOptions = @[@"Pass", @"Fail"];
    row500hz40L.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row500hz40L];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioL500Hz40] != (id)[NSNull null])
        row500hz40L.value = [self getPassFailfromOneZero:hearingDict[kAudioL500Hz40]];
    
    [section addFormRow:row500hz40L];
    
    XLFormRowDescriptor *row500hz40R = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioR500Hz40 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (R) 500Hz at 40 dBHL Results"];
    row500hz40R.cellConfig[@"textLabel.numberOfLines"] = @0;
    row500hz40R.required = YES;
    row500hz40R.selectorOptions = @[@"Pass", @"Fail"];
    row500hz40R.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row500hz40R];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioR500Hz40] != (id)[NSNull null])
        row500hz40R.value = [self getPassFailfromOneZero:hearingDict[kAudioR500Hz40]];
    
    [section addFormRow:row500hz40R];
    
    XLFormRowDescriptor *row1000hz40L = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioL1000Hz40 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (L) 1000Hz at 40 dBHL Results"];
    row1000hz40L.cellConfig[@"textLabel.numberOfLines"] = @0;
    row1000hz40L.required = YES;
    row1000hz40L.selectorOptions = @[@"Pass", @"Fail"];
    row1000hz40L.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row1000hz40L];
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioL1000Hz40] != (id)[NSNull null])
        row1000hz40L.value = [self getPassFailfromOneZero:hearingDict[kAudioL1000Hz40]];
    [section addFormRow:row1000hz40L];
    
    XLFormRowDescriptor *row1000hz40R = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioR1000Hz40 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (R) 1000Hz at 40 dBHL Results"];
    row1000hz40R.cellConfig[@"textLabel.numberOfLines"] = @0;
    row1000hz40R.required = YES;
    row1000hz40R.selectorOptions = @[@"Pass", @"Fail"];
    row1000hz40R.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row1000hz40R];
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioR1000Hz40] != (id)[NSNull null])
        row1000hz40R.value = [self getPassFailfromOneZero:hearingDict[kAudioR1000Hz40]];
    
    [section addFormRow:row1000hz40R];
    
    XLFormRowDescriptor *row2000hz40L = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioL2000Hz40 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (L) 2000Hz at 40 dBHL Results"];
    row2000hz40L.cellConfig[@"textLabel.numberOfLines"] = @0;
    row2000hz40L.required = YES;
    row2000hz40L.selectorOptions = @[@"Pass", @"Fail"];
    row2000hz40L.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row2000hz40L];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioL2000Hz40] != (id)[NSNull null])
        row2000hz40L.value = [self getPassFailfromOneZero:hearingDict[kAudioL2000Hz40]];
    [section addFormRow:row2000hz40L];
    
    XLFormRowDescriptor *row2000hz40R = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioR2000Hz40 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (R) 2000Hz at 40 dBHL Results"];
    row2000hz40R.cellConfig[@"textLabel.numberOfLines"] = @0;
    row2000hz40R.required = YES;
    row2000hz40R.selectorOptions = @[@"Pass", @"Fail"];
    row2000hz40R.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row2000hz40R];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioR2000Hz40] != (id)[NSNull null])
        row2000hz40R.value = [self getPassFailfromOneZero:hearingDict[kAudioR2000Hz40]];
    
    [section addFormRow:row2000hz40R];
    
    XLFormRowDescriptor *row4000hz40L = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioL4000Hz40 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (L) 4000Hz at 40 dBHL Results"];
    row4000hz40L.cellConfig[@"textLabel.numberOfLines"] = @0;
    row4000hz40L.required = YES;
    row4000hz40L.selectorOptions = @[@"Pass", @"Fail"];
    row4000hz40L.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row4000hz40L];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioL4000Hz40] != (id)[NSNull null])
        row4000hz40L.value = [self getPassFailfromOneZero:hearingDict[kAudioL4000Hz40]];
    [section addFormRow:row4000hz40L];
    
    XLFormRowDescriptor *row4000hz40R = [XLFormRowDescriptor formRowDescriptorWithTag:kAudioR4000Hz40 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Audioscope (R) 4000Hz at 40 dBHL Results"];
    row4000hz40R.cellConfig[@"textLabel.numberOfLines"] = @0;
    row4000hz40R.required = YES;
    row4000hz40R.selectorOptions = @[@"Pass", @"Fail"];
    row4000hz40R.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", attendedAudioscopeRow];
    [self setDefaultFontWithRow:row4000hz40R];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kAudioR4000Hz40] != (id)[NSNull null])
        row4000hz40R.value = [self getPassFailfromOneZero:hearingDict[kAudioR4000Hz40]];
    
    [section addFormRow:row4000hz40R];
    
    //    NSArray *audioscopeVariables = @[row500hz60, row500hz25L, row500hz25R, row500hz40L, row500hz40R,
    //                                     row1000hz25L, row1000hz25R, row1000hz40L, row1000hz40R,
    //                                     row2000hz25L, row2000hz25R, row2000hz40L, row2000hz40R,
    //                                     row4000hz25L, row4000hz25R, row4000hz40L, row4000hz40R];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *referredApptRow = [XLFormRowDescriptor formRowDescriptorWithTag:kApptReferred rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Referred for appointment with Mobile Hearing Bus (go back to waiting room booth)"];
    referredApptRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    referredApptRow.required = YES;
    referredApptRow.selectorOptions = @[@"Yes", @"No"];
    [self setDefaultFontWithRow:referredApptRow];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kApptReferred] != (id)[NSNull null])
        referredApptRow.value = [self getYesNofromOneZero:hearingDict[kApptReferred]];
    
    [section addFormRow:referredApptRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Referrer Info"];
    section.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", referredApptRow];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *referrerNameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kReferrerName rowType:XLFormRowDescriptorTypeName title:@"Name of HPB Referrer"];
    referrerNameRow.value = @"RHS";
    referrerNameRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [referrerNameRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    referrerNameRow.required = YES;
    [self setDefaultFontWithRow:referrerNameRow];
    
    //value
    if (hearingDict != (id)[NSNull null] && [hearingDict objectForKey:kReferrerName] != (id)[NSNull null])
        referrerNameRow.value = hearingDict[kReferrerName];
    else
        referrerNameRow.value = @"RHS";
    
    [section addFormRow:referrerNameRow];
    
    referrerSignButtonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"sign_screening_btn" rowType:XLFormRowDescriptorTypeButton title:@"Sign Screening Consent"];
    referrerSignButtonRow.required = NO;
    referrerSignButtonRow.action.formSelector = @selector(goToViewSignatureVC:);
    referrerSignButtonRow.cellConfigAtConfigure[@"backgroundColor"] = signColor;
    referrerSignButtonRow.cellConfig[@"textLabel.textColor"] = [UIColor whiteColor];
    [section addFormRow:referrerSignButtonRow];
    
    
    return [super initWithForm:formDescriptor];
}

- (id) initFollowUp {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Follow Up"];
    XLFormSectionDescriptor * section;

    NSDictionary *followUpDict = [_fullScreeningForm objectForKey:SECTION_FOLLOW_UP];

    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];

    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckFollowUp];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }

    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

    XLFormRowDescriptor *abnormalHearingRow = [XLFormRowDescriptor
                                          formRowDescriptorWithTag:kAbnormalHearing
                                          rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Does resident have any abnormal hearing results?"];
    abnormalHearingRow.required = YES;
    [self setDefaultFontWithRow:abnormalHearingRow];
    abnormalHearingRow.selectorOptions = @[@"Yes", @"No"];
    abnormalHearingRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    if (followUpDict != (id)[NSNull null] && [followUpDict objectForKey:kAbnormalHearing] != (id)[NSNull null])
        abnormalHearingRow.value = [self getYesNofromOneZero:followUpDict[kAbnormalHearing]];
    
    [section addFormRow:abnormalHearingRow];

    

    XLFormRowDescriptor *upcomingApptRow = [XLFormRowDescriptor formRowDescriptorWithTag:kUpcomingAppt rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Do you have an upcoming appointment with your ear specialist/audiologist?"];
    upcomingApptRow.required = YES;
    [self setDefaultFontWithRow:upcomingApptRow];
    upcomingApptRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    upcomingApptRow.selectorOptions = @[@"Yes", @"No"];
    upcomingApptRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", abnormalHearingRow];

    if (followUpDict != (id)[NSNull null] && [followUpDict objectForKey:kUpcomingAppt] != (id)[NSNull null])
        upcomingApptRow.value = [self getYesNofromOneZero:followUpDict[kUpcomingAppt]];

    [section addFormRow:upcomingApptRow];
    
    XLFormRowDescriptor *apptLocationRow = [XLFormRowDescriptor formRowDescriptorWithTag:kApptLocation rowType:XLFormRowDescriptorTypeText title:@"If yes, where?"];
    apptLocationRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [apptLocationRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    apptLocationRow.required = YES;
    [self setDefaultFontWithRow:apptLocationRow];
    apptLocationRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", upcomingApptRow];
    
    if (followUpDict != (id)[NSNull null] && [followUpDict objectForKey:kApptLocation] != (id)[NSNull null])
        apptLocationRow.value = followUpDict[kApptLocation];
    
    [section addFormRow:apptLocationRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *recommendationQRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q" rowType:XLFormRowDescriptorTypeInfo title:@"Recommended Follow up (auto-fill)"];
    [self setDefaultFontWithRow:recommendationQRow];
    recommendationQRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", abnormalHearingRow];
    [section addFormRow:recommendationQRow];
    
    recommendationRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHearingFollowUp rowType:XLFormRowDescriptorTypeText title:@""];

    recommendationRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Yes'", abnormalHearingRow];
    recommendationRow.disabled = @1;
    
    if (followUpDict != (id)[NSNull null] && [followUpDict objectForKey:kHearingFollowUp] != (id)[NSNull null])
        recommendationRow.value = followUpDict[kHearingFollowUp];
    
    [section addFormRow:recommendationRow];


    return [super initWithForm:formDescriptor];
}

#pragma mark - Buttons

-(void)editBtnPressed:(UIBarButtonItem * __unused)button
{
    if ([self.form isDisabled]) {
        [self.form setDisabled:NO];     //enable the form
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finalize" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeBtnPressed:)];
        
        NSString *fieldName;
        
        switch ([self.formNo intValue]) {
                
            case Hearing: fieldName = kCheckHearing;
                break;
            case FollowUp: fieldName = kCheckFollowUp;
                break;
                
            default:
                break;
                
        }
        
        [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:fieldName andNewContent:@"0"]; //un-finalize it
        
        
        
    }
    
}

- (void) finalizeBtnPressed: (UIBarButtonItem * __unused) button {
    
    NSLog(@"%@", [self.form formValues]);
    
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor orangeColor];
            [UIView animateWithDuration:0.3 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }];
        [self showFormValidationError:[validationErrors firstObject]];
        
        return;
    } else {
        NSString *fieldName;
        
        switch ([self.formNo intValue]) {
            case Hearing: fieldName = kCheckHearing;
                break;
            case FollowUp: fieldName = kCheckFollowUp;
                break;
                
            default:
                break;
        }
        [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:fieldName andNewContent:@"1"];
        [SVProgressHUD setMaximumDismissTimeInterval:1.0];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showSuccessWithStatus:@"Completed!"];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
        [self.form setDisabled:YES];
        [self.tableView endEditing:YES];    //to really disable the table
        [self.tableView reloadData];
        
        
    }
    
    
}

#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    NSString *ansFromYesNo;
    
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Yes"])
            ansFromYesNo = @"1";
        else if ([newValue isEqualToString:@"No"])
            ansFromYesNo = @"0";
    }
    
    NSString* ansFromPassFail;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Pass"])
            ansFromPassFail = @"1";
        else if ([newValue isEqualToString:@"Fail"])
            ansFromPassFail = @"0";
    }
    
    /* 7. Hearing */
    if ([rowDescriptor.tag isEqualToString:kUsesAidRight]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kUsesAidRight andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kUsesAidLeft]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kUsesAidLeft andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kAttendedHhie]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAttendedHhie andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kAttendedTinnitus]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAttendedTinnitus andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kTinnitusResult]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kTinnitusResult andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kOtoscopyLeft]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kOtoscopyLeft andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kOtoscopyRight]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kOtoscopyRight andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kAttendedAudioscope]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAttendedAudioscope andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kPractice500Hz60]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kPractice500Hz60 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioR500Hz25]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioR500Hz25 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioL500Hz25]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioL500Hz25 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioL1000Hz25]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioL1000Hz25 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioR1000Hz25]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioR1000Hz25 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioL2000Hz25]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioL2000Hz25 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioR2000Hz25]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioR2000Hz25 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioL4000Hz25]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioL4000Hz25 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioR4000Hz25]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioR4000Hz25 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioL500Hz40]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioL500Hz40 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioR500Hz40]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioR500Hz40 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioL1000Hz40]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioL1000Hz40 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioR1000Hz40]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioR1000Hz40 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioL2000Hz40]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioL2000Hz40 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioR2000Hz40]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioR2000Hz40 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioL4000Hz40]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioL4000Hz40 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kAudioR4000Hz40]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kAudioR4000Hz40 andNewContent:ansFromPassFail];
    } else if ([rowDescriptor.tag isEqualToString:kApptReferred]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kApptReferred andNewContent:ansFromYesNo];
    }

    /* Follow Up */
    else if ([rowDescriptor.tag isEqualToString:kAbnormalHearing]) {
        [self postSingleFieldWithSection:SECTION_FOLLOW_UP andFieldName:kAbnormalHearing andNewContent:ansFromYesNo];
    } else if ([rowDescriptor.tag isEqualToString:kUpcomingAppt]) {
        [self updateFollowUpRecommendation];
        [self postSingleFieldWithSection:SECTION_FOLLOW_UP andFieldName:kUpcomingAppt andNewContent:ansFromYesNo];
    }
    
    
}

//-(void)beginEditing:(XLFormRowDescriptor *)rowDescriptor {
//    if ([rowDescriptor.tag isEqualToString:kInterventions]) {
//        if (rowDescriptor.value == nil || [rowDescriptor.value isEqualToString:@""]) {
//
//        }
//    }
//}

-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {    //works great for textField and textView
    
    if (rowDescriptor.value == nil) {
        rowDescriptor.value = @"";  //empty string
    }
    
    /* 7. Hearing */
    if ([rowDescriptor.tag isEqualToString:kHhieResult]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kHhieResult andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kReferrerName]) {
        [self postSingleFieldWithSection:SECTION_HEARING andFieldName:kReferrerName andNewContent:rowDescriptor.value];
    }
    
    /* Follow Up */
    else if ([rowDescriptor.tag isEqualToString:kApptLocation]) {
        [self postSingleFieldWithSection:SECTION_FOLLOW_UP andFieldName:kApptLocation andNewContent:rowDescriptor.value];
    }
}


- (void) updateFollowUpRecommendation {
    if ([[[self.form formValues] objectForKey:kUpcomingAppt] isEqualToString:@"Yes"]) {
        recommendationRow.value = @"To continue regular follow-up";
    } else {
        recommendationRow.value = @"To see specialist";
    }
    [self reloadFormRow:recommendationRow];
    [self postSingleFieldWithSection:SECTION_FOLLOW_UP andFieldName:kHearingFollowUp andNewContent:recommendationRow.value];
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
                [self.form setDisabled:YES];
                [self.tableView reloadData];
                [self.tableView endEditing:YES];
                [SVProgressHUD setMaximumDismissTimeInterval:2.0];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showErrorWithStatus:@"No Internet!"];
                
                
                break;
            }
            case ReachableViaWiFi:
            case ReachableViaWWAN:
                NSLog(@"Connected to server!");
                
                if (!isFormFinalized) {
                    [self.form setDisabled:NO];
                    [self.tableView reloadData];
                }
                
                
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


- (NSString *) getYesNofromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"]) {
            return @"Yes";
        } else {
            return @"No";
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1]) {
            return @"Yes";
        } else {
            return @"No";
        }
    }
    return @"";
}

- (NSString *) getPassFailfromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"]) {
            return @"Pass";
        } else {
            return @"Fail";
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1]) {
            return @"Pass";
        } else {
            return @"Fail";
        }
    }
    return @"";
}


- (void) showValidationError {
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [validationErrors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
            [UIView animateWithDuration:0.3 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }];
        [self showFormValidationError:[validationErrors firstObject]];
        
        return;
    }
}


#pragma mark - UIFont methods
- (void) setDefaultFontWithRow: (XLFormRowDescriptor *) row {
    UIFont *font = [UIFont fontWithName:DEFAULT_FONT_NAME size:DEFAULT_FONT_SIZE];
    UIFont *boldedFont = [self boldFontWithFont:font];
    [row.cellConfig setObject:boldedFont forKey:@"textLabel.font"];
}

- (UIFont *)boldFontWithFont:(UIFont *)font
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}

#pragma mark - XLFormButton Segue
- (void) goToViewSignatureVC: (XLFormRowDescriptor *) sender {
    [self performSegueWithIdentifier:@"HearingFormToSignatureSegue" sender:self];
}

- (void) updateSignatureButtonColors {
    
    NSString *image_str = [[NSUserDefaults standardUserDefaults] objectForKey:HEARING_REFERRER_SIGNATURE];
    
    if (image_str != nil) {
        signColor = GREEN_COLOR;
    } else {
        signColor = [UIColor redColor];
    }
    
    referrerSignButtonRow.cellConfig[@"backgroundColor"] = signColor;
    [self reloadFormRow:referrerSignButtonRow];
    
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

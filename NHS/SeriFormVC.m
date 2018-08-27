//
//  SeriFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/21/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "SeriFormVC.h"
#import "ServerComm.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "SeriSubsectionTableVC.h"
#import "math.h"
#import "Reachability.h"
#import "ScreeningDictionary.h"
#import "KAStatusBar.h"



typedef enum formName {
    MedHistory,
    VisualAcuity,
    Autorefractor,
    IntraOcularPressure,
    AnteriorHealthExam,
    PosteriorHealthExam,
    DiagAndFollowUp
} formName;


@interface SeriFormVC () {
    NSArray *snellenIndexOptions, *logmarIndexOptions;
    BOOL isFormFinalized;
    BOOL internetDCed;
}


@property (nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (strong, nonatomic) NSDictionary *fullScreeningForm;


@end

@implementation SeriFormVC

- (void)viewDidLoad {
    
    XLFormViewController *form;
    _fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
//    snellenIndexOptions = [[NSArray alloc] initWithObjects:@"6/3.8", @"6/3.8-1", @"6/3.8-2", @"6/5+2", @"6/5+1", @"6/5", @"6/5-1", @"6/5-2", @"6/6+2", @"6/6+1", @"6/6", @"6/6-1", @"6/6-2", @"6/7.5+2", @"6/7.5+1", @"6/7.5", @"6/7.5-1", @"6/7.5-2", @"6/9+2", @"6/9+1", @"6/9", @"6/9-1", @"6/9-2", @"6/12+2", @"6/12+1", @"6/12", @"6/12-1", @"6/12-2", @"6/15+2", @"6/15+1", @"6/15", @"6/15-1", @"6/15-2", @"6/18+2", @"6/18+1", @"6/18", @"6/18-1", @"6/18-2", @"6/24+2", @"6/24+1", @"6/24", @"6/24-1", @"6/24-2", @"6/30+2", @"6/30+1", @"6/30", @"6/30-1", @"6/30-2", @"6/36+2", @"6/36+1", @"6/36", @"6/36-1", @"6/36-2", @"6/48+2", @"6/48+1", @"6/48", @"6/48-1", @"6/48-2", @"6/60+2", @"6/60+1", @"6/60", @"6/120", nil];
//    
//    logmarIndexOptions = [[NSArray alloc] initWithObjects:@"-0.20", @"-0.18", @"-0.16", @"-0.14", @"-0.12", @"-0.10", @"-0.08", @"-0.06", @"-0.04", @"-0.02", @"0.00", @"0.02", @"0.04", @"0.06", @"0.08", @"0.10", @"0.12", @"0.14", @"0.16", @"0.18", @"0.20", @"0.22", @"0.24", @"0.26", @"0.28", @"0.30", @"0.32", @"0.34", @"0.36", @"0.38", @"0.40", @"0.42", @"0.44", @"0.46", @"0.48", @"0.50", @"0.52", @"0.54", @"0.56", @"0.58", @"0.60", @"0.62", @"0.64", @"0.66", @"0.68", @"0.70", @"0.72", @"0.74", @"0.76", @"0.78", @"0.80", @"0.82", @"0.04", @"0.86", @"0.88", @"0.90", @"0.92", @"0.94", @"0.96", @"0.98", @"1.00", @"2.00", nil];
    
    //must init first before [super viewDidLoad]
    int formNumber = [_formNo intValue];
    switch (formNumber) {
            //case 0 is for demographics
        case 0:
            form = [self initMedHistory];
            break;
        case 1:
            form = [self initVisualAcuity];
            break;
        case 2:
            form = [self initAutorefractor];
            break;
        case 3:
            form = [self initIntraOcularPressure];
            break;
        case 4:
            form = [self initAntHealthExam];
            break;
        case 5:
            form = [self initPostHealthExam];
            break;
        case 6:
            form = [self initDiagAndFollowUp];
            break;
        default:
            break;
    }
    
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

- (id) initMedHistory {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Medical History"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row, *rowInfo;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *medHistoryDict = [self.fullScreeningForm objectForKey:SECTION_SERI_MED_HIST];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSeriMedHist];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUndergoneAdvSeri rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Undergone Advanced SERI?"];
    [self setDefaultFontWithRow:row];
    row.required = YES;
    row.selectorOptions = @[@"Yes", @"No"];
    [section addFormRow:row];
    
    
    rowInfo = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Chief Complaint"];
    [self setDefaultFontWithRow:rowInfo];
    [section addFormRow:rowInfo];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kChiefComp rowType:XLFormRowDescriptorTypeTextView title:@""];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@"Type here..." forKey:@"textView.placeholder"];
    
    //value
    if (medHistoryDict != (id)[NSNull null] && [medHistoryDict objectForKey:kChiefComp] != (id)[NSNull null])
        row.value = medHistoryDict[kChiefComp];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOcuHist rowType:XLFormRowDescriptorTypeText title:@"Ocular History"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (medHistoryDict != (id)[NSNull null] && [medHistoryDict objectForKey:kOcuHist] != (id)[NSNull null])
        row.value = medHistoryDict[kOcuHist];
    [section addFormRow:row];

    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHealthHist rowType:XLFormRowDescriptorTypeText title:@"Health History"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (medHistoryDict != (id)[NSNull null] && [medHistoryDict objectForKey:kHealthHist] != (id)[NSNull null])
        row.value = medHistoryDict[kHealthHist];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMedHistComments rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (medHistoryDict != (id)[NSNull null] && [medHistoryDict objectForKey:kMedHistComments] != (id)[NSNull null])
        row.value = medHistoryDict[kMedHistComments];
    
    [section addFormRow:row];

    
    return [super initWithForm:formDescriptor];
    
}

- (id) initVisualAcuity {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Visual Acuity"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row, *vaLogmarOdRow, *vaLogmarOsRow, *pinholeLogmarOdRow, *pinholeLogmarOsRow;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *vaDict = [self.fullScreeningForm objectForKey:SECTION_SERI_VA];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSeriVa];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVaDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.required = YES;
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kVaDone] != (id)[NSNull null])
        row.value = vaDict[kVaDone];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVa rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Presenting VA"];
    row.required = YES;
    row.selectorOptions = @[@"With glasses", @"Without Glasses"];
    [self setDefaultFontWithRow:row];
    
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kVa] != (id)[NSNull null])
        row.value = vaDict[kVa];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVaSnellenOd rowType:XLFormRowDescriptorTypeNumber title:@"Presenting VA Snellen OD: 6/"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kVaSnellenOd] != (id)[NSNull null])
        row.value = [vaDict objectForKey:kVaSnellenOd];
    
    [section addFormRow:row];
    
    vaLogmarOdRow = [XLFormRowDescriptor formRowDescriptorWithTag:kVaLogmarOd rowType:XLFormRowDescriptorTypeNumber title:@"Presenting VA LogMAR OD:"];
    [self setDefaultFontWithRow:vaLogmarOdRow];
    
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kVaLogmarOd] != (id)[NSNull null])
        vaLogmarOdRow.value = vaDict[kVaLogmarOd];
    
    [section addFormRow:vaLogmarOdRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVaSnellenOs rowType:XLFormRowDescriptorTypeNumber title:@"Presenting VA Snellen OS: 6/"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kVaSnellenOs] != (id)[NSNull null])
        row.value = [vaDict objectForKey:kVaSnellenOs];
    
    
    [section addFormRow:row];
    
    vaLogmarOsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kVaLogmarOs rowType:XLFormRowDescriptorTypeNumber title:@"Presenting VA LogMAR OS: +/-"];
    [self setDefaultFontWithRow:vaLogmarOsRow];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kVaLogmarOs] != (id)[NSNull null])
        vaLogmarOsRow.value = vaDict[kVaLogmarOs];
    
    [section addFormRow:vaLogmarOsRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPinSnellenOd rowType:XLFormRowDescriptorTypeNumber title:@"Presenting Pinhole Snellen OD: 6/"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kPinSnellenOd] != (id)[NSNull null])
        row.value = [vaDict objectForKey:kPinSnellenOd];
    
    [section addFormRow:row];
    
    pinholeLogmarOdRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPinLogmarOd rowType:XLFormRowDescriptorTypeNumber title:@"Presenting Pinhole LogMAR OD: +/-"];
    [self setDefaultFontWithRow:pinholeLogmarOdRow];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kPinLogmarOd] != (id)[NSNull null])
        pinholeLogmarOdRow.value = vaDict[kPinLogmarOd];
    
    [section addFormRow:pinholeLogmarOdRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPinSnellenOs rowType:XLFormRowDescriptorTypeNumber title:@"Presenting Pinhole Snellen OS: 6/"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kPinSnellenOs] != (id)[NSNull null])
        row.value = [vaDict objectForKey:kPinSnellenOs];
    
    [section addFormRow:row];
    
    pinholeLogmarOsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPinLogmarOs rowType:XLFormRowDescriptorTypeNumber title:@"Presenting Pinhole LogMAR OS: +/-"];
    [self setDefaultFontWithRow:pinholeLogmarOsRow];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kPinLogmarOs] != (id)[NSNull null])
        pinholeLogmarOsRow.value = vaDict[kPinLogmarOs];
    
    [section addFormRow:pinholeLogmarOsRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNearLogmarOd rowType:XLFormRowDescriptorTypeNumber title:@"Near Visual Acuity LogMAR OD: +/-"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kNearLogmarOd] != (id)[NSNull null])
        row.value = vaDict[kNearLogmarOd];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNearNxOd rowType:XLFormRowDescriptorTypeNumber title:@"Near Visual Acuity Nx OD: +/-"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kNearNxOd] != (id)[NSNull null])
        row.value = vaDict[kNearNxOd];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNearLogmarOs rowType:XLFormRowDescriptorTypeNumber title:@"Near Visual Acuity LogMAR OS: +/-"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kNearLogmarOs] != (id)[NSNull null])
        row.value = vaDict[kNearLogmarOs];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNearNxOs rowType:XLFormRowDescriptorTypeNumber title:@"Near Visual Acuity Nx OS: +/-"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kNearNxOs] != (id)[NSNull null])
        row.value = vaDict[kNearNxOs];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVaComments rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (vaDict != (id)[NSNull null] && [vaDict objectForKey:kVaComments] != (id)[NSNull null])
        row.value = vaDict[kVaComments];
    
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initAutorefractor {

    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Autorefractor"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *autoRefractorDict = [self.fullScreeningForm objectForKey:SECTION_SERI_AUTOREFRACTOR];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSeriAutorefractor];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAutoDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAutoDone] != (id)[NSNull null])
        row.value = autoRefractorDict[kAutoDone];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Right Eye"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR1 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpRightR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpRightR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR2 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpRightR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpRightR2];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR3 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Right Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpRightR3] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpRightR3];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR4 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Right Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpRightR4] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpRightR4];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR5 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Right Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpRightR5] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpRightR5];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR1 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylRightR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylRightR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR2 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylRightR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylRightR2];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR3 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Right Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylRightR3] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylRightR3];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR4 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Right Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylRightR4] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylRightR4];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR5 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Right Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylRightR5] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylRightR5];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR1 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisRightR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisRightR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR2 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisRightR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisRightR2];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR3 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisRightR3] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisRightR3];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR4 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisRightR4] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisRightR4];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR5 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisRightR5] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisRightR5];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerMmRightR1 rowType:XLFormRowDescriptorTypeDecimal title:@"KER MM Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 5 to 10" regex:@"^((([5-9]{1})+(?:\\.([0-9][0-9])?))|1[0])$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerMmRightR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerMmRightR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerMmRightR2 rowType:XLFormRowDescriptorTypeDecimal title:@"KER MM Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 5 to 10" regex:@"^((([5-9]{1})+(?:\\.([0-9][0-9])?))|1[0])$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerMmRightR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerMmRightR2];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerDioRightR1 rowType:XLFormRowDescriptorTypeDecimal title:@"KER Dio Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 30 to 61" regex:@"^(([3-5][0-9]|6[0])+(?:\\.(25|5|75|0)0*)?|6[1])$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerDioRightR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerDioRightR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerDioRightR2 rowType:XLFormRowDescriptorTypeDecimal title:@"KER Dio Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 30 to 61" regex:@"^(([3-5][0-9]|6[0])+(?:\\.(25|5|75|0)0*)?|6[1])$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerDioRightR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerDioRightR2];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerAxRightR1 rowType:XLFormRowDescriptorTypeInteger title:@"KER Ax Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerAxRightR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerAxRightR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerAxRightR2 rowType:XLFormRowDescriptorTypeInteger title:@"KER Ax Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerAxRightR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerAxRightR2];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Left Eye"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR1 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpLeftR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpLeftR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR2 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpLeftR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpLeftR2];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR3 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Left Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpLeftR3] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpLeftR3];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR4 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Left Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpLeftR4] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpLeftR4];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR5 rowType:XLFormRowDescriptorTypeNumber title:@"Sphere Left Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kSpLeftR5] != (id)[NSNull null])
        row.value = autoRefractorDict[kSpLeftR5];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR1 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylLeftR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylLeftR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR2 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylLeftR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylLeftR2];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR3 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Left Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylLeftR3] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylLeftR3];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR4 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Left Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylLeftR4] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylLeftR4];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR5 rowType:XLFormRowDescriptorTypeNumber title:@"Cyl Left Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kCylLeftR5] != (id)[NSNull null])
        row.value = autoRefractorDict[kCylLeftR5];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR1 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisLeftR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisLeftR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR2 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];

    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisLeftR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisLeftR2];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR3 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisLeftR3] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisLeftR3];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR4 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisLeftR4] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisLeftR4];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR5 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAxisLeftR5] != (id)[NSNull null])
        row.value = autoRefractorDict[kAxisLeftR5];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerMmLeftR1 rowType:XLFormRowDescriptorTypeDecimal title:@"KER MM Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 5 to 10" regex:@"^((([5-9]{1})+(?:\\.([0-9][0-9])?))|1[0])$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerMmLeftR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerMmLeftR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerMmLeftR2 rowType:XLFormRowDescriptorTypeDecimal title:@"KER MM Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 5 to 10" regex:@"^((([5-9]{1})+(?:\\.([0-9][0-9])?))|1[0])$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerMmLeftR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerMmLeftR2];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerDioLeftR1 rowType:XLFormRowDescriptorTypeDecimal title:@"KER Dio Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 30 to 61" regex:@"^(([3-5][0-9]|6[0])+(?:\\.(25|5|75|0)0*)?|6[1])$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerDioLeftR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerDioLeftR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerDioLeftR2 rowType:XLFormRowDescriptorTypeDecimal title:@"KER Dio Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 30 to 61" regex:@"^(([3-5][0-9]|6[0])+(?:\\.(25|5|75|0)0*)?|6[1])$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerDioLeftR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerDioLeftR2];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerAxLeftR1 rowType:XLFormRowDescriptorTypeInteger title:@"KER Ax Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerAxLeftR1] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerAxLeftR1];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerAxLeftR2 rowType:XLFormRowDescriptorTypeInteger title:@"KER Ax Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kKerAxLeftR2] != (id)[NSNull null])
        row.value = autoRefractorDict[kKerAxLeftR2];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPupilDist rowType:XLFormRowDescriptorTypeNumber title:@"Pupillary Distance: "];
    [self setDefaultFontWithRow:row];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kPupilDist] != (id)[NSNull null])
        row.value = autoRefractorDict[kPupilDist];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAutorefractorComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (autoRefractorDict != (id)[NSNull null] && [autoRefractorDict objectForKey:kAutorefractorComment] != (id)[NSNull null])
        row.value = autoRefractorDict[kAutorefractorComment];
    
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initIntraOcularPressure {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Intra-ocular Pressure"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *intraOcularDict = [self.fullScreeningForm objectForKey:SECTION_SERI_IOP];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSeriIop];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIopDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.required = YES;
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (intraOcularDict != (id)[NSNull null] && [intraOcularDict objectForKey:kIopDone] != (id)[NSNull null])
        row.value = intraOcularDict[kIopDone];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIopRight rowType:XLFormRowDescriptorTypeInteger title:@"Intra-Ocular Pressure (Right Eye) "];
    [self setDefaultFontWithRow:row];
    
    if (intraOcularDict != (id)[NSNull null] && [intraOcularDict objectForKey:kIopRight] != (id)[NSNull null])
        row.value = intraOcularDict[kIopRight];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIopLeft rowType:XLFormRowDescriptorTypeInteger title:@"Intra-Ocular Pressure (Left Eye) "];
    [self setDefaultFontWithRow:row];
    
    if (intraOcularDict != (id)[NSNull null] && [intraOcularDict objectForKey:kIopLeft] != (id)[NSNull null])
        row.value = intraOcularDict[kIopLeft];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIopComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    if (intraOcularDict != (id)[NSNull null] && [intraOcularDict objectForKey:kIopComment] != (id)[NSNull null])
        row.value = intraOcularDict[kIopComment];
    
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initAntHealthExam {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Anterior Health Exam"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *antHealthExamDict = [self.fullScreeningForm objectForKey:SECTION_SERI_AHE];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSeriAhe];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    row.required = YES;
    [self setDefaultFontWithRow:row];
    
    //value
    if (antHealthExamDict != (id)[NSNull null] && [antHealthExamDict objectForKey:kAheDone] != (id)[NSNull null])
        row.value = antHealthExamDict[kAheDone];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheOd rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"OD:"];
    row.selectorOptions = @[@"Normal", @"Abnormal"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (antHealthExamDict != (id)[NSNull null] && [antHealthExamDict objectForKey:kAheOd] != (id)[NSNull null])
        row.value = antHealthExamDict[kAheOd];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheOdRemark rowType:XLFormRowDescriptorTypeText title:@"OD Remarks: "];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    //value
    if (antHealthExamDict != (id)[NSNull null] && [antHealthExamDict objectForKey:kAheOdRemark] != (id)[NSNull null])
        row.value = antHealthExamDict[kAheOdRemark];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheOs rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"OS:"];
    row.selectorOptions = @[@"Normal", @"Abnormal"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (antHealthExamDict != (id)[NSNull null] && [antHealthExamDict objectForKey:kAheOs] != (id)[NSNull null])
        row.value = antHealthExamDict[kAheOs];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheOsRemark rowType:XLFormRowDescriptorTypeText title:@"OS Remarks: "];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (antHealthExamDict != (id)[NSNull null] && [antHealthExamDict objectForKey:kAheOsRemark] != (id)[NSNull null])
        row.value = antHealthExamDict[kAheOsRemark];
    
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (antHealthExamDict != (id)[NSNull null] && [antHealthExamDict objectForKey:kAheComment] != (id)[NSNull null])
        row.value = antHealthExamDict[kAheComment];
    
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initPostHealthExam {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Posterior Health Exam"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *postHealthExamDict = [self.fullScreeningForm objectForKey:SECTION_SERI_PHE];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSeriPhe];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.required = YES;
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    
    //value
    if (postHealthExamDict != (id)[NSNull null] && [postHealthExamDict objectForKey:kPheDone] != (id)[NSNull null])
        row.value = postHealthExamDict[kPheDone];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheFundusOd rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"Fundus Examination OD:"];
    row.selectorOptions = @[@"Normal", @"Abnormal"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (postHealthExamDict != (id)[NSNull null] && [postHealthExamDict objectForKey:kPheFundusOd] != (id)[NSNull null])
        row.value = postHealthExamDict[kPheFundusOd];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheFundusOdRemark rowType:XLFormRowDescriptorTypeText title:@"Fundus Examination OD Remarks: "];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    //value
    if (postHealthExamDict != (id)[NSNull null] && [postHealthExamDict objectForKey:kPheFundusOdRemark] != (id)[NSNull null])
        row.value = postHealthExamDict[kPheFundusOdRemark];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheFundusOs rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"Fundus Examination OS:"];
    row.selectorOptions = @[@"Normal", @"Abnormal"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (postHealthExamDict != (id)[NSNull null] && [postHealthExamDict objectForKey:kPheFundusOs] != (id)[NSNull null])
        row.value = postHealthExamDict[kPheFundusOs];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheFundusOsRemark rowType:XLFormRowDescriptorTypeText title:@"Fundus Examination OS Remarks: "];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (postHealthExamDict != (id)[NSNull null] && [postHealthExamDict objectForKey:kPheFundusOsRemark] != (id)[NSNull null])
        row.value = postHealthExamDict[kPheFundusOsRemark];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (postHealthExamDict != (id)[NSNull null] && [postHealthExamDict objectForKey:kPheComment] != (id)[NSNull null])
        row.value = postHealthExamDict[kPheComment];
    
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initDiagAndFollowUp {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Diagnosis and Follow-up"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    NSDictionary *diagFollowUpDict = [self.fullScreeningForm objectForKey:SECTION_SERI_DIAG];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckSeriDiag];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    XLFormRowDescriptor *diagOdRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagnosisOd rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Diagnosis OD: "];
    diagOdRow.required = YES;
    diagOdRow.selectorOptions = @[@"Normal", @"Refractive Error", @"Cataract", @"Glaucoma", @"Age-related macular degeneration", @"Diabetic Retinopathy/maculopathy", @"Others"];
    diagOdRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:diagOdRow];
    
    if (diagFollowUpDict != (id)[NSNull null]) {
        diagOdRow.value = [self getDiagnosisOdArray:diagFollowUpDict];
    }
    
    [section addFormRow:diagOdRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagOdOthers rowType:XLFormRowDescriptorTypeText title:@"Diagnosis OD Others "];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", diagOdRow];
    [self setDefaultFontWithRow:row];
    
    //value
    if (diagFollowUpDict != (id)[NSNull null] && [diagFollowUpDict objectForKey:kDiagOdOthers] != (id)[NSNull null])
        row.value = diagFollowUpDict[kDiagOdOthers];
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *diagOsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagnosisOs rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Diagnosis OS: "];
    diagOsRow.required = YES;
    diagOsRow.selectorOptions = @[@"Normal", @"Refractive Error", @"Cataract", @"Glaucoma", @"Age-related macular degeneration", @"Diabetic Retinopathy/maculopathy", @"Others"];
    diagOsRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:diagOsRow];
    
    if (diagFollowUpDict != (id)[NSNull null]) {
        diagOsRow.value = [self getDiagnosisOsArray:diagFollowUpDict];
    }
    
    [section addFormRow:diagOsRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagOsOthers rowType:XLFormRowDescriptorTypeText title:@"Diagnosis OS Others "];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", diagOsRow];
    [self setDefaultFontWithRow:row];
    
    //value
    if (diagFollowUpDict != (id)[NSNull null] && [diagFollowUpDict objectForKey:kDiagOsOthers] != (id)[NSNull null])
        row.value = diagFollowUpDict[kDiagOsOthers];
    
    [section addFormRow:row];
    
    XLFormRowDescriptor *followUpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUp rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Follow-up:"];
    followUpRow.required = YES;
    followUpRow.selectorOptions = @[@"No FU needed", @"Already on FU", @"Need spectacles", @"Referral to eye specialist", @"Cataract Surgery"];
    followUpRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:followUpRow];
    
    //value
    if (diagFollowUpDict != (id)[NSNull null] && [diagFollowUpDict objectForKey:kFollowUp] != (id)[NSNull null])
        followUpRow.value = diagFollowUpDict[kFollowUp];
    
    [section addFormRow:followUpRow];
    
    XLFormRowDescriptor *eyeSpecRefRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEyeSpecRef rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"Provided with Referral Letter:"];
    eyeSpecRefRow.selectorOptions = @[@"Urgent", @"Non-urgent"];
    eyeSpecRefRow.noValueDisplayText = @"Tap here";
    eyeSpecRefRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:eyeSpecRefRow];
    eyeSpecRefRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Referral to eye-specialist'", followUpRow];
    
    //value
    if (diagFollowUpDict != (id)[NSNull null] && [diagFollowUpDict objectForKey:kEyeSpecRef] != (id)[NSNull null])
        eyeSpecRefRow.value = diagFollowUpDict[kEyeSpecRef];
    
    [section addFormRow:eyeSpecRefRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNonUrgentRefMths rowType:XLFormRowDescriptorTypeNumber title:@"Non-urgent referral: ___ months"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Non-urgent'", eyeSpecRefRow];
    
    //value
    if (diagFollowUpDict != (id)[NSNull null] && [diagFollowUpDict objectForKey:kNonUrgentRefMths] != (id)[NSNull null])
        row.value = diagFollowUpDict[kNonUrgentRefMths];
    
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    
    //value
    if (diagFollowUpDict != (id)[NSNull null] && [diagFollowUpDict objectForKey:kDiagComment] != (id)[NSNull null])
        row.value = diagFollowUpDict[kDiagComment];
    
    [section addFormRow:row];

    return [super initWithForm:formDescriptor];
    
}

#pragma mark - Validation
-(void)validateBtnPressed:(UIBarButtonItem * __unused)button
{
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

            [SVProgressHUD setMinimumDismissTimeInterval:1.0f];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showImage:[[UIImage imageNamed:@"ThumbsUp"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] status:@"Good!"];
    }
    
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
            case MedHistory: fieldName = kCheckSeriMedHist;
                break;
            case VisualAcuity: fieldName = kCheckSeriVa;
                break;
            case Autorefractor: fieldName = kCheckSeriAutorefractor;
                break;
            case IntraOcularPressure: fieldName = kCheckSeriIop;
                break;
            case AnteriorHealthExam: fieldName = kCheckSeriAhe;
                break;
            case PosteriorHealthExam: fieldName = kCheckSeriPhe;
                break;
            case DiagAndFollowUp: fieldName = kCheckSeriDiag;
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
            case MedHistory: fieldName = kCheckSeriMedHist;
                break;
            case VisualAcuity: fieldName = kCheckSeriVa;
                break;
            case Autorefractor: fieldName = kCheckSeriAutorefractor;
                break;
            case IntraOcularPressure: fieldName = kCheckSeriIop;
                break;
            case AnteriorHealthExam: fieldName = kCheckSeriAhe;
                break;
            case PosteriorHealthExam: fieldName = kCheckSeriPhe;
                break;
            case DiagAndFollowUp: fieldName = kCheckSeriDiag;
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
    
    NSString* ansFromYesNo;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"Yes"])
            ansFromYesNo = @"1";
        else if ([newValue isEqualToString:@"No"])
            ansFromYesNo = @"0";
    }
    
    NSString* ansFromYESNO;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"YES"])
            ansFromYESNO = @"1";
        else if ([newValue isEqualToString:@"NO"])
            ansFromYESNO = @"0";
    }
    
    //Medical History
    if ([rowDescriptor.tag isEqualToString:kUndergoneAdvSeri]) {
        [self postSingleFieldWithSection:SECTION_SERI_MED_HIST andFieldName:kUndergoneAdvSeri andNewContent:ansFromYesNo];
    }

    //Visual Acuity
    if ([rowDescriptor.tag isEqualToString:kVaDone]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kVaDone andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kVa]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kVa andNewContent:newValue];
    }
    
    // AutoRefractor
    else if ([rowDescriptor.tag isEqualToString:kAutoDone]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAutoDone andNewContent:newValue];
    }
    
    // Intra-ocular Pressure
    else if ([rowDescriptor.tag isEqualToString:kIopDone]) {
        [self postSingleFieldWithSection:SECTION_SERI_IOP andFieldName:kIopDone andNewContent:newValue];
    }
    
    // Anterior Health Exam
    else if ([rowDescriptor.tag isEqualToString:kAheDone]) {
        [self postSingleFieldWithSection:SECTION_SERI_AHE andFieldName:kAheDone andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kAheOd]) {
        [self postSingleFieldWithSection:SECTION_SERI_AHE andFieldName:kAheOd andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kAheOs]) {
        [self postSingleFieldWithSection:SECTION_SERI_AHE andFieldName:kAheOs andNewContent:newValue];
    }
    
    // Posterior Health Exam
    else if ([rowDescriptor.tag isEqualToString:kPheDone]) {
        [self postSingleFieldWithSection:SECTION_SERI_PHE andFieldName:kPheDone andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPheFundusOd]) {
        [self postSingleFieldWithSection:SECTION_SERI_PHE andFieldName:kPheFundusOd andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kPheFundusOs]) {
        [self postSingleFieldWithSection:SECTION_SERI_PHE andFieldName:kPheFundusOs andNewContent:newValue];
    }
    
    //Diagnosis and Follow-up
    else if ([rowDescriptor.tag isEqualToString:kDiagnosisOd]) {
        [self processDiagnosisOdWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kDiagnosisOs]) {
        [self processDiagnosisOsWithNewValue:newValue andOldValue:oldValue];
    } else if ([rowDescriptor.tag isEqualToString:kFollowUp]) {
        [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:kFollowUp andNewContent:newValue];
    } else if ([rowDescriptor.tag isEqualToString:kEyeSpecRef]) {
        [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:kEyeSpecRef andNewContent:newValue];
    }
}


-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor {    //works great for textField and textView
    
    if (rowDescriptor.value == nil) {
        rowDescriptor.value = @"";  //empty string
    }
    
    //Medical History
    if ([rowDescriptor.tag isEqualToString:kChiefComp]) {
        [self postSingleFieldWithSection:SECTION_SERI_MED_HIST andFieldName:kChiefComp andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kOcuHist]) {
        [self postSingleFieldWithSection:SECTION_SERI_MED_HIST andFieldName:kOcuHist andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kHealthHist]) {
        [self postSingleFieldWithSection:SECTION_SERI_MED_HIST andFieldName:kHealthHist andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kMedHistComments]) {
        [self postSingleFieldWithSection:SECTION_SERI_MED_HIST andFieldName:kMedHistComments andNewContent:rowDescriptor.value];
    }
    
    //Visual Acuity
    else if ([rowDescriptor.tag isEqualToString:kVaSnellenOd]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kVaSnellenOd andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kVaLogmarOd]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kVaLogmarOd andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kVaSnellenOs]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kVaSnellenOs andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kVaLogmarOs]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kVaLogmarOs andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kPinSnellenOd]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kPinSnellenOd andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kPinLogmarOd]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kPinLogmarOd andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kPinSnellenOs]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kPinSnellenOs andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kPinLogmarOs]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kPinLogmarOs andNewContent:rowDescriptor.value];
    }else if ([rowDescriptor.tag isEqualToString:kNearLogmarOd]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kNearLogmarOd andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNearNxOd]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kNearNxOd andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNearLogmarOs]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kNearLogmarOs andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kNearNxOs]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kNearNxOs andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kVaComments]) {
        [self postSingleFieldWithSection:SECTION_SERI_VA andFieldName:kVaComments andNewContent:rowDescriptor.value];
    }
    
    //AutoRefractor
    else if ([rowDescriptor.tag isEqualToString:kSpRightR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpRightR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSpRightR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpRightR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSpRightR3]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpRightR3 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSpRightR4]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpRightR4 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSpRightR5]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpRightR5 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylRightR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylRightR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylRightR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylRightR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylRightR3]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylRightR3 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylRightR4]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylRightR4 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylRightR5]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylRightR5 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisRightR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisRightR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisRightR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisRightR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisRightR3]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisRightR3 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisRightR4]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisRightR4 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisRightR5]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisRightR5 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerMmRightR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerMmRightR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerMmRightR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerMmRightR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerDioRightR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerDioRightR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerDioRightR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerDioRightR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerAxRightR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerAxRightR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerAxRightR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerAxRightR2 andNewContent:rowDescriptor.value];
    }
    
    else if ([rowDescriptor.tag isEqualToString:kSpLeftR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpLeftR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSpLeftR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpLeftR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSpLeftR3]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpLeftR3 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSpLeftR4]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpLeftR4 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kSpLeftR5]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kSpLeftR5 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylLeftR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylLeftR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylLeftR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylLeftR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylLeftR3]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylLeftR3 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylLeftR4]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylLeftR4 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kCylLeftR5]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kCylLeftR5 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisLeftR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisLeftR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisLeftR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisLeftR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisLeftR3]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisLeftR3 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisLeftR4]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisLeftR4 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAxisLeftR5]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAxisLeftR5 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerMmLeftR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerMmLeftR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerMmLeftR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerMmLeftR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerDioLeftR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerDioLeftR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerDioLeftR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerDioLeftR2 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kPupilDist]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kPupilDist andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAutorefractorComment]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kAutorefractorComment andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerAxLeftR1]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerAxLeftR1 andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kKerAxLeftR2]) {
        [self postSingleFieldWithSection:SECTION_SERI_AUTOREFRACTOR andFieldName:kKerAxLeftR2 andNewContent:rowDescriptor.value];
    }
    
    //Intra-ocular Pressure
    else if ([rowDescriptor.tag isEqualToString:kIopRight]) {
        [self postSingleFieldWithSection:SECTION_SERI_IOP andFieldName:kIopRight andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kIopLeft]) {
        [self postSingleFieldWithSection:SECTION_SERI_IOP andFieldName:kIopLeft andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kIopComment]) {
        [self postSingleFieldWithSection:SECTION_SERI_IOP andFieldName:kIopComment andNewContent:rowDescriptor.value];
    }
    
    // Anterior Health Examination
    else if ([rowDescriptor.tag isEqualToString:kAheOdRemark]) {
        [self postSingleFieldWithSection:SECTION_SERI_AHE andFieldName:kAheOdRemark andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAheOsRemark]) {
        [self postSingleFieldWithSection:SECTION_SERI_AHE andFieldName:kAheOsRemark andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kAheComment]) {
        [self postSingleFieldWithSection:SECTION_SERI_AHE andFieldName:kAheComment andNewContent:rowDescriptor.value];
    }
    
    // Posterior Health Examination
    else if ([rowDescriptor.tag isEqualToString:kPheFundusOdRemark]) {
        [self postSingleFieldWithSection:SECTION_SERI_PHE andFieldName:kPheFundusOdRemark andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kPheFundusOsRemark]) {
        [self postSingleFieldWithSection:SECTION_SERI_PHE andFieldName:kPheFundusOsRemark andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kPheComment]) {
        [self postSingleFieldWithSection:SECTION_SERI_PHE andFieldName:kPheComment andNewContent:rowDescriptor.value];
    }
    
    
    else if ([rowDescriptor.tag isEqualToString:kNonUrgentRefMths]) {
        [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:kNonUrgentRefMths andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kDiagOdOthers]) {
        [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:kDiagOdOthers andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kDiagOsOthers]) {
        [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:kDiagOsOthers andNewContent:rowDescriptor.value];
    } else if ([rowDescriptor.tag isEqualToString:kDiagComment]) {
        [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:kDiagComment andNewContent:rowDescriptor.value];
    }

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

#pragma mark - Data Process b4 Submission

- (void) processDiagnosisOdWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
    if (newValue != oldValue) {
        
        if (newValue != nil && newValue != (id) [NSNull null]) {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                NSMutableSet *oldSet = [NSMutableSet setWithCapacity:[oldValue count]];
                [oldSet addObjectsFromArray:oldValue];
                NSMutableSet *newSet = [NSMutableSet setWithCapacity:[newValue count]];
                [newSet addObjectsFromArray:newValue];
                
                if ([newSet count] > [oldSet count]) {
                    [newSet minusSet:oldSet];
                    NSArray *array = [newSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:[self getFieldNameFromDiagnosisOd:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:[self getFieldNameFromDiagnosisOd:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:[self getFieldNameFromDiagnosisOd:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:[self getFieldNameFromDiagnosisOd:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}

- (NSString *) getFieldNameFromDiagnosisOd: (NSString *) expenses {
    if ([expenses containsString:@"Normal"]) return kOdNormal ;
    else if ([expenses containsString:@"Refractive Error"]) return kOdRefractive;
    else if ([expenses containsString:@"Cataract"]) return kOdCataract;
    else if ([expenses containsString:@"Glaucoma"]) return kOdGlaucoma;
    else if ([expenses containsString:@"Age-related macular degeneration"]) return kOdAge;
    else if ([expenses containsString:@"Diabetic Retinopathy/maculopathy"]) return kOdDiabetic;
    else if ([expenses containsString:@"Others"]) return kOdOthers;
    else return @"";
    
}

- (void) processDiagnosisOsWithNewValue: (NSArray *) newValue andOldValue: (NSArray *) oldValue {
    
    if (newValue != oldValue) {
        
        if (newValue != nil && newValue != (id) [NSNull null]) {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                NSMutableSet *oldSet = [NSMutableSet setWithCapacity:[oldValue count]];
                [oldSet addObjectsFromArray:oldValue];
                NSMutableSet *newSet = [NSMutableSet setWithCapacity:[newValue count]];
                [newSet addObjectsFromArray:newValue];
                
                if ([newSet count] > [oldSet count]) {
                    [newSet minusSet:oldSet];
                    NSArray *array = [newSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:[self getFieldNameFromDiagnosisOs:[array firstObject]] andNewContent:@"1"];
                } else {
                    [oldSet minusSet:newSet];
                    NSArray *array = [oldSet allObjects];
                    [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:[self getFieldNameFromDiagnosisOs:[array firstObject]] andNewContent:@"0"];
                }
            } else {
                [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:[self getFieldNameFromDiagnosisOs:[newValue firstObject]] andNewContent:@"1"];
            }
        } else {
            if (oldValue != nil && oldValue != (id) [NSNull null]) {
                [self postSingleFieldWithSection:SECTION_SERI_DIAG andFieldName:[self getFieldNameFromDiagnosisOs:[oldValue firstObject]] andNewContent:@"0"];
            }
        }
    }
    
}

- (NSString *) getFieldNameFromDiagnosisOs: (NSString *) expenses {
    if ([expenses containsString:@"Normal"]) return kOsNormal ;
    else if ([expenses containsString:@"Refractive Error"]) return kOsRefractive;
    else if ([expenses containsString:@"Cataract"]) return kOsCataract;
    else if ([expenses containsString:@"Glaucoma"]) return kOsGlaucoma;
    else if ([expenses containsString:@"Age-related macular degeneration"]) return kOsAge;
    else if ([expenses containsString:@"Diabetic Retinopathy/maculopathy"]) return kOsDiabetic;
    else if ([expenses containsString:@"Others"]) return kOsOthers;
    else return @"";
    
}

- (NSString *) removeSubstringFromSnellenIndex: (NSString *) string {

    if ([string containsString:@"6/"]) {
        NSMutableString *str = [string copy];
        string = [str stringByReplacingOccurrencesOfString:@"6/" withString:@""];
        return string;
    } else return @"";
    
}

#pragma mark - Initialisation of Value

- (NSArray *) getDiagnosisOdArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kOdNormal, kOdRefractive, kOdCataract, kOdGlaucoma,kOdAge, kOdDiabetic, kOdOthers];
    NSArray *textArray = @[@"Normal", @"Refractive Error", @"Cataract", @"Glaucoma", @"Age-related macular degeneration", @"Diabetic Retinopathy/maculopathy", @"Others"];
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[keyArray count]; i++) {
        NSString *key = keyArray[i];
        if (dict[key] != (id)[NSNull null]) {
            if ([dict[key] isEqual:@1])
                [returnArray addObject:textArray[i]];
        }
    }
    
    return returnArray;
}

- (NSArray *) getDiagnosisOsArray: (NSDictionary *) dict {
    NSArray *keyArray = @[kOsNormal, kOsRefractive, kOsCataract, kOsGlaucoma, kOsAge, kOsDiabetic, kOsOthers];
    NSArray *textArray = @[@"Normal", @"Refractive Error", @"Cataract", @"Glaucoma", @"Age-related macular degeneration", @"Diabetic Retinopathy/maculopathy", @"Others"];
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[keyArray count]; i++) {
        NSString *key = keyArray[i];
        if (dict[key] != (id)[NSNull null]) {
            if ([dict[key] isEqual:@1])
                [returnArray addObject:textArray[i]];
        }
    }
    
    return returnArray;
}


#pragma mark - Snellen to LogMAR
- (NSString *) snellenToLogMARWithRowValue: (NSString *) string {
    
    
    NSUInteger index = [snellenIndexOptions indexOfObject:string];
    return logmarIndexOptions[index];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

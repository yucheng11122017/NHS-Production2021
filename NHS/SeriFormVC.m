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

@interface SeriFormVC () {
    NSArray *snellenIndexOptions, *logmarIndexOptions;
}

@end

@implementation SeriFormVC

- (void)viewDidLoad {
    
    XLFormViewController *form;
    
    snellenIndexOptions = [[NSArray alloc] initWithObjects:@"6/3.8", @"6/3.8-1", @"6/3.8-2", @"6/5+2", @"6/5+1", @"6/5", @"6/5-1", @"6/5-2", @"6/6+2", @"6/6+1", @"6/6", @"6/6-1", @"6/6-2", @"6/7.5+2", @"6/7.5+1", @"6/7.5", @"6/7.5-1", @"6/7.5-2", @"6/9+2", @"6/9+1", @"6/9", @"6/9-1", @"6/9-2", @"6/12+2", @"6/12+1", @"6/12", @"6/12-1", @"6/12-2", @"6/15+2", @"6/15+1", @"6/15", @"6/15-1", @"6/15-2", @"6/18+2", @"6/18+1", @"6/18", @"6/18-1", @"6/18-2", @"6/24+2", @"6/24+1", @"6/24", @"6/24-1", @"6/24-2", @"6/30+2", @"6/30+1", @"6/30", @"6/30-1", @"6/30-2", @"6/36+2", @"6/36+1", @"6/36", @"6/36-1", @"6/36-2", @"6/48+2", @"6/48+1", @"6/48", @"6/48-1", @"6/48-2", @"6/60+2", @"6/60+1", @"6/60", @"6/120", nil];
    
    logmarIndexOptions = [[NSArray alloc] initWithObjects:@"-0.20", @"-0.18", @"-0.16", @"-0.14", @"-0.12", @"-0.10", @"-0.08", @"-0.06", @"-0.04", @"-0.02", @"0.00", @"0.02", @"0.04", @"0.06", @"0.08", @"0.10", @"0.12", @"0.14", @"0.16", @"0.18", @"0.20", @"0.22", @"0.24", @"0.26", @"0.28", @"0.30", @"0.32", @"0.34", @"0.36", @"0.38", @"0.40", @"0.42", @"0.44", @"0.46", @"0.48", @"0.50", @"0.52", @"0.54", @"0.56", @"0.58", @"0.60", @"0.62", @"0.64", @"0.66", @"0.68", @"0.70", @"0.72", @"0.74", @"0.76", @"0.78", @"0.80", @"0.82", @"0.04", @"0.86", @"0.88", @"0.90", @"0.92", @"0.94", @"0.96", @"0.98", @"1.00", @"2.00", nil];
    
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
    
    if (formNumber == 2 || formNumber  == 3)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Validate" style:UIBarButtonItemStyleDone target:self action:@selector(validateBtnPressed:)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    
    rowInfo = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Chief Complaint"];
    [self setDefaultFontWithRow:rowInfo];
    [section addFormRow:rowInfo];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kChiefComp rowType:XLFormRowDescriptorTypeTextView title:@""];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@"Type here..." forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kOcuHist rowType:XLFormRowDescriptorTypeText title:@"Ocular History"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;

    [self setDefaultFontWithRow:row];
    [section addFormRow:row];

    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHealthHist rowType:XLFormRowDescriptorTypeText title:@"Health History"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];

    
    return [super initWithForm:formDescriptor];
    
}

- (id) initVisualAcuity {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Visual Acuity"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row, *vaLogmarOdRow, *vaLogmarOsRow, *pinholeLogmarOdRow, *pinholeLogmarOsRow;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVaDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVa rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Presenting VA"];
    row.selectorOptions = @[@"With glasses", @"Without Glasses"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVaSnellenOd rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Presenting VA Snellen OD: "];
    row.selectorOptions = snellenIndexOptions;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    vaLogmarOdRow = [XLFormRowDescriptor formRowDescriptorWithTag:kVaLogmarOd rowType:XLFormRowDescriptorTypeInfo title:@"Presenting VA LogMAR OD: "];
    [self setDefaultFontWithRow:vaLogmarOdRow];
    [section addFormRow:vaLogmarOdRow];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            vaLogmarOdRow.value  = [self snellenToLogMARWithRowValue:newValue];
            [self reloadFormRow:vaLogmarOdRow];
        }
    };
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVaSnellenOs rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Presenting VA Snellen OS: "];
    row.selectorOptions = snellenIndexOptions;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    vaLogmarOsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kVaLogmarOs rowType:XLFormRowDescriptorTypeInfo title:@"Presenting VA LogMAR OS: "];
    [self setDefaultFontWithRow:vaLogmarOsRow];
    [section addFormRow:vaLogmarOsRow];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            vaLogmarOsRow.value  = [self snellenToLogMARWithRowValue:newValue];
            [self reloadFormRow:vaLogmarOsRow];
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPinSnellenOd rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Presenting Pinhole Snellen OD: "];
    row.selectorOptions = snellenIndexOptions;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    pinholeLogmarOdRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPinLogmarOd rowType:XLFormRowDescriptorTypeInfo title:@"Presenting Pinhole LogMAR OD: "];
    [self setDefaultFontWithRow:pinholeLogmarOdRow];
    [section addFormRow:pinholeLogmarOdRow];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            pinholeLogmarOdRow.value  = [self snellenToLogMARWithRowValue:newValue];
            [self reloadFormRow:pinholeLogmarOdRow];
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPinSnellenOs rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Presenting Pinhole Snellen OS: "];
    row.selectorOptions = snellenIndexOptions;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    pinholeLogmarOsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPinLogmarOs rowType:XLFormRowDescriptorTypeInfo title:@"Presenting Pinhole LogMAR OS: "];
    [self setDefaultFontWithRow:pinholeLogmarOsRow];
    [section addFormRow:pinholeLogmarOsRow];
    
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            pinholeLogmarOsRow.value  = [self snellenToLogMARWithRowValue:newValue];
            [self reloadFormRow:pinholeLogmarOsRow];
        }
    };
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNearLogmarOd rowType:XLFormRowDescriptorTypeDecimal title:@"Near Visual Acuity LogMAR OD: "];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNearNxOd rowType:XLFormRowDescriptorTypeDecimal title:@"Near Visual Acuity Nx OD: "];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNearLogmarOs rowType:XLFormRowDescriptorTypeDecimal title:@"Near Visual Acuity LogMAR OS: "];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNearNxOs rowType:XLFormRowDescriptorTypeDecimal title:@"Near Visual Acuity Nx OS: "];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVaComments rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initAutorefractor {

    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Visual Acuity"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAutoDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Right Eye"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR1 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR2 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR3 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Right Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR4 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Right Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpRightR5 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Right Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR1 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR2 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR3 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Right Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR4 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Right Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylRightR5 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Right Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR1 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR2 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR3 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR4 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisRightR5 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Right Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerMmRightR1 rowType:XLFormRowDescriptorTypeDecimal title:@"KER MM Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 5 to 10" regex:@"^((([5-9]{1})+(?:\\.([0-9][0-9])?))|1[0])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerMmRightR2 rowType:XLFormRowDescriptorTypeDecimal title:@"KER MM Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 5 to 10" regex:@"^((([5-9]{1})+(?:\\.([0-9][0-9])?))|1[0])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerDioRightR1 rowType:XLFormRowDescriptorTypeDecimal title:@"KER Dio Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 30 to 61" regex:@"^(([3-5][0-9]|6[0])+(?:\\.(25|5|75|0)0*)?|6[1])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerDioRightR2 rowType:XLFormRowDescriptorTypeDecimal title:@"KER Dio Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 30 to 61" regex:@"^(([3-5][0-9]|6[0])+(?:\\.(25|5|75|0)0*)?|6[1])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerAxRightR1 rowType:XLFormRowDescriptorTypeInteger title:@"KER Ax Right Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerAxRightR2 rowType:XLFormRowDescriptorTypeInteger title:@"KER Ax Right Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Left Eye"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR1 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR2 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR3 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Left Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR4 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Left Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSpLeftR5 rowType:XLFormRowDescriptorTypeDecimal title:@"Sphere Left Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -25 to 15" regex:@"(^([0-9]|[1][0-5])$)|(^([0-9]|[1][0-4]).([2,7]5|5)$)|^-([0-9]|[1][0-9]|[2][0-5])$|^-([0-9]|[1][0-9]|[2][0-4]).([2,7]5|5)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR1 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR2 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR3 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Left Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR4 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Left Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCylLeftR5 rowType:XLFormRowDescriptorTypeDecimal title:@"Cyl Left Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Between -9 to 0" regex:@"^([0]|-[9]|(-[0-8]{1})+(?:\\.(25|5|75|0)0*)?)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR1 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR2 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR3 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 3: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR4 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 4: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAxisLeftR5 rowType:XLFormRowDescriptorTypeInteger title:@"Axis Left Eye Reading 5: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerMmLeftR1 rowType:XLFormRowDescriptorTypeDecimal title:@"KER MM Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 5 to 10" regex:@"^((([5-9]{1})+(?:\\.([0-9][0-9])?))|1[0])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerMmLeftR2 rowType:XLFormRowDescriptorTypeDecimal title:@"KER MM Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 5 to 10" regex:@"^((([5-9]{1})+(?:\\.([0-9][0-9])?))|1[0])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerDioLeftR1 rowType:XLFormRowDescriptorTypeDecimal title:@"KER Dio Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 30 to 61" regex:@"^(([3-5][0-9]|6[0])+(?:\\.(25|5|75|0)0*)?|6[1])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerDioLeftR2 rowType:XLFormRowDescriptorTypeDecimal title:@"KER Dio Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 30 to 61" regex:@"^(([3-5][0-9]|6[0])+(?:\\.(25|5|75|0)0*)?|6[1])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerAxLeftR1 rowType:XLFormRowDescriptorTypeInteger title:@"KER Ax Left Eye Reading 1: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kKerAxLeftR2 rowType:XLFormRowDescriptorTypeInteger title:@"KER Ax Left Eye Reading 2: "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 180" regex:@"^([0-9]|[0-9][0-9]|1[0-7][0-9]|180)$"]];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPupilDist rowType:XLFormRowDescriptorTypeNumber title:@"Pupillary Distance: "];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAutorefractorComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initIntraOcularPressure {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Intra-ocular Pressure"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIopDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIopRight rowType:XLFormRowDescriptorTypeInteger title:@"Intra-Ocular Pressure (Right Eye) "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 55" regex:@"^([0-4][0-9]|5[0-5])$"]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIopLeft rowType:XLFormRowDescriptorTypeInteger title:@"Intra-Ocular Pressure (Left Eye) "];
    [self setDefaultFontWithRow:row];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"From 0 to 55" regex:@"^([0-4][0-9]|5[0-5])$"]];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIopComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    return [super initWithForm:formDescriptor];
    
}

- (id) initAntHealthExam {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Anterior Health Exam"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheOd rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"OD:"];
    row.selectorOptions = @[@"Normal", @"Abnormal"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheOdRemark rowType:XLFormRowDescriptorTypeText title:@"OD Remarks: "];
    [self setDefaultFontWithRow:row];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheOs rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"OS:"];
    row.selectorOptions = @[@"Normal", @"Abnormal"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheOsRemark rowType:XLFormRowDescriptorTypeText title:@"OS Remarks: "];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAheComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initPostHealthExam {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Anterior Health Exam"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheDone rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Done?"];
    row.selectorOptions = @[@"Done", @"Not Done", @"Refused"];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheFundusOd rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"Fundus Examination OD:"];
    row.selectorOptions = @[@"Normal", @"Abnormal"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheFundusOdRemark rowType:XLFormRowDescriptorTypeText title:@"Fundus Examination OD Remarks: "];
    [self setDefaultFontWithRow:row];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheFundusOs rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"Fundus Examination OS:"];
    row.selectorOptions = @[@"Normal", @"Abnormal"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheFundusOsRemark rowType:XLFormRowDescriptorTypeText title:@"Fundus Examination OS Remarks: "];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPheComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initDiagAndFollowUp {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Diagnosis and Follow-up"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *diagOdRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagnosisOd rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Diagnosis OD: "];
    diagOdRow.selectorOptions = @[@"Normal", @"Refractive Error", @"Cataract", @"Glaucoma", @"Age-related macular degeneration", @"Diabetic Retinopathy/maculopathy", @"Others"];
    diagOdRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:diagOdRow];
    [section addFormRow:diagOdRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagOdOthers rowType:XLFormRowDescriptorTypeText title:@"Diagnosis OD Others "];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", diagOdRow];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    XLFormRowDescriptor *diagOsRow = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagnosisOs rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Diagnosis OS: "];
    diagOsRow.selectorOptions = @[@"Normal", @"Refractive Error", @"Cataract", @"Glaucoma", @"Age-related macular degeneration", @"Diabetic Retinopathy/maculopathy", @"Others"];
    diagOsRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:diagOsRow];
    [section addFormRow:diagOsRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagOsOthers rowType:XLFormRowDescriptorTypeText title:@"Diagnosis OS Others "];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", diagOsRow];
    [self setDefaultFontWithRow:row];
    [section addFormRow:row];
    
    XLFormRowDescriptor *followUpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFollowUp rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Follow-up:"];
    followUpRow.selectorOptions = @[@"No Followup/Already on followup", @"Referral to eye-specialist", @"Cataract surgery"];
    followUpRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:followUpRow];
    [section addFormRow:followUpRow];
    
    XLFormRowDescriptor *eyeSpecRefRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEyeSpecRef rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"Referral to eye specialist:"];
    eyeSpecRefRow.selectorOptions = @[@"Urgent", @"Non-urgent"];
    eyeSpecRefRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:eyeSpecRefRow];
    eyeSpecRefRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Referral to eye-specialist'", followUpRow];
    [section addFormRow:eyeSpecRefRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNonUrgentRefMths rowType:XLFormRowDescriptorTypeNumber title:@"Non-urgent referral: ___ months"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Non-urgent'", eyeSpecRefRow];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Comments"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDiagComment rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Comments..." forKey:@"textView.placeholder"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
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
            [SVProgressHUD showImage:[[UIImage imageNamed:@"ThumbsUp"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] status:@"Good!"];
    }
    
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

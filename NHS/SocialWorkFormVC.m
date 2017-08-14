//
//  SocialWorkFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/9/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "SocialWorkFormVC.h"
#import "ServerComm.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "ScreeningSectionTableViewController.h"
#import "math.h"

@interface SocialWorkFormVC () {
    XLFormRowDescriptor *relativesContactRow, *relativesEaseRow, *relativesCloseRow, *friendsContactRow, *friendsEaseRow, *friendsCloseRow, *socialScoreRow;
}

@end

@implementation SocialWorkFormVC

- (void)viewDidLoad {
    
    XLFormViewController *form;
    
    //must init first before [super viewDidLoad]
    int formNumber = [_formNo intValue];
    switch (formNumber) {
            //case 0 is for demographics
        case 1:
            form = [self initCurrentSocioSituation];
            break;
        case 2:
            form = [self initCurrentPhysStatus];
            break;
        case 3:
            form = [self initSocialSupportAssessment];
            break;
        case 4:
            form = [self initPsychWellbeing];
            break;
        case 5:
            form = [self initAdditionalSvcs];
            break;
        case 6:
            form = [self initSummary];
            break;
        default:
            break;
    }
    
    [self.form setAssignFirstResponderOnShow:NO];       //disable the feature of Keyboard always auto show.
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id) initCurrentSocioSituation {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Socioeconomic Situation"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    XLFormRowDescriptor *copeFinancialRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCopeFin rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Are you able to cope financially?"];
    copeFinancialRow.selectorOptions = @[@"Yes", @"No"];
    copeFinancialRow.required = YES;
    copeFinancialRow.value = @"Yes";
    copeFinancialRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:copeFinancialRow];
    
    XLFormRowDescriptor *whyNotCopeFinanRow = [XLFormRowDescriptor formRowDescriptorWithTag:kWhyNotCopeFin rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"If not, why?"];
    whyNotCopeFinanRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Medical Expenses"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Housing Rent"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Arrears/Debts"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Daily living expenses (e.g. transport)"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Others"]];
    whyNotCopeFinanRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow];
    [section addFormRow:whyNotCopeFinanRow];
    
    XLFormRowDescriptor *moreWhyNotCopeFinanRow = [XLFormRowDescriptor formRowDescriptorWithTag:kMoreWhyNotCopeFin rowType:XLFormRowDescriptorTypeTextView title:@""];
    [moreWhyNotCopeFinanRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    moreWhyNotCopeFinanRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow];
    [section addFormRow:moreWhyNotCopeFinanRow];
    
    
    
//    copeFinancialRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
//        if (oldValue != newValue) {
//            if ([rowDescriptor.value isEqual:@(1)]) {
//                whyNotCopeFinanRow.hidden = @(1);
//                moreWhyNotCopeFinanRow.hidden = @(1);
//            } else
//                whyNotCopeFinanRow.hidden = @(0);
//                moreWhyNotCopeFinanRow.hidden = @(0);
//        }
//    };
    XLFormRowDescriptor *whatYouHaveRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"what_you_have" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Do you have the following?"];
    whatYouHaveRow.selectorOptions = @[@"Community Health Assist Scheme", @"Pioneer Generation Package", @"Medisave", @"Insurance Coverage", @"CPF Pay Outs"];
    whatYouHaveRow.required = YES;
    [section addFormRow:whatYouHaveRow];
    
    

    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"" rowType:XLFormRowDescriptorTypeInfo title:@"Do you have the following?"];
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHasChas rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Community Health Assist Scheme"];
//    row.required = YES;
//    [row.cellConfig setObject:[UIFont systemFontOfSize:12] forKey:@"textLabel.font"];   //the description too
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHasPgp rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Pioneer Generation Package"];
//    row.required = YES;
//    [row.cellConfig setObject:[UIFont systemFontOfSize:12] forKey:@"textLabel.font"];   //the description too
//    [section addFormRow:row];
//    
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHasMedisave rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Medisave"];
//    row.required = YES;
//    [row.cellConfig setObject:[UIFont systemFontOfSize:12] forKey:@"textLabel.font"];   //the description too
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHasInsure rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Insurance coverage	"];
//    row.required = YES;
//    [row.cellConfig setObject:[UIFont systemFontOfSize:12] forKey:@"textLabel.font"];   //the description too
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHasCpfPayouts rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"CPF Pay Outs"];
//    row.required = YES;
//    [row.cellConfig setObject:[UIFont systemFontOfSize:12] forKey:@"textLabel.font"];   //the description too
//    [section addFormRow:row];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCpfAmt rowType:XLFormRowDescriptorTypeNumber
//                                                  title:@"If yes, Amount:$ "];
//    row.required = YES;
//    [row.cellConfig setObject:[UIFont systemFontOfSize:12] forKey:@"textLabel.font"];   //the description too
//    [section addFormRow:row];
//    
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:section];
//
    XLFormRowDescriptor *cpfAmtRow = [XLFormRowDescriptor formRowDescriptorWithTag:kCpfAmt
                                                                                   rowType:XLFormRowDescriptorTypeNumber
                                                                                     title:@"CPF Payouts amount: $"];
    cpfAmtRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    cpfAmtRow.required = NO;
    cpfAmtRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'CPF Pay Outs'", whatYouHaveRow];
    [section addFormRow:cpfAmtRow];
    
    XLFormRowDescriptor *receiveFinAssistRow = [XLFormRowDescriptor formRowDescriptorWithTag:kReceivingFinAssist rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Are you receiving any form of social/financial assistance?"];
    receiveFinAssistRow.required = YES;
    receiveFinAssistRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:receiveFinAssistRow];
    
    XLFormSectionDescriptor *finanAssistSection = [XLFormSectionDescriptor formSectionWithTitle:@"Financial assistance details"];
    [formDescriptor addFormSection:finanAssistSection];
    finanAssistSection.hidden = @(1); //default hidden
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistName rowType:XLFormRowDescriptorTypeText title:@"Name"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [finanAssistSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistOrg rowType:XLFormRowDescriptorTypeText title:@"Organisation"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [finanAssistSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistAmt rowType:XLFormRowDescriptorTypeText title:@"Amount"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [finanAssistSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistPeriod rowType:XLFormRowDescriptorTypeText title:@"Period"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [finanAssistSection addFormRow:row];

    XLFormRowDescriptor *finAssistEnufRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistEnuf rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Has the assistance rendered been sufficient?"];
    finAssistEnufRow.required = NO;
    finAssistEnufRow.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [finanAssistSection addFormRow:finAssistEnufRow];
    
    XLFormRowDescriptor *finAssistEnufWhyRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFinAssistEnufWhy rowType:XLFormRowDescriptorTypeTextView title:@""];
    finAssistEnufWhyRow.required = NO;
    [finAssistEnufWhyRow.cellConfigAtConfigure setObject:@"Elaboration on sufficiency if assistance" forKey:@"textView.placeholder"];
    finAssistEnufWhyRow.hidden = @(1); //default hidden
    [finanAssistSection addFormRow:finAssistEnufWhyRow];
    
    finAssistEnufRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
        if (oldValue != newValue) {
            if ([rowDescriptor.value isEqual:@(1)]) {
                finAssistEnufWhyRow.hidden = @(0);
            } else {
                finAssistEnufWhyRow.hidden = @(1);
            }
            
        }
    };
    
    receiveFinAssistRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            if ([rowDescriptor.value isEqual:@(1)]) {
                finanAssistSection.hidden = @(0);
            } else
                finanAssistSection.hidden = @(1);
        }
    };
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSocSvcAware rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Are you aware of the social services available in your area?"];
    row.required = NO;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;    //allow it to expand the cell.
    [section addFormRow:row];
    
    
    
    
    
    
    
    return [super initWithForm:formDescriptor];

}

- (id) initCurrentPhysStatus {
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Physical Situation"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Activities of Daily Living"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1"
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"Can you perform the following activities without assistance? (Tick those activities that the resident CAN perform on his/her own)."];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"multiple_ADL" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Activities"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Bathe/Shower"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Dress"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Eat"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Personal Hygiene and Grooming"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Toileting"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Transfer/Walk"]];
//    row.value = [self getADLArrayFromDict:adlDict andOptions:row.selectorOptions];
    row.noValueDisplayText = @"Tap here for options";
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Mobility Status"];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityStatus
                                               rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                                 title:@"Mobility Status"];
    row.selectorOptions = @[@"Ambulant", @"Able to walk with assistance (stick/frame)", @"Wheelchair-bound", @"Bed-ridden"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMobilityEquipment
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:@"Do you require mobility equipment in your household? (e.g. non-slip mat, handle bar, etc)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    
    
    return [super initWithForm:formDescriptor];
    
}

//
//- (id) initCurrentSocioSituation {
//    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Socioeconomic Issues"];
//    XLFormSectionDescriptor * section;
//    XLFormRowDescriptor * row;
//    NSDictionary *currSocioSituationDict = [self.fullScreeningForm objectForKey:@"socioecon"];
//
//    formDescriptor.assignFirstResponderOnShow = YES;
//
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTE"];
//    section.footerTitle = @"Non-medical barriers have to be addressed in order to improve the resident's health. A multi-disciplinary team is required for this section.";
//    [formDescriptor addFormSection:section];
//
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    section.footerTitle = @"If interesed in CHAS, visit Pub Med booth at Triage";
//    [formDescriptor addFormSection:section];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMultiPlan rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Do you have the following?"];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Medisave"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Insurance Coverage"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"CPF pay outs"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Pioneer Generation Package (PGP)"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Community Health Assist Scheme (CHAS)"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"If no, will you like to apply for CHAS?"]];
//    row.value = [self getPlansArrayFromDict:currSocioSituationDict andOptions:row.selectorOptions];
//    [section addFormRow:row];
//
//    // New section
//    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
//    [formDescriptor addFormSection:section];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionOne rowType:XLFormRowDescriptorTypeInfo title:@"If you have CPF pay outs, what is the amount per month?"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCPFAmt rowType:XLFormRowDescriptorTypeNumber title:@"Amount $"];
//    row.value = [currSocioSituationDict objectForKey:kCPFAmt];
//    row.noValueDisplayText = @"Specify here";
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwo rowType:XLFormRowDescriptorTypeInfo title:@"If you have the CHAS card, what colour is it?"];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kChasColour rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@" "];
//    row.selectorOptions = @[@"Blue", @"Orange", @"N.A."];
//    //value
//    if (![[currSocioSituationDict objectForKey:kChasColour]isEqualToString:@""]) {
//        if ([[currSocioSituationDict objectForKey:kChasColour] isEqualToString:@"0"]) row.value = @"Blue";
//        else if ([[currSocioSituationDict objectForKey:kChasColour] isEqualToString:@"1"]) row.value = @"Orange";
//        else if ([[currSocioSituationDict objectForKey:kChasColour] isEqualToString:@"2"]) row.value = @"N.A.";
//    }
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThree rowType:XLFormRowDescriptorTypeInfo title:@"Is your household currently coping in terms of financial expenses? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    XLFormRowDescriptor *financeCopingRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseCoping rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
//    financeCopingRow.selectorOptions = @[@"YES", @"NO"];
//    financeCopingRow.required = YES;
//    //value
//    if (![[currSocioSituationDict objectForKey:kHouseCoping] isEqualToString:@""]) {
//        financeCopingRow.value = [[currSocioSituationDict objectForKey:kHouseCoping] isEqualToString:@"1"]? @"YES":@"NO";
//    }
//    [section addFormRow:financeCopingRow];
//
//    XLFormRowDescriptor *notCopingReasonRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseCopingReason rowType:XLFormRowDescriptorTypeMultipleSelector title:@"If no, why?"];
//    notCopingReasonRow.selectorOptions = @[@"Medical expenses", @"Daily living expenses", @"Arrears / Debts", @"Others"];
//    notCopingReasonRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", financeCopingRow];
//
//    //value
//    notCopingReasonRow.value = [self getCantCopeArrayFromDict:currSocioSituationDict andOptions:notCopingReasonRow.selectorOptions];
//
//    [section addFormRow:notCopingReasonRow];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseCopingReasonOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
//    [row.cellConfigAtConfigure setObject:@"Other reason" forKey:@"textField.placeholder"];
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", notCopingReasonRow];
//    row.value = [currSocioSituationDict objectForKey:kHouseCopingReasonOthers];
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFour rowType:XLFormRowDescriptorTypeInfo title:@"What is your employment status? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    XLFormRowDescriptor *EmployStatusRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStatus rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
//    EmployStatusRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Full time employed"],
//                                           [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Part time employed"],
//                                           [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Unemployed due to disability"],
//                                           [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Unemployed but able to work"],
//                                           [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Housewife/Homemaker"],
//                                           [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Retiree"],
//                                           [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"Student"],
//                                           [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"Others"]];
//    EmployStatusRow.required = YES;
//    //value
//    NSArray *options = EmployStatusRow.selectorOptions;
//    if (![[currSocioSituationDict objectForKey:kEmployStatus] isEqualToString:@""]) {
//        int index = [[currSocioSituationDict objectForKey:kEmployStatus] intValue];
//        EmployStatusRow.value = [options objectAtIndex:index];
//    }
//    [section addFormRow:EmployStatusRow];
//
//    XLFormRowDescriptor *employStatusOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEmployStatusOthers rowType:XLFormRowDescriptorTypeText title:@"Others"];
//    [employStatusOthersRow.cellConfigAtConfigure setObject:@"Please specify" forKey:@"textField.placeholder"];
//    employStatusOthersRow.value = [currSocioSituationDict objectForKey:kEmployStatusOthers];
//
//    [section addFormRow:employStatusOthersRow];
//
//    //Initial hidden state
//    if(![[currSocioSituationDict objectForKey:kEmployStatusOthers] isEqualToString:@""]) {
//        if ([[EmployStatusRow.value formValue] isEqual:@(7)]) {
//            employStatusOthersRow.hidden = @(0);
//        } else {
//            employStatusOthersRow.hidden = @(1);
//        }
//    } else {
//        employStatusOthersRow.hidden = @(1);
//    }
//
//    EmployStatusRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor){
//        if (oldValue != newValue) {
//            if ([[newValue formValue] isEqual:@(7)]) {
//                employStatusOthersRow.hidden = @(0);  //show
//            } else {
//                employStatusOthersRow.hidden = @(1);  //hide
//            }
//        }
//    };
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFive rowType:XLFormRowDescriptorTypeInfo title:@"If unemployed, how does resident manage his/her expenses?"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kManageExpenses rowType:XLFormRowDescriptorTypeTextView title:@""];
//    [row.cellConfigAtConfigure setObject:@"(max 2 lines)" forKey:@"textView.placeholder"];
//    //value
//    row.value = [currSocioSituationDict objectForKey:kManageExpenses];
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSix rowType:XLFormRowDescriptorTypeInfo title:@"What is your average monthly household income? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHouseholdIncome rowType:XLFormRowDescriptorTypeInteger title:@"$"];
//    //value
//    row.value = [currSocioSituationDict objectForKey:kHouseholdIncome];
//    row.required = YES;
//    row.noValueDisplayText = @"Specify here";
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionSeven rowType:XLFormRowDescriptorTypeInfo title:@"How many people are there in your household? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPplInHouse rowType:XLFormRowDescriptorTypeNumber title:@"No. of person(s):"];
//    row.required = YES;
//
//    //value
//    row.value = [currSocioSituationDict objectForKey:kPplInHouse];
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEight rowType:XLFormRowDescriptorTypeInfo title:@"Is your household receiving or has received any form of social or financial assistance?"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    XLFormRowDescriptor *financeAssist = [XLFormRowDescriptor formRowDescriptorWithTag:kAnyAssist rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
//    financeAssist.selectorOptions = @[@"YES", @"NO"];
//    //value
//    if (![[currSocioSituationDict objectForKey:kAnyAssist] isEqualToString:@""]) {
//        financeAssist.value = [[currSocioSituationDict objectForKey:kAnyAssist] isEqualToString:@"1"]? @"YES":@"NO";
//    }
//    [section addFormRow:financeAssist];
//
//    XLFormRowDescriptor *qSeekHelpRow = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionNine rowType:XLFormRowDescriptorTypeInfo title:@"If no, do you know who to approach if you need help? (e.g. financial, social services)"];
//    qSeekHelpRow.cellConfig[@"textLabel.numberOfLines"] = @0;
//    qSeekHelpRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", financeAssist];
//    [section addFormRow:qSeekHelpRow];
//    XLFormRowDescriptor *seekHelpSegmentRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSeekHelp rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
//    seekHelpSegmentRow.selectorOptions = @[@"YES", @"NO"];
//    seekHelpSegmentRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", financeAssist];
//
//    //value
//    if (![[currSocioSituationDict objectForKey:kSeekHelp] isEqualToString:@""]) {
//        seekHelpSegmentRow.value = [[currSocioSituationDict objectForKey:kSeekHelp] isEqualToString:@"1"]? @"YES":@"NO";
//    }
//
//    [section addFormRow:seekHelpSegmentRow];
//
////    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTen rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Details of financial/social assistance received  - Type )"];
////    row.cellConfig[@"textLabel.numberOfLines"] = @0;
////    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
////    [section addFormRow:row];
////    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpType rowType:XLFormRowDescriptorTypeText title:@""];
////    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
////    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionEleven rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Details of financial/social assistance received  - Organisation )"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpOrg rowType:XLFormRowDescriptorTypeText title:@""];
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//
//    //value
//    row.value = [currSocioSituationDict objectForKey:kHelpOrg];
//    row.noValueDisplayText = @"Specify the details";
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionTwelve rowType:XLFormRowDescriptorTypeInfo title:@"If yes, help rendered:"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpDescribe rowType:XLFormRowDescriptorTypeTextView title:@""];
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [row.cellConfigAtConfigure setObject:@"Describe the help you received..." forKey:@"textView.placeholder"];
//    row.value = [currSocioSituationDict objectForKey:kHelpDescribe];
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionThirteen rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Details of financial/social assistance received - Amount per month (if applicable)"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpAmt rowType:XLFormRowDescriptorTypeInteger title:@""];
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    row.value = [currSocioSituationDict objectForKey:kHelpAmt];
//    row.noValueDisplayText = @"Specify the amount";
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFourteen rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Details of financial/social assistance received - Period"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpPeriod rowType:XLFormRowDescriptorTypeText title:@""];
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [row.cellConfigAtConfigure setObject:@"Specify the period here" forKey:@"textField.placeholder"];
//    //value
//    row.value = [currSocioSituationDict objectForKey:kHelpPeriod];
//
//    [section addFormRow:row];
//
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kQuestionFifteen rowType:XLFormRowDescriptorTypeInfo title:@"If yes, has the assistance rendered been helpful? (elaboration in Annex A)"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHelpHelpful rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
//    row.selectorOptions = @[@"YES", @"NO"];
//    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", financeAssist];
//
//    //value
//    if (![[currSocioSituationDict objectForKey:kHelpHelpful] isEqualToString:@""]) {
//        row.value = [[currSocioSituationDict objectForKey:kHelpHelpful] isEqualToString:@"1"]? @"YES":@"NO";
//    }
//
//    [section addFormRow:row];
//
//    return [super initWithForm:formDescriptor];
//}
//
- (id) initSocialSupportAssessment {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Social Support Assessment"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
//    NSDictionary *socialSuppAssessmentDict = [self.fullScreeningForm objectForKey:@"social_support"];

    formDescriptor.assignFirstResponderOnShow = YES;


    section = [XLFormSectionDescriptor formSectionWithTitle:@"NOTE"];
    section.footerTitle = @"Non-medical barriers have to be addressed in order to improve the resident's health. A multi-disciplinary team is required for this section.";
    [formDescriptor addFormSection:section];

    XLFormSectionDescriptor *hasPriCaregiversection = [XLFormSectionDescriptor formSectionWithTitle:@"Social Network"];
    [formDescriptor addFormSection:hasPriCaregiversection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Do you have a Primary Caregiver?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [hasPriCaregiversection addFormRow:row];

    XLFormRowDescriptor *hasCaregiverRow = [XLFormRowDescriptor formRowDescriptorWithTag:kHasCaregiver rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasCaregiverRow.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[socialSuppAssessmentDict objectForKey:kHasCaregiver] isEqualToString:@""]) {
//        hasCaregiverRow.value = [[socialSuppAssessmentDict objectForKey:kHasCaregiver] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    [hasPriCaregiversection addFormRow:hasCaregiverRow];

    XLFormSectionDescriptor *careGiverSection = [XLFormSectionDescriptor formSectionWithTitle:@"Caregiver Details"];
    careGiverSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasCaregiverRow];
    [formDescriptor addFormSection:careGiverSection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverName rowType:XLFormRowDescriptorTypeName title:@"Name"];
//    row.value = [socialSuppAssessmentDict objectForKey:kCaregiverName];
    [careGiverSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverRs rowType:XLFormRowDescriptorTypeText title:@"Relationship"];
//    row.value = [socialSuppAssessmentDict objectForKey:kCaregiverRs];
    [careGiverSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregiverContactNum rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
//    row.value = [socialSuppAssessmentDict objectForKey:kCaregiverContactNum];
    [careGiverSection addFormRow:row];

    XLFormSectionDescriptor *askEmerContactSection = [XLFormSectionDescriptor formSectionWithTitle:@""];
    askEmerContactSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'NO'", hasCaregiverRow];
    [formDescriptor addFormSection:askEmerContactSection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q2" rowType:XLFormRowDescriptorTypeInfo title:@"Do you have any emergency contact person?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [askEmerContactSection addFormRow:row];
    XLFormRowDescriptor *hasEmerContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEContact rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasEmerContactRow.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[socialSuppAssessmentDict objectForKey:kEContact] isEqualToString:@""]) {
//        hasEmerContactRow.value = [[socialSuppAssessmentDict objectForKey:kEContact] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    [askEmerContactSection addFormRow:hasEmerContactRow];

    XLFormSectionDescriptor *EmerContactSection = [XLFormSectionDescriptor formSectionWithTitle:@"Emergency Contact"];
    EmerContactSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasEmerContactRow];
    [formDescriptor addFormSection:EmerContactSection];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactName rowType:XLFormRowDescriptorTypeName title:@"Name"];
//    row.value = [socialSuppAssessmentDict objectForKey:kEContactName];
    [EmerContactSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactRs rowType:XLFormRowDescriptorTypeText title:@"Relationship"];
//    row.value = [socialSuppAssessmentDict objectForKey:kEContactRs];
    [EmerContactSection addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEContactNum rowType:XLFormRowDescriptorTypePhone title:@"Contact Number"];
//    row.value = [socialSuppAssessmentDict objectForKey:kEContactNum];
    [EmerContactSection addFormRow:row];
    
    //Are you a caregiver?
    XLFormSectionDescriptor *hasCaregivingSection = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:hasCaregivingSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q3" rowType:XLFormRowDescriptorTypeInfo title:@"Are you a caregiver for somebody else?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [hasCaregivingSection addFormRow:row];
    
    XLFormRowDescriptor *hasCaregivingRow = [XLFormRowDescriptor formRowDescriptorWithTag:kUCaregiver rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    hasCaregivingRow.selectorOptions = @[@"YES", @"NO"];
    hasCaregivingRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    
    [hasCaregivingSection addFormRow:hasCaregivingRow];
    
    //Details of being a caregiver
    XLFormSectionDescriptor *caregivingSection = [XLFormSectionDescriptor formSectionWithTitle:@"Caregiving Details"];
    
    caregivingSection.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", hasCaregivingRow];
    [formDescriptor addFormSection:caregivingSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUCareStress rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Are you facing caregiver stress?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    //    row.value = [socialSuppAssessmentDict objectForKey:kEContactName];
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q4" rowType:XLFormRowDescriptorTypeInfo title:@"Describe your caregiving responsibilities (e.g. frequency, caregiving tasks)"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingDescribe rowType:XLFormRowDescriptorTypeTextView title:@""];
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingAssist rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Would you like to receive caregiving assistance?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q5" rowType:XLFormRowDescriptorTypeInfo title:@"If yes, Type of assistance preferred:"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [caregivingSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaregivingAssistType rowType:XLFormRowDescriptorTypeTextView title:@""];
    [caregivingSection addFormRow:row];

    
    
    //SUPPORT
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Social Network - Support"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q3" rowType:XLFormRowDescriptorTypeInfo title:@"Are you getting support from your family/relatives/friends?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    XLFormRowDescriptor *getSupportRow = [XLFormRowDescriptor formRowDescriptorWithTag:kGettingSupport rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    getSupportRow.selectorOptions = @[@"YES", @"NO"];

    //value
//    if (![[socialSuppAssessmentDict objectForKey:kGettingSupport] isEqualToString:@""]) {
//        getSupportRow.value = [[socialSuppAssessmentDict objectForKey:kGettingSupport] isEqualToString:@"1"]? @"YES":@"NO";
//    }

    [section addFormRow:getSupportRow];

    XLFormRowDescriptor *multiSupportRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_support" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Support in terms of:"];
    multiSupportRow.hidden =[NSString stringWithFormat:@"NOT $%@.value contains 'YES'", getSupportRow];
    multiSupportRow.selectorOptions = @[@"Care-giving", @"Food", @"Money", @"Others"];

    //value
//    multiSupportRow.value = [self getSupportArrayFromDict:socialSuppAssessmentDict andOptions:multiSupportRow.selectorOptions];
    [section addFormRow:multiSupportRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"support_others" rowType:XLFormRowDescriptorTypeText title:@"Others"];
    [row.cellConfigAtConfigure setObject:@"Specify here" forKey:@"textField.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiSupportRow];
//    row.value = [socialSuppAssessmentDict objectForKey:kSupportOthers];
    [section addFormRow:row];

    section = [XLFormSectionDescriptor formSectionWithTitle:@"MEASURING RISK OF SOCIAL ISOLATION"];
    [formDescriptor addFormSection:section];

    //RELATIVES
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Relatives"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q4" rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you see or hear from at least once a month? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    
    relativesContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesContact rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    relativesContactRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    relativesContactRow.required = YES;

    //value
    NSArray *options = relativesContactRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kRelativesContact] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kRelativesContact] intValue];
//        relativesContactRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:relativesContactRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q5" rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you feel at ease with that you can talk about private matters? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];

    relativesEaseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesEase rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    relativesEaseRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    relativesEaseRow.required = YES;

    //value
    options = relativesEaseRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kRelativesEase] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kRelativesEase] intValue];
//        relativesEaseRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:relativesEaseRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q6" rowType:XLFormRowDescriptorTypeInfo title:@"How many relatives do you feel close to such that you could call on them for help? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    relativesCloseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRelativesClose rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    relativesCloseRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    relativesCloseRow.required = YES;

    //value
    options = relativesCloseRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kRelativesClose] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kRelativesClose] intValue];
//        relativesCloseRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:relativesCloseRow];


    //FRIENDS
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Friends"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q7" rowType:XLFormRowDescriptorTypeInfo title:@"How many friends do you see or hear from at least once a month? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsContactRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsContact rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsContactRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    friendsContactRow.required = YES;

    //value
    options = friendsContactRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kFriendsContact] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kFriendsContact] intValue];
//        friendsContactRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:friendsContactRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q8" rowType:XLFormRowDescriptorTypeInfo title:@"How many friends do you feel at ease with that you can talk about private matters? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsEaseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsEase rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsEaseRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    friendsEaseRow.required = YES;

    //value
    options = friendsEaseRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kFriendsEase] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kFriendsEase] intValue];
//        friendsEaseRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:friendsEaseRow];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q9" rowType:XLFormRowDescriptorTypeInfo title:@"How many of your friends do you feel close to such that you could call on them for help? *"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    friendsCloseRow = [XLFormRowDescriptor formRowDescriptorWithTag:kFriendsClose rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
    friendsCloseRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"None"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"One"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Two"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Three-Four"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Five-Eight"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Nine or more"]];
    friendsCloseRow.required = YES;

    //value
    options = friendsCloseRow.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kFriendsClose] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kFriendsClose] intValue];
//        friendsCloseRow.value = [options objectAtIndex:index];
//    }

    [section addFormRow:friendsCloseRow];

    //SOCIAL SCORE
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Social Score"];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"kComputeScoreButton" rowType:XLFormRowDescriptorTypeButton title:@"Compute Score"];
    row.action.formSelector = @selector(computeScoreButton:);
    [section addFormRow:row];

    socialScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSocialScore rowType:XLFormRowDescriptorTypeText title:@"Computed Social Score"];
    socialScoreRow.disabled = @(1);
    socialScoreRow.cellConfig[@"textLabel.textColor"] = [UIColor blackColor];
    socialScoreRow.cellConfig[@"textField.textColor"] = [UIColor blueColor];
    [socialScoreRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
//    if (![[socialSuppAssessmentDict objectForKey:kSocialScore] isEqualToString:@""]) {
//        socialScoreRow.value = [socialSuppAssessmentDict objectForKey:kSocialScore];
//    } else {
//        socialScoreRow.value = @"";
//    }

    [section addFormRow:socialScoreRow];

    //MEASURING LONELINESS
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"Measuring Loneliness"];
//    [formDescriptor addFormSection:section];

//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q10" rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel lack of companionship? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kLackCompan rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Hardly Ever"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Sometimes"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Often"]];
//    row.required = YES;

    //value
//    options = row.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kLackCompan] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kLackCompan] intValue];
//        row.value = [options objectAtIndex:index];
//    }

//    [section addFormRow:row];

//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q11" rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel left out? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelLeftOut rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Hardly Ever"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Sometimes"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Often"]];
//    row.required = YES;

    //value
//    options = row.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kFeelLeftOut] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kFeelLeftOut] intValue];
//        row.value = [options objectAtIndex:index];
//    }

//    [section addFormRow:row];

//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q12" rowType:XLFormRowDescriptorTypeInfo title:@"How often do you feel isolated from others? *"];
//    row.cellConfig[@"textLabel.numberOfLines"] = @0;
//    [section addFormRow:row];
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFeelIsolated rowType:XLFormRowDescriptorTypeSelectorPush title:@""];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Hardly Ever"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Sometimes"],
//                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Often"]];
//    row.required = YES;

    //value
//    options = row.selectorOptions;
//    if (![[socialSuppAssessmentDict objectForKey:kFeelIsolated] isEqualToString:@""]) {
//        int index = [[socialSuppAssessmentDict objectForKey:kFeelIsolated] intValue];
//        row.value = [options objectAtIndex:index];
//    }
//
//    [section addFormRow:row];

    //Last part
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q14" rowType:XLFormRowDescriptorTypeInfo title:@"Do you participate in any community activities?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *gotCommActivitiesRow = [XLFormRowDescriptor formRowDescriptorWithTag:kParticipateActivities rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
    gotCommActivitiesRow.selectorOptions = @[@"YES", @"NO"];
    

    //value
//    if (![[socialSuppAssessmentDict objectForKey:kParticipateActivities] isEqualToString:@""]) {
//        row.value = [[socialSuppAssessmentDict objectForKey:kParticipateActivities] isEqualToString:@"1"]? @"YES":@"NO";
//    }
    [section addFormRow:gotCommActivitiesRow];
    

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"q15" rowType:XLFormRowDescriptorTypeInfo title:@"If yes, where do you participate in such activities?"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", gotCommActivitiesRow];
    [section addFormRow:row];
    
    XLFormRowDescriptor *multiOrgActivitiesRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_host" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    multiOrgActivitiesRow.selectorOptions = @[@"Senior Activity Centre (SAC)", @"Family Services Centre (FSC)", @"Community Centre (CC)", @"Residents' Committee (RC)", @"Religious Organisations", @"Self-organised", @"Others", @"N.A."];
    multiOrgActivitiesRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'YES'", gotCommActivitiesRow];

    //value
//    multiOrgActivitiesRow.value = [self getOrgArrayFromDict:socialSuppAssessmentDict andOptions:multiOrgActivitiesRow.selectorOptions];

    [section addFormRow:multiOrgActivitiesRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHostOthers rowType:XLFormRowDescriptorTypeText title:@"Others: "];
    row.required = NO;
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiOrgActivitiesRow];
    //    row.value = [socialSuppAssessmentDict objectForKey:@"others_text"];
    [section addFormRow:row];
    
    
    
    XLFormRowDescriptor *multiNoCommActivRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"multi_why_not_comm_activities" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"If no, why not?"];
    multiNoCommActivRow.selectorOptions = @[@"Don't know", @"Don't like", @"Mobility Issues", @"Others"];
    multiNoCommActivRow.hidden = @YES;
    gotCommActivitiesRow.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (newValue != oldValue) {
            if ([newValue isEqualToString:@"YES"])
                multiNoCommActivRow.hidden = @YES;
            else
                multiNoCommActivRow.hidden = @NO;
        }
    };
    [section addFormRow:multiNoCommActivRow];
    
    XLFormRowDescriptor *NoCommActivOthersRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"why_not_comm_activities_others" rowType:XLFormRowDescriptorTypeTextView title:@"Others:"];
    [NoCommActivOthersRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    NoCommActivOthersRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Others'", multiNoCommActivRow];
    
    [section addFormRow:NoCommActivOthersRow];

    

    // Just to avoid keyboard covering the row in the ScrollView
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];


    return [super initWithForm:formDescriptor];
}

- (id) initPsychWellbeing {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Psychological Well-being"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Psychotic Disorder"];
    [formDescriptor addFormSection:section];

    
    XLFormRowDescriptor *symptomPsychRow = [XLFormRowDescriptor formRowDescriptorWithTag:kIsPsychotic rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does the resident exhibit symptoms of psychotic disorders (i.e. bipolar disorder, schizophrenia)?"];
    symptomPsychRow.required = YES;
    symptomPsychRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:symptomPsychRow];
    
    XLFormRowDescriptor *psychRemarksRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPsychoticRemarks rowType:XLFormRowDescriptorTypeTextView title:@""];
    [psychRemarksRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    psychRemarksRow.hidden = @YES;
//    moreWhyNotCopeFinanRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow];
    [section addFormRow:psychRemarksRow];
    
    symptomPsychRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            if ([newValue  isEqual: @1]) {
                psychRemarksRow.hidden = @NO;
            } else
                psychRemarksRow.hidden = @YES;
        }
    };
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Suicidal Ideations"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *suicideIdeasRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSuicideIdeas rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Does the resident have/had suicide ideations?"];
    suicideIdeasRow.required = YES;
    suicideIdeasRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:suicideIdeasRow];
    
    XLFormRowDescriptor *suicideIdeasRemarksRow = [XLFormRowDescriptor formRowDescriptorWithTag:kSuicideIdeasRemarks rowType:XLFormRowDescriptorTypeTextView title:@""];
    [suicideIdeasRemarksRow.cellConfigAtConfigure setObject:@"Please elaborate more..." forKey:@"textView.placeholder"];
    suicideIdeasRemarksRow.hidden = @YES;
    //    moreWhyNotCopeFinanRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow];
    [section addFormRow:suicideIdeasRemarksRow];
    
    suicideIdeasRow.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        if (oldValue != newValue) {
            if ([newValue  isEqual: @1]) {
                suicideIdeasRemarksRow.hidden = @NO;
            } else
                suicideIdeasRemarksRow.hidden = @YES;
        }
    };
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initAdditionalSvcs {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Current Socioeconomic Situation"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBedbug rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Household is suspected/at risk of bedbug infection"];
    row.required = YES;
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    XLFormRowDescriptor *bedbugProofRow = [XLFormRowDescriptor formRowDescriptorWithTag:kBedbugOthers rowType:XLFormRowDescriptorTypeMultipleSelector title:@"If yes, select from this checklist:"];
    bedbugProofRow.selectorOptions = @[@"Dried scars on body",
                                       @"Hoarding behavior",
                                       @"Itchy bites on skin",
                                       @"Poor personal hygiene",
                                       @"Bedbug blood stains on furniture/floor",
                                       @"Others (specify in next field)"
                                       ];
    bedbugProofRow.required = YES;
    [section addFormRow:bedbugProofRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBedbugOthersText rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Specify here" forKey:@"textView.placeholder"];
    //    moreWhyNotCopeFinanRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"bedbug_other_svs" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Services required:"];
    row.selectorOptions = @[@"1. Bedbug eradication services",
                            @"2. Decluttering services"
                            ];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
    
}

- (id) initSummary {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Summary"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Problems"];
    [formDescriptor addFormSection:section];
    
    XLFormRowDescriptor *infoRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"q1" rowType:XLFormRowDescriptorTypeInfo title:@"Presenting Problems"];
    infoRow.required = NO;
    [section addFormRow:infoRow];
    
    XLFormRowDescriptor *problemsRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"summary_problems" rowType:XLFormRowDescriptorTypeMultipleSelector title:@""];
    problemsRow.selectorOptions = @[@"Financial",
                            @"ElderCare",
                            @"BASIC/Childcare",
                            @"Behavioural/Emotional",
                            @"Family/Marital",
                            @"Employment",
                            @"Legal",
                            @"Other services (Bedbugs, Mobility)",
                            @"Accommodation (e.g. tenant issues, housing matters)",
                            @"Other Issues"];
    problemsRow.noValueDisplayText = @"Tap here for options";
    problemsRow.required = YES;
    [section addFormRow:problemsRow];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kProblems rowType:XLFormRowDescriptorTypeTextView title:@""];
    [row.cellConfigAtConfigure setObject:@"Elaborate on the presenting problems" forKey:@"textView.placeholder"];
    row.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'Other Issues'", problemsRow];
    //    moreWhyNotCopeFinanRow.hidden = [NSString stringWithFormat:@"NOT $%@.value contains 'No'", copeFinancialRow];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Category"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCaseCat rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Follow-up case category"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"R1"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"R2"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"R3"],
                                           [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"R4"],
                                           ];
    [section addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Volunteer Details"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwVolName rowType:XLFormRowDescriptorTypeName title:@"Volunteer Name"];
    row.required = YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSwVolContactNum rowType:XLFormRowDescriptorTypePhone title:@"Volunteer Contact No"];
    row.required = YES;
    [section addFormRow:row];
    
    
    return [super initWithForm:formDescriptor];
}


#pragma mark - Button methods
- (void) computeScoreButton: (XLFormRowDescriptor *)sender {
    NSInteger score = [[relativesContactRow.value formValue] integerValue] + [[relativesEaseRow.value formValue] integerValue] + [[relativesCloseRow.value formValue] integerValue] + [[friendsContactRow.value formValue] integerValue] + [[friendsEaseRow.value formValue] integerValue] + [[friendsCloseRow.value formValue] integerValue];
    
    socialScoreRow.value = [NSString stringWithFormat:@"%ld", (long)score];
    [self updateFormRow:socialScoreRow];
    
    [self deselectFormRow:sender];
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

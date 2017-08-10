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

@interface SocialWorkFormVC ()

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
//        case 2:
//            form = [self initHypertension];
//            break;
//        case 3:
//            form = [self initGeriatricDepreAssess];
//            break;
//        case 4:
//            form = [self initRiskStratifaction];
//            break;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

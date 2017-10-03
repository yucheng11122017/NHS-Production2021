//
//  HealthEduFormVC.m
//  NHS
//
//  Created by Nicholas Wong on 9/27/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "HealthEduFormVC.h"
#import "ServerComm.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "KAStatusBar.h"
#import "AppConstants.h"
#import "math.h"
#import "ScreeningDictionary.h"

//XLForms stuffs
#import "XLForm.h"


typedef enum rowTypes {
    Text,
    YesNo,
    TextView,
    Checkbox,
    SelectorPush,
    SelectorActionSheet,
    SegmentedControl,
    Number,
    Switch,
    YesNoNA
} rowTypes;

@interface HealthEduFormVC () {
    XLFormRowDescriptor *postScreenEdScoreRow;
    XLFormSectionDescriptor *postScreenEdSection;
    BOOL isFormFinalized, tableDidEndEditing, internetDCed;
}

@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) NSMutableDictionary *fullScreeningForm;

@end

@implementation HealthEduFormVC

- (void)viewDidLoad {
    
    isFormFinalized = false;    //by default
    XLFormViewController *form;
    
    _pushPopTaskArray = [[NSMutableArray alloc] init];
    _fullScreeningForm = [[NSMutableDictionary alloc] initWithDictionary:[[[ScreeningDictionary sharedInstance] dictionary] mutableCopy]];
    
    internetDCed = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:REMOTE_HOST_NAME];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    form = [self initHealthEducation];
    
    tableDidEndEditing = false;
    self.form.addAsteriskToRequiredRowsTitle = YES;
    
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillDisappear:(BOOL)animated {
    //    [self saveEntriesIntoDictionary];
    [KAStatusBar dismiss];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    [super viewWillDisappear:animated];
    
}

- (id) initHealthEducation {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Health Education"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSDictionary *preEduDict = [_fullScreeningForm objectForKey:SECTION_POST_HEALTH_SCREEN];
    
    NSDictionary *checkDict = _fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckEdPostScreen];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    
    
    postScreenEdSection = [XLFormSectionDescriptor formSectionWithTitle:@"Post-Screening Knowledge Quiz"];
    [formDescriptor addFormSection:postScreenEdSection];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu1 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"1. A person always knows when they have heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu1]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu2 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"2. If you have a family history of heart disease, you are at risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu2]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu3 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"3. The older a person is, the greater their risk of having heart disease "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu3]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu4 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"4. Smoking is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu4]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu5 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"5. A person who stops smoking will lower their risk of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu5]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu6 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"6. High blood pressure is a risk factor for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu6]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu7 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"7. Keeping blood pressure under control will reduce a person’s risk for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu7]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu8 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"8. High cholesterol is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu8]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu9 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"9. Eating fatty foods does not affect blood cholesterol levels"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu9]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu10 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"10. If your ‘good’ cholesterol (HDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu10]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu11 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"11. If your ‘bad’ cholesterol (LDL) is high you are at risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu11]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu12 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"12. Being overweight increases a person’s risk for heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu12]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu13 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"13. Regular physical activity will lower a person’s chance of getting heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu13]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu14 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"14. Only exercising at a gym or in an exercise class will lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu14]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu15 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"15. Walking is considered exercise that will help lower a person’s chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu15]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu16 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"16. Diabetes is a risk factor for developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu16]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu17 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"17. High blood sugar puts a strain on the heart"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu17]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu18 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"18. If your blood sugar is high over several months it can cause your cholesterol level to go up and increase your risk of heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu18]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu19 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"19. A person who has diabetes can reduce their risk of developing heart disease if they keep their blood sugar levels under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu19]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu20 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"20. People with diabetes rarely have high cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu20]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu21 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"21. If a person has diabetes, keeping their cholesterol under control will help to lower their chance of developing heart disease"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu21]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu22 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"22. People with diabetes tend to have low HDL (good) cholesterol"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu22]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu23 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"23. A person who has diabetes can reduce their risk of developing heart disease if they keep their blood pressure under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu23]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu24 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"24. A person who has diabetes can reduce their risk of developing heart disease if they keep their weight under control"];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu24]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdu25 rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"25. Men with diabetes have a higher risk of heart disease than women with diabetes "];
    row.selectorOptions = @[@"True", @"False"];
    row.cellConfig[@"textLabel.numberOfLines"] = @0;
    [self setDefaultFontWithRow:row];
    row.required = YES;
    if (preEduDict != (id)[NSNull null]) row.value = [self getTFfromOneZero:preEduDict[kEdu25]];
    [postScreenEdSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"postScreenHealthEdScore" rowType:XLFormRowDescriptorTypeButton title:@"Calculate Health Education Score"];
    row.action.formSelector = @selector(calculateScore:);
    
    [postScreenEdSection addFormRow:row];
    
    postScreenEdScoreRow = [XLFormRowDescriptor formRowDescriptorWithTag:kPostScreenEdScore rowType:XLFormRowDescriptorTypeInteger title:@"Health Education Score"];
    postScreenEdScoreRow.cellConfig[@"textLabel.numberOfLines"] = @0;
    postScreenEdScoreRow.noValueDisplayText = @"-/-";
    postScreenEdScoreRow.disabled = @YES;
    [self setDefaultFontWithRow:postScreenEdScoreRow];
    postScreenEdScoreRow.required = YES;
    if (preEduDict != (id)[NSNull null]) postScreenEdScoreRow.value = preEduDict[kPostScreenEdScore];
    [postScreenEdSection addFormRow:postScreenEdScoreRow];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [formDescriptor addFormSection:section];
    
    return [super initWithForm:formDescriptor];
}


- (void) calculateScore: (XLFormRowDescriptor *)sender {
    
    NSDictionary *dict = [self.form formValues];
    int score, eachAns;
    NSString *ans;
    
    score = 0;
    
    NSDictionary *correctPreAnswers = @{kPostScreenEdu1:@"False",//1
                                        kPostScreenEdu2:@"True", //2
                                        kPostScreenEdu3:@"True", //3
                                        kPostScreenEdu4: @"True", //4
                                        kPostScreenEdu5: @"True", //5
                                        kPostScreenEdu6: @"True", //6
                                        kPostScreenEdu7: @"True", //7
                                        kPostScreenEdu8: @"True", //8
                                        kPostScreenEdu9:@"False",//9
                                        kPostScreenEdu10:@"False",//10
                                        kPostScreenEdu11:@"True", //11
                                        kPostScreenEdu12:@"True", //12
                                        kPostScreenEdu13:@"True", //13
                                        kPostScreenEdu14:@"False",//14
                                        kPostScreenEdu15:@"True", //15
                                        kPostScreenEdu16:@"True", //16
                                        kPostScreenEdu17:@"True", //17
                                        kPostScreenEdu18:@"True", //18
                                        kPostScreenEdu19:@"True", //19
                                        kPostScreenEdu20:@"False",//20
                                        kPostScreenEdu21:@"True", //21
                                        kPostScreenEdu22:@"True", //22
                                        kPostScreenEdu23:@"True", //23
                                        kPostScreenEdu24:@"True", //24
                                        kPostScreenEdu25:@"False" //25
                                        };
        
    for (NSString *key in dict) {
        if (![key isEqualToString:kPostScreenEdScore] && ![key isEqualToString:@"postScreenHealthEdScore"]) {
            //prevent null cases
            if (dict[key] != [NSNull null]) {//only take non-null values;
                ans = dict[key];
                
                if ([ans isEqualToString:correctPreAnswers[key]]) {
                    eachAns = 1;
                } else
                    eachAns = 0;
                
                score = score + eachAns;
                ans = @"";
            }
        }
    }
        
    postScreenEdScoreRow.value = [NSString stringWithFormat:@"%d", score];
    [self reloadFormRow:postScreenEdScoreRow];
    
    
    [self deselectFormRow:sender];
    
}

- (NSString *) getTFfromOneZero: (id) value {
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"1"]) {
            return @"True";
        } else {
            return @"False";
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if ([value isEqual:@1]) {
            return @"True";
        } else {
            return @"False";
        }
    }
    return @"";
}


#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    NSString* ansFromTF;
    if (newValue != (id)[NSNull null] && [newValue isKindOfClass:[NSString class]]) {
        if ([newValue isEqualToString:@"True"])
            ansFromTF = @"1";
        else if ([newValue isEqualToString:@"False"])
            ansFromTF = @"0";
    }

    /* Post-Screening Education */
    if ([rowDescriptor.tag isEqualToString:kPostScreenEdu1]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu1 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu2]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu2 andNewContent:ansFromTF];
    }else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu3]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu3 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu4]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu4 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu5]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu5 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu6]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu6 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu7]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu7 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu8]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu8 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu9]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu9 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu10]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu10 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu11]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu11 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu12]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu12 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu13]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu13 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu14]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu14 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu15]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu15 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu16]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu16 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu17]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu17 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu18]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu18 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu19]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu19 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu20]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu20 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu21]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu21 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu22]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu22 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu23]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu23 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu24]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu24 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdu25]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kEdu25 andNewContent:ansFromTF];
    } else if ([rowDescriptor.tag isEqualToString:kPostScreenEdScore]) {
        [self postSingleFieldWithSection:SECTION_POST_HEALTH_SCREEN andFieldName:kPostScreenEdScore andNewContent:newValue];
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
        
        NSString *fieldName = kCheckEdPostScreen;
        
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
        NSString *fieldName = kCheckEdPostScreen;
        
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

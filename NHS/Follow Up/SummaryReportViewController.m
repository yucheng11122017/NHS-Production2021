//
//  SummaryReportViewController.m
//  NHS
//
//  Created by Nicholas Wong on 9/13/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "SummaryReportViewController.h"


#define remarksTextViewHeight 150
#define summaryTextViewHeight 500

@interface SummaryReportViewController () {
    UITextView *summaryTextView;
}

@end

@implementation SummaryReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    NSLog(@"%@", self.fullScreeningForm);
    
    self.navigationItem.title = @"Summary";
    
    [self generateSummaryReport];
    
    [self.view addSubview:summaryTextView];
    
//    /* Allow taping anywhere on the screen to hide keyboard */
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard)];
//    
//    [self.view addGestureRecognizer:tap];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    CGRect contentRect = CGRectZero;
//    for (UIView *view in self.scrollViewBackground.subviews) {
//        contentRect = CGRectUnion(contentRect, view.frame);
//    }
//    self.scrollViewBackground.contentSize = contentRect.size;   //update to the correct size according to content
    
}

- (void)viewDidLayoutSubviews {
    [summaryTextView setContentOffset:CGPointZero animated:NO]; //make subview offset from the navigation bar to be 0
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) generateSummaryReport {
    NSDictionary *resi_particulars = [self.fullScreeningForm objectForKey:@"resi_particulars"];
    NSDictionary *clinical_results = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"clinical_results"];
    NSArray *bp_records = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"bp_record"];
    NSDictionary *risk_factors = [self.fullScreeningForm objectForKey:@"risk_factors"];
    NSDictionary *diabetes = [self.fullScreeningForm objectForKey:@"diabetes"];
    NSDictionary *hyperlipid = [self.fullScreeningForm objectForKey:@"hyperlipid"];
    NSDictionary *hypertension = [self.fullScreeningForm objectForKey:@"hypertension"];
    NSDictionary *consult_record = [self.fullScreeningForm objectForKey:@"consult_record"];
    
    //Remarks (problems encountered when filling form / missing information)
    
    UIFont* warningFont = [UIFont systemFontOfSize:14];
    UIColor* redColor = [UIColor colorWithRed:216/255.0 green:0 blue:0 alpha:1.0f];
    NSDictionary *warningAttrs = @{ NSForegroundColorAttributeName : redColor,
                                    NSFontAttributeName : warningFont,
                                    NSTextEffectAttributeName : NSTextEffectLetterpressStyle};
    
    
    UIColor* headerColor = [UIColor colorWithRed:2/255.0 green:63/255.0 blue:165/255.0 alpha:1.0f];
    NSDictionary *headerAttrs = @{NSForegroundColorAttributeName : headerColor,
                                  NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    UIColor* bloodTestHeaderColor = [UIColor colorWithRed:171/255.0 green:33/255.0 blue:0/255.0 alpha:1.0f];
    NSDictionary *bloodTestHeaderAttrs = @{NSForegroundColorAttributeName : bloodTestHeaderColor,
                                  NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    
    
    
    
    NSAttributedString *resi_part_header = [[NSAttributedString alloc] initWithString:@"Resident Particulars\n" attributes:headerAttrs];
    
    NSAttributedString *name = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Name: %@\n",[resi_particulars objectForKey:@"resident_name"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *gender = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Gender: %@\n",[resi_particulars objectForKey:@"gender"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSArray *spokenLangArray = [self getSpokenLangArray:resi_particulars];
    NSString *spoken_lang_string = [spokenLangArray componentsJoinedByString:@", "];
    
    NSAttributedString *spoken_lang = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Spoken Language(s): %@\n",spoken_lang_string] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *ethnicity = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Ethnicity: %@\n",[self getEthnicityString:resi_particulars]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *contac_num = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Contact Number: %@\n",[resi_particulars objectForKey:@"contact_no"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    //
    NSAttributedString *address = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Address: %@, Blk %@, %@, S(%@)\n\n",[resi_particulars objectForKey:@"address_unit"], [resi_particulars objectForKey:@"address_block"], [resi_particulars objectForKey:@"address_street"], [resi_particulars objectForKey:@"address_postcode"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *clinical_results_header = [[NSAttributedString alloc] initWithString:@"Clinical Findings\n" attributes:headerAttrs];
    
    NSAttributedString *bp_systolic;
    if ([[bp_records[0] objectForKey:@"systolic_bp"] intValue] < 140) {
        bp_systolic = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Systolic: %@\n",[bp_records[0] objectForKey:@"systolic_bp"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    } else {
        bp_systolic = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Systolic: %@\n",[bp_records[0] objectForKey:@"systolic_bp"]] attributes:warningAttrs];
    }
    
    NSAttributedString *bp_diastolic;
    if ([[bp_records[0] objectForKey:@"diastolic_bp"] intValue] < 90) {
        bp_diastolic = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Diastolic: %@\n",[bp_records[0] objectForKey:@"diastolic_bp"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    } else {
        bp_diastolic = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Diastolic: %@\n",[bp_records[0] objectForKey:@"diastolic_bp"]] attributes:warningAttrs];
    }
    
    NSAttributedString *bmi;
    if ([[clinical_results objectForKey:@"bmi"] floatValue] <= 30.0) {
        bmi = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"BMI: %@\n",[clinical_results objectForKey:@"bmi"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    } else {
        bmi = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"BMI: %@\n",[clinical_results objectForKey:@"bmi"]] attributes:warningAttrs];
    }
    NSAttributedString *cbg;
    if ([[clinical_results objectForKey:@"cbg"] floatValue] <= 11.1) {
        cbg = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"CBG: %@\n",[clinical_results objectForKey:@"cbg"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    } else {
        cbg = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"CBG: %@\n",[clinical_results objectForKey:@"cbg"]] attributes:warningAttrs];
    }
    
    NSAttributedString *waist_hip_ratio = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Waist-Hip Ratio: %@\n\n",[clinical_results objectForKey:@"waist_hip_ratio"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *past_history_header = [[NSAttributedString alloc] initWithString:@"Past History\n" attributes:headerAttrs];
    
    NSAttributedString *smoking_status = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"🚬 Smoking: %@\n",[self getSmokingStatusString:risk_factors]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *alcohol_status = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"🍺 Alcohol: %@\n",[self getAlcoholHowOftenString:risk_factors]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *diabetes_status = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"History of Diabetes: %@\n", [self getYesNoWithString:[diabetes objectForKey:@"has_informed"]]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *hyperlipid_status = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"History of Hyperlipidemia: %@\n", [self getYesNoWithString:[hyperlipid objectForKey:@"has_informed"]]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *hypertension_status = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"History of Hypertension: %@\n\n", [self getYesNoWithString:[hypertension objectForKey:@"has_informed"]]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    NSAttributedString *doctor_referral_header = [[NSAttributedString alloc] initWithString:@"The resident has gone for/received the following:\n" attributes:headerAttrs];
    
    NSAttributedString *doctor_referral_contents = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [self getRefForDocConsultString:consult_record]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];

    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:resi_part_header];
    [textStorage appendAttributedString:name];
    [textStorage appendAttributedString:gender];
    [textStorage appendAttributedString:spoken_lang];
    [textStorage appendAttributedString:ethnicity];
    [textStorage appendAttributedString:contac_num];
    [textStorage appendAttributedString:address];
    [textStorage appendAttributedString:clinical_results_header];
    [textStorage appendAttributedString:bp_systolic];
    [textStorage appendAttributedString:bp_diastolic];
    [textStorage appendAttributedString:bmi];
    [textStorage appendAttributedString:cbg];
    [textStorage appendAttributedString:waist_hip_ratio];
    [textStorage appendAttributedString:past_history_header];
    [textStorage appendAttributedString:smoking_status];
    [textStorage appendAttributedString:alcohol_status];
    [textStorage appendAttributedString:diabetes_status];
    [textStorage appendAttributedString:hyperlipid_status];
    [textStorage appendAttributedString:hypertension_status];
    [textStorage appendAttributedString:doctor_referral_header];
    [textStorage appendAttributedString:doctor_referral_contents];
    
    if ([self.bloodTestResult objectForKey:@"blood_test"] != [NSNull null]) {   //include only if it's not blank
        NSAttributedString *blood_test_header = [[NSAttributedString alloc] initWithString:@"Blood Test Results\n" attributes:bloodTestHeaderAttrs];
    
        NSAttributedString *blood_test_contents = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [self getBloodTestResultString]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        
        [textStorage appendAttributedString:blood_test_header];
        [textStorage appendAttributedString:blood_test_contents];
    }
    
    NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
    // Add layout manager to text storage object
    [textStorage addLayoutManager:textLayout];
    // Create a text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
    // Add text container to text layout manager
    [textLayout addTextContainer:textContainer];
    // Instantiate UITextView object using the text container
    
    
    summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 10+self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-20) textContainer:textContainer];
    
    summaryTextView.layer.borderWidth = 0.5f;
    summaryTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    summaryTextView.layer.cornerRadius = 8;
    
    summaryTextView.scrollEnabled = NO;
    summaryTextView.scrollEnabled = YES;
    summaryTextView.editable = NO;  //make it not editable
    
}


#pragma mark - Misc. Methods

- (NSArray *) getSpokenLangArray: (NSDictionary *) dictionary {
    NSMutableArray *spokenLangArray = [[NSMutableArray alloc] init];
    if ([[dictionary objectForKey:@"lang_canto"] isKindOfClass:[NSString class]]) {
        
        if([[dictionary objectForKey:@"lang_canto"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Cantonese"];
        if([[dictionary objectForKey:@"lang_english"] isEqualToString:@"1"]) [spokenLangArray addObject:@"English"];
        if([[dictionary objectForKey:@"lang_hindi"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hindi"];
        if([[dictionary objectForKey:@"lang_hokkien"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Hokkien"];
        if([[dictionary objectForKey:@"lang_malay"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Malay"];
        if([[dictionary objectForKey:@"lang_mandrin"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Mandarin"];
        if([[dictionary objectForKey:@"lang_others"] isEqualToString:@"1"]) {
            if (![[dictionary objectForKey:@"lang_others_text"]isEqualToString:@""]) {
                [spokenLangArray addObject:[dictionary objectForKey:@"lang_others_text"]];
            }
        }
        if([[dictionary objectForKey:@"lang_tamil"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Tamil"];
        if([[dictionary objectForKey:@"lang_teochew"] isEqualToString:@"1"]) [spokenLangArray addObject:@"Teochew"];
    }
    
    return spokenLangArray;
}

- (NSString *) getEthnicityString: (NSDictionary *) dictionary {
    if ([[dictionary objectForKey:@"ethnicity_id"] isEqualToString:@"0"]) return @"Chinese";
    else if ([[dictionary objectForKey:@"ethnicity_id"] isEqualToString:@"1"]) return @"Indian";
    else if ([[dictionary objectForKey:@"ethnicity_id"] isEqualToString:@"2"]) return @"Malay";
    else if ([[dictionary objectForKey:@"ethnicity_id"] isEqualToString:@"3"]) return @"Others";
    
    return @"";
}

- (NSString *) getSmokingStatusString: (NSDictionary *) dictionary {
    if ([[dictionary objectForKey:@"smoking"] isEqualToString:@"0"]) return @"Smokes at least once a day";
    else if ([[dictionary objectForKey:@"smoking"] isEqualToString:@"1"]) return @"Smokes but not everyday";
    else if ([[dictionary objectForKey:@"smoking"] isEqualToString:@"2"]) return @"Ex-smoker, now quit";
    else if ([[dictionary objectForKey:@"smoking"] isEqualToString:@"3"]) return @"Never smoked";
    
    return @"";
}

- (NSString *) getAlcoholHowOftenString: (NSDictionary *) dictionary {
    if ([[dictionary objectForKey:@"alcohol_how_often"] isEqualToString:@"0"]) return @"More than 4 days a week";
    else if ([[dictionary objectForKey:@"alcohol_how_often"] isEqualToString:@"1"]) return @"1-4 days a week";
    else if ([[dictionary objectForKey:@"alcohol_how_often"] isEqualToString:@"2"]) return @"Less than 3 days a month";
    else if ([[dictionary objectForKey:@"alcohol_how_often"] isEqualToString:@"3"]) return @"Not drinking";
    
    return @"";
}

- (NSString *) getYesNoWithString: (NSString *) stringOneOrZero {
    if ([stringOneOrZero isEqualToString:@"0"]) return @"NO";
    if ([stringOneOrZero isEqualToString:@"1"]) return @"YES";
    
    return @"";
}

- (NSString *) getRefForDocConsultString: (NSDictionary *) dictionary {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if([[dictionary objectForKey:@"doc_consult"] isEqualToString:@"1"]) [array addObject:@"Doctor's consultation"];
    if([[dictionary objectForKey:@"doc_ref"] isEqualToString:@"1"]) [array addObject:@"Doctor's referral"];
    if([[dictionary objectForKey:@"seri"] isEqualToString:@"1"]) [array addObject:@"SERI"];
    if([[dictionary objectForKey:@"seri_ref"] isEqualToString:@"1"]) [array addObject:@"SERI referral"];
    if([[dictionary objectForKey:@"dental"] isEqualToString:@"1"]) [array addObject:@"Dental"];
    if([[dictionary objectForKey:@"dental_ref"] isEqualToString:@"1"]) [array addObject:@"Dental referral"];
    if([[dictionary objectForKey:@"mammo_ref"] isEqualToString:@"1"]) [array addObject:@"Mammogram referral"];
    if([[dictionary objectForKey:@"fit_kit"] isEqualToString:@"1"]) [array addObject:@"FIT kit"];
    if([[dictionary objectForKey:@"pap_smear_ref"] isEqualToString:@"1"]) [array addObject:@"Pap smear referral"];
    if([[dictionary objectForKey:@"phleb"] isEqualToString:@"1"]) [array addObject:@"Phlebotomy (Blood test)"];
    if([[dictionary objectForKey:@"na"] isEqualToString:@"1"]) [array addObject:@"N.A."];
    
    
    return [array componentsJoinedByString:@"\n"];;
}
                                               
- (NSString *) getBloodTestResultString {
    NSString *firstString = [NSString stringWithFormat:@"Glucose (Fasting): %@\nTriglycerides: %@\nLDL Cholesterol: %@\nFIT Positive: ", [[self.bloodTestResult objectForKey:@"blood_test"] objectForKey:@"glucose"], [[self.bloodTestResult objectForKey:@"blood_test"] objectForKey:@"trigly"], [[self.bloodTestResult objectForKey:@"blood_test"] objectForKey:@"ldl"]];
    
    NSString *secondString = @"No"; //default No
    
    if ([[[self.bloodTestResult objectForKey:@"blood_test"] objectForKey:@"fit"] isEqualToNumber:@1]) {
        secondString = @"Yes";
    }
    
    return [firstString stringByAppendingString:secondString];
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

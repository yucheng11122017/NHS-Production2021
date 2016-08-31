//
//  SummaryPageViewController.m
//  NHS
//
//  Created by Nicholas Wong on 8/31/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "SummaryPageViewController.h"
#import "ServerComm.h"
#import "MBProgressHUD.h"
#import "AppConstants.h"
#import "math.h"

//XLForms stuffs
#import "XLForm.h"

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

@interface SummaryPageViewController () <UITextViewDelegate>


@end

@implementation SummaryPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@", self.fullScreeningForm);
    NSDictionary *resi_particulars = [self.fullScreeningForm objectForKey:@"resi_particulars"];
    NSDictionary *clinical_results = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"clinical_results"];
    NSArray *bp_records = [[self.fullScreeningForm objectForKey:@"clinical_results"] objectForKey:@"bp_record"];
    
    
    //Past History (smoker / drinker / history of diabetes? /  history of hyperlipidemia? / history of hypertension? )
    //The resident has gone for/received the following: Doctor's Consultation | Doctor's referral | SERI | SERI referral | Dental | Dental referral | Mammogram referral | FIT kit | Pap Smear referral l Phlebotomy (Blood Test) l NA
    //Remarks (problems encountered when filling form / missing information)
    NSAttributedString *resi_part_header = [[NSAttributedString alloc] initWithString:@"Resident Particulars\n" attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14]}];
    
    NSAttributedString *name = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Name: %@\n",[resi_particulars objectForKey:@"resident_name"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    NSAttributedString *gender = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Gender: %@\n",[resi_particulars objectForKey:@"gender"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    NSArray *spokenLangArray = [self getSpokenLangArray:resi_particulars];
    NSString *spoken_lang_string = [spokenLangArray componentsJoinedByString:@", "];
    
    NSAttributedString *spoken_lang = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Spoken Language(s): %@\n",spoken_lang_string] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    NSAttributedString *ethnicity = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Ethnicity: %@\n",[self getEthnicityString:resi_particulars]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    NSAttributedString *contac_num = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Contact Number: %@\n",[resi_particulars objectForKey:@"contact_no"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
//
    NSAttributedString *address = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Address: %@, Blk %@, %@, S(%@)\n\n",[resi_particulars objectForKey:@"address_unit"], [resi_particulars objectForKey:@"address_block"], [resi_particulars objectForKey:@"address_street"], [resi_particulars objectForKey:@"address_postcode"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    NSAttributedString *clinical_results_header = [[NSAttributedString alloc] initWithString:@"Clinical Findings\n" attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14]}];
    
    NSAttributedString *bp = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Diastolic: %@\nSystolic: %@\n",[bp_records[0] objectForKey:@"diastolic_bp"], [bp_records[0] objectForKey:@"systolic_bp"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    NSAttributedString *bmi = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"BMI: %@\n",[clinical_results objectForKey:@"bmi"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    NSAttributedString *cbg = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"BMI: %@\n",[clinical_results objectForKey:@"cbg"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    NSAttributedString *waist_hip_ratio = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Waist-Hip Ratio: %@\n",[clinical_results objectForKey:@"waist_hip_ratio"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
//
//    NSAttributedString *contac_num = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Name: %@\n",[resi_particulars objectForKey:@"contact_no"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    
    
    
//    NSAttributedString *textString =  [[NSAttributedString alloc] initWithString:@"Hello World\n" attributes:@{
//                                                                                                             NSFontAttributeName: [UIFont fontWithName:@"HoeflerText-Italic" size:12]
//                                                                                                             }];
//    NSAttributedString *textString2 =  [[NSAttributedString alloc] initWithString:@"You're beautiful!" attributes:@{
//                                                                                                             NSFontAttributeName: [UIFont fontWithName:@"HoeflerText-Italic" size:14]
//                                                                                                             }];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:resi_part_header];
    [textStorage appendAttributedString:name];
    [textStorage appendAttributedString:gender];
    [textStorage appendAttributedString:spoken_lang];
    [textStorage appendAttributedString:ethnicity];
    [textStorage appendAttributedString:contac_num];
    [textStorage appendAttributedString:address];
    [textStorage appendAttributedString:clinical_results_header];
    [textStorage appendAttributedString:bp];
    [textStorage appendAttributedString:bmi];
    [textStorage appendAttributedString:cbg];
    [textStorage appendAttributedString:waist_hip_ratio];
    
    
    NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
    // Add layout manager to text storage object
    [textStorage addLayoutManager:textLayout];
    // Create a text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
    // Add text container to text layout manager
    [textLayout addTextContainer:textContainer];
    // Instantiate UITextView object using the text container
    
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-20, self.view.bounds.size.height-20) textContainer:textContainer];
    
    textView.scrollEnabled = YES;
    
    [self.view addSubview:textView];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

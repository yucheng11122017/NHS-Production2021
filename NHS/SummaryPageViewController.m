//
//  SummaryPageViewController.m
//  NHS
//
//  Created by Nicholas Wong on 8/31/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "SummaryPageViewController.h"
#import "PatientScreeningListTableViewController.h"
#import "ServerComm.h"
#import "MBProgressHUD.h"
#import "AppConstants.h"

//XLForms stuffs
#import "XLForm.h"
#define remarksTextViewHeight 150
#define summaryTextViewHeight 500
#define remarksLabelHeight 20


#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

@interface SummaryPageViewController () {

    UITextView *summaryTextView;
    UILabel *remarksLabel;
    MBProgressHUD *hud;
    int successCounter;
    float timestampSecond;
    BOOL errorMsgFlag;
}
@property(strong, nonatomic) UIScrollView *scrollViewBackground;
@property(strong, nonatomic) UITextView *remarksTextView;
@property(strong, nonatomic) NSString *resident_id;



@end

@implementation SummaryPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSLog(@"%@", self.fullScreeningForm);
    
    self.navigationItem.title = @"Summary";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitScreeningPressed:)];
    
    [self initScrollView];
    
    [self generateSummaryReport];
    [self initRemarksColumn];
    
    [self.scrollViewBackground addSubview:summaryTextView];
    [self.scrollViewBackground addSubview:remarksLabel];
    [self.scrollViewBackground addSubview:self.remarksTextView];
    
     /* Allow taping anywhere on the screen to hide keyboard */
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(dismissKeyboard)];
     
     [self.view addGestureRecognizer:tap];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollViewBackground.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.scrollViewBackground.contentSize = contentRect.size;   //update to the correct size according to content
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [summaryTextView setContentOffset:CGPointZero animated:NO]; //make subview offset from the navigation bar to be 0
}

#pragma mark Keyboard Notifs - to adj screen when keyboard comes up
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWasShown:)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillBeHidden:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
// If login button is hidden by keyboard, scroll it so it's visible
- (void)keyboardWasShown:(NSNotification *)aNotification {
    
    // get keyboard size
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize =
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // set kayboard's height as content inset
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollViewBackground.contentInset = contentInsets;
    self.scrollViewBackground.scrollIndicatorInsets = contentInsets;
    
    // If Remarks Text View is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsRect(aRect, self.remarksTextView.frame))
        [self.scrollViewBackground scrollRectToVisible:self.remarksTextView.frame
                                              animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    
    // reset content insets between scrollview and content, to zero
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+10, 0, 0, 0);
    self.scrollViewBackground.contentInset = contentInsets;
    self.scrollViewBackground.scrollIndicatorInsets = contentInsets;
}

#pragma mark Keyboard/ UIButton presses

// this gets called when 'return' or its equivalent button is pressed.
// return 'YES' to implement its default behaviour (which is to insert line
// break)
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [_remarksTextView resignFirstResponder];
    return NO; // We do not want to insert a line-break.
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
}


//Hide Keyboard if anywhere in the screen is tapped
-(void)dismissKeyboard {
    [_remarksTextView resignFirstResponder];
}

#pragma  mark - Label, TextView, Button Init
- (void) initScrollView {
    self.scrollViewBackground = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    self.scrollViewBackground.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.scrollViewBackground];
}

- (void) initRemarksColumn {
    
    remarksLabel= [[UILabel alloc] initWithFrame:CGRectMake(10, summaryTextView.frame.origin.y+summaryTextViewHeight+10, self.scrollViewBackground.bounds.size.width-20, remarksLabelHeight)];
    
    [remarksLabel setText:@"Remarks"];
    [remarksLabel setTextColor:[UIColor grayColor]];
    
    self.remarksTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, remarksLabel.frame.origin.y+remarksLabel.frame.size.height+10, self.view.bounds.size.width-20, remarksTextViewHeight)];
    
    [self.remarksTextView setText:[[self.fullScreeningForm objectForKey:@"submit_remarks"] objectForKey:@"remarks"]];
    [self.remarksTextView setFont:[UIFont systemFontOfSize:14]];
    self.remarksTextView.layer.borderWidth = 0.5f;
    self.remarksTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.remarksTextView.layer.cornerRadius = 8;
    self.remarksTextView.delegate = self;
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
    
    NSAttributedString *doctor_referral_contents = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [self getRefForDocConsultString:consult_record]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    
    //
    //    NSAttributedString *contac_num = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Name: %@\n",[resi_particulars objectForKey:@"contact_no"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    
    
    
    
    //    NSAttributedString *textString =  [[NSAttributedString alloc] initWithString:@"Hello World\n" attributes:@{
    //                                                                                                             NSFontAttributeName: [UIFont fontWithName:@"HoeflerText-Italic" size:14]
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
    
    
    NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
    // Add layout manager to text storage object
    [textStorage addLayoutManager:textLayout];
    // Create a text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
    // Add text container to text layout manager
    [textLayout addTextContainer:textContainer];
    // Instantiate UITextView object using the text container
    
    
     summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width-20, summaryTextViewHeight) textContainer:textContainer];
    
    summaryTextView.layer.borderWidth = 0.5f;
    summaryTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    summaryTextView.layer.cornerRadius = 8;
    
    summaryTextView.scrollEnabled = NO;
    summaryTextView.scrollEnabled = YES;
    summaryTextView.editable = NO;  //make it not editable

}

#pragma mark Submit Button

-(void)submitScreeningPressed:(UIBarButtonItem * __unused)button {
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [self saveRemarksToDict];
    
    // Set the label text.
    hud.label.text = NSLocalizedString(@"Uploading...", @"HUD loading title");
    errorMsgFlag = NO;
    [self submitResidentParticulars];
    
    
}

#pragma mark - Post data to server methods
- (void) submitResidentParticulars {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    NSDictionary *dict = [self insertTimestampToDict:[self.fullScreeningForm objectForKey:@"resi_particulars"]];
    [client postResidentParticularsWithDict:dict
                      progressBlock:[self progressBlock]
                       successBlock:[self newEntrySuccessBlock]
                       andFailBlock:[self errorBlock]];
}

- (void) submitAllOtherSections {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    successCounter = 0;
    timestampSecond = 1;
    NSDictionary *dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"neighbourhood"]];
    NSLog(@"neighbourhood:%@}",dict);
    [client postNeighbourhoodWithDict:dict
                              progressBlock:[self progressBlock]
                               successBlock:[self successBlock]
                               andFailBlock:[self errorBlock]];
    
    dict = [self prepareClinicalResultsDict];
    [client postClinicalResultsWithDict:dict
                        progressBlock:[self progressBlock]
                         successBlock:[self successBlock]
                         andFailBlock:[self errorBlock]];
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"risk_factors"]];
    [client postRiskFactorsWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"risk_factors:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"diabetes"]];
    [client postDiabetesWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"diabetes:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"hyperlipid"]];
    [client postHyperlipidWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"hyperlipid:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"hypertension"]];
    [client postHypertensionWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"hypertension:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"cancer"]];
    [client postCancerWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"cancer:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"others"]];
    [client postOtherMedIssuesWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"others:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"primary_care"]];
    [client postPriCareSourceWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"primary_care:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"self_rated"]];
    [client postMyHealthMyNeighbourhoodWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"self_rated:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"demographics"]];
    [client postDemographicsWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"demographics:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"adls"]];
    [client postCurrPhyIssuesWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"adls:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"socioecon"]];
    [client postCurrSocioSituationWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"socioecon:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"social_support"]];
    [client postSociSuppAssessWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"social_support:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"consult_record"]];
    [client postRefForDocConsultWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"consult_record:%@",dict);
    
    dict = [self insertTimestampAndResidentIDToDict:[self.fullScreeningForm objectForKey:@"submit_remarks"]];
    
    [client postSubmitRemarksWithDict:dict
                          progressBlock:[self progressBlock]
                           successBlock:[self successBlock]
                           andFailBlock:[self errorBlock]];
    NSLog(@"submit_remarks:%@",dict);
}



#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"POST in progress...");
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        successCounter++;
        if(successCounter == 16) {
            NSLog(@"SUBMISSION SUCCESSFUL!!");
            [self deleteAutoSavedFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
//            if (self.loadDataFlag == [NSNumber numberWithBool:YES]) {       //if this draft is loaded and submitted,now delete!
//                [self removeDraftAfterSubmission];
//            }
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Uploaded", nil)
                                                                                      message:@"Screening form upload successful!"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * okAction) {
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshScreeningResidentTable"
                                                                                                                      object:nil
                                                                                                                    userInfo:nil];
                                                                  NSArray *viewControllers = [[self navigationController] viewControllers];
                                                                  for( int i=0;i<[viewControllers count];i++){
                                                                      id obj=[viewControllers objectAtIndex:i];
                                                                      if([obj isKindOfClass:[PatientScreeningListTableViewController class]]){
                                                                          [[self navigationController] popToViewController:obj animated:YES];
                                                                          return;
                                                                      }
                                                                  }
                                                              }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))newEntrySuccessBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"Resident Particulars submission success");
        self.resident_id = [responseObject objectForKey:@"resident_id"];
        NSLog(@"I'm resident %@", self.resident_id);
        
        [hud hideAnimated:YES];
        
        [self submitAllOtherSections];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"submittingOtherSections" object:nil];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"******UNSUCCESSFUL SUBMISSION******!!");
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSLog(@"Error: %@", errorString);

        [hud hideAnimated:YES];     //stop showing the progressindicator
        if (!errorMsgFlag) {
            errorMsgFlag = YES;
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Ooops!", nil)
                                                                                      message:@"Form failed to upload. Please try again."
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * okAction) {
                                                                  //do nothing
                                                              }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
    };
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

- (void) saveRemarksToDict {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:[self.fullScreeningForm objectForKey:@"submit_remarks"]];
    [dict setObject:_remarksTextView.text forKey:@"remarks"];
    [self.fullScreeningForm setObject:dict forKey:@"submit_remarks"];   //put it back to the dictionary;
}

- (NSDictionary *) prepareClinicalResultsDict {
    NSMutableDictionary *clinical_results = [[NSMutableDictionary alloc] initWithDictionary:[self.fullScreeningForm objectForKey:@"clinical_results"]];
    
    NSMutableArray *bp_records = [[NSMutableArray alloc] initWithArray:[clinical_results objectForKey:@"bp_record"]];
    NSDictionary *innerClinicalDict = [self insertTimestampAndResidentIDToDict:[[clinical_results objectForKey:@"clinical_results"] mutableCopy]];
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    for(int i=0; i<4;i++) {
        temp = [[bp_records objectAtIndex:i] mutableCopy];
        [temp setObject:[localDateTime description] forKey:@"ts"];  //so that all time variable will be the same
        [temp setObject:self.resident_id forKey:@"resident_id"];
        [bp_records replaceObjectAtIndex:i withObject:temp];
    }
    
    [clinical_results setObject:innerClinicalDict forKey:@"clinical_results"];
    [clinical_results setObject:bp_records forKey:@"bp_record"];
    
    return clinical_results;
}

- (NSDictionary *) insertTimestampToDict:(NSMutableDictionary *) dictionary {
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    
    [dictionary setObject:[localDateTime description] forKey:@"ts"];
    
    return dictionary;
}

- (NSDictionary *) insertTimestampAndResidentIDToDict:(NSMutableDictionary *) dictionary {
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:today];
    localDateTime = [NSDate dateWithTimeInterval:timestampSecond sinceDate:localDateTime];      //add a second
    timestampSecond++;  //forcefully make sure that no upload of same timestamp.
    
    [dictionary setObject:[localDateTime description] forKey:@"ts"];
    [dictionary setObject:self.resident_id forKey:@"resident_id"];
    
    return dictionary;
}

- (void) deleteAutoSavedFile {

    NSString *nric = [[[self.fullScreeningForm objectForKey:@"resi_particulars"] objectForKey:kNRIC] stringByAppendingString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [nric stringByAppendingString:@"autosave"]; //Eg. S12313K_autosave
    NSString *folderPath = [documentsDirectory stringByAppendingString:@"/Screening"];
    
    NSError *error;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
    
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"Draft deleted!");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
    //    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:NULL];
    //    for (count = 0; count < (int)[directoryContent count]; count++)
    //    {
    //        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    //    }
    
    
    
    //Save the form locally on the iPhone
    [self.fullScreeningForm writeToFile:filePath atomically:YES];

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

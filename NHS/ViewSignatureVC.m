//
//  ViewSignatureVC.m
//  NHS
//
//  Created by rehabpal on 21/8/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import "ViewSignatureVC.h"
#import "AppConstants.h"

@interface ViewSignatureVC () {
    NSNumber *index;
}

@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *insertSignature1Btn;
@property (weak, nonatomic) IBOutlet UIButton *insertSignature2Btn;

@end

@implementation ViewSignatureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat borderWidth = 2.0f;
    
    self.signature1ImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.signature1ImageView.layer.borderWidth = borderWidth;
    
    self.signature2ImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.signature2ImageView.layer.borderWidth = borderWidth;
    
    [self loadImageIfAny];
    
    //create long press gesture recognizer(gestureHandler will be triggered after gesture is detected)
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    longPressGesture.delegate = self;
    longPressGesture.delaysTouchesBegan = YES;
    //adjust time interval(floating value CFTimeInterval in seconds)
    [longPressGesture setMinimumPressDuration:2.0];
    //add gesture to view you want to listen for it(note that if you want whole view to "listen" for gestures you should add gesture to self.view instead)
    [self.view addGestureRecognizer:longPressGesture];
    
    NSString *formName;
//    if ([sender.tag containsString:@"research"]) {
//        formName = @"ResearchConsent";
//    } else {
        formName = @"ScreeningConsent";
//    }
//    UIViewController *webVC = [[UIViewController alloc] init];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    NSURL *targetURL = [[NSBundle mainBundle] URLForResource:formName withExtension:@"pdf"];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [_webView setScalesPageToFit:YES];
    [_webView loadRequest:request];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hide Form" style:UIBarButtonItemStyleDone target:self action:@selector(hideWebViewBtnPressed:)];
    
    [self.view addSubview:_webView];
//    [self.navigationController pushViewController:webVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) hideWebViewBtnPressed:(UIBarButtonItem * __unused)button {
    if ([button.title containsString:@"Hide"]) {
        _webView.hidden = YES;
        button.title = @"Show Form";
    } else {
        _webView.hidden = NO;
        button.title = @"Hide Form";
    }
}

-(void)gestureHandler:(UISwipeGestureRecognizer *)gesture
{
    if(UIGestureRecognizerStateBegan == gesture.state)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Are you sure you want to delete both signatures?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self removeBothSignatures];
        }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        alertController.preferredAction = noAction;
        
        [self presentViewController:alertController animated:true completion:nil];
    }
}

- (void) removeBothSignatures {
    self.insertSignature1Btn.hidden = NO;
    self.insertSignature2Btn.hidden = NO;
    self.signature1ImageView.image = nil;
    self.signature2ImageView.image = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SCREENING_PARTICIPANT_SIGNATURE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SCREENING_CONSENT_TAKER_SIGNATURE];
    
}

- (void) loadImageIfAny {
    NSString *imagePath1 = [[NSUserDefaults standardUserDefaults] objectForKey:SCREENING_PARTICIPANT_SIGNATURE];
    if (imagePath1) {
        _signature1ImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath1]];
        _insertSignature1Btn.hidden = true;
    }
    
    NSString *imagePath2 = [[NSUserDefaults standardUserDefaults] objectForKey:SCREENING_CONSENT_TAKER_SIGNATURE];
    if (imagePath2) {
        _signature2ImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath2]];
        _insertSignature2Btn.hidden = true;
    }
}

//implementation of delegate method
- (void)processCompleted:(UIImage*)signImage withIndex: (NSNumber *)index
{
    if ([index isEqualToNumber:@1]) {
        _insertSignature1Btn.hidden = YES;
        _signature1ImageView.image = signImage;
        [self saveImageInDirectory: signImage withIdentifier: SCREENING_PARTICIPANT_SIGNATURE];
    } else {
        _insertSignature2Btn.hidden = YES;
        _signature2ImageView.image = signImage;
        [self saveImageInDirectory: signImage withIdentifier: SCREENING_CONSENT_TAKER_SIGNATURE];
    }
}

- (void) saveImageInDirectory: (UIImage *)image
               withIdentifier: (NSString *) identifier {
    // Get image data. Here you can use UIImagePNGRepresentation if you need transparency
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
    NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image_%@.jpg", identifier]];
    
    // Write image data to user's folder
    [imageData writeToFile:imagePath atomically:YES];
    
    // Store path in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:identifier];
    
    // Sync user defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}
- (IBAction)signBtn1Pressed:(id)sender {
    NSString *someText =  @"I consent to NHS directly disclosing the Information and my past screening and follow-up information (participant’s past screening and follow-up information under NHS’ Screening and Follow-Up Programme) to NHS’ collaborators (refer to organisations/institutions that work in partnership with NHS for the provision of screening and follow-up related services, such as but not limited to: MOH, HPB, Regional Health Systems, Senior Cluster Network Operators, etc. where necessary) for the purposes of checking if I require re-screening, further tests, follow-up action and/or referral to community programmes/activities.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Read this" message:someText preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"goToCaptureSignature" sender:self];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier hasPrefix:@"view_to_capture"]) {
        CaptureSignatureVC *destination = segue.destinationViewController;
        destination.delegate = self;
        NSUInteger tagNumber = ((UIButton *) sender).tag;
        destination.signatureIndex = [NSNumber numberWithInteger:tagNumber];
    } else if ([segue.identifier containsString:@"CaptureSignature"]) {
        CaptureSignatureVC *destination = segue.destinationViewController;
        destination.delegate = self;
        NSUInteger tagNumber = 1;
        destination.signatureIndex = [NSNumber numberWithInteger:tagNumber];
    }
}



#pragma mark - Sample protocol delegate


@end

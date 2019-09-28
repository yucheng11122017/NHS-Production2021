//
//  HearingSignatureVC.m
//  NHS
//
//  Created by rehabpal on 6/9/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import "HearingSignatureVC.h"
#import "AppConstants.h"
#import "ServerComm.h"
#import "KAStatusBar.h"
@import WebKit;

@interface HearingSignatureVC () {
    NSNumber *index;
}

@property (strong, nonatomic) WKWebView *wkWebView;
@property (weak, nonatomic) IBOutlet UIButton *insertSignature1Btn;

@end

@implementation HearingSignatureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat borderWidth = 2.0f;
    
    self.signature1ImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.signature1ImageView.layer.borderWidth = borderWidth;
    
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
    formName = @"HearingConsent";
//
//    NSURL *targetURL = [[NSBundle mainBundle] URLForResource:formName withExtension:@"pdf"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
//    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
//    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:theConfiguration];
//    [_wkWebView loadRequest:request];
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hide Form" style:UIBarButtonItemStyleDone target:self action:@selector(hideWebViewBtnPressed:)];
    
//    [self.view addSubview:_wkWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//-(void) hideWebViewBtnPressed:(UIBarButtonItem * __unused)button {
//    if ([button.title containsString:@"Hide"]) {
//        _wkWebView.hidden = YES;
//        button.title = @"Show Form";
//    } else {
//        _wkWebView.hidden = NO;
//        button.title = @"Hide Form";
//    }
//}

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
    self.signature1ImageView.image = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HEARING_REFERRER_SIGNATURE];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *downloadedImage1Path = [documentsDirectory stringByAppendingPathComponent:@"hearing_referrer_sign.png"];
    
    NSError *error;
    BOOL fileDeleted = [[NSFileManager defaultManager] removeItemAtPath:downloadedImage1Path error:&error];
    if (!fileDeleted) {
        NSLog(@"%@ doesn't exist!", downloadedImage1Path.lastPathComponent);
    }
}

- (void) loadImageIfAny {
    NSString *imageDataPath1 = [[NSUserDefaults standardUserDefaults] objectForKey:HEARING_REFERRER_SIGNATURE];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *downloadedImage1Path = [documentsDirectory stringByAppendingPathComponent:@"hearing_referrer_sign.png"];
    NSData *imgData1 = [NSData dataWithContentsOfFile:downloadedImage1Path];
    UIImage *thumbNail1 = [[UIImage alloc] initWithData:imgData1];
    
    if (imageDataPath1) {
        _signature1ImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageDataPath1]];
        _insertSignature1Btn.hidden = true;
    } else if (thumbNail1) {
        _signature1ImageView.image = thumbNail1;
        _insertSignature1Btn.hidden = true;
    }
}

//implementation of delegate method
- (void)processCompleted:(UIImage*)signImage withIndex: (NSNumber *)index
{
    NSString *nric = [[NSUserDefaults standardUserDefaults] objectForKey:kNRIC];
    NSNumber *residentID = [[NSUserDefaults standardUserDefaults] objectForKey:kResidentId];
    
        _insertSignature1Btn.hidden = YES;
        _signature1ImageView.image = signImage;
        [self saveImageInDirectory: signImage withIdentifier: HEARING_REFERRER_SIGNATURE];
        
        if (residentID != nil) {
            [[ServerComm sharedServerCommInstance] uploadImage:signImage forResident:residentID withNric:nric andWithFileType:@"hearing_referrer_sign" withProgressBlock:^(NSProgress *downloadProgress) {
                // do nothing here
            } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                NSLog(@"ResponseObject: %@", responseObject);
                
                if (responseObject != (id)[NSNull null] && [[responseObject objectForKey:@"success"] isEqualToNumber:@1]) {
                    [KAStatusBar showWithStatus:@"Signature uploaded!" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
                }
            }];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier hasPrefix:@"view_to_capture"]) {
        CaptureSignatureVC *destination = segue.destinationViewController;
        destination.delegate = self;
        NSUInteger tagNumber = ((UIButton *) sender).tag;
        destination.signatureIndex = [NSNumber numberWithInteger:tagNumber];
    }
}



#pragma mark - Sample protocol delegate


@end

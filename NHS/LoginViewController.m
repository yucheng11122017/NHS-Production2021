//
//  LoginViewController.m
//  NHS
//
//  Created by Nicholas on 8/19/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "LoginViewController.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>

#define ERROR_INFO @"com.alamofire.serialization.response.error.data"
#define ERROR_MSG_DELAY 5.0f

#define USERNAME_TEXTFIELD_TAG 1
#define PASSWORD_TEXTFIELD_TAG 2

@interface LoginViewController ()
@property(strong, nonatomic) IBOutlet UIScrollView *scrollViewBackground;

@property(strong, nonatomic) IBOutlet UIImageView *nhsLogoImageView;
@property(strong, nonatomic) IBOutlet UITextField *usernameField;
@property(strong, nonatomic) IBOutlet UITextField *passwordField;
@property(strong, nonatomic) IBOutlet UILabel *errorMsgLabel;

@property(strong, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonPressed:(id)sender;
@property(nonatomic) NSInteger volunteerID;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    // scale the NHS logo properly
    self.nhsLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // set textfield delegate - for responding to return button presses
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    // set tags for identifying textfields
    self.usernameField.tag = USERNAME_TEXTFIELD_TAG;
    self.passwordField.tag = PASSWORD_TEXTFIELD_TAG;
    
    // prepare scrollview if screen is too small to display all elements
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    if (height < 500) {
        [self registerForKeyboardNotifications];
        
        CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width,
                                 [[UIScreen mainScreen] bounds].size.height);
        [self.scrollViewBackground setContentSize:size];
        
        [self.scrollViewBackground setFrame:[[UIScreen mainScreen] bounds]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // place cursor at username field and raise the keyboard
    [self.usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // If login button is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsRect(aRect, self.loginButton.frame))
        [self.scrollViewBackground scrollRectToVisible:self.loginButton.frame
                                              animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    
    // reset content insets between scrollview and content, to zero
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollViewBackground.contentInset = contentInsets;
    self.scrollViewBackground.scrollIndicatorInsets = contentInsets;
}

#pragma mark Keyboard/ UIButton presses

// this gets called when 'return' or its equivalent button is pressed.
// return 'YES' to implement its default behaviour (which is to insert line
// break)
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    // if 'return' is pressed at the name text field,
    // go on to the passowrd text field
    if (theTextField.tag == USERNAME_TEXTFIELD_TAG)
        [self.passwordField becomeFirstResponder];
    else if (theTextField.tag == PASSWORD_TEXTFIELD_TAG) {
        // if 'return' is pressed at the password text field,
        // minimise keyboard and attempt sign in
        [theTextField resignFirstResponder];
        [self loginButtonPressed:theTextField];
    }
    return NO; // We do not want to insert a line-break.
}

- (IBAction)loginButtonPressed:(id)sender {
    // fetch user entered values
    NSString *username = self.usernameField.text; // @"nhs16user2";
    NSString *password = self.passwordField.text; // @"2016user2"
    
    // prepare password for submission: hash 5 times
    NSString *passkey = [self createSHA512:password];
    
    for (int i = 0; i < 4; i++) // 4 more times
        passkey = [self createSHA512:passkey];
    
    // clear password field
    self.passwordField.text = @"";
    
    // submit credentials
    NSString *url = @"https://nus-nhs.ml/volunteerLogin";
    NSDictionary *dict = @{ @"username" : username, @"passkey" : passkey };
    NSDictionary *dataDict = @{ @"data" : dict };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:url
       parameters:dataDict
         progress:nil
          success:^(NSURLSessionDataTask *_Nonnull task,
                    id _Nullable responseObject) {
              
              NSLog(@"success: %@", responseObject);
              NSDictionary *responseDict = responseObject;
              
              // login if auth_result is 1
              if ([[responseDict valueForKey:@"auth_result"] integerValue] == 1) {
                  self.volunteerID =
                  [[responseDict valueForKey:@"user_id"] integerValue];
                  [self performSegueWithIdentifier:@"login segue" sender:self];
              }
              
              // show error msg for some time
              else {
                  [self.errorMsgLabel setHidden:NO];
                  [self performSelector:@selector(hideErrorMsg)
                             withObject:nil
                             afterDelay:ERROR_MSG_DELAY];
              }
          }
     // print error msg if HTTP failure
          failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
              NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
              NSString *errorString =
              [[NSString alloc] initWithData:errorData
                                    encoding:NSUTF8StringEncoding];
              NSLog(@"error: %@", errorString);
          }];
}

- (void)hideErrorMsg {
    [self.errorMsgLabel setHidden:YES];
}

- (NSString *)createSHA512:(NSString *)string {
    
    // convert string to char*
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    // convert char* to data
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output =
    [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end

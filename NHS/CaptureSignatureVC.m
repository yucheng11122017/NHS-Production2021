//
//  CaptureSignatureVC.m
//  NHS
//
//  Created by rehabpal on 21/8/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import "CaptureSignatureVC.h"
#import <QuartzCore/QuartzCore.h>
#import "AppConstants.h"



@interface CaptureSignatureVC ()

@end

@implementation CaptureSignatureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    
    NSLog(@"This is signature %@", _signatureIndex);
    NSData *data;
//    if ([_signatureIndex isEqualToNumber:@1])
//        data = [[NSUserDefaults standardUserDefaults] objectForKey:SCREENING_PARTICIPANT_SIGNATURE];
//    else
//        data = [[NSUserDefaults standardUserDefaults] objectForKey:SCREENING_CONSENT_TAKER_SIGNATURE];
    
    NSMutableArray *signPathArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.signatureView setPathArray:signPathArray];
    CGFloat borderWidth = 2.0f;
    
    self.signatureView.layer.borderColor = [UIColor grayColor].CGColor;
    self.signatureView.layer.borderWidth = borderWidth;
    [self.signatureView setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"motion shaking happened!");
        // your code
    }
}

- (IBAction)clearSignature:(id)sender {
    [self.signatureView erase];
}

-(IBAction)captureSign:(id)sender {
    
    [self.signatureView captureSignatureWithIndex:[_signatureIndex intValue]];
    [self startSampleProcess:@""];
    [self.navigationController popViewControllerAnimated:YES];
    //display an alert to capture the person's name
    
//    UIAlertController * alertView=   [UIAlertController
//                                      alertControllerWithTitle:@"Saving signature with name"
//                                      message:@"Please enter your name"
//                                      preferredStyle:UIAlertControllerStyleAlert];
//
//    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = @"Name";
//
//    }];
//
//    UIAlertAction* yesButton = [UIAlertAction
//                                actionWithTitle:@"Yes, please"
//                                style:UIAlertActionStyleDefault
//                                handler:^(UIAlertAction * action)
//                                {
//                                    //Handel your yes please button action here
//                                    UITextField *textField = alertView.textFields[0];
//                                    userName = textField.text;
//
//                                    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
//                                    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
//                                    signedDate  = [dateFormatter stringFromDate:[NSDate date]];
//                                    if(userName != nil && ![userName isEqualToString:@""] && signedDate != nil  && ![signedDate isEqualToString:@""])
//                                    {
//                                        [alertView dismissViewControllerAnimated:YES completion:nil];
//                                        [self.signatureView captureSignature];
//                                        [self startSampleProcess:[NSString stringWithFormat:@"By: %@, %@",userName,signedDate]];
//                                        [self.navigationController popViewControllerAnimated:YES];
//                                    }
//
//                                }];
//    UIAlertAction* noButton = [UIAlertAction
//                               actionWithTitle:@"No, thanks"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action)
//                               {
//                                   //Handel no, thanks button
//                                   [alertView dismissViewControllerAnimated:YES completion:nil];
//                               }];
//
//    [alertView addAction:yesButton];
//    [alertView addAction:noButton];
//    [self presentViewController:alertView animated:YES completion:nil];
    
    
}

-(void)startSampleProcess:(NSString*)text {
    UIImage *captureImage = [self.signatureView signatureImage:CGPointMake(self.signatureView.frame.origin.x+10 , self.signatureView.frame.size.height-25) text:text];
    [self.delegate processCompleted:captureImage withIndex:_signatureIndex];
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

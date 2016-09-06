//
//  PreRegPatientDetailsViewController.m
//  NHS
//
//  Created by Nicholas on 7/25/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "PreRegPatientDetailsViewController.h"
#import "ServerComm.h"

@interface PreRegPatientDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PreRegPatientDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPatientData];
    NSLog(@"Patient %@ selected!", self.patientID);
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.backItem.title = @"Back";
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPatientData {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getPatientDataWithPatientID:self.patientID
          progressBlock:[self progressBlock]
          successBlock:[self successBlock]
          andFailBlock:[self errorBlock]];
}


#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"Patient Data GET Request in progress.");
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSArray *data = responseObject;      //somehow double brackets... (())
        NSLog(@"%@",data);
        NSDictionary *dict;
        dict = data[0];
        
        [self.textView setText:[dict description]];
        
        
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Patients data fetch failed");
    };
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

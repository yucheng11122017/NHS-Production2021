//
//  HomeViewController.m
//  NHS
//
//  Created by Mac Pro on 8/7/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *bloodTestBtn;
@property (weak, nonatomic) IBOutlet UIButton *followUpBtn;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([_isComm isEqualToNumber:@0]) {
        self.bloodTestBtn.hidden = YES;
        self.followUpBtn.hidden = YES;
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Home Page";
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.hidesBackButton = YES;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationItem.title = @"Home";
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutBtnPressed:(UIButton *)sender {
    NSLog(@"logout pressed");
    [self.navigationController popViewControllerAnimated:YES];
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

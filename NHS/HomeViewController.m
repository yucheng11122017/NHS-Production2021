//
//  HomeViewController.m
//  NHS
//
//  Created by Mac Pro on 8/7/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "PatientPreRegTableViewController.h"
#import "PatientScreeningListTableViewController.h"
#import "FollowUpListTableViewController.h"
#import "BTListTableViewController.h"

#import "HTPressableButton.h"
#import "UIColor+HTColor.h"



@interface HomeViewController ()

@property (strong, nonatomic) HTPressableButton *preRegBtn;
@property (strong, nonatomic) HTPressableButton *screeningBtn;
@property (strong, nonatomic) HTPressableButton *followUpBtn;
@property (strong, nonatomic) HTPressableButton *bloodTestBtn;
@property (strong, nonatomic) UIBarButtonItem *logoutBtn;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([_isComm isEqualToNumber:@0]) {
        self.bloodTestBtn.hidden = YES;
        self.followUpBtn.hidden = YES;
    }
    
    [self createButtons];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Home Page";
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = self.logoutBtn;
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

- (void) createButtons {
    // Rounded rectangular default color button
    int yPos1 = (self.view.frame.size.height - (self.navigationController.navigationBar.frame.size.height + 60 + 40))/4;
    CGRect frame1 = CGRectMake(30, yPos1, self.view.frame.size.width - 60, 50);
    self.preRegBtn = [[HTPressableButton alloc] initWithFrame:frame1 buttonStyle:HTPressableButtonStyleRounded];
    [self.preRegBtn setTitle:@"Pre-Registration" forState:UIControlStateNormal];
    [self.preRegBtn addTarget:self action:@selector(preRegBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.preRegBtn];
    
    
    int yPos2 = yPos1*2;
    CGRect frame2 = CGRectMake(30, yPos2, self.view.frame.size.width - 60, 50);
    self.screeningBtn = [[HTPressableButton alloc] initWithFrame:frame2 buttonStyle:HTPressableButtonStyleRounded];
    [self.screeningBtn setButtonColor:[UIColor ht_turquoiseColor]];
    [self.screeningBtn setShadowColor:[UIColor ht_greenSeaColor]];
    [self.screeningBtn setTitle:@"Screening" forState:UIControlStateNormal];
    [self.screeningBtn addTarget:self action:@selector(screeningBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.screeningBtn];
    
    int yPos3 = yPos1*3;
    CGRect frame3 = CGRectMake(30, yPos3, self.view.frame.size.width - 60, 50);
    self.followUpBtn = [[HTPressableButton alloc] initWithFrame:frame3 buttonStyle:HTPressableButtonStyleRounded];
    [self.followUpBtn setButtonColor:[UIColor ht_sunflowerColor]];
    [self.followUpBtn setShadowColor:[UIColor ht_citrusColor]];
    [self.followUpBtn setTitle:@"Follow Up" forState:UIControlStateNormal];
    [self.followUpBtn addTarget:self action:@selector(followUpBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.followUpBtn];
    
    int yPos4 = yPos1*4;
    CGRect frame4 = CGRectMake(30, yPos4, self.view.frame.size.width - 60, 50);
    self.bloodTestBtn = [[HTPressableButton alloc] initWithFrame:frame4 buttonStyle:HTPressableButtonStyleRounded];
    [self.bloodTestBtn setButtonColor:[UIColor ht_grapeFruitColor]];
    [self.bloodTestBtn setShadowColor:[UIColor ht_grapeFruitDarkColor]];
    [self.bloodTestBtn setTitle:@"Blood Test" forState:UIControlStateNormal];
    [self.bloodTestBtn addTarget:self action:@selector(bloodTestBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bloodTestBtn];
    
    self.logoutBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Logout"] style:UIBarButtonItemStylePlain target:self action:@selector(logoutBtnPressed:)];
}

#pragma mark - Buttons Action

- (IBAction) preRegBtnPressed: (HTPressableButton *) sender {
    [self performSegueWithIdentifier:@"HomeToPreRegListSegue" sender:self];
}

- (IBAction) screeningBtnPressed: (HTPressableButton *) sender {
    [self performSegueWithIdentifier:@"HomeToScreeningListSegue" sender:self];
}

- (IBAction) followUpBtnPressed: (HTPressableButton *) sender {
    [self performSegueWithIdentifier:@"HomeToFollowUpListSegue" sender:self];
}

- (IBAction) bloodTestBtnPressed: (HTPressableButton *) sender {
    [self performSegueWithIdentifier:@"HomeToBloodTestListSegue" sender:self];
}

- (IBAction) logoutBtnPressed: (UIBarButtonItem *) sender {
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

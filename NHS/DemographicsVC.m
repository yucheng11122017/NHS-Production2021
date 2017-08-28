//
//  DemographicsVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/11/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "DemographicsVC.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"


@interface DemographicsVC () {
    BOOL shownOverlayView;
}


@property UIView *backgroundDimmingView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage* genogramImage;
@property (strong, nonatomic) UIView *infoBox;


@end

@implementation DemographicsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.genogramImage = [[UIImage alloc]init];
    _imageView.hidden = YES;
    shownOverlayView = false;
    
    if(!self.backgroundDimmingView){
        self.backgroundDimmingView = [self buildBackgroundDimmingView];
        [self.view addSubview:self.backgroundDimmingView];
        [self.view insertSubview:_containerView aboveSubview:_backgroundDimmingView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImage:) name:@"displayImage" object:nil];
    
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    self.navigationItem.rightBarButtonItem = modalButton;
    
    [self setupInfoBox];
}

- (void) viewDidLayoutSubviews {
    if (shownOverlayView) {
        [self dismissContainerWithAnimation:YES];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!shownOverlayView) {
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.containerView.center = self.view.center;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             shownOverlayView = true;
                         }
                     }];
    } else {
        [self setupImageViewAndNavigationController];
        [SVProgressHUD showSuccessWithStatus:@"Image imported!"];
    }

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController ) {
        self.navigationController.hidesBarsOnTap = NO;  //go back to default
    }
}

- (BOOL)prefersStatusBarHidden {return YES;}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)buildBackgroundDimmingView{
    
    UIView *bgView;
    //blur effect for iOS8
    CGFloat frameHeight = self.view.frame.size.height;
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat sideLength = frameHeight > frameWidth ? frameHeight : frameWidth;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        UIBlurEffect *eff = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        bgView = [[UIVisualEffectView alloc] initWithEffect:eff];
        bgView.frame = CGRectMake(0, 0, sideLength, sideLength);
    }
    else {
        bgView = [[UIView alloc] initWithFrame:self.view.frame];
        bgView.backgroundColor = [UIColor blackColor];
    }
//    bgView.alpha = 0.0;
//    if(self.tapBackgroundToDismiss){
//        [bgView addGestureRecognizer:
//         [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                 action:@selector(cancelButtonPressed:)]];
//    }
    return bgView;
}

- (void) dismissContainerWithAnimation: (BOOL) animated {
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.containerView.frame = CGRectOffset(self.containerView.frame, 0, +600);    //shift it down by 600
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             [self.containerView removeFromSuperview];
                             self.backgroundDimmingView.hidden = YES;
                             
                         }

                     }];
}

- (void) setupImageViewAndNavigationController {
    self.imageView.frame = self.view.frame;
    [self.imageView setImage:_genogramImage];
    self.imageView.hidden = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.hidesBarsOnTap = true;    //to hide the top bar when tapped elsewhere
}

- (void) infoButtonAction: (UIButton *) sender {
    if (_infoBox.alpha == 0) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _infoBox.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 //do nothing.
                             }
                             
                         }];
    } else {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _infoBox.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 //do nothing.
                             }
                             
                         }];
    }
}

- (void) setupInfoBox {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _infoBox = [[UIView alloc] initWithFrame:CGRectMake(100, 50, 250, 100)];     //trying to find out its center.
    _infoBox.backgroundColor = [UIColor colorWithRed:193/255.0 green:241/255.0 blue:255/255.0 alpha:1.0];
    _infoBox.layer.cornerRadius = 5.0;
    
    _infoBox.center = CGPointMake(CGRectGetMidX(self.view.bounds), _infoBox.center.y);  //only center horizontally, NOT vertically
    [self.view addSubview:_infoBox];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    nameLabel.text = [NSString stringWithFormat:@"Name: %@", [defaults objectForKey:kName]];
    nameLabel.font = [UIFont systemFontOfSize:12.0];
    nameLabel.textColor = [UIColor blueColor];
    [_infoBox addSubview:nameLabel];
    
    UILabel *nricLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 200, 20)];
    nricLabel.text = [NSString stringWithFormat:@"NRIC: %@", [defaults objectForKey:kNRIC]];
    nricLabel.font = [UIFont systemFontOfSize:12.0];
    nricLabel.textColor = [UIColor blueColor];
    [_infoBox addSubview:nricLabel];
    
    UILabel *citizenshipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 200, 20)];
    citizenshipLabel.text = [NSString stringWithFormat:@"Citizenship: %@", [defaults objectForKey:kCitizenship]];
    citizenshipLabel.font = [UIFont systemFontOfSize:12.0];
    citizenshipLabel.textColor = [UIColor blueColor];
    [_infoBox addSubview:citizenshipLabel];
    
    UILabel *religionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 200, 20)];
    religionLabel.text = [NSString stringWithFormat:@"Religion: %@", [defaults objectForKey:kReligion]];
    religionLabel.font = [UIFont systemFontOfSize:12.0];
    religionLabel.textColor = [UIColor blueColor];
    [_infoBox addSubview:religionLabel];
    
    _infoBox.alpha = 0;
    
}
#pragma mark - NSNotificationCenter
- (void) showImage: (NSNotification *) notification {
    _genogramImage = [notification.userInfo objectForKey:@"image"];

    
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

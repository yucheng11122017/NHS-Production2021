//
//  DemographicsVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/11/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "DemographicsVC.h"
#import "SVProgressHUD.h"


@interface DemographicsVC () {
    BOOL shownOverlayView;
}


@property UIView *backgroundDimmingView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage* genogramImage;


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

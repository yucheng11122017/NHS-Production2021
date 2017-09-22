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
#import "ServerComm.h"
#import "ScreeningDictionary.h"
#import "KAStatusBar.h"


#define GENOGRAM_LOADED_NOTIF @"Genogram image downloaded"


@interface DemographicsVC () {
    BOOL shownOverlayView;
    BOOL genogramExist;
    BOOL isFormFinalized;
}


@property UIView *backgroundDimmingView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage* genogramImage;
@property (strong, nonatomic) UIView *infoBox;
@property (strong, nonatomic) NSMutableArray *pushPopTaskArray;


@end

@implementation DemographicsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFormFinalized = false;
    
    self.genogramImage = [[UIImage alloc]init];
    self.pushPopTaskArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageExist:) name:GENOGRAM_LOADED_NOTIF object:nil];
    
    genogramExist = false;
    
    NSDictionary *fullScreeningForm = [[ScreeningDictionary sharedInstance] dictionary];
    
    NSDictionary *checkDict = fullScreeningForm[SECTION_CHECKS];
    
    if (checkDict != nil && checkDict != (id)[NSNull null]) {
        NSNumber *check = checkDict[kCheckGeno];
        if ([check isKindOfClass:[NSNumber class]]) {
            isFormFinalized = [check boolValue];
        }
    }
    

    if ([fullScreeningForm objectForKey:SECTION_GENOGRAM] != nil && [fullScreeningForm objectForKey:SECTION_GENOGRAM] != (id)[NSNull null]) {   //genogram dictionary exists
        NSDictionary *genogramDict = [fullScreeningForm objectForKey:SECTION_GENOGRAM];
        if ([genogramDict objectForKey:kFilename] != nil && [genogramDict objectForKey:kFilename] != (id)[NSNull null]) {
            genogramExist = true;
        }
    }
    
    if (genogramExist) {
        shownOverlayView = true;
        [self.containerView removeFromSuperview];   //don't show containerView at all!
        NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
        [[ServerComm sharedServerCommInstance] retrieveGenogramImageForResident:[defaults objectForKey:kResidentId] withNric:[defaults objectForKey:kNRIC]];
    } else {
    
        _imageView.hidden = YES;
        shownOverlayView = false;
        
        if(!self.backgroundDimmingView){
            self.backgroundDimmingView = [self buildBackgroundDimmingView];
            [self.view addSubview:self.backgroundDimmingView];
            [self.view insertSubview:_containerView aboveSubview:_backgroundDimmingView];
        }
        
        
    }
    
    if (isFormFinalized) {
        
    }
    else {
        
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageAfterPicker:) name:@"displayImage" object:nil];
    //Setup InfoButton
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
        if (!genogramExist) // this will be done after fetching the image for genogram exist case
            [self setupImageViewAndNavigationController];
    }

}

- (void) viewWillDisappear:(BOOL)animated {
    
    [KAStatusBar dismiss];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    if (self.isMovingFromParentViewController ) {
        self.navigationController.hidesBarsOnTap = NO;  //go back to default
    }
    
    [super viewWillDisappear:animated];
    
    
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
- (void) imageExist: (NSNotification *) notification {
    NSString *genogramImagePath = [[ServerComm sharedServerCommInstance] getretrievedGenogramImagePath];
    _genogramImage = [UIImage imageWithContentsOfFile:genogramImagePath];
    
    [self setupImageViewAndNavigationController];
}

- (void) saveImageAfterPicker: (NSNotification *) notification {
    _genogramImage = [notification.userInfo objectForKey:@"image"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client saveGenogram:_genogramImage forResident:[defaults objectForKey:kResidentId] withNric:[defaults objectForKey:kNRIC]];
    [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:kCheckGeno andNewContent:@"1"];    //post this for completion too.
    
}

#pragma mark - Buttons

-(void)editBtnPressed:(UIBarButtonItem * __unused)button
{

//    self.navigationItem.rightBarButtonItem = nil;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finalize" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeBtnPressed:)];
    
    [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:kCheckGeno andNewContent:@"0"]; //un-finalize it
}

- (void) finalizeBtnPressed: (UIBarButtonItem * __unused) button {
    
    
    [self postSingleFieldWithSection:SECTION_CHECKS andFieldName:kCheckGeno andNewContent:@"1"];
    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showSuccessWithStatus:@"Completed!"];
    
//    self.navigationItem.rightBarButtonItem = nil;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnPressed:)];
}


#pragma mark - Post data to server methods

- (void) postSingleFieldWithSection:(NSString *) section andFieldName: (NSString *) fieldName andNewContent: (NSString *) content {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *resident_id = [defaults objectForKey:kResidentId];
    
    if ((content != (id)[NSNull null]) && (content != nil)) {   //make sure don't insert nil or null value to a dictionary
        
        NSDictionary *dict = @{kResidentId:resident_id,
                               kSectionName:section,
                               kFieldName:fieldName,
                               kNewContent:content
                               };
        
        NSLog(@"Uploading %@ for $%@$ field", content, fieldName);
        [KAStatusBar showWithStatus:@"Syncing..." andBarColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:0 alpha:1.0]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [_pushPopTaskArray addObject:dict];
        
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postDataGivenSectionAndFieldName:dict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
    }
}

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"%@", responseObject);
        
        [_pushPopTaskArray removeObjectAtIndex:0];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [KAStatusBar showWithStatus:@"All changes saved" barColor:[UIColor colorWithRed:51/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] andRemoveAfterDelay:[NSNumber numberWithFloat:2.0]];
        
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"<<< SUBMISSION FAILED >>>");
        
        NSDictionary *retryDict = [_pushPopTaskArray firstObject];
        
        NSData *errorData = [[error userInfo] objectForKey:ERROR_INFO];
        NSLog(@"error: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
        
        
        NSLog(@"\n\nRETRYING...");
        
        ServerComm *client = [ServerComm sharedServerCommInstance];
        [client postDataGivenSectionAndFieldName:retryDict
                                   progressBlock:[self progressBlock]
                                    successBlock:[self successBlock]
                                    andFailBlock:[self errorBlock]];
        
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

//
//  AutorefractorImageVC.m
//  NHS
//
//  Created by Nicholas Wong on 10/2/18.
//  Copyright © 2018 NUS. All rights reserved.
//

#import "AutorefractorImageVC.h"
#import "OverlayView.h"
#import "ServerComm.h"
#import "AppConstants.h"
#import "KAStatusBar.h"
#import "ScreeningDictionary.h"
#import "ResidentProfile.h"

//Change this value to toggle between custom camera or standard camera
#define CUSTOM_CAMERA 0;


//transform values for full screen support
#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1.12412

//iphone screen dimensions
#define SCREEN_WIDTH  320
#define SCREEN_HEIGHT 480

#define AUTOREFRACTOR_LOADED_NOTIF @"Autorefractor image downloaded"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface AutorefractorImageVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *scannedImage;
@property (strong, nonatomic) UIToolbar *toolbar;

@end

@implementation AutorefractorImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageExist:) name:AUTOREFRACTOR_LOADED_NOTIF object:nil];
    
    NSLog(@"**** **** **** ***\n THIS IS THE DICTIONARY\n\n %@", _imageDict);
    
    if (_imageDict != nil && _imageDict != (id)[NSNull null]) {
        [self getAutorefractorImageFromServer];
    } else {
        [self launchCameraView];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [KAStatusBar dismiss];
    [[ScreeningDictionary sharedInstance] fetchFromServer];
    
    if (self.isMovingFromParentViewController ) {
        self.navigationController.hidesBarsOnTap = NO;  //go back to default
    }
    
    [super viewWillDisappear:animated];
}


- (void) launchCameraView {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    //    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]; //Available for both photo and video taking
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.videoQuality = 4;    // Changing the resolution to Full HD
    
    BOOL cameraMode=CUSTOM_CAMERA;
    if(cameraMode) {
        //newly added
        picker.showsCameraControls = NO;
        picker.navigationBarHidden = YES;
        picker.toolbarHidden = YES;
        
        //create an overlay view instance
        OverlayView *overlay = [[OverlayView alloc]
                                initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        picker.cameraViewTransform =
        CGAffineTransformScale(picker.cameraViewTransform,
                               CAMERA_TRANSFORM_X,
                               CAMERA_TRANSFORM_Y);
        //set our custom overlay view
        picker.cameraOverlayView = overlay;
    }
    
    
    //    overlay.pickerReference = picker;
    //    picker.delegate = overlay;
    
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) getAutorefractorImageFromServer {
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    [[ServerComm sharedServerCommInstance] retrieveAutorefractorFormImageForResident:[defaults objectForKey:kResidentId] withNric:[defaults objectForKey:kNRIC]];
}


#pragma mark - NSNotificationCenter
- (void) imageExist: (NSNotification *) notification {
    NSString *scannedImagePath = [[ServerComm sharedServerCommInstance] getRetrievedAutorefractorFormImagePath];
    _scannedImage = [UIImage imageWithContentsOfFile:scannedImagePath];
    
    [self setupImageViewAndNavigationController];
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if([info[UIImagePickerControllerMediaType]isEqualToString:[NSString stringWithFormat:@"%@",kUTTypeImage]])
    {
        //Saving STILL IMAGE
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        
        NSData *imageData = UIImageJPEGRepresentation(chosenImage, 1.0);
        
        
        if([UIImage imageWithData:imageData].size.width < [UIImage imageWithData:imageData].size.height)       //If portrait image
        {
            //Change the imageView size to fit nicely to a portrait image
            //self.imageCapturedView.contentMode = UIViewContentModeRedraw;
            //            [self.imageCapturedView setFrame:CGRectMake(20, 268, 335, 335)];
            //            [self.imageCapturedView setBounds:CGRectMake(20, 268, 335, 335)];
            
            
        }
        //If landscape photo
        else {
            //do nothing
        }
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view setNeedsDisplay];
        self.imageView.image = chosenImage;
        
        NSLog(@"Image saved");
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        ServerComm *client = [ServerComm sharedServerCommInstance];
        
        [client saveAutorefractorFormImage:chosenImage
                         forResident:[defaults objectForKey:kResidentId]
                            withNric:[defaults objectForKey:kNRIC]];
    }
}

#pragma mark - Layout Stuffs
- (void) setupImageViewAndNavigationController {
    
    if (_scannedImage.size.width > _scannedImage.size.height) {   //portrait image
        _scannedImage = [self rotateImage:_scannedImage byDegree:90];
    }
    [self.imageView setImage:_scannedImage];
    
    self.imageView.hidden = NO;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.hidesBarsOnTap = true;    //to hide the top bar when tapped elsewhere
    
    [self createBottomBar];
}

- (void) createBottomBar {
    CGRect frame, remain;
    CGRectDivide(self.view.bounds, &frame, &remain, 44, CGRectMaxYEdge);
    self.toolbar = [[UIToolbar alloc] initWithFrame:frame];
    UIBarButtonItem *replaceImageBtn = [[UIBarButtonItem alloc] initWithTitle:@"Replace Image" style:UIBarButtonItemStylePlain target:self action:@selector(launchCameraView)];
    //    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //    UIBarButtonItem *button2=[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:nil];
    [_toolbar setItems:[[NSArray alloc] initWithObjects:spacer,replaceImageBtn, spacer,nil]];
    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:_toolbar];
}

- (UIImage *)rotateImage:(UIImage*)image byDegree:(CGFloat)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    //[rotatedViewBox release];
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    
    CGContextTranslateCTM(bitmap, rotatedSize.width, rotatedSize.height);
    
    CGContextRotateCTM(bitmap, DEGREES_TO_RADIANS(degrees));
    
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width, -image.size.height, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
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

//
//  AutorefractorImageVC.h
//  NHS
//
//  Created by Nicholas Wong on 10/2/18.
//  Copyright © 2018 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>       //For kUTTypeImage
@import AVFoundation;

@interface AutorefractorImageVC : UIViewController <UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSDictionary *imageDict;

@end


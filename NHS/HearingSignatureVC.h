//
//  HearingSignatureVC.h
//  NHS
//
//  Created by rehabpal on 6/9/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CaptureSignatureVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface HearingSignatureVC : UIViewController <CaptureSignatureViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *signature1ImageView;

@end

NS_ASSUME_NONNULL_END

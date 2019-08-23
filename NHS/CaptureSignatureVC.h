//
//  CaptureSignatureVC.h
//  NHS
//
//  Created by rehabpal on 21/8/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UviSignatureView.h"

NS_ASSUME_NONNULL_BEGIN

// Protocol definition starts here
@protocol CaptureSignatureViewDelegate <NSObject>
@required
- (void)processCompleted:(UIImage*)signImage withIndex: (NSNumber *)index;
@end


@interface CaptureSignatureVC : UIViewController {
    // Delegate to respond back
    id <CaptureSignatureViewDelegate> _delegate;
    NSString *userName, *signedDate;
}

@property (nonatomic,strong) id delegate;
@property (strong, nonatomic) NSNumber *signatureIndex;
-(void)startSampleProcess:(NSString*)text;
// Instance method
@property (weak, nonatomic) IBOutlet UviSignatureView *signatureView;
- (IBAction)captureSign:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@end

NS_ASSUME_NONNULL_END

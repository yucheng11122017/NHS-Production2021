//
//  PdfReportViewController.h
//  NHS
//
//  Created by Nicholas Wong on 9/7/18.
//  Copyright © 2018 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface PdfReportViewController : UIViewController <WKNavigationDelegate, UIWebViewDelegate>


@property (strong, nonatomic) NSString *reportFilepath;


- (void) setReportFilepath:(NSString *)reportFilepath;
@end


//
//  ReportViewController.h
//  NHS
//
//  Created by Nicholas Wong on 9/20/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ReportViewController : UIViewController <WKNavigationDelegate, UIWebViewDelegate>


@property (strong, nonatomic) NSString *reportFilepath;


- (void) setReportFilepath:(NSString *)reportFilepath;
@end

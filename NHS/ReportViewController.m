//
//  ReportViewController.m
//  NHS
//
//  Created by Nicholas Wong on 9/20/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "ReportViewController.h"

@interface ReportViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSURL *url = [NSURL URLWithString:@"https://www.hackingwithswift.com"];
    NSURL *fileUrl = [NSURL URLWithString:_reportFilepath];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
    [_webView loadRequest:request];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self emptySandbox];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) shareAction: (UIBarButtonItem *) sender {
//    NSString *string = ...;
//    NSURL *URL = ...;
    
//    NSData *pdfData = [NSData dataWithContentsOfFile:_reportFilepath];
    NSURL *pdfUrl = [NSURL fileURLWithPath:_reportFilepath];
    NSArray *activityItems = [NSArray arrayWithObjects:pdfUrl, nil];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                         applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    [self presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         // ...
                                     }];
}

-(void) emptySandbox
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    while (files.count > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
                if (!removeSuccess) {
                    NSLog(@"Error deleting file: %@", fullPath);
                } else {
                    NSLog(@"Removed file: %@", fullPath);
                }
            }
            
        } else {
            NSLog(@"Error getting directory contents...");
        }
    }
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

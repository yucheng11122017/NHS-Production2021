//
//  ViewSignatureVC.m
//  NHS
//
//  Created by rehabpal on 21/8/19.
//  Copyright © 2019 NUS. All rights reserved.
//

#import "ViewSignatureVC.h"

@interface ViewSignatureVC () {
    NSNumber *index;
}

@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *insertSignature1Btn;
@property (weak, nonatomic) IBOutlet UIButton *insertSignature2Btn;

@end

@implementation ViewSignatureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat borderWidth = 2.0f;
    
    self.signature1ImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.signature1ImageView.layer.borderWidth = borderWidth;
    
    self.signature2ImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.signature2ImageView.layer.borderWidth = borderWidth;
    
    NSString *formName;
//    if ([sender.tag containsString:@"research"]) {
//        formName = @"ResearchConsent";
//    } else {
        formName = @"ScreeningConsent";
//    }
//    UIViewController *webVC = [[UIViewController alloc] init];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    NSURL *targetURL = [[NSBundle mainBundle] URLForResource:formName withExtension:@"pdf"];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [_webView setScalesPageToFit:YES];
    [_webView loadRequest:request];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hide Form" style:UIBarButtonItemStyleDone target:self action:@selector(hideWebViewBtnPressed:)];
    
    [self.view addSubview:_webView];
//    [self.navigationController pushViewController:webVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) hideWebViewBtnPressed:(UIBarButtonItem * __unused)button {
    if ([button.title containsString:@"Hide"]) {
        _webView.hidden = YES;
        button.title = @"Show Form";
    } else {
        _webView.hidden = NO;
        button.title = @"Hide Form";
    }
}

//implementation of delegate method
- (void)processCompleted:(UIImage*)signImage withIndex: (NSNumber *)index
{
    if ([index isEqualToNumber:@1]) {
        _insertSignature1Btn.hidden = YES;
        _signature1ImageView.image = signImage;
    } else {
        _insertSignature2Btn.hidden = YES;
        _signature2ImageView.image = signImage;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier hasPrefix:@"view_to_capture"]) {
        CaptureSignatureVC *destination = segue.destinationViewController;
        destination.delegate = self;
        NSUInteger tagNumber = ((UIButton *) sender).tag;
        destination.signatureIndex = [NSNumber numberWithInteger:tagNumber];
    }
}



#pragma mark - Sample protocol delegate


@end

//
//  PageGuideVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/11/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "PageGuideVC.h"
#import "AppConstants.h"

@interface PageGuideVC ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIButton *camScannerBtn;
@property (strong, nonatomic) UIButton *selectImageBtn;
@property (strong, nonatomic) UIView *infoBox;

@end

@implementation PageGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.viewControllers = controllers;
    self.view.layer.cornerRadius = 5.0;
    NSUInteger numberPages = 2;
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;

    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;
    
    self.pageControl.numberOfPages = numberPages;
    self.pageControl.currentPage = 0;
    
    [self loadScrollViewWithPage:1];    //one is already done
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {    //very important, otherwise can't scroll!
    NSUInteger numberPages = 2;
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
}

#pragma mark - Page stuffs
// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
//    [self loadScrollViewWithPage:page - 1];
//    [self loadScrollViewWithPage:page];
//    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}
- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= 2)
        return;
    
    // replace the placeholder if necessary
//    MyViewController *controller = [self.viewControllers objectAtIndex:page];
//    if ((NSNull *)controller == [NSNull null])
//    {
//        controller = [[MyViewController alloc] initWithPageNumber:page];
//        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
//    }
    
    UIView *pageView = [[UIView alloc] initWithFrame:self.scrollView.frame];
    
    UILabel *labelCopy = [UILabel new];
    labelCopy.frame = self.instructionLabel.frame;
    [labelCopy setFont:[UIFont systemFontOfSize:15]];
    labelCopy.text = @"Step 2: Select the genogram from your Camera Roll.";
    labelCopy.numberOfLines = 0;    //so that it will expand into multiple rows
    labelCopy.textAlignment = NSTextAlignmentCenter;
    
    self.selectImageBtn = [[UIButton alloc] initWithFrame:self.camScannerBtn.frame];
    [_selectImageBtn setImage:[UIImage imageNamed:@"galleryIcon"] forState:UIControlStateNormal];
    [_selectImageBtn addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [pageView addSubview:labelCopy];
    [pageView addSubview:_selectImageBtn];
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = CGRectGetWidth(frame) * page;
    frame.origin.y = 0;
    pageView.frame = frame;
    
    [self.scrollView addSubview:pageView];
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
    // update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)goToPage:(id)sender {
    [self gotoPage:YES];    // YES = animate
}


#pragma mark - UIButtons
- (IBAction)launchCamScanner:(id)sender {
    [self openScheme:@"camscannerfree:"];
}

-(IBAction)selectImage:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;  //defines whether you can edit the image or not.
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)openScheme:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Opened %@",scheme);
        } else {
            [self downloadCamScanner];
        }
    }];
}

- (void) downloadCamScanner {
    NSString *iTunesLink = @"itms://itunes.apple.com/sg/app/camscanner-lite-pdf-document-scanner-and-ocr/id388627783?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink] options:@{} completionHandler:^(BOOL success) {
        NSLog(@"Open iTunes Link successful!");
    }];
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
//    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImage *pickedImageOriginal = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    NSLog(@"%@", pickedImageOriginal);
    
    NSDictionary *dict = @{@"image":pickedImageOriginal};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"displayImage"
                                                        object:nil
                                                      userInfo:dict];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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

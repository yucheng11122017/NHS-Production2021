//
//  DrawingViewController.m
//  NHS
//
//  Created by Nicholas Wong on 6/11/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "DrawingViewController.h"
#import "ACEDrawingView.h"
#import "FontAwesomeKit.h"
#import "AFNetworking.h"

@interface DrawingViewController ()

//views
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ACEDrawingView *drawingView;

//buttons
@property (strong, nonatomic) IBOutlet UIButton *modeToggleButton;
@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) IBOutlet UIButton *redoButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation DrawingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"moi genoo";
    
    //configure scrollview
    [self.scrollView setContentSize:CGSizeMake(1000, 2000)];
    self.scrollView.scrollEnabled = NO;
    self.scrollView.scrollsToTop = NO;
    
    
    //configure drawing view
    self.drawingView = [[ACEDrawingView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
    [self.scrollView addSubview:self.drawingView];
    [self.drawingView setUserInteractionEnabled:YES];
    [self.drawingView setExclusiveTouch:YES];
    
    //setup mode toggle button
    FAKFontAwesome *drawIcon = [FAKFontAwesome pencilSquareIconWithSize:40.0f];
    [self.modeToggleButton setImage:[drawIcon imageWithSize:self.modeToggleButton.frame.size] forState:(UIControlStateNormal)];
    
    //setup undo-redo buttons
    FAKFontAwesome *undoIcon = [FAKFontAwesome undoIconWithSize:40.0f];
    [self.undoButton setImage:[undoIcon imageWithSize:self.undoButton.frame.size] forState:(UIControlStateNormal)];
    FAKFontAwesome *redoIcon = [FAKFontAwesome repeatIconWithSize:40.0f];
    [self.redoButton setImage:[redoIcon imageWithSize:self.redoButton.frame.size] forState:(UIControlStateNormal)];
    
    //setup save button
    FAKFontAwesome *saveIcon = [FAKFontAwesome floppyOIconWithSize:40.0f];
    [self.saveButton setImage:[saveIcon imageWithSize:self.saveButton.frame.size] forState:(UIControlStateNormal)];
}

- (IBAction)modeToggleButtonPressed:(UIButton *)sender {
    if (self.scrollView.isScrollEnabled) {
        NSLog(@"drawing ON");
        self.scrollView.scrollEnabled = NO;
        [self.drawingView setUserInteractionEnabled:YES];
        [self.drawingView setExclusiveTouch:YES];
        
        FAKFontAwesome *drawIcon = [FAKFontAwesome pencilSquareIconWithSize:40.0f];
        [sender setImage:[drawIcon imageWithSize:self.modeToggleButton.frame.size] forState:(UIControlStateNormal)];
    }
    else{
        NSLog(@"scroll ON");
        self.scrollView.scrollEnabled = YES;
        [self.drawingView setUserInteractionEnabled:NO];
        [self.scrollView setExclusiveTouch:YES];
        [self.drawingView setDrawMode:ACEDrawingModeScale];
        
        FAKFontAwesome *scrollIcon = [FAKFontAwesome squareOIconWithSize:40.0f];
        [sender setImage:[scrollIcon imageWithSize:self.modeToggleButton.frame.size] forState:(UIControlStateNormal)];
    }
}

- (IBAction)undoButtonPressed:(UIButton *)sender {
    if (self.drawingView.canUndo)
        [self.drawingView undoLatestStep];
}

- (IBAction)redoButtonPressed:(UIButton *)sender {
    if (self.drawingView.canRedo)
        [self.drawingView redoLatestStep];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    //create UIImage from drawing
    UIImage *drawingImage = self.drawingView.image;
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    
    // Save image.
    [UIImagePNGRepresentation(drawingImage) writeToFile:filePath atomically:YES];
    
    //upload image to server
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"https://nhs-som.nus.edu.sg/uploadGenogram"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePathUrl progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];
    [uploadTask resume];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

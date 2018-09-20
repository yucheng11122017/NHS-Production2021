//
//  OverlayView.m
//  Home Assessment
//
//  Created by Nicholas on 9/12/15.
//  Copyright © 2015 National University of Singapore. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //clear the background color of the overlay
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
//        //load an image to show in the overlay
//        UIImage *crosshair = [UIImage imageNamed:@"crosshair.png"];
//        UIImageView *crosshairView = [[UIImageView alloc]
//                                      initWithImage:crosshair];
//        crosshairView.frame = CGRectMake(0, 40, 320, 300);
//        crosshairView.contentMode = UIViewContentModeCenter;
//        [self addSubview:crosshairView];
//        [crosshairView release];
        
        //add a simple button to the overview
        //with no functionality at the moment
        UIButton *button = [UIButton
                            buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Catch now" forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 430, 320, 40);
        [button addTarget:self action:@selector(captureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(150,560,70,70)];
        
        [self circleFilledWithOutline:circleView fillColor:[UIColor whiteColor] outlineColor:[UIColor whiteColor]];
        [self addSubview:circleView];
        
        UIButton *circleRing = [UIButton buttonWithType:UIButtonTypeCustom];
        [circleRing setFrame:CGRectMake(155,565, 60, 60)];
      [self circleFilledWithOutline:circleRing fillColor:[UIColor clearColor] outlineColor:[UIColor blackColor]];
        [self addSubview:circleRing];
        
        [circleRing addTarget:self action:@selector(captureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

        
        
    }
    return self;
}

- (IBAction)captureBtnClicked:(id)sender {
    NSLog(@"Tap");
}

- (void) circleFilledWithOutline:(UIView*)circleView fillColor:(UIColor*)fillColor outlineColor:(UIColor*)outlinecolor{
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    float width = circleView.frame.size.width;
    float height = circleView.frame.size.height;
    [circleLayer setBounds:CGRectMake(2.0f, 2.0f, width-2.0f, height-2.0f)];
    [circleLayer setPosition:CGPointMake(width/2, height/2)];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2.0f, 2.0f, width-2.0f, height-2.0f)];
    [circleLayer setPath:[path CGPath]];
    [circleLayer setFillColor:fillColor.CGColor];
    [circleLayer setStrokeColor:outlinecolor.CGColor];
    [circleLayer setLineWidth:2.0f];
    [[circleView layer] addSublayer:circleLayer];
}

@end

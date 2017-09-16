//
//  UIScrollViewWithTouchesBegan.m
//  NHS
//
//  Created by Nicholas on 8/19/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "UIScrollViewWithTouchesBegan.h"

@implementation UIScrollViewWithTouchesBegan

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touches began!");
    [self minimiseAllKeyboards];
}

- (void)minimiseAllKeyboards {
    // this is shorter than the resign first responder method
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
@end

//
//  tempViewController.m
//  NHS
//
//  Created by Nicholas on 7/30/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "tempViewController.h"
#import "PreRegFormViewController.h"
#import "XLForm.h"

NSString * const kTextFieldAndTextView = @"TextFieldAndTextView";

@interface tempViewController ()

@end

@implementation tempViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}


#pragma mark - Helper

-(void)initializeForm
{
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptor];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"This form is actually an example"];
    section.footerTitle = @"ExamplesFormViewController.h, Select an option to view another example";
    [form addFormSection:section];
    
    // TextFieldAndTextView
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTextFieldAndTextView rowType:XLFormRowDescriptorTypeButton title:@"Text Fields"];
    row.action.viewControllerClass = [PreRegFormViewController class];
    [section addFormRow:row];
    

    
    self.form = form;
    
}


@end

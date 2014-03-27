//
//  LINSignUpStep2VC.m
//  Huihui
//
//  Created by Lin on 3/27/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINSignUpStep2VC.h"
#import "MKNetworkKit.h"
#import "BZGFormField.h"
#import "LINSignStepVC.h"



@interface LINSignUpStep2VC ()<BZGFormFieldDelegate>
@property (weak, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) IBOutlet BZGFormField *authCodeForm;
@property (strong, nonatomic) IBOutlet UIButton *button;
@end

@implementation LINSignUpStep2VC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.authCodeForm.layer.borderColor = [UIColor colorWithRed:255/255.0 green:140/255.0 blue:0.0 alpha:1.0].CGColor;
    self.authCodeForm.layer.borderWidth = 1;
    self.authCodeForm.textField.keyboardType = UIKeyboardTypePhonePad;
    
    self.authCodeForm.textField.placeholder = @"请输入收到的验证码";
    self.authCodeForm.textField.keyboardType = UIKeyboardTypePhonePad;
    
    [self.authCodeForm setTextValidationBlock:^BOOL(NSString *text) {
        NSString *authCodeReg = @"\\d{6}$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", authCodeReg];
        if (![predicate evaluateWithObject:text]) {
            return NO;
        }else{
            return YES;
        }
    }];
    self.authCodeForm.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegatge = [[UIApplication sharedApplication] delegate];
        _engine = [delegatge engine];
    }
    return _engine;
}

#pragma mark - BZGFormFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([self.authCodeForm formFieldState] == BZGFormFieldStateValid) {
        self.button.enabled = YES;
        self.button.backgroundColor = [UIColor colorWithRed:250/255. green:140/255. blue:0.0 alpha:1.0];
    }else{
        self.button.enabled = NO;
        self.button.backgroundColor = [UIColor lightGrayColor];
    }
    
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)summit:(id)sender {
    LINSignStepVC *stepVC = (LINSignStepVC *)self.stepsController;
    stepVC.authCode = self.authCodeForm.textField.text;
    [stepVC showNextStep];
}

@end

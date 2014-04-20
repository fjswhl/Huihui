//
//  LINSignUpStep3VC.m
//  Huihui
//
//  Created by Lin on 3/27/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINSignUpStep3VC.h"
#import "BZGFormField.h"
#import "LINSignStepVC.h"
#import "MKNetworkKit.h"
#import "NSString+Md5.h"
#import "MBProgressHUD.h"
#import "LINRootVC.h"
NSString *const __apiRegister = @"index.php/User/register";
NSString *const __apiRestPwd = @"index.php/User/resetSecret";

typedef NS_ENUM(NSInteger, LinRegisterState){
    LinRegisterStateAlreadySigned,
    LinRegisterStateAuchCodeError,
    LinRegisterStatePhoneError,
    LinRegisterStatePwdError,
    LinRegisterStateOK
};

@interface LINSignUpStep3VC ()<BZGFormFieldDelegate>

@property (strong, nonatomic) IBOutlet BZGFormField *passwordForm;
@property (strong, nonatomic) IBOutlet BZGFormField *confirmPasswordForm;

@property (strong, nonatomic) IBOutlet UIButton *summit;

@property (weak, nonatomic) MKNetworkEngine *engine;
@end

@implementation LINSignUpStep3VC

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
    self.passwordForm.delegate = self;
    self.confirmPasswordForm.delegate = self;
    
    
    self.passwordForm.layer.borderColor = [UIColor colorWithRed:255/255.0 green:140/255.0 blue:0.0 alpha:1.0].CGColor;
    self.passwordForm.layer.borderWidth = 1;
    
    self.confirmPasswordForm.layer.borderColor = [UIColor colorWithRed:255/255.0 green:140/255.0 blue:0.0 alpha:1.0].CGColor;
    self.confirmPasswordForm.layer.borderWidth = 1;
    
    self.passwordForm.textField.placeholder = @"6-32位数字字母符号组合";
    self.confirmPasswordForm.textField.placeholder = @"请再次输入设置的密码";
    
    [self.passwordForm.textField setSecureTextEntry:YES];
    [self.confirmPasswordForm.textField setSecureTextEntry:YES];
    __weak LINSignUpStep3VC *weakSelf = self;
    [self.passwordForm setTextValidationBlock:^BOOL(NSString *text) {
        NSString *pwdReg = @"[0-9|a-z]{6,32}";
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pwdReg];
        if (![test evaluateWithObject:text]) {
            return NO;
        }else{
            return YES;
        }
    }];
    
    [self.confirmPasswordForm setTextValidationBlock:^BOOL(NSString *text) {
        if ([text isEqualToString:weakSelf.passwordForm.textField.text] && [weakSelf.passwordForm formFieldState] == BZGFormFieldStateValid) {
            return YES;
        }else{
            return NO;
        }
    }];
    
    
    // 如果是重置密码 ,更改UI
    LINSignStepVC *stepVC = (LINSignStepVC *)self.stepsController;
    if (stepVC.isForgetPwd == YES) {
        [self.summit setTitle:@"确认提交新密码" forState: UIControlStateDisabled];
        [self.summit setTitle:@"确定提交新密码" forState:UIControlStateNormal];
    }
    
    
    [self.passwordForm.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {
    LINSignStepVC *stepVC = (LINSignStepVC *)self.stepsController;
    
   // __weak LINSignUpStep3VC *weakSelf = self;
    MKNetworkOperation *op = nil;
    
    NSString *postPwd = [NSString encripedPwdWithOriginalString:self.passwordForm.textField.text];
    NSLog(@"%@", postPwd);
    if (stepVC.isForgetPwd == YES) {
        op = [self.engine operationWithPath:__apiRestPwd params:@{@"phone":stepVC.phoneNumber,
                                                                  @"password":postPwd,
                                                                  @"CheckCode":stepVC.authCode} httpMethod:@"POST"];
        
        
    }else{
        op = [self.engine operationWithPath:__apiRegister params:@{@"phone":stepVC.phoneNumber,
                                                              @"password":postPwd,
                                                              @"registerCode":stepVC.authCode} httpMethod:@"POST"];
    }
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
        if (dic[@"error"] != nil) {
            NSString *errorCode = dic[@"error"];
            [self handleRegisterErrorWithState:[errorCode integerValue]];
            return;
        }
        if (stepVC.isForgetPwd == YES) {
                    [MBProgressHUD showTextHudToView:self.view text:@"修改密码成功"];
        }else{
                    [MBProgressHUD showTextHudToView:self.view text:@"注册成功"];
        }

        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged"];
        [[NSUserDefaults standardUserDefaults] setValue:stepVC.phoneNumber forKey:@"phoneNumber"];
        [[NSUserDefaults standardUserDefaults] setValue:self.passwordForm.textField.text forKey:@"password"];
        
        LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
        [rootVC loginCompletion:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        NSLog(@"注册成功");
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    [self.engine enqueueOperation:op];
    
}

- (void)handleRegisterErrorWithState:(LinRegisterState)state{
    NSString *errorStr = nil;
    if (state == LinRegisterStateAuchCodeError) {
        errorStr = @"验证码错误";
    }else{
        errorStr = @"系统错误,请稍后重试";
    }
    [MBProgressHUD showTextHudToView:self.view text:errorStr];
}

#pragma mark - Getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegatge = [[UIApplication sharedApplication] delegate];
        _engine = [delegatge engine];
    }
    return _engine;
}

#pragma mark - Form Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([self.passwordForm formFieldState] == BZGFormFieldStateValid &&
        [self.confirmPasswordForm formFieldState] == BZGFormFieldStateValid) {
        [self setSubmitButton:YES];
    }else{
        [self setSubmitButton:NO];
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
- (void)setSubmitButton:(BOOL)enabled{
    self.summit.enabled = enabled;
    if (enabled) {
        self.summit.backgroundColor = [UIColor colorWithRed:250/255.0 green:140/255.0 blue:0 alpha:1.0f];
    }else{
        self.summit.enabled = NO;
        self.summit.backgroundColor = [UIColor lightGrayColor];
    }
}


@end

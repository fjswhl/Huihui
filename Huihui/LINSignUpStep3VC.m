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

NSString *const __apiRegister = @"index.php/User/register";

typedef NS_ENUM(NSInteger, LinRegisterState){
    LinRegisterStateAlreadySigned,
    LinRegisterStateAuchCodeError,
    LinRegisterStatePhoneError,
    LinRegisterStatePwdError,
    LinRegisterStateOK
};

@interface LINSignUpStep3VC ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {
    LINSignStepVC *stepVC = (LINSignStepVC *)self.stepsController;
    NSLog(@"%@\n%@\n", stepVC.phoneNumber, stepVC.authCode);
    
    __weak LINSignUpStep3VC *weakSelf = self;
    MKNetworkOperation *op = [self.engine operationWithPath:__apiRegister params:@{@"phone":stepVC.phoneNumber,
                                                                                   @"password":weakSelf.passwordForm.textField.text,
                                                                                   @"registerCode":stepVC.authCode} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        if (dic[@"error"] != nil) {
            NSString *errorCode = dic[@"error"];
            [self handleRegisterErrorWithState:[errorCode integerValue]];
            return;
        }
        NSLog(@"注册成功");
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
    
}

- (void)handleRegisterErrorWithState:(LinRegisterState)state{
    NSLog(@"%i", state);
#warning wait
}

#pragma mark - Getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegatge = [[UIApplication sharedApplication] delegate];
        _engine = [delegatge engine];
    }
    return _engine;
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

@end

//
//  LINSignUpVC.m
//  Huihui
//
//  Created by Lin on 3/27/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINSignUpVC.h"
#import "BZGFormField.h"
#import "MKNetworkKit.h"
#import "QCheckBox.h"
#import "RMStepsController.h"
#import "LINSignStepVC.h"
#import "UIHyperlinksButton.h"
#import "MBProgressHUD.h"
NSString *const __apiGetVerification = @"index.php/User/getVerification";


typedef  NS_ENUM(NSInteger, GetAuthCodeState){
    GetAuthCodeStateFormatError,
    GetAuthCodeStateSystemError,
    GetAuthCodeStateRejected,
    GetAuthCodeStateParamUnknown,
    GetAuthCodeStateAlreadySigned,
    GetAuthCodeStateNotExist,
    GetAuthCodeStateOK
};


@interface LINSignUpVC ()<BZGFormFieldDelegate, QCheckBoxDelegate>
@property (strong, nonatomic) IBOutlet BZGFormField *phoneForm;
@property (strong, nonatomic) IBOutlet UIButton *getAuthCodeButton;
@property (weak, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) IBOutlet QCheckBox *check;

@property (strong, nonatomic) IBOutlet UIHyperlinksButton *xieyiButton;


@end

@implementation LINSignUpVC

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
    self.phoneForm.layer.borderColor = [UIColor colorWithRed:255/255.0 green:140/255.0 blue:0.0 alpha:1.0].CGColor;
    self.phoneForm.layer.borderWidth = 1;
    self.phoneForm.textField.keyboardType = UIKeyboardTypePhonePad;
    [self.xieyiButton setColor:[UIColor redColor]];
    
    //      如果是忘记密码,调整一下UI
    LINSignStepVC *stepVC = (LINSignStepVC *)self.stepsController;
    if (stepVC.isForgetPwd == YES) {
        self.phoneForm.textField.placeholder = @"请输入注册时的手机号";
        self.infoLabel.hidden = YES;
        self.xieyiButton.hidden = YES;
    }else{
        [self.view addSubview:self.check];
        self.phoneForm.textField.placeholder = @"请输入您的手机号";
    }

    __weak LINSignUpVC *weakSelf = self;
    
    [self.phoneForm setTextValidationBlock:^BOOL(NSString *text) {
        NSString *phoneRegex = @"^[1][358]\\d{9}$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
        if (![phoneTest evaluateWithObject:text]) {
            weakSelf.phoneForm.alertView.title = @"不合法的手机号";
            return NO;
        }else{
            return YES;
        }
    }];
    self.phoneForm.delegate = self;

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.phoneForm.textField becomeFirstResponder];
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

- (QCheckBox *)check{
    if (!_check) {
        _check = [[QCheckBox alloc] initWithDelegate:self];
        _check.frame = CGRectMake(self.infoLabel.frame.origin.x - 20, self.infoLabel.frame.origin.y, 21, 21);
        [_check setChecked:NO];
    }
    return _check;
}
#pragma mark - BZGFormFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

#pragma mark - QCheckBox Delegate

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    if ([self.phoneForm formFieldState] == BZGFormFieldStateValid && checked == YES) {
        [self setSubmitButton:YES];
    }else{
        [self setSubmitButton:NO];
    }
}

- (void)setSubmitButton:(BOOL)enabled{
    self.getAuthCodeButton.enabled = enabled;
    if (enabled) {
        self.getAuthCodeButton.backgroundColor = [UIColor colorWithRed:250/255.0 green:140/255.0 blue:0 alpha:1.0f];
    }else{
        self.getAuthCodeButton.enabled = NO;
        self.getAuthCodeButton.backgroundColor = [UIColor lightGrayColor];
    }
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
- (IBAction)fetchAutoCode:(UIButton *)sender {
    if ([self.phoneForm.textField isFirstResponder]) {
        [self.phoneForm.textField resignFirstResponder];
    }
    LINSignStepVC *stepVC = (LINSignStepVC *)self.stepsController;
    NSString *authCodeType = stepVC.isForgetPwd ? @"f" : @"r";
    
    MKNetworkOperation *op = [self.engine operationWithPath:__apiGetVerification params:@{@"phone":self.phoneForm.textField.text,
                                                                                          @"type":authCodeType} httpMethod:@"POST"];
    
    __weak LINSignUpVC *weakSelf = self;
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        if (dic[@"error"] != nil) {
            NSString *errorCode = dic[@"error"];
            [self handleGetAuthCodeWithState:[errorCode integerValue]];
            return;
        }
        //传递一些参数
        LINSignStepVC *stepVC = (LINSignStepVC *)self.stepsController;
        stepVC.phoneNumber = weakSelf.phoneForm.textField.text;
        [stepVC showNextStep];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    [self.engine enqueueOperation:op];
}

- (void)handleGetAuthCodeWithState:(GetAuthCodeState)state{
    if (state == GetAuthCodeStateAlreadySigned) {
        [MBProgressHUD showTextHudToView:self.view text:@"该号码已经注册过了"];
    }else if (state == GetAuthCodeStateRejected){
        [MBProgressHUD showTextHudToView:self.view text:@"一分钟之内只能发送一次验证码"];
    }else if (state == GetAuthCodeStateNotExist){
         [MBProgressHUD showTextHudToView:self.view text:@"号码不存在"];
    }else{
        [MBProgressHUD showTextHudToView:self.view text:@"系统错误"];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//
    LINSignStepVC *stepVC = (LINSignStepVC *)self.stepsController;
    if ([self.phoneForm formFieldState] == BZGFormFieldStateValid) {
        if (stepVC.isForgetPwd == YES) {
            [self setSubmitButton:YES];
        }else{
            if (self.check.checked == YES) {
                [self setSubmitButton:YES];
            }else{
                [self setSubmitButton:NO];
            }
        }
    }else{
        [self setSubmitButton:NO];
    }
    return YES;
}


@end

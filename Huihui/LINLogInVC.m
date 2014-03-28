//
//  LINLogInVC.m
//  Huihui
//
//  Created by Lin on 3/28/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINLogInVC.h"
#import "LINLogInTextField.h"
#import "MKNetworkKit.h"
#import "UIHyperlinksButton.h"
#import "LINRootVC.h"
#import "LINSignStepVC.h"
#import "NSString+Md5.h"
//  这里登入成功后会将用户名和密码保存进UserDefault

NSString *const __apiLogin = @"index.php/User/loadin";
@interface LINLogInVC ()

@property (strong, nonatomic) IBOutlet LINLogInTextField *phoneNumberForm;
@property (strong, nonatomic) IBOutlet LINLogInTextField *pwdForm;
@property (strong, nonatomic) IBOutlet UIHyperlinksButton *jumpSignUp;
@property (strong, nonatomic) IBOutlet UIHyperlinksButton *jumpForgetPwd;

@property (weak, nonatomic) MKNetworkEngine *engine;
@end

@implementation LINLogInVC

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
    
    [self.jumpSignUp setColor:[UIColor redColor]];
    [self.jumpForgetPwd setColor:[UIColor redColor]];
    // Do any additional setup after loading the view.
    [self.phoneNumberForm becomeFirstResponder];
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

- (IBAction)login:(id)sender {
    MKNetworkOperation *op = [self.engine operationWithPath:__apiLogin params:@{@"phone":self.phoneNumberForm.text, @"password":self.pwdForm.text} httpMethod:@"POST"];
    NSLog(@"%@,%@", self.pwdForm.text, [self.pwdForm.text md5]);
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
        if (dic[@"error"] != nil) {
            NSLog(@"用户名密码错误");
        }else{
#warning wait for md5 encode
            [[NSUserDefaults standardUserDefaults] setValue:self.phoneNumberForm.text forKey:@"phoneNumber"];
            [[NSUserDefaults standardUserDefaults] setValue:self.pwdForm.text forKey:@"password"];
            LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
            [rootVC setLogged:YES];
            
            NSLog(@"登入成功");
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    
    [self.engine enqueueOperation:op];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"logToSign"]) {
        LINSignStepVC *stepVC = (LINSignStepVC *)segue.destinationViewController;
        [stepVC setIsForgetPwd:YES];
    }
}

- (IBAction)forgetPwd:(UIButton *)sender {
    [self performSegueWithIdentifier:@"logToSign" sender:nil];
}

@end

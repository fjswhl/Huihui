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


extern NSString *const __apiLogin;
extern NSString *const __apiGetScretKey;

@interface LINLogInVC ()<LINRootVCDelegate>

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
    
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    rootVC.rootVCdelegate = self;
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
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    if (rootVC.logged == NO) {
        [rootVC loginWithName:self.phoneNumberForm.text password:self.pwdForm.text completion:nil];
    }else{
        
    }

//    MKNetworkOperation *getEncripCode = [self.engine operationWithPath:__apiGetScretKey params:nil httpMethod:@"POST"];
//    [getEncripCode addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//
//        NSDictionary *dic = [completedOperation responseJSON];
//#warning wait
//        NSNumber *number = dic[@"success"];
//        NSString *secretCode = [NSString stringWithFormat:@"%i",[number intValue]];
//        NSString *s1 = [[secretCode md5] substringToIndex:16];
//        //      密钥md5的前16位
//        
//        NSString *s2 = [[NSString encripedPwdWithOriginalString:self.pwdForm.text] substringToIndex:16];
//        //      注册时提交的密码的前16位
//
//        NSString *desPwd = [[s1 stringByAppendingString:s2] md5];
//        //      把s1和s2合并后再次md5
//        
////        NSLog(@"%@\n%@", s1, s2);
//
//        
//        
//        MKNetworkOperation *op = [self.engine operationWithPath:__apiLogin params:@{@"phone":self.phoneNumberForm.text, @"password":desPwd} httpMethod:@"POST"];
//
//        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//            
//            NSDictionary *dic = [completedOperation responseJSON];
//            NSLog(@"%@", dic);
//            if (dic[@"error"] != nil) {
//                NSLog(@"用户名密码错误");
//            }else{
//#warning wait for md5 encode
//                [[NSUserDefaults standardUserDefaults] setValue:self.phoneNumberForm.text forKey:@"phoneNumber"];
//                [[NSUserDefaults standardUserDefaults] setValue:self.pwdForm.text forKey:@"password"];
//                LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
//                [rootVC setLogged:YES];
//                [self.navigationController popToRootViewControllerAnimated:YES];
//                NSLog(@"登入成功");
//            }
//        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//#warning wait
//        }];
//        [self.engine enqueueOperation:op];
//        NSLog(@"%@", desPwd);
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//#warning wait
//    }];
//    
//    
//
//    [self.engine enqueueOperation:getEncripCode];
//  //  [self.engine enqueueOperation:op];

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

#pragma mark - LINRootVCDelegate
- (void)userDidLogin{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)pop:(id)sender {
        [self.navigationController popViewControllerAnimated:YES];
}

@end
























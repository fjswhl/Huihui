//
//  LINSignStepVC.m
//  Huihui
//
//  Created by Lin on 3/27/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINSignStepVC.h"

@implementation LINSignStepVC
- (void)viewDidLoad{
    [super viewDidLoad];
   // self.stepsBar.hideCancelButton = YES;
//    self.step.selectedBarColor = [UIColor colorWithRed:250/255.0f green:240/255.0 blue:0 alpha:1.0];
//    self.step.enabledBarColor = [UIColor colorWithRed:250/255.0f green:240/255.0 blue:0 alpha:1.0];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}


- (NSArray *)stepViewControllers{
    UIViewController *firstStep = [self.storyboard instantiateViewControllerWithIdentifier:@"sign1"];
    firstStep.step.title = @"输入手机号";
    
    UIViewController *secondStep = [self.storyboard instantiateViewControllerWithIdentifier:@"sign2"];
    
    secondStep.step.title = @"请输入验证码";
    
    UIViewController *thirdStep = [self.storyboard instantiateViewControllerWithIdentifier:@"sign3"];
    thirdStep.step.title = self.isForgetPwd ? @"重置密码" : @"设置密码";
    return @[firstStep, secondStep, thirdStep];
}

- (void)finishedAllSteps{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)pop:(id)sender {
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)canceled{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

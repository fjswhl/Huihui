//
//  LINRootVC.h
//  Huihui
//
//  Created by Lin on 3/28/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LINRootVC : UITabBarController

@property (assign, nonatomic, getter = isLogged) BOOL logged;
@property (strong, nonatomic) NSString *userPhoneNumber;
@property (strong, nonatomic) NSString *userPwd;

@end

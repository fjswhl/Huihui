//
//  LINRootVC.h
//  Huihui
//
//  Created by Lin on 3/28/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LINRootVCDelegate

@optional
- (void)userDidLogin;
- (void)userDidlogout;

@end

@interface LINRootVC : UITabBarController

@property (assign, nonatomic, getter = isLogged) BOOL logged;
@property (strong, nonatomic) NSString *userPhoneNumber;
@property (strong, nonatomic) NSString *userPwd;

@property (weak, nonatomic) id<LINRootVCDelegate> rootVCdelegate;
//              vc:用于从登入界面登入时,登入成功后弹到root
- (BOOL)loginWithName:(NSString *)name password:(NSString *)password completion:(void (^)(void))block;

- (BOOL)logout;

//              sessionid过时时自动重新登入
- (BOOL)loginCompletion:(void (^)(void))block;

- (void)setLogged:(BOOL)logged;
- (BOOL)logged;
@end



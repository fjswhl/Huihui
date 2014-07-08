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
@property (strong, nonatomic) NSDictionary *userInfo;
@property (weak, nonatomic) id<LINRootVCDelegate> rootVCdelegate;

@property (assign, nonatomic) BOOL isHidden;
//              vc:用于从登入界面登入时,登入成功后弹到root

/**
 *  以name和password(未加密)登入, 并在登入成功后调用block
 *
 *  @param name     用户名
 *  @param password 密码
 *  @param block    登入成功后执行的块
 *
 *  @return 暂时只返回真
 */
- (BOOL)loginWithName:(NSString *)name password:(NSString *)password completion:(void (^)(void))block failed:(void (^)(void))failedBlock;



- (BOOL)logout;

/**
 *  sessionid过时时自动重新登入, 该方法会调用-(BOOL)loginWithName:(NSString *)name password:(NSString *)password completion:(void (^)(void))block. 使用的name和password是已经存在userdefault里面的
 * 
 *  @param block    登入成功后执行的块
 *
 *  @return 暂时只返回真
 */
- (BOOL)loginCompletion:(void (^)(void))block failed:(void (^)(void))failedBlock;

/**
 *  设置userdefault的logged
 *
 *  @param  logged  是否登入
 *
 *  @return void
 */

- (void)fetchUserInfo;
- (void)setLogged:(BOOL)logged;
- (BOOL)logged;

- (void)hideTabbarAnimated:(BOOL)animated;
- (void)showTabbarAnimated:(BOOL)animated;
@end



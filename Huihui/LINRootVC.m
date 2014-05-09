//
//  LINRootVC.m
//  Huihui
//
//  Created by Lin on 3/28/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINRootVC.h"
#import "MKNetworkKit.h"
#import "NSString+Md5.h"
#import "UIColor+LINColor.h"
#import "MBProgressHUD.h"

//  这里登入成功后会将用户名和密码保存进UserDefault
//  key:phoneNumber  ,password


NSString *const __apiLogin = @"index.php/User/loadin";
NSString *const __apiGetScretKey = @"index.php/User/getSecretKey";
NSString *const __apiLogout = @"index.php/User/logout";
NSString *const __apiGetProfile = @"index.php/User/getProfile";
@interface LINRootVC ()

@property (weak, nonatomic) MKNetworkEngine *engine;
@end

@implementation LINRootVC

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
    self.tabBar.tintColor = [UIColor preferredColor];
    if ([self logged]) {
        [self loginWithName:self.userPhoneNumber password:self.userPwd completion:^{
            [self fetchUserInfo];
        } failed:^{
            ;
        }];
    }
    
    
    /*          获取用户信息          */
    
//    if ([self logged]) {
//        [self fetchUserInfo];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - Getter And Setter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegatge = [[UIApplication sharedApplication] delegate];
        _engine = [delegatge engine];
    }
    return _engine;
}

- (void)setLogged:(BOOL)logged{
    _logged = logged;
    [[NSUserDefaults standardUserDefaults] setBool:logged forKey:@"logged"];
}

- (BOOL)logged{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"logged"];
}

- (NSString *)userPhoneNumber{
    if (!_userPhoneNumber) {
        _userPhoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"phoneNumber"];
    }
    return _userPhoneNumber;
}

- (NSString *)userPwd{
    if (!_userPwd) {
        _userPwd = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    }
    return _userPwd;
}

- (BOOL)loginWithName:(NSString *)name password:(NSString *)password completion:(void (^)(void))block failed:(void (^)(void))failedBlock{
    [self.engine emptyCache];
    
    MKNetworkOperation *getEncripCode = [self.engine operationWithPath:__apiGetScretKey params:nil httpMethod:@"POST"];
    [getEncripCode addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *dic = [completedOperation responseJSON];
#warning wait
        NSNumber *number = dic[@"success"];
        NSString *secretCode = [NSString stringWithFormat:@"%i",[number intValue]];
        NSString *s1 = [[secretCode md5] substringToIndex:16];
        //      密钥md5的前16位
        
        NSString *s2 = [[NSString encripedPwdWithOriginalString:password] substringToIndex:16];
        //      注册时提交的密码的前16位
        
        NSString *desPwd = [[s1 stringByAppendingString:s2] md5];
        //      把s1和s2合并后再次md5
        
        //        NSLog(@"%@\n%@", s1, s2);
        
        
        MKNetworkOperation *op = [self.engine operationWithPath:__apiLogin params:@{@"phone":name, @"password":desPwd} httpMethod:@"POST"];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            
            NSDictionary *dic = [completedOperation responseJSON];
            NSLog(@"%@", dic);
            NSLog(@"%@,%@", name, password);
                           static int count = 0; //计数登入失败的次数
            if (dic[@"error"] != nil) {
                NSLog(@"%@", dic[@"error"]);
                count++;
                if (count < 2) {
                    [self loginWithName:name password:password completion:block failed:failedBlock];
                }else{
                    if (failedBlock) {
                        failedBlock();
                    }
                }
               // [MBProgressHUD showTextHudToView:self.view text:@"用户名或密码错误"];
                return;
            }else{
#warning wait for md5 encode
                count = 0;
                self.userPhoneNumber = name;
                self.userPwd = password;
                [[NSUserDefaults standardUserDefaults] setValue:name forKey:@"phoneNumber"];
                [[NSUserDefaults standardUserDefaults] setValue:password forKey:@"password"];
                [self setLogged:YES];

                if (self.rootVCdelegate) {
                    [self.rootVCdelegate userDidLogin];
                }
                
                if (block) {
                    block();
                }
                
                NSLog(@"登入成功");
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
        }];
        [self.engine enqueueOperation:op];
//        NSLog(@"%@", desPwd);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    
    
    
    [self.engine enqueueOperation:getEncripCode];
    //  [self.engine enqueueOperation:op];
    return true;
}

- (BOOL)logout{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiLogout params:nil httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [self.rootVCdelegate userDidlogout];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    [self.engine enqueueOperation:op];
    return true;
}

- (BOOL)loginCompletion:(void (^)(void))block failed:(void (^)(void))failedBlock{
    if ([self logged] == NO) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请先登入.";
        [hud hide:YES afterDelay:1.5f];
        return NO;
    }
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"phoneNumber"];
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    [self loginWithName:phoneNumber password:password completion:block failed:failedBlock];
    return true;
}


- (void)fetchUserInfo{
    MKNetworkOperation *op2 = [self.engine operationWithPath:__apiGetProfile params:nil httpMethod:@"POST"];
    [op2 addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        //      如果sessionid已经过期,自动重新登入
        if (dic[@"error"]) {
            NSNumber *errorCode = dic[@"error"];
            if ([errorCode intValue] == 0) {
                [self loginCompletion:^{
                    [self fetchUserInfo];
                } failed:nil];
                return;
            }
        }
        self.userInfo = dic[@"success"];
        NSLog(@"%@", self.userInfo);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    [self.engine enqueueOperation:op2];
}

- (void)hideTabbarAnimated:(BOOL)animated{
    [UIView animateWithDuration:0.4f animations:^{
            self.tabBar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.tabBar.frame));
    }];
    self.isHidden = YES;

}

- (void)showTabbarAnimated:(BOOL)animated{
    [UIView animateWithDuration:0.4f animations:^{
        self.tabBar.transform = CGAffineTransformIdentity;
    }];
    self.isHidden = NO;
}
@end



















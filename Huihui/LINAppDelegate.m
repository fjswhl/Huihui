//
//  LINAppDelegate.m
//  Huihui
//
//  Created by Lin on 3/24/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINAppDelegate.h"
#import "pinyin.h"
#import <ShareSDK/ShareSDK.h>
#import <QQConnection/QQConnection.h>
#import <QZoneConnection/QZoneConnection.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "NSString+Md5.h"
@implementation LINAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    NSLog(@"%@", [HTFirstLetter firstLetter:@"凌"]);
//    NSLog(@"%@\n%@", [@"hh1111" md5], [NSString md5:@"hh1111"]);
    
//    UITabBarController *rootVC = (UITabBarController *)self.window.rootViewController;
//    for (UINavigationController *navVC in rootVC.viewControllers) {
//        navVC.delegate = self;
//    }
    
    //  设置默认的schoolid
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }];
//    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back_button.png"]];
//    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back_button.png"]];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud valueForKey:@"schoolid"]) {
        [ud setValue:@(1) forKey:@"schoolid"];
    }
    
    if (![ud valueForKey:@"showImgOnlyWhenWifi"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showImgOnlyWhenWifi"];
    }
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [ShareSDK registerApp:@"1a912d3d0aba"];
    [ShareSDK connectSinaWeiboWithAppKey:@"3210166262" appSecret:@"d78c2f7097539b2de04496017df4d596" redirectUri:@"http://xdhuihui.sinaapp.com"];
    [ShareSDK connectTencentWeiboWithAppKey:@"801490222" appSecret:@"417df257cf65e79468cb9248e3939b47" redirectUri:@"http://xdhuihui.sinaapp.com"];

    [ShareSDK connectQZoneWithAppKey:@"101044706" appSecret:@"91e6e28b8e1945ac1d603179151642a4" qqApiInterfaceCls:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];

    [ShareSDK connectRenRenWithAppKey:@"6abd134b79e84e8b88bfd8554effb386" appSecret:@"d92a0ca22bd24939be08df727ebcfa61"];
    [ShareSDK connectWeChatTimelineWithAppId:@"wx24e1c667b64ac6a3" wechatCls:[WXApi class]];
    [ShareSDK connectWeChatSessionWithAppId:@"wx24e1c667b64ac6a3" wechatCls:[WXApi class]];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        _engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
        [_engine useCache];
    }
    return _engine;
}

//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
//    return self;
//}
//
//- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
//    return 0.4f;
//}
//
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
//    UIViewController *vc2 = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIViewController *vc1 = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    
//    UIView *con = [transitionContext containerView];
//    CGRect r2end = [transitionContext finalFrameForViewController:vc2];
//    CGRect r1end = [transitionContext finalFrameForViewController:vc1];
//    
//    UIView *v2 = vc2.view;
//    UIView *v1 = vc1.view;
//    
//    
//    v2.frame = r2end;
//    
////    UIView *shalldow = [[UIView alloc] initWithFrame:r2end];
////    shalldow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
////    shalldow.alpha = 0;
////    [con addSubview:shalldow];
//    [con addSubview:v2];
//    
//    UINavigationController *navVC = vc1.navigationController;
//    int ix1 = [navVC.viewControllers indexOfObject:vc1];
//    int ix2 = [navVC.viewControllers indexOfObject:vc2];
//    int dir = ix1 < ix2 ? 1 : -1;
//    
//    
//    v2.transform = CGAffineTransformMakeTranslation(360 * dir, 0);
//    [UIView animateWithDuration:0.4 animations:^{
////        shalldow.alpha = 1;
//        //        v1.frame = r1end;
//        //        v2.frame = r2end;
//  //      v1.transform = CGAffineTransformMakeTranslation(-100 * dir, 0);
//        v2.transform = CGAffineTransformIdentity;
//        v1.transform = CGAffineTransformMakeScale(0.9, 0.9);
//    }completion:^(BOOL finished) {
//        v1.transform = CGAffineTransformIdentity;
//        [transitionContext completeTransition:YES];
//    }];
//
//}


@end































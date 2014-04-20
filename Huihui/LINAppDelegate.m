//
//  LINAppDelegate.m
//  Huihui
//
//  Created by Lin on 3/24/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINAppDelegate.h"
#import "pinyin.h"

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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud valueForKey:@"schoolid"]) {
        [ud setValue:@(1) forKey:@"schoolid"];
    }
    
    if (![ud valueForKey:@"showImgOnlyWhenWifi"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showImgOnlyWhenWifi"];
    }
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    return YES;
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































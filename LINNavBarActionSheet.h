//
//  LINNavBarActionSheet.h
//  LINNavBarActionSheet
//
//  Created by Lin on 14-5-6.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LINNavBarActionSheet;

@protocol LINNavBarActionSheetDelegate <NSObject>
- (void)navBarActionSheet:(LINNavBarActionSheet *)navBarActionSheet clickedButtonAtIndex:(NSInteger)index;

@end

@interface LINNavBarActionSheet : UIView

@property (nonatomic, assign) id<LINNavBarActionSheetDelegate> delegate;
@property (strong, nonatomic, readonly) NSArray *buttonTitles;

@property (nonatomic, assign) BOOL isShown;

- (instancetype)initWithDelegate:(id<LINNavBarActionSheetDelegate>)delegate
                    buttonTitles:(NSArray *)buttonTitles;

- (void)showInViewController:(UIViewController *)viewController;

- (void)dismissAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))block;
@end

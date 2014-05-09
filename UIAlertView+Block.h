//
//  UIAlertView+Block.h
//  Huihui
//
//  Created by Lin on 14-5-9.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CompleteBlock) (NSInteger buttonIndex);

@interface UIAlertView (Block)

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showAlertViewWithCompleteBlock:(CompleteBlock) block;

@end
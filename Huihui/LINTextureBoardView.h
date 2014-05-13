//
//  LINTextureBoardView.h
//  test
//
//  Created by Lin on 14-5-12.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LINTextureBoardView;

@protocol LINTextureBoardViewDelegate <NSObject>

- (void)textureBoardView:(LINTextureBoardView *)textureBoardView didClickedButtonWithColor:(UIColor *)color;

@end

@interface LINTextureBoardView : UIView


@property (assign, nonatomic) id<LINTextureBoardViewDelegate> delegate;
@end

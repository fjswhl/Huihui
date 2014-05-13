//
//  UIButton+Color.m
//  Huihui
//
//  Created by Lin on 14-5-4.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "UIButton+Color.h"

@implementation UIButton (Color)
- (void)setBackgroundImageWithColor:(UIColor *)color{
    [self setBackgroundImage:[self resizableImageWithColor:color] forState:UIControlStateNormal];
}

- (void)setBackgroundImageWithColor:(UIColor *)color forState:(UIControlState)state{
    [self setBackgroundImage:[self resizableImageWithColor:color] forState:state];
}

- (UIImage *)resizableImageWithColor:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1,1), YES, 0.0);
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 1, 1));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    return [img resizableImageWithCapInsets:UIEdgeInsetsZero];
}
@end

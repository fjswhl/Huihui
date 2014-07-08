//
//  UIImage+ColorImage.m
//  test1
//
//  Created by Lin on 14-5-21.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "UIImage+ColorImage.h"

@implementation UIImage (ColorImage)


+ (UIImage *)resizableImageWithColor:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1,1), YES, 0.0);
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 1, 1));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    return [img resizableImageWithCapInsets:UIEdgeInsetsZero];
}
@end

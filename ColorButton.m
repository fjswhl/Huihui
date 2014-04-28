//
//  ColorButton.m
//  btn
//
//  Created by LYZ on 14-1-10.
//  Copyright (c) 2014年 LYZ. All rights reserved.
//

#import "ColorButton.h"
@implementation ColorButton

- (id)initWithFrame:(CGRect)frame FromColorArray:(NSMutableArray*)colorArray ByGradientType:(GradientType)gradientType
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *backImage = [self buttonImageFromColors:colorArray ByGradientType:gradientType];
        [self setBackgroundImage:backImage forState:UIControlStateNormal];
        self.layer.cornerRadius = 4.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (UIImage*) buttonImageFromColors:(NSArray*)colors ByGradientType:(GradientType)gradientType{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, self.frame.size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(self.frame.size.width, 0.0);
            break;
        case 2:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(self.frame.size.width, self.frame.size.height);
            break;
        case 3:
            start = CGPointMake(self.frame.size.width, 0.0);
            end = CGPointMake(0.0, self.frame.size.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)resizableImageWithColor:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1,1), YES, 0.0);
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 1, 1));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    return [img resizableImageWithCapInsets:UIEdgeInsetsZero];
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundImage:[self resizableImageWithColor:color] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setBackgroundImageWithColor:(UIColor *)color{
    [self setBackgroundImage:[self resizableImageWithColor:color] forState:UIControlStateNormal];
}
@end


//
//  LINPickerSchoolViewController.h
//  Huihui
//
//  Created by Lin on 4/13/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LINPickerSchoolDelegatge

- (void)userDidChangeSchoolid:(NSInteger)schoolid;

@end

@interface LINPickerSchoolViewController : UIViewController
@property (strong, nonatomic) UIImage *backImage;

@property (weak, nonatomic) id<LINPickerSchoolDelegatge> delegate;
@end

//
//  LINMoodCommentViewController.h
//  Huihui
//
//  Created by Lin on 14-5-13.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LINMood.h"
@interface LINMoodCommentViewController : UIViewController

@property (weak, nonatomic) NSMutableDictionary *mood;
@property (strong, nonatomic) NSNumber *needInstantComment;
@end
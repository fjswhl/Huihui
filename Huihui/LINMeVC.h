//
//  LINMeVC.h
//  Huihui
//
//  Created by Lin on 3/27/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LINMeVC : UITableViewController

@property (strong, nonatomic) NSDictionary *userInfo;
- (void)updateUIWhenLoginOrOut;
@end

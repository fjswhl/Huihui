//
//  LINMood.h
//  Huihui
//
//  Created by Lin on 14-5-13.
//  Copyright (c) 2014年 Lin. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface LINMood : NSObject


@property (strong, nonatomic) UIColor *bgColor;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *moodId;
@property (strong, nonatomic) NSString *isthumbup;
@property (strong, nonatomic) NSNumber *numofcomment;
@property (strong, nonatomic) NSNumber *numofthumbup;
@property (strong, nonatomic) NSDate *date;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

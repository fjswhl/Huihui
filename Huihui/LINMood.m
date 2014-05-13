//
//  LINMood.m
//  Huihui
//
//  Created by Lin on 14-5-13.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

//                    {
//                        bg = "-3549200";
//                        content = "%E5%90%83%E9%A5%AD%E3%80%82%E3%80%82%E3%80%82";
//                        id = 61;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 1;
//                        time = 1399888637;
//                    },

#import "LINMood.h"
#import "UIColor+MLPFlatColors.h"

@implementation LINMood


- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _content = [dic[@"content"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _moodId = dic[@"id"];
        _isthumbup = dic[@"isthumbup"];
        _numofcomment = dic[@"numofcomment"];
        _numofthumbup = dic[@"numofthumbup"];
        _date = [NSDate dateWithTimeIntervalSince1970:[dic[@"time"] integerValue]];
        
        NSNumber *colorCode = dic[@"bg"];
        _bgColor = UIColorFromRGBA(([colorCode integerValue] + 10000));
    }
    return self;
}
@end

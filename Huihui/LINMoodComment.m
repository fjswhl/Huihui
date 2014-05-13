//
//  LINMoodComment.m
//  Huihui
//
//  Created by Lin on 14-5-13.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

//content = "+%E9%83%BD%E6%AF%94";
//id = 59;
//isme = 1;
//time = 1399966657;
//uid = 17;
//},


#import "LINMoodComment.h"

@implementation LINMoodComment


- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _content = [dic[@"content"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _commentid = dic[@"id"];
        _isMe = dic[@"isme"];
        _date = [NSDate dateWithTimeIntervalSince1970:[dic[@"time"] integerValue]];
        _uid = dic[@"uid"];
    }
    return self;
}
@end

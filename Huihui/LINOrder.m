//
//  LINOrder.m
//  Huihui
//
//  Created by Lin on 14-5-7.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "LINOrder.h"

//{
//    amount = 1;
//    goodid = 17;
//    goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//    id = 56;
//    price = 100;
//    shopid = 284;
//    shopname = "\U751c\U54c1\U679c\U884c";
//    time = 1399472027;
//    uid = 60;
//},
@implementation LINOrder

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _amount = dic[@"amount"];
        _goodid = dic[@"goodid"];
        _goodname = dic[@"goodname"];
        _orderid = dic[@"id"];
        _price = dic[@"price"];
        _shopid = dic[@"shopid"];
        _shopname = dic[@"shopname"];
        _uid = dic[@"uid"];
        
        NSNumber *timeNumber = dic[@"time"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeNumber intValue]];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        
        _createTime = [dateFormatter stringFromDate:date];
    }
    return self;
}
@end

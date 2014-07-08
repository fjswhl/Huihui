//
//  LINGood.m
//  Huihui
//
//  Created by Lin on 14-5-7.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "LINGood.h"

//{
//    favour = 2;
//    goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//    id = 17;
//    isfavour = 0;
//    price = 100;
//    shopid = 284;
//    stored = 0;
//},
@implementation LINGood


- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _favour = dic[@"favour"];
        _goodName = dic[@"goodname"];
        _goodId = dic[@"id"];
        _isFavour = dic[@"isfavour"];
        _price = dic[@"price"];
        _shopId = dic[@"shopid"];
        _stored = dic[@"stored"];
    }
    return self;
}
@end

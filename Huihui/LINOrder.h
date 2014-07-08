//
//  LINOrder.h
//  Huihui
//
//  Created by Lin on 14-5-7.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LINOrder : NSObject

@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *goodid;
@property (strong, nonatomic) NSString *goodname;
@property (strong, nonatomic) NSNumber *orderid;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *shopid;
@property (strong, nonatomic) NSString *shopname;
@property (strong, nonatomic) NSString *createTime;
@property (strong, nonatomic) NSNumber *uid;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

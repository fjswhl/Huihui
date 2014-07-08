//
//  LINGood.h
//  Huihui
//
//  Created by Lin on 14-5-7.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LINGood : NSObject

@property (strong, nonatomic) NSNumber *favour;
@property (strong, nonatomic) NSString *goodName;
@property (strong, nonatomic) NSNumber *goodId;
@property (strong, nonatomic) NSNumber *isFavour;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *shopId;
@property (strong, nonatomic) NSNumber *stored;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

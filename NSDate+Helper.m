//
//  NSDate+Helper.m
//  Huihui
//
//  Created by Lin on 14-5-13.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)
/**
 *  根据给的时间返回 多长时间前的字符长. 比如现在是3点, 给2点55返回5分钟前
 *
 *  @param date date
 *
 *  @return nsstring
 */
+ (NSString *)timeFlagWithDate:(NSDate *)date{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    NSString *result = nil;
    if (timeInterval < 60) {
        
        result = [NSString stringWithFormat:@"%i秒前", (int)timeInterval];
    }else if (timeInterval < 60 * 60) { /*        分钟          */
        int minute = ((int)timeInterval) / 60;
        result = [NSString stringWithFormat:@"%i分钟前", minute];
    }else if (timeInterval < 60 * 60 * 24){
        int hour = ((int)timeInterval) / 3600;
        result = [NSString stringWithFormat:@"%i小时前", hour];
    }else{
        int day = ((int)timeInterval) / (3600 * 24);
        result = [NSString stringWithFormat:@"%i天前", day];
    }
    return result;
    
}
@end

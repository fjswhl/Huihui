//
//  LINMoodComment.h
//  Huihui
//
//  Created by Lin on 14-5-13.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LINMoodComment : NSObject

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *commentid;
@property (strong, nonatomic) NSNumber *isMe;
@property (strong, nonatomic) NSNumber *uid;
@property (strong, nonatomic) NSDate *date;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

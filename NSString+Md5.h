//
//  NSString+Md5.h
//  Huihui
//
//  Created by Lin on 3/28/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface NSString (Md5)
+ (NSString *)md5:(NSString *)str;
- (NSString*) sha1;
-(NSString *) md5;
@end

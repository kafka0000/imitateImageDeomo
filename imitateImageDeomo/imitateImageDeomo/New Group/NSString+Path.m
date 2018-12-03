//
//  NSString+Path.m
//  imitateImageDeomo
//
//  Created by leeee on 2018/11/21.
//  Copyright © 2018年 leeee. All rights reserved.
//

#import "NSString+Path.h"

@implementation NSString (Path)
-(NSString*)appendingDocuments{
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    return [dir stringByAppendingString:self.lastPathComponent];
}
-(NSString*)appendingLibrary{
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    return [dir stringByAppendingString:self.lastPathComponent];
}
-(NSString*)appendingCaches{
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    return [dir stringByAppendingString:self.lastPathComponent];
}
-(NSString*)appendingTmp{
    NSString *dir = NSTemporaryDirectory();// temp目录和其他两个不一样
    return [dir stringByAppendingString:self.lastPathComponent];
}
@end

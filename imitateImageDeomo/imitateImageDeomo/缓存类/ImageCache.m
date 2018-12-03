//
//  ImageCache.m
//  imitateImageDeomo
//
//  Created by leeee on 2018/11/21.
//  Copyright © 2018年 leeee. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

+ (id)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}
@end

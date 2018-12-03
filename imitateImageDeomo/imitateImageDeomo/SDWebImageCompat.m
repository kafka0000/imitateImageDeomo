//
//  SDWebImageCompat.m
//  SDWebImage
//
//  Created by Olivier Poitrey on 11/12/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "SDWebImageCompat.h"

#if !__has_feature(objc_arc)
#error SDWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif
/**
 给定一张图片，通过scale属性返回放大的图片
 @param key 图片名称
 @param image 资源图片
 @return 处理以后的图片
 */
inline UIImage *SDScaledImageForKey(NSString *key, UIImage *image) {
    //异常处理
    if (!image) {
        return nil;
    }
    //如果多张图片说明是gif图片
    if ([image.images count] > 0) {
        NSMutableArray *scaledImages = [NSMutableArray array];
        //迭代处理每一张图片
        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:SDScaledImageForKey(key, tempImage)];
        }
        //把处理结束的图片再合成一张动态图片
        return [UIImage animatedImageWithImages:scaledImages duration:image.duration];
    }
    else {// 非动态图片
        //屏幕包含缩放尺寸
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGFloat scale = 1;
            if (key.length >= 8) {
                NSRange range = [key rangeOfString:@"@2x."];
                if (range.location != NSNotFound) {
                    scale = 2.0;
                }
                
                range = [key rangeOfString:@"@3x."];
                if (range.location != NSNotFound) {
                    scale = 3.0;
                }
            }
            //图片进行缩放适应屏幕
            UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
            image = scaledImage;
        }
        return image;
    }
}

NSString *const SDWebImageErrorDomain = @"SDWebImageErrorDomain";

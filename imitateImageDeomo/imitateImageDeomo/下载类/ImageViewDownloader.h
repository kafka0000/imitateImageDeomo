//
//  ImageViewDownloader.h
//  imitateImageDeomo
//
//  Created by leeee on 2018/11/21.
//  Copyright © 2018年 leeee. All rights reserved.
//  图片加载处理，管理NSURLResquest请求头封装、缓存、Cokkie 也是单例类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ImageViewDownloader : NSObject
/**
 1.下载设置枚举（是否显示下载进度，下载优先级，是否处理cookie）
 2.下载执行顺序（FIFO：先进先出 LIFO：先进后出）
 3.常量开始结束notification
 4.回调：下载中，下载完成，请求头
 
 初始化：设置先进先出，最大并发执行线程为6 请求头设置为image/webp等，下载超时为15s(NSURLSessionConfiguration ttimeoutInterval),设置NSURLSessionConfiguration,初始化session
 
 下载：
    1）创建NSURLRequest，如果option == SDWebImageDownloaderUseNSURLCache,那么调用NSURLRequest缓存策略NSURLRequestUseProtocolCachePolicy
    2）option == SDWebImageDownloaderHandleCookies,调用NSURLRequesr的HTTPShouldHandleCookies属性。
    3）调用NSURLRequest的shuouldUsePipelining。使用管道--可以提高网络性能 3次握手更快
    4）调用NSURLRequest的allHTTPHeaderFields==请求头信息block包url和字典（请求头设置为image/webp）
 */
//下载过程阶段的回调
typedef void(^WebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

//下载完成block
typedef void(^WebImageDownloaderCompletedBlock)(UIImage *image, NSData *data, NSError *error, BOOL finished);


+ (id)sharedManager;
@end

//
//  ImageViewManager.h
//  imitateImageDeomo
//
//  Created by leeee on 2018/11/21.
//  Copyright © 2018年 leeee. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageCache.h"
#import "ImageViewDownloader.h"
#import "ImageOperation.h"

#pragma mark -- ENum
/* 下载设置图片处理方式 */
typedef NS_OPTIONS(NSUInteger, WebImageOptions){
        SDWebImageRetryFailed = 1 << 0,/* 默认当URL下载失败会加入黑名单，下次使用停止加载 */
        SDWebImageLowPriority = 1 << 1,/* 默认在ScrollView减速时开始加载 */
        SDWebImageCacheMemoryOnly = 1 << 2,/* 禁止磁盘缓存，仅存在内存中 */
        SDWebImageProgreesiveDownload = 1 << 3,/* 🦁可以和浏览器一样，逐行加载。默认是加载完成后显示 */
        SDWebImageRefreshCached = 1 << 4,/* 🤔 使用NSURLCache而不是SDWebImage来处理磁盘缓存 */
        SDWebImageContinueBackground = 1 << 5,/* 应用进入后台继续下载 */
        SDWebImageHandleCookies = 1 << 6,/* 处理缓存在NSHttpCookiesStroe里的Cookie */
        SDWebImageAllowInvalidSSLCertificates = 1 << 7,/* 允许HTTPS非信任证书 */
        SDWebImageHighPriority = 1 << 8,/* 默认情况下，图片加载顺序是根据加入列队的顺序加载，🤔可以用来逐行显示？？ */
        SDWebImageDelayPlaceholder = 1 << 9,/* 如果逐行显示那么要设置placeholder延迟 */
        SDWebImageTranformAnimatedImage = 1 << 10,/* 🦁如果gif需要循环播放时使用 */
        SDWebImageAvoidAutoSetImage = 1 << 11,/* 加载手动处理好的图片 */
        SDWebImageScaleDownLargeImages = 1 << 12/* 🦁高性能使用，先调整大小后解码 */
};

/* 下载完成Block */
typedef void(^WebImageCompletionBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL);
/* 下载完成Block+是否完成 */
typedef void(^WebImageCompletionWithFinishedBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL);
/* 筛选有缓存的Block */
typedef NSString *(^WebImageCacheKeyFilterBlock)(NSURL *url);

#pragma mark -- Delegate
@class ImageViewManager;

@protocol SDWebImageManagerDelegate<NSObject>
/**
 控制图片在没有缓存时去下载
 */
- (BOOL)imageManager:(ImageViewManager *)imageManager shouldDownloadImageForURL:(NSURL *)imageURL;
/**
 每次图片下载完毕如果不是gif并需要转换的话可以转换图片
 */
- (UIImage *)imageManager:(ImageViewManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL;
@end

@interface ImageViewManager : NSObject
/*  */
@property (nonatomic,weak) id<SDWebImageManagerDelegate> delegate;
/* 核心属性--缓存，这边只读，在.m的extension中，可以重写为readwrite */
@property (strong, nonatomic, readonly) ImageCache *imageCache;
/* 核心属性--下载类 */
@property (strong, nonatomic, readonly) ImageViewDownloader *imageDownloader;
/* 筛选器，移除动态图片 */
@property (nonatomic,copy)WebImageCacheKeyFilterBlock cacheFilter;

#pragma mark -- Function
/* 单例 */
+(ImageViewManager*)sharedManager;
/* 初始化-设置cache和downloader */
-(instancetype)initWithCache:(ImageCache*)cache downloader:(ImageViewDownloader*)downloader;


/**
 🦁核心方法

 @param url 传入要请求的URL
 @param options 当前当前建造者管理类的枚举选项
 @param progressBlock 核心下载类的回调（一级回调）
 @param completedBlock 核心缓存类的回调（二级回调-通过本层）
 @return 载体？？
 */
- (id <WebImageOperation>)loadImageWithURL:(nullable NSURL *)url
                                              options:(WebImageOptions)options
                                             progress:(WebImageDownloaderProgressBlock)progressBlock
                                            completed:(WebImageCompletionBlock)completedBlock;
@end

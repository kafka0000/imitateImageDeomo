//
//  ImageDownloaderOperation.m
//  imitateImageDeomo
//
//  Created by leeee on 2018/11/21.
//  Copyright © 2018年 leeee. All rights reserved.
//

#import "ImageDownloaderOperation.h"
#import "NSString+Path.h"
@implementation ImageDownloaderOperation
/**
 1.属性包括：NSURLRequest、NSURLSessionTask、是否压缩图片、身份验证信息
 2.重写开始方法
    --2.1 加锁，（互斥锁，防止多线程抢夺资源）检测是否开始如果开始，那么就取消并重置
    --2.2 检测是否遵守了Downloader中的后台下载枚举，调用UIapplication的endBackgroundTask方法（必须和end承兑出现）
    --2.3 初始化session\datatask\request，初始化progressBlock(内含两个参数，一个为目前大小，一个为总大小)，目前为0
    --2.4 注册通知SDWebImageDownloadStartNotification，传递DownloaderOperation当前类，在Downloader里观察，一旦开始，那么就开始转小菊
 
 3.cencel取消方法
    --3.1 如果已经开始下载了，那么把放到下载的那个线程，等下载完毕后cancel
    --3.2 如果还没有开始下载，那么取消datatask，并注册下载取消通知
    --3.3
 
 4.NSURLSessionDataDelegate
    didReceiveResponse
    --4.1 在收到回复didReceiveResponse代理方法中,判断除了305以外小于400,设置接收数据回调progressBlock，注册SDWebImageDownloadReceiveResponseNotification
    --4.2 判断如果是304返回图片没有变化，停止operation并返回cache,注册SDWebImageDownloadStopNotification，completedBlock返回错误信息
    didReceiveData
    --4.3 添加到缓存中，如果需要显示图片下载进度，那么获得下载图片大小
 
 
 */
//重写main方法  操作添加到队列的时候会调用该方法
- (void)main{
    //创建自动释放池：因如果是异步操作，无法访问主线程的自动释放池
    @autoreleasepool {
        //断言
        //添加断言后，if (self.finishedBlock) 不用再设置，如果为空了，程序会崩溃，同时会提醒：finishedBlock不能为空
        NSAssert(self.finishedBlock != nil, @"finishedBlock不能为空");
        
        //下载网络图片
        NSURL *url = [NSURL URLWithString:self.urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        //缓存到沙盒中
        if (data) {
            [data writeToFile:[self.urlString appendingCaches] atomically:YES];
        }
        //这里是子线程  图片下载在Library的Caches中
        //沙盒包括
        //1.Documents:保存游戏进度等--PS:不能保存网上下载内容,会无法上架，但备份时会回复。
        //2.Library:包括Caches（持久化,保存网络请求、图片等） Preferences：保存偏好设置,userDefaluts
        //3.Temp:保存临时数据，会被不定时删除
        //NSLog(@"下载图片 %@ %@",self.urlString,[NSThread currentThread]);
        NSLog(@"从网络下载图片,图片所在地址是：%@",[self.urlString appendingCaches]);
        
        //判断操作是否被取消
        //如果取消，直接return。放在耗时操作之后和合理一些，取消操作的时候，不会拦截耗时操作，耗时操作依然可以执行。下次想显示图像的时候，耗时操作也执行完毕
        if (self.isCancelled) {
            return;
        }
        //图片下载完成回到主线程更新UI 
        //if (self.finishedBlock) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            UIImage *img = [UIImage imageWithData:data];
            // 有断言报错直接跳断言 不必加校验
            self.finishedBlock(img);
        }];
    }
}
// 对外暴露一个类方法，通过赋值url给属性,调用block
+ (instancetype)downloaderOperationWithURLString:(NSString *)urlString finishedBlock:(void (^)(UIImage *image))finishedBlock{

    ImageDownloaderOperation *op = [[ImageDownloaderOperation alloc]init];
    op.urlString = urlString;
    op.finishedBlock = finishedBlock;
    return op;
}
@end

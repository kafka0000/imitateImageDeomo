//
//  ImageDownloaderOperation.h
//  imitateImageDeomo
//
//  Created by leeee on 2018/11/21.
//  Copyright © 2018年 leeee. All rights reserved.
//  下载+解压缩+operation生命周期管理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ImageDownloaderOperation : NSOperation
//下载图片的地址
@property(nonatomic,copy)NSString *urlString;
//执行完成任务之后的回调block
@property(nonatomic,copy)void (^finishedBlock)(UIImage *img);

+ (instancetype)downloaderOperationWithURLString:(NSString *)urlString finishedBlock:(void (^)(UIImage *image))finishedBlock;
@end

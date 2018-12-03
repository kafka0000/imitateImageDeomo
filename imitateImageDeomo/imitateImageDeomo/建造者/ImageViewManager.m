//
//  ImageViewManager.m
//  imitateImageDeomo
//
//  Created by leeee on 2018/11/21.
//  Copyright © 2018年 leeee. All rights reserved.
//

#import "ImageViewManager.h"
#import "SDWebImageCompat.h"
//nsoperation的一层封装,实现SDWebImageOperation协议
//SDWebImageCombinedOperation 继承自SDWebImageOperation
/**
 通过这个对象关联 DownloaderOperation对象
 */
@interface SDWebImageCombinedOperation : NSObject <WebImageOperation>
/* 判断operation是否取消 */
@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
/* 取消回调 */
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock;
/* 取消operation */
@property (strong, nonatomic) NSOperation *cacheOperation;

@end
@interface ImageViewManager()
/* 核心属性--可读可写暴露在外面只读*/
@property (strong, nonatomic, readwrite) ImageCache *imageCache;
/* 核心属性--可读可写暴露在外面只读 */
@property (strong, nonatomic, readwrite) ImageViewDownloader *imageDownloader;
/* 失败的url存储 */
// set类型和arr类型区别在于，set是哈希表集合 是无顺序的 查找更快
@property (strong, nonatomic) NSMutableSet *faieledURLs;
/* 正在运行的operation组合 */
@property (strong, nonatomic) NSMutableArray * runningOperations;
@end

@implementation ImageViewManager

#pragma mark --  初始化+单例
/* 单例 */
+ (id)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

/* 初始化三个单例对象 */
-(instancetype)init{
    ImageCache * cache = [ImageCache sharedManager];
    ImageViewDownloader *downloader = [ImageViewDownloader sharedManager];
    return [self initWithCache:cache downloader:downloader];
}

-(instancetype)initWithCache:(ImageCache *)cache downloader:(ImageViewDownloader *)downloader{
    if(self = [super init]){
        _imageCache = cache;
        _imageDownloader = downloader;
        //用于保存加载失败的url集合
        _faieledURLs = [NSMutableSet new];
         //用于保存当前正在加载的Operation
        _runningOperations = [NSMutableArray new];
    }
    return self;
}

//
- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!url) {
        return @"";
    }
    
    //有filter走filter
    if (self.cacheFilter) {
        return self.cacheFilter(url);
    } else {
        //默认是url的完全string
        return [url absoluteString];
    }
}
#pragma mark --  Main Function
-(id<WebImageOperation>)loadImageWithURL:(NSURL *)url
                                    options:(WebImageOptions)options
                                    progress:(WebImageDownloaderProgressBlock)progressBlock
                                    completed:(WebImageCompletionWithFinishedBlock)completedBlock{
    // url可传str
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString*)url];
    }
    // 如果url不是nsurl类型那么置空
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }
    // 创建operation的封装对象😅
    // 图片加载获取获取过程中绑定一个`SDWebImageCombinedOperation`对象。以方便后续再通过这个对象对url的加载控制。
    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    __weak SDWebImageCombinedOperation *weakOperation = operation;
    
    BOOL isFailedUrl = NO;
    //当前url是否在失败url的集合里面
    if (url) {
        @synchronized (self.faieledURLs) {
            isFailedUrl = [self.faieledURLs containsObject:url];
        }
    }
    /*
     如果url是失败的url或者url有问题等各种问题。则直接根据opeation来做异常情况的处理
     🤡枚举情况：SDImageCacheTypeNone
     */
    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        //构建回调Block
        dispatch_main_sync_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            //带出去 返回Imgae为niL， 报url不存在nil，finish状态 返回url
             completedBlock(nil, error, SDImageCacheTypeNone, YES, url);
        });
        
        return operation;
    }
    
    //判断是否时间失败
    /**
     synchrinized是创建互斥所，保证没有其他对象对self.runnningOperationsx对象进行修改
     */
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    //🤡枚举情况为：RetryFaield
//    如果url长度为0或者说设置不允许失败的url充实则返回错误
    if (url.absoluteString.length == 0|| (!(options && SDWebImageRetryFailed)&& isFailedUrl)) {
        dispatch_main_sync_safe(^{
            /**
             errorWithDomain:错误域
             code:表示了error的id,是唯一标识符
             userInfo:额外的错误信息xw❎
             */
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            /* 给block带出去 */
//            completedBlock(nil,error,SDImageCacheTypeNone,YES,url);
        });
    }
    return url;
}
@end

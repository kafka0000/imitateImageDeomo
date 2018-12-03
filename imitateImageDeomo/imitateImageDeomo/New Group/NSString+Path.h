//
//  NSString+Path.h
//  imitateImageDeomo
//
//  Created by leeee on 2018/11/21.
//  Copyright © 2018年 leeee. All rights reserved.
//

#import <Foundation/Foundation.h>
//沙盒包括
//1.Documents:保存游戏进度等--PS:不能保存网上下载内容,会无法上架，但备份时会回复。
//2.Library:包括Caches（持久化,保存网络请求、图片等） Preferences：保存偏好设置,userDefaluts
//3.Temp:保存临时数据，会被不定时删除
@interface NSString (Path)
// 追加到Docunments
-(NSString*)appendingDocuments;
// 追加到Library **
-(NSString*)appendingLibrary;
// 追加到Caches **
-(NSString*)appendingCaches;
// 追加到temp
-(NSString*)appendingTmp;

@end

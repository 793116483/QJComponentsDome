//
//  PPGifCommonType.h
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#ifndef PPGifCommonType_h
#define PPGifCommonType_h

@class PPGifModel;

typedef void(^PPGifCacheCheckCompletionBlock)(BOOL isInCache);
typedef void(^PPQueryGifModelCacheComplationBlock)(PPGifModel * _Nullable gifModel);
typedef void(^PPQueryGifDataCacheComplationBlock)(NSData * _Nullable gifData);

#endif /* PPGifCommonType_h */

//
//  EPSFeedStorage.h
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EPSFeedStorage : NSObject

/**
 *  Получение "страницы" из ленты пользователя, начиная с первой
 */
- (void)getUserFeed;

@end

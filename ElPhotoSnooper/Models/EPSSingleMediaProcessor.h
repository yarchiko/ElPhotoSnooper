//
//  EPSSingleMediaProcessor.h
//  ElPhotoSnooper
//
//  Created by Mega on 09/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InstagramKit/InstagramKit.h>

@interface EPSSingleMediaProcessor : NSObject

- (instancetype)initWithInstagramMedia:(InstagramMedia *)instagramMedia;
/**
 *  Получение полного списка комментариев для текущего медиаэлемента
 *
 *  @param completion массив аттрибутед-строк
 */
- (void)getCommentsForInstagramMediaWithCompletion:(void (^)(NSArray *))completion;
/**
 *  Получение полного списка лакнувших пользователей для текущего медиаэлемента
 *
 *  @param completion массив аттрибутед-строк
 */
- (void)getLikesForInstagramMediaWithCompletion:(void (^)(NSArray *))completion;
/**
 *  Лайк текущего медиаэлемента
 *
 *  @param completion флаг успешности операции
 */
- (void)likeInstagramMediaWithCompletion:(void (^)(BOOL))completion;
/**
 *  АнЛайк текущего медиаэлемента
 *
 *  @param completion флаг успешности операции
 */
- (void)unlikeInstagramMediaWithCompletion:(void (^)(BOOL))completion;

@end

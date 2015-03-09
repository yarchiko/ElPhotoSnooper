//
//  EPSFeedStorage.h
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <InstagramKit/InstagramKit.h>
#import "EPSFeedTableViewCell.h"

@protocol EPSFeedStorageDelegate <NSObject>

- (void)updateViewWithFreshData;

@end

@interface EPSFeedStorage : NSObject <EPSFeedTableViewCellDelegate>

@property (nonatomic, weak) id<EPSFeedStorageDelegate> feedStorageDelegate;

/**
 *  Массив элементов ленты пользователя (содержит объекты класса InstagramMedia)
 */
@property (strong, nonatomic, readonly) NSArray *feedArray;

/**
 *  Получение "страницы" из ленты пользователя, начиная с первой
 */
- (void)getUserFeed;
/**
 *  Полная перезагрузка ленты пользователя
 */
- (void)reloadUserFeed;
/**
 *  Проверка - авторизован ли пользователь на этом устройстве
 *
 *  @return YES если access_token найден
 */
- (BOOL)isUserAuthed;
/**
 *  Получение id медиа-элемента
 *
 *  @param index  индекс элемента в массиве
 *
 *  @return id элемента, который используется для изменения параметров медиа-элемента
 */
- (NSString *)getIdForElementInStorageWithIndex:(NSInteger)index;
/**
 *  Получение username пользователя, загрузившего фото для элемента с индексом
 *
 *  @param index индекс элемента в массиве
 *
 *  @return ник пользователя
 */
- (NSString *)getUsernameForElementInStorageWithIndex:(NSInteger)index;
/**
 *  Получение количества "лайков" для элемента с индексом
 *
 *  @param index индекс элемента в массиве
 *
 *  @return количество лайков
 */
- (NSInteger)getLikesCountForElementInStorageWithIndex:(NSInteger)index;
/**
 *  Получение количества комментариев для элемента с индексом
 *
 *  @param index индекс элемента в массиве
 *
 *  @return количество комментариев
 */
- (NSInteger)getCommentsCountForElementInStorageWithIndex:(NSInteger)index;
/**
 *  Получение URL-адреса фото (самого высокого качества) для элемента с индексом
 *
 *  @param index индекс элемента в массиве
 *
 *  @return строка с URL-адресом
 */
- (NSURL *)getImageUrlForElementInStorageWithIndex:(NSInteger)index;
/**
 *  Получение массива attributed String комментариев для элемента с индексом
 *
 *  @param index индекс элемента в массиве
 *
 *  @return массив комментариев для элемента
 */
- (NSArray *)getCommentsForElementInStorageWithIndex:(NSInteger)index;
/**
 *  Получение флага - лайкнул ли текущий пользователь элемент с индексом
 *
 *  @param index индекс элемента в массиве
 *
 *  @return YES если лайкнул
 */
- (BOOL)userHasLikedElementWithIndex:(NSInteger)index;
/**
 *  Получение строковой ссылки на медиа
 *
 *  @param index индекс элемента в массиве
 *
 *  @return строковое представление ссылки для медиа-элемента
 */
-(NSString *)getMediaLinkWithIndex:(NSInteger)index;
/**
 *  Разлогинить текущего пользователя
 */
- (void)logout;

@end

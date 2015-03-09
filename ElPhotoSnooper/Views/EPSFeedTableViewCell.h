//
//  EPSFeedTableViewCell.h
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPSFeedTableViewCellDelegate <NSObject>

- (void)updateLikeForMediaWithMediaId:(NSString *)mediaId
                      andCurrentState:(BOOL)state
                            andSender:(id)sender;

@end

@interface EPSFeedTableViewCell : UITableViewCell

@property (nonatomic, weak) id<EPSFeedTableViewCellDelegate> feedTableViewCellDelegate;

/**
 *  Заполнение ячейки исходя из параметров, поступивших извне
 *  @param Id            id элемента
 *  @param imageUrl      ссылка на фото
 *  @param likesCount    общее количество лайков
 *  @param commentsCount общее количество комментариев
 *  @param comments      последние комментарии (до 8)
 *  @param liked         лайкнуто фото текущим пользователем или нет
 *  @param justConfig    только просчитываем размеры или уже показываем
 */
- (void)prepareCellWithId:(NSString *)Id
              andImageUrl:(NSURL *)imageUrl
            andLikesCount:(NSInteger)likesCount
         andCommentsCount:(NSInteger)commentsCount
              andComments:(NSArray *)comments
                 andLiked:(BOOL)liked
            andJustConfig:(BOOL)justConfig;
/**
 *  Установка лайкнуто ли фото пользователем или нет
 *
 *  @param liked <#liked description#>
 */
- (void)updateLike;
//- (void)setLikedStateWithState:(BOOL)userHasLiked;
@end

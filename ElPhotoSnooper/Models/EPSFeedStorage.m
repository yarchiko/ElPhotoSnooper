//
//  EPSFeedStorage.m
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import "EPSFeedStorage.h"
#import "EPSConstants.h"

@interface EPSFeedStorage ()

@property (strong, nonatomic) NSMutableArray *privateFeedMutableArray;
@property (strong, nonatomic) InstagramEngine *instagramSharedEngine;
@property (strong, nonatomic) InstagramPaginationInfo *currentPaginationInfo;

@end

@implementation EPSFeedStorage

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _privateFeedMutableArray = [NSMutableArray array];
        _instagramSharedEngine = [InstagramEngine sharedEngine];
    }
    
    return self;
}

#pragma mark - Whole feed stuff

- (void)getUserFeed {
    
    if ([self isUserAuthed]) {
        NSString *accessToken = [self getUserAccessToken];
        [_instagramSharedEngine setAccessToken:accessToken];
        
        if (_instagramSharedEngine.accessToken) {
            [self loadSelfFeed];
        }
    }
}

- (void)loadSelfFeed {
    [[InstagramEngine sharedEngine] getSelfFeedWithCount:20
                                                   maxId:_currentPaginationInfo.nextMaxId
                                                 success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        _currentPaginationInfo = paginationInfo;
        [_privateFeedMutableArray addObjectsFromArray:media];
         _feedArray = _privateFeedMutableArray;
                                                     
         [self sendMessageToDelegateToUpdateView];
    } failure:^(NSError *error) {
        NSLog(@"Request Self Feed Failed");
    }];
}

- (void)reloadUserFeed {
    _currentPaginationInfo = nil;
    if (_privateFeedMutableArray) {
        [_privateFeedMutableArray removeAllObjects];
    }
    
    [self loadSelfFeed];
}

- (void)sendMessageToDelegateToUpdateView {
    [_feedStorageDelegate updateViewWithFreshData];
}

#pragma mark - Individual entries stuff

- (NSString *)getIdForElementInStorageWithIndex:(NSInteger)index {
    InstagramMedia *instagramMedia = _feedArray[index];
    NSString *Id = instagramMedia.Id;
    
    return Id;
}

- (NSString *)getUsernameForElementInStorageWithIndex:(NSInteger)index {
    InstagramMedia *instagramMedia = _feedArray[index];
    InstagramUser *user = instagramMedia.user;
    NSString *username = user.username;
    
    return username;
}

- (NSInteger)getLikesCountForElementInStorageWithIndex:(NSInteger)index {
    InstagramMedia *instagramMedia = _feedArray[index];
    NSInteger likesCount = instagramMedia.likesCount;

    return likesCount;
}

- (NSInteger)getCommentsCountForElementInStorageWithIndex:(NSInteger)index {
    InstagramMedia *instagramMedia = _feedArray[index];
    NSInteger commentsCount = instagramMedia.commentCount;

    return commentsCount;
}

- (NSURL *)getImageUrlForElementInStorageWithIndex:(NSInteger)index {
    InstagramMedia *instagramMedia = _feedArray[index];
    NSURL *imageUrl = instagramMedia.standardResolutionImageURL;
    
    return imageUrl;
}

- (NSArray *)getCommentsForElementInStorageWithIndex:(NSInteger)index {
    InstagramMedia *instagramMedia = _feedArray[index];
    NSMutableArray *commentMutableArray = [NSMutableArray array];
    
    /**
     *  Подпись к фото
     */
    InstagramComment *caption = instagramMedia.caption;
    NSString *captionString = caption.text;
    /**
     *  Проверка подписи на пустоту
     */
    BOOL isCaptionNil = (captionString == nil);
    
    NSArray *comments = instagramMedia.comments;
    
    /**
     *  Если подпись не пустая - добавление её в массив комментариев в начало
     */
    if (!isCaptionNil) {
        NSMutableArray *mutableComments = [comments mutableCopy];
        [mutableComments insertObject:caption atIndex:0];
        comments = mutableComments;
    }
    
    for (InstagramComment *comment in comments) {
        InstagramUser *user = comment.user;
        NSString *username = user.username;

        UIFontDescriptor *usernameFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        UIFontDescriptor *usernameFontDescriptor2 = [usernameFontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        UIFont *myFont = [UIFont fontWithDescriptor:usernameFontDescriptor2 size:0.0];
        NSDictionary *usernameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               myFont, NSFontAttributeName,
                               [UIColor blackColor], NSForegroundColorAttributeName, nil];
        
        NSAttributedString *usernameAttributedFinalText =
        [[NSAttributedString alloc] initWithString:username
                                               attributes:usernameAttributes];
        
        NSMutableAttributedString *finalMutableAttributedString = [[NSMutableAttributedString alloc] initWithString:@"@"];
        
        [finalMutableAttributedString appendAttributedString:usernameAttributedFinalText];
        NSMutableAttributedString *delimiter = [[NSMutableAttributedString alloc] initWithString:@": "];
        [finalMutableAttributedString appendAttributedString:delimiter];
        
        NSString *commentText = comment.text;
        if (![commentText isEqualToString:@""]) {
            UIFontDescriptor *commentFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
            UIFont *commentFont = [UIFont fontWithDescriptor:commentFontDescriptor size:0.0];
            /**
             *  Создание аттрибутов
             */
            NSDictionary *commentAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                commentFont, NSFontAttributeName,
                                                [UIColor blackColor], NSForegroundColorAttributeName, nil];
            
            /**
             Создание attributedString из текста и аттрибутов
             */
            NSAttributedString *commentFinalAttributedString =
            [[NSAttributedString alloc] initWithString:commentText
                                                   attributes:commentAttributes];
            [finalMutableAttributedString appendAttributedString:commentFinalAttributedString];
            
        }
        [commentMutableArray addObject:finalMutableAttributedString];
    }
    
    comments = commentMutableArray;
    
    return comments;
}

- (BOOL)userHasLikedElementWithIndex:(NSInteger)index {
    InstagramMedia *instagramMedia = _feedArray[index];
    BOOL userHasLiked = instagramMedia.userHasLiked;
    
    return userHasLiked;
}

-(NSString *)getMediaLinkWithIndex:(NSInteger)index {
    InstagramMedia *instagramMedia = _feedArray[index];
    NSString *link = instagramMedia.link;
    
    return link;
}

#pragma mark - change content on behalf

- (void)updateLikeForMediaWithMediaId:(NSString *)mediaId
                      andCurrentState:(BOOL)state
                            andSender:(id)sender {
    if (state) {
        [[InstagramEngine sharedEngine] unlikeMedia:mediaId withSuccess:^{
            if ([sender respondsToSelector:@selector(updateLike)]) {
                [sender updateLike];
            }
            [self updateLikeInArrayForElementWithMediaId:mediaId andNewState:NO];
        } failure:^(NSError *error) {
            NSLog(@"Error when trying to unlike with error: %@", [error localizedDescription]);
        }];
    }
    else {
        [[InstagramEngine sharedEngine] likeMedia:mediaId withSuccess:^{
            if ([sender respondsToSelector:@selector(updateLike)]) {
                [sender updateLike];
            }
            [self updateLikeInArrayForElementWithMediaId:mediaId andNewState:YES];
        } failure:^(NSError *error) {
            NSLog(@"Error when trying to like with error: %@", [error localizedDescription]);
        }];
    }
}
/**
 *  Изменение состояния
 *
 *  @param mediaId идентификатор медиаэлемента
 *  @param state   новый статус "лайкнутости" фото
 */
- (void)updateLikeInArrayForElementWithMediaId:(NSString *)mediaId
                                   andNewState:(BOOL)state {
    NSUInteger indexTochangeLike = [_privateFeedMutableArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(InstagramMedia *)obj Id] isEqualToString:mediaId]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    InstagramMedia *instagramMedia = _privateFeedMutableArray[indexTochangeLike];
    if (state) {
        instagramMedia.likesCount++;
        instagramMedia.userHasLiked = YES;
    }
    else {
        instagramMedia.likesCount--;
        instagramMedia.userHasLiked = NO;
    }
    _privateFeedMutableArray[indexTochangeLike] = instagramMedia;
    _feedArray = _privateFeedMutableArray;
}

#pragma mark - Authorisation

- (BOOL)isUserAuthed {
    NSString *accessToken = [self getUserAccessToken];
    BOOL isAccessTokenBlank = [accessToken isEqualToString:@""];
    if (isAccessTokenBlank) {
        return NO;
    }
    
    return YES;
}
/**
 *  Получение access_token из User Defaults
 *
 *  @return access_token
 */
- (NSString *)getUserAccessToken {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:INSTAGRAM_USER_ACCESS_TOKEN];

    return accessToken;
}

- (void)logout {
    [_instagramSharedEngine logout];
    [_privateFeedMutableArray removeAllObjects];
    _feedArray = _privateFeedMutableArray;
}

@end

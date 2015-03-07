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
    NSArray *comments = instagramMedia.comments;
    NSMutableArray *commentMutableArray = [NSMutableArray array];
    
    for (InstagramComment *comment in comments) {
        InstagramUser *user = comment.user;
        NSString *username = user.username;
        NSString *commentText = comment.text;
        
        const CGFloat fontSize = 13;
        UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
        UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
        UIColor *foregroundColor = [UIColor whiteColor];
        
        /**
         *  Создание аттрибутов
         */
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName,
                               foregroundColor, NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  regularFont, NSFontAttributeName, nil];
        /**
         *  Жёсткая расстановка диапазона разметки, для теста. Переписать.
         */
        const NSRange range = NSMakeRange(2,4);
        
        /**
         Создание attributedString из текста и аттрибутов
         */
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:commentText
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        
        [commentMutableArray addObject:attributedText];
    }
    
    comments = commentMutableArray;
    
    return comments;
}

#pragma mark - Authorisation checking/reading

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

@end

//
//  EPSSingleMediaProcessor.m
//  ElPhotoSnooper
//
//  Created by Mega on 09/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import "EPSSingleMediaProcessor.h"

@interface EPSSingleMediaProcessor ()

@property (nonatomic, strong) InstagramMedia *instagramMedia;
@property (strong, nonatomic) InstagramEngine *instagramSharedEngine;

@end

@implementation EPSSingleMediaProcessor

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Need Instagram media object" reason:@"Use -[[EPSSingleMediaProcessor alloc] initWithInstagramMedia:]" userInfo:nil];
    
    return nil;
}

- (instancetype)initWithInstagramMedia:(InstagramMedia *)instagramMedia {
    self = [super init];
    if (self) {
        _instagramMedia = instagramMedia;
        _instagramSharedEngine = [InstagramEngine sharedEngine];
    }
    
    return self;
}

- (void)getCommentsForInstagramMediaWithCompletion:(void (^)(NSArray *))completion {
    NSString *mediaId = _instagramMedia.Id;
    [_instagramSharedEngine getCommentsOnMedia:mediaId withSuccess:^(NSArray *commentsArrayFromInstagram) {
        
        NSMutableArray *commentMutableArray = [NSMutableArray array];
        
        NSArray *comments = commentsArrayFromInstagram;
        
        for (InstagramComment *comment in comments) {
            InstagramUser *user = comment.user;
            NSString *username = user.username;
            NSString *commentText = comment.text;
            NSString *usernameAndComment = [[NSString alloc] initWithFormat:@"@%@: %@", username, commentText];
            [commentMutableArray addObject:usernameAndComment];
        }
        
        comments = commentMutableArray;
        
        completion(comments);
        
    } failure:^(NSError *error) {
         NSLog(@"Error when trying to get comments: %@", [error localizedDescription]);
    }];
}

- (void)getLikesForInstagramMediaWithCompletion:(void (^)(NSArray *))completion {
    [_instagramSharedEngine getLikesOnMedia:_instagramMedia.Id withSuccess:^(NSArray *likedUsers) {
        NSMutableArray *arrayWithLikes = [NSMutableArray array];
        for (InstagramUser *user in likedUsers) {
            NSString *usernameWithAtSymbol = [[NSString alloc] initWithFormat:@"@%@", user.username];
            [arrayWithLikes addObject:usernameWithAtSymbol];
        }
        NSArray *arrayToReturn = arrayWithLikes;
        completion(arrayToReturn);
    } failure:^(NSError *error) {
        NSLog(@"Could not load likes because of: %@", [error localizedDescription]);
    }];
}
- (void)likeInstagramMediaWithCompletion:(void (^)(BOOL))completion {
    [_instagramSharedEngine likeMedia:_instagramMedia.Id withSuccess:^{
        _instagramMedia.userHasLiked = YES;
        completion(YES);
    } failure:^(NSError *error) {
        NSLog(@"Error while liking: %@", [error localizedDescription]);
        completion(NO);
    }];
}

- (void)unlikeInstagramMediaWithCompletion:(void (^)(BOOL))completion {
    [_instagramSharedEngine unlikeMedia:_instagramMedia.Id withSuccess:^{
        _instagramMedia.userHasLiked = NO;
        completion(YES);
        
    } failure:^(NSError *error) {
        NSLog(@"Error while unliking: %@", [error localizedDescription]);
        completion(NO);
    }];
}

@end

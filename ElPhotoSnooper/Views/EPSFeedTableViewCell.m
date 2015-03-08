//
//  EPSFeedTableViewCell.m
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import "EPSFeedTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EPSFeedTableViewCell ()

@property (nonatomic, assign) BOOL isLiked;

// UI elements
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsBottomConstraint;

@end

@implementation EPSFeedTableViewCell

- (void) prepareCellWithImageUrl:(NSURL *)imageUrl
                   andLikesCount:(NSInteger)likesCount
                andCommentsCount:(NSInteger)commentsCount
                     andComments:(NSArray *)comments
                        andLiked:(BOOL)liked {
    
    UIImage *placeholderImage = [UIImage imageNamed:@"MediaPlaceholder.png"];
    [_image sd_setImageWithURL:imageUrl placeholderImage:placeholderImage];
    /**
     *  Возвращает emoji-знак комметария и количество комментариев
     */
    NSString *stringForCommentsCountsLabel = [[NSString alloc] initWithFormat:@"%@ %ld", @"\xF0\x9F\x92\xAC", (long)commentsCount];
    _commentsCountLabel.text = stringForCommentsCountsLabel;
    _commentsCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSString *wordForLikeCountButton = NSLocalizedString(@"\xE2\x9D\xA4", @"Количество лайков- button в ленте пользователя");
    NSString *stringForLikesCountButton = [[NSString alloc] initWithFormat:@"%@ %ld", wordForLikeCountButton, (long)likesCount];
    //_likeButton.titleLabel.text = stringForLikesCountButton;
    _likeButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [_likeButton setTitle:stringForLikesCountButton forState:UIControlStateNormal];
    
    
    if (liked) {
        _isLiked = YES;
        _likeButton.tintColor = [UIColor redColor];
    }
    [_likeButton sizeToFit];
    
    NSMutableAttributedString *mutableCommentsString = [[NSMutableAttributedString alloc] init];
    NSInteger commentsCountOfLastComments = [comments count];
    
    for (NSInteger i = 0; i < commentsCountOfLastComments; i++) {
        NSAttributedString *commentString = comments[i];
        [mutableCommentsString appendAttributedString:commentString];
        
        /**
         *  Ставим символ новой строки, если это не последняя строка
         */
        if (i < commentsCountOfLastComments - 1) {
            [mutableCommentsString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        }
    }

    NSAttributedString *stringToShow = mutableCommentsString;
    _commentsLabel.attributedText = stringToShow;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];

    [_commentsCountLabel sizeToFit];
    _commentsCountLabel.preferredMaxLayoutWidth = CGRectGetWidth(_commentsCountLabel.frame);
    
    [_likeButton sizeToFit];
    _likeButton.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(_likeButton.titleLabel.frame);
    
    _commentsLabel.preferredMaxLayoutWidth = CGRectGetWidth(_commentsLabel.frame);
}

- (void)prepareForReuse {
    _commentsCountLabel.text = @"";
    _commentsLabel.text = @"";
    
    _likeButton.titleLabel.text = @"";
    _likeButton.tintColor = [[[UIApplication sharedApplication] keyWindow] tintColor];
    _isLiked = NO;
    
    [self setNeedsUpdateConstraints];
    [self.layer removeAllAnimations];
}

- (void)setLikedStateWithState:(BOOL)userHasLiked {
    if (userHasLiked) {
        _isLiked = YES;
        _likeButton.tintColor = [UIColor redColor];
    }
}

@end

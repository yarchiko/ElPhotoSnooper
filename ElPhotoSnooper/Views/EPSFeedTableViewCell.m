//
//  EPSFeedTableViewCell.m
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import "EPSFeedTableViewCell.h"

@implementation EPSFeedTableViewCell

- (void) prepareCellWithImageUrl:(NSURL *)imageUrl
                   andLikesCount:(NSInteger)likesCount
                andCommentsCount:(NSInteger)commentsCount
                     andComments:(NSArray *)comments {
    
    if (commentsCount > 0) {
        NSAttributedString *comment = comments[0];
        
    }
    
}

@end

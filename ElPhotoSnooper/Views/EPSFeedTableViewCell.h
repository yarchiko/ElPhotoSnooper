//
//  EPSFeedTableViewCell.h
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPSFeedTableViewCell : UITableViewCell

- (void) prepareCellWithPhotoString:(NSString *)photo
                      andLikesCount:(NSString *)likesCount
                   andCommentsCount:(NSString *)commentsCount
                   andCommentsArray:(NSString *)commentsArray;

@end

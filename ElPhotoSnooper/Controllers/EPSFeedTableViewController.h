//
//  EPSFeedTableViewController.h
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPSFeedTableViewController : UITableViewController

/**
 *  Запускает тот же механизм что и Pull To Refresh
 */
- (void)reloadFeedFromOutside;

@end

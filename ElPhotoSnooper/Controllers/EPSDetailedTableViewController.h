//
//  EPSDetailedTableViewController.h
//  ElPhotoSnooper
//
//  Created by Mega on 09/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InstagramKit/InstagramKit.h>

@interface EPSDetailedTableViewController : UITableViewController

/**
 *  Идентификатор медиаэлемента для определения режима работы контроллера
 */
@property (nonatomic, strong) InstagramMedia *instagramMedia;

@end

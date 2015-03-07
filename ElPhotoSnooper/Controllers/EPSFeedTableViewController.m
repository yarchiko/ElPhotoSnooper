//
//  EPSFeedTableViewController.m
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import "EPSFeedTableViewController.h"
#import "EPSConstants.h"
#import "EPSFeedStorage.h"
#import "EPSFeedTableViewCell.h"

@interface EPSFeedTableViewController () <EPSFeedStorageDelegate>

@property (strong, nonatomic) EPSFeedStorage *feedStorage;

@end

@implementation EPSFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _feedStorage = [[EPSFeedStorage alloc] init];
    _feedStorage.feedStorageDelegate = self;
    
    BOOL isUserAuthed = [_feedStorage isUserAuthed];
    if (!isUserAuthed) {
        [self performSegueWithIdentifier:SEGUE_TO_AUTH_SCREEN sender:self];
    }
    else {
        [_feedStorage getUserFeed];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *feedEntries = _feedStorage.feedArray;
    NSInteger feedEntriesCount = [feedEntries count];
    NSLog(@"%ld", (long)feedEntriesCount);
    return feedEntriesCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (EPSFeedTableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EPSFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FEED_CELL_REUSE_IDENTIFIER
                                                            forIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSURL *imageUrl = [_feedStorage getImageUrlForElementInStorageWithIndex:section];
    NSInteger likesCount = [_feedStorage getLikesCountForElementInStorageWithIndex:section];
    NSInteger commentsCount = [_feedStorage getCommentsCountForElementInStorageWithIndex:section];
    NSArray *comments = [_feedStorage getCommentsForElementInStorageWithIndex:section];
    
    [cell prepareCellWithImageUrl:imageUrl
                    andLikesCount:likesCount
                 andCommentsCount:commentsCount
                      andComments:comments];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    NSString *username = [_feedStorage getUsernameForElementInStorageWithIndex:section];
    
    return username;
}

#pragma mark - EPSFeedStorageDelegate

- (void)updateViewWithFreshData {
    [self.tableView reloadData];
}

@end

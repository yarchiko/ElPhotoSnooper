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

@property (nonatomic, strong) EPSFeedStorage *feedStorage;
@property (nonatomic, strong) EPSFeedTableViewCell *prototypeCell;

@end

@implementation EPSFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _feedStorage = [[EPSFeedStorage alloc] init];
    _feedStorage.feedStorageDelegate = self;
    
    /**
     *  Не очень нравится идея перезаписывать respondsToSelector
     *  Но есть свои плюсы, например система не тратит ресурсы на вызов и просчёт через heightForRowAtIndexPath
     */
    if (![self respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    BOOL isUserAuthed = [_feedStorage isUserAuthed];
    if (!isUserAuthed) {
        [self performSegueWithIdentifier:SEGUE_TO_AUTH_SCREEN
                                  sender:self];
    }
    else {
        [_feedStorage getUserFeed];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *feedEntries = _feedStorage.feedArray;
    NSInteger feedEntriesCount = [feedEntries count];

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
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    NSString *username = [_feedStorage getUsernameForElementInStorageWithIndex:section];
    
    return username;
}

- (CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:FEED_CELL_REUSE_IDENTIFIER];
    }
    
    [self configureCell:_prototypeCell
      forRowAtIndexPath:indexPath];
    
    [_prototypeCell layoutIfNeeded];
    CGSize size = [_prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    /**
     *  Добавляем 1 к высоте из-за delimiter
     */
    return size.height + 1.0;
}

#pragma mark - Configure

- (void)configureCell:(EPSFeedTableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSURL *imageUrl = [_feedStorage getImageUrlForElementInStorageWithIndex:section];
    NSInteger likesCount = [_feedStorage getLikesCountForElementInStorageWithIndex:section];
    NSInteger commentsCount = [_feedStorage getCommentsCountForElementInStorageWithIndex:section];
    NSArray *comments = [_feedStorage getCommentsForElementInStorageWithIndex:section];
    
    [cell prepareCellWithImageUrl:imageUrl
                    andLikesCount:likesCount
                 andCommentsCount:commentsCount
                      andComments:comments];
}

#pragma mark - EPSFeedStorageDelegate

- (void)updateViewWithFreshData {
    [self.tableView reloadData];
}

#pragma mark - Respoder rewrite

- (BOOL)respondsToSelector:(SEL)selector {
    static BOOL useSelector;
    static dispatch_once_t predicate = 0;
    dispatch_once(&predicate, ^{
        useSelector = [[UIDevice currentDevice].systemVersion floatValue] < 8.0 ? YES : NO;
    });
    
    if (selector == @selector(tableView:heightForRowAtIndexPath:)) {
        return useSelector;
    }
    
    return [super respondsToSelector:selector];
}

@end

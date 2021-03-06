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
#import "IKLoginViewController.h"
#import "EPSDetailedTableViewController.h"

@interface EPSFeedTableViewController () <EPSFeedStorageDelegate>

@property (nonatomic, strong) EPSFeedStorage *feedStorage;
/**
 *  Медиа-элемент для передачи в подробный вид
 */
@property (nonatomic, strong) EPSFeedTableViewCell *prototypeCell;
@property (nonatomic, assign) BOOL alreadyLoadingNextPage;
@property (nonatomic, strong) NSMutableDictionary *cachedCellHeights;

@end

@implementation EPSFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self preparationsInController];
    [self checkUserAndLoadAuthControllerIfNeeded];
}

- (void)preparationsInController {
    _feedStorage = [[EPSFeedStorage alloc] init];
    _feedStorage.feedStorageDelegate = self;
    _cachedCellHeights = [NSMutableDictionary dictionary];
    /**
     *  Не очень нравится идея перезаписывать respondsToSelector
     *  Но есть свои плюсы, например система не тратит ресурсы на вызов и просчёт через heightForRowAtIndexPath
     */
    if (![self respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 388.0f;
    }
    /**
     По рефрешу - получение свежих записей
     */
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadFeed)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)checkUserAndLoadAuthControllerIfNeeded {
    BOOL isUserAuthed = [_feedStorage isUserAuthed];
    if (!isUserAuthed) {
        [self performSegueWithIdentifier:SEGUE_TO_AUTH_SCREEN
                                  sender:self];
    }
    else {
        [_feedStorage getUserFeed];
        _alreadyLoadingNextPage = YES;
    }
}

- (void)reloadFeed {
    if (_feedStorage) {
        [_feedStorage reloadUserFeed];
    }
}

- (void)reloadFeedFromOutside {
    [self reloadFeed];
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
    cell.feedTableViewCellDelegate = _feedStorage;
    [self configureCell:cell
      forRowAtIndexPath:indexPath
          andJustConfig:NO];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    NSString *username = [_feedStorage getUsernameForElementInStorageWithIndex:section];
    
    return username;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:FEED_CELL_REUSE_IDENTIFIER];
    }
    
    NSInteger section = indexPath.section;
    NSString *linkID = [_feedStorage getMediaLinkWithIndex:section];
    
    NSNumber *cachedHeight = _cachedCellHeights[linkID];
    if (cachedHeight != nil) {
        return [cachedHeight floatValue];
    }
    
    [self configureCell:_prototypeCell
      forRowAtIndexPath:indexPath
          andJustConfig:YES];
    [_prototypeCell layoutIfNeeded];
    CGSize size = [_prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    /**
     *  Добавляем 1 к высоте из-за delimiter
     */
    CGFloat heightToReturn = size.height + 1;
    
    _cachedCellHeights[linkID] = @(heightToReturn);
    
    return heightToReturn;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

#pragma mark - Configure

- (void)configureCell:(EPSFeedTableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath andJustConfig:(BOOL)justConfig {
    NSInteger section = indexPath.section;
    NSString *Id = [_feedStorage getIdForElementInStorageWithIndex:section];
    NSURL *imageUrl = [_feedStorage getImageUrlForElementInStorageWithIndex:section];
    NSInteger likesCount = [_feedStorage getLikesCountForElementInStorageWithIndex:section];
    NSInteger commentsCount = [_feedStorage getCommentsCountForElementInStorageWithIndex:section];
    NSArray *comments = [_feedStorage getCommentsForElementInStorageWithIndex:section];
    BOOL userHasLiked = [_feedStorage userHasLikedElementWithIndex:section];
    [cell prepareCellWithId:Id
                andImageUrl:imageUrl
              andLikesCount:likesCount
           andCommentsCount:commentsCount
                andComments:comments
                   andLiked:userHasLiked
              andJustConfig:justConfig];
}

#pragma mark - EPSFeedStorageDelegate

- (void)updateViewWithFreshData {
    /**
     *  Чтобы избежать "промаргивания" фото при обновлении
     */
    //self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    _alreadyLoadingNextPage = NO;
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

#pragma mark - Scroll Delegate
/**
 *  Проверка положиения прокрутки
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat actualPosition = self.tableView.contentOffset.y;
    CGFloat contentHeight = self.tableView.contentSize.height - (700.0f);
    
    if ((actualPosition >= contentHeight)&&(!_alreadyLoadingNextPage)) {
        _alreadyLoadingNextPage = YES;
        [_feedStorage getUserFeed];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_TO_DETAIL_SCREEN]) {

            NSIndexPath *selectedCellPath = [self.tableView indexPathForSelectedRow];

            InstagramMedia *instagramMedia = [_feedStorage feedArray][selectedCellPath.section];
            
            EPSDetailedTableViewController *detailedTableViewController = [segue destinationViewController];
            detailedTableViewController.instagramMedia = instagramMedia;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_AUTH_SCREEN]) {
        UINavigationController *loginNavigationController = (UINavigationController *)segue.destinationViewController;
        IKLoginViewController *loginViewController = loginNavigationController.viewControllers[0];
        loginViewController.feedTableViewController = self;
    }
}

#pragma mark - Logout

- (IBAction)logoutAction:(id)sender {
    [_feedStorage logout];
    [[NSUserDefaults standardUserDefaults] setObject:@""
                                              forKey:INSTAGRAM_USER_ACCESS_TOKEN];
    [self.tableView reloadData];
    [self checkUserAndLoadAuthControllerIfNeeded];
}

@end

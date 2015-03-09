//
//  EPSDetailedTableViewController.m
//  ElPhotoSnooper
//
//  Created by Mega on 09/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import <InstagramKit/InstagramKit.h>
#import "EPSDetailedTableViewController.h"
#import "EPSConstants.h"
#import "EPSSingleMediaProcessor.h"

#import "IKMediaCell.h"

@interface EPSDetailedTableViewController ()

@property (nonatomic, strong) EPSSingleMediaProcessor *singleMediaProcessor;
@property (nonatomic, strong) NSArray *arrayofLikesStrings;
@property (nonatomic, strong) NSArray *arrayOfCommentsStrings;

@end

@implementation EPSDetailedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    if (_instagramMedia) {
        [self tuneupController];
        [self loadAsyncData];
    }
}

#pragma mark - Preparations

- (void)tuneupController {
    _singleMediaProcessor = [[EPSSingleMediaProcessor alloc] initWithInstagramMedia:_instagramMedia];
    self.title = _instagramMedia.user.username;
}

- (void)loadAsyncData {
    [_singleMediaProcessor getCommentsForInstagramMediaWithCompletion:^(NSArray *comments) {
        _arrayOfCommentsStrings = comments;
        [self.tableView reloadData];
    }];
    [_singleMediaProcessor getLikesForInstagramMediaWithCompletion:^(NSArray *likes) {
        _arrayofLikesStrings = likes;
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return [_arrayOfCommentsStrings count];
            break;
        case 2:
            return [_arrayofLikesStrings count];
            break;
        default:
            return 1;
            break;
    }
}

/**
 *  Метод мягко говоря не идеальный
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    
    switch (section) {
        case 0:
            if (!indexPath.row) {
                IKMediaCell *cell = (IKMediaCell *)[tableView dequeueReusableCellWithIdentifier:@"MediaCell" forIndexPath:indexPath];
                [cell setImageWithUrl:_instagramMedia.standardResolutionImageURL];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
            else {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
                
                switch (indexPath.row) {
                    case 1:
                        if (_instagramMedia.userHasLiked) {
                            cell.textLabel.text = @"\xE2\x9D\xA4";
                            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                        }
                        else {
                            NSString *likeLocalizedString = NSLocalizedString(@"Лайкнуть", @"Надпись на кнопке для лайканья в детальном виде изображения");
                            cell.textLabel.text = likeLocalizedString;
                            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                        }
                        break;
                }
                
                return cell;
            }
            break;
            
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.textLabel.text = _arrayOfCommentsStrings[indexPath.row];
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            return cell;
        }
            break;
        case 2: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.textLabel.text = _arrayofLikesStrings[indexPath.row];
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            return cell;
        }
            break;
        default: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.textLabel.text = @"Тест";
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            return cell;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /**
     *  Если нажали на строку с лайком - выполнить действие
     */
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    BOOL isThisLikeCell = (section == 0)&&(row == 1);
    if (isThisLikeCell) {
        /**
         *  Проверка текущего ссостояния медиаэлемента
         */
        if (!_instagramMedia.userHasLiked) {
            [self like];
        }
        else {
            [self unlike];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle = [_singleMediaProcessor headerTitleForSection:section];
    
    return headerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    /**
     *  Для самой первой ячейки (где фото) - простановка высоты под фото
     */
    if (!section && !row) {
        return 320;
    }
    /**
     *  Остальные ячейки стандартного размера
     */
    else {
        /**
         *  Для iOS 8 и новее было бы здорово использовать автопросчёт высоты для комментариев
         */
        NSString *version = [[UIDevice currentDevice] systemVersion];
        BOOL isAtLeast8 = [version compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending;
        if (isAtLeast8) {
            return UITableViewAutomaticDimension;
        }
        /**
         *  Для более старых ОС
         */
        return 44;
    }
}
/**
 *  Отправка запроса на лайк медиаэлемента и обработка ответа
 */
- (void)like {
    [_singleMediaProcessor likeInstagramMediaWithCompletion:^(BOOL completion) {
        if (completion) {
            _instagramMedia.userHasLiked = YES;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1
                                                                        inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationBottom];
        }
    }];
}
/**
 *  Отправка запроса на анлайк медиаэлемента и обработка ответа
 */
- (void)unlike {
    [_singleMediaProcessor unlikeInstagramMediaWithCompletion:^(BOOL completion) {
        if (completion) {
            _instagramMedia.userHasLiked = NO;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1
                                                                        inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationBottom];
        }
    }];
}

@end

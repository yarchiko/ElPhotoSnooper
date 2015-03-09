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
    /**
     *  Не очень нравится идея перезаписывать respondsToSelector
     *  Но есть свои плюсы, например система не тратит ресурсы на вызов и просчёт через heightForRowAtIndexPath
     */
    /*
    if (![self respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 388.0f;
    }
     */
    if (_instagramMedia) {
        _singleMediaProcessor = [[EPSSingleMediaProcessor alloc] initWithInstagramMedia:_instagramMedia];
        [_singleMediaProcessor getCommentsForInstagramMediaWithCompletion:^(NSArray *comments) {
            _arrayOfCommentsStrings = comments;
            [self.tableView reloadData];
        }];
        [_singleMediaProcessor getLikesForInstagramMediaWithCompletion:^(NSArray *likes) {
            _arrayofLikesStrings = likes;
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
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
                            cell.textLabel.text = [NSString stringWithFormat:@"\xE2\x9D\xA4 Всего: %ld",(long)_instagramMedia.likesCount];
                            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];;
                        }
                        else {
                            cell.textLabel.text = [NSString stringWithFormat:@"Лайкнуть. Всего: %ld",(long)_instagramMedia.likesCount];
                            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];;
                        }
                        break;
                        
                    case 2:
                        cell.textLabel.text = [NSString stringWithFormat:@"%ld комментарий(ев)",(long)_instagramMedia.commentCount];
                        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                        break;
                        
                    default:
                        cell.textLabel.text = @"Test";
                        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
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
    switch (section) {
        case 0:
            return nil;
            break;
        case 1:
            return @"Комментарии";
            break;
        case 2:
            return @"Лайки";
            break;
        default:
            return @"Тест";
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (!section && !row) {
        return 320;
    }
    else {
        return 44;
    }
}

- (void)like {
    [_singleMediaProcessor likeInstagramMediaWithCompletion:^(BOOL completion) {
        if (completion) {
            _instagramMedia.userHasLiked = YES;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

- (void)unlike {
    [_singleMediaProcessor unlikeInstagramMediaWithCompletion:^(BOOL completion) {
        if (completion) {
            _instagramMedia.userHasLiked = NO;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

@end

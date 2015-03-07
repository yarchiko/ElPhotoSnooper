//
//  EPSFeedTableViewController.m
//  ElPhotoSnooper
//
//  Created by Mega on 07/03/15.
//  Copyright (c) 2015 8of. All rights reserved.
//

#import "EPSFeedTableViewController.h"
#import "EPSFeedStorage.h"
#import "EPSConstants.h"
#import "EPSFeedTableViewController.h"

@interface EPSFeedTableViewController ()

@property (strong, nonatomic) EPSFeedStorage *feedStorage;

@end

@implementation EPSFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _feedStorage = [[EPSFeedStorage alloc] init];
    BOOL isUserAuthed = [self isUserAuthed];
    if (!isUserAuthed) {
        [self performSegueWithIdentifier:SEGUE_TO_AUTH_SCREEN sender:self];
    }
}

- (BOOL)isUserAuthed {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:INSTAGRAM_USER_ACCESS_TOKEN];
    BOOL isAccessTokenBlank = [accessToken isEqualToString:@""];
    if (isAccessTokenBlank) {
        return NO;
    }
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FEED_CELL_REUSE_IDENTIFIER
                                                            forIndexPath:indexPath];
    
    
    return cell;
}

@end

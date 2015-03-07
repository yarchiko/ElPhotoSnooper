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

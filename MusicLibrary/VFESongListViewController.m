//
//  VFESongListViewController.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/13/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFESongListViewController.h"
#import "VFEModel.h"

@implementation VFESongListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Songs";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];

    VFESong *song = self.songs[indexPath.row];

    cell.textLabel.text = song.name;

    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

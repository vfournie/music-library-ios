//
//  VFEAlbumListViewController.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/13/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEAlbumListViewController.h"
#import "VFEModel.h"
#import "VFESongListViewController.h"

@implementation VFEAlbumListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Albums";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];

    VFEAlbum *album = self.albums[indexPath.row];

    cell.textLabel.text = album.name;

    if ([album.songs count] > 0) {
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pushSongs"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        VFEAlbum *album = self.albums[indexPath.row];
        VFESongListViewController *destVC = [segue destinationViewController];
        destVC.songs = [album sortedSongs];
    }
}

@end

//
//  VFEArtistListViewController.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEArtistListViewController.h"
#import <CoreData/CoreData.h>
#import "VFEArtist.h"
#import "VFEFetchedResultsTableDataSource.h"
#import "VFEModelManager.h"
#import "VFEModelImportOperation.h"
#import "VFEAlbumListViewController.h"

@interface VFEArtistListViewController () <UITableViewDelegate>

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) VFEFetchedResultsTableDataSource *dataSource;

@end

@implementation VFEArtistListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[VFEModelManager sharedManager] deleteDB];

    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.name = @"Import queue";

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VFEArtist entityName]];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:[VFEModelManager sharedManager].mainContext
                                                            sectionNameKeyPath:nil
                                                            cacheName:nil];
    UITableView *tableView = self.tableView;
    self.dataSource = [[VFEFetchedResultsTableDataSource alloc] initWithTableView:tableView
                                                         fetchedResultsController:fetchedResultsController
                                                                   cellIdentifier:@"ArtistCell"];
    self.dataSource.configureCellBlock = ^(UITableViewCell *cell, VFEArtist *artist) {
        cell.textLabel.text = artist.name;
        if (artist.albums.count > 0) {
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    };

    tableView.dataSource = self.dataSource;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pushAlbums"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        VFEArtist *artist = [self.dataSource itemAtIndexPath:indexPath];
        VFEAlbumListViewController *destVC = [segue destinationViewController];
        destVC.albums = [artist sortedAlbums];
    }
}

#pragma mark - Actions

- (IBAction)startImport:(id)sender
{
    self.progressView.progress = 0;
    self.cancelButton.enabled = YES;
    self.importButton.enabled = NO;

    VFEModelImportOperation *operation = [[VFEModelImportOperation alloc] init];
    operation.progressCallback = ^(float progress) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.progressView.progress = progress;

            if (progress == 1.0f) {
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    self.importButton.enabled = YES;
                    self.cancelButton.enabled = NO;
                    self.progressView.progress = 0.0f;
                });
            }
        }];
    };

    [self.operationQueue addOperation:operation];
}

- (IBAction)cancelImport:(id)sender
{
    [self.operationQueue cancelAllOperations];
    self.progressView.progress = 0;
    self.cancelButton.enabled = NO;
    self.importButton.enabled = YES;
}

- (IBAction)refresh:(id)sender
{
    [self.dataSource performFetch];
    [self.tableView reloadData];
}

@end

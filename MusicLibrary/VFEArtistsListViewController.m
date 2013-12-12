//
//  VFEArtistsListViewController.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEArtistsListViewController.h"
#import <CoreData/CoreData.h>
#import "VFEArtist.h"
#import "VFEFetchedResultsTableDataSource.h"
#import "VFEModelManager.h"
#import "VFEModelImportOperation.h"

@interface VFEArtistsListViewController () <UITableViewDelegate>

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) VFEFetchedResultsTableDataSource *dataSource;

@end

@implementation VFEArtistsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[VFEModelManager sharedManager] deleteDB];

    self.operationQueue = [[NSOperationQueue alloc] init];

    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VFEArtist entityName]];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[VFEModelManager sharedManager].mainContext sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    UITableView *tableView = self.tableView;
    self.dataSource = [[VFEFetchedResultsTableDataSource alloc] initWithTableView:tableView
                                                         fetchedResultsController:fetchedResultsController
                                                                   cellIdentifier:@"ArtistCell"
                                                               configureCellBlock:^(UITableViewCell *cell, VFEArtist *item) {
                                                                   cell.textLabel.text = item.name;
                                                               }];

    tableView.dataSource = self.dataSource;
}

#pragma mark - Actions

- (IBAction)startImport:(id)sender
{
    self.progressView.progress = 0;
    self.cancelButton.enabled = YES;
    self.importButton.enabled = NO;

    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"artists" ofType:@"csv"];
    VFEModelImportOperation *operation = [[VFEModelImportOperation alloc] initWithFileName:fileName
                                                                          progressCallback:^(float progress) {
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
                                                                          }
                                                                                modelClass:[VFEArtist class]];
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

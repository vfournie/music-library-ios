//
//  VFEFetchedResultsTableDataSource.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/12/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEFetchedResultsTableDataSource.h"
#import <CoreData/NSFetchedResultsController.h>

@interface VFEFetchedResultsTableDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) VFEConfigureCellBlock configureCellBlock;
@property (nonatomic, copy) NSString *cellIdentifier;

@end

@implementation VFEFetchedResultsTableDataSource

- (id)initWithTableView:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
         cellIdentifier:(NSString *)cellIdentifier
     configureCellBlock:(VFEConfigureCellBlock)configureCellBlock
{
    self = [super init];
    if(self) {
        _tableView = tableView;
        _fetchedResultsController = fetchedResultsController;
        _cellIdentifier = [cellIdentifier copy];
        _configureCellBlock = [configureCellBlock copy];
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.tableView.dataSource = self;
    self.fetchedResultsController.delegate = self;
    [self performFetch];
}

- (void)performFetch
{
    NSError *error;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    NSLog( @"fetchedObjects count : %d", [self.fetchedResultsController.fetchedObjects count]);
    if (success == NO) {
        NSLog(@"Unable to perform fetch : %@", error);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger i = [self.fetchedResultsController.sections[(NSUInteger)section] numberOfObjects];
    return i;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> info = [self.fetchedResultsController sections][(NSUInteger)section];
    return info.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[ indexPath ]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            if ([self.tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            }
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[ indexPath ]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

#pragma mark - Private

- (id)itemAtIndexPath:(NSIndexPath *)path
{
    return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:path.row inSection:path.section]];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path
{
    id item = [self itemAtIndexPath:path];
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item);
    }
}

@end

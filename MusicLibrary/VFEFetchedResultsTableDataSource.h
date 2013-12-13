//
//  VFEFetchedResultsTableDataSource.h
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/12/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VFEConfigureCellBlock)(UITableViewCell *cell, id item);

@class NSFetchedResultsController;

@interface VFEFetchedResultsTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) VFEConfigureCellBlock configureCellBlock;

- (id)initWithTableView:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
         cellIdentifier:(NSString *)cellIdentifier;

- (void)performFetch;

- (id)itemAtIndexPath:(NSIndexPath *)path;

@end

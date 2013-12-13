//
//  VFEModelImportOperation.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEModelImportOperation.h"
#import "VFEModelManager.h"
#import "VFEModel.h"
#import "NSString+CSV.h"

static const NSInteger ImportBatchSize = 500;
static const NSInteger ImportProgressGranularity = 250;

@interface VFEModelImportOperation ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation VFEModelImportOperation

- (void)main
{
    self.context = [[VFEModelManager sharedManager] createContextFromRootContext];

    [self.context performBlock:^{
        [self import];
    }];
}

- (void)saveContext
{
    NSError *error;
    BOOL success = [[VFEModelManager sharedManager] saveContext:self.context error:&error];

    if (success == NO) {
        NSLog(@"Unable to save context : %@", error);
    }
}

- (void)import
{
    NSDate *beginDate = [NSDate date];

    [self importArtists];
    [self importSongs];

    self.progressCallback(1);
    [self saveContext];

    NSLog(@"Imported done in %f s", ABS([beginDate timeIntervalSinceNow]));
}

- (void)importArtists
{
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"artists" ofType:@"csv"];
    [self importFileName:fileName modelClass:[VFEArtist class]];
}

- (void)importSongs
{
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"songs" ofType:@"csv"];
    [self importFileName:fileName modelClass:[VFESong class]];
}

- (void)importFileName:(NSString *)fileName modelClass:(Class<VFEImportableObject>)modelClass
{
    NSString *fileContents = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];
    NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger count = lines.count;
    NSInteger progressGranularity = ImportProgressGranularity;
    if (count > ImportProgressGranularity) {
        progressGranularity = count / ImportProgressGranularity;
    }
    __block NSInteger idx = -1;
    [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *shouldStop) {
        idx++;
        if (idx == 0) {
            // header line
            return;
        }

        if (self.isCancelled) {
            *shouldStop = YES;
            return;
        }

        NSArray *components = [line vfe_csvComponents];

        [modelClass importCSVComponents:components intoContext:self.context];

        if (idx % progressGranularity == 0) {
            self.progressCallback(idx / (float)count);
        }
        if (idx % ImportBatchSize == 0) {
            [self saveContext];
        }
    }];
}

@end

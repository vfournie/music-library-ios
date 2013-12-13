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
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) Class modelClass;

@end

@implementation VFEModelImportOperation

- (id)initWithFileName:(NSString *)fileName
            modelClass:(Class<VFEImportableObject>)modelClass
{
    self = [super init];
    if (self) {
        _fileName = [fileName copy];
        _modelClass = modelClass;
    }
    return self;
}

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

    NSString *fileContents = [NSString stringWithContentsOfFile:self.fileName encoding:NSUTF8StringEncoding error:NULL];
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

        [self.modelClass importCSVComponents:components intoContext:self.context];

        if (idx % progressGranularity == 0) {
            self.progressCallback(idx / (float)count);
        }
        if (idx % ImportBatchSize == 0) {
            [self saveContext];
        }
    }];
    self.progressCallback(1);
    [self saveContext];

    NSLog(@"Imported done in %f s", ABS([beginDate timeIntervalSinceNow]));
}

@end

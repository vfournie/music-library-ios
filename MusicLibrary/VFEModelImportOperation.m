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
static const NSInteger ImportProgressGranularity = 100;

@interface VFEModelImportOperation ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) VFEModelImportOperationProgress progressCallback;
@property (nonatomic, strong) Class modelClass;

@end

@implementation VFEModelImportOperation

- (id)initWithFileName:(NSString *)fileName
      progressCallback:(VFEModelImportOperationProgress)progressCallback
            modelClass:(Class<VFEImportableObject>)modelClass
{
    self = [super init];
    if (self) {
        _fileName = [fileName copy];
        _progressCallback = [progressCallback copy];
        _modelClass = modelClass;
        _context = [[VFEModelManager sharedManager] createPrivateContext];
    }
    return self;
}

- (void)main
{
    [self.context performBlockAndWait:^{
        [self import];
    }];
}

- (void)saveContext
{
    NSError *error;
    [self.context save:&error];
    if (error) {
        NSLog(@"Unable to save context : %@", error);
    }
}

- (void)import
{
    NSString *fileContents = [NSString stringWithContentsOfFile:self.fileName encoding:NSUTF8StringEncoding error:NULL];
    NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger count = lines.count;
    NSInteger progressGranularity = count/ImportProgressGranularity;
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
}

@end

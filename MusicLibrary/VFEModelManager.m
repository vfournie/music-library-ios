//
//  VFEModelManager.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEModelManager.h"

@interface VFEModelManager ()

@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) NSURL *storeURL;
@property (nonatomic, strong) NSPersistentStoreCoordinator *storeCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;

@end

@implementation VFEModelManager

+ (instancetype)sharedManager
{
    static VFEModelManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[VFEModelManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MusicLibrary" withExtension:@"momd"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MusicLibrary.sqlite"];
    return [self initWithStoreURL:storeURL modelURL:modelURL];
}

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL
{
    self = [super init];
    if (self) {
        _storeURL = storeURL;
        _modelURL = modelURL;
        [self initializeCoreDataStack];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}

- (NSManagedObjectContext *)createPrivateContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.storeCoordinator;
    context.undoManager = nil;
    return context;
}

#pragma mark - CoreData stack

- (void)initializeCoreDataStack
{
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];

    self.storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

    NSError *error;
    [self.storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                configuration:nil
                                                  URL:self.storeURL
                                              options:nil
                                                error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }

    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.persistentStoreCoordinator = self.storeCoordinator;
    self.mainContext.undoManager = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContextDidSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}

#pragma mark - Notification handle

- (void)handleContextDidSaveNotification:(NSNotification *)notif
{
    NSManagedObjectContext *moc = self.mainContext;
    if (notif.object != moc) {
        [moc performBlock:^(){
            [moc mergeChangesFromContextDidSaveNotification:notif];
        }];
    }
}

#pragma mark - Private methods

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

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
@property (nonatomic, strong, readwrite) NSManagedObjectContext *rootContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;

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
}

- (void)saveRootContext
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(rootContextChanged:)
//                                                 name:NSManagedObjectContextDidSaveNotification
//                                               object:self.rootContext];
    [self.rootContext performBlock:^{
        NSError *error = nil;

        BOOL success = [self.rootContext save:&error];
        if (success == NO) {
            NSLog(@"Unable to save the root context : %@", error);
        }

//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:NSManagedObjectContextDidSaveNotification
//                                                      object:self.rootContext];
        
    }];
}

- (void)deleteDB
{
    [self.mainContext performBlockAndWait:^{
        [self.mainContext reset];
    }];
    [self.rootContext performBlockAndWait:^{
        [self.rootContext reset];
    }];

    // effectively delete the database
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:self.storeURL.path error:&error]) {
        NSLog(@"Unable to delete the store : %@", error);
    }

    [self initializeCoreDataStack];
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

    self.rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.rootContext.persistentStoreCoordinator = self.storeCoordinator;
    self.rootContext.undoManager = nil;

    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.parentContext = self.rootContext;
    self.mainContext.undoManager = nil;
}

#pragma mark - Notification handle

- (void)rootContextChanged:(NSNotification *)notif
{
    NSManagedObjectContext *moc = self.mainContext;
    // Only interested in merging from root context into main context.
    if (notif.object == self.rootContext) {
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

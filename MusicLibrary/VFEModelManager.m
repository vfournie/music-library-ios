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

@interface VFEModelManagerImpl_NestedContexts : VFEModelManager

@end

@interface VFEModelManagerImpl_IndependentContexts : VFEModelManager

@end


@implementation VFEModelManager

+ (instancetype)sharedManager
{
    static VFEModelManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[VFEModelManagerImpl_NestedContexts alloc] init];
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


- (NSManagedObjectContext *)createContextFromRootContext
{
    return [self createContextFromParentContext:self.rootContext];
}

- (NSManagedObjectContext *)createContextFromMainContext
{
    return [self createContextFromParentContext:self.mainContext];
}

- (void)saveRootContext
{
    [self.rootContext performBlock:^{
        NSError *error = nil;

        BOOL success = [self.rootContext save:&error];
        if (success == NO) {
            NSLog(@"Unable to save the root context : %@", error);
        }
    }];
}

- (BOOL)saveContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    __block BOOL success;

    [context performBlockAndWait:^{
        success = [context save:error];
        if (success) {
            [context reset];
        }
    }];
    if (success) {
        [self saveRootContext];
    }
    return success;
}

- (void)deleteDB
{
    [self.mainContext performBlockAndWait:^{
        [self.mainContext reset];
    }];
    [self.rootContext performBlockAndWait:^{
        [self.rootContext reset];
    }];

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

    [self initializeContexts];
}

- (void)initializeContexts
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

#pragma mark - Private methods

- (NSManagedObjectContext *)createContextFromParentContext:(NSManagedObjectContext *)parentContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = parentContext;
    context.undoManager = nil;

    return context;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end


#pragma mark - VFEModelManagerImpl_IndependentContexts

@implementation VFEModelManagerImpl_NestedContexts

- (void)initializeContexts
{
    self.rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.rootContext.persistentStoreCoordinator = self.storeCoordinator;
    self.rootContext.undoManager = nil;

    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.parentContext = self.rootContext;
    self.mainContext.undoManager = nil;
}

@end


#pragma mark - VFEModelManagerImpl_IndependentContexts

@implementation VFEModelManagerImpl_IndependentContexts

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL
{
    self = [super initWithStoreURL:storeURL modelURL:modelURL];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rootContextChanged:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}

- (void)initializeContexts
{
    self.rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.rootContext.persistentStoreCoordinator = self.storeCoordinator;
    self.rootContext.undoManager = nil;

    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.persistentStoreCoordinator = self.storeCoordinator;
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

@end

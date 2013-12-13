//
//  VFEBaseObject.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEBaseObject.h"

@implementation VFEBaseObject

+ (NSString *)entityName
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

+ (instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:moc];
}

+ (void)importCSVComponents:(NSArray *)components intoContext:(NSManagedObjectContext *)moc
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

+ (instancetype)findOrCreateEntityName:(NSString *)entityName
                         forIdentifier:(NSString *)name
                             inContext:(NSManagedObjectContext *)moc
{
    __block VFEBaseObject *object;

    [moc performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        fetchRequest.fetchLimit = 1;

        NSError *error = nil;
        object = [[moc executeFetchRequest:fetchRequest error:&error] lastObject];
        if (error) {
            NSLog(@"Unable to fetch request : %@", error);
        }
        if (object == nil) {
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                   inManagedObjectContext:moc];
        }
    }];

    return object;
}

@end

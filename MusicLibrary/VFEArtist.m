//
//  Artist.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEArtist.h"

@implementation VFEArtist

@dynamic name;
@dynamic albums;
@dynamic songs;

+ (NSString *)entityName
{
    return @"VFEArtist";
}

+ (void)importCSVComponents:(NSArray *)components intoContext:(NSManagedObjectContext *)moc
{
    NSString *name = components[0];

    VFEArtist *artist = [self findOrCreateWithName:name inContext:moc];
    artist.name = name;
}

+ (instancetype)findOrCreateWithName:(NSString *)name inContext:(NSManagedObjectContext *)moc
{
    __block VFEArtist *artist;

    [moc performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        fetchRequest.fetchLimit = 1;

        NSError *error = nil;
        artist = [[moc executeFetchRequest:fetchRequest error:&error] lastObject];
        if (error) {
            NSLog(@"Unable to fetch request : %@", error);
        }
        if (artist == nil) {
            artist = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                   inManagedObjectContext:moc];
        }
    }];

    return artist;
}

@end

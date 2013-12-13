//
//  Song.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFESong.h"
#import "VFEAlbum.h"

@implementation VFESong

@dynamic name;
@dynamic album;
@dynamic artist;

+ (NSString *)entityName
{
    return @"VFESong";
}

+ (void)importCSVComponents:(NSArray *)components intoContext:(NSManagedObjectContext *)moc
{
    NSString *name = components[0];

    VFEAlbum *album = [self findOrCreateEntityName:[VFEAlbum entityName]
                                     forIdentifier:name
                                         inContext:moc];

    int count = components.count;
    if (count >= 1 ) {
        for (int i=1 ; i < count ; i++) {
            NSString *songName = components[i];
            VFESong *song = [self findOrCreateEntityName:[VFESong entityName]
                                           forIdentifier:songName
                                               inContext:moc];
            song.name = songName;
            song.album = album;
            song.artist = album.artist;
        }
    }
}

@end

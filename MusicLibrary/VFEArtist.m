//
//  Artist.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEArtist.h"
#import "VFEAlbum.h"

@implementation VFEArtist

@dynamic name;
@dynamic albums;
@dynamic songs;

- (NSArray *)sortedAlbums
{
    return [self.albums sortedArrayUsingDescriptors:@[
                                                      [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                                     ]];
}

- (NSArray *)sortedSongs
{
    return [self.songs sortedArrayUsingDescriptors:@[
                                                      [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                                    ]];
}

+ (NSString *)entityName
{
    return @"VFEArtist";
}

+ (void)importCSVComponents:(NSArray *)components intoContext:(NSManagedObjectContext *)moc
{
    NSString *name = components[0];

    VFEArtist *artist = [self findOrCreateEntityName:[VFEArtist entityName]
                                       forIdentifier:name
                                           inContext:moc];
    artist.name = name;

    int count = components.count;
    if (count >= 1 ) {
        for (int i=1 ; i < count ; i++) {
            NSString *albumName = components[i];
            VFEAlbum *album = [self findOrCreateEntityName:[VFEAlbum entityName]
                                             forIdentifier:albumName
                                                 inContext:moc];
            album.name = albumName;
            album.artist = artist;
        }
    }
}

@end

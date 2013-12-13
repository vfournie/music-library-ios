//
//  Album.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFEAlbum.h"

@implementation VFEAlbum

@dynamic name;
@dynamic artist;
@dynamic songs;

- (NSArray *)sortedSongs
{
    return [self.songs sortedArrayUsingDescriptors:@[
                                                     [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                                    ]];
}

+ (NSString *)entityName
{
    return @"VFEAlbum";
}

@end

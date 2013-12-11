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
@dynamic year;
@dynamic artist;
@dynamic songs;

+ (NSString *)entityName
{
    return @"VFEAlbum";
}

@end

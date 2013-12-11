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

@end

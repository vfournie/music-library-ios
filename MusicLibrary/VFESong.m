//
//  Song.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "VFESong.h"

@implementation VFESong

@dynamic name;
@dynamic album;
@dynamic artist;

+ (NSString *)entityName
{
    return @"VFESong";
}

@end

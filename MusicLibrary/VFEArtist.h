//
//  Artist.h
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VFEBaseObject.h"

@interface VFEArtist : VFEBaseObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSSet *albums;
@property (nonatomic, strong) NSSet *songs;

- (NSArray *)sortedAlbums;
- (NSArray *)sortedSongs;

@end

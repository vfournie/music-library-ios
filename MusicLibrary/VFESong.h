//
//  Song.h
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VFEBaseObject.h"

@class VFEAlbum, VFEArtist;

@interface VFESong : VFEBaseObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) VFEAlbum *album;
@property (nonatomic, strong) VFEArtist *artist;

@end

//
//  Album.h
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VFEBaseObject.h"

@class VFEArtist;

@interface VFEAlbum : VFEBaseObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *year;
@property (nonatomic, strong) VFEArtist *artist;
@property (nonatomic, strong) NSSet *songs;

@end

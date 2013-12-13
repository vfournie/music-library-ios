//
//  VFEBaseObject.h
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "VFEImportableObject.h"

@interface VFEBaseObject : NSManagedObject <VFEImportableObject>

+ (NSString *)entityName;

+ (instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc;

+ (instancetype)findOrCreateEntityName:(NSString *)entityName
                         forIdentifier:(NSString *)name
                             inContext:(NSManagedObjectContext *)moc;

@end

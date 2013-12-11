//
//  VFEImportableObject.h
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@protocol VFEImportableObject <NSObject>

+ (void)importCSVComponents:(NSArray *)components intoContext:(NSManagedObjectContext *)moc;

@end

//
//  VFEModelManager.h
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VFEModelManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;

+ (instancetype)sharedManager;

- (NSManagedObjectContext *)createPrivateContext;

@end

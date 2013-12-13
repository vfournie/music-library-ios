//
//  VFEModelImportOperation.h
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VFEImportableObject.h"

typedef void(^VFEModelImportOperationProgress)(float progress);

@interface VFEModelImportOperation : NSOperation

@property (nonatomic, copy) VFEModelImportOperationProgress progressCallback;

@end

//
//  NSString+CSV.m
//  MusicLibrary
//
//  Created by Vincent Fournié on 12/11/13.
//  Copyright (c) 2013 VFE. All rights reserved.
//

#import "NSString+CSV.h"

@implementation NSString (CSV)

- (NSArray *)vfe_csvComponents
{
    NSMutableArray *components = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSString *quote = @"\"";
    NSString *separator = @",";
    NSString *result;
    while (![scanner isAtEnd]) {
        if ([scanner scanString:quote intoString:NULL]) {
            [scanner scanUpToString:quote intoString:&result];
            [scanner scanString:quote intoString:NULL];
        }
        else {
            [scanner scanUpToString:separator intoString:&result];
        }
        [scanner scanString:separator intoString:NULL];
        [components addObject:result];
    }
    return components;
}

@end

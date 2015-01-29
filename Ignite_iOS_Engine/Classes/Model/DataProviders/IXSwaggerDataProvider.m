//
//  IXJSONDataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/6/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXSwaggerDataProvider.h"

#import "AFHTTPClient.h"
#import "AFOAuth2Client.h"

#import "IXAFJSONRequestOperation.h"
#import "IXAppManager.h"
#import "IXDataGrabber.h"
#import "IXLogger.h"
#import "IXViewController.h"
#import "IXSandbox.h"

@interface IXSwaggerDataProvider ()

@end

@implementation IXSwaggerDataProvider

-(void)calculateAndStoreDataRowResultsForDataRowPath:(NSString*)dataRowPath
{
    NSObject* jsonObject = nil;
    if( [dataRowPath length] <= 0 && [[super lastJSONResponse] isKindOfClass:[NSArray class]] )
    {
        jsonObject = [super lastJSONResponse];
    }
    else
    {
        jsonObject = [super objectForPath:dataRowPath container:[super lastJSONResponse]];
    }
    
    NSArray* rowDataResults = nil;
    if( [jsonObject isKindOfClass:[NSDictionary class]] )
    {
        NSDictionary* jsonDict = (NSDictionary*)jsonObject;
        rowDataResults = [self mediateSwaggerObject:jsonDict];
    }
    
    if( [jsonObject isKindOfClass:[NSArray class]] )
    {
        rowDataResults = (NSArray*)jsonObject;
    }
    
    if( rowDataResults )
    {
        NSPredicate* predicate = [self predicate];
        if( predicate )
        {
            rowDataResults = [rowDataResults filteredArrayUsingPredicate:predicate];
        }
        NSSortDescriptor* sortDescriptor = [self sortDescriptor];
        if( sortDescriptor )
        {
            rowDataResults = [rowDataResults sortedArrayUsingDescriptors:@[sortDescriptor]];
        }
    }
    
    if( [dataRowPath length] && rowDataResults != nil )
    {
        [[super rowDataResultsDict] setObject:rowDataResults forKey:dataRowPath];
    }
}

- (NSArray*)mediateSwaggerObject:(NSDictionary*)jsonDict {
    NSMutableArray* rowDataResults = [NSMutableArray new];
    if (jsonDict) {
        [[jsonDict allKeys] enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
            NSDictionary* path = jsonDict[key];
            
            NSMutableArray* methods = [NSMutableArray new];
            
            [[path allKeys] enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
                NSDictionary* method = path[key];
                [method setValue:key forKey:@"method"];
                [methods addObject:method];
            }];

            [path setValue:key forKey:@"path"];
            [path setValue:methods forKey:@"methods"];
            [rowDataResults addObject:path];
        }];
    }
    NSLog(@"%@", rowDataResults[0][@"methods"]);
    return rowDataResults;
}

@end

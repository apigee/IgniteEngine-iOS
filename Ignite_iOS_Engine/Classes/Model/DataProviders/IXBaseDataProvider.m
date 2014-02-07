//
//  IXBaseDataProvider.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseDataProvider.h"

#import "IXPropertyContainer.h"
#import "IXTableView.h"
#import "IXEntityContainer.h"

#import <RestKit/RestKit.h>

@interface IXBaseDataProvider ()

@end

@implementation IXBaseDataProvider

+(void)initialize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

-(id)init
{
    self = [super init];
    if( self )
    {
        _requestParameterProperties = [[IXPropertyContainer alloc] init];
        _requestHeaderProperties = [[IXPropertyContainer alloc] init];
        _fileAttachmentProperties = [[IXPropertyContainer alloc] init];
    }
    return self;
}

-(void)setSandbox:(IXSandbox *)sandbox
{
    [super setSandbox:sandbox];
    
    [_requestHeaderProperties setSandbox:sandbox];
    [_requestParameterProperties setSandbox:sandbox];
    [_fileAttachmentProperties setSandbox:sandbox];
}

-(void)applySettings
{
    [super applySettings];
    
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:@"auto_load" defaultValue:YES]];
    [self setDataLocation:[[self propertyContainer] getStringPropertyValue:@"data_location" defaultValue:nil]];
}

-(void)loadData:(BOOL)forceGet
{
    // Base Provider does nothing... Might need to update this.
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed
{
    if( loadDidSucceed )
    {
        [[self actionContainer] executeActionsForEventNamed:@"success"];
    }
    else
    {
        [[self actionContainer] executeActionsForEventNamed:@"fail"];
    }
    [[self actionContainer] executeActionsForEventNamed:@"finished"];
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:@"raw_data_response"] )
    {
        returnValue = [[self rawResponse] copy];
    }
    else if( [propertyName isEqualToString:@"status_code"] )
    {
        returnValue = [NSString stringWithFormat:@"%li",[self lastResponseStatusCode]];
    }
    else if( [propertyName isEqualToString:@"error_message"] )
    {
        returnValue = [[self lastResponseErrorMessage] copy];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

@end
